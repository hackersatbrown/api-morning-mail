restify = require "restify"
fs = require "fs"
xml2js = require "xml2js"

parser = new xml2js.Parser()


### INPUT TRANSFORMERS ###
transformreq = (err, req, next) ->
  if err
    err
  newreq = req
  next[0] newreq, next[1]

### DATA FETCHERS ###
fetchdata = (req, next) ->
  next {error: "not implemented yet"}, null

fetchtestdata = (req, next) ->
  testdata = null
  
  days = req.params.days
  feed = req.params.feed
  
  fs.readFile "test/data/12-13-1-all.xml", (err, data) ->
    if err
      next err, null
    parser.parseString data, (err, result) ->
      if err
        next err, null
      testdata = JSON.stringify result
  next null, testdata

### OUTPUT TRANSFORMERS ###
transformres = (err, res, next = (x) -> x) ->
  if err
    next err
  newres = res
  next newres


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

server.get "/posts", (req, res, next) ->
  res.send transformreq null, req, [fetchres, transformres]

server.listen (process.env.PORT or 8080), ->
  console.log "#{server.name} listening at #{server.url}"
