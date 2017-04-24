var path = require('path');
module.exports = {
  entry: './entry.js',
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


var path = require('path');

module.exports = {
  entry: './entry.js',
    module: {
        rules:[
            {
             test: /\.css$/,
             use: [ 'style-loader', 'css-loader' ]
            }
            ]
    },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
    },
};
