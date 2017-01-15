#!/usr/bin/env ruby

###
#provides the search client to dpla
###

require 'cgi'
require 'open-uri'

module Search

	class Client

		def initialize(service)
			@service = service
		end

		def encode_params(params_hash)
			params_hash.map{|k,v| CGI.escape(k) + '=' + CGI.escape(v)}.join('&')
		end

		def search(term, format, type='items', limit=25)
			@type = type
			@params_hash = Hash.new
			@params_hash['q'] = term
			@params_hash['sourceResource.type'] = format
			@params_hash['page_size'] = limit.to_s
			@params = encode_params @params_hash
			url = @service % [@type, @params]
			puts "Your search is: #{url}"
			res = open(url).read
		end
	end
end