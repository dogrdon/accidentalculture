#!/usr/bin/env ruby

##
# Twitter connection and basic posting
##
require 'twitter'
require_relative '../../etc/conf/twitter_keys'

module Twitter
  def self.post_content(text, media)
    config = TWIT_CONF
    client = Twitter::REST::Client.new(config)
    gif_path = '../gifs/' << media
    client.update_with_media(text, File.new(gif_path))
  end
end