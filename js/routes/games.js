/**
 * @author Max Najork
 */

const games = require('../db/games');

// Get game
exports.find = function(req, res) {
  games.find(req.params.gameId, function(err, row) {
    // Database error
    if (err) {
      res.status(500).send(err);
      return;
    }

    // Game not found
    if (!row) {
      res.sendStatus(404);
      return;
    }

    res.json(row);
  });
};

// Get all games for school
exports.findBySchool = function(req, res) {
  games.findBySchool(req.params.schoolId, function(err, rows) {
    // Database error
    if (err) {
      res.status(500).send(err);
      return;
    }

    // No games
    if (!rows.length) {
      res.sendStatus(404);
      return;
    }

    res.json(rows);
  });
};
