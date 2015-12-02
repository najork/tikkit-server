// db/accesstokens.js

var sqlite3 = require('sqlite3').verbose();
var fs = require('fs');

var config = JSON.parse(fs.readFileSync('../config.json', 'utf8'));
var dbFile = config.db.dbFile;

exports.find = function(token, done) {
  var db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'SELECT * FROM AccessTokens WHERE token = ?';
  db.get(query, token, function(err, row) {
    if (err) return done(err);
    return done(null, row);
  });

  db.close();
}

exports.save = function(token, userId, done) {
  var db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'INSERT INTO AccessTokens(token, user_id) VALUES (?, ?)';
  db.run(query, token, userId, function(err) {
    if (err) return done(err);
    return done(null);
  });

  db.close();
}
