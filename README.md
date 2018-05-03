[![Build Status][ci-svg]][ci-url]

[ci-svg]: https://circleci.com/gh/fake-news-detector/robinho.svg?style=shield
[ci-url]: https://circleci.com/gh/fake-news-detector/robinho

# The Fake News Detector

The [Fake News Detector](https://fakenewsdetector.org/) is an extension for [Chrome](https://chrome.google.com/webstore/detail/fake-news-detector/alomdfnfpbaagehmdokilpbjcjhacabk)
and [Firefox](https://addons.mozilla.org/en-US/firefox/addon/fakenews-detector/)
that allows you to detect and flag news directly from your Facebook into
**Legitimate**, **Fake News**, **Click Bait**, **Extremely Biased**, **Satire** or **Not news**.

After flagging a newstory, other people that have the extension will be able to see your flagging,
will pay more attention to it and may also flag it. The data is then saved on a database and read by our robot,
[Robinho](https://github.com/fake-news-detector/robinho).

Robinho reads the information given by us humans and learn with time to automatically flag
news as Fake News, Click Bait, etc, based on its text. By doing that, even fresh news that no
one saw may be quickly flagged.

# Contributing

This is the main repo for the project, which is divided into smaller projects, you can read more about those and learn how to contribute to them:

### /robinho <small>[ [README](robinho/README.md) ]</small>

This is where our machine learning models live, it also provides an endpoint for giving predictions. It uses Python.

### /api <small>[ [README](api/README.md) | [CONTRIBUTING](api/CONTRIBUTING.md) ]</small>

The API saves flagged content to the database, retrieve them, authenticate users and so on, basically all backend work except predictions. It uses Rust.

### /extension <small>[ [README](extension/README.md) | [CONTRIBUTING](extension/CONTRIBUTING.md) ]</small>

This is the WebExtension that users can install to flag and detect bad content on their twitter and facebook feeds. It uses Elm and JavaScript.

### /site <small>[ [README](site/README.md) ]</small>

This is the main website, which also allows users to check and flag content without having to install the extension. It uses Elm.

---

Also check out the [issues](https://github.com/fake-news-detector/robinho/issues) to find some things that you can do to help.
