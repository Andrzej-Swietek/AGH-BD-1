
--     W ramach bazy danych PostgreSQL - relacyjnej bazy danych typu OLTP (Online Transaction Processing) pojawiły się funkcjonalności dotąd dostępne w systemach OLAP (Online Analitycal Processing).
--     Dodatkowe możliwości dostępne w bazach danych umożliwiają bardziej wydajną analizę danych bez konieczności przenoszenia danych do systemów hurtowni danych z wbudowanymi technologiami do analizy OLAP,
--     czy do zewnętrznych aplikacji np. arkuszy kalkulacyjnych.
--     Funkcje analityczne są wykorzystywane wyłącznie w klauzulach SELECT oraz ORDER BY i nie mogą być używane w klauzulach WHERE, GROUP BY, HAVING.
--     Działają wyłącznie na wierszach będących wynikiem zapytania i nie odrzuconych przez WHERE lub HAVING.

    -- Przykladowa tabela
    CREATE TABLE sample (
          Row_id int,
          Order_id int,
          Order_data date,
          Order_priority varchar,
          Order_quantity int,
          Sales numeric(10,2),
          Discount numeric(10,2),
          Ship_mode varchar,
          Profit numeric(10,2),
          Unit_price numeric(10,2),
          Shipping_cost numeric(10,2),
          Customer_name varchar,
          Province varchar,
          Region varchar,
          Customer_segment varchar,
          Product_category varchar,
          Product_sub_category varchar,
          Product_name varchar,
          Product_container varchar,
          Product_basa_margin numeric(10,2),
          Ship_date date
    ) ;

--     Operatory grupujące

-- 1. liczba rekordów w tabeli sample

    SELECT COUNT(*) FROM sample;


-- 2. Regiony i prowincje w tabeli sample

    SELECT DISTINCT region, province FROM sample ORDER BY region;


-- 3. Liczba sprzedaży i suma sprzedaży dla każdego regionu

    select region,count(*),sum(sales) from sample
    group by region;


-- 4. Liczba sprzedaży i suma sprzedaży dla każdej prowincji

    select province,count(*),sum(sales) from sample
    group by province;


-- 5. Liczba sprzedaży i suma sprzedaży dla każdej prowincji w regionie

    select region, province,count(*),sum(sales) from sample
    group by region, province;


-- 6. Liczba sprzedaży i suma sprzedaży dla regionu i prowincji, regionu, prowincji i całkowita

    -- sumowanie po regionach i prowincjach
    select region,province,count(*),sum(sales) from sample group by region, province
    union
    -- sumowanie po regionach
    select region,null,count(*),sum(sales) from sample group by region
    union
    -- sumowanie po prowincjach
    select null,province,count(*),sum(sales) from sample group by province
    union
    -- sumowanie po wszystkich rekordach
    select null,null,count(*),sum(sales) from sample
    order by region, province;



-- GROUPING SETS
--      Rozszerza funkcjonalność klauzuli GROUP BY o możliwość wyboru zbiorów grup, które chcemy uzyskać w wyniku zapytania

--     SELECT {lista atrybutów}
--     FROM {lista relacji}
--     ...
--     GROUP BY GROUPING SETS(({lista wyrażeń grupujących 1}),
--                            ({lista wyrażeń grupujących 2}),
--                            ({lista wyrażeń grupujących 3})
--     )
--     ... ;

-- Liczba sprzedaży i suma sprzedaży dla regionu i prowincji, regionu, prowincji i całkowitą

    select
        region,
        province,
        count(*),
        sum(sales)
    from sample
    group by
        grouping sets ((region, province), (region), (province), ())
    order by region, province;




-- GROUP BY ROLLUP
--      Rozszerza funkcjonalność klauzuli GROUP BY pozwalając na wyznaczenie wartości funkcji grupowych na rosnących poziomach agregacji

--     SELECT {lista atrybutów} FROM {lista relacji}
--     ...
--     GROUP BY ROLLUP({lista wyrażeń grupujących})
--     ...;

    -- WARTOŚCI ZWRACANE

--     .. GROUP BY ROLLUP ( aa, bb, cc) ..
--     -- zwracane wartości
--     aa bb cc  (wartość zaagregowana)
--     aa bb     (wartość zaagregowana)
--     aa        (wartość zaagregowana)
--               (wartość zaagregowana)


-- Liczba sprzedaży i suma sprzedaży dla regionu i prowincji, regionu, prowincji i całkowitą

    select
        region,
        province,
        count(*),
        sum(sales)
    from sample
    group by
        rollup (region, province)
    order by region, province;



-- GROUP BY CUBE
--      Rozszerza funkcjonalność klauzuli GROUP BY pozwalając na wyznaczenie wartości funkcji grupowych na wszystkich kombinacjach poziomów agregacji.

--          Dla każdej grupy zwracany jest jeden rekord podsumowania.
--          Dla każdej kombinacji zwracany jest jeden rekord podsumowania.


    -- użycie

--     SELECT {lista atrybutów} FROM {lista relacji}
--     ...
--     GROUP BY CUBE({lista wyrażeń grupujących})
--     ...;


-- Liczba sprzedaży i suma sprzedaży dla regionu i prowincji, regionu, prowincji i całkowitą

    select
        region,
        province,
        count(*),
        sum(sales)
    from sample
    group by
        cube (region, province)
    order by
        region, province;



-- CROSSTAB ()
--      funkcja realizująca konstrukcję tabeli przestawnej PIVOT()


-- Informację o wartościach zagregowanych sprzedaży dla każdego miesiąca plus rok

    select
        extract(month from ship_date) as m,
        extract(year from ship_date) as y,
        count(*),
        sum(sales) as s
    from sample
    group by
        rollup (
            extract(month from ship_date),
            extract(year from ship_date)
        )
    order by 2, 1;


-- informację o wartościach zagregowanych sprzedaży dla każdego każdego miesiąca plus rok, każdego miesiąca, każdego roku

    select
        extract(month from ship_date) as m,
        extract(year from ship_date) as y,
        sum(sales) as s
    from sample
    group by
        cube (
            extract(month from ship_date),
            extract(year from ship_date)
        )
    order by 2, 1 ;

    --tworzymy tymczasową tabelę z poprzedniego zapytania

    create temp table temp1 as
    select
        extract(month from ship_date) as m,
        extract(year from ship_date) as y,
        sum(sales) as s
    from sample
    group by
        cube (
            extract(month from ship_date),
            extract(year from ship_date)
        )
    order by 2, 1 ;

-- utworzenie tabeli przestawnej

    select * from CROSSTAB(  'select  y::text, m::text, s from temp1' ) as fr
        ( Rok text, Styczen numeric, Luty  numeric,  Marzec  numeric, Kwiecien  numeric, Maj numeric, Czerwiec numeric, Lipiec numeric, Sierpien  numeric, Wrzesien numeric, Pazdziernik numeric, Listopad  numeric, Grudzien  numeric, Razem numeric) ;
