---

[Pre-Requirements](#pre-requirements) | [Running](#running) | [Tech Stack](#tech-stack) | [Testing](#testing) | [Debugging](#debugging) | [Formatting](#formatting) | [Publishing](#publishing)
---

# Contributing

Contributions are always welcome, no matter how large or small.

## Pre-Requirements

You need to have installed:

* [nodejs](https://nodejs.org/en/download/)
* npm 5+ (run `npm -g install npm`)
* elm (run `npm -g install elm`)
* [Firefox Quantum](https://www.mozilla.org/en-US/firefox/quantum/)

## Running

First install the dependencies

```
npm install
```

This will download both javascript and elm dependencies. Now, start the project:

```
npm start
```

It should fire up firefox for you, now go to `facebook.com` or `twitter.com`, sign in and scroll to see it working on some news.

## Tech Stack

The main languages of the project are Elm and JavaScript. Elm is used for building the UI elements and comunication with the [API](https://github.com/fake-news-detector/fake-news-detector/tree/master/api), while JavaScript is the glue for injecting Elm on the pages and accessing WebExtensions functions.

If you don't know Elm, don't worry, you can contribute without it, but if you want to know more, the best place to start is the [official guide](https://guide.elm-lang.org/).

For styling, we use [style-elements](http://package.elm-lang.org/packages/mdgriffith/style-elements/latest), a different but easy-to-learn way to style your UI, that takes advantage from Elm's type safety. You can read [this guide](https://mdgriffith.gitbooks.io/style-elements/content/) to learn more.

The JavaScript code is vanilla ES6, with pretty standard libs (mocha, webpack, babel).

Also, the Fake News Detector uses WebExtensions, which is the new standard for developing cross-browsers extensions. You can learn more about it from the [Mozilla Docs](https://developer.mozilla.org/en-US/Add-ons/WebExtensions), they have a couple nice examples that makes it easy to learn.

## Testing

To run the tests, you can execute:

```
npm test
```

If you want it in watch mode, you can run `npm run test:watch`

The JavaScript code is more important to test because it is much more fragile.

Since it is the JavaScript that injects the extension on twitter and facebook, any changes on their layout might break the extension.

For testing that, we use fixtures, which are a snapshot from the original html snippets where the extension will plug into, they live at `test/fixtures`.

## Debugging

If the extension throws an exception or if you add any `console.log`, it won't show on the regular browser console, neither the network requests.

Instead, for debugging it on firefox you will need to open Tools > Web Developer > Browser Toolbox

![Tools > Web Developer > Browser Toolbox](https://user-images.githubusercontent.com/792201/31666402-d81136dc-b32a-11e7-885c-4daa770d67bd.png)

This console shows the logs from _everything_ on the browser, which can be too much noisy, to focus on developing the extension, you can type `bundle.js` on the search field on the top left corner.

![Filtering bundle.js](https://user-images.githubusercontent.com/792201/31666481-285ab38e-b32b-11e7-89a1-788ac5bfeb68.png)

Here are some urls you can go to test the extension:

* https://www.facebook.com/ and https://twitter.com/ to test the feed
* http://www.boatos.org/ for hoaxes
* https://g1.globo.com/ for verified news
* https://www.buzzfeed.com/ for click baits
* https://ceticismopolitico.com/ for extremely biased

## Formatting

For automatically format the source code, we use two opinionated tools:

* [elm-format](https://github.com/avh4/elm-format) for Elm code
* [Prettier](https://prettier.io/) for JavaScript code

They both have good integrations with almost every code editor, you should install them on your editor because they format the code automatically, keeping a standard across the codebase.

Also, we add no configuration to them, just install the plugins and use the standard behaviours, this way we eliminate the discussions about formatting on PRs.

## Publishing

The extension is published on Chrome Webstore and Mozilla Addons.

The publishing is automatically done to Chrome Webstore, you just need to bump the version on the `manifest.json` file. After merging to master [the CircleCI pipeline](https://circleci.com/gh/fake-news-detector/extension) will build the changes and publish it.

But, for Firefox, it still has to be published manually, so remember to inform the maintainers if your change needs a new publishing.
