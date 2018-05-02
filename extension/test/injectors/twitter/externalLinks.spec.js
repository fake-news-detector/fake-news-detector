import { getExternalLinkTweet } from "../../../src/injectors/twitter/externalLinks";
import { tweetFromFixture, loadFixture } from "../../helpers";

describe("Twitter External Links", () => {
  let userStory;

  describe("tweet with external links", () => {
    beforeAll(() => {
      userStory = tweetFromFixture("tweetWithEmbededLink");
      let iframeDocument = document.querySelector("iframe").contentWindow
        .document;
      iframeDocument.open();
      iframeDocument.write(loadFixture("twitter/embededLinkIframe"));
      iframeDocument.close();
    });

    test("gets the link title", () => {
      expect(getExternalLinkTweet(userStory).title).toBe(
        "Finland Has Figured Out How to Combat Fake News. Full Frontal Thinks The U.S. Can Follow Suit."
      );
    });

    test("gets the url from the original post", () => {
      expect(getExternalLinkTweet(userStory).url).toBe(
        "http://www.slate.com/blogs/browbeat/2017/10/12/full_frontal_investigates_finland_s_anti_fake_news_efforts_video.html?wpsrc=sh_all_dt_tw_bot"
      );
    });

    test("gets the div where the image content lives to render the detector", () => {
      expect(getExternalLinkTweet(userStory).elem).toBe(
        document.querySelector("iframe").contentDocument.body
      );
    });
  });
});
