CREATE SCHEMA lab04;


-- ### DDL ###
-- Tworzenie tabeli instytut
CREATE TABLE lab04.instytut (
    instytut_id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    lokal TEXT NOT NULL
);

-- Tworzenie tabeli funkcja
CREATE TABLE lab04.funkcja (
    funkcja_id INTEGER PRIMARY KEY,
    nazwa TEXT UNIQUE NOT NULL,
    min_wynagrodzenia INTEGER NOT NULL CHECK (min_wynagrodzenia > 0),
    max_wynagrodzenia INTEGER NOT NULL CHECK (max_wynagrodzenia > min_wynagrodzenia)
);

-- Tworzenie tabeli wykladowca
CREATE TABLE lab04.wykladowca (
    wykladowca_id INTEGER PRIMARY KEY,
    nazwisko TEXT NOT NULL,
    manager_id INTEGER,
    rok_zatrudnienia INTEGER NOT NULL,
    wynagrodzenie INTEGER CHECK (wynagrodzenie >= 1000),
    instytut_id INTEGER,
    FOREIGN KEY (instytut_id) REFERENCES lab04.instytut(instytut_id),
    FOREIGN KEY (manager_id) REFERENCES lab04.wykladowca(wykladowca_id) -- relacja samoodwołująca
);

-- Tworzenie tabeli kurs
CREATE TABLE lab04.kurs (
    kurs_id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    start DATE NOT NULL,
    koniec DATE
);

-- Tworzenie tabeli łączącej kursy z wykładowcami (relacja N:M)
CREATE TABLE lab04.wykladowca_kurs (
    wykladowca_id INTEGER,
    kurs_id INTEGER,
    PRIMARY KEY (wykladowca_id, kurs_id),
    FOREIGN KEY (wykladowca_id) REFERENCES lab04.wykladowca(wykladowca_id),
    FOREIGN KEY (kurs_id) REFERENCES lab04.kurs(kurs_id)
);

-- ### DML ###


-- SEEDERS

INSERT INTO lab04.instytut (instytut_id, nazwa, lokal) VALUES
(1, 'Instytut Informatyki', 'Kraków'),
(2, 'Instytut Fizyki', 'Warszawa'),
(3, 'Instytut Mechatroniki', 'Kalisz'),
(4, 'Instytut Odlewnictwa', 'Radom');

INSERT INTO lab04.funkcja (funkcja_id, nazwa, min_wynagrodzenia, max_wynagrodzenia) VALUES
(1, 'Asystent', 1000, 3000),
(2, 'Adiunkt', 3001, 6000),
(3, 'Profesor', 6001, 10000);


INSERT INTO lab04.wykladowca (wykladowca_id, nazwisko, manager_id, rok_zatrudnienia, wynagrodzenie, instytut_id) VALUES
(1, 'Kowalski', NULL, 2015, 3500, 1),
(2, 'Nowak', 1, 2010, 7000, 1),
(3, 'Wiśniewski', NULL, 2018, 2500, 2),
(4, 'Kaczmarek', 2, 2011, 6200, 2),
(5, 'Radzikowski', NULL, 2015, 3500, 1),
(6, 'Kida', 1, 2010, 8000, 1),
(7, 'Kowalewski', NULL, 2018, 2200, 2),
(8, 'Kaczanowski', 2, 2011, 6100, 2);


INSERT INTO lab04.kurs (kurs_id, nazwa, start, koniec) VALUES
(1, 'Algorytmy', '2023-09-01', '2023-12-15'),
(2, 'Matematyka dyskretna', '2024-10-01', NULL),
(3, 'Bazy Danych I', '2024-10-01', NULL),
(4, 'Bazy Danych II', '2024-02-01', NULL),
(5, 'Grafy', '2022-10-01', '2022-11-01')
;

INSERT INTO lab04.wykladowca_kurs (wykladowca_id, kurs_id) VALUES
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
INSERT  INTO lab04.wykladowca
VALUES (9, 'Korczyński', 2, 2012, 6100, 1);


-- Ten wykladowca ma od teraz 3 kursy czyli wiecej niz rerszta
INSERT INTO lab04.wykladowca_kurs (wykladowca_id, kurs_id) VALUES
(3, 1),
(3, 3);



-- a) liczbę wykładowców biorących udział w danym kursie (bez podziału na ukończone i nieukończone) wypisać numer kursu, nazwę kursu  i liczba  prowadzących --> każdy prowadzący liczy się tylko raz
SELECT
    k.kurs_id,
    k.nazwa AS kurs_nazwa,
    COUNT(wk.wykladowca_id) AS liczba_prowadzacych
FROM lab04.kurs k
    JOIN lab04.wykladowca_kurs wk ON k.kurs_id = wk.kurs_id
GROUP BY k.kurs_id, k.nazwa;


-- b) nazwiska wykładowców, którzy obecnie nie prowadzą żadnych kursów
SELECT w.nazwisko
FROM lab04.wykladowca w
    LEFT JOIN lab04.wykladowca_kurs wk on w.wykladowca_id = wk.wykladowca_id
WHERE wk.kurs_id IS NULL
;


-- c) średnie zarobki dla instytutów zatrudniających powyżej 3 wykładowców (nazwa instytutu, kwota)
SELECT i.nazwa AS instytut_nazwa, AVG (w. wynagrodzenie) AS srednie_wynagrodzenie
FROM lab04.instytut i
    JOIN lab04.wykladowca w ON i.instytut_id = w.instytut_id
GROUP BY i.instytut_id
HAVING COUNT (w.wykladowca_id) > 3;


-- d) różnicę między najwyższą i najniższą pensją
SELECT
    MAX(wynagrodzenie) - MIN(wynagrodzenie) as roznica
FROM lab04.wykladowca;


-- e) średnie wynagrodzenie (realne) dla każdej funkcji
SELECT f.nazwa AS funkcja_nazwa, AVG(w.wynagrodzenie) as srednie_wynagrodzenie
FROM lab04.funkcja f
    JOIN lab04.wykladowca w
        ON w.wynagrodzenie BETWEEN f.min_wynagrodzenia AND f.max_wynagrodzenia
GROUP BY f.nazwa;


-- f) wykładowca, który brał udział w największej ilości kursów (zastosować LIMIT)
SELECT
    w.nazwisko,
    COUNT(wk.kurs_id) AS liczba_kursow
FROM lab04.wykladowca w
    JOIN lab04.wykladowca_kurs wk on w.wykladowca_id = wk.wykladowca_id
GROUP BY w.wykladowca_id
ORDER BY liczba_kursow DESC
LIMIT 1
;


-- g) listę instytutów, których pracownicy biorą udział w poszczególnych kursach (nazwa kursu, nazwa instytutu) - nazwy instytutów występują tylko raz dla danego kursu
SELECT
    k.nazwa AS kurs_nazwa,
    i.nazwa AS instytut_nazwa
FROM lab04.kurs k
    JOIN lab04.wykladowca_kurs wk ON k.kurs_id = wk.kurs_id
    JOIN lab04.wykladowca w ON wk.wykladowca_id = w.wykladowca_id
    JOIN lab04.instytut i ON w.instytut_id = i.instytut_id
GROUP BY k.kurs_id, i.instytut_id
;

-- h) ilość podwładnych dla każdego pracownika (id_managera , ilość podwładnych)
SELECT
    manager_id,
    COUNT(wykladowca_id) AS liczba_podwladnych
FROM lab04.wykladowca
WHERE manager_id IS NOT NULL -- bo to nie szefowie => pracownicy
GROUP BY manager_id
;

-- i) listę pracowników, którzy pracują w co najmniej dwóch  kursach aktualnie prowadzonych (nazwisko)
SELECT
    w.nazwisko
FROM lab04.wykladowca w
    JOIN lab04.wykladowca_kurs wk ON w.wykladowca_id = wk.wykladowca_id
    JOIN lab04.kurs k ON wk.kurs_id = k.kurs_id
WHERE k.koniec IS NULL
GROUP BY w.wykladowca_id
HAVING COUNT(wk.kurs_id) >= 2
;

-- j) koszt miesięczny poszczególnego kursu - wynagrodzenie pracowników biorących w nim udział --> bez podziału na ukończone i nieukończone
SELECT
    k.nazwa AS kurs_nazwa,
    SUM(w.wynagrodzenie / 12) AS koszt_miesieczny
FROM lab04.kurs k
    JOIN lab04.wykladowca_kurs wk ON k.kurs_id = wk.kurs_id
    JOIN lab04.wykladowca w ON wk.wykladowca_id = w.wykladowca_id
GROUP BY k.kurs_id
;