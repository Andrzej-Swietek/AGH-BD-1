CREATE SCHEMA lab11;


-- ### DDL ###


-- Tworzenie tabeli instytut
CREATE TABLE lab11.instytut
(
    instytut_id INTEGER PRIMARY KEY,
    nazwa       TEXT NOT NULL,
    lokal       TEXT NOT NULL
);

-- Tworzenie tabeli funkcja
CREATE TABLE lab11.funkcja
(
    funkcja_id        INTEGER PRIMARY KEY,
    nazwa             TEXT UNIQUE NOT NULL,
    min_wynagrodzenia INTEGER     NOT NULL CHECK (min_wynagrodzenia > 0),
    max_wynagrodzenia INTEGER     NOT NULL CHECK (max_wynagrodzenia > min_wynagrodzenia)
);

-- Tworzenie tabeli wykladowca
CREATE TABLE lab11.wykladowca
(
    wykladowca_id    INTEGER PRIMARY KEY,
    nazwisko         TEXT    NOT NULL,
    manager_id       INTEGER,
    rok_zatrudnienia INTEGER NOT NULL,
    wynagrodzenie    INTEGER CHECK (wynagrodzenie >= 1000),
    instytut_id      INTEGER,
    FOREIGN KEY (instytut_id) REFERENCES lab11.instytut (instytut_id),
    FOREIGN KEY (manager_id) REFERENCES lab11.wykladowca (wykladowca_id) -- relacja samoodwołująca
);

-- Tworzenie tabeli kurs
CREATE TABLE lab11.kurs
(
    kurs_id INTEGER PRIMARY KEY,
    nazwa   TEXT NOT NULL,
    start   DATE NOT NULL,
    koniec  DATE
);

-- Tworzenie tabeli łączącej kursy z wykładowcami (relacja N:M)
CREATE TABLE lab11.wykladowca_kurs
(
    wykladowca_id INTEGER,
    kurs_id       INTEGER,
    PRIMARY KEY (wykladowca_id, kurs_id),
    FOREIGN KEY (wykladowca_id) REFERENCES lab11.wykladowca (wykladowca_id),
    FOREIGN KEY (kurs_id) REFERENCES lab11.kurs (kurs_id)
);


-- tabela koszty
create table lab11.koszty
(
    wpis_id    serial,
    kurs_id    integer,
    wykladowcy integer not null, --ilosc wykladowcoa w kursie
    koszt_plus numeric(7, 2),    --kwota, o która koszt kursu przekracza wartosc graniczna
    CONSTRAINT koszt_pk PRIMARY KEY (wpis_id)
);


-- tabela nagrody
create table lab11.nagrody
(
    wpis_id       serial PRIMARY KEY,
    wykladowca_id integer,
    nagroda       numeric(7, 2),
    data          date --data przyznania nagrody, czyli moment wykonania funkcji
);



-- ### DML ###


-- SEEDERS

INSERT INTO lab11.instytut (instytut_id, nazwa, lokal)
VALUES (1, 'Instytut Informatyki', 'Kraków'),
       (2, 'Instytut Fizyki', 'Warszawa'),
       (3, 'Instytut Mechatroniki', 'Kalisz'),
       (4, 'Instytut Odlewnictwa', 'Radom');

INSERT INTO lab11.funkcja (funkcja_id, nazwa, min_wynagrodzenia, max_wynagrodzenia)
VALUES (1, 'Asystent', 1000, 3000),
       (2, 'Adiunkt', 3001, 6000),
       (3, 'Profesor', 6001, 10000);


INSERT INTO lab11.wykladowca (wykladowca_id, nazwisko, manager_id, rok_zatrudnienia, wynagrodzenie, instytut_id)
VALUES (1, 'Kowalski', NULL, 2015, 3500, 1),
       (2, 'Nowak', 1, 2010, 7000, 1),
       (3, 'Wiśniewski', NULL, 2018, 2500, 2),
       (4, 'Kaczmarek', 2, 2011, 6200, 2),
       (5, 'Radzikowski', NULL, 2015, 3501, 1),
       (6, 'Kida', 1, 2010, 8000, 1),
       (7, 'Kowalewski', NULL, 2018, 2200, 2),
       (8, 'Kaczanowski', 2, 2011, 6100, 2),
       (9, 'Korczyński', 2, 2012, 6100, 1),
       (10, 'Buchalik', NULL, 2023, 4000, 3),
       (11, 'Porwoł', NULL, 2023, 4000, 4);



INSERT INTO lab11.kurs (kurs_id, nazwa, start, koniec)
VALUES (1, 'Algorytmy', '2023-09-01', '2023-12-15'),
       (2, 'Matematyka dyskretna', '2024-10-01', NULL),
       (3, 'Bazy Danych I', '2024-10-01', NULL),
       (4, 'Bazy Danych II', '2024-02-01', NULL),
       (5, 'Grafy', '2022-10-01', '2022-11-01')
;

INSERT INTO lab11.wykladowca_kurs (wykladowca_id, kurs_id)
VALUES (1, 1),
       (2, 1),
       (3, 2),
       (4, 2),
       (5, 3),
       (6, 3),
       (7, 4),
       (8, 4),
       (3, 1),
       (3, 3);

ALTER TABLE lab11.wykladowca
    ADD COLUMN premia REAL DEFAULT 0 CHECK (premia BETWEEN 0.0 AND 100.0);


----------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION lab11.get_courses_for_lecturer(p_lecturer_id INT)
    RETURNS TABLE
            (
                course_name  TEXT,
                start_date   DATE,
                is_completed BOOLEAN
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT k.nazwa, k.start, k.koniec IS NOT NULL AS is_completed
        FROM lab11.kurs k
                 JOIN lab11.wykladowca_kurs wk ON k.kurs_id = wk.kurs_id
        WHERE wk.wykladowca_id = p_lecturer_id;
END;
$$ LANGUAGE plpgsql;
