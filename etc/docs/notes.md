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

dlg.galileo.usg.edu 11542
research.archives.gov 5640
openvault.wgbh.org 2887
utah-primoprod.hosted.exlibrisgroup.com 1894
digitallibrary.usc.edu 1770
texashistory.unt.edu 1071
libx.bsu.edu 631
digital.lib.ecu.edu 277
elonuniversity.contentdm.oclc.org 240
cdm16786.contentdm.oclc.org 174
www.youtube.com 153
www.crossroadstofreedom.org 112
cdm16016.contentdm.oclc.org 108

####TOP HOSTS BY COUNT
If we only target one host from five of the top 5 video content providers, that is still ~72% of all video content currently on DPLA (as of FEB 2016) - 19403/27099)

| use | host                                    | provider                                                 | path                                                                                                                                     | total_in_dpla                                                                                                      | notes                                                                                                                                                                            | redirect                                                      | platform                                     |                              |                  |                | 
|-----|-----------------------------------------|----------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------|----------------------------------------------|------------------------------|------------------|----------------| 
| YES | dlg.galileo.usg.edu                     | http://dp.la/api/contributor/georgia                     | "http://dlg.galileo.usg.edu/news/id:wsbn35848 -> http://dlgmedia1-www.galib.uga.edu/wsbn-f4v/{obj-id}.f4v OR http://dlg.galileo.usg.edu/ugabma/gfc/do-mp4:gfc-2028 -> http://dlgmedia1-www.galib.uga.edu/gfc/mp4/gfc-2028.mp4" | 11542                                                                                                                                                                            | static url if know object id                                  | "yes                                         |  but doesn't matter"         | "flash           |  flowplayer"   | 
| YES | research.archives.gov                   | http://dp.la/api/contributor/nara                        | a#downloadVideoAudio['href']                                                                                                             | 5640                                                                                                               | sometimes only first few minutes available for preview/download. nara hasView['@id'] goes straigt to media resource? if hasView['format'] is. Unrestricted rights for 5625 items | yes                                                           | wmv                                          |                              |                  |                | 
| YES | digitallibrary.usc.edu                  | http://dp.la/api/contributor/usc                         | cdm:utils/getstream                                                                                                                      | 1770                                                                                                               |                                                                                                                                                                                  |                                                               | flowplayer                                   |                              |                  |                | 
| YES | digital.lib.ecu.edu                     | http://dp.la/api/contributor/digitalnc                   | "video source[type=""video/mp4""]['href']"                                                                                               | 277                                                                                                                |                                                                                                                                                                                  |                                                               |                                              |                              |                  |                | 
| YES | cdm16786.contentdm.oclc.org             | http://dp.la/api/contributor/washington                  | cdm: utils/gestream                                                                                                                      | 174                                                                                                                |                                                                                                                                                                                  |                                                               | flowplayer                                   |                              |                  |                | 
| NO  | www.youtube.com                         | http://dp.la/api/contributor/georgia                     | download source or youtube-dl                                                                                                            | 153                                                                                                                | "interviews                                                                                                                                                                      |  oral history                                                 |  fair use"                                   | no                           | youtube/html5    |                | 
| NO  | openvault.wgbh.org                      | http://dp.la/api/contributor/digital-commonwealth        | MUST AUTHENTICATE                                                                                                                        | 2887                                                                                                               |                                                                                                                                                                                  |                                                               |                                              |                              |                  |                | 
| NO  | utah-primoprod.hosted.exlibrisgroup.com | http://api.dp.la/contributor/mwdl                        |                                                                                                                                          | 1894                                                                                                               | "no streaming                                                                                                                                                                    |  but has a link to vimeo? has a link to tons of places        |  might not be a great resource. for now. "   |                              | "linkes to vimeo |  youtube etc." | 
| NO  | texashistory.unt.edu                    | http://dp.la/api/contributor/the_portal_to_texas_history |                                                                                                                                          | 1071                                                                                                               | "won't work with youtube-dl                                                                                                                                                      |  unclear rights. View this video button. Really hard to get." |                                              | jwplayer                     |                  |                | 
| NO  | libx.bsu.edu                            | http://dp.la/api/contributor/indiana                     | cdm: empty url shortcut                                                                                                                  | 631                                                                                                                | "news footage                                                                                                                                                                    |  highly restrictive rights                                    |  not worth it. Getstream onl gives blank url |  only supports silverlight?" |                  |                | 
| NO  | elonuniversity.contentdm.oclc.org       | http://dp.la/api/contributor/digitalnc                   | cdm: utils/gestream                                                                                                                      | 240                                                                                                                |                                                                                                                                                                                  |                                                               |                                              |                              |                  |                | 
| NO  | www.crossroadstofreedom.org             | http://dp.la/api/contributor/tn                          | http://www.crossroadstofreedom.org/view.player?pid=rds:117969 -> http://fedora.crossroadstofreedom.org/fedora/get/rds:117969/video_1.flv | 112                                                                                                                | interviews? Have transcripts.                                                                                                                                                    |                                                               | flash                                        |                              |                  |                | 
| NO  | cdm16016.contentdm.oclc.org             | http://dp.la/api/contributor/scdl                        | cdm: utils/getstream                                                                                                                     | 108                                                                                                                | mainly interviews with ww vets etc.                                                                                                                                              |                                                               |                                              |                              |                  |                | 
| NO  | history.library.gatech.edu              | http://dp.la/api/contributor/georgia                     | div.mejs-mediaelement video['src']                                                                                                       | 70                                                                                                                 | interviews?                                                                                                                                                                      | no                                                            | mediaelementjs.com                           |                              |                  |                | 


mndigital.org (contentdm): http://reflections.mndigital.org/utils/getstream/collection/{collection-id}/id/{item-id} 

georgiaencyclopedia.org: video source['src']
  http://dp.la/api/contributor/georgia - so we have to check the url, provider

purl.umn.edu = umedia.lib.umn.edu - argh it's drupal, flash if the video streams - div#gallery-thumb span['onclick'] = 'getPlayer('video','prod/60/815977','sites/default/files/archive/60/video/quicktime/815977.mov');'
  http://dp.la/api/contributor/mdl

http://digitalcollections.nypl.org/items/3ef7d750-0381-0131-9fd1-3c075448cc4b - brightcove (youtube-dl?)
  http://dp.la/api/contributor/nypl


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
- http://dp.la/api/items/25669406978981f38a89568b63ce0dc2#sourceResource - landing page for a collection
- missouri hub does not seem to have the same metadata structure as the others, no type properties of sourceResource.


###Parsing the giant 5gb data dump


0) Preliminary exploration: 

jq path: 
`.[]._source.sourceResource.type`

For something like Empire State Digital network, 49.6mb, takes about 28 - 30 second real time:
`time gzip -dc esdn.json.gz | jq '.[] | select(._source.sourceResource.type=="sound")'`

But we want to get all possible types first to make sure we are'nt missing something.
`gzip -dc esdn.json.gz | jq '.[]._source.sourceResource.type' >> esdn_types.txt

* some are arrays, some are strings, some are null. 

These will not function with our memory?
`time gzip -dc all.json.gz | jq '.[] | select(._source.sourceResource.type=="sound")'`
`time gzip -dc all.json.gz | jq '.[] | select(._source.sourceResource.type=="moving image")'`



1) To work with these large files, and actually achieve something with limited memory - stream to jq with:

This will give you all of the types, for example, if you want to figure out which collections have "moving image", and "sound" types 
`zcat < file.json.gz | jq --stream 'select(.[0][1] == "_source" and .[0][2] == "sourceResource" and .[0][3] == "type") | .[1]'`

2) extract only the entries you want (so you have smaller files to analyze, and can facet):

`zcat < file.json.gz | jq -cn --stream "fromstream(1|truncate_stream(inputs))" | jq -c "select(any(._source.sourceResource; .type=="moving image"))"`


3) make sure it's valid json (below is posix formatted):

  `sed -i.bak -e 's/$/,/g' -e '$s/,$//' -e '1i\
  [' -e '$a\
  ]' file.json`

4) Continue to analyze in jq (extracting necessary subset of information), or use another language, or tool to analyze open refine?



###Current Distribution of AV items (as of Feb 14, 2016)

This is based on whether entries from these hubs have types that express "moving image" or "sound". Might not be 100% accurate and might not reflect the current collections past 2/14/2016)

####Audio and Video

* cdl
* digital commonwealth
* digital nc
* esdn
* georgia
* gpo
* indiana
* mwdl
* nypl
* scdl
* smithsonian
* the portal to texas history
* tn
* uiuc
* usc
* washington

####Audio Only

* internet archive
* kdl

####Video Only

* nara

####Neither

* artstor
* bhl
* david_rumsey
* harvard
* mdl
* virginia


####Questions we'd like to answer with data in more managable shape

* How much audio/video per provider?
* How much audio/video per domain (dataProvider) within provider?
* How many of those domains are ContentDM sites?
* What are other ways AV data are being distributed (youtube, primo, )

###Some Summary Data

####Hosts Counts (Video)

| Host                                  | COUNT                   | 
|:--------------------------------------|:-----------------------:|
|dlg.galileo.usg.edu                    |         11542           |
|research.archives.gov                  |          5640           |
|openvault.wgbh.org                     |          2887           |
|utah-primoprod.hosted.exlibrisgroup.com|          1894           |
|digitallibrary.usc.edu                 |          1770           |
|texashistory.unt.edu                   |          1071           | 
|libx.bsu.edu                           |           631           |
|digital.lib.ecu.edu                    |           277           |
|elonuniversity.contentdm.oclc.org      |           240           |
|cdm16786.contentdm.oclc.org            |           174           |
|www.youtube.com                        |           153           |
|www.crossroadstofreedom.org            |           112           |
|cdm16016.contentdm.oclc.org            |           108           |
|library.digitalnc.org                  |            95           |
|history.library.gatech.edu             |            70           |
|digitalcollections.nypl.org            |            64           |
|cdm16108.contentdm.oclc.org            |            54           |
|digitalcollections.lib.rochester.edu   |            49           |
|clio.lib.olemiss.edu                   |            41           |
|ftp.atlantahistorycenter.com           |            39           |
|cdm16122.contentdm.oclc.org            |            24           |
|hdl.handle.net                         |            20           |
|catalog.gpo.gov                        |            14           |
|moakleyarchive.omeka.net               |            14           |
|digital.ncdcr.gov                      |            12           |
|digital.tcl.sc.edu                     |            12           |
|www.hrvh.org                           |            10           |
|cdm15138.contentdm.oclc.org            |             8           |
|cdm16694.contentdm.oclc.org            |             8           |
|collections.si.edu                     |             8           |
|imagesearchnew.library.illinois.edu    |             8           |
|www.libs.uga.edu                       |             7           |
|ark.cdlib.org                          |             6           |
|www.georgiaencyclopedia.org            |             5           |
|catalog.hathitrust.org                 |             4           |
|russelldoc.galib.uga.edu               |             4           |
|encore.greenvillelibrary.org           |             3           |
|lcdl.library.cofc.edu                  |             3           |
|primo.getty.edu                        |             3           |
|album.atlantahistorycenter.com         |             2           |
|collections.atlantahistorycenter.com   |             2           |
|heritage.noblenet.org                  |             2           |
|cdm15838.contentdm.oclc.org            |             1           |
|depts.washington.edu                   |             1           |
|digital.lib.utk.edu                    |             1           |
|dlgmedia1-www.galib.uga.edu            |             1           |
|libcdm1.uncg.edu                       |             1           |
|nashville.contentdm.oclc.org           |             1           |
|omeka.library.appstate.edu             |             1           |
|www.floridamemory.com                  |             1           |
|www.library.gatech.edu                 |             1           |  
|---------------------------------------|-------------------------|
|TOTAL                                  |           27099         |        

####Host Counts (Audio)    

| Host                                   | COUNT                  | 
|:---------------------------------------|:----------------------:|    
|utah-primoprod.hosted.exlibrisgroup.com |         4501           |
|collections.si.edu                      |         3327           |
|dlg.galileo.usg.edu                     |         1319           |
|libx.bsu.edu                            |          476           |
|kdl.kyvl.org                            |          415           |
|nashville.contentdm.oclc.org            |          412           |
|texashistory.unt.edu                    |          366           |
|digital.ncdcr.gov                       |          361           |
|digitallibrary.usc.edu                  |          325           |
|www.crossroadstofreedom.org             |          266           |
|lcdl.library.cofc.edu                   |          234           |
|digitalcollections.library.gsu.edu      |          211           |
|cdm16786.contentdm.oclc.org             |          159           |
|digital.tcl.sc.edu                      |          120           |
|digital.lib.ecu.edu                     |          115           |
|collections.atlantahistorycenter.com    |          105           |
|libcdm1.uncg.edu                        |           93           |
|ohms.galileo.usg.edu                    |           80           |
|cdm15138.contentdm.oclc.org             |           71           |
|moakleyarchive.omeka.net                |           70           |
|goldmine.uncc.edu                       |           69           |
|wcudigitalcollection.cdmhost.com        |           65           |
|library.digitalnc.org                   |           64           |
|hdl.handle.net                          |           61           |
|openvault.wgbh.org                      |           38           |
|cdm16694.contentdm.oclc.org             |           37           |
|128.121.13.244                          |           34           |
|cdm15838.contentdm.oclc.org             |           26           |
|archive.org                             |           21           |
|www.hrvh.org                            |           20           |
|kaga.wsulibs.wsu.edu                    |           19           |
|catalog.gpo.gov                         |           12           |
|acumen.lib.ua.edu                       |           11           |
|digitalcollections.nypl.org             |           11           |
|cdm16122.contentdm.oclc.org             |            9           |
|cdm16108.contentdm.oclc.org             |            8           |
|content.wsulibs.wsu.edu                 |            8           |
|ftp.atlantahistorycenter.com            |            7           |
|ark.digitalcommonwealth.org             |            6           |
|imagesearchnew.library.illinois.edu     |            6           |
|www.archive.org                         |            6           |
|ark.cdlib.org                           |            5           |
|catalog.hathitrust.org                  |            4           |
|heritage.noblenet.org                   |            3           |
|soundcloud.com                          |            3           |
|www.presidentialtimeline.org            |            2           |
|content5.ad.wsu.edu                     |            1           |
|elonuniversity.contentdm.oclc.org       |            1           |
|mdah.state.ms.us                        |            1           |
|presidentialtimeline.org                |            1           |
|primo.getty.edu                         |            1           |
|register.shelby.tn.us                   |            1           |
|www.louisianadigitallibrary.org         |            1           |
|(blank)                                 |           60           |
|----------------------------------------|------------------------|
|TOTAL                                   |         13588          |