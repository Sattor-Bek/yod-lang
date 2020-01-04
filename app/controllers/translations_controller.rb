class TranslationsController < ApplicationController
  require 'uri'
  require 'cgi'
  require 'json'
  require 'open-uri'
  require 'nokogiri'

  # before_action :authorize_translation, only: [:show, :new, :create]
  before_action :set_translation, only: [:show, :edit, :update]

  def create
    url = params[:subtitle_url_id]
    if params[:language] == '日本語(ja)'
      language = 'ja'
    elsif params[:language] == 'ロシア語(ru)'
      language = 'ru'
    elsif params[:language] == 'ウズベク語(uz)'
      language = 'uz'
    elsif params[:language] == 'フランス語(fr)'
      language = 'fr'
    elsif params[:language] == 'ブルトン語(br)'
      language = 'br'
    elsif params[:language] == 'スペイン語(es)'
      language = 'es'
    elsif params[:language] == 'タジク語(tg)'
      language = 'tg'
    elsif params[:language] == 'デンマーク語(da)'
      language = 'da'
    else
      language = 'en'
    end
    begin
      video_id = parse_youtube(url)
      url_id = "(#{language})#{video_id}"
      video_info = info_call_api(video_id)
      @translation = Subtitle.find_or_create_by(language: language, video_id: video_id, user: current_or_guest_user, video_title: video_info[:title], url_id: url_id) do |translation|
          blocks_attributes = contents_call_api(video_id, language)
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

      @blocks = Block.where(subtitle_id: @translation.id)
      respond_to do |format|
          format.html
          format.csv { send_data @blocks.as_csv(@blocks) }
      end
    else
      skip_authorization
      redirect_to subtitle_path(@subtitle)
    end
  end

  private

  def parse_youtube(url)
    url.split("").drop(4).join("")
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
        clean_sentence = node.children.text.gsub(/\n/, ' ').gsub(/\(.*?\)/, '').gsub(/\[/, '').gsub(/\]/, '').gsub('&quot;', '"').gsub('&#39;', "'").gsub('<i>', '').gsub('</i>', '').gsub('<b>', '').gsub('</b>', '').gsub('<strong>', '').gsub('</strong>', '')
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
    elsif language == 'ru'
      array_elements = doc.css("transcript text").map do |node|
        clean_sentence = node.children.text.gsub(/\n/, ' ').gsub(/\(.*?\)/, '').gsub(/\[/, '').gsub(/\]/, '').gsub('<i>', '').gsub('</i>', '').gsub('<b>', '').gsub('</b>', '').gsub('<strong>', '').gsub('</strong>', '')
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
    elsif language == 'fr'
      array_elements = doc.css("transcript text").map do |node|
        clean_sentence = node.children.text.gsub(/\n/, ' ').gsub(/\(.*?\)/, '').gsub(/\[/, '').gsub(/\]/, '').gsub('&quot;', '"').gsub('&#39;', "'").gsub('<i>', '').gsub('</i>', '').gsub('<b>', '').gsub('</b>', '').gsub('<strong>', '').gsub('</strong>', '')
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
    elsif language == 'br'
      array_elements = doc.css("transcript text").map do |node|
        clean_sentence = node.children.text.gsub(/\n/, ' ').gsub(/\(.*?\)/, '').gsub(/\[/, '').gsub(/\]/, '').gsub('&quot;', '"').gsub('&#39;', "'").gsub('<i>', '').gsub('</i>', '').gsub('<b>', '').gsub('</b>', '').gsub('<strong>', '').gsub('</strong>', '')
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
