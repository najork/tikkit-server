/**
 * @author Max Najork
 */

const fs = require('fs');

const configPath = __dirname + '/../config.json';
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

// Server
exports.port = config.server.port;
exports.logDir = config.server.logDir;

// Database
exports.dbFile = config.db.dbFile;
exports.passwordSaltLength = config.db.passwordSaltLength;

// Auth
exports.secret = config.auth.secret;
exports.tokenTtl = config.auth.tokenTtl;
exports.tokenTtlUnits = config.auth.tokenTtlUnits;
