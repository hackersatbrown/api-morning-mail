restify = require "restify"
fs = require "fs"
xml2js = require "xml2js"
_ = require "underscore"

parser = new xml2js.Parser()


### INPUT TRANSFORMERS ###

# Does nothing but pass along the request for now.
transformreq = (err, req, next) ->
  if err
    return err
  newreq = req
  _.first(next) newreq, _.rest next

### DATA FETCHERS ###

# This will pass the modified request to morningmail.brown.edu.
fetchdata = (req, next) ->
  _.first(next) {error: "not implemented yet"}, null, _.rest next

# Fetches test data based on the request.
# Right now this just returns today for feed 'all'.
fetchtestdata = (req, next) ->
  days = req.params.days
  feed = req.params.feed
  
  fs.readFile "test/data/12-13-1-all.xml", (err, data) ->
    if err
      return _.first(next) err, null
    _.first(next) null, data, _.rest next


### OUTPUT TRANSFORMERS ###

# Does nothing but translate from xml to json for now.
transformres = (err, res, next) ->
  if err
    return _.first(next) err
  parser.parseString res, (err, result) ->
    if err
      return _.first(next) err
    _.first(next) result


### SERVER SETUP ###
server = restify.createServer name: "morning-mail"
process.env.NODE_ENV = process.env.NODE_ENV or "production"

fetchres = switch process.env.NODE_ENV
  when "development", "test"
    fetchtestdata
  when "production"
    fetchdata

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
