export const getExternalLinkTweet = tweet => {
  const link = tweet.querySelector("a[data-expanded-url]");
  if (!link) return null;

  const iframe = tweet.querySelector("iframe");
  if (!iframe) return null;

  const title = iframe.contentDocument.body.querySelector("h2");
  if (!title) return null;

  return {
    elem: iframe.contentDocument.body,
    title: title.textContent,
    url: link.dataset.expandedUrl
  };
};

const getStoryTitle = a => a.parentNode.querySelector("a").textContent;
