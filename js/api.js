/**
 * @author Max Najork
 */

const express = require('express');
const passport = require('passport');

const routes = require('./routes');

module.exports = function(app) {
  // Set up passport
  app.use(passport.initialize());

  const router = express.Router();

  // Use bearer token auth on /api endpoints
  router.use(passport.authenticate('bearer', { session: false }));

  // Send all /api endpoint calls through router
  app.use('/api', router);

  // Create new user
  app.post('/create', routes.users.create);

  // Log in
  app.post('/login', passport.authenticate('local', { session: false }), routes.users.login);

  // Get user
  router.get('/users/:userId', routes.users.find);

  // Get all tickets for sale by user
  router.get('/users/:userId/tickets', routes.tickets.findBySeller);

  // List all schools
  router.get('/schools', routes.schools.all);

  // Get school
  router.get('/schools/:schoolId', routes.schools.find);

  // Get all games for school
  router.get('/schools/:schoolId/games', routes.games.findBySchool);

  // Get game
  router.get('/games/:gameId', routes.games.find);

  // Get all tickets for game
  router.get('/games/:gameId/tickets', routes.tickets.findByGame);

  // Create new ticket
  router.post('/games/:gameId/tickets/create', routes.tickets.create);

  // Get ticket
  router.get('/tickets/:ticketId', routes.tickets.find);

  // Update existing ticket
  router.post('/tickets/:ticketId/update', routes.tickets.update);

  // Destroy existing ticket
  router.post('/tickets/:ticketId/destroy', routes.tickets.destroy);
};
