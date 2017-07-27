#!/usr/bin/env ruby

###
#once we've downloaded possibles, turn them into a gif and place them somewhere
###

require 'streamio-ffmpeg'
require 'json'
require 'aws-sdk'
require ENV["HOME"]+'/accidentalculture/etc/conf/mongo_conf'
require ENV["HOME"]+'/accidentalculture/etc/conf/aws_conf'


module DotGif

  AWS_S3 = Aws::S3::Resource.new(
  region: AWS_CONF[:region],
  access_key_id: AWS_CONF[:access_key_id],
  secret_access_key: AWS_CONF[:secret_access_key]
  )

  def self.pick_start(duration)
    if duration <= 3
      start = 0
    else
      last = duration - 3
      start = rand(0..last)
    end

    return start.to_i.to_s
  end

  def self.search_and_deploy
    puts "I AM STARTING TO MAKE THE GIF"
    storage = Store::MongoStore.new(MONGO_CONF[:host], MONGO_CONF[:port], MONGO_CONF[:database], MONGO_CONF[:collection])
    videopath = ENV["HOME"]+"/accidentalculture/tmp_v/"
    jsonpath = videopath + "*.json"
    gifpath = ENV["HOME"]+"/accidentalculture/gifs/"
    default_gif_len = "3" # how many seconds for the gif
    gifoptions = Hash.new
    
    Dir.glob(jsonpath) do |f|
      d = File.open(f).read
      j = JSON.parse(d)
      score = j['score']
      dpla = j['dpla_id']
      gifoptions[dpla] = score
    end

    puts 'gif options are: #{gifoptions}'
    winner = gifoptions.max_by{|k,v| v}[0]
    puts 'the winner is #{winner}'

    # trying without checking the db
    # shaking it up so much, should rarely get repeats
    begin
      if gifoptions.length == 0
        result, winner = nil
        puts "we tried, but there are not videos for this search."
        return result
      else
        winner = gifoptions.max_by{|k,v| v}[0]
      end
    rescue => e
      puts "this happened to your check: #{e}"
    end

    if !winner.nil?
      winnerpath = "#{videopath}#{winner}"
      begin
        video = FFMPEG::Movie.new(winnerpath)
      rescue => e
        puts "You got an error of #{e}, do you even ffmpeg?"
      end
      duration = video.duration
      start = pick_start(duration)

    	#filname is dpla_id+ss+t.gif
      gifid = "#{winner}_#{start}"
      giffile = "#{gifid}_#{default_gif_len}.gif"
      gifdest = "#{gifpath}#{giffile}" 

      transcode_options = {frame_rate: 15, resolution: "320x240", video_bitrate: 300, custom: "-ss #{start} -t #{default_gif_len}"}

      #TODO need error checking, can't do it like this ultimately
      puts "TRANSCODING NOW"
      transcoded = video.transcode(gifdest, transcode_options)
      puts "TRANSCODING COMPLETE"
      puts "SAVING TO AWS S3..."
      obj = AWS_S3.bucket('dpladotgif').object(giffile)
      obj.upload_file(gifdest)
      
      #return the id of winner, gif_file to the main
      record_path = "#{winner}.json"
      begin 
        puts "PACKING UP METADATA FOR WRAPPING UP."
        result = {_id: gifid, gif: giffile, video_duration: duration, record: JSON.parse(File.open("#{videopath}#{record_path}").read)}
      rescue => e
        puts "Error packing up result: #{e}"
        result = nil
      end
    end
    return result

  	
  end

end
