CREATE SCHEMA lab06;


-- ### DDL ###


-- Tworzenie tabeli instytut
CREATE TABLE lab06.instytut (
    instytut_id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    lokal TEXT NOT NULL
);

-- Tworzenie tabeli funkcja
CREATE TABLE lab06.funkcja (
    funkcja_id INTEGER PRIMARY KEY,
    nazwa TEXT UNIQUE NOT NULL,
    min_wynagrodzenia INTEGER NOT NULL CHECK (min_wynagrodzenia > 0),
    max_wynagrodzenia INTEGER NOT NULL CHECK (max_wynagrodzenia > min_wynagrodzenia)
);

-- Tworzenie tabeli wykladowca
CREATE TABLE lab06.wykladowca (
    wykladowca_id INTEGER PRIMARY KEY,
    nazwisko TEXT NOT NULL,
    manager_id INTEGER,
    rok_zatrudnienia INTEGER NOT NULL,
    wynagrodzenie INTEGER CHECK (wynagrodzenie >= 1000),
    instytut_id INTEGER,
    FOREIGN KEY (instytut_id) REFERENCES lab06.instytut(instytut_id),
    FOREIGN KEY (manager_id) REFERENCES lab06.wykladowca(wykladowca_id) -- relacja samoodwołująca
);

-- Tworzenie tabeli kurs
CREATE TABLE lab06.kurs (
    kurs_id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    start DATE NOT NULL,
    koniec DATE
);

-- Tworzenie tabeli łączącej kursy z wykładowcami (relacja N:M)
CREATE TABLE lab06.wykladowca_kurs (
    wykladowca_id INTEGER,
    kurs_id INTEGER,
    PRIMARY KEY (wykladowca_id, kurs_id),
    FOREIGN KEY (wykladowca_id) REFERENCES lab06.wykladowca(wykladowca_id),
    FOREIGN KEY (kurs_id) REFERENCES lab06.kurs(kurs_id)
);


-- ### DML ###


-- SEEDERS

INSERT INTO lab06.instytut (instytut_id, nazwa, lokal) VALUES
(1, 'Instytut Informatyki', 'Kraków'),
(2, 'Instytut Fizyki', 'Warszawa'),
(3, 'Instytut Mechatroniki', 'Kalisz'),
(4, 'Instytut Odlewnictwa', 'Radom');

INSERT INTO lab06.funkcja (funkcja_id, nazwa, min_wynagrodzenia, max_wynagrodzenia) VALUES
(1, 'Asystent', 1000, 3000),
(2, 'Adiunkt', 3001, 6000),
(3, 'Profesor', 6001, 10000);


INSERT INTO lab06.wykladowca (wykladowca_id, nazwisko, manager_id, rok_zatrudnienia, wynagrodzenie, instytut_id) VALUES
(1, 'Kowalski', NULL, 2015, 3500, 1),
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




INSERT INTO lab06.kurs (kurs_id, nazwa, start, koniec) VALUES
(1, 'Algorytmy', '2023-09-01', '2023-12-15'),
(2, 'Matematyka dyskretna', '2024-10-01', NULL),
(3, 'Bazy Danych I', '2024-10-01', NULL),
(4, 'Bazy Danych II', '2024-02-01', NULL),
(5, 'Grafy', '2022-10-01', '2022-11-01')
;

INSERT INTO lab06.wykladowca_kurs (wykladowca_id, kurs_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2),
(5, 3),
(6, 3),
(7, 4),
(8, 4),
(3, 1),
(3, 3);




-- a) Proszę zapisać kwerendę krzyżową (CASE) tworzącą raport w postaci

-- || instytut | kurs_1                         | kurs_2                        | ...
-- || nazwa_1  | ilosc wykladowcow z nazwa_1    | ilosc wykladowcow z nazwa_1   | ...
-- ||          | ktorzy sa w kursie 1           | ktorzy sa w kursie 2          | ...
-- || nazwa_2  | ilosc wykladowcow z nazwa_2    | ilosc wykladowcow z nazwa_2   | ...
-- ||          | ktorzy sa w kursie 1           | ktorzy sa w kursie 2          | ...

SELECT
    instytut.nazwa AS instytut,
    SUM(CASE WHEN kurs.kurs_id = 1 THEN 1 ELSE 0 END) AS kurs_1,
    SUM(CASE WHEN kurs.kurs_id = 2 THEN 1 ELSE 0 END) AS kurs_2,
    SUM(CASE WHEN kurs.kurs_id = 3 THEN 1 ELSE 0 END) AS kurs_3,
    SUM(CASE WHEN kurs.kurs_id = 4 THEN 1 ELSE 0 END) AS kurs_4,
    SUM(CASE WHEN kurs.kurs_id = 5 THEN 1 ELSE 0 END) AS kurs_5
FROM lab06.instytut instytut
    JOIN lab06.wykladowca wykladowca ON wykladowca.instytut_id = instytut.instytut_id
    JOIN lab06.wykladowca_kurs wyk_kurs ON wyk_kurs.wykladowca_id = wykladowca.wykladowca_id
    JOIN lab06.kurs kurs ON wyk_kurs.kurs_id = kurs.kurs_id
GROUP BY instytut.nazwa;


-- b) Proszę zapisać kwerendę z wyrażeniem tabelarycznym (CTE) zwracająca zestawienie w ile razy wykładowcy z danego instytutu prowadzili zajęcia w poszczególnym kursie (nazwa_instytutu, kurs, ilosc)

WITH CourseCounts AS (
    SELECT
        instytut.nazwa AS nazwa_instytutu,
        kurs.nazwa AS kurs,
        COUNT(*) AS ilosc
    FROM lab06.instytut instytut
        JOIN lab06.wykladowca wykladowca ON wykladowca.instytut_id = instytut.instytut_id
        JOIN lab06.wykladowca_kurs wyk_kurs ON wyk_kurs.wykladowca_id = wykladowca.wykladowca_id
        JOIN lab06.kurs kurs ON wyk_kurs.kurs_id = kurs.kurs_id
    GROUP BY instytut.nazwa, kurs.nazwa
)
SELECT * FROM CourseCounts;



-- Kolejne zapytania odnoszą się do tabeli STAFF


CREATE TABLE lab06.staff ( empno INT, empname VARCHAR(20), mgrno INT ) ;

INSERT INTO lab06.staff
VALUES ( 100, 'Kowalski',    null),
                   ( 101, 'Jasny',      100),
                   ( 102, 'Ciemny',     101),
                   ( 103, 'Szary',     102),
                   ( 104, 'Bury',    101),
                   ( 105, 'Cienki',    104),
                   ( 106, 'Dlugi', 100),
                   ( 107, 'Stary',       106),
                   ( 108, 'Mlody',   106),
                   ( 109, 'Bialy',    107),
                   ( 110, 'Sztuka',      109),
                   ( 111, 'Czarny',       110),
                   ( 112, 'Nowy',     110),
                   ( 113, 'Sredni', 110),
                   ( 114, 'Jeden',      100),
                   ( 115, 'Drugi',    114),
                   ( 116, 'Ostatni',       115),
                   ( 117, 'Lewy',   115)  ;


-- c)  nazwisko pracownika i jego przełożonego
SELECT
    e.empno AS "emp_no" ,
    e.empname AS "emp_name",
    m.empno AS "mgr_no",
    m.empname AS "mgr_name"
FROM lab06.staff e
    JOIN lab06.staff m ON e.mgrno = m.empno;


-- d) nazwisko pracownika, nazwisko bezpośredniego przełożonego i poziom w hierarchii
WITH RECURSIVE hierarchia AS(
    SELECT
        empno,
        empname,
        mgrno,
        1 AS level,
        CAST(NULL AS VARCHAR(20)) AS mgr_name
    FROM lab06.staff
        WHERE mgrno IS NULL

    UNION ALL

    SELECT
        s.empno,
        s.empname,
        s.mgrno,
        h.level + 1,
        h.empname AS mgr_name
    FROM lab06.staff s
        JOIN hierarchia h ON s.mgrno=h.empno
) SELECT
      empname AS "emp_name",
      (
        CASE
          WHEN mgr_name is null THEN 'SZEF WSZYSTKICH SZEFÓW'
          WHEN mgr_name is not null THEN mgr_name
        END
      ) as "mgr_name",
      level AS "lvl"
FROM hierarchia;



-- e) nazwisko pracownika, poziom w hierarchii i listę przełożonych

WITH RECURSIVE hierarchia AS(
    SELECT
        empno,
        empname,
        mgrno,
        1 AS level,
        CAST(NULL AS VARCHAR) AS managers
    FROM lab06.staff
        WHERE mgrno IS NULL

    UNION ALL

    SELECT s.empno, s.empname, s.mgrno, h.level+1, CONCAT(h.managers, CONCAT(CAST('->' AS VARCHAR),h.empname))
    FROM lab06.staff s
        JOIN hierarchia h ON s.mgrno=h.empno
) SELECT
      empname AS "emp_name",
      level AS "lvl",
      managers AS "path"
FROM hierarchia;


