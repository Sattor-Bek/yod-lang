require 'uri'
require 'cgi'
require 'json'
require 'open-uri'

class GetVideoInfo
  def self.info_call_api(id)
    url = "https://www.googleapis.com/youtube/v3/videos?id=#{id}&key=#{ENV['GOOGLE_API_KEY']}&part=snippet,contentDetails,statistics,status"
    opened_url = open(url).read
    info = JSON.parse(opened_url)
    title = info["items"].first["snippet"]["title"]
    channel_title = info["items"].first["snippet"]["channelTitle"]
    { info: info, title: title, id: id, channel_title: channel_title }
  end
end
