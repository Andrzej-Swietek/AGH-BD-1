-- 1. Wszystkie przystanki dla danej linii z kolejnością:
SELECT l.name AS linia, s.name AS przystanek, ls.sequence_number AS kolejnosc
    FROM erd01.line_stop ls
    JOIN erd01.stop s ON ls.stop_id = s.stop_id AND ls.coordinate_id = s.coordinate_id
    JOIN erd01.line l ON ls.line_id = l.line_id
WHERE l.name = 'Linia 1'
ORDER BY ls.sequence_number;


-- 2. Godziny odjazdów dla danego przystanku i linii:
SELECT d.departure_time AS godzina_odjazdu, l.name AS linia, s.name AS przystanek
    FROM erd01.departure d
    JOIN erd01.line_stop ls ON d.line_stop_id = ls.line_stop_id
        JOIN erd01.line l ON ls.line_id = l.line_id
            JOIN erd01.stop s ON ls.stop_id = s.stop_id AND ls.coordinate_id = s.coordinate_id
WHERE s.name = 'Rynek Główny' AND l.name = 'Linia 1';


--3. Wszystkie linie przejeżdżające przez dany przystanek:
SELECT DISTINCT l.name AS linia, s.name AS przystanek
FROM erd01.line_stop ls
JOIN erd01.line l ON ls.line_id = l.line_id
JOIN erd01.stop s ON ls.stop_id = s.stop_id AND ls.coordinate_id = s.coordinate_id
WHERE s.name = 'Kazimierz';


-- 4. Znajdź wszystkie przystanki z kierunkiem "2" (dla przystanków dwukierunkowych):
SELECT name AS przystanek, direction AS kierunek
FROM erd01.stop
WHERE direction = 2;


-- 5. Znajdź linię o największej liczbie przystanków
SELECT l.name AS line_name, COUNT(ls.stop_id) AS num_stops
    FROM erd01.line_stop ls
    JOIN erd01.line l ON ls.line_id = l.line_id
GROUP BY l.name
ORDER BY num_stops DESC
LIMIT 1;


-- 6. Znajdź przystanki, które znajdują się w określonej odległości od konkretnej współrzędnej (np. Rynek Główny
SELECT s.name AS stop_name,
       SQRT(POWER(c.x - 50.061, 2) + POWER(c.y - 19.938, 2)) AS distance
    FROM erd01.stop s
    JOIN erd01.coordinate c ON s.coordinate_id = c.coordinate_id
WHERE SQRT(POWER(c.x - 50.061, 2) + POWER(c.y - 19.938, 2)) <= 0.005
ORDER BY distance;


-- 7. Znajdź wszystkie linie i przystanki dla konkretnego typu transportu (np. Tramwaj)
SELECT l.name AS line_name, s.name AS stop_name
    FROM erd01.line_stop ls
    JOIN erd01.line l ON ls.line_id = l.line_id
    JOIN erd01.stop s ON ls.stop_id = s.stop_id AND ls.coordinate_id = s.coordinate_id
WHERE l.type = 'Tramwaj'
ORDER BY l.name, ls.sequence_number;


-- 8. Znajdź wszystkie trasy przechodzące przez kilka wybranych przystanków (np. "Rynek Główny" i "Wawel")
SELECT l.name AS line_name
    FROM erd01.line_stop ls
    JOIN erd01.line l ON ls.line_id = l.line_id
    JOIN erd01.stop s ON ls.stop_id = s.stop_id AND ls.coordinate_id = s.coordinate_id
WHERE s.name IN ('Rynek Główny', 'Wawel')
GROUP BY l.name
HAVING COUNT(DISTINCT s.stop_id) = 2;


-- 9. Wyświetl godziny odjazdów dla każdego przystanku w kolejności trasowania na danej linii
SELECT s.name AS stop_name, d.departure_time, ls.sequence_number
    FROM erd01.line_stop ls
    JOIN erd01.stop s ON ls.stop_id = s.stop_id AND ls.coordinate_id = s.coordinate_id
    JOIN erd01.departure d ON ls.line_stop_id = d.line_stop_id
WHERE ls.line_id = (SELECT line_id FROM erd01.line WHERE name = 'Linia 1')
ORDER BY ls.sequence_number, d.departure_time;


-- 10. Znajdź najbliższy przystanek do podanej lokalizacji
SELECT s.name AS stop_name,
       SQRT(POWER(c.x - 50.061, 2) + POWER(c.y - 19.938, 2)) AS distance
FROM erd01.stop s
JOIN erd01.coordinate c ON s.coordinate_id = c.coordinate_id
ORDER BY distance
LIMIT 1;


-- 11. Wyświetl wszystkie trasy dostępne między dwoma przystankami (np. "Rynek Główny" i "Zakrzówek")
SELECT DISTINCT l.name AS line_name
FROM erd01.line_stop ls1
    JOIN erd01.line_stop ls2 ON ls1.line_id = ls2.line_id
    JOIN erd01.line l ON ls1.line_id = l.line_id
    JOIN erd01.stop s1 ON ls1.stop_id = s1.stop_id AND ls1.coordinate_id = s1.coordinate_id
    JOIN erd01.stop s2 ON ls2.stop_id = s2.stop_id AND ls2.coordinate_id = s2.coordinate_id
WHERE s1.name = 'Rynek Główny' AND s2.name = 'Zakrzówek';
