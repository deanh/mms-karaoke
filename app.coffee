express = require 'express'
resolver = require './lib/resolver'
assembler = require './lib/assembler'
util = require('openaura-api').util
cors = require('cors')

app = express()
app.use(express.json())
app.use(cors())

PORT = process.env.NPM_CONFIG_PORT || 3333
EN_API_KEY = "VXGS9RGQYRGB7OUGE"
MM_API_KEY="b956117746bf6dd8824562b615bf0516"
OA_API_KEY="music-hack-day"

app.get '/hello', (req, res) ->
  res.send { "hello": "world" }

app.post '/karaoke', (req, res) ->
  console.dir resolver
  console.dir req.body
  resolver EN_API_KEY, req.body, (mmTrackId, oaAnchorId) ->
    console.log mmTrackId, oaAnchorId
    console.log "in resolver cb"
    assembler MM_API_KEY, OA_API_KEY, mmTrackId, oaAnchorId, (outData) ->
      console.log "in assembler cb"
      res.send outData

console.log "Starting web app on #{PORT}"
app.listen PORT
