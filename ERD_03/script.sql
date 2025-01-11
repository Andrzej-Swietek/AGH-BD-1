DROP SCHEMA IF EXISTS erd03 CASCADE;
CREATE SCHEMA erd03;

-- Tworzenie tabel
CREATE TABLE erd03.Team (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    points INTEGER DEFAULT 0
);

CREATE TABLE erd03.Player (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    team_id INTEGER NOT NULL REFERENCES erd03.Team(id),
    goals_scored INTEGER DEFAULT 0,
    red_card BOOLEAN DEFAULT FALSE
);

CREATE TABLE erd03.Match (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    home_team_id INTEGER NOT NULL REFERENCES erd03.Team(id),
    away_team_id INTEGER NOT NULL REFERENCES erd03.Team(id),
    home_team_score INTEGER DEFAULT 0,
    away_team_score INTEGER DEFAULT 0
);

CREATE TABLE erd03.MatchEvent (
    id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL REFERENCES erd03.Match(id),
    player_id INTEGER REFERENCES erd03.Player(id),
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN ('goal', 'red_card')),
    timestamp TIMESTAMP NOT NULL
);

-- Wypełnianie tabel przykładowymi danymi
INSERT INTO erd03.Team (name) VALUES
('Team A'),
('Team B'),
('Team C');

INSERT INTO erd03.Player (name, team_id) VALUES
('Player 1', 1),
('Player 2', 1),
('Player 3', 1),
('Player 4', 2),
('Player 5', 2),
('Player 6', 2),
('Player 7', 3),
('Player 8', 3),
('Player 9', 3);

INSERT INTO erd03.Match (date, home_team_id, away_team_id, home_team_score, away_team_score) VALUES
('2025-01-01', 1, 2, 3, 2),
('2025-01-02', 2, 3, 1, 1),
('2025-01-03', 1, 3, 2, 3);

INSERT INTO erd03.MatchEvent (match_id, player_id, event_type, timestamp) VALUES
(1, 1, 'goal', '2025-01-01 14:00:00'),
(1, 2, 'goal', '2025-01-01 14:15:00'),
(1, 4, 'goal', '2025-01-01 14:30:00'),
(2, 5, 'goal', '2025-01-02 16:00:00'),
(2, 7, 'goal', '2025-01-02 16:15:00'),
(3, 8, 'goal', '2025-01-03 18:00:00'),
(3, 1, 'red_card', '2025-01-03 18:15:00');




-- Zapytania SELECT


-- 1. Informacje o meczu (czerwone kartki, bramki, wynik)
SELECT
    m.id AS match_id,
    m.date,
    ht.name AS home_team,
    at.name AS away_team,
    m.home_team_score,
    m.away_team_score,
    e.player_id,
    p.name AS player_name,
    e.event_type,
    e.timestamp
FROM erd03.Match m
LEFT JOIN erd03.MatchEvent e ON e.match_id = m.id
LEFT JOIN erd03.Player p ON p.id = e.player_id
LEFT JOIN erd03.Team ht ON ht.id = m.home_team_id
LEFT JOIN erd03.Team at ON at.id = m.away_team_id;



-- 2. Informacje o piłkarzu (strzelone bramki, czy ma czerwoną kartkę)
SELECT
    p.id AS player_id,
    p.name,
    t.name AS team_name,
    p.goals_scored,
    p.red_card
FROM erd03.Player p
JOIN erd03.Team t ON t.id = p.team_id;



-- 3. Tabela drużyn (punkty)
SELECT
    t.id AS team_id,
    t.name AS team_name,
    COUNT(CASE WHEN m.home_team_id = t.id AND m.home_team_score > m.away_team_score THEN 1 END) * 3 +
    COUNT(CASE WHEN m.away_team_id = t.id AND m.away_team_score > m.home_team_score THEN 1 END) * 3 +
    COUNT(CASE WHEN (m.home_team_id = t.id OR m.away_team_id = t.id) AND m.home_team_score = m.away_team_score THEN 1 END) AS total_points
FROM erd03.Team t
LEFT JOIN erd03.Match m ON m.home_team_id = t.id OR m.away_team_id = t.id
GROUP BY t.id, t.name
ORDER BY total_points DESC;
