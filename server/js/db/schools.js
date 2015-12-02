// db/schools.js

var sqlite3 = require('sqlite3').verbose();
var fs = require('fs');

var config = JSON.parse(fs.readFileSync('../config.json', 'utf8'));
var dbFile = config.db.dbFile;

exports.find = function(schoolId, done) {
  var db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'SELECT * FROM Schools WHERE school_id = ?';
  db.get(query, schoolId, function(err, row) {
    if (err) return done(err);
    return done(null, row);
  });

  db.close();
}

exports.all = function(done) {
  var db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'SELECT * FROM Schools';
  db.all(query, function(err, rows) {
    if (err) return done(err);
    return done(null, rows);
  });

  db.close();
}
