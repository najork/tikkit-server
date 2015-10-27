// server.js

var express = require('express');
var crypto = require('crypto');
var app = express();
var sqlite3 = require('sqlite3').verbose();
var db = new sqlite3.Database('db/app-data.db');      // TODO: PERSISTENT DB

var passport = require('passport');

// Set port
var port = process.env.PORT || 8080;

var salt_bytes = 16;

// Get instance of express Router
var router = express.Router();

// Test route (accessed at GET http://localhost:8080/api)
router.get('/', function(req, res) {
    res.json({ message: 'Welcome to our API!' });
});

// GET method route
app.get('/', function (req, res) {
  res.send('GET request to the homepage');
});

// POST method route
app.post('/', function (req, res) {
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
    salt = crypto.randomBytes(salt_bytes);
    db.run('INSERT INTO Users(username, password, salt) VALUES (?, ?, ?)', username, hashPassword(password, salt), salt);
    // TODO: add error handling
}

// TODO; TEST CODE
// createUser('test_user', 'test_password');

// passport.use(new LocalStrategy(function(username, password, done) {
//   db.get('SELECT salt FROM users WHERE username = ?', username, function(err, row) {
//     if (!row) return done(null, false);
//     var hash = hashPassword(password, row.salt);
//     db.get('SELECT username, id FROM users WHERE username = ? AND password = ?', username, hash, function(err, row) {
//       if (!row) return done(null, false);
//       return done(null, row);
//     });
//   });
// }));

// passport.serializeUser(function(user, done) {
//   return done(null, user.id);
// });

// passport.deserializeUser(function(id, done) {
//   db.get('SELECT id, username FROM users WHERE id = ?', id, function(err, row) {
//     if (!row) return done(null, false);
//     return done(null, row);
//   });
// });

app.post('/create', function (req, res) {
    createUser(req.query.username, req.query.password)
    console.log('Created new user: ' + req.query.username);
    res.json({ message: 'Successfully created user!' });
});

// app.post('/login', passport.authenticate('local', { successRedirect: '/good-login',
//                                                     failureRedirect: '/bad-login' }));

app.use(function (req, resp, next) {
    if(!shutting_down)
        return next();

    resp.setHeader('Connection', "close");
    resp.send(503, "Server is in the process of restarting");
    // Change the response to something your client is expecting:
    //   html, text, json, etc.
});

function cleanup() {
    shutting_down = true;
    server.close( function () {
        console.log("Closed out remaining connections.");
        // Close db connections, other chores, etc.
        db.close();
        process.exit();
    });

    setTimeout( function () {
        console.error("Could not close connections in time, forcing shut down");
        process.exit(1);
    }, 30*1000);
}

process.on('SIGINT', cleanup);
process.on('SIGTERM', cleanup);
