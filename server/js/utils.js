/**
 * @author Max Najork
 */

const crypto = require('crypto');

exports.hashPassword = function(password, salt) {
  const hash = crypto.createHash('sha256');
  hash.update(password);
  hash.update(salt);
  return hash.digest('hex');
}
