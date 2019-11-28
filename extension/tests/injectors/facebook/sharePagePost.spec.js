import { getSharePagePost } from "../../../src/injectors/facebook/sharePagePost";
import { userStoryFromFixture } from "../../helpers";

describe("Share Page Post", () => {
  let userStory;

  describe("share page post", () => {
    beforeAll(() => {
      userStory = userStoryFromFixture("sharedPostFromPage");
    });

    test("gets the post description as title", () => {
      expect(getSharePagePost(userStory).title).toBe(
        "Um escândalo sem precedentes.  Marcos Feliciano e combina com Jair Bolsonaro como ajudar Eduardo Cunha a entrar com pedido de impeachment sem correr risco de perderem o processo. No mesmo áudio Feliciano,admite que estaria com um grupo, blindando e salvando a pele de Eduardo Cunha, para que ele ajudasse a derrubar Dilma Rousseff."
      );
    });

    test("gets the url from the original post", () => {
      expect(getSharePagePost(userStory).url).toBe(
        "/VerdadeSemManipulacao/videos/479313152193503/"
      );
    });

    test("gets the div where the image content lives to render the detector", () => {
      expect(getSharePagePost(userStory).elem).toBe(
        document.querySelector("#this-one")
      );
    });
  });

  describe("share profile post", () => {
    test("returns null because it is not a page post", () => {
      userStory = userStoryFromFixture("sharedPostFromProfile");
      expect(getSharePagePost(userStory)).toBe(null);
    });
  });
});
