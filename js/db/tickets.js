/**
 * @author Max Najork
 */

const sqlite3 = require('sqlite3').verbose();
const prefs = require('../prefs');

const dbFile = prefs.dbFile;

exports.find = function(ticketId, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'SELECT * FROM Tickets WHERE ticket_id = ?';
  db.get(query, ticketId, function(err, row) {
    if (err) return done(err);
    if (!row) return done(null, false);
    return done(null, row);
  });

  db.close();
};

exports.findByGame = function(gameId, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'SELECT * FROM Tickets WHERE game_id = ?';
  db.all(query, gameId, function(err, rows) {
    if (err) return done(err);
    if (!rows.length) return done(null, false);
    return done(null, rows);
  });

  db.close();
};

exports.findBySeller = function(sellerId, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'SELECT * FROM Tickets WHERE seller_id = ?';
  db.all(query, sellerId, function(err, rows) {
    if (err) return done(err);
    if (!rows.length) return done(null, false);
    return done(null, rows);
  });

  db.close();
};

exports.create = function(gameId, sellerId, section, row, seat, price, sold, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'INSERT INTO Tickets(game_id, seller_id, section, row, seat, price, sold) ' +
    'VALUES (?, ?, ?, ?, ?, ?, ?)';
  db.run(query, gameId, sellerId, section, row, seat, price, sold, function(err) {
    if (err) return done(err);
    // TODO: Fix hacky solution
    /** this.lastID is technically rowId of last row inserted into Tickets, so ticket_id
     * *should* equal rowId */
    return done(null, this.lastID);
  });

  db.close();
};

exports.destroy = function(ticketId, sellerId, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'DELETE FROM Tickets WHERE ticket_id = ? AND seller_id = ?';
  db.run(query, ticketId, sellerId, function(err) {
    if (err) return done(err);
    return done(null, this.changes);
  });

  db.close();
};

exports.setPrice = function(ticketId, sellerId, price, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'UPDATE Tickets SET price = ? WHERE ticket_id = ? AND seller_id = ?';
  db.run(query, price, ticketId, sellerId, function(err) {
    if (err) return done(err);
    return done(null, this.changes);
  });

  db.close();
};

exports.setSold = function(ticketId, sellerId, sold, done) {
  const db = new sqlite3.Database(dbFile);
  db.run('PRAGMA foreign_keys = ON');

  const query = 'UPDATE Tickets SET sold = ? WHERE ticket_id = ? AND seller_id = ?';
  db.run(query, sold, ticketId, sellerId, function(err) {
    if (err) return done(err);
    return done(null, this.changes);
  });

  db.close();
};
