  require 'uri'
  require 'cgi'
  require 'open-uri'
  require 'nokogiri'

class GetLanguageList
  def self.call_api(video_id)
    url = "http://video.google.com/timedtext?type=list&v=#{video_id}"
    file = open(url).read
    doc = Nokogiri::HTML(file)
    doc.css('transcript_list').children.map do |node|
      [node['lang_original'], node['lang_code']]
    end
  end
end
