/**
 * @author Max Najork
 */

// TODO: Cleanup

const sqlite3 = require('sqlite3').verbose();
const crypto = require('crypto');
const prefs = require('../prefs');

const dbFile = prefs.dbFile;
const saltBytes = prefs.passwordSaltLength;

exports.create = function(username, password, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  // https://crackstation.net/hashing-security.htm#salt
  const salt = crypto.randomBytes(saltBytes);
  const hash = utils.hashPassword(password, salt);

  const query = 'INSERT INTO Users(username, password, salt) VALUES (?, ?, ?)';
  db.run(query, username, hash, salt, function(err) {
    if (err) return done(err);
    // TODO: Fix hacky solution
    // this.lastID is technically rowId of last row inserted into Users, so user_id *should* equal rowId
    return done(null, this.lastID);
  });

  db.close();
}

exports.find = function(userId, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'SELECT user_id, username FROM Users WHERE user_id = ?';
  db.get(query, userId, function(err, row) {
    if (err) return done(err);
    if (!row) return done(null, false);
    return done(null, row);
  });

  db.close();
};

exports.findByUsername = function(username, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'SELECT user_id, username FROM Users WHERE username = ?';
  db.get(query, username, function(err, row) {
    if (err) return done(err);
    if (!row) return done(null, false);
    return done(null, row);
  });

  db.close();
};

// TODO: Refactor/clean up (try to replace w/ commented-out code below)
exports.findByUsernameAndPassword = function(username, password, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const saltQuery = 'SELECT salt FROM Users WHERE username = ?';
  db.get(saltQuery, username, function(err, row) {
    if (err) return done (err);
    if (!row) return done(null, false);
    const hash = utils.hashPassword(password, row.salt);
    const query = 'SELECT user_id, username FROM Users WHERE username = ? AND password = ?';
    db.get(query, username, hash, function(err, row) {
      if (err) return done(err);
      if (!row) return done(null, false);
      return done(null, row);
    });
  });

  db.close();
};

function hashPassword(password, salt) {
  const hash = crypto.createHash('sha256');
  hash.update(password);
  hash.update(salt);
  return hash.digest('hex');
}

/*
exports.findSalt = function(userId, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'SELECT salt FROM Users WHERE user_id = ?';
  db.get(query, userId, function(err, row) {
    if (err) return done(err);
    if (!row) return done(null, false);
    return done(null, row);
  });

  db.close();
};

exports.validPassword = function(username, password, salt, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const hash = utils.hashPassword(password, salt);

  const query = 'SELECT user_id FROM Users WHERE username = ? AND password = ?';
  db.get(query, username, hash, function(err, row) {
    if (err) return done(err);
    if (!row) return done(null, false);
    return done(null, true);
  });

  db.close();
}
*/
