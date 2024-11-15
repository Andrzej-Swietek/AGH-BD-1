-- CTE - Recursive
-- Wyrażenia CTE dają możliwość stosowania rekurencji (iteracji) w ich wnętrzu. Może to zostać wykorzystane w tabelach gdzie rekordy posiadają hierarchiczną zależność (SELF JOIN)
--
-- Definicja struktury wyrażeń rekurencyjnych WITH składa się z trzech elementów:
--
-- Określenia zapytania zakotwiczającego, jest to zazwyczaj zbiór elementów stanowiących korzeń .
-- Zapytania rekursywnego – skorelowanego z wynikiem zwracanym przez zapytanie poprzednie. Odwołujemy się tu do struktury hierarchicznej. Operator UNION (UNION ALL) łączy wszystkie przebiegi w finalny zbiór wynikowy. W każdym kroku działamy tylko na zbiorze zwracanym przez krok poprzedni.
-- Niejawnego warunku zakończenia rekurencji. Jeśli zapytanie rekurencyjne, skorelowane, nie zwróci żadnego elementu, działanie CTE zostaje porzerwane.
-- Struktura rekurencyjnego wyrażenia CTE.

--                 WITH RECURSIVE cte_name (
--                     CTE_definicja_zapytania    -- część nierekursywna ( zapytanie zakotwiczające )
--                     UNION [ALL]
--                     CTE_definicja_zapytania    -- cześć rekursywna ( zapytanie rekursyne,
--                                                -- skorelowane z wynikiem poprzedniego zapytania )
--                 ) SELECT * FROM cte_name;


-- Wypisanie 10 kolejnych liczb

WITH RECURSIVE test_with(n) AS (
   VALUES(1)
   UNION
   SELECT n+1 FROM test_with WHERE n < 10
)
SELECT * FROM test_with ORDER BY n;