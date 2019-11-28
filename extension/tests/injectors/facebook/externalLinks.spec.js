import {
  getExternalLinkStory,
  getExternalUrl
} from "../../../src/injectors/facebook/externalLinks";
import { userStoryFromFixture } from "../../helpers";

describe("Facebook External Links", () => {
  let userStory;

  describe("post with external links", () => {
    beforeAll(() => {
      userStory = userStoryFromFixture("postWithExternalLink");
    });

    test("gets the link title", () => {
      expect(getExternalLinkStory(userStory).title).toBe(
        "O dia em que Adriane Galisteu e Faustão estrelaram uma videocassetada ao vivo na TV"
      );
    });

    test("gets the external url", () => {
      expect(getExternalLinkStory(userStory).url).toBe(
        "http://huffp.st/2ynax3o"
      );
    });

    test("gets the div where the image content lives to render the detector", () => {
      expect(getExternalLinkStory(userStory).elem).toBe(
        document.querySelector("#this-one")
      );
    });
  });

  describe("post with internal links", () => {
    test("returns null because it is not an external link", () => {
      userStory = userStoryFromFixture("sharedPostFromPage");
      expect(getExternalLinkStory(userStory)).toBe(null);
    });
  });

  describe("getExternalUrl", () => {
    const createA = href => ({
      href: href,
      dataset: {},
      className: "foo"
    });

    test("returns the url if it is not a facebook one", () => {
      const a = createA("http://www.pudim.com.br");
      expect(getExternalUrl(a)).toBe(a.href);
    });

    test("extracts external link out of facebook's wrapper", () => {
      let a = createA(
        "https://l.facebook.com/l.php?u=https%3A%2F%2Ftecnoblog.net%2F224816%2Frumor-preco-iphone-8-plus-brasil%2F&h=ATPUoAPZS7_4ovGV7USWGOosDT_5NhE1bYLryDQKKfgt03fwcna46IbFp1CItisdDKszIIV5JfaDe9oifkpB2kdUpRQLF9AsnoXCjD9POpKrKYmrAb6cFjNtRbzZryhYOs7aygRS_bI-VUu8IfF801fPixhsajw9w7qFjSZjdjTQfUohtPKwS8Q-zor81wKNdqbWHUSLZcwCFrf8TDUELQdeHuwxJngRiWTz1d1W3dBYQqHA_Wcud__TVhpfjzAS2pBeYlbf4vXyH2HdfcQ6k0YrC2v4aBb1HWwDGw"
      );

      expect(getExternalUrl(a)).toBe(
        "https://tecnoblog.net/224816/rumor-preco-iphone-8-plus-brasil/"
      );
    });

    test("returns null for facebook urls", () => {
      const a = createA("http://facebook.com/pudim");
      expect(getExternalUrl(a)).toBe(null);
    });

    test("returns null for relative urls", () => {
      const a = createA("#");
      expect(getExternalUrl(a)).toBe(null);
    });
  });

  describe("post from twitter", () => {
    beforeAll(() => {
      userStory = userStoryFromFixture("postFromTwitter");
    });

    test("gets the link title", () => {
      expect(getExternalLinkStory(userStory).title).toBe("rai on Twitter");
    });

    test("gets the external url", () => {
      expect(getExternalLinkStory(userStory).url).toBe(
        "https://twitter.com/raissaalmeida/status/931910705409937409/photo/1?utm_source=fb&utm_medium=fb&utm_campaign=gomex&utm_content=932300495623991296"
      );
    });

    test("gets the div where the image content lives to render the detector", () => {
      expect(getExternalLinkStory(userStory).elem).toBe(
        document.querySelector("#this-one")
      );
    });
  });
});
