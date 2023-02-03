process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const environment = require('./environment');

// hot reloads non webpack files UNCOMMENT FOR REGULAR RELOADING OF NON JAVASCRIPT PACK HOT RELOADING (NOT USING THIS FIXES COMPILING... FOREVER ISSUE IN REACT OR OTHER LIBRARY)
const chokidar = require('chokidar');
environment.config.devServer.before = (app, server) => {
  chokidar
    .watch([
      'config/locales/*.yml',
      'app/views/**/*.html.erb',
      'app/assets/**/*.css',
      'app/assets/**/*.js',
    ])
    .on('change', () => server.sockWrite(server.sockets, 'content-changed'));
};

module.exports = environment.toWebpackConfig();
