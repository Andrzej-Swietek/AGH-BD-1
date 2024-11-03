-- Wypełnienie danymi tabeli Coordinate
INSERT INTO erd01.coordinate (x, y) VALUES (50.061, 19.938);  -- Kraków, Rynek
INSERT INTO erd01.coordinate (x, y) VALUES (50.065, 19.945);  -- Kraków, Wawel
INSERT INTO erd01.coordinate (x, y) VALUES (50.067, 19.924);  -- Kraków, Kazimierz
INSERT INTO erd01.coordinate (x, y) VALUES (50.055, 19.929);  -- Kraków, Zakrzówek
INSERT INTO erd01.coordinate (x, y) VALUES (50.054, 19.944);  -- Kraków, Bulwary Wiślane
INSERT INTO erd01.coordinate (x, y) VALUES (50.059, 19.940);  -- Kraków, Most Grunwaldzki

-- Wypełnienie danymi tabeli Stop
INSERT INTO erd01.stop (coordinate_id, direction, name) VALUES (1, 1, 'Rynek Główny');
INSERT INTO erd01.stop (coordinate_id, direction, name) VALUES (2, 1, 'Wawel');
INSERT INTO erd01.stop (coordinate_id, direction, name) VALUES (3, 1, 'Kazimierz');
INSERT INTO erd01.stop (coordinate_id, direction, name) VALUES (4, 2, 'Zakrzówek');
INSERT INTO erd01.stop (coordinate_id, direction, name) VALUES (5, 1, 'Bulwary Wiślane');
INSERT INTO erd01.stop (coordinate_id, direction, name) VALUES (6, 1, 'Most Grunwaldzki');

-- Wypełnienie danymi tabeli Line
INSERT INTO erd01.line (name, type) VALUES ('Linia 1', 'Tramwaj');
INSERT INTO erd01.line (name, type) VALUES ('Linia 2', 'Tramwaj');
INSERT INTO erd01.line (name, type) VALUES ('Linia 3', 'Autobus');
INSERT INTO erd01.line (name, type) VALUES ('Linia 4', 'Autobus');

-- Wypełnienie danymi tabeli Departure
INSERT INTO erd01.departure (departure_time, line_stop_id) VALUES ('08:00', 1);
INSERT INTO erd01.departure (departure_time, line_stop_id) VALUES ('08:15', 2);
INSERT INTO erd01.departure (departure_time, line_stop_id) VALUES ('08:30', 3);
INSERT INTO erd01.departure (departure_time, line_stop_id) VALUES ('08:45', 4);
INSERT INTO erd01.departure (departure_time, line_stop_id) VALUES ('09:00', 5);
INSERT INTO erd01.departure (departure_time, line_stop_id) VALUES ('09:15', 6);
INSERT INTO erd01.departure (departure_time, line_stop_id) VALUES ('09:30', 7);
INSERT INTO erd01.departure (departure_time, line_stop_id) VALUES ('09:45', 8);
INSERT INTO erd01.departure (departure_time, line_stop_id) VALUES ('10:00', 9);
INSERT INTO erd01.departure (departure_time, line_stop_id) VALUES ('10:15', 10);

-- Wypełnienie danymi tabeli Line_Stop
INSERT INTO erd01.line_stop (line_stop_id, stop_id, line_id, departure_id, sequence_number, coordinate_id) VALUES (1, 1, 1, 1, 1, 1);  -- Rynek Główny, Linia 1
INSERT INTO erd01.line_stop (line_stop_id, stop_id, line_id, departure_id, sequence_number, coordinate_id) VALUES (2, 2, 1, 2, 2, 2);  -- Wawel, Linia 1
INSERT INTO erd01.line_stop (line_stop_id, stop_id, line_id, departure_id, sequence_number, coordinate_id) VALUES (3, 3, 2, 3, 1, 3);  -- Kazimierz, Linia 2
INSERT INTO erd01.line_stop (line_stop_id, stop_id, line_id, departure_id, sequence_number, coordinate_id) VALUES (4, 4, 3, 4, 1, 4);  -- Zakrzówek, Linia 3
INSERT INTO erd01.line_stop (line_stop_id, stop_id, line_id, departure_id, sequence_number, coordinate_id) VALUES (5, 5, 1, 5, 3, 5);  -- Bulwary Wiślane, Linia 1
INSERT INTO erd01.line_stop (line_stop_id, stop_id, line_id, departure_id, sequence_number, coordinate_id) VALUES (6, 6, 2, 6, 2, 6);  -- Most Grunwaldzki, Linia 2
INSERT INTO erd01.line_stop (line_stop_id, stop_id, line_id, departure_id, sequence_number, coordinate_id) VALUES (7, 1, 4, 7, 1, 1);  -- Rynek Główny, Linia 4
INSERT INTO erd01.line_stop (line_stop_id, stop_id, line_id, departure_id, sequence_number, coordinate_id) VALUES (8, 2, 4, 8, 2, 2);  -- Wawel, Linia 4
INSERT INTO erd01.line_stop (line_stop_id, stop_id, line_id, departure_id, sequence_number, coordinate_id) VALUES (9, 3, 4, 9, 3, 3);  -- Kazimierz, Linia 4
INSERT INTO erd01.line_stop (line_stop_id, stop_id, line_id, departure_id, sequence_number, coordinate_id) VALUES (10, 5, 3, 10, 2, 5);  -- Bulwary Wiślane, Linia 3
