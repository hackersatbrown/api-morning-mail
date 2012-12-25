# This file will run before any tests.
# Set up whatever we need to set up before the tests run.
config = require "./_config"
before ->
  process.env.NODE_ENV = "test"
  if config.TEST_REDIS then process.env.TEST_REDIS = true
  require "../bin/server"
