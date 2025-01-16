CREATE SCHEMA lab13;

-- ERD bazy danych: mamy tabele czytelnik, wypożyczenia, kara, książki według schematu
-- między tabelami czytelnik i wypożyczenia mamy relacje 1:N, natomiast między tabelami wypożyczenia i książki relację N:M

--     ERD bazy danych: mamy tabele czytelnik, wypożyczenia, kara, książki według schematu
--     między tabelami czytelnik i wypożyczenia mamy relacje 1:N, natomiast między tabelami wypożyczenia i książki relację N:M
--
--     zad2k
--
--
--     ZAD_1 Napisać polecenia tworzące bazę danych według przedstawionego schematu - atrybuty i ograniczenia według specyfikacji poniżej:
--     czytelnik
--         czytelnik_id  (integer) --klucz główny
--         imie  (tekstowy)
--         nazwisko  (tekstowy)
--     ksiazka
--         ksiazka_id  (integer) --klucz główny
--         autor_imie  (tekstowy)
--         autor_nazwisko  (tekstowy)
--         tytul (tekstowy)
--         cena (liczbowe) --nie mniej a niz 100.0
--         rok_wydania (integer) --miedzy 1995, a 2020
--         ilosc_egzemplarzy (integer) --nie moze byc ujemne
--
--     kara  --książki powinny być oddane do 4 dni, za zwłokę jest kara
--         kara_id  (integer) --klucz główny  stopien kary
--         opoznienie_min  (integer) --dolna granica opoznienia dla danego stopnia kary
--         opoznienie_max  (integer) --gorna granica opoznienia dla danego stopnia kary
--         --ograniczenie na tablice opoznienie_min < opoznienie_max
--         --kara_id = 0 brak kary
--     Wypełnić danymi - imie_1, nazwisk_1, tytul_1, ....
--
--     ZAD_2
--
--     Napisać polecania bez użycia LIMIT, generujące raporty, które zawierają
--     1. dla każdego czytelnika (id , nazwisko) zestawienie ilość_kar (sumarycznie)
--     2. lista książek (tytuł) które były pożyczone przez co najmniej dwóch różnych  czytelników
--     3. książka (tytuł), która była pożyczana najczęściej
--     4. dla każdego czytelnika (id , nazwisko) średnia_ilość_dni  trwania  wypożyczenia
--     5. lista czytelników (imie , nazwisko), którzy nigdy nie przetrzymali żadnej książki
--     6.ranking czytelników - nazwisko,  ilosc_pozyczonych_roznych _ksiazek
--     7. czytelnika (imie , nazwisko), który pożyczył największą ilość książek w jednym wypożyczeniu
--     8. tytuł książki, która była najczęściej przetrzymywana
--     9. Ilość wypożyczeń, które zostały przedłużone - zestawienie ilosc_dni , ilosc_wypozyczen
--     10. zestawienie - z wykorzystaniem kwerendy krzyżowej (CASE)

--                     || czytelnik |        tytul_1           |          tytul_2      ||
--                     || nazwisko_1|  ilosc wyporzyczen       |  ilosc wyporzyczen    ||
--                     || nazwisko_2|  ilosc wyporzyczen       |  ilosc wyporzyczen    ||


-- =========================== Tworzenie Tabel ===========================

CREATE TABLE lab13.czytelnik (
    czytelnik_id SERIAL PRIMARY KEY,
    imie TEXT NOT NULL,
    nazwisko TEXT NOT NULL
);

CREATE TABLE lab13.ksiazka (
    ksiazka_id SERIAL PRIMARY KEY,
    autor_imie TEXT NOT NULL,
    autor_nazwisko TEXT NOT NULL,
    tytul TEXT NOT NULL,
    cena NUMERIC CHECK (cena >= 100.0),
    rok_wydania INTEGER CHECK (rok_wydania BETWEEN 1995 AND 2020),
    ilosc_egzemplarzy INTEGER CHECK (ilosc_egzemplarzy >= 0)
);

CREATE TABLE lab13.kara (
    kara_id SERIAL PRIMARY KEY,
    opoznienie_min INTEGER NOT NULL,
    opoznienie_max INTEGER NOT NULL,
    CHECK (opoznienie_min < opoznienie_max)
);

CREATE TABLE lab13.wypozyczenie (
    wypozyczenie_id SERIAL PRIMARY KEY,
    czytelnik_id INTEGER NOT NULL REFERENCES lab13.czytelnik(czytelnik_id),
    data_wypozyczenia DATE NOT NULL,
    data_zwrotu DATE,
    przedluzone BOOLEAN DEFAULT FALSE, -- na etapie planowania myslalem ze tak to dziala ale nie uzywam pola
    kara_id INTEGER REFERENCES lab13.kara(kara_id)
);

CREATE TABLE lab13.wypozyczenie_ksiazka (
    wypozyczenie_id INTEGER NOT NULL REFERENCES lab13.wypozyczenie(wypozyczenie_id),
    ksiazka_id INTEGER NOT NULL REFERENCES lab13.ksiazka(ksiazka_id),
    PRIMARY KEY (wypozyczenie_id, ksiazka_id)
);

-- =========================== Dodanie danych ===========================

    INSERT INTO lab13.czytelnik (imie, nazwisko) VALUES
    ('Jan', 'Kowalski'),
    ('Anna', 'Nowak'),
    ('Piotr', 'Zieliński');
    INSERT INTO lab13.czytelnik (imie, nazwisko) VALUES ('Nie prztrzymal', 'bo jest dobry');

    INSERT INTO lab13.ksiazka (autor_imie, autor_nazwisko, tytul, cena, rok_wydania, ilosc_egzemplarzy) VALUES
    ('Adam', 'Mickiewicz', 'Pan Tadeusz', 120.0, 2000, 5),
    ('Henryk', 'Sienkiewicz', 'Potop', 150.0, 2010, 3),
    ('Bolesław', 'Prus', 'Lalka', 200.0, 1999, 2);

    INSERT INTO lab13.kara (opoznienie_min, opoznienie_max) VALUES
    (1, 3),
    (4, 7),
    (8, 14);
    INSERT INTO lab13.kara (kara_id, opoznienie_min, opoznienie_max) VALUES (0, -1, 0);


-- Dodanie przykładowych wypożyczeń i relacji z książkami
    INSERT INTO lab13.wypozyczenie (czytelnik_id, data_wypozyczenia, data_zwrotu, kara_id) VALUES
    (1, '2025-01-01', '2025-01-06', 2),
    (2, '2025-01-02', NULL, 3),
    (3, '2025-01-03', '2025-01-05', 1);
    INSERT INTO lab13.wypozyczenie (wypozyczenie_id, czytelnik_id, data_wypozyczenia, data_zwrotu, kara_id, przedluzone)
    VALUES
        (4, 1, '2025-01-01', '2025-01-08', 2, TRUE),
        (5, 1, '2025-01-10', '2025-01-12', 0, FALSE),
        (6, 2, '2025-01-03', '2025-01-09', 1, TRUE),
        (7, 3, '2025-01-05', NULL, 3, FALSE);

    INSERT INTO lab13.wypozyczenie_ksiazka (wypozyczenie_id, ksiazka_id) VALUES
    (1, 1),
    (1, 2),
    (2, 1),
    (3, 3);
    INSERT INTO lab13.wypozyczenie_ksiazka (wypozyczenie_id, ksiazka_id)
    VALUES
        (4, 1),
        (4, 2),
        (5, 3),
        (6, 2),
        (7, 3);



-- ZAD_2: Raporty
-- 1. Dla każdego czytelnika ilość kar sumarycznie

    SELECT c.czytelnik_id, c.nazwisko, COUNT(w.kara_id) AS ilosc_kar
    FROM lab13.czytelnik c
        LEFT JOIN lab13.wypozyczenie w ON c.czytelnik_id = w.czytelnik_id
    where kara_id > 0
    GROUP BY c.czytelnik_id, c.nazwisko;

-- 2. Lista książek wypożyczonych przez co najmniej dwóch różnych czytelników

    SELECT k.tytul
    FROM lab13.ksiazka k
        JOIN lab13.wypozyczenie_ksiazka wk ON k.ksiazka_id = wk.ksiazka_id
        JOIN lab13.wypozyczenie w ON wk.wypozyczenie_id = w.wypozyczenie_id
    GROUP BY k.tytul
        HAVING COUNT(DISTINCT w.czytelnik_id) >= 2;

-- 3. Książka wypożyczana najczęściej

--     SELECT k.tytul, COUNT(*) AS ilosc_wypozyczen
--     FROM lab13.ksiazka k
--         JOIN lab13.wypozyczenie_ksiazka wk ON k.ksiazka_id = wk.ksiazka_id
--     GROUP BY k.tytul
--     ORDER BY ilosc_wypozyczen DESC
--     LIMIT 1;

    SELECT tytul, ilosc_wypozyczen
    FROM (
        SELECT k.tytul, COUNT(*) AS ilosc_wypozyczen, RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
        FROM lab13.ksiazka k
            JOIN lab13.wypozyczenie_ksiazka wk ON k.ksiazka_id = wk.ksiazka_id
        GROUP BY k.tytul
    ) subquery
    WHERE rnk = 1;


-- 4. Średnia liczba dni trwania wypożyczenia dla każdego czytelnika

    SELECT c.czytelnik_id, c.nazwisko,
        AVG(COALESCE(w.data_zwrotu, CURRENT_DATE) - w.data_wypozyczenia) AS srednia_ilosc_dni
    FROM lab13.czytelnik c
        JOIN lab13.wypozyczenie w ON c.czytelnik_id = w.czytelnik_id
    GROUP BY c.czytelnik_id, c.nazwisko;


-- 5. Czytelnicy, którzy nigdy nie przetrzymali książki

    SELECT c.imie, c.nazwisko
    FROM lab13.czytelnik c
        LEFT JOIN lab13.wypozyczenie w ON c.czytelnik_id = w.czytelnik_id AND w.kara_id > 1
    WHERE w.kara_id IS NULL OR w.kara_id = 0;

-- 6. Ranking czytelników - ilość wypożyczonych różnych książek

    SELECT c.nazwisko, COUNT(DISTINCT wk.ksiazka_id) AS ilosc_ksiazek
    FROM lab13.czytelnik c
        JOIN lab13.wypozyczenie w ON c.czytelnik_id = w.czytelnik_id
        JOIN lab13.wypozyczenie_ksiazka wk ON w.wypozyczenie_id = wk.wypozyczenie_id
    GROUP BY c.nazwisko
    ORDER BY ilosc_ksiazek DESC;

-- 7. Czytelnik z największą ilością książek w jednym wypożyczeniu

    WITH reslut_cte as (
        SELECT c.imie, c.nazwisko, MAX(ilosc_ksiazek) AS max_ksiazek
        FROM (
            SELECT w.czytelnik_id, COUNT(wk.ksiazka_id) AS ilosc_ksiazek
            FROM lab13.wypozyczenie w
                JOIN lab13.wypozyczenie_ksiazka wk ON w.wypozyczenie_id = wk.wypozyczenie_id
            GROUP BY w.czytelnik_id, w.wypozyczenie_id
        ) subquery
        JOIN lab13.czytelnik c ON subquery.czytelnik_id = c.czytelnik_id
        GROUP BY c.imie, c.nazwisko
    )
    SELECT imie, nazwisko, max_ksiazek
    FROM  reslut_cte
    WHERE max_ksiazek = (
        SELECT MAX(max_ksiazek) FROM reslut_cte
    );


-- 8. Tytuł książki najczęściej przetrzymywanej

--     SELECT k.tytul, COUNT(*) AS ilosc_przetrzyman
--     FROM lab13.ksiazka k
--         JOIN lab13.wypozyczenie_ksiazka wk ON k.ksiazka_id = wk.ksiazka_id
--         JOIN lab13.wypozyczenie w ON wk.wypozyczenie_id = w.wypozyczenie_id
--     WHERE w.kara_id > 1
--     GROUP BY k.tytul
--     ORDER BY ilosc_przetrzyman DESC;

    SELECT tytul, ilosc_przetrzyman
    FROM (
        SELECT
            k.tytul,
            COUNT(*) AS ilosc_przetrzyman,
            RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
        FROM lab13.ksiazka k
        JOIN lab13.wypozyczenie_ksiazka wk ON k.ksiazka_id = wk.ksiazka_id
        JOIN lab13.wypozyczenie w ON wk.wypozyczenie_id = w.wypozyczenie_id
        WHERE w.kara_id >= 1
        GROUP BY k.tytul
    ) subquery
    WHERE rnk = 1;


-- 9. Ilość wypożyczeń, które zostały przedłużone - zestawienie ilosc_dni , ilosc_wypozyczen

    SELECT (COALESCE(w.data_zwrotu, CURRENT_DATE) - w.data_wypozyczenia) AS ilosc_dni, COUNT(*) AS ilosc_wypozyczen
    FROM lab13.wypozyczenie w
        WHERE (COALESCE(w.data_zwrotu, CURRENT_DATE) - w.data_wypozyczenia) > 4
    GROUP BY w.wypozyczenie_id;


-- 10. Kwerenda krzyżowa z CASE

    SELECT
        c.nazwisko,
        SUM(CASE WHEN k.tytul = 'Pan Tadeusz' THEN 1 ELSE 0 END) AS pan_tadeusz,
        SUM(CASE WHEN k.tytul = 'Potop' THEN 1 ELSE 0 END) AS potop,
        SUM(CASE WHEN k.tytul = 'Lalka' THEN 1 ELSE 0 END) AS lalka
    FROM lab13.czytelnik c
        LEFT JOIN lab13.wypozyczenie w ON c.czytelnik_id = w.czytelnik_id
        LEFT JOIN lab13.wypozyczenie_ksiazka wk ON w.wypozyczenie_id = wk.wypozyczenie_id
        LEFT JOIN lab13.ksiazka k ON wk.ksiazka_id = k.ksiazka_id
    GROUP BY c.nazwisko;
