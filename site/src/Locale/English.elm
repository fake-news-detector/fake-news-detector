module Locale.English exposing (..)

import Locale.Words exposing (LocaleKey(..))


translate : LocaleKey -> String
translate localeValue =
    case localeValue of
        Loading ->
            "Loading..."

        FlagContent ->
            "Flag Content"

        FlagQuestion ->
            "Which of the following options best defines this content?"

        FlagSubmitButton ->
            "Submit"

        Legitimate ->
            "Legitimate"

        LegitimateDescription ->
            "Honest content, does not try to fool anyone"

        FakeNews ->
            "Fake News"

        FakeNewsDescription ->
            "Tries to fool the reader and spreads rumors"

        Biased ->
            "Biased"

        ExtremelyBiased ->
            "Extremely Biased"

        ExtremelyBiasedDescription ->
            "Shows only one side of the story, some points of the news are exaggerated"

        Satire ->
            "Satire"

        SatireDescription ->
            "Fake content on purpose, just to make humor"

        NotNews ->
            "Not News"

        NotNewsDescription ->
            "Meme, personal content or anything that is not news"

        Clickbait ->
            "Clickbait"

        ClickbaitQuestion ->
            "Is the title Clickbait?"

        ClickbaitDescription ->
            "Eye-catching title, intentionally hides informations about the content just to trigger your curiosity to click"

        Yes ->
            "Yes"

        No ->
            "No"

        DontKnow ->
            "I don't know"

        FillAllFields ->
            "Fill all the fields"

        Verified ->
            "(verified)"

        FlagButton ->
            "🏴 Flag it"

        InvalidQueryError ->
            "Paste a valid link, a text or type more keywords to check"

        LoadingError ->
            "loading error"

        TimeoutError ->
            "Timeout: the operation took too long to execute"

        NetworkError ->
            "Network error: check your internet connection"

        Explanation ->
            explanation

        Check ->
            "check"

        PasteLink ->
            "Paste a suspicious link or text here, or use keywords to search for a hoax"

        FakeNewsDetector ->
            "Fake News Detector"

        AddToChrome ->
            "Add to Chrome"

        AddToFirefox ->
            "Add to Firefox"

        RobinhosOpinion ->
            "Robinho's opinion"

        PeoplesOpinion ->
            "People's opinion"

        NothingWrongExample ->
            "There doesn't seem to be anything wrong with this content. Want an example? "

        ClickHere ->
            "Click here"

        HelpImproveResult ->
            "Do you believe this result is wrong?"

        ContentFlagged ->
            "Content flagged, thank you!"

        LooksLike ->
            "Looks like"

        LooksALotLike ->
            "Looks a lot like"

        AlmostCertain ->
            "I'm almost certain it is"

        HelpRobinho ->
            "Help Robinho"

        CheckYourself ->
            "Check it yourself"

        WeDidAGoogleSearch ->
            "We did a Google search with keywords extracted from the text"

        TwitterSpread ->
            "Spread on Twitter"

        CheckHowItIsSpreading ->
            "Check how this is spreading on twitter"

        LoadingTweets ->
            "Loading tweets..."

        NoTweetsFound ->
            "No tweets found"

        YouNeedToSignInWithTwitter ->
            "To build the spread graph, we need you to login with you Twitter account"

        SignInWithTwitter ->
            "Sign in with Twitter"


explanation : String
explanation =
    """

## What is this?

The Fake News Detector allows you to detect and flag **Fake News**, **Click Baits** and
**Extremely Biased** news, thanks to our robot, [Robinho](https://github.com/fake-news-detector/fake-news-detector/tree/master/robinho).

There are several ways to use the Fake News Detector:

- Install the extension for [Chrome](https://chrome.google.com/webstore/detail/fake-news-detector/alomdfnfpbaagehmdokilpbjcjhacabk)
or [Firefox](https://addons.mozilla.org/en-US/firefox/addon/fakenews-detector/), this checks the news directly from your Twitter and Facebook feeds
- Talk directly with Robinho [on Telegram](https://t.me/RobinhoFakeBot)
- Copy and paste the link or text on the field above to check

## How it works?

After flagging a newstory, other people that use the Fake News Detector will be able to see your flagging,
will pay more attention to it and may also flag. The data is then saved on a database and read by Robinho.

Robinho reads the information given by us humans and learn with time to automatically flag
news as Fake News, Click Bait, etc, based on its text. By doing that, even fresh news that no
one saw may be quickly flagged.

The extension then show on your facebook the opinion from other people and from the robot:

<img src="static/clickbait.png" width="471" alt="Extension showing that news was rated as clickbait on Facebook" />

The more you flag the news, more you contribute to building a database to better teach Robinho,
which is still in very early development, look, he is still a baby robot:

<img src="static/robinho.jpg" width="350" alt="Picture of Robinho">

<small>Credits to <a href="http://www.paper-toy.fr/baby-robot-friend-de-drew-tetz/" target="_blank">Drew Tetz</a> for the picture</small> <br />
<small>Credits to <a href="https://twitter.com/laurapaschoal" target="_blank">@laurapaschoal</a> for the name "Robinho"</small>

## Motivation

In 2016, during United States election, a lot of fake news websites were created,
and shared through social media, specially Facebook. They were so much, that
Fake News had
<a target="_blank" href="http://www.patheos.com/blogs/accordingtomatthew/2016/12/fake-news-stories-received-more-clicks-than-real-news-during-end-of-2016-election-season/">
more clicks than the real ones.
</a>

One of the most iconic cases were from a citzen from Macedonia who had
<a target="_blank" href="https://www.wired.com/2017/02/veles-macedonia-fake-news/">over 100 fake news websites</a>,
and earned thousands of dollars with advertising.

Most of those websites were pro-Trump, why? Was the macedonian a true Trump defender?
Not necessarily! But he noticed that Trump voters were more likely to believe
and propagate Fake News.

Now, in 2018, we will have elections in Brazil, and there are many pages out there
that do not bother to check the sources and can take advantage (some already are)
of the same strategy that benefited Donald Trump.

In addition, we also have lots of extremely biased posts from all sides and the
annoying click-baits.

The Fake News Detector is a small initiative to try to make some difference in the
fight against this problem, joining people's goodwill (Crowdsourcing) with
technology (Machine Learning)

## How to contribute

Just by downloading the extension and flagging the news you will already be
helping a lot! Both other users and in the development of Robinho.

But if you are a programmer or data scientist, the Fake News Detector is an open
source project that needs a lot of your help! All repositories are available at:
[https://github.com/fake-news-detector](https://github.com/fake-news-detector).

The technologies are also very exciting: we use Elm with WebExtensions for the
extension, Rust for the API and Python for Machine Learning. Not an expert?
Not a problem, after all the goal of the project is precisely to learn these
technologies while helping the world.

If you want to help, take a look at our [ROADMAP](https://github.com/fake-news-detector/fake-news-detector/blob/master/site/ROADMAP.md)
to understand where the project is going, also check out the
[issues on github](https://github.com/fake-news-detector).

If you are interested but have questions about how you can help, send me a tweet,
[@_rchaves_](https://twitter.com/_rchaves_).

And follow our profile on twitter for news about Fake News and updates about the project:
[@fndetector](https://twitter.com/fndetector).

"""
