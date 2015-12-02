// server.js

// TODO: Cleanup

const FileStreamRotator = require('file-stream-rotator')

const express = require('express');
const bodyParser = require('body-parser');
const expressValidator = require('express-validator');
const fs = require('fs');
const crypto = require('crypto');
const morgan = require('morgan');
const passport = require('passport');
const sqlite3 = require('sqlite3').verbose();
const util = require('util');

const auth = require('./js/auth');
const db = require('./js/db');
const prefs = require('./js/prefs');
const utils = require('./js/utils');

const app = express();

const logDir = prefs.logDir;
const port = prefs.port;

// Server shutdown state
var shuttingDown = false;

// Get instance of express Router
const router = express.Router();

// Server shutdown on signal interrupt or termination
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

// Configure express
app.get('env');

// Set up query validation
app.use(bodyParser.urlencoded({ extended: false }));
app.use(expressValidator());

// Set up passport
app.use(passport.initialize());
app.use(passport.session());

// Ensure log directory exists
fs.existsSync(logDir) || fs.mkdirSync(logDir);

// Create rotating log stream
const accessLogStream = FileStreamRotator.getStream({
  filename: logDir + '/access-%DATE%.log',
  frequency: 'daily',
  verbose: false
});

// Set up morgan
app.use(morgan('combined', {stream: accessLogStream}));

// Send connection close header if server is shutting down
app.use(function(req, res, next) {
  if(!shuttingDown) return next();
  res.setHeader('Connection', 'close');
  res.status(503).send({ message: 'Server is restarting'});
});

// Login
app.post('/login', passport.authenticate('local', { failureRedirect: '/login' }), function(req, res) {
  db.users.findByUsername(req.query.username, function(err, row) {
    const accessToken = auth.createAccessToken(row.user_id);
    res.json(accessToken);
  });
});

// Create user
app.post('/create', function(req, res) {
  // Checks: username is unique, username ends with @umich.edu, password is at least 8 characters
  db.users.create(req.query.username, req.query.password, function(err, userId) {
    if (err) {
      // TODO: What's the correct response code?
      res.status(400).send(err);
      return;
    }

    // Return id of new user
    res.json({ user_id: userId });
  });
});

// TODO: Create school endpoint
// TODO: Determine return value and response status for query with non-existant id

// Use bearer auth to protect all /api calls
router.use(passport.authenticate('bearer', { session: false }));

// Get school from school id
router.get('/schools/:schoolId', function(req, res) {
  db.schools.find(req.params.schoolId, function(err, row) {
    res.json(row);
  });
});

// List all schools
router.get('/lists/schools', function(req, res) {
  db.schools.all(function(err, rows) {
    res.json(rows);
  });
});

// TODO: Create game endpoint

// Get game from game id
router.get('/games/:gameId', function(req, res) {
  db.games.find(req.params.gameId, function(err, row) {
    res.json(row);
  });
});

// Get all games for school from school id
router.get('/lists/schools/:schoolId/games', function(req, res) {
  db.games.findBySchool(req.params.schoolId, function(err, rows) {
    res.json(rows);
  });
});

// Get ticket from ticket id
router.get('/tickets/:ticketId', function(req, res) {
  db.tickets.find(req.params.ticketId, function(err, row) {
    res.json(row);
  });
});

// Get all tickets for game from game id
router.get('/lists/games/:gameId/tickets', function(req, res) {
  db.tickets.findByGame(req.params.gameId, function(err, rows) {
    res.json(rows);
  });
});

// Checks: game exists, seller exists
// Create a new ticket
router.post('/games/:gameId/tickets/create', function(req, res) {
  // TODO: determine reasonable asserts, consider splitting notEmpty and isX asserts to give more descriptive error messages
  req.assert('section', 'Invalid section number').notEmpty().isInt({ min: 1 });
  req.assert('row', 'Invalid row number').notEmpty().isInt({ min: 1 });
  req.assert('seat', 'Invalid seat number').notEmpty().isInt({ min: 1 });
  req.assert('price', 'Invalid price').notEmpty().isInt({ min: 0 });

  const errors = req.validationErrors();
  if (errors) {
    res.status(400).send('Error: ' + util.inspect(errors));
    return;
  }

  // Checks: game exists, seller exists, identical ticket doesn't exist
  // TODO: Automatically get seller_id from logged-on user
  // Ticket price expected in cents
  var sold = false;
  db.tickets.create(req.params.gameId, req.query.seller_id, req.query.section, req.query.row, req.query.seat, req.query.price, sold, function(err, ticketId) {
    res.json({ ticket_id: ticketId });
  });
});

// Check: ticket_id exists
// Toggle sold status for ticket from ticket id
router.post('/tickets/:ticketId/sold', function(req, res) {
  req.assert('sold', 'Invalid sold status').notEmpty().isBoolean();

  const errors = req.validationErrors();
  if (errors) {
    res.status(400).send('Error: ' + util.inspect(errors));
    return;
  }

  db.tickets.setSold(req.params.ticketId, req.query.sold, function(err, changes) {
    // TODO: Check value of changes (if 0, then no rows updated)
    res.sendStatus(204);  // 204 No Content
  });
});

// All routes prefixed with /api
app.use('/api', router);

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
