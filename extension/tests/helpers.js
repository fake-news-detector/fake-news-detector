import fs from "fs";

export const loadFixture = path =>
  fs.readFileSync(__dirname + `/fixtures/${path}.html`);

export const userStoryFromFixture = path => {
  document.body.innerHTML = loadFixture(`facebook/${path}`);
  return document.querySelector(".userContentWrapper");
};

export const tweetFromFixture = path => {
  document.body.innerHTML = loadFixture(`twitter/${path}`);
  return document.querySelector(".tweet");
};
