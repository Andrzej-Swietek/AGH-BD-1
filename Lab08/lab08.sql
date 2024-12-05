CREATE SCHEMA lab08;


-- ### DDL ###


-- Tworzenie tabeli instytut
CREATE TABLE lab08.instytut (
    instytut_id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    lokal TEXT NOT NULL
);

-- Tworzenie tabeli funkcja
CREATE TABLE lab08.funkcja (
    funkcja_id INTEGER PRIMARY KEY,
    nazwa TEXT UNIQUE NOT NULL,
    min_wynagrodzenia INTEGER NOT NULL CHECK (min_wynagrodzenia > 0),
    max_wynagrodzenia INTEGER NOT NULL CHECK (max_wynagrodzenia > min_wynagrodzenia)
);

-- Tworzenie tabeli wykladowca
CREATE TABLE lab08.wykladowca (
    wykladowca_id INTEGER PRIMARY KEY,
    nazwisko TEXT NOT NULL,
    manager_id INTEGER,
    rok_zatrudnienia INTEGER NOT NULL,
    wynagrodzenie INTEGER CHECK (wynagrodzenie >= 1000),
    instytut_id INTEGER,
    FOREIGN KEY (instytut_id) REFERENCES lab08.instytut(instytut_id),
    FOREIGN KEY (manager_id) REFERENCES lab08.wykladowca(wykladowca_id) -- relacja samoodwołująca
);

-- Tworzenie tabeli kurs
CREATE TABLE lab08.kurs (
    kurs_id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    start DATE NOT NULL,
    koniec DATE
);

-- Tworzenie tabeli łączącej kursy z wykładowcami (relacja N:M)
CREATE TABLE lab08.wykladowca_kurs (
    wykladowca_id INTEGER,
    kurs_id INTEGER,
    PRIMARY KEY (wykladowca_id, kurs_id),
    FOREIGN KEY (wykladowca_id) REFERENCES lab08.wykladowca(wykladowca_id),
    FOREIGN KEY (kurs_id) REFERENCES lab08.kurs(kurs_id)
);


-- tabela koszty
create table lab08.koszty (
    wpis_id                        serial,
    kurs_id                         integer,
    wykladowcy                      integer    not null, --ilosc wykladowcoa w kursie
    koszt_plus                      numeric(7,2), --kwota, o która koszt kursu przekracza wartosc graniczna
    CONSTRAINT                      koszt_pk PRIMARY KEY (wpis_id)
);


-- tabela nagrody
create table lab08.nagrody
(
    wpis_id                         serial  PRIMARY KEY,
    wykladowca_id                   integer,
    nagroda                         numeric(7,2),
    data                             date --data przyznania nagrody, czyli moment wykonania funkcji
);



-- ### DML ###


-- SEEDERS

INSERT INTO lab08.instytut (instytut_id, nazwa, lokal) VALUES
(1, 'Instytut Informatyki', 'Kraków'),
(2, 'Instytut Fizyki', 'Warszawa'),
(3, 'Instytut Mechatroniki', 'Kalisz'),
(4, 'Instytut Odlewnictwa', 'Radom');

INSERT INTO lab08.funkcja (funkcja_id, nazwa, min_wynagrodzenia, max_wynagrodzenia) VALUES
(1, 'Asystent', 1000, 3000),
(2, 'Adiunkt', 3001, 6000),
(3, 'Profesor', 6001, 10000);


INSERT INTO lab08.wykladowca (wykladowca_id, nazwisko, manager_id, rok_zatrudnienia, wynagrodzenie, instytut_id) VALUES
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




INSERT INTO lab08.kurs (kurs_id, nazwa, start, koniec) VALUES
(1, 'Algorytmy', '2023-09-01', '2023-12-15'),
(2, 'Matematyka dyskretna', '2024-10-01', NULL),
(3, 'Bazy Danych I', '2024-10-01', NULL),
(4, 'Bazy Danych II', '2024-02-01', NULL),
(5, 'Grafy', '2022-10-01', '2022-11-01')
;

INSERT INTO lab08.wykladowca_kurs (wykladowca_id, kurs_id) VALUES
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

ALTER TABLE lab08.wykladowca ADD COLUMN premia REAL DEFAULT 0 CHECK (premia BETWEEN 0.0 AND 100.0); --dodajemy


--     Należy dopisać kwerendy pozwalające przetestować działanie tryggerów.
--     Tabela zajecia u mnie to wykladowca_kurs

--     1. Proszę skonstruować trygger, który zrealizuje wprowadzanie danych do tabel powiązanych
--     Tabela koszty przechowuje informacje o kursach, które przekraczają wyznaczony koszt graniczny (ćwiczenie1 z poprzednich zajęć).
--     Należy skonstruować wyzwalacz, który będzie uruchamiany po każdej zmianie w tabeli zajecia, który będzie aktualizował tabelę koszty

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
        FROM lab08.kurs k
    LOOP
        SELECT COALESCE(SUM(w.wynagrodzenie), 0)
            INTO suma_kosztow
        FROM lab08.wykladowca_kurs wk
            JOIN lab08.wykladowca w ON wk.wykladowca_id = w.wykladowca_id
        WHERE wk.kurs_id = kurs.kurs_id;

        IF suma_kosztow > wartosc_graniczna THEN
            przekroczone_kursy := przekroczone_kursy + 1;

            INSERT INTO lab08.koszty (kurs_id, wykladowcy, koszt_plus)
            VALUES (kurs.kurs_id,
                    (SELECT COUNT(*)
                     FROM lab08.wykladowca_kurs wk
                     WHERE wk.kurs_id = kurs.kurs_id),           -- liczba wykładowców
                    suma_kosztow - wartosc_graniczna); -- nadwyżka kosztu
        END IF;
    END LOOP;

    RETURN przekroczone_kursy;
END;
$$
LANGUAGE plpgsql;
SELECT oblicz_koszty(5000);

CREATE OR REPLACE FUNCTION update_koszty_trigger_handler()
RETURNS TRIGGER AS $$
DECLARE
    suma_kosztow NUMERIC;
    wartosc_graniczna NUMERIC := 5000;
BEGIN
    -- Sumę wynagrodzeń wykładowców dla kursu
    SELECT COALESCE(SUM(w.wynagrodzenie), 0)
        INTO suma_kosztow
    FROM lab08.wykladowca_kurs wk
        JOIN lab08.wykladowca w ON wk.wykladowca_id = w.wykladowca_id
    WHERE wk.kurs_id = NEW.kurs_id;

    IF suma_kosztow > wartosc_graniczna THEN
        INSERT INTO lab08.koszty (kurs_id, wykladowcy, koszt_plus)
        VALUES (NEW.kurs_id,
                (SELECT COUNT(*)
                 FROM lab08.wykladowca_kurs
                 WHERE kurs_id = NEW.kurs_id),
                suma_kosztow - wartosc_graniczna);
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_zajecia_tgr
    AFTER INSERT ON lab08.wykladowca_kurs
FOR EACH ROW
    EXECUTE PROCEDURE update_koszty_trigger_handler();



--     2. Proszę skonstruować trygger, który po każdych 3 kursach, w których bierze udział pracownik zwiększy jego premie   o 2% - nie może być wyższa niż 100
--     --do tabeli wykladowca dodajemy kolumnę premia, która przechowuje wartość premii przysługująca wykładowcy
--     ALTER TABLE wykladowca ADD COLUMN premia REAL DEFAULT 0 CHECK (premia BETWEEN 0.0 AND 100.0); --dodajemy

CREATE OR REPLACE FUNCTION update_premia_trigger_handler()
RETURNS TRIGGER AS $$
DECLARE
    kursy_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO kursy_count
    FROM lab08.wykladowca_kurs
    WHERE wykladowca_id = NEW.wykladowca_id;

    IF kursy_count % 3 = 0 THEN
        UPDATE lab08.wykladowca
        SET premia = LEAST(premia + 2, 100) -- maksymalna premia to 100%
        WHERE wykladowca_id = NEW.wykladowca_id;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_premia_tgr
    AFTER INSERT ON lab08.wykladowca_kurs
FOR EACH ROW
    EXECUTE PROCEDURE update_premia_trigger_handler();


--     3. Proszę skonstruować trygger, który zapewnienia integralności danych
--     Próba usunięcia wykładowcy z tabeli wykladowca
--      - w przypadku, gdy bierze on udział w niezakończonym kursie  nie może  zostać usunięty  - należy wygenerować stosowny komunikat
--      - w przypadku, gdy nie bierze on udziału w niezakończonym kursie  może  zostać usunięty - i cała historia jego pracy.
--      - Jeżeli był on jedynym prowadzącym kurs kurs też należy usunąć

CREATE OR REPLACE FUNCTION delete_wykladowca_trigger_handler()
RETURNS TRIGGER AS $$
    DECLARE
        unfinished_courses INTEGER;
        other_instructors INTEGER;
        row_kurs_id INTEGER;
    BEGIN
        IF (TG_OP = 'DELETE') THEN

         -- Sprawdzanie, czy wykładowca uczestniczy w niezakończonych kursach
            SELECT COUNT(*) INTO unfinished_courses
            FROM lab08.kurs k
                JOIN lab08.wykladowca_kurs wk ON k.kurs_id = wk.kurs_id
            WHERE wk.wykladowca_id = OLD.wykladowca_id AND k.koniec IS NULL;

            IF unfinished_courses > 0 THEN
                RAISE EXCEPTION 'Nie można usunąć wykładowcy. Bierze udział w niezakończonym kursie.';
            END IF;

         -- Sprawdzenie czy byl ostatnim prowadzacym - przejscie przez jego kursy
             FOR row_kurs_id IN
                SELECT kurs_id as row_kurs_id FROM lab08.wykladowca_kurs wk
                WHERE wykladowca_id = OLD.wykladowca_id
            LOOP
                SELECT COUNT(*) INTO other_instructors
                FROM lab08.wykladowca_kurs
                WHERE kurs_id = kurs_id AND wykladowca_id != OLD.wykladowca_id;

                -- Usuń kurs, jeśli nie ma innych prowadzących
                IF other_instructors = 0 THEN
                    DELETE FROM lab08.kurs k WHERE row_kurs_id = k.kurs_id;
                END IF;
            END LOOP;

        END IF;
        RETURN OLD;
    END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delete_wykladowca_tgr
    BEFORE DELETE ON lab08.wykladowca
FOR EACH ROW
    EXECUTE PROCEDURE delete_wykladowca_trigger_handler();





-- Testowanie poprawnosci dzialania triggerow

-- Test zadanie 1
-- Przed dla kursu 1
SELECT * FROM lab08.koszty where kurs_id = 1;

-- Sprawdzenie obecnych kosztów dla kursu o ID 1
SELECT * FROM lab08.koszty WHERE kurs_id = 1;

-- Dodanie nowego wykładowcy do kursu (kurs ID 1)
INSERT INTO lab08.wykladowca (wykladowca_id, nazwisko, rok_zatrudnienia, wynagrodzenie, instytut_id) VALUES (12, 'Nowy Wykładowca', 2022, 4500, 1);
INSERT INTO lab08.wykladowca_kurs (wykladowca_id, kurs_id) VALUES (12, 1);
-- Sprawdzenie, czy tabela koszty została zaktualizowana
SELECT * FROM lab08.koszty WHERE kurs_id = 1;



-- Dodanie nowego kursu
INSERT INTO lab08.kurs (kurs_id, nazwa, start, koniec)
VALUES (10, 'Nowy Kurs Testowy', '2024-01-01', NULL);

-- Przypisanie wykładowców do nowego kursu
INSERT INTO lab08.wykladowca_kurs (wykladowca_id, kurs_id)
VALUES
(1, 10),
(2, 10),
(5, 10);

-- Weryfikacja wpisów w tabeli koszty
SELECT * FROM lab08.koszty WHERE kurs_id = 10;





-- Test zadanie 2
-- Dodanie nowego kursu
INSERT INTO lab08.kurs (kurs_id, nazwa, start, koniec) VALUES
(6, 'Nowy Kurs 1', '2024-01-01', NULL),
(7, 'Nowy Kurs 2', '2024-02-01', NULL),
(8, 'Nowy Kurs 3', '2024-03-01', NULL);

-- Przed dodaniem
SELECT wykladowca_id, nazwisko, premia FROM lab08.wykladowca WHERE wykladowca_id = 1;

-- Przypisanie wykładowcy do kursów
INSERT INTO lab08.wykladowca_kurs (wykladowca_id, kurs_id) VALUES
(1, 6),
(1, 7),
(1, 8),
(1, 3),
(1, 2),
(1, 5),
(1, 4);

-- Poprostu mi dojsc do liczby podzielnej przez 3

-- Po dodaniu
SELECT wykladowca_id, nazwisko, premia FROM lab08.wykladowca WHERE wykladowca_id = 1;
SELECT COUNT(*) FROM lab08.wykladowca_kurs WHERE wykladowca_id = 1;



-- Test zadanie 3
-- Sprawdzenie wykładowców w niezakończonych kursach
WITH wk_delete_cte AS (
    SELECT DISTINCT w.wykladowca_id
    FROM lab08.wykladowca w
    JOIN lab08.wykladowca_kurs wk ON w.wykladowca_id = wk.wykladowca_id
    JOIN lab08.kurs k ON wk.kurs_id = k.kurs_id
    WHERE k.koniec IS NULL
    LIMIT 1
)
DELETE FROM lab08.wykladowca
WHERE wykladowca_id = (SELECT wykladowca_id FROM wk_delete_cte);

-- Próba usunięcia wykładowcy biorącego udział w niezakończonym kursie
 -- u mnie wyrzuca wyjatek bo Wiśniewski ma jeszcze kurs

-- Komunikat ktory dostalem:
--     [P0001] ERROR: Nie można usunąć wykładowcy. Bierze udział w niezakończonym kursie.
--     Where: PL/ pgSQL function delete_wykladowca_trigger_handler() line 16 at RAISE


-- Dodanie zakończonego kursu dla testowego wykładowcy
INSERT INTO lab08.kurs (kurs_id, nazwa, start, koniec) VALUES (6, 'Historia', '2022-01-01', '2022-12-31');
INSERT INTO lab08.wykladowca_kurs (wykladowca_id, kurs_id) VALUES (11, 6);

-- Próba usunięcia wykładowcy po zakończeniu wszystkich jego kursów
DELETE FROM lab08.wykladowca WHERE wykladowca_id = 11;

-- Sprawdzenie, czy kurs również został usunięty (jeśli wykładowca był jedynym prowadzącym)
SELECT * FROM lab08.kurs WHERE kurs_id = 6;
