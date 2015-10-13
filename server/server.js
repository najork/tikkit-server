// server.js

var express = require('express');
var app = express();
var sqlite3 = require('sqlite3').verbose();
var db = new sqlite3.Database(':memory:');

// Set port
var port = process.env.PORT || 8080;

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

app.listen(port);
console.log('Server running on port ' + port);
