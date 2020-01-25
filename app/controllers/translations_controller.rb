class TranslationsController < ApplicationController
  require 'uri'
  require 'cgi'
  require 'json'
  require 'open-uri'
  require 'nokogiri'

  # before_action :authorize_translation, only: [:show, :new, :create]
  before_action :set_translation, only: [:show, :edit, :update]
  skip_after_action :verify_policy_scoped, :only => :index

  def create
    url = params[:subtitle_url_id]
    language = params[:language]
    begin
      video_id = parse_youtube(url)
      url_id = "(#{language})#{video_id}"
      video_info = GetVideoInfo.call_api(video_id)
      language_list = GetLanguageList.call_api(video_id)
      @translation = Subtitle.find_or_create_by(language: language, video_id: video_id, user: current_or_guest_user, video_title: video_info[:title], url_id: url_id, language_list: language_list) do |translation|
          blocks_attributes = GetSubtitle.call_api(video_id, language)
          contents = { subtitle: {
            blocks_attributes: blocks_attributes, language: language
          } }
          translation.assign_attributes(contents[:subtitle])
      end
    rescue Subtitle::MissingSubtitlesError
      @subtitle = Subtitle.new
      @subtitle.errors.add(:video_id, 'この動画では字幕が見つかりません。他の動画をお試しください。')
    rescue NoMethodError
      @subtitle = Subtitle.new(video_id: url)
      @subtitle.errors.add(:video_id, '無効なURLです。')
    end

    @subtitle = Subtitle.find_by(url_id: params[:subtitle_url_id])
    if @translation != nil
      authorize_translation
      if @translation.persisted?
        redirect_to subtitle_translation_path(@subtitle, @translation)
      elsif @translation == nil
        redirect_to subtitle_path(@subtitle)
      end
    else
      skip_authorization
      redirect_to subtitle_path(@subtitle)
    end

  end

  def show
    if @translation != nil

      authorize_translation
      @subtitle = Subtitle.find_by(url_id: params[:subtitle_url_id])
      @sub_blocks = Block.where(subtitle_id: @subtitle.id)
      @trans_blocks = Block.where(subtitle_id: @translation.id)
      respond_to do |format|
          format.html
          format.csv { send_data Block.to_csv(@sub_blocks, @trans_blocks) }
      end
    else
      skip_authorization
      redirect_to subtitle_path(@subtitle)
    end
  end

  def index
    redirect_to subtitle_path(@subtitle)
  end

  private

  def parse_youtube(url)
    url.split("").drop(4).join("")
  end

  def authorize_translation
    authorize @translation
  end

  def translation_params
    params.require(:translation).permit(:language, :subtitle_url_id)
  end

  def set_translation
    @translation = Subtitle.find_by(url_id: params[:url_id])
  end

end
