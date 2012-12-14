restify = require "restify"
fs = require "fs"
xml2js = require "xml2js"
_ = require "underscore"

parser = new xml2js.Parser()


### INPUT TRANSFORMERS ###
transformreq = (err, req, next) ->
  if err
    err
  newreq = req
  _.first(next) newreq, _.rest next

### DATA FETCHERS ###
fetchdata = (req, next) ->
  next {error: "not implemented yet"}, null


# fetch test data based on request
fetchtestdata = (req, next) ->
  days = req.params.days
  feed = req.params.feed
  
  fs.readFile "test/data/12-13-1-all.xml", (err, data) =>
    if err
      _.first(next) err, null
    parser.parseString data, (err, result) =>
      if err
        _.first(next) err, null
      _.first(next) null, result, _.rest next


### OUTPUT TRANSFORMERS ###
transformres = (err, res, next) ->
  if err
    next err
  newres = res
  _.first(next) newres


# Server config
server = restify.createServer name: "morning-mail"

fetchres = fetchdata

switch process.env.NODE_ENV
  when "development", "test"
    # Do something to load in some fake data
    fetchres = fetchtestdata
  when "production"
    # Do some real stuff
    fetchres = fetchdata

server.get "/posts", (req, res, next) =>
  _.bindAll(res)
  transformreq null, req, [fetchres, transformres, res.send]

server.listen (process.env.PORT or 8080), ->
  console.log "#{server.name} listening at #{server.url}"
