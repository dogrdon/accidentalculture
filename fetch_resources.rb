#!/usr/bin/env ruby

=begin
fetch audiovisual results from {dpla|internetarchive|nypl} for a given search term
=end

require 'rest-client'
require 'nokogiri'
require 'capybara/poltergeist'
require 'optparse'
require 'json'
require_relative 'config/api_keys'



#set up for api, search
__APIS__ = {"dpla"=>{"base"=>"http://api.dp.la/v2/", 
					 "items"=>"items", 
					 "params"=>{"api_key"=>API_KEYS['dpla']}
					 } 
		    }

class Client

	def initialize(service)
		@service = service
	end

	def clean_results(res)

	end

	def search(type, term, format)
		@type = @service[type]
		@params_hash = @service['params']
		@params_hash['q'] = term
		@params_hash['sourceResource.type'] = format
		url = @service['base'] + @type 
		res = RestClient.get url, {:params => @params_hash}
		puts res
	end


end

if __FILE__ == $0
	c = Client.new(__APIS__['dpla'])
	c.search('items', 'mice', '"moving image"')
end