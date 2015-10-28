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

// TODO: think about what the endpoint should be called
router.post('/school/list', function(req, res) {
    getSchools(function(rows) {
        var schools = [];
        rows.forEach(function(row) {
            schools.push(row.name);
        });
        res.json(schools);
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

// passport.serializeUser(function(user, done) {
//   return done(null, user.id);
// });

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
