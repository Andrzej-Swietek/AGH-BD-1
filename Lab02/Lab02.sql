CREATE TABLE IF NOT exists Wykladowca
(
	wykładowca_id INT PRIMARY KEY,
	nazwisko	 varchar(32) not null,
	funkcja		 varchar(32) not null,
	kierownik_id INT,
	rok_zatrudnienia INT not null check (wynagrodzenie >= 1990),
	wynagrodzenie INT not null check (wynagrodzenie >= 1000),
	instytut varchar(128) not null
);


-- ## Wypelnienie ##
INSERT INTO Wykladowca (wykładowca_id, nazwisko, funkcja, kierownik_id, rok_zatrudnienia, wynagrodzenie, instytut) VALUES
(1, 'Nowak', 'Profesor', NULL, 1995, 5000, 'Instytut Informatyki'),
(2, 'Kowalski', 'Adiunkt', 1, 2000, 3000, 'Instytut Informatyki'),
(3, 'Wiśniewski', 'Asystent', 1, 2021, 4000, 'Instytut Informatyki'),
(4, 'Lewandowski', 'Profesor', NULL, 1998, 6000, 'Instytut Matematyki'),
(5, 'Kamiński', 'Adiunkt', 4, 2005, 3200, 'Instytut Matematyki'),
(6, 'Wójcik', 'Asystent', 4, 2020, 2100, 'Instytut Matematyki'),
(7, 'Zieliński', 'Profesor', NULL, 1993, 5500, 'Instytut Fizyki'),
(8,'Szymański', 'Adiunkt', 7, 2010, 2900, 'Instytut Fizyki'),
(9, 'Woźniak', 'Asystent', 7, 2022, 2200, 'Instytut Fizyki'),
(10, 'Dąbrowski', 'Profesor', NULL, 1992, 7000, 'Instytut Chemii'),
(11, 'Majewski', 'Adiunkt', 10, 2012, 3500, 'Instytut Chemii'),
(12, 'Jankowski', 'Asystent', 10, 2021, 2000, 'Instytut Chemii'),
(13, 'Olszewski', 'Adiunkt', 1, 2015, 2800, 'Instytut Informatyki'),
(14, 'Król', 'Asystent', 4, 2019, 2040, 'Instytut Matematyki'),
(15, 'Wiśniewska', 'Asystent', 7, 2021, 2001, 'Instytut Fizyki');

-- ## Zapytania ##

-- Listę wszystkich pracowników ( nazwisko, płaca, staż - ilość lat pracy) posortowaną według funkcji, nazwiska kierownika
select w.nazwisko, w.wynagrodzenie as "płaca", CAST(2024-w.rok_zatrudnienia AS INT) as "staż"
from 
	wykladowca w
	inner join wykladowca kierownik on kierownik.wykładowca_id  = w.kierownik_id 
--where w.kierownik_id is NOT null
order by w.funkcja, kierownik.nazwisko;


-- Wypisać dane (nazwisko, instytut, rok_zatrudnienia) kierowników
select nazwisko, instytut, rok_zatrudnienia 
from wykladowca 
where kierownik_id IS null;


-- Wypisać dane (nazwisko, instytut) wszystkich pracowników z daną (wybraną) funkcja
select nazwisko, instytut
from wykladowca
where funkcja LIKE 'Asystent';

-- Wypisać posortowaną listę  funkcji
SELECT DISTINCT funkcja
FROM wykladowca
ORDER BY funkcja;


-- Podnieść wszystkim podwładnym (nie kierownikom) wynagrodzenie o 10%
UPDATE wykladowca
SET wynagrodzenie = wynagrodzenie * 1.10
WHERE kierownik_id IS NOT NULL;

-- Wypisać dane  nazwisko i funkcja osób zarabiających między 1000 a 3000.
SELECT nazwisko, funkcja
FROM wykladowca
WHERE wynagrodzenie 
BETWEEN 1000 AND 3000;


-- Usunąć pracowników, którzy pracują krócej niż rok
DELETE FROM wykladowca
WHERE EXTRACT(YEAR FROM CURRENT_DATE) - rok_zatrudnienia < 1;


