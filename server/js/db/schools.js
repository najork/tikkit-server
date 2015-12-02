// db/schools.js

const sqlite3 = require('sqlite3').verbose();
const prefs = require('../prefs');

const dbFile = prefs.dbFile;

exports.find = function(schoolId, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'SELECT * FROM Schools WHERE school_id = ?';
  db.get(query, schoolId, function(err, row) {
    if (err) return done(err);
    return done(null, row);
  });

  db.close();
}

exports.all = function(done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'SELECT * FROM Schools';
  db.all(query, function(err, rows) {
    if (err) return done(err);
    return done(null, rows);
  });

  db.close();
}
