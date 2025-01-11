--     Partycje obliczeniowe i funkcje rankingowe
--         Tradycyjne wykorzystanie funkcji agregujących wymaga wykorzystania klauzuli GROUP BY grupującej rekordy.
--         Dla każdej grupy rekordów wyznaczana jest jedna wartość zaagregowana.
--         W ramach funkcjanalności partycji obliczeniowej możliwe jest wyznaczenie wartości zaagregowanej oddzielnie dla każdego rekordu grupy
--             (a nie raz dla wszystkich rekordów).
--
--         W celu skorzystania z tego rozwiązania należy wykorzystać wyrażenie PARTITION osadzone w wyrażeniu OVER().
--
--     funkcja_agregująca() OVER ( PARTITION BY atrybut )
--
--         funkcja_agregująca() - tradycyjna funkcja grupująca
--         atrybut - atrybut (wyrażenie) grupujący rekordy w celu wyliczenia funkcji


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
    );

-- Wyznaczyć kwotę sprzedaży w każdym rejonie i prowincji, z udziałem procentowym każdej kwoty dla prowincji w kwocie dla danego regionu

    with cte as (
        select region, province, sum(sales) as suma
        from sample
        group by region, province
    )
    select
        region,
        province,
        suma,
        sum(suma) over ( partition by region ) as suma_region,
        round(100*suma/(sum(suma) over (partition by region))) as "udzial_%"
    from cte;


--      Funkcje rankingowe umożliwiają wyznaczenie położenia rekordu w odniesieniu do pozostałych rekordów grupy względem wybranej funkcji porządkującej..


--     funkcja() over( [partition by wyrażenie1] order by wyrażenie2 [desc] )


--     funkcja() - funkcja rankingowa
--     wyrażenie1 - wyrażenie grupujące rekordy w rankingu. Brak wyrażenie oznacza, że w rankingu biorą udział wszystkie rekordy. Parametr opcjonalny.
--     wyrażenie2 - wyrażenie porządkujące rekordy wewnątrz grupy, parametr wymagany.
--     desc - parametr zmieniający porządek rankingu, od wartości największej do najmniejszej

--         RANK() i DENSE_RANK() - ranking zwykły, w RANK() wystąpienie tej samej pozycji rankingowej dla kilku rekordów powoduje przerwę w numeracji
--         CUME_DIST - ranking względny
--         PERCENT_RANK - ranking procentowy
--         ROW_NUMBER - numer rekorduy
--         NTILE - podział partycji na grupy

-- Numeracja rekordów

    with cte as (
     select
         region,
         province,
         sum(sales) as suma
     from sample
     group by region, province
    )
     select
         row_number() over(order by region) as nr,
        region,
        province,
        suma,
        sum(suma) over ( partition by region ),
        round(100*suma/(sum(suma) over (partition by region))) as "udzial_%"
    from cte;

-- Numerację wszystkich rekordów oraz rekordów w ramach każdego regionu


    with cte as (
        select region, province, sum(sales) as suma
        from sample
        group by region, province
    )
    select
        row_number() over(order by region) as nr,
        row_number() over (partition by region order by region ) as nl,
        region,
        province,
        suma,
        sum(suma) over ( partition by region ),
        round(100*suma/(sum(suma) over (partition by region))) as "udzial_%"
    from cte;


-- Analizy kategorii i podkategorii sprzedanych artykułów

    select
        product_category,
        product_sub_category,
        count(*)
    from sample
    group by
        product_category,
        product_sub_category
    order by 1,2;

    --
    with cte as (
        select
            product_category,
            product_sub_category,
            count(*)
        from sample
        group by
            product_category,product_sub_category
        order by 1,2
    )
    select
        product_category,
        product_sub_category,
        rank() over( order by product_category )
    from cte;

--
    with cte as (
        select
            product_category,
            product_sub_category,
            count(*)
        from sample
        group by
            product_category, product_sub_category
        order by 1,2
    )
    select
        product_category,
        product_sub_category,
        dense_rank() over( order by product_category )
    from cte;


-- Najlepiej sprzedające się produkty w danej podkategorii produktów

    select
        product_sub_category,
        sum(sales) as suma,
        rank() over ( order by sum(sales) desc ) as pozycja
    from sample
    group by product_sub_category
    order by suma desc, product_sub_category;


    with cte as (
        select
            product_category,
            product_sub_category,
            sum(sales) suma
        from sample
        group by
            product_category, product_sub_category
        order by 1,2
    )
    select
        product_category,
        product_sub_category,
        dense_rank() over( order by product_category ),
        rank() over(order by product_category),
        row_number() over( partition by product_category) as row_number_cat,
        row_number() over() as row_number_all,
        suma,
        sum(suma) over( partition by product_category)
    from cte;


-- Najlepsi klienci pod względem dokonanych zakupów

    select
        customer_name,
        sum(sales) as suma,
        rank() over( order by sum(sales) desc ) as ranking
    from sample
    group by customer_name
    order by suma desc, customer_name;


-- Procentowy ranking z bieżącego rekordu w stosunku do zbioru wartości w partycji
--      wyznacza jaki procent rekordów w partycji poprzedza w rankingu bieżący rekord (tzw.percentyl).
--      Wyznacza wartość w przedziale (0,1>. Do wyliczonej wartości jest dodawany bieżący rekord.

    select
        product_sub_category,sum(sales) as suma,
        cume_dist() over ( order by sum(sales) desc ) as cume_dist
    from sample
    group by product_sub_category
    order by suma desc, product_sub_category;


-- Procentowy ranking z bieżącego rekordu w stosunku do zbioru wartości w partycji

--      wyznacza jaki procent rekordów w partycji poprzedza w rankingu bieżący rekord (tzw.percentyl).
--      Wyznacza wartość w przedziale (0,1>. Do wyliczonej wartości nie jest dodawany bieżący rekord.

    select
        product_sub_category,
        sum(sales) as suma,
        percent_rank() over (
            order by sum(sales) desc
        ) as perc_rank
    from sample
    group by product_sub_category
    order by suma desc, product_sub_category;