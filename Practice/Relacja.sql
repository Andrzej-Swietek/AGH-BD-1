-- TWORZENIE TABEL
CREATE SCHEMA lab;
CREATE TABLE lab.customer
(
    customer_id                     serial                        ,
    title                           char(4)                       ,
    fname                           varchar(32)                   ,
    lname                           varchar(32)           not null,
    addressline                     varchar(64)                   ,
    town                            varchar(32)                   ,
    zipcode                         char(10)              not null,
    phone                           varchar(16)                   ,
    CONSTRAINT                      customer_pk PRIMARY KEY(customer_id)
);

CREATE TABLE lab.item
(
    item_id                         serial                        ,
    description                     varchar(64)           not null,
    cost_price                      numeric(7,2)                  ,
    sell_price                      numeric(7,2)                  ,
    CONSTRAINT                      item_pk PRIMARY KEY(item_id)
);


CREATE TABLE lab.orderinfo( orderinfo_id SERIAL,
                        customer_id INTEGER ,--nie moze byc NOT NULL bo przy usuwaniu z tabeli customer bedziemy wstawiali NULL
                        date_placed DATE NOT NULL,
                        date_shipped DATE,
                        shipping NUMERIC(7,2),
                        CONSTRAINT orderinfo_pk PRIMARY KEY(orderinfo_id),
                        CONSTRAINT orderinfo_customer_id_fk FOREIGN KEY(customer_id) REFERENCES lab.customer(customer_id)ON DELETE SET NULL);

CREATE TABLE lab.orderinfo( orderinfo_id SERIAL,
                        customer_id INTEGER NOT NULL,
                        date_placed DATE NOT NULL,
                        date_shipped DATE,
                        shipping NUMERIC(7,2),
                        CONSTRAINT orderinfo_pk PRIMARY KEY(orderinfo_id),
                        CONSTRAINT orderinfo_customer_id_fk FOREIGN KEY(customer_id) REFERENCES lab.customer(customer_id)ON DELETE CASCADE);


CREATE TABLE lab.orderline( orderinfo_id INTEGER NOT NULL,
                        item_id INTEGER NOT NULL,
                        quantity INTEGER NOT NULL,
                        CONSTRAINT orderline_pk PRIMARY KEY(orderinfo_id, item_id),
                        CONSTRAINT orderline_orderinfo_id_fk FOREIGN KEY(orderinfo_id) REFERENCES lab.orderinfo (orderinfo_id),
                        CONSTRAINT orderline_item_id_fk FOREIGN KEY(item_id) REFERENCES lab.item (item_id));

-- a) Iloczyn kartezjański tabel - generuje relację składającą się ze wszystkich możliwych krotek, będących kombinacjami dwóch krotek, po jednej z każdej wskazanej relacji. Iloczyn ten nazywamy też złączeniem krzyżowym.
SELECT * FROM lab.customer, lab.orderinfo;

-- b) Wszystkie zamówienia złożone przez Ann Stones - jeżeli pomiędzy relacjami istneje powiązanie 1-1 lub 1-N możemy wykorzytując klucz złączenia zrelizować selekcję rekordów, które spełniają wymaganie zgodności klucza kandydującego i klucza obcego.
SELECT c.fname, lab.orderinfo.orderinfo_id, lab.orderinfo.date_placed
FROM lab.customer c
    JOIN lab.orderinfo o ON lab.customer.customer_id=lab.orderinfo.customer_id
WHERE lab.customer.fname = 'Ann' AND lab.customer.lname = 'Stones';


-- c) Opis wszystkich zamówień złożonych przez Ann Stones wraz z identyfikatorami produktów i ilością
SELECT orderinfo.orderinfo_id, orderinfo.date_placed, orderinfo.date_shipped, orderline.item_id,orderline.quantity
FROM ((lab.customer JOIN lab.orderinfo ON lab.customer.customer_id = lab.orderinfo.customer_id)
    JOIN lab.orderline ON lab.orderinfo.orderinfo_id =  lab.orderline.orderinfo_id)
WHERE lab.customer.fname = 'Ann' AND lab.customer.lname = 'Stones';

SELECT lab.orderinfo.orderinfo_id, lab.orderinfo.date_placed, lab.orderinfo.date_shipped,
lab.orderline.item_id,lab.orderline.quantity FROM lab.customer, lab.orderinfo, lab.orderline
WHERE  lab.customer.customer_id = lab.orderinfo.customer_id
AND lab.orderinfo.orderinfo_id = lab.orderline.orderinfo_id
AND lab.customer.fname = 'Ann' AND lab.customer.lname = 'Stones';

-- d) Identyfikatory i opisy wszystkich zamówionych przez Ann Stones produktów.

SELECT  DISTINCT i.description,i.item_id
FROM lab.customer c, lab.orderinfo ord, lab.orderline ol, lab.item i
WHERE  c.customer_id = ord.customer_id
AND ord.orderinfo_id = ol.orderinfo_id
AND ol.item_id = i.item_id
AND fname = 'Ann' AND lname = 'Stones';