  require 'uri'
  require 'cgi'
  require 'json'
  require 'open-uri'
  require 'nokogiri'

class GetTranslation
  def self.contents_call_api(video_id, language)
    url = "http://video.google.com/timedtext?lang=#{language}&v=#{video_id}"
    file = open(url).read
    doc = Nokogiri::HTML(file)

    raise Subtitle::MissingSubtitlesError if doc.css("transcript text").empty?

    if language == 'ja'
      array_elements = doc.css("transcript text").map do |node|
        clean_sentence = node.children.text.gsub(/\n/, ' ').gsub(/\(.*?\)/, '').gsub(/\[/, '').gsub(/\]/, '').gsub('&quot;', '"').gsub('&#39;', "'").gsub(/<[^<>]*>/, '').gsub('&nbsp;', '').gsub('&lt;', '<').gsub('&gt;', '').gsub('&amp;', '&')
        { start: node.attributes['start'].value, sentence: clean_sentence }
      end

      array_elements.delete_if {|hash| hash[:sentence].blank? }

      sentences_array = array_elements.map do |hash_sentence|
        "[#{hash_sentence[:start]}] #{hash_sentence[:sentence]}"
      end

      prev = nil
      sentences_array.map do |sentence|
        sentence.gsub!('。', ' ')
        regex_match = sentence.match(/\[\d*?\.?\d*?\]/)

        prev = regex_match[0].gsub(/\[|\]/, '') if regex_match.present?
        {
          start_timestamp: prev,
          sentence: sentence.gsub(/\[\d*?\.?\d*?\] /, '').strip
        }
      end
    else
      array_elements = doc.css("transcript text").map do |node|
          clean_sentence = node.children.text.gsub(/\n/, ' ').gsub(/\(.*?\)/, '').gsub(/\[/, '').gsub(/\]/, '').gsub('&quot;', '"').gsub('&#39;', "'").gsub(/<[^<>]*>/, '').gsub('&nbsp;', '').gsub('&lt;', '<').gsub('&gt;', '').gsub('&amp;', '&')
          { start: node.attributes['start'].value, sentence: clean_sentence }
      end
      array_elements.delete_if {|hash| hash[:sentence].blank? }

      sentences_array = array_elements.map do |hash_sentence|
          "[#{hash_sentence[:start]}] #{hash_sentence[:sentence]}"
      end

      prev = nil
      sentences_array.map do |sentence|
        regex_match = sentence.match(/\[\d*?\.?\d*?\]/)

        prev = regex_match[0].gsub(/\[|\]/, '') if regex_match.present?
        {
          start_timestamp: prev,
          sentence: sentence.gsub(/\[\d*?\.?\d*?\] /, '').strip
        }
      end
    end
  end
end
