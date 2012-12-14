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

    ### # TEST COMBINATIONS OF TODAY AND ALL
    ###
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/posts", checkToday "all", done
    
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/posts?days=1", checkToday "all", done

    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/posts?days=1&date=12-13-12", checkToday "all", done
      
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/posts?days=1&date=12-13-12&feed=all", checkToday "all", done
    
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/posts?date=12-13-12", checkToday "all", done
    
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/posts?date=12-13-12&feed=all", checkToday "all", done
   
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/posts?date=12-13-12&feed=all&days=1", checkToday "all", done
    
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/posts?feed=all", checkToday "all", done
    
    ### # TEST TODAY AND UNDERGRAD
    ###
    it "should send 12-13's 'undergrad' MM posts", (done) ->
      client.get "/posts?feed=undergrad", checkToday "undergrad", done
    
    ### # TEST THE LAST WEEK
    ###
    it "should send the last week of 'all' MM posts", (done) ->
      client.get "/posts?days=7&feed=undergrad", checkWeek "all", done
    
    it "should send the last week of 'undergrad' MM posts", (done) ->
      client.get "/posts?days=7&feed=undergrad", checkWeek "undergrad", done

checkToday = (feed, done) ->
  (err, req, res, data) ->
    if err
      done err
    loadToday feed, (today) ->
      assert.deepEqual data, today
      done()

checkWeek = (feed, done) ->
  (err, req, res, data) ->
    if err
      done err
    loadWeek feed, (week) ->
      assert.deepEqual data, week
      done()

loadToday = (feed, next) ->
  fs.readFile "#{testdata}/12-13-1-#{feed}.json", (err, data) ->
    if err
      throw err
    next JSON.parse data

loadWeek = (feed, next) ->
  fs.readFile "#{testdata}/12-13-7-#{feed}.json", (err, data) ->
    if err
      throw err
    next JSON.parse data
