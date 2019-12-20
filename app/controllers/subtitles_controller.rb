class SubtitlesController < ApplicationController
  require 'addressable/uri'
  before_action :authorize_subtitle, only: [:index, :show, :new, :create]
  # before_action :set_subtitle, only: [:show, :edit, :update, :destroy]
  require 'addressable/uri'
  def show

  end

  def create
    url = subtitle_params[:video_id]
    if params[:language] == '日本語(ja)'
      language = 'ja'
    elsif params[:language] == 'ロシア語(ru)'
      language = 'ru'
    elsif params[:language] == 'ウズベク語(uz)'
      language = 'uz'
    else
      language = 'en'
    end

    begin
      video_id = Addressable::URI.parse(youtube_url)
      if video_id.path == "/watch"
        video_id.query_values["v"] if video_id.query_values
      else
        video_id.path
      end
      video_info = call_api(video_id)
      @subtitle = subtitle.find_or_create_by(language: language, video_id: video_id, user: current_user, video_title: video_info[:title]) do |subtitle|
        subtitle.assign_attributes(params_new[:subtitle])
      end
    rescue  Subtitle::MissingSubtitlesError
      @subtitle = Subtitle.new
      @subtitle.errors.add(:video_id, 'このビデオでは字幕が見つかりません。他のビデオをお試しください。')
    rescue NoMethodError
      @subtitle = Subtitle.new(video_id: url)
      @subtitle.errors.add(:video_id, '無効なURLです。')
    end

    authorize @subtitle

    if @subtitle.persisted?
      redirect_to subtitle_path(@subtitle)
    else
      render 'pages/home'
    end
  end

  def call_api(id)
    url = "https://www.googleapis.com/youtube/v3/videos?id=#{id}&key=#{ENV['GOOGLE_API_KEY']}&part=snippet,contentDetails,statistics,status"
    info = JSON.parse(RestClient.get(url).body)
    title = info["items"].first["snippet"]["title"]
    channel_title = info["items"].first["snippet"]["channelTitle"]
    { info: info, title: title, id: id, channel_title: channel_title }
  end

  private
  def authorize_subtitle
    authorize @subtitle
  end
  def subtitle_params
    params.require(:subtitle).permit(:video_id)
  end

  def set_subtitle
    @subtitle = Subtitle.find(params[:id])
  end
end
