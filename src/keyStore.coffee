keyLib = require "./keys"
_ = require "underscore"
redis = require "redis"

makeRedisStore = ->
  # TODO will need to set host and port when running in production
  client = redis.createClient()
  add: (key, keyObj, done) ->
    client.set key, JSON.stringify(keyObj), done
  update: (args...) -> this.add args... # same as add
  lookup: (key, done) ->
    client.get key, (err, data) ->
      if err
        done err
      else
        done null, JSON.parse data.toString()

store = null

switch process.env.NODE_ENV
  when "test", "development"
    t = require "./testFuns"
    if process.env.TEST_REDIS
      store = makeRedisStore() 
    else
      store = t.makeStore()
    t.addTestKeys store
  when "production"
    store = makeRedisStore() 

module.exports = keyLib.init store
