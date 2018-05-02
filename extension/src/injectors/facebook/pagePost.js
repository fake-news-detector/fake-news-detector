export const getPagePost = userStory => {
  if (!isPage(userStory)) return null;

  const content = userStory.querySelector(".userContent p");
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

export const isPage = userStory => {
  const pageUrlsMatch = userStory.innerHTML.match(/page\.php/g);
  return pageUrlsMatch && pageUrlsMatch.length >= 2;
};

export const getLinkFromTimestamp = userStory => {
  const timestamp = userStory.querySelector(".timestampContent");
  if (!timestamp) return null;
  return timestamp.parentNode.parentNode;
};
