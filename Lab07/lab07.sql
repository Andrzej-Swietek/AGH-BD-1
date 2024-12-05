CREATE SCHEMA lab07;


-- ### DDL ###


-- Tworzenie tabeli instytut
CREATE TABLE lab07.instytut (
    instytut_id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    lokal TEXT NOT NULL
);

-- Tworzenie tabeli funkcja
CREATE TABLE lab07.funkcja (
    funkcja_id INTEGER PRIMARY KEY,
    nazwa TEXT UNIQUE NOT NULL,
    min_wynagrodzenia INTEGER NOT NULL CHECK (min_wynagrodzenia > 0),
    max_wynagrodzenia INTEGER NOT NULL CHECK (max_wynagrodzenia > min_wynagrodzenia)
);

-- Tworzenie tabeli wykladowca
CREATE TABLE lab07.wykladowca (
    wykladowca_id INTEGER PRIMARY KEY,
    nazwisko TEXT NOT NULL,
    manager_id INTEGER,
    rok_zatrudnienia INTEGER NOT NULL,
    wynagrodzenie INTEGER CHECK (wynagrodzenie >= 1000),
    instytut_id INTEGER,
    FOREIGN KEY (instytut_id) REFERENCES lab07.instytut(instytut_id),
    FOREIGN KEY (manager_id) REFERENCES lab07.wykladowca(wykladowca_id) -- relacja samoodwołująca
);

-- Tworzenie tabeli kurs
CREATE TABLE lab07.kurs (
    kurs_id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    start DATE NOT NULL,
    koniec DATE
);

-- Tworzenie tabeli łączącej kursy z wykładowcami (relacja N:M)
CREATE TABLE lab07.wykladowca_kurs (
    wykladowca_id INTEGER,
    kurs_id INTEGER,
    PRIMARY KEY (wykladowca_id, kurs_id),
    FOREIGN KEY (wykladowca_id) REFERENCES lab07.wykladowca(wykladowca_id),
    FOREIGN KEY (kurs_id) REFERENCES lab07.kurs(kurs_id)
);


-- tabela koszty
create table lab07.koszty (
    wpis_id                        serial,
    kurs_id                         integer,
    wykladowcy                      integer    not null, --ilosc wykladowcoa w kursie
    koszt_plus                      numeric(7,2), --kwota, o która koszt kursu przekracza wartosc graniczna
    CONSTRAINT                      koszt_pk PRIMARY KEY (wpis_id)
);


-- tabela nagrody
create table lab07.nagrody
(
    wpis_id                         serial  PRIMARY KEY,
    wykladowca_id                   integer,
    nagroda                         numeric(7,2),
    data                             date --data przyznania nagrody, czyli moment wykonania funkcji
);



-- ### DML ###


-- SEEDERS

INSERT INTO lab07.instytut (instytut_id, nazwa, lokal) VALUES
(1, 'Instytut Informatyki', 'Kraków'),
(2, 'Instytut Fizyki', 'Warszawa'),
(3, 'Instytut Mechatroniki', 'Kalisz'),
(4, 'Instytut Odlewnictwa', 'Radom');

INSERT INTO lab07.funkcja (funkcja_id, nazwa, min_wynagrodzenia, max_wynagrodzenia) VALUES
(1, 'Asystent', 1000, 3000),
(2, 'Adiunkt', 3001, 6000),
(3, 'Profesor', 6001, 10000);


INSERT INTO lab07.wykladowca (wykladowca_id, nazwisko, manager_id, rok_zatrudnienia, wynagrodzenie, instytut_id) VALUES
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




INSERT INTO lab07.kurs (kurs_id, nazwa, start, koniec) VALUES
(1, 'Algorytmy', '2023-09-01', '2023-12-15'),
(2, 'Matematyka dyskretna', '2024-10-01', NULL),
(3, 'Bazy Danych I', '2024-10-01', NULL),
(4, 'Bazy Danych II', '2024-02-01', NULL),
(5, 'Grafy', '2022-10-01', '2022-11-01')
;

INSERT INTO lab07.wykladowca_kurs (wykladowca_id, kurs_id) VALUES
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

-- Dodanie nagrod i kosztow



--     1. Napisać funkcję, która wypełnia tablicę koszt informacjami o kosztach poszczególnych kursów.
--     - Argumentem funkcji jest wartość graniczna kosztu kursu.
--     - Funkcja ma zwracać ilość kursów, które przekraczają koszt graniczny.
--     - W tablicy koszty ma się pojawić wpis dotyczący takich kursów

CREATE OR REPLACE FUNCTION oblicz_koszty(wartosc_graniczna NUMERIC)
RETURNS INTEGER AS
$$
DECLARE
    przekroczone_kursy INTEGER := 0;
    kurs RECORD;
    suma_kosztow NUMERIC;
BEGIN
    FOR kurs IN
        SELECT k.kurs_id, k.nazwa
        FROM lab07.kurs k
    LOOP
        SELECT COALESCE(SUM(w.wynagrodzenie), 0)
            INTO suma_kosztow
        FROM lab07.wykladowca_kurs wk
            JOIN lab07.wykladowca w ON wk.wykladowca_id = w.wykladowca_id
        WHERE wk.kurs_id = kurs.kurs_id;

        IF suma_kosztow > wartosc_graniczna THEN
            przekroczone_kursy := przekroczone_kursy + 1;

            INSERT INTO lab07.koszty (kurs_id, wykladowcy, koszt_plus)
            VALUES (kurs.kurs_id,
                    (SELECT COUNT(*)
                     FROM lab07.wykladowca_kurs wk
                     WHERE wk.kurs_id = kurs.kurs_id),           -- liczba wykładowców
                    suma_kosztow - wartosc_graniczna); -- nadwyżka kosztu
        END IF;
    END LOOP;

    RETURN przekroczone_kursy;
END;
$$
LANGUAGE plpgsql;


SELECT oblicz_koszty(5000);


--     2. Napisać funkcję, która wypełnia tablicę nagrody danymi o wypłacie dodatku za prowadzenie kursów.
--     - Funkcja nie ma argumentów.
--     - Funkcja ma zwracać ilość rekordów dopisanych do tabeli.
--     - W tablicy nagrody mają pojawić się wpisy  dotyczące wypłat dla poszczególnych wykładowców.
--          - jeżeli wykładowca prowadzi 2 kursy (nieistotne czy ukończone czy nie) dostaje nagrodę w wysokości 10% swojej pensji
--          - jeżeli wykładowca prowadzi  3, 4 lub 5 kursów (nieistotne czy ukończone czy nie) dostaje nagrodę w wysokości 20% swojej pensji
--          - jeżeli prowadzi więcej niż 5 kursów (nieistotne czy ukończone czy nie) dostaje nagrodę w wysokości 30% swojej pensji



CREATE OR REPLACE FUNCTION oblicz_nagrody()
RETURNS integer AS
$$
DECLARE
    wykladowca RECORD;
    reward_count integer := 0;
    reward_amount numeric;
BEGIN
    FOR wykladowca IN
        SELECT wykladowca_id, wynagrodzenie, COUNT(*) AS kurs_count
        FROM lab07.wykladowca
            JOIN lab07.wykladowca_kurs USING (wykladowca_id)
        GROUP BY wykladowca_id, wynagrodzenie
    LOOP
        IF wykladowca.kurs_count = 2 THEN
            reward_amount := wykladowca.wynagrodzenie * 0.10;
        ELSIF wykladowca.kurs_count BETWEEN 3 AND 5 THEN
            reward_amount := wykladowca.wynagrodzenie * 0.20;
        ELSIF wykladowca.kurs_count > 5 THEN
            reward_amount := wykladowca.wynagrodzenie * 0.30;
        ELSE
            CONTINUE;
        END IF;

        INSERT INTO lab07.nagrody (wykladowca_id, nagroda, data)
        VALUES (wykladowca.wykladowca_id, reward_amount, CURRENT_DATE);

        reward_count := reward_count + 1;
    END LOOP;

    RETURN reward_count;
END;
$$
LANGUAGE plpgsql;


SELECT oblicz_nagrody();



--     3. Należy utworzyć funkcję rozwiązująca równanie kwadratowe
--
--     select rownanie_1(1,10,1); --(argumenty to (A, B, C) współczynniki równania  A*x2+B*x+C)
--
--     INFORMACJA:  DELTA = 96
--
--     INFORMACJA:  Rozwiazanie posiada dwa rzeczywiste pierwiastki
--
--     INFORMACJA:  x1 = -0.101020514433644
--
--     INFORMACJA:  x2 = -9.89897948556636
--
--                           equ_solve
--
--     ------------------------------------------------------
--
--      (x1 = -0.101020514433644 ),(x2 = -9.89897948556636 )
--
--     (1 wiersz)

CREATE OR REPLACE FUNCTION rownanie_1(A numeric, B numeric, C numeric)
RETURNS TABLE (equ_solve TEXT) AS
$$
DECLARE
    delta numeric;
    re numeric;
    im numeric;
    x1 TEXT;
    x2 TEXT;
BEGIN
    delta := B*B - 4*A*C;
    RAISE INFO 'DELTA = %', delta;

    IF delta > 0 THEN
        RAISE INFO 'Rozwiazanie posiada dwa rzeczywiste pierwiastki';
        re := (-B + sqrt(delta)) / (2 * A);
        x1 := 'x1 = ' || re;
        re := (-B - sqrt(delta)) / (2 * A);
        x2 := 'x2 = ' || re;
        equ_solve := '(' || x1 || ' ),(' || x2 || ' )';
        RETURN NEXT;

    ELSIF delta = 0 THEN
        RAISE INFO 'Rozwiazanie posiada jeden rzeczywisty pierwiastek';
        re := -B / (2 * A);
        x1 := 'x1 = ' || re;
        equ_solve := '(' || x1 || ' )';
        RETURN NEXT;

    ELSE
        RAISE INFO 'Rozwiazanie w dziedzinie liczb zespolonych';
        re := -B / (2 * A);
        im := sqrt(abs(delta)) / (2 * A);
        x1 := 'x1 = ' || re || ' + ' || im || 'i';
        x2 := 'x2 = ' || re || ' - ' || im || 'i';
        equ_solve := '(' || x1 || ' ),(' || x2 || ' )';
        RETURN NEXT;
    END IF;
END;
$$
LANGUAGE plpgsql;


SELECT * FROM rownanie_1(1, 10, 1);
SELECT * FROM rownanie_1(10, 5, 1);
SELECT * FROM rownanie_1(1, -2, 1);
