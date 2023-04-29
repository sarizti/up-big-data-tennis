DROP TABLE IF EXISTS report;
CREATE TABLE report(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ATP, Location, Tournament, Date, Series, Court, Surface, Round, "Best of", Winner, Loser, WRank, LRank, WPts, LPts, W1, L1, W2, L2, W3, L3, W4, L4, W5, L5,
    Comment, pl1_flag, pl1_year_pro, pl1_weight, pl1_height, pl1_hand, pl2_flag, pl2_year_pro, pl2_weight, pl2_height, pl2_hand
);

DROP TABLE IF EXISTS tournaments;
CREATE TABLE tournaments( -- the name of the tournament, not necessarily on the same location every time.
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL, -- 'Tournament' e.g. 'Melbourne Summer Set'
    created_at DATE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

DROP TABLE IF EXISTS locations;
CREATE TABLE locations( -- place where the tournament happened, has many courts, belongs to N tournaments
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL, -- 'Location' e.g. 'Melbourne'
    created_at DATE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

DROP TABLE IF EXISTS events;
CREATE TABLE events( -- combination of tournament + location
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    year INTEGER NOT NULL, -- contained in 'Date'
    atp INTEGER NOT NULL, -- 'ATP' e.g. 1|2|3. looks like the number of the tournament in the year
    series TEXT NOT NULL, -- 'Series' e.g. ATP250
    tournament_id INTEGER REFERENCES tournaments(id) NOT NULL,
    location_id INTEGER REFERENCES locations(id) NOT NULL,
    created_at DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE (year, atp)
);
CREATE INDEX events__tournaments ON events(tournament_id);
CREATE INDEX events__locations ON events(location_id);

DROP TABLE IF EXISTS courts;
CREATE TABLE courts( -- each location has different types of courts
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    court TEXT NOT NULL CHECK(court in ('Indoor', 'Outdoor')), -- 'Court'
    surface TEXT NOT NULL CHECK(surface in ('Hard', 'Grass', 'Clay', 'Carpet')), -- 'Surface'
    location_id INTEGER REFERENCES locations(id),
    created_at DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE (court, surface, location_id)
);
CREATE INDEX courts__locations ON courts(location_id);

DROP TABLE IF EXISTS players;
CREATE TABLE players( -- feeds both the Winner and Loser columns in the final report
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL, -- 'Winner'|'Loser' e.g. 'Djere L.'
    flag TEXT, -- 'pl1_flag' e.g. 'KOR'|'BRA'
    year_pro INTEGER, -- 'pl1_year_pro' e.g. 2015
    weight INTEGER, -- 'pl1_weight' e.g. 72
    height INTEGER, -- 'pl1_height' e.g.180
    hand TEXT CHECK(hand in ('Right-Handed', 'Left-Handed')), -- 'pl1_hand'
    created_at DATE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

DROP TABLE IF EXISTS matches;
CREATE TABLE matches(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date DATE NOT NULL, -- 'Date' comes formatted as 26/01/2022 and needs to be converted to 2022-01-26
    round TEXT NOT NULL, -- 'Round' e.g. '1st Round'
    best_of INTEGER NOT NULL, -- 'Best of' e.g. 3
    comment TEXT NOT NULL, -- 'Comment' e.g. 'completed'|'retired'
    event_id INTEGER REFERENCES events(id) NOT NULL,
    court_id INTEGER REFERENCES courts(id) NOT NULL,
    created_at DATE DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE INDEX matches__events ON matches(event_id);
CREATE INDEX matches__courts ON matches(court_id);

DROP TABLE IF EXISTS players_matches;
CREATE TABLE players_matches(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    new_rank INTEGER, -- 'WRank'|'LRank' e.g. 52
    new_points INTEGER, -- 'WPts'|'LPts' e.g. 1131
    win INTEGER NOT NULL, -- TRUE|FALSE
    match_id INTEGER REFERENCES matches(id) NOT NULL,
    player_id INTEGER REFERENCES players(id) NOT NULL,
    created_at DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE (match_id, player_id)
);
CREATE INDEX players_matches__matches ON players_matches(match_id);
CREATE INDEX players_matches__players ON players_matches(player_id);

DROP TABLE IF EXISTS players_matches_sets;
CREATE TABLE players_matches_sets(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    players_matches_id INTEGER REFERENCES players_matches(id) NOT NULL,
    set_num INTEGER NOT NULL, -- 'W1'|'L2'|... e.g. 1-5
    games INTEGER NOT NULL, -- 1-7
    created_at DATE DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE INDEX players_matches_sets__players_matches ON players_matches_sets(players_matches_id);
