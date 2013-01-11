# API - Morning Mail

A wrapper around Brown's Morning Mail Feed.

## Developing

To work on this repo, make a branch for the feature you are working on, and then submit a pull request to merge it back into master.

To get the code running, first install dependencies:

    $ npm install

Then build:

    $ make

Then run the server:

    $ ./run.sh
    morning-mail listening at http://0.0.0.0:8080

Note that at least one of the dependencies listed in `package.json` (Testify) is a reference to another Git repo. If you want a new version of that library, you'll need to delete the installed version so you can upgrade, like so:

    $ rm -rf node_modules/testify
    $ npm install

## Deploying

The code is deployed by pushing the `deploy` branch to a remote Heroku
repository. Basically, the flow is: merge `master` into `deploy`, commit new
compiled files in `deploy`, push `deploy` to Heroku. You should do this all
using:

    $ make deploy

## Testing

To run the tests, just run `make test`.

Note that this will use a mock key store when testing the key management API. To test with the actual Redis store, follow these steps:

1. Install Redis
2. Start a local Redis server: `$ redis-server`
3. Set the `TEST_REDIS` option to `true` in `test/_config.coffee`
