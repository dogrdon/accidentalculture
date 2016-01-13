fetch
  - an audio
  - a video
  - based on some similarity or connection
  - text

extract something of each
  - 6 sec audio
  - 6 sec video

ffmpeg
  - convert audio and video streams to whatever vine accepts

vine
  - upload to vine??twitter??instagram??

twitter
  - post to twitter


dpla api:

to search the API by format, use `sourceResource.type` parameter. Or `sourceResource.format`? It appears the sourceResource.type is more often applied and sourceResource.format appears less frequently and in less predictable ways. That is, for example, values for sourceResource.format are (formats for sound appear to be the duration of some audio recordings). sourceResource.type maps to the search facet for format in the browser.

Values for sourceResource.type are:

	* "image"
	* "moving image"**
	* "sound"
	* "text"
	* "physical object"**

**Got to use quotes

Other sources of videos:

	- Internet Archive
	- 


###Examples

http://api.dp.la/items/?q=cow&page_size=12&sourceResource.type=%22physical%20object%22&api_key=b2e5bb78379ad55ead9a148202c8e5fd

http://api.dp.la/items/?q=cow&page_size=12&sourceResource.type=%22moving%20image%22&api_key=b2e5bb78379ad55ead9a148202c8e5fd


###Grabbing videos

Since a headless browser that supports flash doesn't seem to be a common tool, may need some hueristics. If there are only a handful of collections that actually have video, this might not be so bad. 

WSB-TV collection: http://dlgmedia1-www.galib.uga.edu/wsbn-f4v/{obj-id}.f4v
  http://dp.la/api/contributor/georgia
archives.org appear to have a download button: a#downloadVideoAudio['href']
  http://dp.la/api/contributor/nara
mndigital.org (contentdm): http://reflections.mndigital.org/utils/getstream/collection/{collection-id}/id/{item-id} 
texashistory.unt.edu: Ugh, really tucked away, jwplayer - won't work with youtube-dl
utah-primoprod.hosted.exlibrisgroup.com: no streaming, but has a link to vimeo? has a link to tons of places, might not be a great resource. for now.
  http://dp.la/api/contributor/mwdl (are there more?)
libx.bsu.edu: cdm, but utils/getstream pattern above doesn't work (downloads blank .url file) and it only supports silverlight
cdm16016.contentdm.oclc.org: utils/getstream downloads url to resource ()
  http://dp.la/api/contributor/scdl (are there more?)
openvault.wgbh.org: appears to be behind authentication
georgiaencyclopedia.org: video source['src']
digital.lib.ecu.edu: video source[type="video/mp4"]['href']
