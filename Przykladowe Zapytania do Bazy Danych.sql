
--- Podaj dane kierowc�w posiadaj�cych tylko kategori� prawa jazdy B ------------------------------------------------------------

SELECT [DBO].[Pracownicy].id, [DBO].[Pracownicy].nazwisko, [DBO].[Pracownicy].staz_pracy, [DBO].[Kierowcy].numer_telefonu, [DBO].[Kierowcy].kat_prawo_jazdy 
FROM [DBO].[Kierowcy]
LEFT JOIN [DBO].[Pracownicy]
ON [Kierowcy].id = [DBO].[Pracownicy].id
WHERE kat_prawo_jazdy = 'B'
GO

--- Podaj nazwiska kierowc�w mog�cych realizowa� zlecenie wymagaj�ce przyczepy --------------------------------------------------

SELECT [DBO].[Pracownicy].nazwisko, [DBO].[Kierowcy].kat_prawo_jazdy
FROM [DBO].[Kierowcy]
LEFT JOIN [DBO].[Pracownicy]
ON [DBO].[Kierowcy].id = [DBO].[Pracownicy].id
WHERE kat_prawo_jazdy LIKE '_E'
GO

--- Podaj liczb� kierowc�w w firmie --------------------------------------------------------------------------------------------

SELECT COUNT(*) AS LiczbaKierowcow
FROM [DBO].[Pracownicy]
WHERE stanowisko = 'Kierowca'
GO

--- OR ---

SELECT COUNT(*) AS LiczbaKierowcow
FROM [DBO].[Kierowcy]
GO

--- Podaj samochody czekaj�ce na przypisanie im kierowcy ----------------------------------------------------------------------

SELECT nr_rejestracyjny FROM [DBO].[Samochody]
EXCEPT
SELECT nr_rejestracyjny FROM [DBO].[Kierowcy]
GO

--- Podaj 10 najnowszych zlece� w firmie -------------------------------------------------------------------------------------

SELECT TOP 10 * FROM [DBO].[Zlecenia]
ORDER BY Data_rozpoczecia DESC
GO

--- Podaj informacje o zleceniach czekaj�cych na przypisanie do kierowcy ----------------------------------------------------

/*
UWAGA W przypadku utworzenia zapytania na wy�wietlenie wszystkich informacji o zleceniach czekaj�cych na realizacj� wymagane jest zastosowanie zapytania tworz�cego tabeli tymczasowej co nie powinno sprawi� problemu przy uprawnieniach "Read Only" jednak dla pewno�ci warto sprawdzi� uprawnienia.
*/

SELECT nr_zlecenia
INTO #MyTempTable 
FROM [DBO].[Zlecenia]
EXCEPT 
SELECT
nr_zlecenia
FROM [DBO].[Kierowcy]
GO

SELECT * FROM [DBO].[Zlecenia]
JOIN #MyTempTable
ON [DBO].[Zlecenia].nr_zlecenia = #MyTempTable.nr_zlecenia
WHERE [DBO].[Zlecenia].nr_zlecenia = #MyTempTable.nr_zlecenia
GO

DROP TABLE #MyTempTable
GO

--- Podaj numer rejestracyjny samochodu, przyczepy i szczeg�y realizowanego zlecenia przez kierowc� o nazwisku 'Moroz' ----

SELECT [DBO].[Pracownicy].nazwisko, [DBO].[Kierowcy].nr_rejestracyjny AS NrRejSamochodu, [DBO].[Samochody].nr_rej_przyczepy AS NrRejPrzyczepy, [DBO].[Kierowcy].nr_zlecenia, [DBO].[Zlecenia].liczba_osob, [DBO].[Zlecenia].waga_towaruWtonach, [DBO].[Zlecenia].Data_rozpoczecia, [DBO].[Zlecenia].Data_zakonczenia
FROM [DBO].[Kierowcy]
JOIN [DBO].[Pracownicy]
ON [DBO].[Pracownicy].id = [DBO].[Kierowcy].id
JOIN [DBO].[Zlecenia]
ON [DBO].[Zlecenia].nr_zlecenia = [DBO].[Kierowcy].nr_zlecenia
JOIN [DBO].[Samochody]
ON [DBO].[Samochody].nr_rejestracyjny = [DBO].[Kierowcy].nr_rejestracyjny
JOIN [DBO].[Przyczepy]
ON [DBO].[Samochody].nr_rej_przyczepy = [DBO].[Przyczepy].nr_rejestracyjny
WHERE Pracownicy.nazwisko = 'Moroz'
GO

--- Podaj wszystkie zaj�te przyczepy wraz z nazwiskami kierowc�w, kt�rzy je zabrali do zlecenia --------------------------

SELECT [DBO].[Samochody].nr_rej_przyczepy, [DBO].[Pracownicy].nazwisko 
FROM [DBO].[Kierowcy]
JOIN [DBO].[Pracownicy]
ON [DBO].[Pracownicy].id = [DBO].[Kierowcy].id
JOIN [DBO].[Samochody]
ON [DBO].[Samochody].nr_rejestracyjny = [DBO].[Kierowcy].nr_rejestracyjny
WHERE nr_rej_przyczepy IS NOT NULL
GO

--- Podaj wszystkie zlecenia przetrzymywane w bazie ---------------------------------------------------------------------

SELECT nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia 
FROM [DBO].[Zlecenia]
UNION 
SELECT * FROM [DBO].[ZleceniaArchiwalne]
GO

--- Podaj liczb� posiadaczy ka�dego typu Prawa Jazdy -------------------------------------------------------------------

SELECT COUNT(kat_prawo_jazdy) AS LiczbaPosiadaczy, kat_prawo_jazdy
FROM [DBO].[Kierowcy]
GROUP BY kat_prawo_jazdy
GO

--- Podaj nazwiska kierowc�w, kt�rzy planuj� zako�czy� swoje zlecenia w lutym -----------------------------------------

SELECT [DBO].[Pracownicy].nazwisko, [DBO].[Zlecenia].nr_zlecenia, [DBO].[Zlecenia].Data_rozpoczecia, [DBO].[Zlecenia].Data_zakonczenia
FROM [DBO].[Zlecenia]
JOIN [DBO].[Kierowcy]
ON [DBO].[Zlecenia].nr_zlecenia = [DBO].[Kierowcy].nr_zlecenia
JOIN [DBO].[Pracownicy]
ON [DBO].[Pracownicy].id = [DBO].[Kierowcy].id
WHERE Data_zakonczenia BETWEEN '2019-02-01' AND '2019-02-28'
GO

--- Zaktualizuj baz� by zlecenia, kt�re ju� si� zako�czy�y nie by�y wykonywane przez kierowc�w ------------------------

/* 
Komenda archiwizuje zlecenia z dat� zako�czenia p�niejsz� ni� dzisiejsza do tabeli [DBO].[ZleceniaArchiwalne], a nast�pnie usuwa zlecenia z listy [DBO].[Kierowcy], kt�rych data zako�czenia jest p�niejsza ni� aktualna data, usuwa r�wnie� pojazdy z listy [DBO].[Kierowcy] w przypadku, gdy kierowca nie ma przypisanego, z listy [DBO].[Samochody] usuwa przyczepy, gdy pojazd nie ma przypisanego kierowcy i zmienia kategori� pojazdu bez przyczepy z BE,CE,DE na B,C,D.
*/
--- Archiwizacja zako�czonych zlece�
INSERT INTO [DBO].[ZleceniaArchiwalne]
SELECT nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia FROM [DBO].[Zlecenia]
WHERE Data_zakonczenia < GETDATE()
GO 

DELETE FROM [DBO].[Zlecenia]
WHERE Data_zakonczenia < GETDATE()
GO
--- aktualizacja [DBO].[Kierowcy] o zako�czone zlecenia
UPDATE [DBO].[Kierowcy]
SET nr_rejestracyjny = NULL
WHERE nr_zlecenia IS NULL
GO

SELECT nr_rejestracyjny
INTO #MyTempTable
FROM [DBO].[Samochody]
EXCEPT
SELECT nr_rejestracyjny
FROM [DBO].[Kierowcy]
GO
 --- Aktualizacja [DBO].[Samochody] i [DBO].[Przyczepy] o zwolnione przyczepy z powodu zako�czonych zlece�
UPDATE [DBO].[Samochody]
SET nr_rej_przyczepy = NULL
FROM #MyTempTable
JOIN [DBO].[Samochody]
ON #MyTempTable.nr_rejestracyjny = [DBO].[Samochody].nr_rejestracyjny
WHERE #MyTempTable.nr_rejestracyjny = [DBO].[Samochody].nr_rejestracyjny
GO

UPDATE [DBO].[Samochody]
SET kategoria_pojazdu = 'B'
WHERE kategoria_pojazdu = 'BE' AND nr_rej_przyczepy IS NULL
GO

UPDATE [DBO].[Samochody]
SET kategoria_pojazdu = 'C'
WHERE kategoria_pojazdu = 'CE' AND nr_rej_przyczepy IS NULL
GO

UPDATE [DBO].[Samochody]
SET kategoria_pojazdu = 'D'
WHERE kategoria_pojazdu = 'DE' AND nr_rej_przyczepy IS NULL
GO

DROP TABLE #MyTempTable
GO

--- wy�wietlenie zaktualizowanej bazy
SELECT Pracownicy.nazwisko, Kierowcy.id, Kierowcy.numer_telefonu, Kierowcy.kat_prawo_jazdy, Kierowcy.nr_rejestracyjny, Kierowcy.nr_zlecenia
FROM Kierowcy
LEFT JOIN Pracownicy
ON Pracownicy.id = Kierowcy.id

SELECT * FROM ZleceniaArchiwalne

SELECT * FROM Zlecenia

GO

--- Zaktualizuj baz� by nowe, zlecenie trafi�o bezpo�rednio do wolnego pracownika -----------------------------------
/*
Zestaw komend odpowiadaj�cy za parowanie wolnego pracownika z nie przypisanym zleceniem, a nast�pnie dobraniem do niego wolnego samochodu i (je�eli wymaga tego zlecenie) odpowiedniej przyczepy. Komenda polega na zaktualizowaniu nowych zam�wie� o wymagan� kategori� prawa jazdy kierowcy, stworzeniu pary samoch�d i przyczepa w ka�dej kategorii (B+E, C+E, D+E), dopasowaniu wolnego zlecenia do wolnego kierowcy, dopasowaniu do kierowcy wolnego samochodu i (je�eli wymaga tego zlecenie) przyczepy i na zako�czenie operacji usuni�ciu tymczasowych par wolny samoch�d + wolna przyczepa.
*/

--- Komendy aktualizuj�ce [DBO].[Zlecenia] o wymagan� kategori� prawa jazdy kierowcy do realizacji zam�wienia (na wypadek pojawienia si� nowych zam�wie� w bazie)
UPDATE [DBO].[Zlecenia]
SET kat_prawo_jazdy = 'B'
WHERE waga_towaruWtonach <= 1.5 AND liczba_osob <= 2
GO

UPDATE [DBO].[Zlecenia]
SET kat_prawo_jazdy = 'B'
WHERE waga_towaruWtonach = 0 AND liczba_osob > 2 AND liczba_osob <= 8
GO

UPDATE [DBO].[Zlecenia]
SET kat_prawo_jazdy = 'BE'
WHERE waga_towaruWtonach <= 1 AND waga_towaruWtonach != 0 AND liczba_osob > 2 AND liczba_osob <= 8
GO

UPDATE [DBO].[Zlecenia]
SET kat_prawo_jazdy = 'BE'
WHERE waga_towaruWtonach > 1.5 AND waga_towaruWtonach <= 2.5
GO

UPDATE [DbO].[Zlecenia]
SET kat_prawo_jazdy = 'C'
WHERE waga_towaruWtonach > 2.5 AND waga_towaruWtonach <= 6 AND liczba_osob <= 2
GO

UPDATE [DBO].[Zlecenia]
SET kat_prawo_jazdy = 'CE'
WHERE waga_towaruWtonach > 6 AND liczba_osob <= 2
GO

UPDATE [DBO].[Zlecenia]
SET kat_prawo_jazdy = 'D'
WHERE waga_towaruWtonach = 0 AND liczba_osob < 49 AND liczba_osob > 8 
GO

UPDATE [DBO].[Zlecenia]
SET kat_prawo_jazdy = 'DE'
WHERE waga_towaruWtonach <= 1 AND waga_towaruWtonach != 0 AND liczba_osob < 49 AND liczba_osob > 8
GO

--- tworzenie po jednej parze samoch�d + przyczepa w tabeli [DBO].[Samochody] na wypadek pojawienia si� zlecenia z kategori� BE, CE, DE
CREATE TABLE TempTable1 (nr_rejestracyjny char(7) NULL, ladownoscWtonach decimal(5,3) NULL)
GO

INSERT INTO [DBO].[TempTable1] (nr_rejestracyjny)
SELECT nr_rejestracyjny
FROM [DBO].[Przyczepy]
EXCEPT
SELECT nr_rej_przyczepy
FROM [DBO].[Samochody]

UPDATE [DBO].[TempTable1]
SET [DBO].[TempTable1].ladownoscWtonach = [DBO].[Przyczepy].ladownoscWtonach
FROM [DBO].[Przyczepy]
JOIN [DBO].[TempTable1]
ON [DBO].[TempTable1].nr_rejestracyjny = [DBO].[Przyczepy].nr_rejestracyjny
WHERE [DBO].[TempTable1].nr_rejestracyjny = [DBO].[Przyczepy].nr_rejestracyjny
GO

ALTER TABLE [DBO].[TempTable1]
ADD Kategoria char(2) NULL
GO

UPDATE TOP (1) [DBO].[TempTable1]
SET Kategoria = 'B'
WHERE ladownoscWtonach = 1
GO

UPDATE TOP (1) [DBO].[TempTable1]
SET Kategoria = 'C'
WHERE ladownoscWtonach = 8
GO

UPDATE TOP (1) [DBO].[TempTable1]
SET Kategoria = 'D'
WHERE ladownoscWtonach = 1
AND
Kategoria IS NULL
GO

SET ROWCOUNT 1

UPDATE [DBO].[Samochody]
SET [DBO].[Samochody].nr_rej_przyczepy = [DBO].[TempTable1].nr_rejestracyjny,
[DBO].[Samochody].kategoria_pojazdu = 'BE'
FROM [DBO].[TempTable1]
JOIN [DBO].[Samochody]
ON [DBO].[Samochody].kategoria_pojazdu = [DBO].[TempTable1].kategoria
WHERE [DBO].[Samochody].kategoria_pojazdu = 'B'
GO

UPDATE [DBO].[Samochody]
SET [DBO].[Samochody].nr_rej_przyczepy = [DBO].[TempTable1].nr_rejestracyjny,
[DBO].[Samochody].kategoria_pojazdu = 'CE'
FROM [DBO].[TempTable1]
JOIN [DBO].[Samochody]
ON [DBO].[Samochody].kategoria_pojazdu = [DBO].[TempTable1].kategoria
WHERE [DBO].[Samochody].kategoria_pojazdu = 'C'
GO

UPDATE [DBO].[Samochody]
SET [DBO].[Samochody].nr_rej_przyczepy = [DBO].[TempTable1].nr_rejestracyjny,
[DBO].[Samochody].kategoria_pojazdu = 'DE'
FROM [DBO].[TempTable1]
JOIN [DBO].[Samochody]
ON [DBO].[Samochody].kategoria_pojazdu = [DBO].[TempTable1].kategoria
WHERE [DBO].[Samochody].kategoria_pojazdu = 'D'
GO

SET ROWCOUNT 0

DROP TABLE [DBO].[TempTable1]
GO

--- dobieranie kierowcy do zlecenia poprzez dodanie nowego (nie b�d�cego jeszcze sparowanego z kierowc�) w tabeli [DBO].[Kierowcy]
CREATE TABLE [DBO].[TempTable1] (kat_prawo_jazdy char(2), nr_zlecenia char(6))
GO

INSERT INTO [DBO].[TempTable1] (kat_prawo_jazdy, nr_zlecenia)
SELECT kat_prawo_jazdy, nr_zlecenia
FROM [DBO].[Zlecenia]
EXCEPT 
SELECT kat_prawo_jazdy,
nr_zlecenia
FROM [DBO].[Kierowcy]

GO

SET ROWCOUNT 1

UPDATE [DBO].[Kierowcy]
SET [DBO].[Kierowcy].nr_zlecenia = [DBO].[TempTable1].nr_zlecenia
FROM [DBO].[TempTable1]
INNER JOIN [DBO].[Kierowcy]
ON [DBO].[Kierowcy].kat_prawo_jazdy = [DBO].[TempTable1].kat_prawo_jazdy
WHERE [DBO].[Kierowcy].nr_zlecenia IS NULL

SET ROWCOUNT 0

GO

DROP TABLE [DBO].[TempTable1]

GO

--- dobieranie samochodu do zlecenia poprzez dodanie nowego (nie b�d�cego sparowanym) w tabeli [DBO].[Kierowcy]
CREATE TABLE [DBO].[TempTable1] (kat_prawo_jazdy char(2), nr_rejestracyjny char(7))
GO

INSERT INTO [DBO].[TempTable1] (kat_prawo_jazdy, nr_rejestracyjny)
SELECT kategoria_pojazdu, nr_rejestracyjny
FROM [DBO].[Samochody]
EXCEPT 
SELECT kat_prawo_jazdy,
nr_rejestracyjny
FROM [DBO].[Kierowcy]

GO

SET ROWCOUNT 1

UPDATE [DBO].[Kierowcy]
SET [DBO].[Kierowcy].nr_rejestracyjny = [DBO].[TempTable1].nr_rejestracyjny
FROM [DBO].[TempTable1]
INNER JOIN [DBO].[Kierowcy]
ON [DBO].[TempTable1].kat_prawo_jazdy = [DBO].[Kierowcy].kat_prawo_jazdy
WHERE [DBO].[Kierowcy].nr_rejestracyjny IS NULL

SET ROWCOUNT 0

GO

DROP TABLE [DBO].[TempTable1]

GO 

--- usuwanie tymczasowych par samochod�w z przyczep� w tabeli [DBO].[Samochody] stworzonych na czas dodawania nowego zlecenia do kierowcy
SELECT nr_rejestracyjny
INTO #MyTempTable
FROM [DBO].[Samochody]
EXCEPT
SELECT nr_rejestracyjny
FROM [DBO].[Kierowcy]
GO

UPDATE [DBO].[Samochody]
SET nr_rej_przyczepy = NULL
FROM #MyTempTable
JOIN [DBO].[Samochody]
ON #MyTempTable.nr_rejestracyjny = [DBO].[Samochody].nr_rejestracyjny
WHERE #MyTempTable.nr_rejestracyjny = [DBO].[Samochody].nr_rejestracyjny
GO

UPDATE [DBO].[Samochody]
SET kategoria_pojazdu = 'B'
WHERE kategoria_pojazdu = 'BE' AND nr_rej_przyczepy IS NULL
GO

UPDATE [DBO].[Samochody]
SET kategoria_pojazdu = 'C'
WHERE kategoria_pojazdu = 'CE' AND nr_rej_przyczepy IS NULL
GO

UPDATE [DBO].[Samochody]
SET kategoria_pojazdu = 'D'
WHERE kategoria_pojazdu = 'DE' AND nr_rej_przyczepy IS NULL
GO

DROP TABLE #MyTempTable
GO

--- wy�wietlenie zaktualizowanej tabeli
SELECT Pracownicy.nazwisko, Kierowcy.id, Kierowcy.numer_telefonu, Kierowcy.kat_prawo_jazdy, Kierowcy.nr_rejestracyjny, Samochody.nr_rej_przyczepy, Kierowcy.nr_zlecenia
FROM Kierowcy
LEFT JOIN Pracownicy
ON Pracownicy.id = Kierowcy.id
JOIN Samochody
ON Samochody.nr_rejestracyjny = Kierowcy.nr_rejestracyjny
GO

/* UWAGA Wyniki po aktualizacji tabeli mog� wy�wietla� si� z lekkim op�nieniem */