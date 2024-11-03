CREATE SCHEMA erd01;

CREATE TABLE erd01.Line (
    line_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(10) CHECK (type IN ('bus', 'tram')) NOT NULL
);

CREATE TABLE erd01.Stop (
    stop_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    direction VARCHAR(50) NOT NULL
);

CREATE TABLE erd01.Line_Stop (
    line_stop_id SERIAL PRIMARY KEY,
    line_id INT REFERENCES erd01.Line(line_id),
    stop_id INT REFERENCES erd01.Stop(stop_id),
    sequence_number INT NOT NULL
);

CREATE TABLE erd01.Departure_Time (
    departure_id SERIAL PRIMARY KEY,
    line_stop_id INT REFERENCES erd01.Line_Stop(line_stop_id),
    departure_time TIME NOT NULL
);


-- Linie
INSERT INTO erd01.Line (name, type) VALUES
('Autobus 123', 'bus'),
('Tramwaj 5', 'tram');

-- Przystanki
INSERT INTO erd01.Stop (name, direction) VALUES
('Dworzec', 'kierunek Centrum'),
('Dworzec', 'kierunek Peron');

-- Przystanki na liniach
INSERT INTO erd01.Line_Stop (line_id, stop_id, sequence_number) VALUES
(1, 1, 1),
(1, 2, 2);

-- Czasy odjazdów
INSERT INTO erd01.Departure_Time (line_stop_id, departure_time) VALUES
(1, '14:30:00'),
(2, '15:00:00');


-- ### QUERY ###

-- 1. Znajdź linie zatrzymujące się na danym przystanku:
SELECT l.name, l.type
FROM erd01.Line l
JOIN erd01.Line_Stop ls ON l.line_id = ls.line_id
WHERE ls.stop_id = (
    SELECT stop_id
    FROM erd01.Stop
    WHERE name = 'Dworzec' AND direction = 'kierunek Centrum'
);


-- 2. Znajdź czasy odjazdów dla wybranego przystanku i linii:
SELECT dt.departure_time
FROM erd01.Departure_Time dt
JOIN erd01.Line_Stop ls ON dt.line_stop_id = ls.line_stop_id
WHERE ls.line_id = (
        SELECT line_id
        FROM erd01.Line
        WHERE name = 'Autobus 123'
    ) AND ls.stop_id = (
        SELECT stop_id
        FROM erd01.Stop
        WHERE name = 'Dworzec' AND direction = 'kierunek Centrum'
    );


-- 3. Znajdź przystanki i czasy odjazdów dla wybranej linii:
SELECT s.name, s.direction, dt.departure_time
FROM erd01.Line_Stop ls
JOIN erd01.Stop s ON ls.stop_id = s.stop_id
JOIN erd01.Departure_Time dt ON ls.line_stop_id = dt.line_stop_id
WHERE ls.line_id = (
    SELECT line_id
    FROM erd01.Line
    WHERE name = 'Autobus 123'
)
ORDER BY ls.sequence_number;
