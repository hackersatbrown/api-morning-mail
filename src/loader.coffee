fs = require "fs"

loadFile = (file, next) ->
  fs.readFile file, (err, data) ->
    if err
      throw err
    next JSON.parse data

loadId = (file, next) ->
  fs.readFile file, (err, data) ->
    if err
      throw err
    next JSON.parse data

exports.loadFile = loadFile
exports.loadId = loadId
