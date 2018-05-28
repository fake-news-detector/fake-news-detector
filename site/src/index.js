import App from "./TwitterGraph.elm";
import uuidv4 from "uuid/v4";

const path = window.location.pathname;
const browerLanguages = navigator.languages || ["en"];

const uuid = localStorage.getItem("uuid") || uuidv4();
localStorage.setItem("uuid", uuid);

// TODO: move this language logic to Elm
const languages = browerLanguages
  .map(language => language.substr(0, 2))
  .reverse();
const isPortuguese = languages.indexOf("pt") >= 0;
const isSpanish =
  !isPortuguese && languages.lastIndexOf("es") > languages.lastIndexOf("en");

let language = isPortuguese ? "pt" : isSpanish ? "es" : "en";
if (path === "/") {
  window.history.pushState(null, "", "/" + language);
} else {
  language = path.replace("/", "");
}

const rootNode = document.getElementById("app");
rootNode.innerHTML = "";

window.resizeIframe = elem => {
  elem.style.height = elem.contentWindow.document.body.scrollHeight + "px";
};

// App.Main.embed(rootNode, { languages: [language], uuid });
App.TwitterGraph.embed(rootNode);

if (!process.env.DEBUG && "serviceWorker" in navigator) {
  navigator.serviceWorker.register("/service-worker.js");
}
