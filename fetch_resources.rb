#!/usr/bin/env ruby

=begin
fetch audiovisual results from {dpla|internetarchive|nypl} for a given search term
=end

require 'rest-client'
require 'nokogiri'
require 'capybara/poltergeist'
require 'optparse'
require 'cgi'
require 'json'
require_relative 'config/api_keys'



#set up for api, search
__APIS__ = {:dpla=>"http://api.dp.la/v2/%s?api_key=#{API_KEYS['dpla']}&%s"}

class Client

	def initialize(service)
		@service = service
	end

	def clean_results(res)

	end

	def encode_params(params_hash)
		params_hash.map{|k,v| CGI.escape(k) + '=' + CGI.escape(v)}.join('&')
	end

	def search(type, term, format)
		@type = type
		@params_hash = Hash.new
		@params_hash['q'] = term
		@params_hash['sourceResource.type'] = format
		@params = encode_params @params_hash
		url = @service % [@type, @params]
		res = RestClient.get url
		puts res
	end


end

if __FILE__ == $0
	c = Client.new(__APIS__[:dpla])
	video = c.search('items', 'mice', '"moving image"')
	audio = c.search('items', 'mice', 'sound')
end