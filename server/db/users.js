// db/users.js

// TODO: Cleanup

var sqlite3 = require('sqlite3').verbose();
var utils = require('../utils');
var crypto = require('crypto');

var dbDir = './db/app-data.db';

// Length in bytes of password salt
var saltBytes = 16;

exports.create = function(username, password, done) {
  var db = new sqlite3.Database(dbDir);
  db.run('PRAGMA foreign_keys = ON');

  // https://crackstation.net/hashing-security.htm#salt
  var salt = crypto.randomBytes(saltBytes);
  var hash = utils.hashPassword(password, salt);

  var query = 'INSERT INTO Users(username, password, salt) VALUES (?, ?, ?)';
  db.run(query, username, hash, salt, function(err) {
    if (err) return done(err);
    // TODO: Fix hacky solution
    // this.lastID is technically rowId of last row inserted into Users, so user_id *should* equal rowId
    return done(null, this.lastID);
  });

  db.close();
}

exports.find = function(userId, done) {
  var db = new sqlite3.Database(dbDir);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'SELECT user_id, username FROM Users WHERE user_id = ?';
  db.get(query, userId, function(err, row) {
    if (err) return done(err);
    if (!row) return done(null, false);   // TODO
    return done(null, row);
  });

  db.close();
};

exports.findByUsername = function(username, done) {
  var db = new sqlite3.Database(dbDir);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'SELECT user_id, username FROM Users WHERE username = ?';
  db.get(query, username, function(err, row) {
    if (err) return done(err);
    if (!row) return done(null, false);   // TODO
    return done(null, row);
  });

  db.close();
};

// TODO: Refactor/clean up (try to replace w/ commented-out code below)
exports.findByUsernameAndPassword = function(username, password, done) {
  var db = new sqlite3.Database(dbDir);
  db.run('PRAGMA foreign_keys = ON');

  var saltQuery = 'SELECT salt FROM Users WHERE username = ?';
  db.get(saltQuery, username, function(err, row) {
    if (err) return done (err);
    if (!row) return done(null, false);   // TODO
    var hash = utils.hashPassword(password, row.salt);
    var query = 'SELECT user_id, username FROM Users WHERE username = ? AND password = ?';
    db.get(query, username, hash, function(err, row) {
      if (err) return done(err);
      if (!row) return done(null, false);   // TODO
      return done(null, row);
    });
  });

  db.close();
};

/*
exports.findSalt = function(userId, done) {
  var db = new sqlite3.Database(dbDir);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'SELECT salt FROM Users WHERE user_id = ?';
  db.get(query, userId, function(err, row) {
    if (err) return done(err);
    if (!row) return done(null, false);   // TODO
    return done(null, row);
  });

  db.close();
};

exports.validPassword = function(username, password, salt, done) {
  var db = new sqlite3.Database(dbDir);
  db.run('PRAGMA foreign_keys = ON');

  var hash = utils.hashPassword(password, salt);

  var query = 'SELECT user_id FROM Users WHERE username = ? AND password = ?';
  db.get(query, username, hash, function(err, row) {
    if (err) return done(err);
    if (!row) return done(null, false);   // TODO
    return done(null, true);
  });

  db.close();
}
*/
