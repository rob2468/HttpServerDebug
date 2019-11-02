const HtmlWebpackPlugin = require('html-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const path = require('path');

const destRootPath = path.resolve(__dirname, '../Resources/HttpServerDebug.bundle/web');
module.exports = {
  entry: {
    index: './src/page/index/index.js',
    file_explorer: './src/page/file_explorer/file_explorer.js',
  },
  output: {
    filename: '[name].js',
    path: destRootPath,
  },
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          { loader: 'style-loader' },
          { loader: 'css-loader' },
        ],
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      filename: 'index.html',
      template: './src/page/index/index.html',
      chunks: [ 'index' ],
      hash: true,
    }),
    new HtmlWebpackPlugin({
      filename: 'file_explorer.html',
      template: './src/page/file_explorer/file_explorer.html',
      chunks: [ 'file_explorer' ],
      hash: true,
    }),
    new CopyWebpackPlugin([
      { from: './src/common/locals/enus.json', to: path.resolve(destRootPath, 'enus.json') },
      { from: './src/common/locals/zhcn.json', to: path.resolve(destRootPath, 'zhcn.json') },
    ]),
  ],
  mode: 'production',
};
