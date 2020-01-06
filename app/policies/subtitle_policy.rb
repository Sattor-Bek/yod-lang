class SubtitlePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    true
  end

  def create?
    true
  end

  def show?
    true
  end

  def choose_book?
    true
  end

  private

  def user_is_owner_or_admin?
    record.user == user || user.admin if user != nil
  end
end
