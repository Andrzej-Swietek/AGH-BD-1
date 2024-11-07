CREATE SCHEMA lab05;


-- ### DDL ###


-- Tworzenie tabeli instytut
CREATE TABLE lab05.instytut (
    instytut_id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    lokal TEXT NOT NULL
);

-- Tworzenie tabeli funkcja
CREATE TABLE lab05.funkcja (
    funkcja_id INTEGER PRIMARY KEY,
    nazwa TEXT UNIQUE NOT NULL,
    min_wynagrodzenia INTEGER NOT NULL CHECK (min_wynagrodzenia > 0),
    max_wynagrodzenia INTEGER NOT NULL CHECK (max_wynagrodzenia > min_wynagrodzenia)
);

-- Tworzenie tabeli wykladowca
CREATE TABLE lab05.wykladowca (
    wykladowca_id INTEGER PRIMARY KEY,
    nazwisko TEXT NOT NULL,
    manager_id INTEGER,
    rok_zatrudnienia INTEGER NOT NULL,
    wynagrodzenie INTEGER CHECK (wynagrodzenie >= 1000),
    instytut_id INTEGER,
    FOREIGN KEY (instytut_id) REFERENCES lab05.instytut(instytut_id),
    FOREIGN KEY (manager_id) REFERENCES lab05.wykladowca(wykladowca_id) -- relacja samoodwołująca
);

-- Tworzenie tabeli kurs
CREATE TABLE lab05.kurs (
    kurs_id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    start DATE NOT NULL,
    koniec DATE
);

-- Tworzenie tabeli łączącej kursy z wykładowcami (relacja N:M)
CREATE TABLE lab05.wykladowca_kurs (
    wykladowca_id INTEGER,
    kurs_id INTEGER,
    PRIMARY KEY (wykladowca_id, kurs_id),
    FOREIGN KEY (wykladowca_id) REFERENCES lab05.wykladowca(wykladowca_id),
    FOREIGN KEY (kurs_id) REFERENCES lab05.kurs(kurs_id)
);


-- ### DML ###


-- SEEDERS

INSERT INTO lab05.instytut (instytut_id, nazwa, lokal) VALUES
(1, 'Instytut Informatyki', 'Kraków'),
(2, 'Instytut Fizyki', 'Warszawa'),
(3, 'Instytut Mechatroniki', 'Kalisz'),
(4, 'Instytut Odlewnictwa', 'Radom');

INSERT INTO lab05.funkcja (funkcja_id, nazwa, min_wynagrodzenia, max_wynagrodzenia) VALUES
(1, 'Asystent', 1000, 3000),
(2, 'Adiunkt', 3001, 6000),
(3, 'Profesor', 6001, 10000);


INSERT INTO lab05.wykladowca (wykladowca_id, nazwisko, manager_id, rok_zatrudnienia, wynagrodzenie, instytut_id) VALUES
(1, 'Kowalski', NULL, 2015, 3500, 1),
(2, 'Nowak', 1, 2010, 7000, 1),
(3, 'Wiśniewski', NULL, 2018, 2500, 2),
(4, 'Kaczmarek', 2, 2011, 6200, 2),
(5, 'Radzikowski', NULL, 2015, 3501, 1),
(6, 'Kida', 1, 2010, 8000, 1),
(7, 'Kowalewski', NULL, 2018, 2200, 2),
(8, 'Kaczanowski', 2, 2011, 6100, 2);

INSERT INTO lab05.kurs (kurs_id, nazwa, start, koniec) VALUES
(1, 'Algorytmy', '2023-09-01', '2023-12-15'),
(2, 'Matematyka dyskretna', '2024-10-01', NULL),
(3, 'Bazy Danych I', '2024-10-01', NULL),
(4, 'Bazy Danych II', '2024-02-01', NULL),
(5, 'Grafy', '2022-10-01', '2022-11-01')
;

INSERT INTO lab05.wykladowca_kurs (wykladowca_id, kurs_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2),
(5, 3),
(6, 3),
(7, 4),
(8, 4);


-- Dodatkowe dane dla różnorodnosci wyników

-- Ten bezkursowy
INSERT  INTO lab05.wykladowca
VALUES (9, 'Korczyński', 2, 2012, 6100, 1);

-- Żeby inne instytuty nie byly puste (pod ostatni podpunkt)
INSERT INTO lab05.wykladowca (wykladowca_id, nazwisko, manager_id, rok_zatrudnienia, wynagrodzenie, instytut_id) VALUES
(10, 'Buchalik', NULL, 2023, 4000, 3),
(11, 'Porwoł', NULL, 2023, 4000, 4);


-- Ten wykladowca Wiśniewski ma od teraz 3 kursy czyli wiecej niz rerszta
INSERT INTO lab05.wykladowca_kurs (wykladowca_id, kurs_id) VALUES
(3, 1),
(3, 3);



-- Proszę zapisać polecenia SELECT  z podzapytaniem, które wybiorą
--
-- a) wszystkich wykładowców o tym samym stopien_ID (tabela funkcja) co wykładowca  XXXXX (nazwiska)

SELECT nazwisko
FROM lab05.wykladowca w
JOIN lab05.funkcja f
    ON w.wynagrodzenie BETWEEN f.min_wynagrodzenia AND f.max_wynagrodzenia
WHERE f.funkcja_id = (
    SELECT funkcja_id
    FROM lab05.wykladowca w
        JOIN lab05.funkcja f
        ON w.wynagrodzenie BETWEEN f.min_wynagrodzenia AND f.max_wynagrodzenia
    WHERE w.nazwisko = 'Kowalski'
);


-- b) wszystkich wykładowców zatrudnionych w tych samych kursach co wykładowca  XXXXX. (nazwisko, instytut)
SELECT w.nazwisko, i.nazwa as instytut
FROM lab05.wykladowca w
    JOIN lab05.wykladowca_kurs wk ON w.wykladowca_id = wk.wykladowca_id
    JOIN lab05.kurs k ON wk.kurs_id = k.kurs_id
    JOIN lab05.instytut i ON w.instytut_id = i.instytut_id
WHERE k.kurs_id IN (
    SELECT k.kurs_id
        FROM lab05.wykladowca_kurs wk
            JOIN lab05.kurs k ON wk.kurs_id = k.kurs_id
            JOIN lab05.wykladowca w ON wk.wykladowca_id = w.wykladowca_id
        WHERE w.nazwisko = 'Kowalski'
);


-- c) wykładowców o pensjach z listy najniższych pensji osiąganych we wszystkich instytutach (nazwisko)
SELECT w.nazwisko
FROM lab05.wykladowca w
JOIN (
    SELECT instytut_id, MIN(wynagrodzenie) AS min_wynagrodzenie
    FROM lab05.wykladowca
    GROUP BY instytut_id
) AS min_salaries ON w.instytut_id = min_salaries.instytut_id
WHERE w.wynagrodzenie = min_salaries.min_wynagrodzenie;


-- d) pracowników o najniższych zarobkach w ich instytutach (nazwisko, pensja)
-- SELECT w.nazwisko, w.wynagrodzenie
-- FROM lab05.wykladowca w
-- JOIN (
--     SELECT instytut_id, MIN(wynagrodzenie) AS min_wynagrodzenie
--     FROM lab05.wykladowca
--     GROUP BY instytut_id
-- ) AS min_salaries ON w.instytut_id = min_salaries.instytut_id
-- WHERE w.wynagrodzenie = min_salaries.min_wynagrodzenie;

SELECT nazwisko, wynagrodzenie, instytut.nazwa
FROM lab05.wykladowca w
JOIN lab05.instytut instytut ON w.instytut_id = instytut.instytut_id
WHERE wynagrodzenie = (
    SELECT MIN(wynagrodzenie)
    FROM lab05.wykladowca
    WHERE instytut_id = w.instytut_id
    ORDER BY w.nazwisko
    LIMIT 1
)
ORDER BY instytut.nazwa;

-- e) stosując operator ANY wybrać wykładowców zarabiających powyżej najniższego zarobku z instytutu XXXXXX. (nazwisko)
SELECT nazwisko
FROM lab05.wykladowca
WHERE wynagrodzenie > ANY (
    SELECT min_wynagrodzenie
    FROM (
        SELECT MIN(wynagrodzenie) AS min_wynagrodzenie
        FROM lab05.wykladowca
        WHERE instytut_id = 1 -- 'Instytut Informatyki'
    ) AS lowest_salary
);


-- f) wykładowca, który brał udział w największej ilości różnych kursów (bez LIMIT)  (nazwisko, ilość)
SELECT nazwisko, liczba_kursow
FROM lab05.wykladowca
JOIN (
    SELECT wykladowca_id, COUNT(DISTINCT kurs_id) AS liczba_kursow
    FROM lab05.wykladowca_kurs
    GROUP BY wykladowca_id
) AS kursy ON lab05.wykladowca.wykladowca_id = kursy.wykladowca_id
WHERE liczba_kursow = (
    SELECT MAX(liczba_kursow)
    FROM (
        SELECT COUNT(DISTINCT kurs_id) AS liczba_kursow
        FROM lab05.wykladowca_kurs
        GROUP BY wykladowca_id
    ) AS max_kursy
);


-- g) instytut, w którym są najwyższe średnie zarobki. (nazwa)
SELECT nazwa
FROM lab05.instytut
WHERE instytut_id = (
    SELECT instytut_id
        FROM lab05.wykladowca
        GROUP BY instytut_id
        ORDER BY AVG(wynagrodzenie) DESC
        LIMIT 1
);



-- h) dla każdego instytutu ostatnio zatrudnionych wykładowców. Uporządkować według dat zatrudnienia. (nazwa_instytutu,nazwisko)
SELECT i.nazwa AS nazwa_instytutu, w.nazwisko
FROM lab05.instytut i
    JOIN lab05.wykladowca w ON i.instytut_id = w.instytut_id
WHERE w.rok_zatrudnienia = (
    SELECT MAX(rok_zatrudnienia)
    FROM lab05.wykladowca
    WHERE instytut_id = i.instytut_id
)
ORDER BY w.rok_zatrudnienia DESC;


-- i) zapytanie zwracające procentowy udział liczby pracowników  każdego instytutu w stosunku do całej firmy ((nazwa, wartosc)

SELECT nazwa, ROUND((liczba_pracownikow * 100.0 / liczba_pracownikow_firmy), 2) AS procent
FROM lab05.instytut
JOIN (
    SELECT instytut_id, COUNT(*) AS liczba_pracownikow
    FROM lab05.wykladowca
    GROUP BY instytut_id
) AS pracownicy ON lab05.instytut.instytut_id = pracownicy.instytut_id
JOIN (
    SELECT COUNT(*) AS liczba_pracownikow_firmy
    FROM lab05.wykladowca
) AS firma ON true;

