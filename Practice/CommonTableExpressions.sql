-- CTE - Common Table Expressions
-- Umożliwiają pisanie bardziej zwięzłego, czytelnego, a przede wszystkim prostszego kodu.
-- Tworzone tymczasowe tabele, które są dostępne w ramach wyrażenia WITH oraz dla następującego bezpośrednio po definicji zapytania.
-- Wyrażenia CTE są szczególnie przydatne w przypadku rozbudowanych zapytań, łączących wiele tabel, które chcemy użyć w kolejnym kroku, wykonując na nich dodatkowe operacje.
--
--         WITH table1_CTE [( atrybuty )] AS ( definicja zapytania )   -- definicja tabeli CTE
--              [ , table2_CTE, ... ]                                  -- definicje kolejnych tabel CTE
--         SELECT [ atrybuty ] FROM tables_CTE ;                       -- zapytanie do tabel CTE


-- A) Ile różnych towarów kupili poszczególni klienci - wypisać nazwisko i ilość

WITH  zestaw AS (
    SELECT * FROM (
        lab.customer c JOIN lab.orderinfo o USING (customer_id)
    ) JOIN lab.orderline ol USING (orderinfo_id)
)
SELECT lname , COUNT (DISTINCT item_id) FROM zestaw GROUP BY customer_id, lname;



-- B) Ile sztuk poszczególnych towarów kupili poszczególni klienci - wypisać nazwisko, nazwę towaru i ilość

WITH  zestaw AS (
    SELECT * FROM (lab.customer c JOIN lab.orderinfo o USING (customer_id))
    JOIN lab.orderline ol USING (orderinfo_id)
), spis AS (SELECT * FROM  zestaw JOIN item USING(item_id))

SELECT lname , description, SUM  (quantity)
FROM spis
GROUP BY customer_id, lname, description;


-- C) Przeniesienie rekordów do innej tabeli

--przygotowujemy nowe tablice
CREATE TABLE lab.order_old
(
    orderinfo_id                    SERIAL,
    customer_id                     INTEGER NOT NULL,
    date_placed                     DATE NOT NULL,
    date_shipped                    DATE NOT NULL,
    shipping                        NUMERIC(7,2));


CREATE TABLE lab.orderinfo_1(
    orderinfo_1_id SERIAL Primary KEY,
    customer_id INTEGER NOT NULL REFERENCES customer(customer_id),
    date_placed DATE NOT NULL,
    date_shipped DATE,
    shipping NUMERIC(7,2)
);

 --składamy zamówienia
INSERT INTO lab.orderinfo_1(customer_id, date_placed, date_shipped, shipping) VALUES(3,'13-03-2000','17-03-2000', 2.99);
INSERT INTO lab.(customer_id, date_placed, date_shipped, shipping) VALUES(8,'23-06-2000','24-06-2000', 0.00);
INSERT INTO lab.orderinfo_1(customer_id, date_placed, date_shipped, shipping) VALUES(15,'02-09-2000','12-09-2000', 3.99);
INSERT INTO lab.orderinfo_1(customer_id, date_placed, date_shipped, shipping) VALUES(13,'03-09-2000','10-09-2000', 2.99);
INSERT INTO lab.orderinfo_1(customer_id, date_placed, date_shipped, shipping) VALUES(8,'21-07-2000','24-07-2000', 0.00);

--przenosimy zamówienia starsze od wyznaczonej daty do tabeli order_old
WITH moved_rows AS (
    DELETE FROM lab.orderinfo_1
    WHERE "date_placed" < '2000-06-25'
    RETURNING *
)
INSERT INTO lab.order_old SELECT * FROM moved_rows;




-- D) Zmiana zawartości tabeli i wypisanie ze starą wartością

WITH t (item_id, nazwa,cena_kupna,nowa_cena_sprzedazy) AS (
    UPDATE lab.item SET sell_price = sell_price * 1.05
    RETURNING *
)  --RETURNING zwraca rekordy (atrybuty) zmienione/wstawione
SELECT * FROM t join lab.item using (item_id);