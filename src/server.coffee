restify = require "restify"

server = restify.createServer name: "morning-mail"

switch process.env.NODE_ENV
  when "development", "test"
    # Do something to load in some fake data
    null
  when "production"
    # Do some real stuff
    null

server.get "/posts", (req, res, next) ->
  res.send 500, "NYI"

server.listen (process.env.PORT or 8080), ->
  console.log "#{server.name} listening at #{server.url}"
