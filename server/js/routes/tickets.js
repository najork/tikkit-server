// router/tickets.js

// TODO: Cleanup

const tickets = require('../db/tickets');

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
  // TODO: determine reasonable asserts, consider splitting notEmpty and isX asserts to give more descriptive error messages
  req.assert('section', 'Invalid section number').notEmpty().isInt({ min: 1 });
  req.assert('row', 'Invalid row number').notEmpty().isInt({ min: 1 });
  req.assert('seat', 'Invalid seat number').notEmpty().isInt({ min: 1 });
  req.assert('price', 'Invalid price').notEmpty().isInt({ min: 0 });

  const errors = req.validationErrors();
  if (errors) {
    res.status(400).send('Error: ' + util.inspect(errors));
    return;
  }

  // Checks: game exists, seller exists, identical ticket doesn't exist
  // TODO: Automatically get seller_id from logged-on user
  // Ticket price expected in cents
  var sold = false;
  tickets.create(req.params.gameId, req.query.seller_id, req.query.section, req.query.row, req.query.seat, req.query.price, sold, function(err, ticketId) {
    res.json({ ticket_id: ticketId });
  });
}

// Check: ticket_id exists
// Toggle sold status for ticket from ticket id
exports.setSold = function(req, res) {
  req.assert('sold', 'Invalid sold status').notEmpty().isBoolean();

  const errors = req.validationErrors();
  if (errors) {
    res.status(400).send('Error: ' + util.inspect(errors));
    return;
  }

  tickets.setSold(req.params.ticketId, req.query.sold, function(err, changes) {
    // TODO: Check value of changes (if 0, then no rows updated)
    res.sendStatus(204);  // 204 No Content
  });
}
