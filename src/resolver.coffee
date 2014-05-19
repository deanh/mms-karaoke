async = require 'async'
rest  = require 'restler'
util  = require('openaura-api').util
_     = require 'lodash'
#VXGS9RGQYRGB7OUGE

parseTrack = (rawPost) ->
  rawPost.track
  
parseArtist = (rawPost) ->
  rawPost.artist

parseOaId = (enResponse) ->
  prop = util.prop
  ids =  prop enResponse, "response.songs.0.artist_foreign_ids"
  console.log ids
  a = aid for aid in ids when /openaura/.test(aid.catalog)
  (a.foreign_id?.split(":")).pop()

parseMmIds = (enResponse) ->
  prop = util.prop
  tracks = prop enResponse, "response.songs.0.foreign_ids"

  console.dir tracks
  trackIds = for t in tracks
    t.foreign_id.split(":").pop()
  console.log "-> ", trackIds
  trackIds

parseCallbackUrl = (rawPost) -> ""

Resolver = (enApiKey, rawPost, cb) ->
  console.dir rawPost
  artist      = parseArtist(rawPost)
  track       = parseTrack(rawPost)
  callbackUrl = parseCallbackUrl(rawPost)
   
  url    = "http://developer.echonest.com/api/v4/song/search?api_key=#{enApiKey}&title=#{track}&artist=#{artist}&bucket=id:openaura&bucket=id:musixmatch-WW&limit=true&bucket=tracks"
  call   = rest.get url
  console.log url
  
  call.on 'success', (data, res) ->
    console.log 'en call success'
    console.dir data
    unless util.prop data, "response.songs.0"
      return cb({error: "No EN songs call failed for #{url}", status: res.statusCode})
    oaAnchorId = parseOaId(data)
    mmTrackIds = parseMmIds(data)
    cb(mmTrackIds, oaAnchorId, callbackUrl)

  call.on 'failure', (data, res) ->
    console.log 'en call failure', res.statusCode
    cb({error: "EN call failed for #{url}", status: res.statusCode})

module.exports = Resolver
