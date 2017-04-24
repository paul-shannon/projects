var webpack = require("webpack");
module.exports = {
    entry: ['./src/index.js'],
    output: {
        path: './dist',
        filename: 'bundle.js',
        libraryTarget: 'amd'
        },
    module: {loaders: [{test: /\.css$/, loader: "style-loader!css-loader"}]},
    plugins: [
        new webpack.ProvidePlugin({
           $: "jquery",
           jQuery: "jquery"
        })
    ],

    resolve: {
        alias: {
         'igv'       :   'http://igv.org/web/release/1.0.6/igv-1.0.6'
        }
    }

}
