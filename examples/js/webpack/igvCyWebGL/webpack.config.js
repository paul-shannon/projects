var webpack = require("webpack");
module.exports = {
    entry: ['./src/index.js'],
    output: {
        path: './dist',
        filename: 'bundle.js'
        },
    plugins: [
        new webpack.ProvidePlugin({
           $: "jquery",
           jQuery: "jquery"
        })
    ]
}
