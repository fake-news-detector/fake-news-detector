import browser from "webextension-polyfill";

const extensionPopup = document.getElementById("fnd-extension-popup");

export const isExtensionPopup = !!extensionPopup;

const injectTab = (onInject, { url, title }) =>
  onInject({ elem: extensionPopup, url, title });

export const extensionPopupInjector = onInject => {
  if (isExtensionPopup) {
    const getActiveTab = browser.tabs.query({
      active: true,
      currentWindow: true
    });

    getActiveTab.then(tabs => {
      const tab = tabs[0];
      if (tab) injectTab(onInject, tab);
    });
  }
};
