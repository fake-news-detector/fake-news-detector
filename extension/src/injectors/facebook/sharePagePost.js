import { isPage } from "./pagePost";

// ex: https://www.facebook.com/permalink.php?story_fbid=1452192804872711&id=100002460165071
export const getSharePagePost = userStory => {
  if (!isPage(userStory)) return null;

  const content = userStory.querySelector(".userContent + div p");
  const link = getLinkFromTimestamp(userStory);
  const elem = userStory.querySelector(".userContent + div");

  if (!content || !link || !elem) return null;
  if (!elem.querySelector("img") || !content.textContent.trim()) return null;

  return {
    elem: elem,
    title: content.textContent,
    url: link.href
  };
};

const getLinkFromTimestamp = userStory => {
  const timestamps = userStory.querySelectorAll(".timestampContent");
  const timestamp = timestamps[timestamps.length - 1];
  if (!timestamp) return null;
  return timestamp.parentNode.parentNode;
};
