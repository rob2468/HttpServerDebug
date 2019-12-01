const HtmlWebpackPlugin = require('html-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const path = require('path');

const destRootPath = path.resolve(__dirname, '../Resources/HttpServerDebug.bundle/web');
module.exports = {
  entry: {
    index: './src/page/index/index.js',
    file_explorer: './src/page/file_explorer/file_explorer.js',
    database_inspect: './src/page/database_inspect/database_inspect.js',
    view_debug: './src/page/view_debug/view_debug.js',
    send_info: './src/page/send_info/send_info.js',
    console_log: './src/page/console_log/console_log.js',
    web_debug: './src/page/web_debug/web_debug.js',
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
      {
        test: /\.(png|jpg|gif|svg)$/,
        use: [
          { loader: 'file-loader' },
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
    new HtmlWebpackPlugin({
      filename: 'database_inspect.html',
      template: './src/page/database_inspect/database_inspect.html',
      chunks: [ 'database_inspect' ],
      hash: true,
    }),
    new HtmlWebpackPlugin({
      filename: 'view_debug.html',
      template: './src/page/view_debug/view_debug.html',
      chunks: [ 'view_debug' ],
      hash: true,
    }),
    new HtmlWebpackPlugin({
      filename: 'send_info.html',
      template: './src/page/send_info/send_info.html',
      chunks: [ 'send_info' ],
      hash: true,
    }),
    new HtmlWebpackPlugin({
      filename: 'console_log.html',
      template: './src/page/console_log/console_log.html',
      chunks: [ 'console_log' ],
      hash: true,
    }),
    new HtmlWebpackPlugin({
      filename: 'web_debug.html',
      template: './src/page/web_debug/web_debug.html',
      chunks: [ 'web_debug' ],
      hash: true,
    }),
    new CopyWebpackPlugin([
      { from: './src/common/image/favicon.ico', to: path.resolve(destRootPath, 'favicon.ico') },
      { from: './src/common/locals/enus.json', to: path.resolve(destRootPath, 'enus.json') },
      { from: './src/common/locals/zhcn.json', to: path.resolve(destRootPath, 'zhcn.json') },
      { from: './node_modules/chrome-devtools-frontend/front_end', to: path.resolve(destRootPath, 'chrome-devtools-frontend/front_end/') },
    ]),
  ],
  mode: 'development',
  watch: true,
};
