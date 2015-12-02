// db/tickets.js

// TODO: Cleanup

const sqlite3 = require('sqlite3').verbose();
const prefs = require('../prefs');

const dbFile = prefs.dbFile;

exports.find = function(ticketId, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'SELECT * FROM Tickets WHERE ticket_id = ?';
  db.get(query, ticketId, function(err, row) {
    if (err) return done(err);
    return done(null, row);
  });

  db.close();
}

exports.findByGame = function(gameId, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'SELECT * FROM Tickets WHERE game_id = ?';
  db.all(query, gameId, function(err, rows) {
    if (err) return done(err);
    return done(null, rows);
  });

  db.close();
}

exports.create = function(gameId, sellerId, section, row, seat, price, sold, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'INSERT INTO Tickets(game_id, seller_id, section, row, seat, price, sold) VALUES (?, ?, ?, ?, ?, ?, ?)';
  db.run(query, gameId, sellerId, section, row, seat, price, sold, function(err) {
    if (err) return done(err);
    // TODO: Fix hacky solution
    // this.lastID is technically rowId of last row inserted into Tickets, so ticket_id *should* equal rowId
    return done(null, this.lastID);
  });

  db.close();
}

exports.setSold = function(ticketId, sold, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'UPDATE Tickets SET sold = ? WHERE ticket_id = ?';
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
