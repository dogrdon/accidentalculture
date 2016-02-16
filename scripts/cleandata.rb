#!/usr/bin/env ruby

#=begin
# for now taking the filtered all video and all audio json files
# and extracting only the information we need to understand 
# more about the providers of these objects
#=end

require 'json'
require 'csv'
require 'optparse'
require 'uri'


#defauls/tests
input = "../data/all_video.json"
output = "../data/all_video_trimmed.csv"

ARGV.options do |opts|
  opts.on("-o", "--output=val", String)   { |val| output = val }
  opts.on("-i", "--input=val", String)  { |val| input = val } 
  opts.parse!
end

file = File.read(input)
data = JSON.parse(file)

CSV.open(output, "wb") do |csv|
	headers = ["uri", "uri_host", "provider", "dpla_id", "view_format", "view_url", "title", "rights"]
	csv << headers
	data.each { |x| 
		source = x['_source']
		sourceResource = source['sourceResource']
		view = source['hasView']
		view_format = []
		view_url = []
		uri = source['isShownAt']
		if uri 
			if uri.include?(' ')
				uri = uri.sub(' ', '')
			end
			uri_host = URI.parse(uri).host
		else
			uri_host = nil
		end
		provider = source['provider']['@id']
		dpla_id = source['id']
		if view
			if view.class == Array
				view.each {|v| view_format << v['format']}
				view.each {|v| view_url << v['@id']}
				view_format.join(",")
				view_url.join(",")
			elsif view.class == Hash
				view_format = view['format']
				view_url = view['@id']
			end
		else
			view_format, view_url = nil
		end
		title = sourceResource['title']
		rights = sourceResource['rights']
		if rights.class == Array
			rights = rights.join(",")
		end

		csv << [uri, uri_host, provider, dpla_id, view_format, view_url, title, rights]

	}
end