CREATE SCHEMA erd01;

CREATE SEQUENCE erd01.coordinate_coordinate_id_seq_1;
CREATE SEQUENCE erd01.departure_departure_id_seq;
CREATE SEQUENCE erd01.stop_stop_id_seq;
CREATE SEQUENCE erd01.line_line_id_seq;

-- Tabela Coordinate - Reprezentuje współrzędne jako geolokalizację

CREATE TABLE erd01.coordinate (
    coordinate_id INTEGER NOT NULL DEFAULT nextval('erd01.coordinate_coordinate_id_seq_1'),
    x DOUBLE PRECISION NOT NULL,
    y DOUBLE PRECISION NOT NULL,
    CONSTRAINT coordinate_id PRIMARY KEY (coordinate_id)
);

-- Tabela Departure - Reprezentuje poszczególne godziny odjazdu

CREATE TABLE erd01.departure (
    departure_id INTEGER NOT NULL DEFAULT nextval('erd01.departure_departure_id_seq'),
    departure_time TIME NOT NULL,
    line_stop_id INTEGER NOT NULL,
    CONSTRAINT departure_id PRIMARY KEY (departure_id)
);
COMMENT ON TABLE erd01.departure IS 'Tabela reprezentująca godziny odjazdów';

-- Tabela Stop - Reprezentuje encję przystanku

CREATE TABLE erd01.stop (
    stop_id INTEGER NOT NULL DEFAULT nextval('erd01.stop_stop_id_seq'),
    coordinate_id INTEGER NOT NULL,
    direction INTEGER DEFAULT 1 NOT NULL,
    name VARCHAR NOT NULL,
    CONSTRAINT stop_id PRIMARY KEY (stop_id),
    CONSTRAINT unique_stop_coordinate UNIQUE (stop_id, coordinate_id),
    CONSTRAINT coordinate_stop_fk FOREIGN KEY (coordinate_id)
        REFERENCES erd01.coordinate (coordinate_id)
        ON DELETE CASCADE
);
COMMENT ON TABLE erd01.stop IS 'Tabela reprezentująca przystanek';
COMMENT ON COLUMN erd01.stop.direction IS 'W przypadku gdy są przystanki w dwie strony lub jak np rondo Grunwaldzkie 1-4';

-- Tabela Line - Reprezentuje encję linii

CREATE TABLE erd01.line (
    line_id INTEGER NOT NULL DEFAULT nextval('erd01.line_line_id_seq'),
    name VARCHAR NOT NULL,
    type VARCHAR NOT NULL,
    CONSTRAINT line_id PRIMARY KEY (line_id)
);
COMMENT ON TABLE erd01.line IS 'Tabela reprezentująca poszczególne linie';

-- Tabela Asocjacyjna dla relacji Many To Many Line - Stop

CREATE TABLE erd01.line_stop (
    line_stop_id SERIAL PRIMARY KEY,
    stop_id INTEGER NOT NULL,
    line_id INTEGER NOT NULL,
    departure_id INTEGER NOT NULL,
    sequence_number INTEGER NOT NULL,
    coordinate_id INTEGER NOT NULL,
    CONSTRAINT departure_line_stop_fk FOREIGN KEY (departure_id)
        REFERENCES erd01.departure (departure_id)
        ON DELETE NO ACTION,
    CONSTRAINT stop_line_stop_fk FOREIGN KEY (stop_id, coordinate_id)
        REFERENCES erd01.stop (stop_id, coordinate_id)
        ON DELETE NO ACTION,
    CONSTRAINT line_line_stop_fk FOREIGN KEY (line_id)
        REFERENCES erd01.line (line_id)
        ON DELETE NO ACTION
);
COMMENT ON COLUMN erd01.line_stop.sequence_number IS 'sequence_number - kolejność przystanku na trasie (ważne dla linii dwukierunkowych)';

-- Przypisanie sekwencji do kolumn

ALTER SEQUENCE erd01.coordinate_coordinate_id_seq_1 OWNED BY erd01.coordinate.coordinate_id;
ALTER SEQUENCE erd01.stop_stop_id_seq OWNED BY erd01.stop.stop_id;
ALTER SEQUENCE erd01.departure_departure_id_seq OWNED BY erd01.departure.departure_id;
ALTER SEQUENCE erd01.line_line_id_seq OWNED BY erd01.line.line_id;
