module.exports = {
  stripPrefix: "build/",
  staticFileGlobs: ["build/*.{html,js,css}", "build/*.js", "build/static/**/*"],
  runtimeCaching: [],
  dontCacheBustUrlsMatching: /\.js/,
  swFilePath: "build/service-worker.js"
};
