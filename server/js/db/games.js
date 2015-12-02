// db/games.js

const sqlite3 = require('sqlite3').verbose();
const prefs = require('../prefs');

const dbFile = prefs.dbFile;

exports.find = function(gameId, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'SELECT * FROM Games WHERE game_id = ?';
  db.get(query, gameId, function(err, row) {
    if (err) return done(err);
    if (!row) return done(null, false);
    return done(null, row);
  });

  db.close();
}

exports.findBySchool = function(schoolId, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'SELECT * FROM Games WHERE home_team_id = ? OR away_team_id = ?';
  db.all(query, schoolId, schoolId, function(err, rows) {
    if (err) return done(err);
    if (!rows.length) return done(null, false);
    return done(null, rows);
  });

  db.close();
}
