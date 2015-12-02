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
  const err = [];

  // Validate username
  const domain = req.query.username.split('@')[1];
  if (domain != 'umich.edu') {
    err.push({ param: 'username', msg: 'Username must be an @umich.edu email address' });
  }

  // Validate password length
  if (req.query.password.length < 8) {
    err.push({ param: 'password', msg: 'Password must be at least 8 characters' });
  }

  // Check if validation failed
  if(err.length) {
    res.status(400).send(err);
    return;
  }

  users.create(req.query.username, req.query.password, function(err, userId) {
    if (err) {
      res.status(400).send(err);
      return;
    }

    // Send new user_id in response
    res.json({ user_id: userId });
  });
}
