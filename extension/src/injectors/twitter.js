import { injectOnChange } from "./common";
import { getExternalLinkTweet } from "./twitter/externalLinks";

const elementsToBeInjected = () =>
  [...document.querySelectorAll(".tweet")].map(getExternalLinkTweet);

export default onInject => {
  if (!document.location.href.match("twitter.com")) return false;

  injectOnChange("#timeline", elementsToBeInjected, onInject);
};
