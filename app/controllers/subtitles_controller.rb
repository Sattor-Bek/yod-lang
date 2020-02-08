class SubtitlesController < ApplicationController
  require 'uri'
  require 'cgi'
  require 'json'
  require 'open-uri'
  require 'nokogiri'
  # before_action :authorize_subtitle, only: [:show, :new, :create]
  before_action :set_subtitle, only: [:show, :edit, :update, :destroy, :result]
  skip_after_action :verify_policy_scoped, :only => :index

  def create
    url = params[:subtitle][:video_id]
    video_id = parse_url(url)
    url_id = video_id
    video_info = GetVideoInfo.call_api(video_id)
    language_list = GetLanguageList.call_api(video_id)
    @subtitle = Subtitle.find_or_create_by(video_id: video_id,
                              user: current_or_guest_user,
                              video_title: video_info[:title],
                              url_id: url_id,
                              language_list: language_list)
    authorize_subtitle
    redirect_to subtitle_path(@subtitle)
  end

  def edit
  end

  def update
    language = params[:language]
    video_id = params[:url_id]
    url_id = "(#{language})#{video_id}"
    video_id = @subtitle.video_id
    user = @subtitle.user
    video_title = @subtitle.video_title
    language_list = @subtitle.language_list
    begin
      # video_id = parse_youtube(url)
      @subtitle = Subtitle.find_or_create_by(language: language,
                                              video_id: video_id,
                                              user: user,
                                              video_title: video_title,
                                              url_id: url_id,
                                              language_list: language_list) do |subtitle|
          blocks_attributes = GetSubtitle.call_api(video_id, language)
          contents = { subtitle: {
            blocks_attributes: blocks_attributes, language: language
          } }
          subtitle.assign_attributes(contents[:subtitle])
      end
    rescue Subtitle::MissingSubtitlesError
      @subtitle = Subtitle.new
      @subtitle.errors.add(:video_id, 'この動画では字幕が見つかりません。他の動画をお試しください。')
    rescue NoMethodError
      @subtitle = Subtitle.new(video_id: url)
      @subtitle.errors.add(:video_id, '無効なURLです。')
    end

    authorize_subtitle

    if @subtitle.persisted?
      redirect_to subtitle_path(@subtitle)
    elsif @subtitle == nil
      redirect_to root_path notice:'字幕を取得できませんでした。'
    else
      render 'pages/home'
    end
  end

  def show
    authorize_subtitle

    @translation = Translation.new
    @blocks = Block.where(subtitle_id: @subtitle.id)

    respond_to do |format|
        format.html
        format.csv { send_data @blocks.as_csv(@blocks) }
    end
  end

  def index
    redirect_to root_path
  end

  private

  # def parse_youtube(url)
  #   u = URI.parse url
  #   if u.path =~ /watch/
  #     CGI::parse(u.query)["v"].first
  #   else
  #     u.path
  #   end
  # end

  def parse_url(url)
    regex = /(?:.be\/|\/watch\?v=|\/(?=p\/))([\w\/\-]+)/
    url != "" ? url.match(regex)[1] : redirect_to root_path notice:'字幕を取得できませんでした。'
  end

  def authorize_subtitle
    authorize @subtitle
  end

  def subtitle_params
    params.require(:subtitle).permit(:video_id, :language)
  end

  def set_subtitle
    @subtitle = Subtitle.find_by(url_id: params[:url_id])
  end
end
