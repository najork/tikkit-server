// db/games.js

var sqlite3 = require('sqlite3').verbose();
var dbDir = './db/app-data.db';

exports.serializeGame = function(game, done) {
  return done(null, game.game_id);
}

exports.deserializeGame = function(id, callback) {
  var db = new sqlite3.Database(dbDir);
  db.run("PRAGMA foreign_keys = ON");

  db.get('SELECT game_id, home_team_id, away_team_id, date FROM Games WHERE game_id = ?', id, function(err, row) {
    if (err) return callback(err);
    if (!row) return callback(null, false);
    return callback(row);
  });

  db.close();
}

exports.getGames = function(schoolId, callback) {
  var db = new sqlite3.Database(dbDir);
  db.run("PRAGMA foreign_keys = ON");

  db.all('SELECT * FROM Games WHERE home_team_id = ? OR away_team_id = ?', schoolId, schoolId, function(err, rows) {
    if (err) return callback(err);
    if (!rows.length) return callback(null, false);
    return callback(rows);
  });

  db.close();
}
