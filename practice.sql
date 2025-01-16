--1) ilość osób zatrudnionych na poszczególnym zaszeregowaniu - zestawienie ilość_osób , stopien_zaszeregowania
WITH CTE AS (SELECT pracownik_id, wynagordzenie, stopien_id
             FROM pracownik
                      JOIN stopien
                           ON wynagordzenie >= stopien.min_wynagrodzenie AND wynagordzenie <= stopien.max_wynagrodzenie)
SELECT COUNT(*) AS ilość_osób, stopien_id
FROM CTE
GROUP BY stopien_id;


--2) dla każdego pracownika (id , nazwisko) zestawienie ilość_projektow_ukonczonych i ilość_projektow_nieukonczonych (sumarycznie)
WITH projekty AS (SELECT pracownik_id, nazwisko, koniec
                  FROM pracownik_projekt
                           JOIN pracownik USING (pracownik_id)
                           JOIN projekt USING (projekt_id))
SELECT pracownik_id AS ID, nazwisko, count(*) - count(koniec) AS nieukonczone, count(koniec) AS ukonczone
FROM projekty
GROUP BY pracownik_id, nazwisko;

--3) hierarchia zatrudnienia -->  (id , nazwisko, hierarchiczna_lista_podwładnych)
-- lista podwładnych ma działać również dla większej ilości danych w tabeli pracownicy

-- Z dołu do góry hierarchi by sprawdzić poprawność zapytania
-- WITH RECURSIVE CTE AS (SELECT pracownik_id, nazwisko, 1 AS lvl, '' AS path
--                        FROM pracownik
--                        WHERE manager_id IS NULL
--                        UNION ALL
--                        SELECT p.pracownik_id, p.nazwisko, lvl + 1, concat(path, '->', p.nazwisko)
--                        FROM pracownik p
--                                 JOIN CTE r ON (r.pracownik_id = p.manager_id))
-- SELECT *
-- FROM CTE;

-- Z góry do dołu
WITH RECURSIVE
    levels AS (SELECT pracownik_id, nazwisko, manager_id, 1 AS lvl
               FROM pracownik
               WHERE manager_id IS NULL
               UNION ALL
               SELECT p.pracownik_id, p.nazwisko, p.manager_id, lvl + 1
               FROM pracownik p
                        JOIN levels r ON (r.pracownik_id = p.manager_id)),
    max AS (SELECT MAX(lvl) FROM levels),
    leafs AS (SELECT *
              FROM levels,
                   max
              WHERE lvl = max.max),
    CTE AS (SELECT pracownik_id, nazwisko, manager_id, '' AS path
            FROM leafs
            UNION ALL
            SELECT p.pracownik_id, p.nazwisko, p.manager_id, concat(path, ' ', r.nazwisko) AS path
            FROM pracownik p
                     JOIN CTE r ON (r.manager_id = p.pracownik_id))
SELECT pracownik_id, nazwisko, REPLACE(TRIM(path), ' ', '->') AS podwładni
FROM CTE
GROUP BY pracownik_id, nazwisko, path
ORDER BY CHAR_LENGTH(path) DESC;



--4) lista pracowników (id , nazwisko), którzy byli zatrudnieni w co najmniej dwóch projektach, w których
-- było zatrudnionych co najmniej dwóch różnych  pracowników
WITH zestawienie_ilosci_pracownikow AS (SELECT projekt_id, COUNT(DISTINCT pracownik_id) AS ilosc_pracowników
                                        FROM pracownik_projekt
                                        GROUP BY projekt_id),
     zestawienie_pracownik_ilosc_projektow AS (SELECT pracownik_id, COUNT(*) AS ilość_projektów
                                               FROM pracownik_projekt
                                               GROUP BY pracownik_id)
SELECT DISTINCT pracownik_id,
                (SELECT nazwisko FROM pracownik WHERE lp.pracownik_id = pracownik.pracownik_id)
FROM zestawienie_ilosci_pracownikow ip,
     zestawienie_pracownik_ilosc_projektow lp
WHERE ilosc_pracowników >= 2
  AND ilość_projektów >= 2
GROUP BY pracownik_id, projekt_id;


--5) projekt (nazwa), w którym było zatrudnionych najwięcej pracowników (bez LIMIT)
WITH data AS (SELECT nazwa, count(pracownik_id) AS ilosc_pracowników
              FROM pracownik_projekt
                       JOIN projekt USING (projekt_id)
              GROUP BY nazwa),
     aggregation AS (SELECT nazwa, rank() OVER (ORDER BY ilosc_pracowników DESC ) AS rank FROM data)
SELECT nazwa
FROM aggregation
WHERE rank = 1;

--6) dla każdego pracownika (id , nazwisko) średnia_ilość_dni  trwania  projektu, w którym pracował
WITH data AS (SELECT pracownik_id, nazwisko, EXTRACT(DAY FROM COALESCE(koniec, NOW()) - projekt.poczatek) AS days
              FROM pracownik_projekt
                       JOIN pracownik USING (pracownik_id)
                       JOIN projekt USING (projekt_id))
SELECT pracownik_id, nazwisko, AVG(data.days) AS srednia_ilosc_dni
FROM data
GROUP BY pracownik_id, nazwisko;

--7) lista projektów (nazwa ) i ich budżet  - suma kosztów pracowników
SELECT nazwa,
       (SUM(wynagordzenie) * (EXTRACT(DAY FROM COALESCE(koniec, NOW()) - projekt.poczatek)) /
        30.436875) AS koszt_projektu
FROM pracownik_projekt
         JOIN projekt USING (projekt_id)
         JOIN pracownik USING (pracownik_id)
GROUP BY nazwa, koniec, poczatek;

--8) ile projektów nieukończonych trwa dłużej  15 dni
WITH data AS (SELECT projekt_id, EXTRACT(DAY FROM NOW() - projekt.poczatek) AS days
              FROM pracownik_projekt
                       JOIN pracownik USING (pracownik_id)
                       JOIN projekt USING (projekt_id)
              WHERE koniec IS NULL
              GROUP BY projekt_id, poczatek)
SELECT COUNT(*) AS ilosc
FROM data
WHERE days > 15;

--9) w ilu projektach brały udział osoby z poszczególnych grup zaszeregowania (stopien_zaszeregowania , ilosc_projektów)
WITH CTE AS (SELECT pracownik_id, stopien_id
             FROM pracownik
                      JOIN stopien
                           ON wynagordzenie >= stopien.min_wynagrodzenie AND wynagordzenie <= stopien.max_wynagrodzenie)
SELECT stopien_id, COUNT(projekt_id) AS ilosc_projektów
FROM CTE
         JOIN pracownik_projekt USING (pracownik_id)
GROUP BY stopien_id;

--10) nazwa projektu, który trwał najdłużej (bez LIMIT)
WITH data AS (SELECT projekt_id, nazwa, EXTRACT(DAY FROM COALESCE(koniec, NOW()) - projekt.poczatek) AS days
              FROM pracownik_projekt
                       JOIN projekt USING (projekt_id)
              GROUP BY projekt_id, koniec, poczatek, nazwa),
     ranks AS (SELECT projekt_id, nazwa, rank() OVER (ORDER BY days DESC) FROM data)
SELECT *
FROM ranks
WHERE rank = 1;
