restify = require "restify"
fs = require "fs"
xml2js = require "xml2js"
_ = require "underscore"
moment = require "moment"
loader = require "./loader"

parser = new xml2js.Parser({explicitArray: false, trim: true, charkey: 'data'})
testdata = "test/data"


### INPUT TRANSFORMERS ###
# Does nothing but pass along the request for now.
transformReq = (req, res, next) ->
  _.defaults(req.params, {days: '1', date: getToday(), today: getToday(), feed: "all"})
  today = moment req.params.today
  date = moment req.params.date
  diff = today.diff date, "days"
  days = diff + parseInt(req.params.days)
  req.params.days = days.toString()
  next()

### DATA FETCHERS ###
# This will pass the modified request to morningmail.brown.edu.
fetchRes = (req, res, next) ->
  return res.send {error: "not implemented yet"}

### OUTPUT TRANSFORMERS ###
# Does nothing but translate from xml to json for now.
transformRes = (req, res, next) ->
  parser.parseString req.params.xml, (err, result) ->
    if err
      return res.send {error: "transforming xml into json"}
    items = result.rss.channel.item
    json = _.map items, (item, idx, list) ->
      search = "?id="
      guid = item.guid.data
      guid = guid.substr guid.lastIndexOf search
      id = guid.substr search.length
      newitem = _.omit item, "guid"
      newitem = _.defaults newitem, {id: id}
      d = Date.parse newitem.pubDate
      d = if _.isNaN d then newitem.pubDate else new Date newitem.pubDate
      newitem.pubDate = d
      return newitem
    req.resultJson = {posts: json}
    next()

# Trims results based on the date range requested
trimRes = (req, res, next) ->
  items = req.resultJson.posts
  start = moment req.params.date
  today = moment req.params.today
  diff = today.diff start, "days"
  end = start.clone().subtract "days", (req.params.days - diff - 1)
  trimmed = _.filter items, (item) ->
    d = moment item.pubDate
    return start.diff(d, "days") >= 0 and d.diff(end, "days") >= 0
  req.resultJson = {posts: trimmed}
  next()

# Send back the resulting json
send = (req, res, next) ->
  res.send req.resultJson
  next()

# return today's date #
getToday = ->
  today = new Date()
  m = today.getMonth()
  d = today.getDate()
  y = today.getFullYear()
  "#{m}-#{d}-#{y}"

### SERVER SETUP ###
server = restify.createServer name: "morning-mail"
server.use restify.queryParser()

switch process.env.NODE_ENV
  when "development", "test"
    t = require "./test-funs"
    fetchRes = t.fetchRes
    getToday = t.getToday

server.get "/v1/posts", [transformReq, fetchRes, transformRes, trimRes, send]

server.get "/v1/posts/:id", [transformReq, fetchRes, transformRes, send]

server.listen (process.env.PORT or 8080), ->
  console.log "#{server.name} listening at #{server.url}"
