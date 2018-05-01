export const getExternalLinkStory = userStory => {
  const links = [...userStory.querySelectorAll("a[href]")];
  const elem = links.find(getExternalUrl);
  if (!elem) return null;

  const textLink = links.find(getExternalUrl);
  if (!textLink) return null;

  return {
    elem: userStory.querySelector(".scaledImageFitWidth").parentNode.parentNode
      .parentNode,
    title: getStoryTitle(textLink),
    url: getExternalUrl(textLink)
  };
};

export const getExternalUrl = a => {
  if (a.dataset.appname || a.text || !a.className) return null;

  if (!a.href.match(/facebook\.com/) && a.href.match(/http/)) {
    return a.href;
  }
  const matches = a.href.match(/facebook\.com\/l.php\?u=(.*?)&/);
  if (matches) {
    return decodeURIComponent(matches[1]);
  }

  return null;
};

const getStoryTitle = a => a.parentNode.querySelector("a").textContent;
