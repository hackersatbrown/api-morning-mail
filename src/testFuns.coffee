loader = require "./loader"
testData = "test/data"

module.exports =
  # Fetches test data based on the request.
  # Right now this just returns today for feed 'all'.
  fetchRes: (req, res, next) ->
    [days, date, feed] = [req.params.days, req.params.date, req.params.feed]
    md = date.substr 0, date.lastIndexOf "-"
    loader.loadFile "#{testData}/#{md}-#{days}-#{feed}.xml", (result) ->
      req.params.xml = result
      next()

  getToday: -> "12-13-2012"

  addTestKeys: (store) ->
    addKey = (name, perms) ->
      store.add name,
        key: name
        active: true
        permissions: perms
      , (err) -> err
    addKey "test-key", {}
    addKey "test-admin-key", adminKeys: true
