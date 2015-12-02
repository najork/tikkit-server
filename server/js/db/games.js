// db/games.js

var sqlite3 = require('sqlite3').verbose();
var fs = require('fs');

var config = JSON.parse(fs.readFileSync('../config.json', 'utf8'));
var dbFile = config.db.dbFile;

exports.find = function(gameId, done) {
  var db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'SELECT * FROM Games WHERE game_id = ?';
  db.get(query, gameId, function(err, row) {
    if (err) return done(err);
    return done(null, row);
  });

  db.close();
}

exports.findBySchool = function(schoolId, done) {
  var db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'SELECT * FROM Games WHERE home_team_id = ? OR away_team_id = ?';
  db.all(query, schoolId, schoolId, function(err, rows) {
    if (err) return done(err);
    return done(null, rows);
  });

  db.close();
}
