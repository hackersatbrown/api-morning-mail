restify = require "restify"
fs = require "fs"
xml2js = require "xml2js"
_ = require "underscore"
loader = require "./loader"

parser = new xml2js.Parser({explicitArray: false, trim: true})
testdata = "test/data"


### INPUT TRANSFORMERS ###
# Does nothing but pass along the request for now.
transformReq = (req, res, next) ->
  _.defaults(req.params, {days: "1", date: getToday(), feed: "all"})
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
      guid = item.guid._
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

switch process.env.NODE_ENV
  when "development", "test"
    t = require "./test-funs"
    fetchRes = t.fetchRes
    getToday = t.getToday

server.get "/v1/posts", [transformReq, fetchRes, transformRes, send]

server.get "/v1/posts/:id", [transformReq, fetchRes, transformRes, send]

server.listen (process.env.PORT or 8080), ->
  console.log "#{server.name} listening at #{server.url}"
