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
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    team_id INTEGER NOT NULL REFERENCES erd03.Team(id)
);

CREATE TABLE erd03.Match (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    home_team_id INTEGER NOT NULL REFERENCES erd03.Team(id),
    away_team_id INTEGER NOT NULL REFERENCES erd03.Team(id),
    home_team_score INTEGER DEFAULT 0,
    away_team_score INTEGER DEFAULT 0
);
ALTER TABLE erd03.Match
    ADD COLUMN sport_type VARCHAR(50) NOT NULL CHECK (sport_type IN ('football', 'volleyball', 'basketball')) default 'football';


CREATE TABLE erd03.MatchEvent (
    id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL REFERENCES erd03.Match(id),
    player_id INTEGER REFERENCES erd03.Player(id),
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN ('goal', 'red_card')),
    timestamp TIMESTAMP NOT NULL
);

CREATE TABLE erd03.MatchLineup (
    id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL REFERENCES erd03.Match(id),
    team_id INTEGER NOT NULL REFERENCES erd03.Team(id),
    player_id INTEGER NOT NULL REFERENCES erd03.Player(id)
);

CREATE VIEW ValidMatchLineups AS
SELECT
    m.id AS match_id,
    m.sport_type,
    ml.team_id,
    COUNT(ml.player_id) AS player_count,
    CASE
        WHEN m.sport_type = 'football' AND COUNT(ml.player_id) = 11 THEN TRUE
        WHEN m.sport_type = 'volleyball' AND COUNT(ml.player_id) = 6 THEN TRUE
        WHEN m.sport_type = 'basketball' AND COUNT(ml.player_id) = 5 THEN TRUE
        ELSE FALSE
    END AS is_valid
FROM erd03.Match m
JOIN erd03.MatchLineup ml ON ml.match_id = m.id
GROUP BY m.id, m.sport_type, ml.team_id;

-- Trigger do walidacji lineupu

CREATE OR REPLACE FUNCTION validate_match_lineup()
RETURNS TRIGGER AS $$
DECLARE
    player_count INTEGER;
    max_players INTEGER;
BEGIN
    -- Pobierz maksymalną liczbę zawodników dla dyscypliny
    SELECT CASE
        WHEN sport_type = 'football' THEN 11
        WHEN sport_type = 'volleyball' THEN 6
        WHEN sport_type = 'basketball' THEN 5
    END INTO max_players
    FROM erd03.Match
    WHERE id = NEW.match_id;

    -- Policz zawodników w składzie dla drużyny w danym meczu
    SELECT COUNT(*)
    INTO player_count
    FROM erd03.MatchLineup
    WHERE match_id = NEW.match_id AND team_id = NEW.team_id;

    -- Sprawdź, czy dodanie nowego zawodnika przekroczy limit
    IF player_count + 1 > max_players THEN
        RAISE EXCEPTION 'Team (%) lineup exceeds maximum allowed players (%) Current: (%).', NEW.team_id,max_players,player_count;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER check_match_lineup
BEFORE INSERT ON erd03.MatchLineup
FOR EACH ROW
EXECUTE FUNCTION validate_match_lineup();




-- Wypełnianie tabel przykładowymi danymi
INSERT INTO erd03.Team (name) VALUES
('Team A'),
('Team B'),
('Team C');

INSERT INTO erd03.Player (firstName, lastName, team_id) VALUES
('Player A', 'Player 1', 1),
('Player B', 'Player 2',1),
('Player C','Player 3', 1),
('Player D','Player 4', 1),
('Player E','Player 5', 1),
('Player F','Player 6', 1),
('Player G','Player 7', 1),
('Player H', 'Player 8',1),
('Player I','Player 9', 1),
('Player J', 'Player 10',1),
('Player K','Player 11', 1);
INSERT INTO erd03.Player (firstName, lastName, team_id) VALUES
('Player L', 'Player 1', 2),
('Player M', 'Player 2',2),
('Player N','Player 3', 2),
('Player O','Player 4', 2),
('Player P','Player 5', 2),
('Player R','Player 6', 2),
('Player S','Player 7', 2),
('Player T', 'Player 8',2),
('Player U','Player 9', 2),
('Player W', 'Player 10',2),
('Player X','Player 11', 2);
INSERT INTO erd03.Player (firstName, lastName, team_id) VALUES
('Player AA', 'Player 1', 3),
('Player BB', 'Player 2',3),
('Player CC','Player 3', 3),
('Player DD','Player 4', 3),
('Player EE','Player 5', 3),
('Player FF','Player 6', 3),
('Player GG','Player 7', 3),
('Player HH', 'Player 8',3),
('Player II','Player 9', 3),
('Player JJ', 'Player 10',3),
('Player KK','Player 11', 3),
('Dodatkowy','Player 12', 3);

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

-- dodawanie lineupów = 1 mecz = 2x team (11) = 22 -> ok

INSERT INTO erd03.MatchLineup (match_id, team_id, player_id)
VALUES (1, 1, 1),
       (1, 1, 2),
       (1, 1, 3),
       (1, 1, 4),
       (1, 1, 5),
       (1, 1, 6),
       (1, 1, 7),
       (1, 1, 8),
       (1, 1, 9),
       (1, 1, 10),
       (1, 1, 11);
INSERT INTO erd03.MatchLineup (match_id, team_id, player_id)
VALUES (1, 2, 12),
       (1, 2, 13),
       (1, 2, 14),
       (1, 2, 15),
       (1, 2, 16),
       (1, 2, 17),
       (1, 2, 18),
       (1, 2, 19),
       (1, 2, 20),
       (1, 2, 21),
       (1, 2, 22);

-- PROBA DODANIA 12 ZAWODNIKA [P0001] ERROR: Team (2) lineup exceeds maximum allowed players (11) Current: (11). Where: PL/ pgSQL function validate_match_lineup() line 23 at RAISE
-- INSERT INTO erd03.MatchLineup (match_id, team_id, player_id)
-- VALUES (1, 2, 23);


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
    p.firstName AS player_name,
    p.lastName AS player_lastName,
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
    p.firstName,
    p.lastName,
    t.name AS team_name,
    COUNT(CASE WHEN me.event_type = 'goal' THEN 1 END) AS goals_scored,
    COUNT(CASE WHEN me.event_type = 'red_card' THEN 1 END) AS red_cards
FROM erd03.Player p
JOIN erd03.Team t ON t.id = p.team_id
LEFT JOIN erd03.MatchEvent me ON me.player_id = p.id
GROUP BY p.id, p.firstName, p.lastName, t.name;



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
