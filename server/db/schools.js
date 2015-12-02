// db/schools.js

var sqlite3 = require('sqlite3').verbose();
var dbDir = './db/app-data.db';

exports.find = function(id, done) {
  var db = new sqlite3.Database(dbDir);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'SELECT * FROM Schools WHERE school_id = ?';
  db.get(query, id, function(err, row) {
    if (err) return done(err);
    return done(null, row);
  });

  db.close();
}

exports.all = function(done) {
  var db = new sqlite3.Database(dbDir);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'SELECT * FROM Schools';
  db.all(query, function(err, rows) {
    if (err) return done(err);
    return done(null, rows);
  });

  db.close();
}
