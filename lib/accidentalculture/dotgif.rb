#!/usr/bin/env ruby

###
#once we've downloaded possibles, turn them into a gif and place them somewhere
###

require 'streamio-ffmpeg'
require 'json'

module DotGif
  def self.search_and_deploy
    videopath = "../tmp_v/"
    jsonpath = videopath + "*.json"
    gifpath = "../gifs/"
    default_gif_len = "3" #3 seconds for the gif
  	#find one in tmp_v(based on score?)
    gifoptions = Hash.new
    Dir.glob(jsonpath) do |f|
      d = File.open(f).read
      j = JSON.parse(d)
      score = j['score']
      dpla = j['dpla_id']
      gifoptions[dpla] = score
    end

    puts gifoptions.class

    winner = gifoptions.max_by{|k,v| v}[0]
    winnerpath = "#{videopath}#{winner}"
    video = FFMPEG::Movie.new(winnerpath)

    start = video.duration/2
    start = start.to_i.to_s

  	#filname is dpla_id+ss+t.gif
    giffile = "#{winner}_#{start}_#{default_gif_len}.gif"
    gifdest = "#{gifpath}#{giffile}" 

    transcode_options = {frame_rate: 20, custom: "-ss #{start} -t #{default_gif_len}"}

    #TODO need error checking, can't do it like this ultimately
    transcoded = video.transcode(gifdest, transcode_options)
    #return the id of winner, gif_file to the main
    record_path = "#{winner}.json"
    begin 
      result = {_id: winner, gif: giffile, record: JSON.parse(File.open("#{videopath}#{record_path}").read)}
    rescue => e
      puts "THIS: #{e}"
      result = nil
    end
    return result

  	
  end

end