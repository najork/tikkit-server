// server.js

// TODO: Cleanup

var FileStreamRotator = require('file-stream-rotator')

var express = require('express');
var bodyParser = require('body-parser');
var expressValidator = require('express-validator');
var fs = require('fs');
var crypto = require('crypto');
var morgan = require('morgan');
var passport = require('passport');
var sqlite3 = require('sqlite3').verbose();
var util = require('util');
var utils = require('./utils');
var auth = require('./auth');

var logDir = './log'

var app = express();
var db = require('./db');
var LocalStrategy = require('passport-local').Strategy;

// Set port
var port = process.env.PORT || 8080;

// Server shutdown state
var shuttingDown = false;

// Get instance of express Router
var router = express.Router();

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
var accessLogStream = FileStreamRotator.getStream({
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

var config = JSON.parse(fs.readFileSync('config.json', 'utf8'));

// Login
app.post('/login', passport.authenticate('local', { failureRedirect: '/login' }), function(req, res) {
  db.users.findByUsername(req.query.username, function(err, row) {
    var accessToken = auth.createAccessToken(row.user_id);
    res.json(accessToken);
  });
});

// Create user
router.post('/users/create', function(req, res) {
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
// TODO: Which API endpoints should be protected by token auth?

// Get school from school id
router.get('/schools/:schoolId', passport.authenticate('bearer', { session: false }), function(req, res) {
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

  var errors = req.validationErrors();
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

  var errors = req.validationErrors();
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

var server = app.listen(port);
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

  var timeoutMillis = 30 * 1000;
  setTimeout(function() {
    console.error('Could not close connections in time, forcing shutdown');
    process.exit(1);
  }, timeoutMillis);
}
