
--- Podaj dane kierowców posiadaj¹cych tylko kategoriê prawa jazdy B ------------------------------------------------------------

SELECT [DBO].[Pracownicy].id, [DBO].[Pracownicy].nazwisko, [DBO].[Pracownicy].staz_pracy, [DBO].[Kierowcy].numer_telefonu, [DBO].[Kierowcy].kat_prawo_jazdy 
FROM [DBO].[Kierowcy]
LEFT JOIN [DBO].[Pracownicy]
ON [Kierowcy].id = [DBO].[Pracownicy].id
WHERE kat_prawo_jazdy = 'B'
GO

--- Podaj nazwiska kierowców mog¹cych realizowaæ zlecenie wymagaj¹ce przyczepy --------------------------------------------------

SELECT [DBO].[Pracownicy].nazwisko, [DBO].[Kierowcy].kat_prawo_jazdy
FROM [DBO].[Kierowcy]
LEFT JOIN [DBO].[Pracownicy]
ON [DBO].[Kierowcy].id = [DBO].[Pracownicy].id
WHERE kat_prawo_jazdy LIKE '_E'
GO

--- Podaj liczbê kierowców w firmie --------------------------------------------------------------------------------------------

SELECT COUNT(*) AS LiczbaKierowcow
FROM [DBO].[Pracownicy]
WHERE stanowisko = 'Kierowca'
GO

--- OR ---

SELECT COUNT(*) AS LiczbaKierowcow
FROM [DBO].[Kierowcy]
GO

--- Podaj samochody czekaj¹ce na przypisanie im kierowcy ----------------------------------------------------------------------

SELECT nr_rejestracyjny FROM [DBO].[Samochody]
EXCEPT
SELECT nr_rejestracyjny FROM [DBO].[Kierowcy]
GO

--- Podaj 10 najnowszych zleceñ w firmie -------------------------------------------------------------------------------------

SELECT TOP 10 * FROM [DBO].[Zlecenia]
ORDER BY Data_rozpoczecia DESC
GO

--- Podaj informacje o zleceniach czekaj¹cych na przypisanie do kierowcy ----------------------------------------------------

/*
UWAGA W przypadku utworzenia zapytania na wyœwietlenie wszystkich informacji o zleceniach czekaj¹cych na realizacjê wymagane jest zastosowanie zapytania tworz¹cego tabeli tymczasowej co nie powinno sprawiæ problemu przy uprawnieniach "Read Only" jednak dla pewnoœci warto sprawdziæ uprawnienia.
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

--- Podaj numer rejestracyjny samochodu, przyczepy i szczegó³y realizowanego zlecenia przez kierowcê o nazwisku 'Moroz' ----

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

--- Podaj wszystkie zajête przyczepy wraz z nazwiskami kierowców, którzy je zabrali do zlecenia --------------------------

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

--- Podaj liczbê posiadaczy ka¿dego typu Prawa Jazdy -------------------------------------------------------------------

SELECT COUNT(kat_prawo_jazdy) AS LiczbaPosiadaczy, kat_prawo_jazdy
FROM [DBO].[Kierowcy]
GROUP BY kat_prawo_jazdy
GO

--- Podaj nazwiska kierowców, którzy planuj¹ zakoñczyæ swoje zlecenia w lutym -----------------------------------------

SELECT [DBO].[Pracownicy].nazwisko, [DBO].[Zlecenia].nr_zlecenia, [DBO].[Zlecenia].Data_rozpoczecia, [DBO].[Zlecenia].Data_zakonczenia
FROM [DBO].[Zlecenia]
JOIN [DBO].[Kierowcy]
ON [DBO].[Zlecenia].nr_zlecenia = [DBO].[Kierowcy].nr_zlecenia
JOIN [DBO].[Pracownicy]
ON [DBO].[Pracownicy].id = [DBO].[Kierowcy].id
WHERE Data_zakonczenia BETWEEN '2019-02-01' AND '2019-02-28'
GO

--- Zaktualizuj bazê by zlecenia, które ju¿ siê zakoñczy³y nie by³y wykonywane przez kierowców ------------------------

/* 
Komenda archiwizuje zlecenia z dat¹ zakoñczenia póŸniejsz¹ ni¿ dzisiejsza do tabeli [DBO].[ZleceniaArchiwalne], a nastêpnie usuwa zlecenia z listy [DBO].[Kierowcy], których data zakoñczenia jest póŸniejsza ni¿ aktualna data, usuwa równie¿ pojazdy z listy [DBO].[Kierowcy] w przypadku, gdy kierowca nie ma przypisanego, z listy [DBO].[Samochody] usuwa przyczepy, gdy pojazd nie ma przypisanego kierowcy i zmienia kategoriê pojazdu bez przyczepy z BE,CE,DE na B,C,D.
*/
--- Archiwizacja zakoñczonych zleceñ
INSERT INTO [DBO].[ZleceniaArchiwalne]
SELECT nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia FROM [DBO].[Zlecenia]
WHERE Data_zakonczenia < GETDATE()
GO 

DELETE FROM [DBO].[Zlecenia]
WHERE Data_zakonczenia < GETDATE()
GO
--- aktualizacja [DBO].[Kierowcy] o zakoñczone zlecenia
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
 --- Aktualizacja [DBO].[Samochody] i [DBO].[Przyczepy] o zwolnione przyczepy z powodu zakoñczonych zleceñ
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

--- wyœwietlenie zaktualizowanej bazy
SELECT Pracownicy.nazwisko, Kierowcy.id, Kierowcy.numer_telefonu, Kierowcy.kat_prawo_jazdy, Kierowcy.nr_rejestracyjny, Kierowcy.nr_zlecenia
FROM Kierowcy
LEFT JOIN Pracownicy
ON Pracownicy.id = Kierowcy.id

SELECT * FROM ZleceniaArchiwalne

SELECT * FROM Zlecenia

GO

--- Zaktualizuj bazê by nowe, zlecenie trafi³o bezpoœrednio do wolnego pracownika -----------------------------------
/*
Zestaw komend odpowiadaj¹cy za parowanie wolnego pracownika z nie przypisanym zleceniem, a nastêpnie dobraniem do niego wolnego samochodu i (je¿eli wymaga tego zlecenie) odpowiedniej przyczepy. Komenda polega na zaktualizowaniu nowych zamówieñ o wymagan¹ kategoriê prawa jazdy kierowcy, stworzeniu pary samochód i przyczepa w ka¿dej kategorii (B+E, C+E, D+E), dopasowaniu wolnego zlecenia do wolnego kierowcy, dopasowaniu do kierowcy wolnego samochodu i (je¿eli wymaga tego zlecenie) przyczepy i na zakoñczenie operacji usuniêciu tymczasowych par wolny samochód + wolna przyczepa.
*/

--- Komendy aktualizuj¹ce [DBO].[Zlecenia] o wymagan¹ kategoriê prawa jazdy kierowcy do realizacji zamówienia (na wypadek pojawienia siê nowych zamówieñ w bazie)
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

--- tworzenie po jednej parze samochód + przyczepa w tabeli [DBO].[Samochody] na wypadek pojawienia siê zlecenia z kategori¹ BE, CE, DE
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

--- dobieranie kierowcy do zlecenia poprzez dodanie nowego (nie bêd¹cego jeszcze sparowanego z kierowc¹) w tabeli [DBO].[Kierowcy]
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

--- dobieranie samochodu do zlecenia poprzez dodanie nowego (nie bêd¹cego sparowanym) w tabeli [DBO].[Kierowcy]
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

--- usuwanie tymczasowych par samochodów z przyczep¹ w tabeli [DBO].[Samochody] stworzonych na czas dodawania nowego zlecenia do kierowcy
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

--- wyœwietlenie zaktualizowanej tabeli
SELECT Pracownicy.nazwisko, Kierowcy.id, Kierowcy.numer_telefonu, Kierowcy.kat_prawo_jazdy, Kierowcy.nr_rejestracyjny, Samochody.nr_rej_przyczepy, Kierowcy.nr_zlecenia
FROM Kierowcy
LEFT JOIN Pracownicy
ON Pracownicy.id = Kierowcy.id
JOIN Samochody
ON Samochody.nr_rejestracyjny = Kierowcy.nr_rejestracyjny
GO

/* UWAGA Wyniki po aktualizacji tabeli mog¹ wyœwietlaæ siê z lekkim opóŸnieniem */