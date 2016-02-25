#!/usr/bin/env ruby

###
#download what we have returned from search and cleaned
###

require 'nokogiri'
require 'capybara/poltergeist'	
require 'timeout'
require 'open-uri'
require 'open_uri_redirections'
require 'json'


module Download
	def self.checkHeaders(u)		
		uri = URI.parse(u)
		http = Net::HTTP.new(uri.host, uri.port)
		req = Net::HTTP::Get.new(uri.request_uri)
		res = http.request(req)
		ct = res.content_type	
		b = res.body

		#this check could be infinitely better.
		#might not even use this if we don't pull from
		#cdm providers that provide a shortcut .url file
		#instead of a video file.
		status = Hash.new
		if ct.include?('video')
			status[:ok] = true
			status[:with] = nil
		elsif ct.include?('application')
			status[:ok] = false
			status[:with] = b
		end
		return status	
	end

	def self.download(url, someid, v)
		path = "../tmp_v/#{someid}"
		#use timeout to cut of extra long downloads (over 30 sec is too much)
		begin
			timeout(120) do
				open(path, 'wb') do |f|
					puts "DOWNLOADING: #{url}"
					begin
						dl = open(url, :allow_redirections => :all)
						ct = dl.content_type #if this is wrong on the server, it will be wrong here.
						puts "#{url} is #{ct}" #for testing
			  			f << dl.read
			  			#also save metadata for file, so we can retrieve later
			  			md = path<<".json"
			  			open(md, 'wb') do |m|
			  				m.write(v.to_json)
			  			end
			  		rescue OpenURI::HTTPError => ex
			  			puts "Oops #{ex}"
			  			File.delete(path)
			  		end
				end
			end
		rescue Timeout::Error
			puts "#{url} is taking too long, probably way to large for our needs"
			File.delete(path)
		end
	end

	#only one of these will get used for a v
	#each one should return a url that is the direct resource location
	def self.getUrl(v, file_id)
		#this is pretty tied to `http://dp.la/api/contributor/georgia` right now,
		#but there are no other providers with this requirement currently in our
		#list of targets
		start_url = v[:original_url]
		resid = start_url.split(':')[-1]
		if start_url.include? "id:"
			url = v[:dl_info][:f4vpath] % resid
		elsif start_url.include? "do-mp4:"
			url = v[:dl_info][:mp4path] % resid
		else
			url = nil
		end
		
		if !url.nil?
			download url, file_id, v
		else
			puts "no pattern for URL: #{start_url}"
		end
	end

	def self.handleUrlShortcut(sc)
		#sometimes you are given back a url shortcut text file, parse this to see if blank or has location
		f = sc.lines
		url = f.find {|e| /URL/ =~ e}.split('=')[1].strip
	end

	def self.getCDM(v, file_id)

		#need to check if there is actually a video downloaded or a url shortcut file (and parse the latter)
		ourl = v[:original_url].sub('cdm/ref', 'utils/getstream')
		proceed = checkHeaders ourl
		url = proceed[:ok] == false ? handleUrlShortcut(proceed[:with]) : ourl

		if url != 'about:blank' && !url.nil?
			download url, file_id, v
		else
			puts "forget it, we won't be able to download from #{ourl}...moving on."
		end
	end

	def self.getSrc(v, file_id) 
		url = v[:original_url]
		puts "TRYING TO GET srcUrl for #{url}"
		browser_options = {:js_errors => false, :timeout => 60}
		Capybara.register_driver :poltergeist do |app|
			Capybara::Poltergeist::Driver.new(app, browser_options)
		end
		session = Capybara::Session.new(:poltergeist)
		#TODO - wrap this in begin, since it might fail
		session.visit url
		page = Nokogiri::HTML(session.html) #allowing all redirs is risky, but since we know where we are getting stuff from, it's okay for now.
		srcUrl = page.css(v[:dl_info][:path]).first[v[:dl_info][:sel]]
		download srcUrl, file_id, v
	end

	def self.download_videos(v)
		f = v[:dl_info][:type]
		fid = v[:dpla_id]
		send(f, v, fid)
	end
end