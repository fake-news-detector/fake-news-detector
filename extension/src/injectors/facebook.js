import { injectOnChange } from "./common";
import { getExternalLinkStory } from "./facebook/externalLinks.js";
import { getPagePost } from "./facebook/pagePost.js";
import { getSharePagePost } from "./facebook/sharePagePost.js";

const markChecked = userStory => {
  userStory.classList.add("fnd-checked");
  return userStory;
};

export const notAdvertisement = userStory =>
  !!userStory.querySelector(".timestampContent");

export const notNested = userStory =>
  !userStory.querySelector(".userContentWrapper");

const findElementToRenderDetector = userStory =>
  getExternalLinkStory(userStory) ||
  getPagePost(userStory) ||
  getSharePagePost(userStory);

const elementsToBeInjected = () =>
  [...document.querySelectorAll(".userContentWrapper:not(.fnd-checked)")]
    .map(markChecked)
    .filter(notAdvertisement)
    .filter(notNested)
    .map(findElementToRenderDetector);

export default onInject => {
  if (!document.location.href.match("facebook.com")) return false;

  injectOnChange("#content_container", elementsToBeInjected, onInject);
};
