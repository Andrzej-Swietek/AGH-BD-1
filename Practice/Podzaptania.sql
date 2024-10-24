
-- Brak odwołania w zapytaniu podrzędnym (zagnieżdżonym) do zapytania nadrzędnego. Wewnętrzne zapytanie jest wykonywane tylko raz, a więc podzapytanie zwraca jeden wynik. Charakterystyczne dla zapytań niepowiązanych jest to, że zapytanie wewnętrzne można wykonać jako osobną instrukcję

-- Wypisać dane towaru (opis i cenę sprzedaży) i różnicę między jego ceną a średnią ceną sprzedaży towarów

SELECT i1.description, i1.sell_price - (
    SELECT CAST(AVG(i2. sell_price) AS NUMERIC(7,2))
    FROM lab.item i2
) as roznica
FROM lab.item i1;


-- Dane osób, które kiedykolwiek kupiły wybrany produkt

SELECT c.fname, c.lname
FROM lab.customer c
    JOIN lab.orderinfo o ON o.customer_id=c.customer_id
WHERE o.orderinfo_id IN (
    SELECT ol.orderinfo_id FROM lab.orderline ol
        WHERE ol.item_id IN (
            SELECT i.item_id
            FROM lab.item i
            WHERE i.description = 'Tissues'
        )
 );


-- Dane o zamówieniach złożonych przez klienta o nazwisku Howard

SELECT * FROM lab.orderinfo o
WHERE o.customer_id = (
    SELECT c.customer_id
    FROM lab.customer c
    WHERE c.lname = 'Howard'
);

-- Dane o zamówieniach złożonych przez klienta o nazwisku Stones

SELECT * FROM lab.orderinfo o
WHERE o.customer_id = (
    SELECT c.customer_id FROM lab.customer c
    WHERE c.lname = 'Stones'
);--bład mamy kilku Stones'ów


-- e) Dane o zamówieniach złożonych przez klienta o nazwisku Stones
SELECT * FROM lab.orderinfo o
WHERE o.customer_id IN (
    SELECT c.customer_id
    FROM lab.customer c
    WHERE c.lname = 'Stones'
);

-- f) Dane klientów, którzy nie złożyli żadnego zamówienia

SELECT c.fname, c.lname
FROM lab.customer c
WHERE c.customer_id NOT IN(
    SELECT o.customer_id
    FROM lab.orderinfo o
);

-- g) Identyfikatory towarów, które zostały zamówione w ilości równej zapasowi tego towaru w magazynie

SELECT s.item_id FROM stock s WHERE s.quantity = ANY (SELECT o.quantity FROM lab.orderline o);

SELECT s.item_id FROM stock s WHERE s.quantity IN (SELECT o.quantity FROM lab.orderline o);

-- h) Nazwy towarów droższych niż jakikolwiek towar, którego mamy w magazynie mniej niż 9 sztuk

SELECT i1.description, i1.sell_price
FROM lab.item i1
WHERE i1.sell_price > ALL (
    SELECT i2.sell_price
    FROM lab.item i2 JOIN stock s USING (item_id)
    WHERE s.quantity <9
)
ORDER BY i1.sell_price;

-- Podzapytania powiązane

SELECT c.lname || ' '||c.fname AS klient ,
(SELECT count(*) FROM lab.orderinfo o WHERE o.customer_id = c.customer_id  ) AS ile_razy_kupowal,
(SELECT count(*) FROM lab.orderinfo o, lab.orderline l WHERE o.customer_id = c.customer_id AND o.orderinfo_id = l.orderinfo_id GROUP BY o.customer_id  ) AS ile_kupil
FROM lab.customer c;
