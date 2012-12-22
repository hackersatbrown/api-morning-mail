_ = require "underscore"
restify = require "restify"
uuid = require "node-uuid"

# We parameterize over a store, which must have the following interface:
#   add: string, object, (err -> any) -> any
#   lookup: string, (err, object -> any) -> any
#   update: string, object, (err -> any) -> any
# Each function takes a callback that should be invoked with an error as its
# first argument (or null/undefined if no error occurred). Lookup's callback
# expects the result of the lookup as its second argument.

module.exports.init = (store) ->

  # Internally, a key is a {
  #   key: string (unique)
  #   active: boolean
  #   permissions: {
  #     <name>: bool
  #     ...
  #   }
  # }

  generateKey = ->
    uuid.v4()

  checkPerms = (key, perms, done) ->
    store.lookup key, (err, keyObj) ->
      if err
        done new restify.InvalidCredentialsError "Invalid key: #{key}"
      else if (keyObj.active and
              _.every perms, (p) -> keyObj.permissions[p])
        done null, true
      else
        done new restify.InvalidCredentialsError(
          "Key #{key} does not have permissions #{perms}")

  create: (perms = {}, done) ->
    # TODO check for uniqueness
    key = generateKey()
    keyObj = 
      key: key
      active: true
      permissions: _.clone perms
    store.add key, keyObj, (err) ->
      done err, key

  deactivate: (key, done) ->
    return done new Error "expected key to be a string" if not _.isString key
    store.lookup key, (err, keyObj) ->
      return done err if err
      keyObj.active = false
      store.update key, keyObj, done

  check: (perms = []) ->
    (req, res, next) ->
      # We expect that the key has been parsed out of the request and put in
      # the username field, since that's what Restify does.
      if not req.username?
        next new restify.InvalidContentError "Missing key"
      else if not _.isString req.username
        next new restify.InvalidContentError "Key must be a string"
      else
        checkPerms req.username, perms, next
