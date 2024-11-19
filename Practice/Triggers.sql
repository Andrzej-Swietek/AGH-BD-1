--     Wyzwalacze
--     Wyzwalacz (TRIGGER) – specjalny typ procedury składowanej związany z jednym z elementów bazy danych (tabelą, widokiem, schematem lub całą bazą danych)
--     wywoływany automatycznie przez SZBD po spełnieniu pewnego warunku (zajściu zdarzenia).
--     Zdarzenie wywołujące wyzwalacz może być zdarzeniem systemowym lub jedną z instrukcji INSERT, DELETE lub UPDATE (na tabeli lub widoku).
--     Służą przede wszystkim do wykonywania stałych czynności i utrzymywania więzów integralności.
--     Najczęściej używamy wyzwalaczy dla tabel.
--

--     CREATE [ CONSTRAINT ] TRIGGER name { BEFORE | AFTER | INSTEAD OF } { event [ OR ... ] }
--       ON table_name
--       [ FROM referenced_table_name ]
--       [ NOT DEFERRABLE | [ DEFERRABLE ] [ INITIALLY IMMEDIATE | INITIALLY DEFERRED ] ]
--       [ FOR [ EACH ] { ROW | STATEMENT } ]
--       [ WHEN ( condition ) ]
--       EXECUTE PROCEDURE function_name ( arguments )
--
--     where event can be one of:
--
--     ?
--     INSERT
--     UPDATE [ OF column_name [, ... ] ]
--     DELETE
--     TRUNCATE

-- Modyfikacja wyzwalacza

ALTER TRIGGER trigger_name ON table_name RENAME TO new_name;

-- ALTER TABLE table_name DISABLE TRIGGER trigger_name | ALL --ALL wyłącza wszystkie trigger'y dla tabeli table_name

ALTER TABLE table_name DISABLE TRIGGER trigger_name | ALL --ALL wyłącza wszystkie trigger'y dla tabeli table_name


-- Włączanie wyzwalacza/wyzwalaczy

ALTER TABLE table_name ENABLE TRIGGER trigger_name | ALL --ALL włącza wszystkie trigger'y dla tabeli table_name


-- Usunięcie wyzwalacza/wyzwalaczy

DROP TRIGGER [IF EXISTS] trigger_name ON table_name;



--     Uruchomienie wyzwalacza
--     BEFORE – gdy chcemy, aby wyzwalacz zadziałał przed zajściem zdarzenia. Używamy go w celu zabezpieczenia przed zmianą danych
--     AFTER – gdy chcemy, aby wyzwalacz zadziałał po zajściu zdarzenia.
--
--     Poziom wyzwalacza

--     ROW – żądamy, aby wyzwalacz zadziałał dla każdego aktualizowanego wiersza (w przypadku gdy w wyniku zajścia zdarzenia mielibyśmy aktualizację więcej niż jednego wiersza).
--     Wyzwalacz zadziała tyle razy ile mamy wierszy aktualizowanych.
--     W ciele funkcji wyzwalacza nie może zostać wykonana żadna operacja odczytu lub modyfikacji danych tabeli lub perspektywy, dla której zdefiniowano wyzwalacz.
--     można bezpośrednio odwołać się do wartości atrybutów rekordu tabeli lub perspektywy, dla którego wyzwalacz został uruchomiony.

--     STATEMENT – żądamy, aby wyzwalacz zadziałał raz dla całej operacji aktualizacji.
--     niemożność bezpośredniego odwołania w ciele funkcji wyzwalacza do danych tabeli lub widoku, na której założono wyzwalacz.
--
--
-- Funkcje/Procedury Wyzwalane
--
--     Funkcja wyzwalana
--      - musi być zdefiniowana przed utworzeniem wyzwalacza.
--      - musi zwracać wartość NULL lub wiersz odpowiadający strukturze tabeli, dla której ją uruchomiono.
--         - dla wyzwalaczy typu AFTER, które wykonuje się po operacji UPDATE, zaleca się, aby procedura wyzwalana zwracała wartość NULL.
--         - dla wyzwalaczy typu BEFORE, zwracany wynik wykorzystuje się do sterowania aktualizacją, która ma być wykonana. Jeżeli procedura wyzwalana zwraca NULL, operacja UPDATE nie jest wykonywana, jeżeli zwracany jest wiersz danych, jest on wykorzystywany jako źródło aktualizacji, dając okazję procedurze wyzwalanej do zmiany danych przed zatwierdzeniem ich w bazie danych (procedura nie może zwracać NULL bo aktualizacja by nie została wykonana).
--         - W przypadku wyzwalaczy typu STATEMENT funkcja powinna zwracać NULL.
--
--
--     Procedura wyzwalana
--      - podobna do procedury składowanej, przy czym stosuje się do niej więcej ograniczeń. Tworzy się ją jako funkcję bez parametrów o specjalnym typie wyniku TRIGGER.
--      - Funkcja połączona z wyzwalaczem napisana w języku C otrzymuje dane za pośrednictwem struktury TriggerData.
--
--     Zmienne specjalne automatycznie udostępniane procedurom wyzwalanym:
--
--     Rekordy:
--     NEW – rekord zawierający nowy wiersz bazy danych lub jest NULL jeżeli użyto klauzuli FOR EACH STATEMENT ; występuje dla INSERT/UPDATE
--     OLD – rekord zawierający stary wiersz bazy danych lub jest NULL jeżeli użyto klauzuli FOR EACH STATEMENT ; występuje dla UPDATE/DELETE
--
--                                                                                                                Zmienne tekstowe:
--     TG_NAME – zawiera nazwę wyzwalacza
--     TG_WHEN – zawiera typ wyzwalacza (BEFORE lub AFTER)
--     TG_LEVEL – zawiera definicję wyzwalacza (ROW lub STATEMENT)
--     TG_OP – zawiera zdarzenia wywołujące wyzwalacz (INSERT, UPADTE lub DELETE)
--     TG_RELNAME – nazwa tabeli dla której uruchomiono wyzwalacz
--     Inne:
--     TG_ARGV[] – tablica, zawiera parametry procedury (rozpoczyna się od indeksu 0, dla niepoprawnego indeksu otrzymamy NULL )
--     TG_NARGS – liczba argumentów wyzwalacza



-- Tworzenie wyzwalacza


-- A. Monitorowanie zmian w bazie danych.

-- zapis do tabeli operacji dokonanych w bazie danych
-- Tabela person
CREATE TABLE person (
    id serial primary key,
    groups char(2),
    first_name varchar(40) NOT NULL,
    last_name varchar(40) NOT NULL);

--Tabela audit zapis operacji w bazie danych
CREATE TABLE audit (
    table_name varchar(15) not null,
    operation varchar,
    time_at timestamp not null default now(),
    userid name not null default session_user
);
-------------------------------------------------------------------
-- Funkcja  zapisujaca operacje do tabeli audit
CREATE OR REPLACE FUNCTION audit_log ()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    BEGIN

    INSERT INTO audit (table_name, operation) VALUES (TG_RELNAME, TG_OP);

    RETURN NEW;
    END;
    $$;
-------------------------------------------------------------------

-- Wyzwalacz monitorujacy działania na tabeli person

    CREATE TRIGGER person_audit AFTER INSERT OR UPDATE OR DELETE ON person
    FOR EACH ROW EXECUTE PROCEDURE audit_log();


-------------------------------------------------------------------
-- Sprawdzenie poprawnosci opracowanego wyzwalacza

    INSERT INTO person VALUES ( 1, 'A', 'Adam', 'Abacki' )  ;

    SELECT * FROM person ;
    SELECT * FROM audit ;

-- zapis do tabeli starych danych po dokonaniu zmiany

--Tabela przechowujaca stare dane (nazwisko)

CREATE TABLE change (
    id serial primary key,
    person_id int4 NOT NULL,
    last_name varchar(40) NOT NULL,
    changed_on timestamp(6) NOT NULL
);

-------------------------------------------------------------------

--Funkcja archiwizujaca nazwisko jeżeli zostało zmieniona

CREATE OR REPLACE FUNCTION log_last_name_changes()RETURNS trigger AS $$
BEGIN
IF NEW.last_name <> OLD.last_name THEN
    INSERT INTO change(person_id,last_name,changed_on) VALUES (OLD.id,OLD.last_name,now());
END IF;
RETURN NEW;
END $$
LANGUAGE 'plpgsql';

-------------------------------------------------------------------

--Wyzwalacz monitorujacy działania na tabeli person

CREATE TRIGGER last_name_changes BEFORE UPDATE ON person
FOR EACH ROW EXECUTE PROCEDURE log_last_name_changes();

-------------------------------------------------------------------

-- Sprawdzenie poprawności opracowanego wyzwalacza

INSERT INTO person VALUES ( 2, 'B', 'Jan', 'Janecki' )  ;
INSERT INTO person VALUES ( 3, 'A', 'Anna', 'Adamska' )  ;

UPDATE person SET last_name = 'Kowalski' WHERE id = 2;

SELECT * FROM person ;
SELECT * FROM change ;





-- B. Testowanie poprawności wprowadzonych danych.


-- Funkcja sprawdzajaca poprawnosc wprowadzonych danych
CREATE OR REPLACE FUNCTION valid_data ()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    BEGIN
    IF LENGTH(NEW.last_name) = 0 THEN
        RAISE EXCEPTION 'Nazwisko nie moze byc puste.';
                RETURN NULL; --Anulujemy
    END IF;

    RETURN NEW;  --Akceputacja modyfikacji
    END;
    $$;

-------------------------------------------------------------------
-- Wyzwalacz monitorujacy poprawnosc danych dla tabeli person

CREATE TRIGGER person_valid
    AFTER INSERT OR UPDATE  ON person
    FOR EACH ROW EXECUTE PROCEDURE valid_data();

-------------------------------------------------------------------
-- Sprawdzenie poprawnosci opracowanego wyzwalacza

INSERT INTO person VALUES ( 12, 'AA', '','');

DROP TRIGGER person_valid ON person;



-- C. Modyfikacja wprowadzanych danych do tabeli.


-- Funkcja normalizujaca wprowadzone dane do bazy danych

    CREATE OR REPLACE FUNCTION norm_data () RETURNS TRIGGER AS $$
    BEGIN
      IF NEW.last_name IS NOT NULL THEN
         NEW.last_name := lower(NEW.last_name);
         NEW.last_name := initcap(NEW.last_name);
      END IF;
      RETURN NEW;
    END;
    $$ LANGUAGE 'plpgsql';

-------------------------------------------------------------------
-- Przypisanie wyzwalacza do tabeli person

CREATE TRIGGER person_norm BEFORE INSERT OR UPDATE ON person
      FOR EACH ROW
      EXECUTE PROCEDURE norm_data();
-------------------------------------------------------------------

INSERT INTO person VALUES
    ( 6, 'bb', 'Adam','babacki'),
        ( 7, 'bb', 'Marek','cabacki'),
        ( 8, 'cc', 'Adam','kabacki'),
        ( 9, 'dd', 'Teresa','Zak');



-- D. Testowanie danych na podstawie informacji z innych tabel.


CREATE TABLE person_group ( name varchar(15), nc int ) ;  --nazwa grupy; maksymalna ilosc osob w  grupie

INSERT INTO person_group VALUES ( 'aa', 2), ( 'bb', 3 ), ( 'cc', 4 ) ;

-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION group_count() RETURNS TRIGGER AS $$
        BEGIN
                IF EXISTS(SELECT 1 FROM person_group WHERE name = New.groups and nc > (SELECT count(*) FROM person WHERE groups LIKE New.groups )) THEN
                -- rekord zostanie dodany lub zaktualizowany
                        RETURN NEW;
                ELSE
                        RAISE NOTICE 'Za duzo osob w grupie %.',New.groups;
                        RETURN NULL;
                END IF;
        END;
$$ LANGUAGE 'plpgsql';

-------------------------------------------------------------------

CREATE TRIGGER person_test_insert BEFORE INSERT OR UPDATE ON person
        FOR EACH ROW EXECUTE PROCEDURE group_count();

-------------------------------------------------------------------

INSERT INTO person VALUES ( 21, 'aa', 'Adam','Babacki'),
    ( 22, 'cc', 'Marek','Cabacki'),
    ( 23, 'aa', 'Adam','Babacki'),
    ( 24, 'a', 'Teresa','Dadacka');

-------------------------------------------------------------------

DROP TRIGGER person_test_insert ON person;




-- E. Wprowadzanie danych do tabel powiązanych.


CREATE TABLE person_data ( id int, city varchar(30), email varchar(30), telefon varchar(15) );

ALTER TABLE person_data ADD PRIMARY KEY (id);
INSERT INTO person_data (id) SELECT id FROM person;
ALTER TABLE person_data ADD FOREIGN KEY (id) REFERENCES person(id);

-------------------------------------------------------------------
CREATE OR REPLACE FUNCTION insert_data () RETURNS TRIGGER AS $$
    BEGIN
          INSERT INTO person_data (id) VALUES (New.id) ;
      RETURN NEW;
    END;
    $$ LANGUAGE 'plpgsql';

-------------------------------------------------------------------

CREATE TRIGGER person_insert AFTER INSERT ON person
        FOR EACH ROW EXECUTE PROCEDURE insert_data();


INSERT INTO person VALUES ( 21, 'bb', 'Zygmunt','Bielecki');

SELECT * from person;
SELECT * FROM person_data;
SELECT * FROM audit;



-- F.  Wprowadzanie danych do tabel powiązanych - tabela asocjacyjna.
-- Chcemy wysyłać do wszystkich naszych klientów magazyn reklamowy, za każdym razem kiedy tylko pojawi się nowe wydanie (czyli, kiedy zostanie dodana pozycja Magazyn_XXXX do tabeli item) .
-- Dodajemy automatycznie zamówienie do tabeli orderinfo (przy czym musimy uzupełnić jeszcze tabelę asocjacyjną orderline z liczbą zamówionych Magazynów równa 1).

CREATE FUNCTION customer_magazine_trigger() RETURNS TRIGGER AS $$
DECLARE
    customer_record record;
    item_record record;
    cust integer;
    max_orderinfo integer;
    itemid integer;
BEGIN
    SELECT count(*) INTO cust FROM customer;
    SELECT * INTO customer_record FROM customer;
    SELECT * INTO item_record FROM item where substr(upper(description),1,7)=substr(upper(new.description),1,7);

    FOR item_record IN SELECT * FROM item where substr(upper(description),1,7)=substr(upper(new.description),1,7)
        LOOP
            itemid:=item_record.item_id;
        END LOOP;
    SELECT max(orderinfo_id) INTO max_orderinfo FROM orderinfo;
    IF (cust>0 AND substr(upper(new.description),1,7)=upper(tg_argv[0]))
    THEN
        RAISE NOTICE 'Trzeba wysylac magazyn do % klientow' ,cust;
    FOR customer_record IN SELECT * FROM customer
        LOOP
            max_orderinfo=max_orderinfo+1;
            --zapis do tabeli orderinfo
            INSERT INTO orderinfo (orderinfo_id, customer_id, date_placed, shipping) VALUES
            (max_orderinfo, customer_record.customer_id, now(), 0.0);
            --zapis do tabeli asocjacyjnej
            INSERT INTO orderline(orderinfo_id,item_id,quantity) values (max_orderinfo, itemid,1);
        END LOOP;
    ELSE
        IF (cust=0)
        THEN
            RAISE NOTICE 'Brak klientow do ktorych moznaby wyslac magazyn';
        END IF;
    END IF;
RETURN new;
END;
$$ LANGUAGE 'plpgsql';

-------------------------------------------------------------------

CREATE TRIGGER trig_customer AFTER INSERT ON item FOR EACH ROW
EXECUTE PROCEDURE customer_magazine_trigger(Magazyn);  --argument wywołania dostepny przez tablicę tg_argv


INSERT INTO  item (description, cost_price,sell_price) values('Magazyn - Luty', 0.1, 0.0);





--- Wyzwalacze INSTEAD OF
--     Wyzwalacz INSTEAD OF stosuje się WYŁACZNIE dla widoków niemodyfikowalnych, czyli takich, które zostały stworzony z wykorzystaniem minimum jednej z poniższych instrukcji:
--
--     złożone złączenia
--     operator DISTINCT
--     klauzule GROUP BY
--     funkcje grupujące

CREATE VIEW miasta AS SELECT town, COUNT(*) FROM customer GROUP BY town;

-- Próba usunięcia rekordu z widoku kończy się błędem


CREATE OR REPLACE FUNCTION view_miasta() RETURNS TRIGGER AS $$
BEGIN
IF TG_OP = 'INSERT' THEN
  RAISE NOTICE 'Nie mozna wstawic nowego miasta' ;
  RETURN NULL;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE customer SET town = NEW.town WHERE town LIKE OLD.town;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
        DELETE FROM customer WHERE town=OLD.town;
    RETURN NULL;
END IF;
RETURN NEW;
END;
$$LANGUAGE 'plpgsql';

--Tworzymy wyzwalacz

CREATE TRIGGER miasta_instead INSTEAD OF INSERT OR UPDATE OR DELETE ON miasta
   FOR EACH ROW EXECUTE PROCEDURE view_miasta();

-- Teraz usuniecie rekordu z widoku miasta pociąga za sobą usunięcie wszystkich rekordów z podaną nazwą miasta w tabeli customer.

DELETE FROM miasta WHERE town LIKE 'Nicetown';

-- Zmiana miasta w widoku zmienia nazwę miasta w tabeli customer.

UPDATE miasta SET town = 'Krakow' WHERE town LIKE 'Histon';
