fs = require "fs"
restify = require "restify"

module.exports.loadFile = (file, next) ->
  fs.readFile file, (err, data) ->
    if err
      next new restify.InternalError "File not found: #{file}"
    next null, data
