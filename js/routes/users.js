/**
 * @author Max Najork
 */

const auth = require('../auth');
const users = require('../db/users');

// Get user
exports.find = function(req, res) {
  users.find(req.params.userId, function(err, row) {
    // Database error
    if (err) {
      res.status(500).send(err);
      return;
    }

    // User not found
    if (!row) {
      res.sendStatus(404);
      return;
    }

    res.json(row);
  });
};

// Login
exports.login = function(req, res) {
  const username = req.body.username;
  const password = req.body.password;

  // Validate username and password
  if (!username || !password) {
    res.sendStatus(400);
    return;
  }

  users.findByUsernameAndPassword(username, password, function(err, row) {
    // Database error
    if (err) {
      res.status(500).send(err);
      return;
    }

    // User not found
    if (!row) {
      // Should never reach
      res.sendStatus(404);
      return;
    }

    auth.createAccessToken(row.user_id, function(err, row) {
      // Database error
      if (err) {
        res.status(500).send(err);
        return;
      }

      res.json(row);
    });
  });
};

// Create new user
exports.create = function(req, res) {
  const username = req.body.username;
  const password = req.body.password;
  const err = [];

  // Validate @umich.edu email address
  const domain = username.split('@')[1];
  if (domain != 'umich.edu') {
    err.push({ param: 'username',
               msg: 'Username must be an @umich.edu email address' });
  }

  // Validate password length
  if (password.length < 8) {
    err.push({ param: 'password',
               msg: 'Password must be at least 8 characters' });
  }

  // Validation failed
  if(err.length) {
    res.status(400).send(err);
    return;
  }

  users.create(username, password, function(err, userId) {
    // Database error
    if (err) {
      res.status(500).send(err);
      return;
    }

    res.status(201).json({ user_id: userId });  // Created
  });
};
