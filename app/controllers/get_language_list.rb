  require 'uri'
  require 'cgi'
  require 'open-uri'
  require 'nokogiri'

class GetLanguageList
  def self.call_api(video_url)
    video_id = parse_url(video_url)
    url = "http://video.google.com/timedtext?type=list&v=#{video_id}"
    file = open(url).read
    doc = Nokogiri::HTML(file)

    raise Subtitle::MissingSubtitlesError if doc.css("transcript text").empty?

    doc.css('transcript text').map do |node|
      { choice: node.attributes['lang_original'].value,
        value: node['lang_code'].value }
    end
  end

  def parse_url(video_url)
    regex = /(?:.be\/|\/watch\?v=|\/(?=p\/))([\w\/\-]+)/
    url.match(regex)[1]
  end
end
