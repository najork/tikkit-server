/**
 * @author Max Najork
 */

const auth = require('../auth');
const users = require('../db/users');

// Login
exports.login = function(req, res) {
  users.findByUsernameAndPassword(req.query.username, req.query.password, function(err, row) {
    const accessToken = auth.createAccessToken(row.user_id);
    res.json(accessToken);
  });
}
