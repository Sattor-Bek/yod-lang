class SubtitlesController < ApplicationController
  require 'uri'
  require 'cgi'
  require 'json'
  require 'open-uri'
  require 'nokogiri'

  # before_action :authorize_subtitle, only: [:show, :new, :create]
  before_action :set_subtitle, only: [:show, :edit, :update, :destroy]

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
      video_id = parse_youtube(url)
      video_info = info_call_api(video_id)
      @subtitle = Subtitle.find_or_create_by(language: language, video_id: video_id, user: current_user, video_title: video_info[:title]) do |subtitle|
          blocks_attributes = contents_call_api(video_id, language)
          contents = { subtitle: {
            blocks_attributes: blocks_attributes, language: language
          } }
          subtitle.assign_attributes(contents[:subtitle])
      end
    rescue Subtitle::MissingSubtitlesError
      @subtitle = Subtitle.new
      @subtitle.errors.add(:video_id, 'このビデオでは字幕が見つかりません。他のビデオをお試しください。')
            raise
    rescue NoMethodError
      @subtitle = Subtitle.new(video_id: url)
      @subtitle.errors.add(:video_id, '無効なURLです。')
      raise
    end

    authorize_subtitle

    if @subtitle.persisted?
      redirect_to subtitle_path(@subtitle)
    else
      render 'pages/home'
    end
  end


  def show
    authorize_subtitle
  end

  private

  def parse_youtube(url)
    u = URI.parse url
    if u.path =~ /watch/
      CGI::parse(u.query)["v"].first
    else
      u.path
    end
  end

  def info_call_api(id)
    url = "https://www.googleapis.com/youtube/v3/videos?id=#{id}&key=#{ENV['GOOGLE_API_KEY']}&part=snippet,contentDetails,statistics,status"
    opened_url = open(url).read
    info = JSON.parse(opened_url)
    title = info["items"].first["snippet"]["title"]
    channel_title = info["items"].first["snippet"]["channelTitle"]
    { info: info, title: title, id: id, channel_title: channel_title }
  end

  def contents_call_api(video_id, language)
    url = "http://video.google.com/timedtext?lang=#{language}&v=#{video_id}"
    file = open(url).read
    doc = Nokogiri::HTML(file)

    raise Subtitle::MissingSubtitlesError if doc.css("transcript text").empty?

    if language == 'en'
      array_elements = doc.css("transcript text").map do |node|
        clean_sentence = node.children.text.gsub(/\n/, ' ').gsub(/\(.*?\)/, '').gsub(/\[/, '').gsub(/\]/, '').gsub('&quot;', '').gsub('&#39;', "'")
        { start: node.attributes['start'].value, sentence: clean_sentence }
      end

      array_elements.delete_if {|hash| hash[:sentence].blank? }

      sentences_array = array_elements.map do |hash_sentence|
        "[#{hash_sentence[:start]}] #{hash_sentence[:sentence]}"
      end

      segmented = PragmaticSegmenter::Segmenter.new(text: sentences_array.join(" ")).segment

      prev = nil
      segmented.map do |sentence|
        regex_match = sentence.match(/\[\d*?\.?\d*?\]/)

        prev = regex_match[0].gsub(/\[|\]/, '') if regex_match.present?
        {
          start_timestamp: prev,
          sentence: sentence.gsub(/\[\d*?\.?\d*?\] /, '').strip
        }
      end
    elsif language == 'ja'
      array_elements = doc.css("transcript text").map do |node|
        clean_sentence = node.children.text.gsub(/\n/, ' ')
        clean_sentence += "。"
        { start: node.attributes['start'].value, sentence: clean_sentence }
      end

      array_elements.delete_if {|hash| hash[:sentence].blank? }

      sentences_array = array_elements.map do |hash_sentence|
        "[#{hash_sentence[:start]}] #{hash_sentence[:sentence]}"
      end

      segmented = PragmaticSegmenter::Segmenter.new(text: sentences_array.join(" "), language: 'ja').segment
      prev = nil
      segmented.map do |sentence|
        sentence.gsub!('。', ' ')
        regex_match = sentence.match(/\[\d*?\.?\d*?\]/)

        prev = regex_match[0].gsub(/\[|\]/, '') if regex_match.present?
        {
          start_timestamp: prev,
          sentence: sentence.gsub(/\[\d*?\.?\d*?\] /, '').strip
        }
      end
    end
  end

  def authorize_subtitle
    authorize @subtitle
  end

  def subtitle_params
    params.require(:subtitle).permit(:video_id)
  end

  def set_subtitle
    @subtitle = Subtitle.find_by(video_id: params[:video_id])
  end
end
