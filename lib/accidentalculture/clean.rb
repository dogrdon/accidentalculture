#!/usr/bin/env ruby

###
#clean things up in the returned search results
###

require 'json'

module Clean	

	#getUrl takes: returns: PARTIAL download URL with params and based on a specific URL patter.
	#getSrc takes: returns: FULL download URL from HTML
	#getCDM takes: original url returns: FULL download URL from CDM
	$VPATHS = {
		"http://dp.la/api/contributor/georgia" => {:type => "getUrl", :hosts => ["dlg.galileo.usg.edu"], :f4vpath => "http://dlgmedia1-www.galib.uga.edu/wsbn-f4v/%s.f4v", :mp4path => "http://dlgmedia1-www.galib.uga.edu/gfc/mp4/%s.mp4"}, 
		"http://dp.la/api/contributor/usc" => {:type => "getCDM", :hosts => ["digitallibrary.usc.edu"], :path => nil},
		"http://dp.la/api/contributor/nara"	   => {:type => "getSrc", :hosts => ["research.archives.gov"], :path => "a#downloadVideoAudio", :sel => "href"},
		"http://dp.la/api/contributor/digitalnc" => {:type => "getSrc", :hosts => ["digital.lib.ecu.edu"], :path =>  "video source[type='video/mp4']", :sel =>"href"},
		"http://dp.la/api/contributor/washington" => {:type => "getCDM", :hosts => ["cdm16786.contentdm.oclc.org"], :path =>  nil}
	}

	def self.check_result(d)
		#before creating the result, want to ensure 2 things
		#1) doc has a provider in $VPATHS
		#2) for that provider in $VPATHS, host is in :hosts
		providers = $VPATHS.keys
		provider = d['provider']['@id']
		host = URI.parse(d['isShownAt']).host
		if providers.include?(provider)
			if $VPATHS[provider][:hosts].include?(host)
				r = Hash.new
				r = {
						:provider_id => d['provider']['@id'], 
						:provider_name => d['provider']['name'],
						:dl_info => $VPATHS[d['provider']['@id']],
						:source_resource => d['sourceResource'],
						:dpla_id => d['id'],
						:original_url => d['isShownAt'], 
						:score => d['score']
				}
				return r
			else
				puts "NO HOST MATCH for #{host}"
				return nil	
			end
		else
			puts "NO PROVIDER MATCH FOR #{provider}"
			return nil
		end
	end

	def self.clean_results(res)
		data = JSON.parse(res)
		if data['count'] == 0
			results = nil
		else
			docs = data['docs']
			results = Array.new
			docs.each do |d|
				
				result = check_result d
				#looks bad to ignore rights, but currently not allowing any providers that are 
				#very stringent about not reusing the material, unrestricted only referes to nara.
				results << result if !result.nil? #&& result[:source_resource]['rights'][0].downcase == 'unrestricted'
			end
		end
		return results
	end
end