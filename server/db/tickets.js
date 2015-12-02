// db/tickets.js

var sqlite3 = require('sqlite3').verbose();
var dbDir = './db/app-data.db';

exports.find = function(id, done) {
  var db = new sqlite3.Database(dbDir);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'SELECT * FROM Tickets WHERE ticket_id = ?';
  db.get(query, id, function(err, row) {
    if (err) return done(err);
    return done(null, row);
  });

  db.close();
}

exports.findByGame = function(gameId, done) {
  var db = new sqlite3.Database(dbDir);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'SELECT * FROM Tickets WHERE game_id = ?';
  db.all(query, gameId, function(err, rows) {
    if (err) return done(err);
    return done(null, rows);
  });

  db.close();
}

// Checks: game exists, seller exists
exports.create = function(gameId, sellerId, section, row, seat, price, sold, done) {
  var db = new sqlite3.Database(dbDir);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'INSERT INTO Tickets(game_id, seller_id, section, row, seat, price, sold) VALUES (?, ?, ?, ?, ?, ?, ?)';
  db.run(query, gameId, sellerId, section, row, seat, price, sold, function(err) {
    if (err) return done(err);
    // TODO: Fix hacky solution
    // this.lastID is technically rowId of last row inserted into Tickets, so ticket_id *should* equal rowId
    return done(null, this.lastID);
  });

  db.close();
}

// Check: ticket id exists
exports.setSold = function(ticketId, sold, done) {
  var db = new sqlite3.Database(dbDir);
  db.run('PRAGMA foreign_keys = ON');

  var query = 'UPDATE Tickets SET sold = ? WHERE ticket_id = ?';
  db.run(query, boolToInt(sold), ticketId, function(err) {
    if (err) return done(err);
    // No rows were changed if this.changes == 0 (ticket being updated does not exist)
    return done(null, this.changes);
  });

  db.close();
}

// Convert boolean to integer for sqlite
function boolToInt(sold) {
  return (sold == 'true' || sold == 1) ? 1 : 0;
}
