CREATE TABLE Users(user_id INTEGER PRIMARY KEY AUTOINCREMENT,
                   username TEXT,
                   password TEXT,
                   salt TEXT);

CREATE TABLE Schools(school_id INTEGER PRIMARY KEY AUTOINCREMENT,
                     name TEXT);

CREATE TABLE Games(game_id INTEGER PRIMARY KEY AUTOINCREMENT,
                   home_team_id INTEGER REFERENCES Schools(school_id),
                   away_team_id INTEGER REFERENCES Schools(school_id),
                   date TEXT);

CREATE TABLE Tickets(ticket_id INTEGER PRIMARY KEY AUTOINCREMENT,
                     game_id INTEGER REFERENCES Games(game_id),
                     seller_id INTEGER REFERENCES Users(user_id),
                     section INTEGER,
                     row INTEGER,
                     seat INTEGER,
                     price INTEGER,
                     sold INTEGER);

