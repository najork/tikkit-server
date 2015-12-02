// auth.js

// TODO: Cleanup

const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const BearerStrategy = require('passport-http-bearer').Strategy;
const fs = require('fs');
const jwt = require('jwt-simple');
const moment = require('moment');
const utils = require('./utils');

const db = require('./db');

const config = JSON.parse(fs.readFileSync('./config.json', 'utf8'));

const serverSecret = config.auth.secret;
const accessTokenTtl = moment.duration(config.auth.tokenTtl, config.auth.tokenTtlUnits);

/**
 * LocalStrategy
 *
 * This strategy is used to authenticate users based on a username and password.
 * Anytime a request is made to authorize an application, we must ensure that
 * a user is logged in before asking them to approve the request.
 */
passport.use(new LocalStrategy(
  function(username, password, done) {
    db.users.findByUsernameAndPassword(username, password, function(err, user) {
      if (err) return done(err);
      if (!user) return done(null, false);
      return done(null, user);
    });
  }
));

passport.serializeUser(function(user, done) {
  return done(null, user.user_id);
});

passport.deserializeUser(function(id, done) {
  db.users.find(id, function (err, user) {
    done(err, user);
  });
});

/**
 * BearerStrategy
 *
 * This strategy is used to authenticate users based on an access token (aka a
 * bearer token).  The user must have previously authorized a client
 * application, which is issued an access token to make requests on behalf of
 * the authorizing user.
 */
passport.use(new BearerStrategy(
  function(accessToken, done) {
    db.accesstokens.find(accessToken, function(err, token) {
      if (err) return done(err);
      if (!token) return done(null, false);

      db.users.find(token.user_id, function(err, user) {
        if (err) return done(err);
        if (!user) return done(null, false);
        // to keep this example simple, restricted scopes are not implemented,
        // and this is just for illustrative purposes
        const info = { scope: '*' }
        done(null, user, info);
      });
    });
  }
));

/*
function validateCredentials(username, password) {
  db.users.findByUsername(username, function(err, row) {
    db.users.findSalt(
      db.users.validPassword()));
  }
}
*/

exports.createAccessToken = function(userId) {
  // Calculate token expiration time
  const expires = moment().add(accessTokenTtl).valueOf();

  // Generate new token
  const token = jwt.encode({
    iss: userId,
    exp: expires
  }, serverSecret);

  // Save token to db
  db.accesstokens.save(token, userId, function(err) {
    // if (err) return [WHAT?]
  });

  return { user_id: userId, token: token, expires: expires };
}
