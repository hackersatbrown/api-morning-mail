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

## Building for production

### Setup

First, you'll need to have the Heroku production repo cloned in a dir called `prod`.
To clone this repo, run:

    $ heroku git:clone --app api-morning-mail

(Taken from <https://devcenter.heroku.com/articles/collab>.) You'll have to
have shared access to the application first, which is controlled by
@jonahkagan.

### Building

To build for production, run:

    $ make prod

The command will build and copy the necessary files to `prod`. If you want to
deploy, just run:

    $ cd prod && git push

It's usually nice to test out that the production version runs first by doing
this:

    $ cd prod && foreman start
    17:54:09 web.1  | started with pid 21324
    17:54:09 web.1  | morning-mail listening at http://0.0.0.0:5000

## Testing

To run the tests, just run `make test`.

Note that this will use a mock key store when testing the key management API. To test with the actual Redis store, follow these steps:

1. Install Redis
2. Start a local Redis server: `$ redis-server`
3. Set the `TEST_REDIS` option to `true` in `test/_config.coffee`
