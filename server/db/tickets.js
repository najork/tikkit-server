// db/tickets.js

var sqlite3 = require('sqlite3').verbose();
var dbDir = './db/app-data.db';

exports.serializeTicket = function(ticket, done) {
  return done(null, ticket.ticket_id);
}

exports.deserializeTicket = function(id, callback) {
  var db = new sqlite3.Database(dbDir);
  db.run("PRAGMA foreign_keys = ON");

  db.get('SELECT ticket_id, game_id, seller_id, section, row, seat, price, sold FROM Tickets WHERE ticket_id = ?', id, function(err, row) {
    if (err) return callback(err);
    if (!row) return callback(null, false);
    return callback(row);
  });

  db.close();
}

exports.getTickets = function(gameId, callback) {
  var db = new sqlite3.Database(dbDir);
  db.run("PRAGMA foreign_keys = ON");

  db.all('SELECT * FROM Tickets WHERE game_id = ?', gameId, function(err, rows) {
    if (err) return callback(err);
    if (!rows.length) return callback(null, false);
    return callback(rows);
  });

  db.close();
}

// Checks: game exists, seller exists
exports.createTicket = function(gameId, sellerId, section, row, seat, price, sold, callback) {
  var db = new sqlite3.Database(dbDir);
  db.run("PRAGMA foreign_keys = ON");

  db.run('INSERT INTO Tickets(game_id, seller_id, section, row, seat, price, sold) VALUES (?, ?, ?, ?, ?, ?, ?)', gameId, sellerId, section, row, seat, price, sold, function(err, row) {
    if (err) return callback(err);
    return callback(this.lastID);
  });

  db.close();
}

// Check: ticket id exists
exports.setSold = function(ticketId, sold, callback) {
  var db = new sqlite3.Database(dbDir);
  db.run("PRAGMA foreign_keys = ON");

  // Convert boolean to integer representation for sqlite
  var soldInt = (sold == 'true' || sold == 1) ? 1 : 0;
  db.run('UPDATE Tickets SET sold = ? WHERE ticket_id = ?', sold, ticketId, function(err, row) {
    if (err) return callback(err);
    return callback(this.changes);
  });

  db.close();
}
