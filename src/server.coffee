restify = require "restify"
fs = require "fs"
xml2js = require "xml2js"
_ = require "underscore"
loader = require "./loader"

parser = new xml2js.Parser()
testdata = "test/data"


### INPUT TRANSFORMERS ###

# Does nothing but pass along the request for now.
transformreq = (err, req, next) ->
  if err
    return err
  req.params.days = req.params.days or "1"
  req.params.date = req.params.date or getToday()
  req.params.feed = req.params.feed or "all"
  _.first(next) req, _.rest next

### DATA FETCHERS ###

# This will pass the modified request to morningmail.brown.edu.
fetchdata = (req, next) ->
  _.first(next) {error: "not implemented yet"}, null, _.rest next

# Fetches test data based on the request.
# Right now this just returns today for feed 'all'.
fetchtestdata = (req, next) ->
  days = req.params.days
  date = req.params.date
  feed = req.params.feed
  md = date.substr 0, date.lastIndexOf "-"
  loader.loadFile "#{testdata}/#{md}-#{days}-#{feed}.xml", (result) ->
    _.first(next) null, result, _.rest next


### OUTPUT TRANSFORMERS ###

# Does nothing but translate from xml to json for now.
transformres = (err, res, next) ->
  if err
    return _.first(next) err
  parser.parseString res, (err, result) ->
    if err
      return _.first(next) err
    _.first(next) result


### helper functions ###
getTestToday = ->
      "12-13-2012"

getRealToday = ->
  today = new Date()
  m = today.getMonth()
  d = today.getDate()
  y = today.getFullYear()
  "#{m}-#{d}-#{y}"


### SERVER SETUP ###
server = restify.createServer name: "morning-mail"
process.env.NODE_ENV = process.env.NODE_ENV or "production"

[fetchres, getToday] = switch process.env.NODE_ENV
  when "development", "test"
    [fetchtestdata, getTestToday]
  when "production"
    [fetchdata, getRealToday]

server.get "/v1/posts", (req, res, next) ->
  # This binding is needed in order for 'this' to refer
  # to 'res' when we finally call res.send
  _.bindAll(res)

  # There could be other things in this chain of calls
  # and there is probably a better way to do this
  #
  # The key check will need to go somewhere as well
  transformreq null, req, [fetchres, transformres, res.send]

server.get "/v1/posts/:id", (req, res, next) ->
  # This binding is needed in order for 'this' to refer
  # to 'res' when we finally call res.send
  _.bindAll(res)

  # There could be other things in this chain of calls
  # and there is probably a better way to do this
  #
  # The key check will need to go somewhere as well
  transformreq null, req, [fetchres, transformres, res.send]


server.listen (process.env.PORT or 8080), ->
  console.log "#{server.name} listening at #{server.url}"
