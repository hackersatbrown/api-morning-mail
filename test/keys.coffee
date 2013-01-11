should = require "should"
_ = require "underscore"
keysLib = require "../bin/keys"
tf = require "../bin/testFuns"
t = require "testify"

describe "keys", ->

  keys = null
  store = null
  beforeEach ->
    # Create a mock store so we don't need to rely on a db
    store = tf.makeStore()
    keys = keysLib.init store

  describe ".create()", ->

    checkCreate = (perms, done) ->
      (err, key) ->
        should.not.exist err
        should.exist key
        key.should.be.a "string"
        k = store.data[key]
        # NOTE(jmkagan): should.eql does deep equality, not should.equal
        should.exist k
        k.should.have.keys "key", "active", "permissions"
        #k.key.should.be.a "string"
        k.key.should.equal key
        k.active.should.be.true
        #k.permissions.should.be.a "object"
        k.permissions.should.eql perms
        done()

    it "should create a key with no permissions", (done) ->
      keys.create null, checkCreate([], done)

    it "should create a key with the given permissions", (done) ->
      perms = 
        speech: true, 
        race: true,
        religion: false
      keys.create perms, checkCreate(_.clone(perms), done)

    it.skip "shouldn't create duplicate keys, but we can't really test that..."

  describe ".deactivate()", ->

    beforeEach ->
      store.data["42"] = key: "42", active: true, permissions: {}

    it "should deactivate the given key", (done) ->
      keys.deactivate "42", (err) ->
        should.not.exist err
        k = store.data["42"]
        should.exist k
        k.should.have.property "active"
        k.active.should.be.false
        done()

    it "should error if given a valid key", (done) ->
      keys.deactivate "missing", t.shouldErr done

    it "should error if given a non-string key", (done) ->
      keys.deactivate 42, t.shouldErr done

  describe ".check()", ->

    beforeEach ->
      store.data["pineapple"] =
        key: "pineapple"
        active: true
        permissions:
          beSweet: true
          beSpicy: false

    makeReq = (key) -> # Simulate Restify's auth parser
      authorization: basic: username: key

    it "should call next w/o err if given a valid key/perm pair", (done) ->
      keys.check(["beSweet"]) makeReq("pineapple"), {}, done

    it "should call next w/o err if given a valid key but no perms", (done) ->
      keys.check() makeReq("pineapple"), {}, done

    it "should call next w/o err if given a valid key and an empty list " +
       "of permissions", (done) ->
      keys.check([]) makeReq("pineapple"), {}, done

    shouldErr = (done, status) ->
      (err) -> should.exist err; done()

    it "should error (401) if given an invalid key", (done) ->
      keys.check([]) makeReq("banana"), {}, shouldErr done

    it "should error (400) if not given a key", (done) ->
      keys.check([]) {}, {}, shouldErr done

    it "should error (400) if given an non-string key", (done) ->
      keys.check([]) makeReq(888), {}, shouldErr done
