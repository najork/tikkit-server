/**
 * @author Max Najork
 */

const express = require('express');
const passport = require('passport');

const routes = require('./routes');

module.exports = function(app) {
  // Set up passport
  app.use(passport.initialize());
  app.use(passport.session());

  // Route all calls to /api endpoints through router
  const router = express.Router();
  app.use('/api', router);

  // Login
  app.post('/login', passport.authenticate('local', { failureRedirect: '/login' }), routes.users.login);

  // Create user
  app.post('/create', routes.users.create);

  // TODO: Create school endpoint
  // TODO: Determine return value and response status for query with non-existant id

  // Use bearer auth to protect all /api calls
  router.use(passport.authenticate('bearer', { session: false }));

  // Get school from school id
  router.get('/schools/:schoolId', routes.schools.find);

  // List all schools
  router.get('/lists/schools', routes.schools.all);

  // TODO: Create game endpoint

  // Get game from game id
  router.get('/games/:gameId', routes.games.find);

  // Get all games for school from school id
  router.get('/lists/schools/:schoolId/games', routes.games.findBySchool);

  // Get ticket from ticket id
  router.get('/tickets/:ticketId', routes.tickets.find);

  // Get all tickets for game from game id
  router.get('/lists/games/:gameId/tickets', routes.tickets.findByGame);

  // Checks: game exists, seller exists
  // Create a new ticket
  router.post('/games/:gameId/tickets/create', routes.tickets.create);

  // Check: ticket_id exists
  // Toggle sold status for ticket from ticket id
  router.post('/tickets/:ticketId/sold', routes.tickets.setSold);
}
