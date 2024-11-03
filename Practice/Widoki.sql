-- Widok jest wynikiem realizacji jednej lub wielu operacji na tabelach w bazie danych. Tworzymy wtedy nową dynamiczną tabelę wynikową. Widok jest tabelą wirtualną, która nie musi fizycznie istnieć w bazie danych (w przeciwieństwie do widoków zmaterializowanych). Jest wyliczana na żądanie użytkownika. Dla użytkownika widok wygląda jak zwykła tabela.
--
--      pozwalają uprościć złożone zapytania - brak konieczności pisania długich poleceń SELECT;
--      umożliwiają wielokrotne użyć zdefiniowane zapytanie;
--      umożliwiają zmianę formatowania danych, np. wykorzystanie funkcji CAST;
--      ukrywanie efektów normalizacji - łączenie tabel z wykorzystaniem JOIN;
--      możemy tworzyć kolumny obliczeniowe;
--      pozwalają ograniczyć dostęp do danych - usuwanie poprzez selekcję i projekcję chronionych danych;
--      pozwalają na tworzenie warstwy abstrakcji - przykrywanie orginalnej struktury bazy danych, zmiana nazw.

-- Tworzenie widoku
-- CREATE VIEW
--     <nazwa perspektywy> [<nazwa kolumny>,...]
--     AS
--     <zapytanie SELECT definiujące perspektywę>
--     [ WITH [CASCADED|LOCAL]
--       CHECK OPTION]



CREATE VIEW lab.item_price AS
    SELECT item_id, description, CAST(sell_price AS FLOAT) AS price
    FROM lab.item;

SELECT * FROM lab.item_price;



-- Tworzenie perspektywy z tabeli item, ukrywającą pole cost_price i przedstawiającą pole sell_price w formacie zmiennoprzecinkowym.Tworzenie perspektywy z tabeli item, ukrywającą pole cost_price i przedstawiającą pole sell_price w formacie zmiennoprzecinkowym.

CREATE VIEW lab.item_price AS
    SELECT item_id, description, CAST(sell_price AS FLOAT) AS price
    FROM lab.item;

SELECT * FROM lab.item_price;



-- Tworzenie perspektywy z tabeli customer, tworzaca nowe pole

CREATE VIEW lab.dane AS
    SELECT fname ||' '|| lname AS name, town
    from lab.customer;

SELECT * FROM lab.dane;



-- Perspektywa, która przedstawia zestawienie item_id, description i barcod

CREATE VIEW lab.all_items AS
    SELECT i.item_id, i.description, b.barcode_ean
    FROM lab.item I, barcode b
    WHERE i.item_id=b.item_id;

SELECT * FROM lab.all_items;


-- Widok jest modyfikowalny, jeżeli istnieje możliwość przeniesienia każdego zmodyfikowanego wiersza czy kolumny z perspektywy do tabeli bazowej.
-- Standard ISO narzuca na widoki modyfikowalne ograniczenia:
--      nie występuje opcja DISTINCT
--      każdy atrybut w poleceniu definiującym widok jest atrybutem z tabeli źródłowej ( nie ma stałych, wyrażeń, czy funkcji agregujących
--      w klauzuli FROM określona jest tylko jedna tabela źródłowa (wykluczone są złączenia, sumy, przecięcia czy różnica)
--      klauzula WHERE nie zawiera żądnego podzapytania
--      nie występuje klauzula GROUP BY i HAVING


CREATE VIEW lab.personel AS
    SELECT fname, lname, zipcode, town
    FROM lab.customer;


INSERT INTO lab.personel (fname, lname, zipcode, town)
VALUES ('Harry','Potter','WT3 8GM','Welltown');


-- W ramach polecenia tworzącego widok występują dodatkowe parametry związane z modyfikacją danych poprzez widok.
-- WITH CHECK OPTION - nie można zmieniać zawartości tabeli bazowej, która nie jest widziana przez widok

CREATE VIEW lab.women AS SELECT title, fname, lname, zipcode, town FROM lab.customer WHERE title <> 'Mr' ;
CREATE VIEW lab.women_check AS SELECT title, fname, lname, zipcode, town FROM lab.customer WHERE title <> 'Mr' WITH CHECK OPTION;

INSERT INTO lab.women(title,fname, lname, zipcode, town) VALUES ('Mr','Tom','Sawyer','WT3 8GM','Welltown');
INSERT INTO lab.women_check(title,fname, lname, zipcode, town) VALUES ('Mr','Tom','Sawyer','WT3 8GM','Welltown');
INSERT INTO lab.women_check(title,fname, lname, zipcode, town) VALUES ('Mrs','Tom','Sawyer','WT3 8GM','Welltown');



-- WITH LOCAL CHECK OPTION - nie można złamać ograniczenia bieżącego widoku - ograniczenie widoku , na podstawie, którego stworzony jest bieżący widok można złamać

CREATE VIEW lab.women AS
    SELECT title, fname, lname, zipcode, town
    FROM lab.customer
    WHERE title <> 'Mr' ;
CREATE VIEW lab.women_town AS
    SELECT title, lname, zipcode, town
    FROM lab.women
    WHERE town LIKE 'W%'
    WITH LOCAL CHECK OPTION;

INSERT INTO lab.women_town(title, lname, zipcode, town) VALUES ('Mr','Sawyer','WT3 8GM','Welltown'); --złamanie ograniczenia widoku women
INSERT INTO lab.women_town(title, lname, zipcode, town) VALUES ('Mr','Sawyer','WT3 8GM','Nicetown'); --złamanie ograniczenia widoku women_town



-- WITH CASCADED CHECK OPTION - nie można złamać ograniczenia bieżącego widoku, ani żadnego, który jest zaangażowany do jego stworzenia

                                                                                                     CREATE VIEW lab.women AS SELECT title, fname, lname, zipcode, town FROM lab.customer WHERE title <> 'Mr' ;
CREATE VIEW lab.women_town_check AS
    SELECT title, lname, zipcode, town
    FROM lab.women WHERE town LIKE 'W%'
    WITH CASCADED CHECK OPTION;

INSERT INTO lab.women_town_check(title, lname, zipcode, town) VALUES ('Miss','Poppins','WT3 8GM','Nicetown'); --złamanie ograniczenia widoku women_town_check
INSERT INTO lab.women_town_check(title, lname, zipcode, town) VALUES ('Mr','Sawyer','WT3 8GM','Nicetown');  --złamanie ograniczenia widoku women
INSERT INTO lab.women_town_check(title, lname, zipcode, town) VALUES ('Miss','Poppins','WT3 8GM','Welltown');


-- Widok materializowany
-- CREATE MATERIALIZED VIEW view_name
-- AS  query
-- WITH [NO] DATA;

-- Tworzenie pustego widoku

CREATE MATERIALIZED VIEW lab.personel_m AS
    SELECT fname, lname, zipcode, town
    FROM lab.customer
    WITH NO DATA;


-- Tworzenie widoku z danymi

CREATE MATERIALIZED VIEW lab.personel_f AS
    SELECT fname, lname, zipcode, town
    FROM lab.customer
    WITH DATA;

-- Wypełnienie istniejącego widoku danymi

REFRESH MATERIALIZED VIEW lab.personel_m;