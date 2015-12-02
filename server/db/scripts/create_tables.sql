CREATE TABLE Users(user_id INTEGER PRIMARY KEY AUTOINCREMENT,
                   username TEXT NOT NULL UNIQUE,
                   password TEXT NOT NULL,
                   salt TEXT);

CREATE TABLE AccessTokens(token TEXT NOT NULL PRIMARY KEY,
                          user_id INTEGER NOT NULL REFERENCES Users(user_id));

CREATE TABLE Schools(school_id INTEGER PRIMARY KEY AUTOINCREMENT,
                     name TEXT NOT NULL UNIQUE);

CREATE TABLE Games(game_id INTEGER PRIMARY KEY AUTOINCREMENT,
                   home_team_id INTEGER NOT NULL REFERENCES Schools(school_id),
                   away_team_id INTEGER NOT NULL REFERENCES Schools(school_id),
                   date TEXT);

CREATE TABLE Tickets(ticket_id INTEGER PRIMARY KEY AUTOINCREMENT,
                     game_id INTEGER NOT NULL REFERENCES Games(game_id),
                     seller_id INTEGER NOT NULL REFERENCES Users(user_id),
                     section INTEGER,
                     row INTEGER,
                     seat INTEGER,
                     price INTEGER,
                     sold INTEGER);

