/**
 * @author Max Najork
 */

const util = require('util');

const auth = require('../auth');
const tickets = require('../db/tickets');

// Get ticket
exports.find = function(req, res) {
  tickets.find(req.params.ticketId, function(err, row) {
    // Database error
    if (err) {
      res.status(500).send(err);
      return;
    }

    // School not found
    if (!row) {
      res.sendStatus(404);
      return;
    }

    res.json(row);
  });
};

// Get all tickets for game
exports.findByGame = function(req, res) {
  tickets.findByGame(req.params.gameId, function(err, rows) {
    // Database error
    if (err) {
      res.status(500).send(err);
      return;
    }

    // School not found
    if (!rows) {
      res.sendStatus(404);
      return;
    }

    res.json(rows);
  });
};

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
  };

  const userId = getUserId(req);
  const sold = 0;

  // Ticket price expected in cents
  tickets.create(req.params.gameId, userId, req.query.section, req.query.row,
      req.query.seat, req.query.price, sold, function(err, ticketId) {
    // Database error
    if (err) {
      res.status(500).send(err);
      return;
    }

    res.json({ ticket_id: ticketId });
  });
};

// Destroy an existing ticket
exports.destroy = function(req, res) {
  const userId = getUserId(req);
  tickets.remove(req.params.ticketId, userId, function(err, changes) {
    // Database error
    if (err) {
      res.status(500).send(err);
      return;
    }

    if (!changes) {
      const msg = 'Ticket does not exist or is not for sale by this user';
      res.status(400).send({ msg: msg });
      return;
    }

    res.sendStatus(204);  // No Content
  });
};

// Update ticket price and sold status
exports.update = function(req, res) {
  const price = req.query.price;
  const sold = req.query.sold;
  const params = [];

  if(price !== undefined) {
    req.checkQuery('price', 'Price cannot be negative').isInt({ min: 0 });
  }

  if(sold !== undefined) {
    req.checkQuery('sold', 'Sold status must be boolean').isBoolean();
  }

  const errors = req.validationErrors();
  if (errors) {
    res.status(400).send('Error: ' + util.inspect(errors));
    return;
  };

  const userId = getUserId(req);
  const msg = 'Ticket does not exist or is not for sale by this user';

  if (price !== undefined) {
    tickets.setSold(req.params.ticketId, userId, price,
        function(err, changes) {
      // Database error
      if (err) {
        res.status(500).send(err);
        return;
      }

      if (!changes) {
        res.status(400).send({ msg: msg });
        return;
      }
    });
  }

  if (sold !== undefined) {
    tickets.setSold(req.params.ticketId, userId, boolToInt(sold),
        function(err, changes) {
      // Database error
      if (err) {
        res.status(500).send(err);
        return;
      }

      if (!changes) {
        res.status(400).send({ msg: msg });
        return;
      }
    });
  }

  res.sendStatus(204);  // No Content
};

// Get user id from bearer token
function getUserId(req) {
  const accessToken = req.header('Authorization').split(' ')[1];
  return auth.decodeAccessToken(accessToken).iss;
}

// Convert boolean to integer for sqlite
function boolToInt(sold) {
  return (sold == 'true' || sold == 1) ? 1 : 0;
}
