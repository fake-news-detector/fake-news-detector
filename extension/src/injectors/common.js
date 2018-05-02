const injectExtension = (elementsToBeInjected, onInject) => () =>
  elementsToBeInjected()
    .filter(a => a)
    .forEach(onInject);

let injectTimeout;
const injectOnFeedRefresh = (observerQuery, injector) => {
  const observer = new MutationObserver(function(mutations) {
    clearTimeout(injectTimeout);
    injectTimeout = setTimeout(injector, 100);
  });

  observer.observe(document.querySelector(observerQuery), {
    subtree: true,
    childList: true
  });
};

export const injectOnChange = (
  observerQuery,
  elementsToBeInjected,
  onInject
) => {
  const injector = injectExtension(elementsToBeInjected, onInject);

  setInterval(injector, 5000);
  injectOnFeedRefresh(observerQuery, injector);
  injector();
};
