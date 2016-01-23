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
require 'net/http' #for checking headers
require 'cgi'
require 'json'
require 'timeout'

require_relative 'config/api_keys'

if ARGV.empty?
	puts "need to provide search term and number of results to limit page to. Put long search terms in quotes"
	exit
end

__TERM__ = ARGV[0]
__LIMIT__ = ARGV[1]


#set up for api, search
__APIS__ = {:dpla=>"http://api.dp.la/v2/%s?api_key=#{API_KEYS[:dpla]}&%s"}

$VPATHS = {
	#getUrl takes: returns: PARTIAL download URL with params and based on a specific URL patter.
	#getSrc takes: returns: FULL download URL from HTML
	#getCDM takes: original url returns: FULL download URL from CDM
	"http://dp.la/api/contributor/georgia" => {:type => "getUrl", :next => false, :f4vpath => "http://dlgmedia1-www.galib.uga.edu/wsbn-f4v/%s.f4v", :mp4path => "http://dlgmedia1-www.galib.uga.edu/gfc/mp4/%s.mp4"}, 
	"http://dp.la/api/contributor/indiana" => {:type => "getCDM", :next => false, :path => nil},
	"http://dp.la/api/contributor/nara"	   => {:type => "getSrc", :next => false, :path => "a#downloadVideoAudio", :sel => "['href']"},
	"http://dp.la/api/contributor/digitalnc" => {:type => "getSrc", :next => false, :path =>  "video source[type='video/mp4']", :sel =>"['href']"}
}
$APATHS = {}

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
			results = Array.new
			docs.each do |d|
				result = Hash.new
				result = {
					:provider_id => d['provider']['@id'], 
					:provider_name => d['provider']['name'],
					:dl_info => $VPATHS[d['provider']['@id']],
					:source_resource => d['sourceResource'],
					:dpla_id => d['id'],
					:original_url => d['isShownAt']
				}
				results << result if !result[:dl_info].nil? #&& result[:source_resource]['rights'][0].downcase == 'unrestricted'
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
		puts url
		res = RestClient.get url
	end
end

def download_videos(v)
	def checkHeaders(u)
		h = Net::HTTP.start(u)
		r = h.head('/')
		he = Hash.new
		r.each { |k, v| he[k]=v}
		h.finish
		# need to return true or false if it's a video file or text file
		#TODO, not getting any good information for the headers
		if #video file
			true
		else
			false	
	end

	def download(url, someid)
		path = "./tmp_v/#{someid}"
		#use timeout to cut of extra long downloads (over 30 sec is too much)
		begin
			timeout(30) do
				open(path, 'wb') do |f|
					dl = open(url, :allow_redirections => :safe)
					ct = dl.content_type #if this is wrong on the server, it will be wrong here.
					puts "#{url} is #{ct}" #for testing
		  			f << dl.read
				end
			end
		rescue Timeout::Error
			puts "#{url} is taking too long, probably way to large for our needs"
		end
	end

	#only one of these will get used for a v
	#each one should return a url that is the direct resource location
	def getUrl(v)
		#this is pretty tied to `http://dp.la/api/contributor/georgia` right now
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

		# mov source = http://cdm16786.contentdm.oclc.org/utils/getstream/collection/filmarch/id/52
		# ishortcut = http://libx.bsu.edu/utils/getstream/collection/newslink/id/592
		def handleUrlShortcut(sc)
			#sometimes you are given back a url shortcut text file, parse this to see if blank or has location
			f = File.readlines(sc)
			url = f.find {|e| /URL/ =~ e}.split('=')[1].strip
		end
		#need to check if there is actually a video downloaded or a url shortcut file (and parse the latter)
		file_id = v[:original_url].split('/')[-1]
		ourl = v[:original_url].sub('cdm/ref', 'utils/getstream')
		proceed = checkHeaders ourl
		url = !proceed ? url = handleUrlShortcut ourl : ourl

		if url != 'about:blank'
			download url, file_id
		else
			puts "forget it, we won't be able to download from #{ourl} "

	end

	def getSrc(v) 
		page = Nokogiri::HTML(open(v[:original_url]))
		elem = page.css(v[:dl_info][:path])[v[:dl_info][:sel]]
		file_id = url.split.('/')[-1]
		if file_id.include?("?")
			file_id = file_id.split("?")[0]!
		end
		download url, file_id
	end

	f = v[:dl_info][:type]
	send(f, v)
end


if __FILE__ == $0
	c = Client.new(__APIS__[:dpla])
	video_results = c.clean_results c.search(__TERM__, '"moving image"', 'items', __LIMIT__)
	#audio = c.clean_results c.search(__TERM__, 'sound', 'items', __LIMIT__)

	#here, video (and audio, soon) should be a list of potential sources with their relevant metadata
	#so depending on which document.dl_info.type it has, go get the video
	video_results.each{|v| download_videos v}

end