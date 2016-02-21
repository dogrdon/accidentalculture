#!/usr/bin/env ruby

=begin
fetch audiovisual results from {dpla|internetarchive|nypl} for a given search term
=end

require 'rest-client'
require 'nokogiri'
require 'capybara/poltergeist'
require 'optparse'
require 'open-uri'
require 'open_uri_redirections'
require 'net/http' 
require 'cgi'
require 'json'
require 'timeout'

require_relative 'config/api_keys'

if ARGV.empty?
	puts "You need to provide [term] and [itemlimit], or else your search is for dogs, with a limit of 50."
	exit
end

searchterm = ARGV[0]
itemlimit = ARGV[1]

#set up for api, search
__APIS__ = {:dpla=>"http://api.dp.la/v2/%s?api_key=#{API_KEYS[:dpla]}&%s"}

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

class Client

	def initialize(service)
		@service = service
	end

	def check_result(d)
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
						:original_url => d['isShownAt']
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

	def clean_results(res)
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
		puts "Your search is: #{url}"
		res = RestClient.get url
	end
end

def download_videos(v)
	def checkHeaders(u)
		
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

	def download(url, someid)
		path = "./tmp_v/#{someid}"
		#use timeout to cut of extra long downloads (over 30 sec is too much)
		begin
			timeout(30) do
				open(path, 'wb') do |f|
					puts "DOWNLOADING: #{url}"
					begin
						dl = open(url, :allow_redirections => :all)
						ct = dl.content_type #if this is wrong on the server, it will be wrong here.
						puts "#{url} is #{ct}" #for testing
			  			f << dl.read
			  		rescue OpenURI::HTTPError => ex
			  			puts "Oops #{ex}"
			  		end
				end
			end
		rescue Timeout::Error
			puts "#{url} is taking too long, probably way to large for our needs"
		end
	end

	#only one of these will get used for a v
	#each one should return a url that is the direct resource location
	def getUrl(v)
		#this is pretty tied to `http://dp.la/api/contributor/georgia` right now,
		#but there are no other providers with this requirement currently in our
		#list of targets
		start_url = v[:original_url]
		resid = start_url.split(':')[-1]
		if start_url.include? "id:"
			url = v[:dl_info][:f4vpath] % resid
			file_format = ".f4v"
		elsif start_url.include? "do-mp4:"
			url = v[:dl_info][:mp4path] % resid
			file_format = ".mp4"
		else
			url = nil
		end

		file_id = resid << file_format if !resid.nil?
		
		if !url.nil?
			download url, file_id
		else
			puts "no pattern for URL: #{start_url}"
		end
	end

	def getCDM(v)

		def handleUrlShortcut(sc)
			#sometimes you are given back a url shortcut text file, parse this to see if blank or has location
			f = sc.lines
			url = f.find {|e| /URL/ =~ e}.split('=')[1].strip

		end
		
		#need to check if there is actually a video downloaded or a url shortcut file (and parse the latter)
		file_id = v[:original_url].split('/')[-1]
		ourl = v[:original_url].sub('cdm/ref', 'utils/getstream')
		proceed = checkHeaders ourl
		url = proceed[:ok] == false ? handleUrlShortcut(proceed[:with]) : ourl

		if url != 'about:blank' && !url.nil?
			download url, file_id
		else
			puts "forget it, we won't be able to download from #{ourl}...moving on."
		end
	end

	def getSrc(v) 
		url = v[:original_url]
		puts "TRYING TO GET srcUrl for #{url}"
		browser_options = {:js_errors => false, :timeout => 60}
		Capybara.register_driver :poltergeist do |app|
			Capybara::Poltergeist::Driver.new(app, browser_options)
		end
		session = Capybara::Session.new(:poltergeist)
		session.visit url
		page = Nokogiri::HTML(session.html) #allowing all redirs is risky, but since we know where we are getting stuff from, it's okay for now.
		srcUrl = page.css(v[:dl_info][:path]).first[v[:dl_info][:sel]]
		file_id = srcUrl.split('/')[-1]
		if file_id.include?("?")
			file_id = file_id.split("?", 2)[0]
		end
		download srcUrl, file_id
	end
	f = v[:dl_info][:type]
	send(f, v)
end

if __FILE__ == $0
	c = Client.new(__APIS__[:dpla])
	video_results = c.clean_results c.search(searchterm, '"moving image"', 'items', itemlimit)
	#here, video (and audio, soon) should be a list of potential sources with their relevant metadata
	#so depending on which document.dl_info.type it has, go get the video
	if video_results.nil?
		puts "Sorry, after much consideration of your request, there are no viable downloads for #{searchterm}"
		exit
	else
		puts "Starting to download..."
		video_results.each{|v| download_videos v}
	end
end