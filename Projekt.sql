/*
Created: 31.12.2018
Last update: 18.01.2019
Project: Firma Transportowa
Company: WSEI
DATABASE: MS SQL Server 2017
*/

--- CREATE DATABASE SECTION ------------------------------------------------------------------------------------

CREATE DATABASE FirmaTransportowa;
GO

USE FirmaTransportowa;
GO

--- CREATE TABLE SECTION ---------------------------------------------------------------------------------------

--- table dbo.Pracownicy

CREATE TABLE [DBO].[Pracownicy]
(
[id] Int Identity(1,1) NOT NULL,
[nazwisko] varchar(30) NOT NULL,
[staz_pracy] Date NOT NULL,
[stanowisko] varchar(20) NOT NULL,
CONSTRAINT [aktPracownik] CHECK (staz_pracy < GETDATE())
)
GO

--- add keys for dbo.Pracownicy

ALTER TABLE [DBO].[Pracownicy] ADD CONSTRAINT [NumerPracownika]
PRIMARY KEY ([id])
GO

--- create table dbo.Kierowcy

CREATE TABLE [DBO].[Kierowcy]
(
[id] INT NOT NULL,
[numer_telefonu] INT NOT NULL,
[kat_prawo_jazdy] char(2) NOT NULL,
[nr_rejestracyjny] char(7) NULL,
[nr_zlecenia] char(6) NULL,
CONSTRAINT [PrawidlowePrawoJazdy]
CHECK (kat_prawo_jazdy LIKE '[B,C,D][E OR ISNULL]')
)
GO

--- adding Unique Key to Kierowcy

/* 
ALTER TABLE [DBO].[Kierowcy] ADD 
CONSTRAINT JedenSamochodnaKierowce
UNIQUE (nr_rejestracyjny)
GO

Jako, ¿e CONSTRAINT UNIQUE pozwala tylko na jeden NULL w tabeli
zamiast niego zastosowa³em filtrowanie Indexu 

ALTER TABLE [DBO].[Kierowcy]
DROP CONSTRAINT JedenSamochodnaKierowce
GO
*/

CREATE UNIQUE INDEX [JedenSamochodnaKierowce]
ON Kierowcy(nr_rejestracyjny)
WHERE nr_rejestracyjny IS NOT NULL
GO


--- create table dbo.Samochody

CREATE TABLE [DBO].[Samochody]
(
[nr_rejestracyjny] char(7) NOT NULL,
[ladownoscWtonach] DECIMAL(5,3) NULL,
[liczba_miejsc] INT NULL,
[wiek] INT NOT NULL,
[kategoria_pojazdu] char(2) NOT NULL,
[nr_rej_przyczepy] char(7) NULL,
CONSTRAINT [PrawidloweOznaczenieSamochodu]
CHECK (kategoria_pojazdu LIKE '[B,C,D][E OR NULL]'),
CONSTRAINT [WerWieku] 
CHECK (wiek < GETDATE()),
CONSTRAINT [RozneNumeryRejestracyjne]
CHECK (nr_rejestracyjny != nr_rej_przyczepy)
)
GO 

--- adding Unique Key to dbo.Samochody

ALTER TABLE [DBO].[Samochody] ADD CONSTRAINT [UnikalnyNrRejestracyjny]
UNIQUE (nr_rejestracyjny)
GO

/*
CONSTRAINT JednaPrzyczepanaSamochod
UNIQUE (nr_rej_przyczepy)
GO

ALTER TABLE [DBO].[Samochody]
DROP CONSTRAINT JednaPrzyczepanaSamochod
GO

Jako, ¿e CONSTRAINT UNIQUE pozwala tylko na jeden NULL w tabeli
zamiast niego zastosowa³em filtrowanie Indexu 

*/
CREATE UNIQUE INDEX [JednaPrzyczepanaSamochod]
ON Samochody(nr_rej_przyczepy)
WHERE nr_rej_przyczepy IS NOT NULL
GO


--- adding Primary Key to dbo.Samochody

ALTER TABLE [DBO].[Samochody] ADD CONSTRAINT [NrRejestracyjny]
PRIMARY KEY ([nr_rejestracyjny])
GO

--- create table dbo.Przyczepy

CREATE TABLE [DBO].[Przyczepy]
(
[nr_rejestracyjny] char(7) NOT NULL,
[ladownoscWtonach] DECIMAL(5,3) NOT NULL
)
GO 

--- adding Unique Key to dbo.Przyczepy

ALTER TABLE [dbo].[Przyczepy]
ADD CONSTRAINT [UnikalnyNrRejestracyjnyPrzyczepy]
UNIQUE (nr_rejestracyjny)
GO

--- adding Primary Key to dbo.Przyczepy

ALTER TABLE [DBO].[Przyczepy] ADD CONSTRAINT [NrRejestracyjnyPrzyczepy]
PRIMARY KEY ([nr_rejestracyjny])
GO

--- create table dbo.Zlecenia

CREATE TABLE [DBO].[Zlecenia]
(
[nr_zlecenia] char(6) NOT NULL,
[liczba_osob] INT NULL,
[waga_towaruWtonach] DECIMAL(5,3) NULL,
[kat_prawo_jazdy] char(2) NULL,
[Data_rozpoczecia] DATE NOT NULL,
[Data_zakonczenia] DATE NOT NULL,
CONSTRAINT [PusteZlecenie] 
CHECK ([liczba_osob] IS NOT NULL OR [waga_towaruWtonach] IS NOT NULL),
CONSTRAINT [CzasNaZlecenie]
CHECK ([Data_rozpoczecia] < [Data_zakonczenia])
)
GO 

--- adding Unique Key to DBO.Zlecenia

ALTER TABLE [DBO].[Zlecenia]
ADD CONSTRAINT [UnikalnyNrZlecenia]
UNIQUE (nr_zlecenia)
GO

--- adding Primary Key to dbo.Zlecenia

ALTER TABLE [DBO].[Zlecenia] ADD CONSTRAINT [AktywneZlecenie]
PRIMARY KEY ([nr_zlecenia])
GO

--- create table dbo.ZleceniaArchiwalne

CREATE TABLE [DBO].[ZleceniaArchiwalne]
(
[nr_zlecenia] char(6) NOT NULL,
[liczba_osob] INT NULL,
[waga_towaruWtonach] DECIMAL(5,3) NULL,
[Data_rozpoczecia] DATE NOT NULL,
[Data_zakonczenia] DATE NOT NULL,
CONSTRAINT [WeryfikacjaZlecenia]
CHECK (Data_zakonczenia < GETDATE())
)
GO

--- CREATE FOREIGN KEYS (RELATIONS) SECTION -----------

ALTER TABLE [DBO].[Kierowcy]
ADD CONSTRAINT [DaneKierowcy] FOREIGN KEY ([id])
REFERENCES [DBO].[Pracownicy] ([id]) ON UPDATE CASCADE ON DELETE CASCADE
GO

ALTER TABLE [DBO].[Kierowcy]
ADD CONSTRAINT [Wykonuje] FOREIGN KEY ([nr_zlecenia])
REFERENCES [DBO].[Zlecenia] ([nr_zlecenia]) ON UPDATE CASCADE ON DELETE SET NULL
GO

ALTER TABLE [DBO].[Samochody]
ADD CONSTRAINT [Zabiera] FOREIGN KEY ([nr_rej_przyczepy])
REFERENCES [DBO].[Przyczepy] ([nr_rejestracyjny]) ON UPDATE CASCADE ON DELETE SET NULL
GO

ALTER TABLE [DBO].[Kierowcy]
ADD CONSTRAINT [Kieruje] FOREIGN KEY ([nr_rejestracyjny])
REFERENCES [DBO].[Samochody] ([nr_rejestracyjny]) ON UPDATE CASCADE ON DELETE SET NULL
GO


------------INSERT VALUES INTO TABLES ------------------------------------------------------------------------

--- insert Values into table DBO.Przyczepy ---

INSERT INTO [DBO].[Przyczepy] (nr_rejestracyjny, ladownoscWtonach)
VALUES ('ERA5754', 1.000);

INSERT INTO [DBO].[Przyczepy] (nr_rejestracyjny, ladownoscWtonach)
VALUES ('GWE5495', 1.000);
GO

INSERT INTO [DBO].[Przyczepy] (nr_rejestracyjny, ladownoscWtonach)
VALUES ('GST4757', 1.000);
GO

INSERT INTO [DBO].[Przyczepy] (nr_rejestracyjny, ladownoscWtonach)
VALUES ('GKA8967', 1.000);
GO

INSERT INTO [DBO].[Przyczepy] (nr_rejestracyjny, ladownoscWtonach)
VALUES ('NLI7786', 1.000);
GO

INSERT INTO [DBO].[Przyczepy] (nr_rejestracyjny, ladownoscWtonach)
VALUES ('WX64997', 8.000);
GO

INSERT INTO [DBO].[Przyczepy] (nr_rejestracyjny, ladownoscWtonach)
VALUES ('WX92658', 8.000);
GO

INSERT INTO [DBO].[Przyczepy] (nr_rejestracyjny, ladownoscWtonach)
VALUES ('BIN5064', 8.000);
GO

INSERT INTO [DBO].[Przyczepy] (nr_rejestracyjny, ladownoscWtonach)
VALUES ('ERA7773', 8.000);
GO

INSERT INTO [DBO].[Przyczepy] (nr_rejestracyjny, ladownoscWtonach)
VALUES ('GWE3313', 8.000);
GO

--- insert Values into table DBO.Zlecenia ---

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0011', 2, 0.850, '2018-12-03', '2019-01-02')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0012', 8, 0, '2018-12-03', '2019-01-01')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0013', 0, 4.000, '2018-12-04', '2019-01-02')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0014', 0, 4.000, '2018-12-03', '2019-01-02')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0015', 40, 0, '2018-12-04', '2019-01-04')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0016', 0, 1.000, '2018-11-25', '2019-01-03')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0017', 0, 10.000, '2018-11-29', '2019-01-02')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0018', 8, 0, '2018-12-06', '2019-01-06')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0019', 0, 0.800, '2018-12-16', '2019-01-03')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0020', 0, 4.200, '2018-12-07', '2019-01-08')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0021', 48, 0, '2018-11-09', '2019-01-06')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0022', 0, 12.000, '2018-12-22', '2019-01-07')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0023', 0, 0.690, '2018-11-12', '2019-01-06')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0024', 1, 1.300, '2018-12-13', '2019-01-07')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0025', 0, 4.100, '2018-12-19', '2019-01-04')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0026', 32, 0, '2019-01-01', '2019-01-19')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0027', 0, 3.000, '2019-01-02', '2019-01-29')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0028', 0, 4.000, '2019-01-03', '2019-02-16')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0029', 8, 0, '2019-01-02', '2019-02-15')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0030', 0, 5.000, '2019-01-04', '2019-02-18')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0031', 0, 5.500, '2019-01-03', '2019-02-17')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0032', 40, 0, '2019-01-05', '2019-01-29')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0033', 8, 0.800, '2019-01-07', '2019-02-17')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0034', 0, 3.500, '2019-01-08', '2019-02-22')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0035', 6, 0, '2019-01-03', '2019-02-18')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0036', 0, 1.350, '2019-01-08', '2019-03-18')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0037', 0, 2.500, '2019-01-09', '2019-02-26')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0038', 0, 5.900, '2019-01-09', '2019-02-20')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0039', 0, 0.750, '2019-01-09', '2019-02-20')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0040', 2, 0.850, '2019-01-10', '2019-02-20')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0041', 37, 0, '2019-01-11', '2019-02-21')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0042', 35, 0, '2019-01-08', '2019-02-28')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0043', 0, 4.200, '2019-01-11', '2019-02-22')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0044', 0, 11.000, '2019-01-14', '2019-02-26')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0045', 45, 0, '2019-01-15', '2019-01-29')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0046', 0, 5.000, '2019-01-18', '2019-02-20')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0047', 39, 0, '2019-01-19', '2019-02-19')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0048', 2, 1.400, '2019-01-20', '2019-03-02')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0049', 0, 1.200, '2019-01-20', '2019-02-28')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0050', 8, 0.000, '2019-01-19', '2019-02-21')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0051', 0, 12.000, '2019-01-22', '2019-03-20')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0052', 0, 5.000, '2019-01-24', '2019-03-20')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0053', 0, 3.600, '2019-01-20', '2019-02-27')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0054', 2, 1.200, '2019-01-25', '2019-03-02')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0055', 45, 0.000, '2019-01-23', '2019-02-20')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0056', 2, 1.100, '2019-01-26', '2019-02-20')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0057', 0, 4.900, '2019-01-26', '2019-03-03')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0058', 39, 0, '2019-01-25', '2019-03-20')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0059', 8, 0.600, '2019-01-25', '2019-02-24')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0060', 1, 1.150, '2019-01-23', '2019-03-07')
GO

INSERT INTO [DBO].[Zlecenia] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0061', 0, 5.900, '2019-01-28', '2019-02-28')
GO

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

--- Insert Values into table DBO.ZleceniaArchiwalne

INSERT INTO [DBO].[ZleceniaArchiwalne] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0001', 0, 1.000, '2018-11-02', '2018-12-06')
GO

INSERT INTO [DBO].[ZleceniaArchiwalne] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0002', 0, 11.000, '2018-11-03', '2018-12-07')
GO

INSERT INTO [DBO].[ZleceniaArchiwalne] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0003', 8, 0, '2018-11-05', '2018-12-12')
GO

INSERT INTO [DBO].[ZleceniaArchiwalne] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0004', 2, 1.000, '2018-11-06', '2018-12-14')
GO

INSERT INTO [DBO].[ZleceniaArchiwalne] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0005', 0, 1.400, '2018-11-07', '2018-12-14')
GO

INSERT INTO [DBO].[ZleceniaArchiwalne] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0006', 40, 0, '2018-11-09', '2018-12-16')
GO

INSERT INTO [DBO].[ZleceniaArchiwalne] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0007', 2, 0.550, '2018-11-10', '2018-12-18')
GO

INSERT INTO [DBO].[ZleceniaArchiwalne] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0008', 0, 1.200, '2018-11-12', '2018-12-25')
GO

INSERT INTO [DBO].[ZleceniaArchiwalne] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0009', 35, 0, '2018-11-12', '2018-12-26')
GO

INSERT INTO [DBO].[ZleceniaArchiwalne] (nr_zlecenia, liczba_osob, waga_towaruWtonach, Data_rozpoczecia, Data_zakonczenia)
VALUES ('PL0010', 7, 0.600, '2018-11-14', '2018-12-28')
GO

--- insert Values into table DBO.Samochody

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('ERA9593', 1.500, 2, 2009, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('BIN1541', 1.500, 2, 2008, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('WX28252', 1.500, 2, 2009, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('WX23954', 1.500, 2, 2007, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('NLI6081', 1.500, 2, 2010, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('GKA5159', 0, 8, 2010, 'BE', 'ERA5754')
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('GST5271', 0, 8, 2012, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('GWE1646', 0, 8, 2011, 'BE', 'GKA8967')
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('ERA7035', 0, 8, 2012, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('BIN8204', 0, 8, 2014, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('WX12180', 1.500, 2, 2008, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('WX28182', 1.500, 2, 2014, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('NLI8514', 1.500, 2, 2007, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('GKA1903', 1.500, 2, 2012, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('GST8893', 1.500, 2, 2007, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('BIN5586', 0, 8, 2011, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('WX21833', 0, 8, 2012, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('WX33596', 0, 8, 2010, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('NLI5573', 0, 8, 2011, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('GWE4783', 0, 8, 2015, 'B', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('GST4802', 6.000, 2, 2011, 'CE', 'GWE3313')
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('EZO8095', 6.000, 2, 2012, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('KRA3620', 6.000, 2, 2014, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('DWL9023', 6.000, 2, 2012, 'CE', 'BIN5064')
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('PZA3404', 6.000, 2, 2011, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('LPU4680', 6.000, 2, 2009, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('KLI3773', 6.000, 2, 2012, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('EPJ4316', 6.000, 2, 2010, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('GST3363', 6.000, 2, 2012, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('EZO3895', 6.000, 2, 2014, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('KRA5436', 6.000, 2, 2011, 'CE', 'WX64997')
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('DWL1561', 6.000, 2, 2012, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('PZA4529', 6.000, 2, 2008, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('LPU1526', 6.000, 2, 2009, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('KLI9002', 6.000, 2, 2013, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('EPJ4568', 6.000, 2, 2009, 'CE', 'ERA7773')
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('GST5859', 6.000, 2, 2011, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('EZO4343', 6.000, 2, 2010, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('KRA7018', 6.000, 2, 2012, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('DWL6420', 6.000, 2, 2008, 'C', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('PZA9146', 0, 49, 2010, 'D', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('LPU2652', 0, 49, 2012, 'D', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('KLI8315', 0, 49, 2009, 'D', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('GST6110', 0, 49, 2011, 'D', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('EZO1634', 0, 49, 2012, 'D', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('KRA3016', 0, 49, 2010, 'D', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('DWL6731', 0, 49, 2009, 'D', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('PZA7140', 0, 49, 2012, 'D', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('LPU4004', 0, 49, 2011, 'D', NULL)
GO

INSERT INTO [DBO].[Samochody] (nr_rejestracyjny, ladownoscWtonach, liczba_miejsc, wiek, kategoria_pojazdu, nr_rej_przyczepy)
VALUES ('KLI9780', 0, 49, 2010, 'D', NULL)
GO

--- Insert Values into table DBO.Pracownicy

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Rychter', '2016-06-01', 'Dyrektor')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Biesiada', '2016-08-01', 'Wicedyrektor')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Furmañczyk', '2016-08-22', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Budek', '2016-08-22', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Hryniewicki', '2016-08-22', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Karp', '2016-08-22', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Soliñski', '2016-08-22', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Strzelecki', '2016-08-22', 'Kierownik')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Ruszkowski', '2016-09-01', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Jab³oñski', '2016-09-03', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Durzyñski', '2016-09-05', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Domalewski', '2016-09-04', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Rutka', '2016-09-08', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Kopacki', '2016-09-10', 'Kierownik')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Ch³opek', '2016-10-01', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Skulski', '2016-10-03', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Sêkowski', '2016-10-05', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Tomiak', '2016-10-08', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Piechota', '2016-10-07', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Puchalski', '2016-10-12', 'Kierownik')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Podsiad³o', '2016-11-01', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Kulak', '2016-11-01', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Rudnicki', '2016-11-05', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Karwacki', '2016-11-04', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Dereñ', '2016-11-06', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Linek', '2016-11-07', 'Kierownik')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Mach', '2016-12-02', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Miko³ajek', '2016-12-04', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Gawroñski', '2016-12-05', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Moroz', '2016-12-06', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Gryczka', '2016-12-06', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Ciborowski', '2016-12-08', 'Kierownik')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Brych', '2017-01-04', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Kubik', '2017-01-05', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Œwi¹tkowski', '2017-01-06', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Gorzkowski', '2017-01-06', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Paw³owicz', '2017-01-07', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Derêgowski', '2017-01-07', 'Kierownik')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Bura', '2017-01-12', 'Sekretarka')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Migdalski', '2017-02-03', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Januszewski', '2017-02-04', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Pinkowski', '2017-02-04', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Baczewski', '2017-02-04', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Jaroñ', '2017-02-04', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Borowik', '2017-02-05', 'Kierownik')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Kulesza', '2017-03-05', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Zarêbski', '2017-03-06', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Klimas', '2017-03-07', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('¯ak', '2017-03-08', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Walczak', '2017-03-11', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Koc', '2017-03-12', 'Celnik')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Taraszkiewicz', '2017-03-15', 'Kierownik')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Gniewek', '2017-03-21', 'Sekretarka')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Cichoñski', '2017-04-06', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Kopera', '2017-04-08', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Krzos', '2017-04-11', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Kozubek', '2017-03-12', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Domaga³a', '2017-03-12', 'Kierowca')
GO

INSERT INTO [DBO].[Pracownicy] (nazwisko, staz_pracy, stanowisko)
VALUES ('Bigaj', '2017-03-13', 'Kierownik')
GO

--- insert Values into table DBO.Kierowcy

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (3, 655931215, 'B', 'BIN1541', 'PL0011')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (4, 511824301, 'B', 'BIN5586', 'PL0012')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny,  nr_zlecenia)
VALUES (5, 640451014, 'C', 'DWL1561', 'PL0013')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (6, 298671269, 'C', 'DWL6420', 'PL0014')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (7, 775028049, 'D', 'DWL6731', 'PL0015')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (9, 294043969, 'B', 'ERA9593', 'PL0016')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (10, 225629418, 'CE', 'DWL9023 ', 'PL0017')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (11, 473612746, 'B', 'BIN8204', 'PL0018')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (12, 486513497, 'B', 'GKA1903', 'PL0019')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (13, 385236914, 'C', 'EPJ4316', 'PL0020')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (15, 306749658, 'D', 'KLI8315', 'PL0021')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (16, 815879489, 'CE', 'EPJ4568', 'PL0022')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (17, 548007023, 'B', 'NLI6081', 'PL0023')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (18, 318398250, 'B', 'NLI8514', 'PL0024')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (19, 731505468, 'C', 'EZO3895', 'PL0025')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (21, 624002376, 'D', 'EZO1634', 'PL0026')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (22, 109051932, 'C', 'EZO4343', 'PL0027')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (23, 819791393, 'C', 'EZO8095', 'PL0028')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (24, 731890605, 'B', 'ERA7035', 'PL0029')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (25, 792554103, 'C', 'GST3363', 'PL0030')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (27, 860022953, 'CE', 'GST4802', NULL)
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (28, 392290297, 'C', 'GST5859', 'PL0031')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (29, 734680643, 'D', 'GST6110', 'PL0032')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (30, 182592525, 'BE', 'GKA5159', 'PL0033')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (31, 178879790, 'C', 'KLI3773', 'PL0034')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (33, 757540380, 'B', 'GST5271', 'PL0035')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (34, 500947633, 'B', 'GST8893', 'PL0036')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (35, 454666215, 'BE', 'GWE1646', 'PL0037')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (36, 331392206, 'C', 'KLI9002', 'PL0038')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (37, 648742851, 'B', 'WX12180', 'PL0039')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (40, 470745362, 'B', 'WX23954', 'PL0040')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (41, 743216508, 'D', 'KLI9780', 'PL0041')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (42, 289193866, 'D', 'KRA3016', 'PL0042')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (43, 669416633, 'C', 'KRA3620', 'PL0043')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (44, 483237836, 'CE', 'KRA5436', 'PL0044')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (46, 795046052, 'D', 'LPU2652', 'PL0045')
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (47, 891857305, 'D', NULL, NULL)
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (48, 869751335, 'DE', NULL, NULL)
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (49, 180282966, 'DE', NULL, NULL)
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (50, 198606964, 'B', NULL, NULL)
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (54, 628289991, 'B', NULL, NULL)
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (55, 417005215, 'B', NULL, NULL)
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (56, 417136294, 'BE', NULL, NULL)
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (57, 252292368, 'BE', NULL, NULL)
GO

INSERT INTO [DBO].[Kierowcy] (id, numer_telefonu, kat_prawo_jazdy, nr_rejestracyjny, nr_zlecenia)
VALUES (58, 426057149, 'BE', NULL, NULL)
GO

--- PRZYK£ADOWE KWERENDY --------------------------------------------------------------------------------------------------------

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
