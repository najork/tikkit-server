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

var logDir = __dirname + '/log'
var dbDir = __dirname + '/db/app-data.db'

var app = express();
var db = new sqlite3.Database(dbDir);
var LocalStrategy = require('passport-local').Strategy;

// Set port
var port = process.env.PORT || 8080;

// Length in bytes of password salt
var saltBytes = 16;

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
fs.existsSync(logDir) || fs.mkdirSync(logDir)

// Create rotating log stream
var accessLogStream = FileStreamRotator.getStream({
  filename: logDir + '/access-%DATE%.log',
  frequency: 'daily',
  verbose: false
})

// Enable sqlite foreign key constraint enforcement
// https://www.sqlite.org/foreignkeys.html#fk_enable
db.run("PRAGMA foreign_keys = ON");

// Set up morgan
app.use(morgan('combined', {stream: accessLogStream}))

// Send connection close header if server is shutting down
app.use(function(req, res, next) {
  if(!shuttingDown) return next();
  res.setHeader('Connection', 'close');
  res.send(503, { message: 'Server is restarting'});
});

// Login
app.post('/login', passport.authenticate('local', {
  successRedirect: '/good-login',
  failureRedirect: '/bad-login'
}));

// Create user
router.post('/users/create', function(req, res) {
  createUser(req.query.username, req.query.password, function(userId) {
    res.json({ user_id: userId });
  });
});

// TODO: Add API auth

// TODO: Create school endpoint

// Get school from school id
router.get('/schools/:schoolId', function(req, res) {
  deserializeSchool(req.params.schoolId, function(row) {
    res.json(row);
  });
});

// List all schools
router.get('/lists/schools', function(req, res) {
  getSchools(function(rows) {
    res.json(rows);
  });
});

// TODO: Create game endpoint

// Get game from game id
router.get('/games/:gameId', function(req, res) {
  deserializeGame(req.params.gameId, function(row) {
    res.json(row);
  });
});

// Get all games for school from school id
router.get('/lists/schools/:schoolId/games', function(req, res) {
  getGames(req.params.schoolId, function(rows) {
    res.json(rows);
  });
});

// Get ticket from ticket id
router.get('/tickets/:ticketId', function(req, res) {
  deserializeTicket(req.params.ticketId, function(row) {
    res.json(row);
  });
});

// Get all tickets for game from game id
router.get('/lists/games/:gameId/tickets', function(req, res) {
  getTickets(req.params.gameId, function(rows) {
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

  // Checks: game exists, seller exists
  // Ticket price expected in cents
  var sold = false;
  createTicket(req.params.gameId, req.query.seller_id, req.query.section, req.query.row, req.query.seat, req.query.price, sold, function(ticketId) {
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

  setSold(req.params.ticketId, req.query.sold, function(changes) {
    res.sendStatus(204);  // 204 No Content
  });
});

// All routes prefixed with /api
app.use('/api', router);

var server = app.listen(port);
console.log('Server running on port ' + port);

function hashPassword(password, salt) {
  var hash = crypto.createHash('sha256');
  hash.update(password);
  hash.update(salt);
  return hash.digest('hex');
}

// Checks: username is unique, username ends with @umich.edu, password is at least 8 characters
function createUser(username, password, callback) {
  var salt = crypto.randomBytes(saltBytes);
  db.run('INSERT INTO Users(username, password, salt) VALUES (?, ?, ?)', username, hashPassword(password, salt), salt, function(err, row) {
    if (err) return callback(err);
    return callback(this.lastID);
  });
  // TODO: add error handling
}

// TODO: Create general functions to perform database actions

function getSchool(schoolName, callback) {
  db.get('SELECT name, school_id FROM Schools WHERE name = ?', schoolName, function(err, row) {
    if (err) return callback(err);
    if (!row) return callback(null, false);
    return callback(row);
  });
}

function serializeSchool(school, done) {
  return done(null, school.school_id);
}

function deserializeSchool(id, callback) {
  db.get('SELECT school_id, name FROM Schools WHERE school_id = ?', id, function(err, row) {
    if (err) return callback(err);
    if (!row) return callback(null, false);
    return callback(row);
  });
}

function serializeGame(game, done) {
  return done(null, game.game_id);
}

function deserializeGame(id, callback) {
  db.get('SELECT game_id, home_team_id, away_team_id, date FROM Games WHERE game_id = ?', id, function(err, row) {
    if (err) return callback(err);
    if (!row) return callback(null, false);
    return callback(row);
  });
}

function serializeTicket(ticket, done) {
  return done(null, ticket.ticket_id);
}

function deserializeTicket(id, callback) {
  db.get('SELECT ticket_id, game_id, seller_id, section, row, seat, price, sold FROM Tickets WHERE ticket_id = ?', id, function(err, row) {
    if (err) return callback(err);
    if (!row) return callback(null, false);
    return callback(row);
  });
}

function getSchools(callback) {
  db.all('SELECT * FROM Schools', function(err, rows) {
    if (err) return callback(err);
    if (!rows.length) return callback(null, false);
    return callback(rows);
  });
}

function getGames(schoolId, callback) {
  db.all('SELECT * FROM Games WHERE home_team_id = ? OR away_team_id = ?', schoolId, schoolId, function(err, rows) {
    if (err) return callback(err);
    if (!rows.length) return callback(null, false);
    return callback(rows);
  });
}

function getTickets(gameId, callback) {
  db.all('SELECT * FROM Tickets WHERE game_id = ?', gameId, function(err, rows) {
    if (err) return callback(err);
    if (!rows.length) return callback(null, false);
    return callback(rows);
  });
}

// Checks: game exists, seller exists
function createTicket(gameId, sellerId, section, row, seat, price, sold, callback) {
  db.run('INSERT INTO Tickets(game_id, seller_id, section, row, seat, price, sold) VALUES (?, ?, ?, ?, ?, ?, ?)', gameId, sellerId, section, row, seat, price, sold, function(err, row) {
    if (err) return callback(err);
    return callback(this.lastID);
  });
}

// Check: ticket id exists
function setSold(ticketId, sold, callback) {
  // Convert boolean to integer representation for sqlite
  var soldInt = (sold == 'true' || sold == 1) ? 1 : 0;
  db.run('UPDATE Tickets SET sold = ? WHERE ticket_id = ?', sold, ticketId, function(err, row) {
    if (err) return callback(err);
    return callback(this.changes);
  });
}

passport.use(new LocalStrategy(function(username, password, done) {
  db.get('SELECT salt FROM Users WHERE username = ?', username, function(err, row) {
    if (!row) return done(null, false);
    var hash = hashPassword(password, row.salt);
    db.get('SELECT username, user_id FROM Users WHERE username = ? AND password = ?', username, hash, function(err, row) {
      if (!row) return done(null, false);
      return done(null, row);
    });
  });
}));

passport.serializeUser(function(user, done) {
  return done(null, user.user_id);
});

passport.deserializeUser(function(id, done) {
  db.get('SELECT user_id, username FROM Users WHERE user_id = ?', id, function(err, row) {
    if (!row) return done(null, false);
    return done(null, row);
  });
});

// Server shutdown
function shutdown() {
  console.log('Initiating shutdown');
  shuttingDown = true;

  // Close db connections, other chores, etc
  server.close(function() {
    db.close();
    console.log('Closed out remaining connections');
    process.exit();
  });

  var timeoutMillis = 30 * 1000;
  setTimeout(function() {
    console.error('Could not close connections in time, forcing shutdown');
    process.exit(1);
  }, timeoutMillis);
}
