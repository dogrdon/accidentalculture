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

__TERM__ = ARGV[0]
__LIMIT__ = ARGV[1]

#set up for api, search
__APIS__ = {:dpla=>"http://api.dp.la/v2/%s?api_key=#{API_KEYS[:dpla]}&%s"}

__VPATHS__ = {
	"http://dp.la/api/contributor/georgia" => "http://dlgmedia1-www.galib.uga.edu/wsbn-f4v/%s.f4v",
	"http://dp.la/api/contributor/nara"	   => ""
}

__APATHS__ = {}

class Client

	def initialize(service)
		@service = service
	end

	def clean_results(res)
		data = JSON.parse(res)
		if data['count'] == 0
			results = "no results"
		else
			docs = data['docs']
			results = Hash.new
			docs.each do |d|
				results[d['provider']['@id']] = d['provider']['name']
			end
		end
		puts results.inspect
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
		puts url
		res = RestClient.get url
	end


end

if __FILE__ == $0
	c = Client.new(__APIS__[:dpla])
	video = c.clean_results c.search(__TERM__, '"moving image"', 'items', __LIMIT__)
	audio = c.clean_results c.search(__TERM__, 'sound', 'items', __LIMIT__)
end