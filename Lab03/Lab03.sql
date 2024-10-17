CREATE SCHEMA lab03;
--SET datestyle TO 'ISO, DMY';

-- ### DDL ###
-- Tworzenie tabeli instytut
CREATE TABLE lab03.instytut (
    instytut_id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    lokal TEXT NOT NULL
);

-- Tworzenie tabeli funkcja
CREATE TABLE lab03.funkcja (
    funkcja_id INTEGER PRIMARY KEY,
    nazwa TEXT UNIQUE NOT NULL,
    min_wynagrodzenia INTEGER NOT NULL CHECK (min_wynagrodzenia > 0),
    max_wynagrodzenia INTEGER NOT NULL CHECK (max_wynagrodzenia > min_wynagrodzenia)
);

-- Tworzenie tabeli wykladowca
CREATE TABLE lab03.wykladowca (
    wykladowca_id INTEGER PRIMARY KEY,
    nazwisko TEXT NOT NULL,
    manager_id INTEGER,
    rok_zatrudnienia INTEGER NOT NULL,
    wynagrodzenie INTEGER CHECK (wynagrodzenie >= 1000),
    instytut_id INTEGER,
    funkcja_id INTEGER, -- tu zle dalem ale dalej nie uzywam tego pola wogole
    FOREIGN KEY (instytut_id) REFERENCES lab03.instytut(instytut_id),
    FOREIGN KEY (funkcja_id) REFERENCES lab03.funkcja(funkcja_id),
    FOREIGN KEY (manager_id) REFERENCES lab03.wykladowca(wykladowca_id) -- relacja samoodwołująca
);

-- Tworzenie tabeli kurs
CREATE TABLE lab03.kurs (
    kurs_id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    start DATE NOT NULL,
    koniec DATE
);

-- Tworzenie tabeli łączącej kursy z wykładowcami (relacja N:M)
CREATE TABLE lab03.wykladowca_kurs (
    wykladowca_id INTEGER,
    kurs_id INTEGER,
    PRIMARY KEY (wykladowca_id, kurs_id),
    FOREIGN KEY (wykladowca_id) REFERENCES lab03.wykladowca(wykladowca_id),
    FOREIGN KEY (kurs_id) REFERENCES lab03.kurs(kurs_id)
);

-- ### DML ###

-- SEEDERS

INSERT INTO lab03.instytut (instytut_id, nazwa, lokal) VALUES
(1, 'Instytut Informatyki', 'Kraków'),
(2, 'Instytut Fizyki', 'Warszawa'),
(3, 'Instytut Mechatroniki', 'Kalisz'),
(4, 'Instytut Odlewnictwa', 'Radom');

INSERT INTO lab03.funkcja (funkcja_id, nazwa, min_wynagrodzenia, max_wynagrodzenia) VALUES
(1, 'Asystent', 1000, 3000),
(2, 'Adiunkt', 3001, 6000),
(3, 'Profesor', 6001, 10000);


INSERT INTO lab03.wykladowca (wykladowca_id, nazwisko, manager_id, rok_zatrudnienia, wynagrodzenie, instytut_id, funkcja_id) VALUES
(1, 'Kowalski', NULL, 2015, 3500, 1, 2),
(2, 'Nowak', 1, 2010, 7000, 1, 3),
(3, 'Wiśniewski', NULL, 2018, 2500, 2, 1),
(4, 'Kaczmarek', 2, 2011, 6200, 2, 3),
(5, 'Radzikowski', NULL, 2015, 3500, 1, 2),
(6, 'Kida', 1, 2010, 8000, 1, 3),
(7, 'Kowalewski', NULL, 2018, 2200, 2, 1),
(8, 'Kaczanowski', 2, 2011, 6100, 2, 3);


INSERT INTO lab03.kurs (kurs_id, nazwa, start, koniec) VALUES
(1, 'Algorytmy', '2023-09-01', '2023-12-15'),
(2, 'Matematyka dyskretna', '2024-10-01', NULL),
(3, 'Bazy Danych I', '2024-10-01', NULL),
(4, 'Bazy Danych II', '2024-02-01', NULL),
(5, 'Grafy', '2022-10-01', '2022-11-01')
;

INSERT INTO lab03.wykladowca_kurs (wykladowca_id, kurs_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2),
(5, 3),
(6, 3),
(7, 4),
(8, 4);




-- QUERIES

-- a) nazwy instytutów i nazwiska pracujących tam  wszystkich wykładowców w kolejności alfabetycznej instytutów

SELECT i.nazwa AS instytut, w.nazwisko
FROM lab03.wykladowca w
JOIN lab03.instytut i ON w.instytut_id = i.instytut_id
ORDER BY i.nazwa, w.nazwisko;

-- b)nazwisko, wynagrodzenie i identyfikator oraz nazwę funkcji wykładowców od najlepiej zarabiającego

SELECT w.nazwisko, w.wynagrodzenie, w.wykladowca_id, f.nazwa AS funkcja
FROM lab03.wykladowca w, lab03.funkcja f
-- JOIN lab03.funkcja f ON w.funkcja_id = f.funkcja_id
WHERE f.min_wynagrodzenia <= w.wynagrodzenie and f.max_wynagrodzenia >= w.wynagrodzenie
ORDER BY w.wynagrodzenie DESC
LIMIT 1;



-- c) nazwiska wykładowców zatrudnionych w wybranej lokalizacji

SELECT w.nazwisko
FROM lab03.wykladowca w JOIN lab03.instytut i ON w.instytut_id = i.instytut_id
WHERE i.lokal ILIKE 'Kraków';

-- d) nazwa kursu, nazwiska wykładowców biorących udział w tym kursie  posortowane według nazwy kursu i nazwiska wykładowcy

SELECT k.nazwa AS kurs, w.nazwisko
FROM lab03.wykladowca w
JOIN lab03.wykladowca_kurs wk ON w.wykladowca_id = wk.wykladowca_id
JOIN lab03.kurs k ON wk.kurs_id = k.kurs_id
ORDER BY k.nazwa, w.nazwisko;


-- e) dla wybranego wykładowcy wypisać nazwy zakończonych kursów, w których brał udział

SELECT k.nazwa AS kurs
FROM lab03.kurs k
JOIN lab03.wykladowca_kurs wk ON k.kurs_id = wk.kurs_id
WHERE wk.wykladowca_id = 1 AND k.koniec IS NOT NULL;