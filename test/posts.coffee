restify = require "restify"
assert = require "assert"
fs = require "fs"

client = restify.createJsonClient url: "http://localhost:8080"
testdata = "test/data/json"

# Set up our server
before ->
  process.env.NODE_ENV = "test"
  require "../bin/server"


describe "/posts", ->
  
  describe "GET /posts", ->
    it "should send today's MM posts", (done) ->
      assert.equal loadToday(),
        client.get "/posts", (err, req, res, data) ->
          # TODO check stuff here
          if err
            done err
      done()

    ###
    it "should send the last week of MM posts", (done) ->
      assert.equal loadWeek(),
        client.get "/posts?days=7", (err, req, res, data) ->
          if err
            done err
          data
    ###
          

loadToday = () ->
  today = null
  fs.readFile "#{testdata}/12-13-1-all.json", (err, data) ->
    if err
      throw err
    today = data
  return today

loadWeek = () ->
  week = null
  fs = readFile "#{testdata}/12-13-7-all.json", (err, data) ->
    if err
      throw err
    week = data
  return today
