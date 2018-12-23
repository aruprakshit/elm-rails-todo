const path = require('path');

module.exports = {
  entry: {
    app: './src/js/index.js'
  },
  watch: true,
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, 'public')
  }
};
