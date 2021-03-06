/**
 * @author Max Najork
 */

// TODO: Cleanup

const bodyParser = require('body-parser');
const express = require('express');
const expressValidator = require('express-validator');
const fileStreamRotator = require('file-stream-rotator');
const fs = require('fs');
const morgan = require('morgan');
const path = require('path');

const prefs = require('./js/prefs');
const api = require('./js/api');

const app = express();

const logDir = prefs.logDir;
const port = prefs.port;

// Server shutdown state
var shuttingDown = false;

// Server shutdown on signal interrupt or termination
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

// Configure express
app.get('env');

// Send connection close header if server is shutting down
app.use(function(req, res, next) {
  if(!shuttingDown) return next();
  res.setHeader('Connection', 'close');
  res.status(503).send({ message: 'Server is restarting'});
});

// Set up body-parser
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Set up query validation
app.use(expressValidator());

// Ensure log directory exists
fs.existsSync(logDir) || fs.mkdirSync(logDir);

// Create rotating log stream
const accessLogStream = fileStreamRotator.getStream({
  filename: path.join(logDir, 'server-access-%DATE%.log'),
  frequency: 'daily',
  verbose: false,
  date_format: 'YYYYMMDD'
});

// Set up morgan
app.use(morgan('short', {stream: accessLogStream}));

// Route API calls
api(app);

// Start server
const server = app.listen(port);
console.log('Server running on port ' + port);

// Server shutdown
function shutdown() {
  console.log('Initiating shutdown');
  shuttingDown = true;

  // Close connections, other chores, etc
  server.close(function() {
    console.log('Closed out remaining connections');
    process.exit();
  });

  const timeoutMillis = 30 * 1000;
  setTimeout(function() {
    console.error('Could not close connections in time, forcing shutdown');
    process.exit(1);
  }, timeoutMillis);
}
