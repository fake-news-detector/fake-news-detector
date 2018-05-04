# Fake News Detector API

## JSON API endpoints

The JSON API is currently running under the url https://api.fakenewsdetector.org/

### Categories

The news are flagged on distinct categories, such as Fake News, Click Bait, etc, you can list all with this call:

`GET /categories`

Response format:

`[{ id: int, name: string }]`

### Links

You can list all links and their data with:

`GET /links/all`

Response format:

```
[{
  id: int,
  url: string,
  title: string,
  content: null | string,
  category_id: bool,
  clickbait_title: null | bool,
  verified_category_id: null | string,
  count: int
}]
```

This endpoint is used by [Robinho](https://github.com/fake-news-detector/fake-news-detector/tree/master/robinho) to fetch the links and train its classification algorithms.

### Votes

You can get all votes to a specific link with:

`GET /votes?url=string&title=string`

or, if you only have the text content but not a link (like hoaxes from Whatsapp):

`GET /votes_by_content?content=string`

Response format:

```
{
  domain: null | { category_id: int },
  robot: {
    fake_news: float,
    extremely_biased: float,
    clickbait: float
  },
  people: {
    content: [{ category_id: int, count: int }],
    title: { clickbait: bool, count: int },
  },
  keywords: [ string ]
}
```

The `domain` key is only present if the given url is listed on one of our [manually verified domains](https://github.com/fake-news-detector/fake-news-detector/blob/master/api/src/data/verified_domains.rs).
When present, this value should be used over robot guesses.

The `keywords` are extracted from the title and content to be used later for automatic googling for the users to fact-check themselves.

To insert a new vote, use this call:

`POST /vote`

Parameters:

`{ uuid: string, url: string, title: string, category_id: int, clickbait_title: null | bool }`

Or, if you only have the text of a hoax to insert, use:

`POST /vote_by_content`

Parameters:

`{ uuid: string, content: string, category_id: int }`

Response format:

`{ link_id: int, category_id: int, uuid: string, ip: string }`

The votes endpoints are used by the [Fake News Extension](https://github.com/fake-news-detector/fake-news-detector/tree/master/extension) and the [Fake News Website](https://github.com/fake-news-detector/fake-news-detector/tree/master/site).

# Contributing

If you want to help the project, you can fork it and run on your machine, for more details, read the [CONTRIBUTING.md](https://github.com/fake-news-detector/fake-news-detector/blob/master/api/CONTRIBUTING.md) guide.
