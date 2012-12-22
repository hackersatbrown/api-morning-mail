should = require "should"
_ = require "underscore"
keysLib = require "../bin/keys"
h = require "./helpers"

# Create a mock store so we don't need to rely on a db
makeStore = ->
  storeObj = {}
  store =
    data: {} # public so we can cheat
    add: (key, keyObj, done) ->
      this.data[key] = keyObj
      done()
    lookup: (key, done) ->
      res = this.data[key]
      if res then done null, res else done "not found!"
    update: (args...) -> this.add args... # Yay JS object semantics!
  store

describe.only "keys", ->

  keys = null
  store = null
  beforeEach ->
    store = makeStore()
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

    it "should create a key with default permissions", (done) ->
      keys.create null, checkCreate(read: true, done)

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
      keys.deactivate "missing", h.shouldErr done

    it "should error if given a non-string key", (done) ->
      keys.deactivate 42, h.shouldErr done

  describe ".check()", ->

    beforeEach ->
      store.data["pineapple"] =
        key: "pineapple"
        active: true
        permissions:
          beSweet: true
          beSpicy: false
          read: true

    it "should call next w/o err if given a valid key/perm pair", (done) ->
      # Simulating what we get from Restify
      keys.check(["beSweet"]) username: "pineapple", {}, done

    it "should call next w/o err if given a valid key but no perms and " +
       "that key has the default perm", (done) ->
      keys.check() username: "pineapple", {}, done

    it "should call next w/o err if given a valid key and an empty list " +
       "of permissions", (done) ->
      keys.check([]) username: "pineapple", {}, done

    it "should error (401) if given an invalid key", (done) ->
      keys.check([]) username: "banana", {}, h.shouldErr(done, 401)

    it "should error (400) if not given a key", (done) ->
      keys.check([]) {}, {}, h.shouldErr(done, 400)

    it "should error (400) if given an non-string key", (done) ->
      keys.check([]) username: 888, {}, h.shouldErr(done, 400)
