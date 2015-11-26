// users.js

var sqlite3 = require('sqlite3').verbose();
var utils = require('../utils');
var crypto = require('crypto');

var dbDir = './db/app-data.db';

// Length in bytes of password salt
var saltBytes = 16;

// Checks: username is unique, username ends with @umich.edu, password is at least 8 characters
exports.createUser = function(username, password, callback) {
  var db = new sqlite3.Database(dbDir);
  db.run("PRAGMA foreign_keys = ON");

  // https://crackstation.net/hashing-security.htm#salt
  var salt = crypto.randomBytes(saltBytes);
  db.run('INSERT INTO Users(username, password, salt) VALUES (?, ?, ?)', username, utils.hashPassword(password, salt), salt, function(err, row) {
    if (err) return callback(err);
    return callback(this.lastID);
  });
  // TODO: add error handling

  db.close();
}
