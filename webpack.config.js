var ExtractTextPlugin = require("extract-text-webpack-plugin");
var webpack = require('webpack');

module.exports = {
  entry: ["./web/static/js/app.js", "./web/static/css/app.scss"],
  output: {
    path: "./priv/static",
    filename: "js/app.js"
  },
  resolve: {
    modulesDirectories: [
      __dirname + "/web/static/js",
      __dirname + "/node_modules"
    ],
    alias: {
      phoenix_html:
        __dirname + "/deps/phoenix_html/web/static/js/phoenix_html.js",
      phoenix:
        __dirname + "/deps/phoenix/web/static/js/phoenix.js"
    }
  },
  module: {
    loaders: [{
      test: /\.jsx?$/,
      loader: "babel",
      include: __dirname,
      query: {
        presets: ["es2015", "react"]
      }
    }, {
      test: /\.css$/,
      loader: ExtractTextPlugin.extract("style", "css")
    }, {
      test: /\.scss$/,
      loader: ExtractTextPlugin.extract("style", "css!sass")
    }]
  },
  plugins: [
    new ExtractTextPlugin("css/app.css"),
    new webpack.ProvidePlugin({
      $: "jquery"
    })
  ]
};
