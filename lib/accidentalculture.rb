#!/usr/bin/env ruby

require_relative 'accidentalculture/search'
require_relative 'accidentalculture/clean'
require_relative 'accidentalculture/download'
require_relative 'accidentalculture/word'
require_relative 'accidentalculture/twitter'
require_relative 'accidentalculture/dotgif'
require_relative 'accidentalculture/store'
require_relative '../etc/conf/api_keys'
require_relative '../etc/conf/mongo_conf'


if __FILE__ == $0

	$video_dir = '../tmp_v/*'


	def shut_it_down

		#delete tmp_v
		FileUtils.rm_rf(Dir.glob($video_dir))
	end

	def get_results
		searchterm = Word::get_word
		puts "search term is #{searchterm}"
		itemlimit = 25
		#set up for api, search
		__APIS__ = {:dpla=>"http://api.dp.la/v2/%s?api_key=#{API_KEYS[:dpla]}&%s"}
		c = Search::Client.new(__APIS__[:dpla])
		video_results = Clean::clean_results c.search(searchterm, '"moving image"', 'items', itemlimit)
		#here, video (and audio, soon) should be a list of potential sources with their relevant metadata
		#so depending on which document.dl_info.type it has, go get the video
		if video_results.nil?
			puts "Sorry, after much consideration of your request, there are no viable downloads for #{searchterm}"
			get_results
		else
			puts "Starting to download..."
			
			dl_result = video_results.length > 5 ? video_results.take(5).each{|v| Download::download_videos v} : video_results.each{|v| Download::download_videos v}
			
			if dl_result.length == 0
				get_results
			end
		end
	end

	begin

		while Dir[$video_dir].empty?
			get_results
		end

		#trigger gif
		gif_res = DotGif::search_and_deploy

		#with info returned from gif, pass to twitter
		if gif_res.class == Hash
			title = gif_res[:record]['source_resource']['title'].split[0...5].join(' ')
			title << "..."
			link = "http://dp.la/item/" << gif_res[:_id]
			text = "#{title} from #{link}"
			post = Twitter::post_content(text, gif_res[:gif])
			#add information brought back from twitter
			gif_res[:twitter_post_id] = post.id
			#save this to mongo
			begin
				storage = Store::MongoStore.new(MONGO_CONF[:host], MONGO_CONF[:port], MONGO_CONF[:database], MONGO_CONF[:collection])
				storage.insertdoc(gif_res)
			rescue => error
				puts "Something wrong happened when storing, and it was: #{error}"
			end
		else
			puts "No, I'm done, it didn't work, there's nothing to post, I'm sorry, Just try again later, I'm through *ugh*."
			shut_it_down
		end

		#when all done, clear out everything in tmp_v
		shut_it_down
	rescue
		shut_it_down
	end
	
end
