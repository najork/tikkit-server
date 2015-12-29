/**
 * @author Max Najork
 */

const schools = require('../db/schools');

// Get school
exports.find = function(req, res) {
  schools.find(req.params.schoolId, function(err, row) {
    // Database error
    if (err) {
      res.status(500).send(err);
      return;
    }

    // School not found
    if (!row) {
      res.sendStatus(404);
      return;
    }

    res.json(row);
  });
};

// List all schools
exports.all = function(req, res) {
  schools.all(function(err, rows) {
    // Database error
    if (err) {
      res.status(500).send(err);
      return;
    }

    // No schools
    if (!rows) {
      res.sendStatus(404);
      return;
    }

    res.json(rows);
  });
};
