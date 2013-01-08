loader = require "./loader"
testData = "test/data"
today = "12-13-2012"

module.exports =

  # Fetches test data based on the request.
  # Right now this just returns today for feed 'all'.
  fetchRes: (req, res, next) ->
    [days, date, feed] = [req.params.span, today, req.params.feed]
    md = date[...date.lastIndexOf "-"]
    loader.loadFile "#{testData}/#{md}-#{days}-#{feed}.xml", (err, result) ->
      return next err if err
      req.resultXml = result
      next()

  getToday: -> today

  makeStore: ->
    data: {} # public so we can cheat
    add: (key, keyObj, done) ->
      this.data[key] = keyObj
      done()
    lookup: (key, done) ->
      res = this.data[key]
      if res then done null, res else done "not found!"
    update: (args...) -> this.add args... # Yay JS object semantics!

  addTestKeys: (store) ->
    addKey = (name, perms) ->
      store.add name,
        key: name
        active: true
        permissions: perms
      , (err) -> err
    addKey "test-key", {}
    addKey "test-admin-key", adminKeys: true
