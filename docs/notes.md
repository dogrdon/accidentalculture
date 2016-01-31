fetch
  - an audio
  - a video
  - based on some similarity or connection
  - text

extract something of each
  - 6 sec audio
  - 6 sec video

ffmpeg
  - convert audio and video streams to .mp4

send it
  - post to something


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

Other import things: 
  - sourceResource.rights
  - sourceResource.format
  - sourceResource.relation
  - sourceResource.title
  - sourceResource.collection
  - sourceResource.subject
  - id (dpla id)
  - isShownAt (link to resource)
  - dataProvider 
  - provider[@id], provider[name]


###Examples

http://api.dp.la/items/?q=cow&page_size=12&sourceResource.type=%22physical%20object%22&api_key=b2e5bb78379ad55ead9a148202c8e5fd

http://api.dp.la/items/?q=cow&page_size=12&sourceResource.type=%22moving%20image%22&api_key=b2e5bb78379ad55ead9a148202c8e5fd


###Grabbing videos

Since a headless browser that supports flash doesn't seem to be a common tool, may need some hueristics. If there are only a handful of collections that actually have video, this might not be so bad. 

WSB-TV collection - http://dlg.galileo.usg.edu/news/id:wsbn35848: http://dlgmedia1-www.galib.uga.edu/wsbn-f4v/{obj-id}.f4v
  http://dp.la/api/contributor/georgia
  New pattern: http://dlg.galileo.usg.edu/ugabma/gfc/do-mp4:gfc-2028 = http://dlgmedia1-www.galib.uga.edu/gfc/mp4/gfc-2028.mp4

archives.org appear to have a download button: a#downloadVideoAudio['href']
  http://dp.la/api/contributor/nara
  nara hasView['@id'] goes straigt to media resource? if hasView['format'] is 

mndigital.org (contentdm): http://reflections.mndigital.org/utils/getstream/collection/{collection-id}/id/{item-id} 

texashistory.unt.edu: Ugh, really tucked away, jwplayer - won't work with youtube-dl

utah-primoprod.hosted.exlibrisgroup.com: no streaming, but has a link to vimeo? has a link to tons of places, might not be a great resource. for now.
  http://dp.la/api/contributor/mwdl (are there more?)

libx.bsu.edu: cdm, but utils/getstream pattern above doesn't work (downloads blank .url file) and it only supports silverlight
cdm16016.contentdm.oclc.org: utils/getstream downloads url to resource ()
  http://dp.la/api/contributor/scdl (are there more?)

openvault.wgbh.org: appears to be behind authentication
  http://dp.la/api/contributor/digital-commonwealth

georgiaencyclopedia.org: video source['src']
  http://dp.la/api/contributor/georgia - so we have to check the url, provider

digital.lib.ecu.edu: video source[type="video/mp4"]['href']
  http://dp.la/api/contributor/digitalnc - again check the url

###To Collect

elonuniversity.contentdm.oclc.org - utils/gestream seems to provide access straight to vid
  http://dp.la/api/contributor/digitalnc

purl.umn.edu = umedia.lib.umn.edu - argh it's drupal, flash if the video streams - div#gallery-thumb span['onclick'] = 'getPlayer('video','prod/60/815977','sites/default/files/archive/60/video/quicktime/815977.mov');'
  http://dp.la/api/contributor/mdl

http://digitalcollections.nypl.org/items/3ef7d750-0381-0131-9fd1-3c075448cc4b - brightcove (youtube-dl?)
  http://dp.la/api/contributor/nypl

http://cdm16786.contentdm.oclc.org/cdm/ref/collection/filmarch/id/63 - utils/getstream
  http://dp.la/api/contributor/washington

http://libx.bsu.edu/cdm/ref/collection/newslink/id/442 - cdm, utils/getstream
  http://dp.la/api/contributor/indiana


###Grabbing Audio

This one probably not much good to pursue - it's contentdm tucked inside of primo
http://utah-primoprod.hosted.exlibrisgroup.com/primo_library/libweb/action/dlDisplay.do?vid=MWDL&afterPDS=true&docId=digcoll_uuu_11wss/2582
  http://dp.la/api/contributor/mwdl

http://libx.bsu.edu/cdm/ref/collection/INArtsDesk/id/148 - video#MediaElement source['src'] (just a video element?)
  http://dp.la/api/contributor/indiana

http://digitalcollections.library.gsu.edu/cdm/ref/collection/ggdp/id/5371 - strange, it appears that /utils/getstream/ ought to work, but there is some wierd network stuff going on behind the scene.
  http://dp.la/api/contributor/georgia

http://dlg.galileo.usg.edu/gtaa/do-mp3:gtaa97-6-01 - http://dlg.galileo.usg.edu/gsac/gtaa/mp3s/gtaa97-6-01.mp3
  http://dp.la/api/contributor/georgia

http://libcdm1.uncg.edu/u?/ui,53359 - redirects to: http://libcdm1.uncg.edu/cdm/ref/collection/ui/id/53359 utils/getstream works
  http://dp.la/api/contributor/digitalnc

###Transcripts

###Puzzling
http://dp.la/api/items/25669406978981f38a89568b63ce0dc2#sourceResource - landing page for a collection
