// routes/schools.js

const schools = require('../db/schools');

// Get school from school id
exports.find = function(req, res) {
  schools.find(req.params.schoolId, function(err, row) {
    res.json(row);
  });
}

// List all schools
exports.all = function(req, res) {
  schools.all(function(err, rows) {
    res.json(rows);
  });
}
