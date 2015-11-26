// db/schools.js

var sqlite3 = require('sqlite3').verbose();
var dbDir = './db/app-data.db';

exports.getSchool = function(schoolName, callback) {
  var db = new sqlite3.Database(dbDir);
  db.run("PRAGMA foreign_keys = ON");

  db.get('SELECT name, school_id FROM Schools WHERE name = ?', schoolName, function(err, row) {
    if (err) return callback(err);
    if (!row) return callback(null, false);
    return callback(row);
  });

  db.close();
}

exports.serializeSchool = function(school, done) {
  return done(null, school.school_id);
}

exports.deserializeSchool = function(id, callback) {
  var db = new sqlite3.Database(dbDir);
  db.run("PRAGMA foreign_keys = ON");

  db.get('SELECT school_id, name FROM Schools WHERE school_id = ?', id, function(err, row) {
    if (err) return callback(err);
    if (!row) return callback(null, false);
    return callback(row);
  });

  db.close();
}

exports.getSchools = function(callback) {
  var db = new sqlite3.Database(dbDir);
  db.run("PRAGMA foreign_keys = ON");

  db.all('SELECT * FROM Schools', function(err, rows) {
    if (err) return callback(err);
    if (!rows.length) return callback(null, false);
    return callback(rows);
  });

  db.close();
}
