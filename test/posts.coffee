restify = require "restify"

client = restify.createJsonClient url: "http://localhost:8080"

# Set up our server
before ->
  process.env.NODE_ENV = "test"
  require "../bin/server"


describe "/posts", ->
  
  describe "GET /posts", ->
    it "should send today's MM posts", (done) ->
      client.get "/posts", (err, req, res, data) ->
        # TODO check stuff here
        done err


