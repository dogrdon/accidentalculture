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

__PATHS__ = {
	"http://dp.la/api/contributor/georgia" => "http://dlgmedia1-www.galib.uga.edu/wsbn-f4v/%s.f4v",
	"http://dp.la/api/contributor/nara"	   => "",
	""

}

class Client

	def initialize(service)
		@service = service
	end

	def clean_results(res)
		data = JSON.parse(res)
		docs = data['docs']
		docs.each do |d|
			puts d['provider']['name']
		end
	end

	def encode_params(params_hash)
		params_hash.map{|k,v| CGI.escape(k) + '=' + CGI.escape(v)}.join('&')
	end

	def search(term, format, type='items', limit=25)
		@type = type
		@params_hash = Hash.new
		#we're not necessarily going to know which params we can use here in future
		@params_hash['q'] = term
		@params_hash['sourceResource.type'] = format
		@params_hash['page_size'] = limit.to_s
		@params = encode_params @params_hash
		url = @service % [@type, @params]
		res = RestClient.get url
	end


end

if __FILE__ == $0
	c = Client.new(__APIS__[:dpla])
	video = c.clean_results c.search('mice', '"moving image"', 'items', 500)
	audio = c.clean_results c.search('mice', 'sound', 'items', 500)
end