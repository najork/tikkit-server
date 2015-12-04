/**
 * @author Max Najork
 */

const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const BearerStrategy = require('passport-http-bearer').Strategy;
const fs = require('fs');
const jwt = require('jwt-simple');
const moment = require('moment');

const db = require('./db');
const prefs = require('./prefs');

const serverSecret = prefs.secret;
const accessTokenTtl = moment.duration(prefs.tokenTtl, prefs.tokenTtlUnits);

// Set up passport local strategy
passport.use(new LocalStrategy(
  function(username, password, done) {
    db.users.findByUsernameAndPassword(username, password, function(err, user) {
      if (err) return done(err);
      if (!user) return done(null, false);
      return done(null, user);
    });
  }
));

// Set up passport bearer strategy
passport.use(new BearerStrategy(
  function(accessToken, done) {
    db.accesstokens.find(accessToken, function(err, token) {
      if (err) return done(err);
      if (!token) return done(null, false);

      db.users.find(token.user_id, function(err, user) {
        if (err) return done(err);
        if (!user) return done(null, false);
        const info = { scope: '*' }
        done(null, user, info);
      });
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

exports.createAccessToken = function(userId, done) {
  // Calculate token expiration time
  const expires = moment().add(accessTokenTtl).valueOf();

  // Generate new token
  const token = jwt.encode({
    iss: userId,
    exp: expires
  }, serverSecret);

  // Save token to db
  db.accesstokens.save(token, userId, function(err) {
    if (err) return done(err);
    const row = { user_id: userId, token: token, expires: expires };
    return done(null, row);
  });
};

exports.decodeAccessToken = function(token) {
  return jwt.decode(token, serverSecret);
};
