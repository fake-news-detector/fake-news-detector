import { notNested, notAdvertisement } from "../../src/injectors/facebook";
import { userStoryFromFixture } from "../helpers";

describe("Facebook injector", () => {
  test("detects nested stories", () => {
    let userStory = userStoryFromFixture("nestedStory");
    expect(notNested(userStory)).toBe(false);

    userStory = userStoryFromFixture("postFromPage");
    expect(notNested(userStory)).toBe(true);
  });

  test("detects advertisement stories", () => {
    let userStory = userStoryFromFixture("advertisement");
    expect(notAdvertisement(userStory)).toBe(false);

    userStory = userStoryFromFixture("postFromPage");
    expect(notAdvertisement(userStory)).toBe(true);
  });
});
