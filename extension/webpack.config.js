const UglifyJSPlugin = require("uglifyjs-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const path = require("path");

const prodPlugins =
  process.env.NODE_ENV === "production" ? [new UglifyJSPlugin()] : [];

module.exports = {
  entry: "./src/index.js",
  output: {
    filename: "bundle.js",
    path: path.resolve(__dirname, "dist")
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: ["elm-webpack-loader"]
      }
    ]
  },
  plugins: [new CopyWebpackPlugin([{ from: "src/index.html" }])].concat(
    prodPlugins
  )
};
