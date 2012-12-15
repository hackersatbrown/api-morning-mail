loader = require "./loader"
testdata = "test/data"

# Fetches test data based on the request.
# Right now this just returns today for feed 'all'.
fetchRes = (req, res, next) ->
  days = req.params.days
  date = req.params.date
  feed = req.params.feed
  md = date.substr 0, date.lastIndexOf "-"
  loader.loadFile "#{testdata}/#{md}-#{days}-#{feed}.xml", (result) ->
    req.params.xml = result
    next()

getToday = ->
      "12-13-2012"

exports.fetchRes = fetchRes
exports.getToday = getToday
