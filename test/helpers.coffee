_ = require "underscore"
restify = require "restify"
should = require "should"

module.exports =

  # Set up whatever we need to set up before the tests run.
  setup: ->
    before ->
      process.env.NODE_ENV = "test"
      require "../bin/server"

  createTestClient: (opts, key) ->
    client = restify.createJsonClient _.extend(
      url: "http://localhost:8080"
    , opts)
    client.basicAuth (key ? "test-key"), "" # TODO fill in test key
    client

  guardErr: (handler) ->
    (err, args...) -> should.not.exist err; handler args...

  shouldErr: (done, status) ->
    (err) ->
      should.exist err
      err.should.have.status status if status?
      done()
