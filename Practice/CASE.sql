-- CASE
-- CASE dla każdego wiersza zwracanego w wyniku zapytania sprawdza warunek i w zależności od wyniku wypisuje komunikat podany po słowie kluczowym THEN.
-- Instrukcja CASE może wystąpić również w innych fragmentach zapytania SQL.
-- Można ją użyć w ramach kluzuli WHERE i HAVING, ale również w klauzuli GROUP BY i ORDER BY.


-- Porównanie z wartością lub zawartością danej kolumny.

-- SELECT a1, a2,
--    CASE wartość_lub_kolumna
--      WHEN wartosc_1 THEN wynik_1
--      WHEN wartosc_2 THEN wynik_2
--      WHEN wartosc_3 THEN wynik_3
--      [ ELSE wynik_gdy_brak_na_liscie ]
--    END
-- FROM relacja;


-- Porównanie z wyznaczoną wartością logiczną

-- SELECT a1, a2,
--     CASE
--         WHEN wyrazenie_logiczne_1 THEN wynik_1
--         WHEN wyrazenie_logiczne_2 THEN wynik_2
--         WHEN wyrazenie_logiczne_3 THEN wynik_3
--         [ ELSE wynik_gdy_brak_na_liscie ]
--     END
-- FROM relacja;


-- A) Zyskiem określimy różnicę między ceną sprzedaży i zakupu.

SELECT description, (sell_price - cost_price) AS zysk FROM lab.item; --jaka jest różnica między ceną sprzedaży a ceną zakupu

SELECT description,
       CASE
           WHEN sell_price - cost_price < 0 THEN 'Strata'
           WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4   THEN  'Zysk'
           ELSE   'Super'
       END
FROM lab.item;



-- B) Ile towarów przynosi zysk, ile jest super, a ile przynosi stratę

SELECT  SUM ( CASE  WHEN sell_price - cost_price < 0 THEN 1 ELSE  0  END  ) AS "Strata",
        SUM (  CASE  WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4   THEN 1 ELSE  0  END  ) AS "Zysk",
        SUM (  CASE  WHEN sell_price - cost_price > 4   THEN 1 ELSE  0  END  ) AS "Super"
FROM lab.item;


-- C) Jaki jest sumaryczny jednostkowy zysk w poszczególych "grupach zysku"

SELECT  SUM (
                CASE
                    WHEN sell_price - cost_price < 0 THEN sell_price - cost_price
                    ELSE  0
                END
        ) AS "Strata",
        SUM (
                CASE
                    WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4   THEN sell_price - cost_price
                    ELSE  0
                END
        ) AS "Zysk",
        SUM (
                CASE  WHEN sell_price - cost_price > 4   THEN sell_price - cost_price
                ELSE  0  END
        ) AS "Super"
FROM lab.item;


-- D) Jaki jest sumaryczny jednostkowy zysk w poszczególych "grupach zysku"- CASE w GROUP BY

SELECT  SUM(sell_price - cost_price), (
    CASE
        WHEN sell_price - cost_price < 0 THEN 'Strata'
        WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4   THEN  'Zysk'
        ELSE   'Super'
    END
) AS kolumna_zysk

FROM lab.item GROUP BY
                CASE
                    WHEN sell_price - cost_price < 0 THEN 'Strata'
                    WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4 THEN  'Zysk'
                    ELSE   'Super'
                END;


-- E) Za ile sprzedano towarów poszczególnych zamówieniach

SELECT orderinfo_id AS numer_zamowienia, SUM ( sell_price * quantity ) AS Sprzedaz
FROM lab.orderline
    JOIN lab.item USING (item_id) GROUP BY orderinfo_id;


-- F) Za ile sprzedano towarów z poszczególnych "grup zysku" - kwerenda krzyżowa

SELECT SUM (
               CASE
                   WHEN sell_price - cost_price < 0 THEN sell_price * quantity
                   ELSE  0
               END
       ) AS "Strata",
       SUM (
               CASE
                   WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4   THEN sell_price * quantity
                   ELSE  0
               END
       ) AS "Zysk",
      SUM (
               CASE
                   WHEN sell_price - cost_price > 4   THEN sell_price * quantity
                   ELSE  0
               END
      ) AS "Super"
FROM lab.orderline JOIN lab.item USING (item_id);


-- G) Za ile sprzedano towarów z poszczególnych "grup zysku" w poszczególnych zamówieniach

SELECT orderinfo_id, SUM ( CASE WHEN sell_price - cost_price < 0 THEN sell_price * quantity ELSE  0  END) AS "Strata",
                     SUM (  CASE  WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4   THEN sell_price * quantity  ELSE  0  END  ) AS "Zysk",
                     SUM (  CASE  WHEN sell_price - cost_price > 4   THEN sell_price * quantity ELSE  0  END  ) AS "Super"
FROM lab.orderline
    JOIN lab.item USING (item_id) GROUP BY orderinfo_id;