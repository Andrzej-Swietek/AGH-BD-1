CREATE SCHEMA erd02;


-- Tabela: Osoba
CREATE TABLE erd02.Osoba (
    id SERIAL PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    data_urodzenia DATE NOT NULL,
    miejsce_urodzenia VARCHAR(100) NOT NULL
);

-- Tabela: Zgon (powiązana z Osoba)
CREATE TABLE erd02.Zgon (
    osoba_id INT PRIMARY KEY REFERENCES erd02.Osoba(id) ON DELETE CASCADE,
    data_zgonu DATE NOT NULL,
    miejsce_zgonu VARCHAR(100) NOT NULL
);

-- Tabela: Pokrewienstwo (relacja rodzic-dziecko)
CREATE TABLE erd02.Pokrewienstwo (
    rodzic_id INT REFERENCES erd02.Osoba(id) ON DELETE CASCADE,
    dziecko_id INT REFERENCES erd02.Osoba(id) ON DELETE CASCADE,
    PRIMARY KEY (rodzic_id, dziecko_id)
);

-- Tabela: Malzenstwo
CREATE TABLE erd02.Malzenstwo (
    malzonek1_id INT REFERENCES erd02.Osoba(id) ON DELETE CASCADE,
    malzonek2_id INT REFERENCES erd02.Osoba(id) ON DELETE CASCADE,
    data_slubu DATE NOT NULL,
    PRIMARY KEY (malzonek1_id, malzonek2_id)
);


-- Dane do tabeli Osoba
INSERT INTO erd02.Osoba (imie, nazwisko, data_urodzenia, miejsce_urodzenia) VALUES
('Jan', 'Kowalski', '1950-05-15', 'Krakow'),
('Anna', 'Nowak', '1952-08-22', 'Warszawa'),
('Piotr', 'Kowalski', '1975-11-30', 'Krakow'),
('Maria', 'Kowalska', '1980-07-20', 'Krakow'),
('Adam', 'Kowalski', '2005-04-10', 'Warszawa'),
('Ewa', 'Kowalska', '2008-09-25', 'Warszawa'),
('Zofia', 'Kowalska', '1925-04-18', 'Krakow'),
('Stanisław', 'Kowalski', '1922-03-01', 'Krakow'),
('Jacek', 'Nowak', '1948-12-12', 'Warszawa'),
('Barbara', 'Nowak', '1950-01-05', 'Warszawa'),
('Marek', 'Kowalski', '1978-07-02', 'Krakow'),
('Karolina', 'Kowalska', '1982-03-14', 'Krakow'),
('Tomasz', 'Kowalski', '2006-11-19', 'Warszawa'),
('Anna', 'Kowalska', '2009-01-30', 'Warszawa');

-- Dane do tabeli Zgon
INSERT INTO erd02.Zgon (osoba_id, data_zgonu, miejsce_zgonu) VALUES
(1, '2020-10-05', 'Krakow'),  -- Jan Kowalski zmarł
(7, '2005-08-12', 'Krakow'),  -- Zofia Kowalska zmarła
(8, '2010-02-22', 'Krakow');  -- Stanisław Kowalski zmarł

-- Relacje małżeńskie
INSERT INTO erd02.Malzenstwo (malzonek1_id, malzonek2_id, data_slubu) VALUES
(1, 2, '1973-06-15'),   -- Jan i Anna Nowak
(3, 4, '2002-05-18'),   -- Piotr i Maria Kowalska
(7, 8, '1948-10-25'),   -- Zofia i Stanisław Kowalscy
(9, 10, '1970-11-07');  -- Jacek i Barbara Nowak

-- Relacje pokrewieństwa
INSERT INTO erd02.Pokrewienstwo (rodzic_id, dziecko_id) VALUES
-- Rodzice Piotra i Marka
(1, 3), (2, 3),  -- Jan i Anna są rodzicami Piotra
(1, 11), (2, 11),  -- Jan i Anna są rodzicami Marka

-- Rodzice Marii i Karoliny
(7, 4), (8, 4),  -- Zofia i Stanisław są rodzicami Marii
(7, 12), (8, 12),  -- Zofia i Stanisław są rodzicami Karoliny

-- Rodzice Adama, Ewy, Tomasza, Anny
(3, 5), (4, 5),  -- Piotr i Maria są rodzicami Adama
(3, 6), (4, 6),  -- Piotr i Maria są rodzicami Ewy
(11, 13), (12, 13),  -- Marek i Karolina są rodzicami Tomasza
(11, 14), (12, 14);  -- Marek i Karolina są rodzicami Anny


-- a) Informacje o wybranej osobie (w tym o zgonie, jeśli dotyczy)
SELECT o.*, z.data_zgonu, z.miejsce_zgonu
FROM erd02.Osoba o
    LEFT JOIN erd02.Zgon z ON o.id = z.osoba_id
WHERE o.imie = 'Piotr' AND o.nazwisko = 'Kowalski';

-- b) Informacje o rodzicach wybranej osoby
SELECT rodzic.imie, rodzic.nazwisko, rodzic.data_urodzenia, rodzic.miejsce_urodzenia
FROM erd02.Osoba dziecko
    JOIN erd02.Pokrewienstwo p ON dziecko.id = p.dziecko_id
    JOIN erd02.Osoba rodzic ON rodzic.id = p.rodzic_id
WHERE dziecko.imie = 'Piotr' AND dziecko.nazwisko = 'Kowalski';

-- c) Czy osoba posiada dzieci, jeżeli tak to ich imiona
SELECT dziecko.imie, dziecko.nazwisko
FROM erd02.Osoba dziecko
    JOIN erd02.Pokrewienstwo p ON dziecko.id = p.dziecko_id
    JOIN erd02.Osoba rodzic ON rodzic.id = p.rodzic_id
WHERE rodzic.imie = 'Piotr' AND rodzic.nazwisko = 'Kowalski';
