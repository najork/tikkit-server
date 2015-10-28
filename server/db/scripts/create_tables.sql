CREATE TABLE Users(user_id INTEGER PRIMARY KEY AUTOINCREMENT,
                   username TEXT,
                   password TEXT,
                   salt TEXT);

CREATE TABLE Schools(school_id INTEGER PRIMARY KEY AUTOINCREMENT,
                     name TEXT);

CREATE TABLE Games(game_id INTEGER PRIMARY KEY AUTOINCREMENT,
                   home_team TEXT,
                   away_team TEXT,
                   date TEXT);

CREATE TABLE Tickets(ticket_id INTEGER PRIMARY KEY AUTOINCREMENT,
                     game_id INTEGER,
                     seller_id INTEGER,
                     section INTEGER,
                     row INTEGER,
                     seat INTEGER,
                     price INTEGER
                     sold INTEGER);

