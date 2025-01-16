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
