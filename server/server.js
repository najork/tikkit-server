// server.js

var express = require('express');
var crypto = require('crypto');
var passport = require('passport');
var sqlite3 = require('sqlite3').verbose();

var app = express();
var db = new sqlite3.Database('db/app-data.db');
var LocalStrategy = require('passport-local').Strategy;

// Set port
var port = process.env.PORT || 8080;

// Length in bytes of password salt
var salt_bytes = 16;

// Server shutdown state
var shutting_down = false;

// Get instance of express Router
var router = express.Router();

// Server shutdown on signal interrupt or termination
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

// Configure express
app.get('env');

app.use(passport.initialize());
app.use(passport.session());

// Send connection close header if server is shutting down
app.use(function(req, res, next) {
    if(!shutting_down) return next();
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
    createUser(req.query.username, req.query.password, function(user_id) {
        res.json({ user_id: user_id });
    });
});

// TODO: Add API auth

// TODO: Create school endpoint

// Get school from school id
router.get('/schools/:id', function(req, res) {
    deserializeSchool(req.params.id, function(row) {
        res.json(row);
    });
});

// List all schools
router.get('/lists/schools', function(req, res) {
    getRows('SELECT * FROM Schools', function(rows) {
        var schools = [];
        rows.forEach(function(row) {
            var school = { school_id: row.school_id, name: row.name };
            schools.push(school);
        });
        res.json(schools);
    });
});

// TODO: Create game endpoint

// Get game from game id
router.get('/games/:id', function(req, res) {
    deserializeGame(req.params.id, function(row) {
        res.json(row);
    });
});

// Get all games for school from school id
router.get('/lists/schools/:id/games', function(req, res) {
    getGames(req.params.id, function(rows) {
        res.json(rows);
    });
});

// Get ticket from ticket id
router.get('/tickets/:id', function(req, res) {
    deserializeTicket(req.params.id, function(row) {
        res.json(row);
    });
});

// Get all tickets for game from game id
router.get('/lists/games/:id/tickets', function(req, res) {
    getTickets(req.params.id, function(rows) {
        res.json(rows);
    });
});

// Create a new ticket
router.post('/tickets/create', function(req, res) {
    var sold = false;
    // Ticket price expected in cents
    createTicket(req.query.game_id, req.query.seller_id, req.query.section, req.query.row, req.query.seat, req.query.price, sold, function(ticket_id) {
        res.json({ ticket_id: ticket_id });
    });
});

// Toggle sold status for ticket from ticket id
router.post('/tickets/:id/sold', function(req, res) {
    setSold(req.params.id, req.query.sold, function(changes) {
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

function createUser(username, password, callback) {
    var salt = crypto.randomBytes(salt_bytes);
    db.run('INSERT INTO Users(username, password, salt) VALUES (?, ?, ?)', username, hashPassword(password, salt), salt, function(err, row) {
        if (err) return callback(err);
        return callback(this.lastID);
    });
    // TODO: add error handling
}

// TODO: Create general functions to perform database actions

function getSchool(school_name, callback) {
    db.get('SELECT name, school_id FROM Schools WHERE name = ?', school_name, function(err, row) {
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

function getGames(school_id, callback) {
    db.all('SELECT * FROM Games WHERE home_team_id = ? OR away_team_id = ?', school_id, school_id, function(err, rows) {
        if (err) return callback(err);
        if (!rows.length) return callback(null, false);
        return callback(rows);
    });
}

function getTickets(game_id, callback) {
    db.all('SELECT * FROM Tickets WHERE game_id = ?', game_id, function(err, rows) {
        if (err) return callback(err);
        if (!rows.length) return callback(null, false);
        return callback(rows);
    });
}

function createTicket(game_id, seller_id, section, row, seat, price, sold, callback) {
    db.run('INSERT INTO Tickets(game_id, seller_id, section, row, seat, price, sold) VALUES (?, ?, ?, ?, ?, ?, ?)', game_id, seller_id, section, row, seat, price, sold, function(err, row) {
        if (err) return callback(err);
        return callback(this.lastID);
    });
}

function setSold(ticket_id, sold, callback) {
    db.run('UPDATE Tickets SET sold = ? WHERE ticket_id = ?', sold, ticket_id, function(err, row) {
        if (err) return callback(err);
        return callback(this.changes);
    });
}

// TODO: what should the callback look like (what parameters)? How do we do error handling?
function getRows(query, callback) {
    db.all(query, function(err, rows) {
        if (!rows.length) return callback(null, false);
        return callback(rows);
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
    shutting_down = true;

    // Close db connections, other chores, etc
    server.close(function() {
        db.close();
        console.log('Closed out remaining connections');
        process.exit();
    });

    var timeout_millis = 30 * 1000;
    setTimeout(function() {
        console.error('Could not close connections in time, forcing shutdown');
        process.exit(1);
    }, timeout_millis);
}
