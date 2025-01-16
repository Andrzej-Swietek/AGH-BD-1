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
    (3, 3),
    (4, 1),
    (4, 2),
    (5, 3),
    (6, 2),
    (7, 3);
