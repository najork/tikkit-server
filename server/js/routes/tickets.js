// router/tickets.js

// TODO: Cleanup

const util = require('util');

const auth = require('../auth');
const tickets = require('../db/tickets');

// Default sold status of newly
const soldDefault = 0;  // false

// Get ticket from ticket id
exports.find = function(req, res) {
  tickets.find(req.params.ticketId, function(err, row) {
    res.json(row);
  });
}

// Get all tickets for game from game id
exports.findByGame = function(req, res) {
  tickets.findByGame(req.params.gameId, function(err, rows) {
    res.json(rows);
  });
}

// Checks: game exists, seller exists
// Create a new ticket
exports.create = function(req, res) {
  // Validate query parameters
  req.checkQuery('section', 'Section number must be positive').isInt({ min: 1 });
  req.checkQuery('row', 'Row number must be positive').isInt({ min: 1 });
  req.checkQuery('seat', 'Seat number must be positive').isInt({ min: 1 });
  req.checkQuery('price', 'Price cannot be negative').isInt({ min: 0 });

  const errors = req.validationErrors();
  if (errors) {
    res.status(400).send('Error: ' + util.inspect(errors));
    return;
  }

  // Get user_id of seller from token
  const accessToken = req.header('Authorization').split(' ')[1];
  const user_id = auth.decodeAccessToken(accessToken).iss;

  // Mark ticket as unsold
  const sold = 0;

  // Checks: game exists, seller exists, identical ticket doesn't exist
  // Ticket price expected in cents
  tickets.create(req.params.gameId, user_id, req.query.section, req.query.row, req.query.seat, req.query.price, sold, function(err, ticketId) {
    res.json({ ticket_id: ticketId });
  });
}

// Check: ticket_id exists
// Toggle sold status for ticket from ticket id
exports.setSold = function(req, res) {
  // Validate query parameters
  req.checkQuery('sold', 'Sold status required').notEmpty();
  req.checkQuery('sold', 'Sold status must be boolean').isBoolean();

  const errors = req.validationErrors();
  if (errors) {
    res.status(400).send('Error: ' + util.inspect(errors));
    return;
  }

  tickets.setSold(req.params.ticketId, boolToInt(req.query.sold), function(err, changes) {
    // TODO: Check value of changes (if 0, then no rows updated)
    res.sendStatus(204);  // 204 No Content
  });
}

// Convert boolean to integer for sqlite
function boolToInt(sold) {
  return (sold == 'true' || sold == 1) ? 1 : 0;
}
