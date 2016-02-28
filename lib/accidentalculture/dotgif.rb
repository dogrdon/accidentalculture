#!/usr/bin/env ruby

###
#once we've downloaded possibles, turn them into a gif and place them somewhere
###

require 'streamio-ffmpeg'
require 'json'
require ENV["HOME"]+'/accidentalculture/etc/conf/mongo_conf'

module DotGif
  def self.search_and_deploy
    puts "I AM STARTING TO MAKE THE GIF"
    storage = Store::MongoStore.new(MONGO_CONF[:host], MONGO_CONF[:port], MONGO_CONF[:database], MONGO_CONF[:collection])
    videopath = ENV["HOME"]+"/accidentalculture/tmp_v/"
    jsonpath = videopath + "*.json"
    gifpath = ENV["HOME"]+"/accidentalculture/gifs/"
    default_gif_len = "2" #2 seconds for the gif
  	#find one in tmp_v(based on score?)
    gifoptions = Hash.new
    
    Dir.glob(jsonpath) do |f|
      d = File.open(f).read
      j = JSON.parse(d)
      score = j['score']
      dpla = j['dpla_id']
      gifoptions[dpla] = score
    end
    puts gifoptions
    winner = gifoptions.max_by{|k,v| v}[0]

    #if winner alread in db, delete that from tmp_v and 
    #run search_and_deploy again. if nothing left, return nil.
    puts "Checking if #{winner} already in db..."
    begin
      if storage.checkpost(winner)
        puts "#{winner} is already in there" 
        gifoptions.delete(winner)
        if gifoptions.length == 0
          result = nil
          puts "we tried, but there is only one video for this search and it has already been used."
          return result
        else
          winner = gifoptions.max_by{|k,v| v}[0]
        end
      end
    rescue => e
      puts "this happened to your check: #{e}"
    end

    winnerpath = "#{videopath}#{winner}"
    begin
      video = FFMPEG::Movie.new(winnerpath)
    rescue => e
      puts "You got an error of #{e}, do you even ffmpeg?"
    end
    start = video.duration/2
    start = start.to_i.to_s

  	#filname is dpla_id+ss+t.gif
    giffile = "#{winner}_#{start}_#{default_gif_len}.gif"
    gifdest = "#{gifpath}#{giffile}" 

    transcode_options = {frame_rate: 15, resolution: "320x240", video_bitrate: 300, custom: "-ss #{start} -t #{default_gif_len}"}

    #TODO need error checking, can't do it like this ultimately
    puts "TRANSCODING NOW"
    transcoded = video.transcode(gifdest, transcode_options)
    puts "TRANSCODING COMPLETE"
    #return the id of winner, gif_file to the main
    record_path = "#{winner}.json"
    begin 
      puts "PACKING UP METADATA FOR WRAPPING UP."
      result = {_id: winner, gif: giffile, record: JSON.parse(File.open("#{videopath}#{record_path}").read)}
    rescue => e
      puts "Error packing up result: #{e}"
      result = nil
    end
    return result

  	
  end

end