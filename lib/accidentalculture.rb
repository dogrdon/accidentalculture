#!/usr/bin/env ruby

require_relative 'accidentalculture/search'
require_relative 'accidentalculture/clean'
require_relative 'accidentalculture/download'
require_relative '../config/api_keys'

if __FILE__ == $0


	if ARGV.empty?
		puts "You need to provide [term] and [itemlimit], or else your search is for dogs, with a limit of 50."
		exit
	end

	searchterm = ARGV[0]
	itemlimit = ARGV[1]

	#set up for api, search
	__APIS__ = {:dpla=>"http://api.dp.la/v2/%s?api_key=#{API_KEYS[:dpla]}&%s"}

	c = Search::Client.new(__APIS__[:dpla])
	video_results = Clean::clean_results c.search(searchterm, '"moving image"', 'items', itemlimit)
	#here, video (and audio, soon) should be a list of potential sources with their relevant metadata
	#so depending on which document.dl_info.type it has, go get the video
	if video_results.nil?
		puts "Sorry, after much consideration of your request, there are no viable downloads for #{searchterm}"
		exit
	else
		puts "Starting to download..."
		video_results.length > 5 ? video_results.take(5).each{|v| Download::download_videos v} : video_results.each{|v| Download::download_videos v}
	end
end
