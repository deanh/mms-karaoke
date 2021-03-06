// Generated by CoffeeScript 1.6.3
(function() {
  var Resolver, async, parseArtist, parseCallbackUrl, parseMmIds, parseOaId, parseTrack, rest, util, _;

  async = require('async');

  rest = require('restler');

  util = require('openaura-api').util;

  _ = require('lodash');

  parseTrack = function(rawPost) {
    return rawPost.track;
  };

  parseArtist = function(rawPost) {
    return rawPost.artist;
  };

  parseOaId = function(enResponse) {
    var a, aid, ids, prop, _i, _len, _ref;
    prop = util.prop;
    ids = prop(enResponse, "response.songs.0.artist_foreign_ids");
    console.log(ids);
    for (_i = 0, _len = ids.length; _i < _len; _i++) {
      aid = ids[_i];
      if (/openaura/.test(aid.catalog)) {
        a = aid;
      }
    }
    return ((_ref = a.foreign_id) != null ? _ref.split(":") : void 0).pop();
  };

  parseMmIds = function(enResponse) {
    var prop, t, trackIds, tracks;
    prop = util.prop;
    tracks = prop(enResponse, "response.songs.0.foreign_ids");
    console.dir(tracks);
    trackIds = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = tracks.length; _i < _len; _i++) {
        t = tracks[_i];
        _results.push(t.foreign_id.split(":").pop());
      }
      return _results;
    })();
    console.log("-> ", trackIds);
    return trackIds;
  };

  parseCallbackUrl = function(rawPost) {
    return "";
  };

  Resolver = function(enApiKey, rawPost, cb) {
    var artist, call, callbackUrl, track, url;
    console.dir(rawPost);
    artist = parseArtist(rawPost);
    track = parseTrack(rawPost);
    callbackUrl = parseCallbackUrl(rawPost);
    url = "http://developer.echonest.com/api/v4/song/search?api_key=" + enApiKey + "&title=" + track + "&artist=" + artist + "&bucket=id:openaura&bucket=id:musixmatch-WW&limit=true&bucket=tracks";
    call = rest.get(url);
    console.log(url);
    call.on('success', function(data, res) {
      var mmTrackIds, oaAnchorId;
      console.log('en call success');
      console.dir(data);
      if (!util.prop(data, "response.songs.0")) {
        return cb({
          error: "No EN songs call failed for " + url,
          status: res.statusCode
        });
      }
      oaAnchorId = parseOaId(data);
      mmTrackIds = parseMmIds(data);
      return cb(mmTrackIds, oaAnchorId, callbackUrl);
    });
    return call.on('failure', function(data, res) {
      console.log('en call failure', res.statusCode);
      return cb({
        error: "EN call failed for " + url,
        status: res.statusCode
      });
    });
  };

  module.exports = Resolver;

}).call(this);
