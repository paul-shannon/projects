var path = require('path');
const webpack = require('webpack'); //to access built-in plugins

module.exports = {
  entry: './entry.js',
  plugins: [
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
      cytoscape: "cytoscape"
      })],
  module: {
    rules:[{
       test: /\.css$/,
       use: [ 'style-loader', 'css-loader' ]
       }]
    },
  output: {
   path: path.resolve(__dirname, 'dist'),
   filename: 'bundle.js'
   },
};
