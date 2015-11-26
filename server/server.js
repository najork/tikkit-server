// server.js

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

// Login
app.post('/login', passport.authenticate('local', {
  successRedirect: '/good-login',
  failureRedirect: '/bad-login'
}));

// Create user
router.post('/users/create', function(req, res) {
  db.users.createUser(req.query.username, req.query.password, function(userId) {
    res.json({ user_id: userId });
  });
});

// TODO: Add API auth

// TODO: Create school endpoint

// Get school from school id
router.get('/schools/:schoolId', function(req, res) {
  db.schools.deserializeSchool(req.params.schoolId, function(row) {
    res.json(row);
  });
});

// List all schools
router.get('/lists/schools', function(req, res) {
  db.schools.getSchools(function(rows) {
    res.json(rows);
  });
});

// TODO: Create game endpoint

// Get game from game id
router.get('/games/:gameId', function(req, res) {
  db.games.deserializeGame(req.params.gameId, function(row) {
    res.json(row);
  });
});

// Get all games for school from school id
router.get('/lists/schools/:schoolId/games', function(req, res) {
  db.games.getGames(req.params.schoolId, function(rows) {
    res.json(rows);
  });
});

// Get ticket from ticket id
router.get('/tickets/:ticketId', function(req, res) {
  db.tickets.deserializeTicket(req.params.ticketId, function(row) {
    res.json(row);
  });
});

// Get all tickets for game from game id
router.get('/lists/games/:gameId/tickets', function(req, res) {
  db.tickets.getTickets(req.params.gameId, function(rows) {
    res.json(rows);
  });
});

// Create a new ticket
router.post('/games/:gameId/tickets/create', function(req, res) {
  // TODO: determine reasonable asserts
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
  db.tickets.createTicket(req.params.gameId, req.query.seller_id, req.query.section, req.query.row, req.query.seat, req.query.price, sold, function(ticketId) {
    res.json({ ticket_id: ticketId });
  });
});

// Toggle sold status for ticket from ticket id
router.post('/tickets/:ticketId/sold', function(req, res) {
  req.assert('sold', 'Invalid sold status').notEmpty().isBoolean();

  var errors = req.validationErrors();
  if (errors) {
    res.status(400).send('Error: ' + util.inspect(errors));
    return;
  }

  db.tickets.setSold(req.params.ticketId, req.query.sold, function(changes) {
    res.sendStatus(204);  // 204 No Content
  });
});

// All routes prefixed with /api
app.use('/api', router);

var server = app.listen(port);
console.log('Server running on port ' + port);

require('./auth');

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
