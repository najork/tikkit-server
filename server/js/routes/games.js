// routes/games.js

const games = require('../db/games');

// Get game from game id
exports.find = function(req, res) {
  games.find(req.params.gameId, function(err, row) {
    res.json(row);
  });
}

// Get all games for school from school id
exports.findBySchool = function(req, res) {
  games.findBySchool(req.params.schoolId, function(err, rows) {
    res.json(rows);
  });
}
