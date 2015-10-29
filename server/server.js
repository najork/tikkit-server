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

// Get instance of express Router
var router = express.Router();

// Configure express
app.get('env');

app.use(passport.initialize());
app.use(passport.session());

// Create user endpoint
app.post('/create', function(req, res) {
    createUser(req.query.username, req.query.password);
    res.json({ message: 'Successfully created user!' });
});

// Login endpoint
app.post('/login', passport.authenticate('local', {
    successRedirect: '/good-login',
    failureRedirect: '/bad-login'
}));

// Test route (accessed at GET http://localhost:8080/api)
router.get('/', function(req, res) {
    res.json({ message: 'Welcome to our API!' });
});

router.get('/school/:id', function(req, res) {
    deserializeSchool(req.params.id, function(row) {
        res.json(row);
    });
});

// TODO: think about what the endpoint should be called
router.post('/school/list', function(req, res) {
    getRows('SELECT * FROM Schools', function(rows) {
        var schools = [];
        rows.forEach(function(row) {
            schools.push(row.name);
        });
        res.json(schools);
    });
});

router.get('/game/:id', function(req, res) {
    deserializeGame(req.params.id, function(row) {
        res.json(row);
    });
});

// TODO: think about what the endpoint should be called
router.post('/game/list', function(req, res) {
    getGames(req.query.school_id, function(rows) {
        var games = [];
        rows.forEach(function(row) {
            var game = { game_id: row.game_id, home_team: row.home_team_id, away_team: row.away_team_id, date: row.date };
            games.push(game);
            res.json(games);
        });
    });
});

router.get('/ticket/:id', function(req, res) {
    deserializeTicket(req.params.id, function(row) {
        res.json(row);
    });
});



// GET method route
app.get('/', function(req, res) {
  res.send('GET request to the homepage');
});

// POST method route
app.post('/', function(req, res) {
  res.send('POST request to the homepage');
});

// All routes prefixed with /api
app.use('/api', router);

var server = app.listen(port);
console.log('Server running on port ' + port);

// // sqlite testing
// db.serialize(function() {
//   db.run("CREATE TABLE Tickets(section INTEGER, row INTEGER, seat INTEGER, price REAL, seller_id TEXT, ticket_id INTEGER PRIMARY KEY)");

//   var stmt = db.prepare("INSERT INTO Tickets VALUES (?, ?, ?, ?, ?, ?)");
//   for (var i = 0; i < 10; i++) {
//       stmt.run(32, 36, i, 25.00, i);
//   }
//   stmt.finalize();

//   db.each("SELECT ticket_id AS id, section, row, seat, price, seller_id FROM Tickets", function(err, row) {
//       console.log(row.id + ": " + row.section + "," + row.row + "," + row.seat + "," + row.price + "," + row.seller_id);
//   });
// });

function hashPassword(password, salt) {
    var hash = crypto.createHash('sha256');
    hash.update(password);
    hash.update(salt);
    return hash.digest('hex');
}

function createUser(username, password) {
    var salt = crypto.randomBytes(salt_bytes);
    db.run('INSERT INTO Users(username, password, salt) VALUES (?, ?, ?)', username, hashPassword(password, salt), salt);
    // TODO: add error handling
}

function getSchool(school_name, callback) {
    // console.log(school_name);
    db.get('SELECT name, school_id FROM Schools WHERE name = ?', school_name, function(err, row) {
        if (!row) return callback(null, false);
        return callback(row);
    });
}

function serializeSchool(school, done) {
    return done(null, school.school_id);
}

function deserializeSchool(id, callback) {
    db.get('SELECT school_id, name FROM Schools WHERE school_id = ?', id, function(err, row) {
        if (!row) return callback(null, false);
        return callback(row);
    });
}

function serializeGame(game, done) {
    return done(null, game.game_id);
}

function deserializeGame(id, callback) {
    db.get('SELECT game_id, home_team_id, away_team_id, date FROM Games WHERE game_id = ?', id, function(err, row) {
        if (!row) return callback(null, false);
        return callback(row);
    });
}

function serializeTicket(ticket, done) {
    return done(null, ticket.ticket_id);
}

function deserializeTicket(id, callback) {
    db.get('SELECT ticket_id, game_id, seller_id, section, row, seat, price, sold FROM Tickets WHERE ticket_id = ?', id, function(err, row) {
        if (!row) return callback(null, false);
        return callback(row);
    });
}

function getSchools(callback) {
    db.all('SELECT * FROM Schools', function(err, rows) {
        // if (err) {
        //     // call your callback with the error
        //     callback(err);
        //     console.log("Error");
        //     return;
        // }
        // // call your callback with the data
        // callback(null, rows);
        callback(rows);
    });
}

function getGames(school_id, callback) {
    // TODO: add error handling
    db.all('SELECT * FROM Games WHERE home_team_id = ? OR away_team_id = ?', school_id, school_id, function(err, rows) {
        if(!rows.length) return callback(null, false);
        return callback(rows);
    });
}

function getRows(query, callback) {
    db.all(query, function(err, rows) {
        if(!rows.length) return callback(null, false);
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

// TODO: Clean up shutdown stuff
var shuttingDown = false;

app.use(function(req, resp, next) {
    if(!shuttingDown)
        return next();

    resp.setHeader('Connection', "close");
    resp.send(503, "Server is in the process of restarting");
    // Change the response to something your client is expecting:
    //   html, text, json, etc.
});

function cleanup() {
    shuttingDown = true;
    server.close(function() {
        console.log("Closed out remaining connections.");
        // Close db connections, other chores, etc.
        db.close();
        process.exit();
    });

    setTimeout(function() {
        console.error("Could not close connections in time, forcing shut down");
        process.exit(1);
    }, 30*1000);
}

process.on('SIGINT', cleanup);
process.on('SIGTERM', cleanup);
