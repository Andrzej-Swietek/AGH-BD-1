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


CREATE SCHEMA lab13;

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
