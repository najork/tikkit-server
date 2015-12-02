// routes/users.js

const auth = require('../auth');
const users = require('../db/users');

// Login
exports.login = function(req, res) {
  users.findByUsernameAndPassword(req.query.username, req.query.password, function(err, row) {
    const accessToken = auth.createAccessToken(row.user_id);
    res.json(accessToken);
  });
}

// Create user
exports.create = function(req, res) {
  // Checks: username is unique, username ends with @umich.edu, password is at least 8 characters
  users.create(req.query.username, req.query.password, function(err, userId) {
    if (err) {
      // TODO: What's the correct response code?
      res.status(400).send(err);
      return;
    }

    // Return id of new user
    res.json({ user_id: userId });
  });
}
