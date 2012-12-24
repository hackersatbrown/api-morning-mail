# API - Morning Mail

A wrapper around Brown's Morning Mail Feed.

To work on this repo, make a branch for the feature you are working on, and then submit a pull request to merge it back into master.

## Testing

To run the tests, just run `make test`.

Note that this will use a mock key store when testing the key management API. To test with the actual Redis store, follow these steps:

1. Install Redis
2. Start a local Redis server: `$ redis-server`
3. Set the `TEST_REDIS` option to `true` in `test/_config.coffee`
