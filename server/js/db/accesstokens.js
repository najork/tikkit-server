// db/accesstokens.js

const sqlite3 = require('sqlite3').verbose();
const prefs = require('../prefs');

const dbFile = prefs.dbFile;

exports.find = function(token, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'SELECT * FROM AccessTokens WHERE token = ?';
  db.get(query, token, function(err, row) {
    if (err) return done(err);
    if (!row) return done(null, false);
    return done(null, row);
  });

  db.close();
}

exports.save = function(token, userId, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'INSERT INTO AccessTokens(token, user_id) VALUES (?, ?)';
  db.run(query, token, userId, function(err) {
    if (err) return done(err);
    if (!row) return done(null, false);
    return done(null);
  });

  db.close();
}
