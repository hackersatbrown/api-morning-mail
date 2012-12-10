restify = require "restify"

server = restify.createServer name: "morning-mail"

server.all "*", (req, res, next) ->
  res.send 500, "NYI"

server.listen 8080, ->
  console.log "#{server.name} listening at #{server.url}"
