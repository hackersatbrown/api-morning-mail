h = require "./_helpers"
should = require "should"

client = h.createTestClient()
adminClient = h.createTestClient {}, "test-admin-key"

describe "/v1/keys", ->

  describe "POST /v1/keys", ->

    it "should send a fresh key if req key has admin permissions",
      (done) ->
        adminClient.post "/v1/keys", {}, h.guardErr (req, res, data) ->
          should.exist data
          data.should.have.property "key" 
          data.key.should.be.a "string"
          done()

    it "should send an error (401) if req key doesn't have admin permisions",
      (done) ->
        client.post "/v1/keys", {}, h.shouldErr(done, 401)

    it.skip "should send a key that authorizes other requests",
      (done) -> throw "NYI" # TODO
          
describe "/v1/keys/:key", ->

  describe "DELETE /v1/keys/:key", ->

    key = null
    beforeEach (done) ->
      adminClient.post "/v1/keys", {}, (err, req, res, data) ->
        key = data.key
        done()

    it "should deactivate the key if req key has admin permissions",
      (done) ->
        adminClient.del "/v1/keys/#{key}", h.guardErr (req, res, data) ->
          done()

    it "should send an error (401) if req key doesn't have admin permissions",
      (done) ->
        client.del "/v1/keys/#{key}", h.shouldErr(done, 401)

    it.skip "should make the key not able to authorize other requests",
      (done) -> throw "NYI" # TODO
