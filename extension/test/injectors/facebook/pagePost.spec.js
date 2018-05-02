import { getPagePost } from "../../../src/injectors/facebook/pagePost";
import { userStoryFromFixture } from "../../helpers";

describe("Page Post", () => {
  let userStory;

  describe("page post", () => {
    beforeAll(() => {
      userStory = userStoryFromFixture("postFromPage");
    });

    test("gets the post description as title", () => {
      expect(getPagePost(userStory).title).toBe(
        "A Natura, dentre outras bizarrices, anuncia no Fantástico. Boicote neles!"
      );
    });

    test("gets the url from the original post", () => {
      expect(getPagePost(userStory).url).toBe(
        "/mblivre/photos/a.204296283027856.1073741829.204223673035117/704540646336748/?type=3"
      );
    });

    test("gets the div where the image content lives to render the detector", () => {
      expect(getPagePost(userStory).elem).toBe(
        document.querySelector("#this-one")
      );
    });
  });

  describe("profile post", () => {
    test("returns null because it is not a page post", () => {
      userStory = userStoryFromFixture("postFromProfile");
      expect(getPagePost(userStory)).toBe(null);
    });
  });
});
