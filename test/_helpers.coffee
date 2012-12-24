_ = require "underscore"
restify = require "restify"
should = require "should"

config = require "./_config"

module.exports =

  # Set up whatever we need to set up before the tests run.
  setup: ->
    before ->
      process.env.NODE_ENV = "test"
      if config.TEST_REDIS then process.env.TEST_REDIS = true
      require "../bin/server"

  createTestClient: (opts, key) ->
    client = restify.createJsonClient _.extend(
      url: "http://localhost:8080"
    , opts)
    client.basicAuth (key ? "test-key"), ""
    client

  guardErr: (handler) ->
    (err, req, res, args...) ->
      res.should.have.status 200
      should.not.exist err
      handler req, res, args...

  shouldErr: (done, status) ->
    (err) ->
      should.exist err
      err.should.have.status status if status?
      done()
