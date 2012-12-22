keyLib = require "./keys"

# TODO replace this temp store with a persistent store
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
    addKey = (name, perms) ->
      store.add name,
        key: name
        active: true
        permissions: perms
      , (err) -> err
    addKey "test-key", {}
    addKey "test-admin-key", adminKeys: true

module.exports = keyLib.init store
