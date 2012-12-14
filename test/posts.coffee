restify = require "restify"
assert = require "assert"
fs = require "fs"

client = restify.createJsonClient url: "http://localhost:8080"
testdata = "test/data/json"

# Set up our server
before ->
  process.env.NODE_ENV = "test"
  require "../bin/server"


describe "/v1/posts", ->
  
  describe "GET /v1/posts", ->

    ### # TEST COMBINATIONS OF TODAY 
    ###
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/v1/posts", checkFile done
    
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/v1/posts?days=1", checkFile done

    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/v1/posts?days=1&date=12-13-12", checkFile done
      
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/v1/posts?days=1&date=12-13-12&feed=all", checkFile done
    
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/v1/posts?date=12-13-12", checkFile done
    
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/v1/posts?date=12-13-12&feed=all", checkFile done
   
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/v1/posts?date=12-13-12&feed=all&days=1", checkFile done
    
    it "should send 12-13's 'all' MM posts", (done) ->
      client.get "/v1/posts?feed=all", checkFile done
    
    it "should send 12-13's 'undergrad' MM posts", (done) ->
      client.get "/v1/posts?feed=undergrad", checkFile done, "1", "12-13-2012", "undergrad"
    
    ### # TEST THE LAST WEEK
    ###
    it "should send the last week of 'all' MM posts", (done) ->
      client.get "/v1/posts?days=7&feed=undergrad", checkFile done, "7"
    
    it "should send the last week of 'undergrad' MM posts", (done) ->
      client.get "/v1/posts?days=7&feed=undergrad", checkFile done, "7", "12-13-2012", "undergrad"

    ### # TEST RANGES
    ###
    it "should send the last two days of 'all' MM posts", (done) ->
      client.get "/v1/posts?days=2", checkFile done, "2", "12-13-2012"

    it "should send the last three days of 'undergrad' MM posts", (done) ->
      client.get "/v1/posts?days=3&feed=undergrad", checkFile done, "3", "12-13-2012", "undergrad"

    it "should send 'all' MM posts from 12-11 and 12-12", (done) ->
      client.get "/v1/posts?date=12-12-2012&days=2", checkFile done, "2", "12-12-2012"

    it "should send 'undergrad' MM posts from 12-08 to 12-11", (done) ->
      client.get "/v1/posts?date=12-11-2012&days=4&feed=undergrad",
        checkFile done, "4", "12-11-2012", "undergrad"

    it "should send 'all' MM posts from 12-07", (done) ->
      client.get "/v1/posts?date=12-07-2012&days=1&feed=all", checkFile done, "1", "12-07-2012"

    it "should send 'undergrad' MM posts from 12-07 to 12-12", (done) ->
      client.get "/v1/posts?date=12-12-2012&days=6&feed=undergrad",
        checkFile done, "6", "12-12-2012", "undergrad"
      

### # NEED TO TEST INDIVIDUAL POSTS AS WELL
###
describe "/v1/posts/:id", ->

  describe "GET /v1/posts/:id", ->

    it "should return BSA holiday sale announcement from 12-13", (done) ->
      client.get "/v1/posts/43327", checkId done, "43327"

    it "should return Conversation about Cuba event from 12-09", (done) ->
      client.get "/v1/posts/43395", checkId done, "43395"

    it "should return Winter Closing information from 12-10", (done) ->
      client.get "/v1/posts/43395", checkId done, "43575"


checkFile = (done, days = "1", date = "12-13-2012", feed = "all") ->
  (err, req, res, data) ->
    if err
      done err
    md = date.substr 0, date.lastIndexOf "-"
    loadFile "#{md}-#{days}-#{feed}.json", (result) ->
      assert.deepEqual data, result
      done()

loadFile = (file, next) ->
  fs.readFile "#{testdata}/#{file}", (err, data) ->
    if err
      throw err
    next JSON.parse data

checkId = (done, id) ->
  (err, req, res, data) ->
    if err
      done err
    loadId "#{id}.json", (result) ->
      assert.deepEqual data, result
      done()

loadId = (file, next) ->
  fs.readFile "#{testdata}/#{file}", (err, data) ->
    if err
      throw err
    next JSON.parse data
