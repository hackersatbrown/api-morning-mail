keyLib = require "./keys"

# TODO replace this temp store with a persistent store
# but maybe keep this one for testing?
store = ((->
  data = {}
  store =
    add: (key, keyObj, done) ->
      data[key] = keyObj
      done()
    lookup: (key, done) ->
      res = data[key]
      if res then done null, res else done "not found!"
    update: (args...) -> this.add args...
  store
)())

switch process.env.NODE_ENV
  when "test"
    t = require "./testFuns"
    t.addTestKeys store

module.exports = keyLib.init store
