#!/usr/bin/env ruby

##
# Twitter connection and basic posting
##
require 'twitter'
require_relative ENV["HOME"]+'/accidentalculture/etc/conf/twitter_keys'

module Twitter
  def self.post_content(text, media, sensitive)
    config = TWIT_CONF
    client = Twitter::REST::Client.new(config)
    gif_path = ENV["HOME"]+'/accidentalculture/gifs/' << media
    client.update_with_media(text, File.new(gif_path), possibly_sensitive: sensitive)
  end
end