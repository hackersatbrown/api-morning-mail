restify = require "restify"
fs = require "fs"
xml2js = require "xml2js"
_ = require "underscore"
moment = require "moment"
request = require "request"

loader = require "./loader"
keyStore = require "./keyStore"

parser = new xml2js.Parser
  explicitArray: false
  trim: true
  charkey: 'data'
testdata = "test/data"

### INPUT TRANSFORMERS ###
transformReq = (req, res, next) ->
  _.defaults req.params,
    days: "1"
    span: "1"
    date: getToday()
    feed: "all"
  # Diff is the number of days between today and the end of the request range
  # Span is the number of days from today to the start of the request range
  # Thus, span is the number of days we want to request from CIS
  today = moment getToday()
  diff = today.diff moment(req.params.date), "days"
  req.params.span = (diff + parseInt req.params.days).toString()
  next()

# Looks for a specific post in the last week of posts.
# Should we return an error if the post is too old?
# Or just return an empty result?
transformIdReq = (req, res, next) ->
  if not req.params.id
    return next new restify.InvalidContentError "No post id specified"
  _.defaults req.params,
    days: "7"
    span: "7"
    date: getToday()
    feed: "all"
  next()

### DATA FETCHERS ###
# This will pass the modified request to morningmail.brown.edu.
fetchRes = (req, res, next) ->
  uri = "http://morningmail.brown.edu/xml.php?"
  uri += "feed=#{req.params.feed}&"
  uri += "days=#{req.params.span}"
  request.get
    uri: uri,
    (err, res, body) ->
      if err
        return next new restify.InternalError "Error getting xml from CIS"
      req.resultXml = body
      next()

### OUTPUT TRANSFORMERS ###
# Does nothing but translate from xml to json for now.
transformRes = (req, res, next) ->
  parser.parseString req.resultXml, (err, result) ->
    if err
      return next new restify.InternalError "Error transforming xml into json"
    items = result.rss.channel.item
    json = _.map items, (item, idx, list) ->
      # Parse the id out of the guid
      search = "?id="
      guid = item.guid.data
      id = guid[guid.lastIndexOf(search) + search.length..]
      newitem = _.omit item, "guid"
      newitem.id = id

      # Put the date in normal javascript datestring format if possible
      d = Date.parse newitem.pubDate
      newitem.pubDate = if _.isNaN d then newitem.pubDate else new Date newitem.pubDate
      return newitem
    req.resultJson = json
    next()

# Trims results based on the date range requested
trimRes = (req, res, next) ->
  # If the days and span are equal, then the range
  # starts with today, so no trimming is necessary.
  return next() if req.params.days == req.params.span
  
  # Otherwise, only return items between start and end
  start = moment req.params.date
  end = start.clone().subtract "days", req.params.days - 1
  trimmed = _.filter req.resultJson, (item) ->
    d = moment item.pubDate
    return start.diff(d, "days") >= 0 and d.diff(end, "days") >= 0
  req.resultJson = trimmed
  next()

transformIdRes = (req, res, next) ->
  parser.parseString req.resultXml, (err, result) ->
    if err
      return next new restify.InternalError "Error transforming xml into json"
    items = result.rss.channel.item
    item = _.find items, (item, idx, list) ->
      search = "?id="
      guid = item.guid.data
      id = guid[guid.lastIndexOf(search) + search.length..]
      return id == req.params.id
    item = _.omit item, "guid"
    item.id = req.params.id
    d = Date.parse item.pubDate
    d = if _.isNaN d then item.pubDate else new Date item.pubDate
    item.pubDate = d
    req.resultJson = item
    next()

# Send back the resulting json
send = (req, res, next) ->
  res.send req.resultJson
  next()

# return today's date #
getToday = ->
  today = new Date()
  "#{today.getMonth() + 1}-#{today.getDate()}-#{today.getFullYear()}"

### SERVER SETUP ###
server = restify.createServer name: "morning-mail"
server.use restify.queryParser()

server.use restify.authorizationParser()
# Check every request to make sure it has an active key.
server.use keyStore.check()

switch process.env.NODE_ENV
  when "development", "test"
    t = require "./testFuns"
    fetchRes = t.fetchRes
    getToday = t.getToday

server.get "/v1/posts", [transformReq, fetchRes, transformRes, trimRes, send]

server.get "/v1/posts/:id", [transformIdReq, fetchRes, transformIdRes, send]

server.post "/v1/keys",
  keyStore.check(["adminKeys"]),
  (req, res, next) ->
    keyStore.create null, (err, key) ->
      if err or not key?
        res.send 500, err # TODO better error message?
      else
        res.send { key: key }

server.del "/v1/keys/:key",
  keyStore.check(["adminKeys"]),
  (req, res, next) ->
    keyStore.deactivate req.params.key, (err) ->
      if err then res.send 500, err else res.send 200

server.listen (process.env.PORT or 8080), ->
  console.log "#{server.name} listening at #{server.url}"
