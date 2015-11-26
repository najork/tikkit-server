// db/index.js

exports.users = require('./users');
exports.games = require('./games');
exports.schools = require('./schools');
exports.tickets = require('./tickets');

// Enable sqlite foreign key constraint enforcement
// https://www.sqlite.org/foreignkeys.html#fk_enable
// db.run("PRAGMA foreign_keys = ON");
