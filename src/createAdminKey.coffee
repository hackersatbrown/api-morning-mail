keyStore = require "./keyStore"

keyStore.create { adminKeys: true }, (err, key) ->
  if err or not key
    console.error "Error creating key:"
    console.error err
    process.exit 1
  else
    console.log "Created key #{key} with permission \"adminKeys\""
