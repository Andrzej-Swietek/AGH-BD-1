-- SCHEMMATY
-- Schematy umożliwiają grupowanie obiektów bazy danych w przestrzenie nazw w obrębie tej samej bazy danych. W przeciwieństwie do baz danych, schematy nie są od siebie „mocno” odseparowane, użytkownik (klient) może mieć dostęp do obiektów w wewnątrz każdego schematu w obrębie jednej bazy danych, do której jest połączony, jeżeli uprawnienia mu na to pozwalają.
-- Użycie schematów wewnątrz bazy ma na celu logiczną separację obiektów, np. dla różnych użytkowników i aplikacji. Standardowo i domyślnie wszystkie obiekty tworzone są w schemacie public.
--

--Tworzenie schematu

CREATE SCHEMA nazwa_schematu;


-- Usuwanie schematu

DROP SCHEMA nazwa_schematu;  --usunie schemat pusty
DROP SCHEMA nazwa_schematu CASCADE;  --usunie schematu wraz z zawartością


-- Tworzenie tabeli nowa w schemacie schemat z poziomu schematu public

CREATE SCHEMA schemat;
CREATE TABLE schemat.nowa (id INT, txt TEXT);  --pełna nazwa kwalifikowana

-- Sprawdzenie aktualnego schematu
SHOW search_path;


-- Zmiana schematu
SET search_path to schemat;


-- Tworzenie widoku, który odnosi sie do tabel z róznych schematów

CREATE SCHEMA schemat_A;
CREATE TABLE schemat_A.nowa (id INT, txt TEXT);

INSERT INTO schemat.nowa VALUES (10, 'To jest schemat schemat');
INSERT INTO schemat_A.nowa VALUES (1, 'To jest schemat schemat_A');

CREATE VIEW view_info AS
    SELECT f.txt AS schemat, b.txt AS schemat_A
    FROM schemat.nowa f, schemat_A.nowa b
    WHERE f.id = b.id;
