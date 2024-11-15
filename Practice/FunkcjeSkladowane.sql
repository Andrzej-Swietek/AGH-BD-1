-- Funkcje składowane
-- W ramach bazy danych PostgreSQL istnieje możliwość definiowania własnych funkcji. Do realizacji ich można wykorzystać język SQL lub wbudowany w bazę danych język PL/pgSQL. Możliwe jest także tworzenie funkcji z wykorzytsaniem języków proceduralnych tj. C, perl czy python. W tym przypadku przygotowane biblioteki dołączamy do bazy danych a poprzez polecenia DDL ( CREATE FUNCTION ) tworzymy odpowiednie obiekty w bazie danych z funkcjonalnością realizowaną przez zewnętrzne programy.
--
-- Polecenie tworzące (modyfikujące) funkcję/procedurę
--
-- CREATE [OR REPLACE] FUNCTION nazwa_funkcji ([typ_funkcji])
--        RETURNS typ_wyniku_funkcji AS
--                  definicja_funkcji
-- LANGUAGE nazwa_języka;


-- Polecenie usuwające procedurę
--
-- DROP FUNCTION nazwa_funkcji([lista typów])
--


--     Funkcje są zapisywane w tabeli systemowej pg_proc
--
--     \df  -- Wyświetlenie funkcji użytkownika - polecenie z interfejsu psql
--
--     \d pg_proc
--
--     SELECT prosrc FROM pg_proc WHERE proname='nazwa_funkcji' ;  -- Polecenie SQL wyświetlające zawartość proceduryv


--     Procedury składowane w języku SQL
--     Aby wykorzystać język SQL do tworzenia funkcji należy język procedury określić jako 'SQL'.
--     Funkcje te przyjmują parametry, do których odwołujemy się poprzez $1, $2 itd. Nie istnieją instrukcje sterujące . Wartością zwracaną przez funkcję są dane zwracane przez ostatnio wykonaną instrukcję SQL (zwykle SELECT).
--


-- 1.  Lista mieszkanców mieszkających w wybranym mieście

CREATE FUNCTION lab.klienci_1(text)
RETURNS SETOF lab.customer AS $$
     SELECT * FROM lab.customer WHERE town=$1;
$$
LANGUAGE SQL;


-- Wykorzystanie funkcji lab.klienci_1(text)

SELECT lab.klienci_1('Bingham');          -- funkcja w obszarze argumentów
 SELECT * FROM lab.klienci_1('Bingham');   -- funkcja w obszarze źródeł danych ( po FROM )
 SELECT lname(lab.klienci_1('Bingham')) AS customer;   --tylko jedna kolumna

DROP FUNCTION lab.klienci_1(text); -- usunięcie funkcji klienci_1(text)



-- 2. Lista mieszkanców mieszkających w wybranym mieście bez SETOF

CREATE FUNCTION lab.klienci_2(text)
RETURNS  lab.customer AS $$
     SELECT * FROM lab.customer WHERE town=$1;
$$
LANGUAGE SQL;


-- Wykorzystanie funkcji lab.klienci_2(text)

 SELECT lab.klienci_2('Bingham');          -- funkcja w obszarze argumentów
 SELECT * FROM lab.klienci_2('Bingham');   -- funkcja w obszarze źródeł danych ( po FROM )
 SELECT lname(lab.klienci_2('Bingham')) AS customer;   --tylko jedna kolumna

DROP FUNCTION lab.klienci_2(text); -- usunięcie funkcji klienci_2(text)


-- Procedury składowane w języku PL/pqSQL

--  Jest to język blokowo-strukturalny, udostepniający deklaracje zmiennych i posiadający zakresy bloków.
--  W języku PL/pqSQL nie jest ważna wielkość liter dla słów kluczowych.
--  Komentarze w pojedynczym wierszu poprzedzone są dwoma minusami (--), a komentarze blokowe mają postać taką jak w C (/* */).


-- 1. Funkcja licząca pole koła

CREATE OR REPLACE FUNCTION lab.fun_1(int4) RETURNS float8 AS
$$        -- otwarcie bloku programu
DECLARE   -- blok deklaracji
    n integer := 1;
    my_pi CONSTANT float8 = pi();
    r ALIAS FOR $1; -- alias argumentów
BEGIN
    RETURN my_pi * r * r;
END;
$$ --zamkniecie bloku programu
LANGUAGE plpgsql;  -- deklaracja języka
---------------------------------------------------------

CREATE OR REPLACE FUNCTION lab.fun_1(int4, int4) RETURNS float8 AS
$$        -- otwarcie bloku programu
DECLARE   -- blok deklaracji
    n integer := 1;
    r ALIAS FOR $1; -- alias argumentów
BEGIN
    RETURN $2 * r;
END;
$$ --zamkniecie bloku programu
LANGUAGE plpgsql;  -- deklaracja języka


-- Wywołanie funkcji

SELECT lab.fun_1(10);

SELECT lab.fun_1(10,12);

-- 2. Funkcja zwracająca nazwisko klienta o zadanym id. Typ zmiennej przypisany do typu atrybutu w tabeli.

CREATE OR REPLACE FUNCTION lab.fun_2 ( int ) RETURNS text AS
$$
  DECLARE
     id_k ALIAS FOR $1;
     name customer.lname%TYPE;       -- przypisanie typu atrybutu do zmiennej
  BEGIN
     SELECT INTO name lname FROM customer WHERE customer_id = id_k ;
     RETURN name;
  END;
$$ LANGUAGE plpgsql;


-- Wywołanie funkcji

SELECT lab.fun_2(10);

SELECT lab.fun_2(123);


-- 3. Funkcja zwracająca informacje o kliencie o zadanym id. Typ zmiennej przypisany do typu rekordu w tabeli.

CREATE OR REPLACE FUNCTION lab.fun_3 ( int )
RETURNS text AS
$$
  DECLARE
     id_k ALIAS FOR $1;
     name customer%ROWTYPE;             -- przypisanie typu rekordu  do zmiennej
  BEGIN
     SELECT * INTO name  FROM customer WHERE customer_id = id_k ;
     RETURN name.fname || ' ' || name.lname;
  END;
$$ LANGUAGE plpgsql;

-- Wywołanie funkcji

SELECT lab.fun_3(1) ;


-- 4. Funkcja zwracająca imię i nazwisko klienta o zadanym id. Typ zmiennej przypisany do typu RECORD w tabeli.

CREATE OR REPLACE FUNCTION lab.fun_4 ( int )
    RETURNS text AS
    $$
      DECLARE
         id_k ALIAS FOR $1;
         name RECORD;                        -- przypisanie typu RECORD
      BEGIN
         SELECT  fname, lname INTO name FROM customer WHERE customer_id = id_k ;
         RETURN name.fname || ' ' || name.lname;
      END;
    $$ LANGUAGE 'plpgsql';

-- Wywołanie funkcji

SELECT lab.fun_4(1) ;



-- Obsługa błędów w PL/pgSQL - RAISE
--
-- Obsługa błędów jest ważnym elementem procedur działających w ramach bazy danych. W ramach obsługi funkcji mamy możliwość wykorzystania polecenia RAISE, które udostępnia przekazanie informacji do użytkownika jak i do systemowego logu. Dodatkowo istnieje możliwość przesyłania do użytkownia standardowego kodu błędu w ramach parametru SQLSTATE.


-- Obsługa polecenia RAISE

DO $$
BEGIN
  RAISE INFO 'information message %', now() ;
  RAISE LOG 'log message %', now(); --zapisywane do bazy danych
  RAISE DEBUG 'debug message %', now();  --zapisywane do bazy danych
  RAISE WARNING 'warning message %', now();
  RAISE NOTICE 'notice message %', now();
END $$;


-- Dodatkowa klauzula USING w ramach RAISE

DO $$
DECLARE
  test text := '[błędna wartość]' ;
BEGIN
  -- ... kod aplikacji
  -- raport o błędzie i podpowiedź
  RAISE EXCEPTION 'Błędne dane: %', test
 USING HINT = 'Podpowiedź dla użytkownika';
END $$;



-- Wysłanie kodu błędu - SQLSTATE

DO $$
BEGIN
  RAISE SQLSTATE '00200' ;
END $$;


-- Wyświetlenie klienta, w przypadku braku rekordu sygnalizacja błędu


CREATE OR REPLACE FUNCTION lab.fun_5 (id_k int) RETURNS text AS $$
DECLARE
    rec_klient customer%ROWTYPE;
BEGIN
    SELECT INTO rec_klient *  FROM customer WHERE customer_id = id_k;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Klienta % nie ma w bazie', id_k;
    END IF;
    RETURN  rec_klient.fname || ' ' || rec_klient.lname;
END;
$$
LANGUAGE 'plpgsql';



SELECT lab.fun_5(1) ;

SELECT lab.fun_5(21) ;



-- Pętle w języku PL/pgSQL

-- Realizacja pętli z konstrukcją LOOP
DO $$
DECLARE
  i INTEGER := 0;
BEGIN
  LOOP
    EXIT WHEN i>9;
    i := i + 1;
    RAISE NOTICE 'i: %',i;
  END LOOP;
END; $$ ;


-- Realizacja pętli z konstrukcją WHILE
DO $$
DECLARE
  i INTEGER := 0;
BEGIN
  WHILE i < 10 LOOP
    i := i + 1;
    RAISE NOTICE 'i: %',i;
  END LOOP;
END; $$;


--  Realizacja pętli z konstrukcją FOR
DO $$
BEGIN
  FOR i IN 1..10 LOOP
    RAISE NOTICE 'i: %',i;
  END LOOP;
END; $$;


-- Lista uczestników wyszukiwanych atrybutem LIKE. Typ zwracanych danych TABLE.

CREATE OR REPLACE FUNCTION lab.fun_6 (p_pattern VARCHAR)
         RETURNS TABLE ( im VARCHAR, naz VARCHAR ) AS            -- zwracany typ danych  tablica
        $$
        BEGIN
         RETURN QUERY
           SELECT fname, lname FROM lab.customer WHERE lname LIKE p_pattern ;
        END;
        $$ LANGUAGE 'plpgsql';


SELECT * FROM lab.fun_6('H%');


-- Modyfikacja danych, pętla LOOP.

CREATE OR REPLACE FUNCTION lab.fun_7 (p_pattern VARCHAR)
         RETURNS TABLE ( im VARCHAR, naz VARCHAR ) AS
        $$
        DECLARE
            var_r RECORD;
        BEGIN
         FOR var_r IN (SELECT fname, lname FROM lab.customer WHERE lname LIKE p_pattern )
         LOOP
                im  := var_r.fname ;
                naz := upper(var_r.lname);
                RETURN NEXT; --dodaje rekord do zwracanej tabeli
         END LOOP;
        END;
        $$  LANGUAGE 'plpgsql';



SELECT * FROM lab.fun_7('H%');




-- Klienci, wybór sortowanie { 'U' - nazwisko, kupiony towar, 'I' - kupiony towar, nazwisko }, ustwienie liczby zwróconych wierszy. Wykorzystanie dynamicznej realizacji zapytań w ramach EXECUTE ... USING.

CREATE OR REPLACE FUNCTION lab.fun_8 ( sort_type char(1), n INTEGER )
RETURNS TABLE ( im VARCHAR, naz VARCHAR, opis VARCHAR ) AS
$$
DECLARE
    rec RECORD;
    query text;
BEGIN
    query := 'SELECT c.fname AS im, c.lname AS naz, i.description AS opis FROM lab.customer c JOIN lab.orderinfo oi  USING (customer_id)
                                                                  JOIN lab.orderline ol USING ( orderinfo_id )
                                                                  JOIN lab.item i Using (item_id) ';
   IF sort_type = 'U' THEN
      query := query || 'ORDER BY naz, opis ';
   ELSIF sort_type = 'I' THEN
      query := query || 'ORDER BY opis, naz ';
   ELSE
      RAISE EXCEPTION 'Niepoprawny typ sortowania %', sort_type;
   END IF;

   query := query || ' LIMIT $1';

   FOR rec IN EXECUTE query USING n
      LOOP
      RAISE NOTICE '% - %', n, rec.naz;
        im   := rec.im   ;
        naz  := rec.naz  ;
        opis := rec.opis ;
        RETURN NEXT;
   END LOOP;

END;
$$ LANGUAGE plpgsql;

SELECT * FROM lab.fun_8('U',12);
SELECT * FROM lab.fun_8('I',7);



-- Kursory w języku PL/pgSQL

-- Lista klientów o padanym nazwisku.

CREATE OR REPLACE FUNCTION lab.fun_9 (stext text) RETURNS text AS
$$
DECLARE
  records TEXT DEFAULT '';
  rec_klient   RECORD;
  cur_klient CURSOR FOR SELECT * FROM lab.customer ;
  id INTEGER;
BEGIN
   id := 0 ;
   OPEN cur_klient ;           -- otwarcie kursora
   LOOP
      FETCH cur_klient INTO rec_klient;  -- pobranie rekordu z kursora do zmiennej rec_klient
      EXIT WHEN NOT FOUND;         -- zamkniecie jak brak dalszych rekordow
                          -- tworzenie rekordu wynikowego
      IF rec_klient.lname LIKE stext AND id != 0 THEN
         records := records || ',' || rec_klient.fname || ':' || rec_klient.lname;
      END IF;
      IF rec_klient.lname LIKE stext AND id = 0 THEN
         records := rec_klient.fname || ':' || rec_klient.lname;
         id := 1 ;
      END IF;

   END LOOP;
   CLOSE cur_klient;           -- zamkniecie kursora
   RETURN records;
END;
$$ LANGUAGE plpgsql;



SELECT * FROM lab.fun_9('Stones');
SELECT * FROM lab.fun_9('Marks');







