class ApplicationController < ActionController::Base
  require 'csv'
    # [...]
  before_action :authenticate_user!
  include Pundit

  # Pundit: white-list approach.
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # Uncomment when you *really understand* Pundit!
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # def user_not_authorized
  #   flash[:alert] = "You are not authorized to perform this action."
  #   redirect_to(root_path)
  # end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) << :user_name
    devise_parameter_sanitizer.for(:sign_up) << :user_name
    devise_parameter_sanitizer.for(:account_update) << :user_name
  end

  # ログインしている場合は、 current_userを返す / していない場合は guest_user を返す
  # current_userを置き換えることにより、Guestと通常のユーザーを透過的に扱えるようになる
  def current_or_guest_user
    if current_user
      if session[:guest_user_id] && session[:guest_user_id] != current_user.id
        logging_in
        guest_user(with_retry = false).try(:destroy)
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end

  # 現在のセッションと関連づく guest_user オブジェクトを探す
  def guest_user(with_retry = true)
    @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)
  rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
     session[:guest_user_id] = nil
     guest_user if with_retry
  end

  def guest_user?
    current_user && current_user.guest?
  end

  # ログインしていない、もしくは、Guestユーザーの場合、ルートにリダイレクトする
  def authenticate_no_user_or_guest!
    redirect_to root_url if current_user.nil? || guest_user?
  end

  # # ユーザーがログインした際に一度だけ呼ばれる
  # # 通常のユーザーが作成され、Guestユーザーは削除されるので、
  # # Guest時に作成したデータを通常のユーザーに渡すなどの処理をする
  def logging_in
    # taskのuser_idをGuestから通常のユーザーに移す
    guest_user.move_to(current_user)
  end

  # Guestユーザーを作成する
  def create_guest_user
    guest = User.new_guest
    guest.save!(:validate => false)
    session[:current_user_id] = guest.id
    guest
  end
end
