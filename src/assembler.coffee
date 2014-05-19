async = require 'async'
rest  = require 'restler'
oa    = require 'openaura-api'
util  = oa.util
_     = require 'lodash'

Assembler = (mmApiKey, oaApiKey, mmTrackIds, oaAnchorId, cb) ->
  prop = util.prop
  if mmTrackIds.error?
    return cb(mmTrackIds)
  console.log mmTrackIds
  mmUrls = for id in mmTrackIds
    "http://api.musixmatch.com/ws/1.1/track.subtitle.get?track_id=#{id}&apikey=#{mmApiKey}&subtitle_format=mxm"
  console.log mmUrls

  # mmCalls = (pcb) ->
  #   foundLyrics = false
  #   result = null
  #   async.until ->
  #     console.log foundLyrics
  #     foundLyrics
  #   , (mmCallsCb) ->
  #     uri = mmUrls.pop()
  #     console.log uri
  #     return mmCalls("no lyrics", null) unless uri
  #     getEm = rest.get mmUrls.pop()
  #     getEm.on 'success', (data, res) ->
  #       console.dir data
  #       console.dir JSON.parse(data)
  #       console.dir prop(JSON.parse(data), "message.body.subtitle.subtitle_body")
  #       if prop(JSON.parse(data), "message.body.subtitle.subtitle_body")
  #         foundLyrics = true
  #         console.log "calling pcb"
  #         pcb(null, data)
  #       console.log "calling mmCb"
  #       return mmCallsCb(null, data)
 
  #     getEm.on 'failure', (data, res) ->
  #       console.log "musixmatch cb failure"
  #       console.log "calling error mmCb"
  #       mmCallsCb(data, null)
  #       console.log "calling error pcb"
  #       pcb(res, null)

  #   , (err) ->
  #     console.log "FAIL"
  #     pcb(err, null)
            
  mmCall = rest.get mmUrls[0]

  particles = new oa.particles(oaApiKey, "http://api.openaura.com/v1", 500)

  pc = (pcb) ->
    particles.byOaAnchorId oaAnchorId, ->
      console.log "parrticles cb error"
      pcb("nope", null)
    , (ps) ->
      console.log "particles cb success"
      pcb(null, ps)

  mmc = (pcb) ->
    mmCall.on 'success', (data, res) ->
      console.log "musixmatch cb success"
      console.log "#>", data
      pcb(null, data)
    mmCall.on 'failure', (data, res) ->
      console.log "musixmatch cb failure"      
      pcb(res, null)      
    
  async.parallel { oa: pc, mm: mmc }, (err, results) ->
    # they return text/plain
    mm = JSON.parse results.mm
    if subtitles = prop(mm, "message.body.subtitle.subtitle_body")
      mmTitles = JSON.parse subtitles
    else
      mmTitles = []
    # we need to filter out bunkticles
    oap = _.filter results.oa.particles, (p) ->
      p.media?.length > 0
    res = _.chain(
      _.zip(mmTitles, oap)).map((pair) ->
        v = formatOutput(pair)
        console.dir v
        v
      ).compact().value()
    cb(res)

# result is in milliseconds
timeDiff = (t1, t2) ->
  mPart = (t2.minutes - t1.minutes) * 60 * 1000
  sPart = (t2.seconds - t1.seconds) * 1000
  hPart = (t2.hundredths - t1.hundredths) * 10
  mPart + sPart + hPart

formatOutput = ([lyric, particle]) ->
  prop  = util.prop
  media = prop particle, "media"
  if media
    list = (m for m in media when parseInt(m.width) > 200 and parseInt(m.height) > 200)
    if list? and list.length > 0
      ret =
        lyric: prop lyric, "text"
        imgUrl: prop list[0], "url"

module.exports = Assembler

