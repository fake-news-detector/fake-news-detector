---

[Pre-Requirements](#pre-requirements) | [Running](#running) | [Testing](#testing) | [Postman](#postman) | [Running outside docker](#running-outside-docker) | [Tech Stack](#tech-stack) | [Formatting](#formatting) | [Deploy](#deploy) | [Jobs](#jobs)
---

# Contributing

Contributions are always welcome, no matter how large or small.

## Pre-Requirements

You need to have installed:

* [docker](https://www.docker.com/docker)
* optional: rust nightly (install using [rustup](https://www.rustup.rs/))
* optional: [elm](https://guide.elm-lang.org/install.html)

## Running

```
docker-compose up
```

It will take a while, about 20 minutes to download an compile all rust dependencies.

But that's it! Now go to `http://localhost:8000/admin` and it should be running.

The default credentials for logging in the admin area are email: `admin@fakenewsdetector.org`, password: `123`

## Testing

To run the tests, with `docker-compose up` running, fire up another terminal and execute:

`docker-compose exec web cargo test`

If you want to run it in watch mode, use:

`docker-compose exec web cargo watch -x test`

## Postman

Postman is an app that helps you make requests when developing APIs.

We have a postman collection ready for you to use for debugging the API, just [download postman](https://www.getpostman.com/) and import the `dev/postman_collection.json` file.

<img width="310" src="https://user-images.githubusercontent.com/792201/31867369-ff4e8060-b76c-11e7-9ea8-2ddbfebec215.png" alt="Postman Collection">

## Running Outside Docker

If you want to run the app outside docker for faster development flow, you will need to install [nightly rust](https://doc.rust-lang.org/1.2.0/book/nightly-rust.html), [cargo watch](https://github.com/passcod/cargo-watch) and [nodejs](https://nodejs.org/en/).

Also, you will need to have a postgres database running, if you don't, you can run it with docker-compose:

```
docker-compose up database
```

Install the rust and js dependencies:

```
cargo build
cd src/scrapper/
npm install
cd -
```

Then start the app:

```
cargo watch -w src -x run
```

For compiling the admin area:

```
cargo watch -w admin -s "elm-make --yes admin/Main.elm --output target/admin.js"
```

To run the tests:

```
cargo watch -x test
```

## Tech Stack

This project is done in Rust, if you don't know Rust yet, the [official guide](https://doc.rust-lang.org/stable/book/) is a good place to start. It shouldn't take very long before you can start contributing, just a few first chapters and you should be good to go, the compiler helps a lot.

For the web framework we use [rocket](https://rocket.rs/), for starting a web server, routing, json-responses, etc.

We use [PostgreSQL](https://www.postgresql.org/) for the database, with [Diesel](http://diesel.rs/) as the ORM for connecting with Rust and run the migrations.

Finally, we use [docker-compose](https://docs.docker.com/compose/) to launch the database and build an image with everything we need to run the project. By using docker we ensure that what's running locally is as close as possible from production.

## Formatting

We use [rustfmt](https://github.com/rust-lang-nursery/rustfmt) to automatically format the source code, please use it as well when developing new features, it integrates with most text editors and IDEs and keep a standard across the codebase.

Also, we add no configuration to it, just use the standard behaviours, this way we eliminate the discussions about formatting on PRs.

## Configuring your IDE

To develop with Rust, having a well configured IDE helps A LOT, once you have a well configured one, you won't be able to code Rust without it anymore, so we recomment to spend a few minutes doing it.

[Visual Studio Code](https://code.visualstudio.com/) has a good support for Rust. After installing it add the [Rust Lang Extension](https://marketplace.visualstudio.com/items?itemName=kalitaalexey.vscode-rust), it should take you about half an hour to configure it well. Things to check:

* Autocomplete is working
* Code autoformats on save (rustfmt)
* Compilation errors and warnings show up on the IDE
* Code compiles on save

## Deploy

The deploy is automatically done by [the CircleCI pipeline](https://circleci.com/gh/fake-news-detector/api) after merging to master.

If you want to learn more how it works, read about deploying to heroku with docker [on the oficial docs](https://devcenter.heroku.com/articles/container-registry-and-runtime).

## Jobs

There are some jobs for helping administrating the app, for creating and running migrations, check out [diesel's docummentation](http://diesel.rs/). If you are running any diesel's job outside docker, you have to `export DATABASE_URL=postgres://postgres:password@localhost:5432/fakenews`.

Custom jobs are added on the `src/jobs.rs` file, and ran like this:

```
cargo run -- --scrape-missing-data
```

or, if the app is installed:

```
fake-news-api --scrape-missing-data
```
