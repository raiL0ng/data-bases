USE Master;
IF DB_ID(N'BusRouteStore') IS NOT NULL
DROP DATABASE [BusRouteStore];
GO


CREATE DATABASE [BusRouteStore] ON PRIMARY
 (
  NAME = N'BusRouteStore',
  FILENAME = 'E:\Program files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\BusRoute_DataStore.mdf',
  SIZE=51200KB,
  FILEGROWTH=10240KB
  )
LOG ON
  (
  NAME = N'BusRouteStore_LOG',
  FILENAME = 'E:\Program files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\BusRoute_DataStore_log.ldf',
  SIZE=10240KB,
  FILEGROWTH=10%
  )
  COLLATE Cyrillic_General_100_CI_AI
GO
 
ALTER DATABASE [BusRouteStore] SET RECOVERY SIMPLE WITH NO_WAIT;
GO

ALTER DATABASE [BusRouteStore] SET AUTO_SHRINK OFF;
GO


CREATE TABLE dimRoutes
(
[RouteID] INT NOT NULL,
[Name] NVARCHAR(20) NOT NULL,
[StartStop] NVARCHAR(45) NOT NULL,
[EndStop] NVARCHAR(45) NOT NULL,
[Flag] BIT NOT NULL,
CONSTRAINT PKWD_1 PRIMARY KEY (RouteID)
) ON [Slow_Growing]

--DROP TABLE dimRoutes


CREATE TABLE miniDimRoutes
(
[RouteFastChangeID] INT NOT NULL,
[PathLength] INT NOT NULL,
[MoneyForTravel] MONEY NOT NULL,
[NumberOfStops] INT NOT NULL,
CONSTRAINT PKWD_2 PRIMARY KEY (RouteFastChangeID)
) ON [Fast_Growing]

--DROP TABLE miniDimRoutes

CREATE TABLE dimBusInformation
(
[BusID] INT NOT NULL,
[Brand] NVARCHAR(45) NOT NULL,
[BusNumber] NVARCHAR(6) NOT NULL,
[PassangerCapacity] INT NOT NULL,
[FuelConsumption] FLOAT NOT NULL,
[VolumeOfTheTank] FLOAT NOT NULL,
CONSTRAINT PKWD_3 PRIMARY KEY (BusID)
) ON [Frequently_Requested]


--DROP TABLE dimBusInformation

CREATE TABLE miniDimBusInformation
(
[BusFastChangeID] INT NOT NULL,
[Mileage] INT NOT NULL,
CONSTRAINT PKWD_4 PRIMARY KEY (BusFastChangeID)
) ON [Fast_Growing]

--DROP TABLE miniDimBusInformation

CREATE TABLE dimDrivers
(
[DriverID] INT NOT NULL,
[Name] NVARCHAR(45) NOT NULL,
[Gender] NVARCHAR(10) NOT NULL,
[DateOfEntry] DATE NOT NULL,
[BirthDate] DATE NOT NULL,
[PhoneNumber] NVARCHAR(11) NOT NULL,
[Email] NVARCHAR(45) NOT NULL,
[Flag] BIT NOT NULL,
CONSTRAINT PKWD_5 PRIMARY KEY (DriverID)
) ON [Slow_Growing]

--drop table dimDrivers

CREATE TABLE miniDimDriverDemography
(
[DriverDemographyID] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
[Age] varchar(10) NOT NULL,
[MaritalStatus] BIT NOT NULL,
[NumberOfChildren] INT NOT NULL
) ON [Fast_Growing]

--drop table miniDimDriverDemography

CREATE TABLE dimDate
(
[DateID] BIGINT NOT NULL,
[CurrentDate] DATE NOT NULL,
[CurrentDay] INT NOT NULL,
[CurrentMonth] INT NOT NULL,
[CurrentYear] INT NOT NULL,
[MonthName] NVARCHAR(15) NOT NULL,
[DayOfWeek] NVARCHAR(15) NOT NULL,
Constraint PKWD_7 PRIMARY KEY (DateID)
) ON [Frequently_Requested]

-- DROP TABLE dimDate

CREATE TABLE factReport
(
[ReportID] INT NOT NULL,
[BusKey] INT NOT NULL,
[BusFastChangeKey] INT NOT NULL,
[RouteKey] INT NOT NULL,
[RouteFastChangeKey] INT NOT NULL,
[DriverKey] INT NOT NULL,
[DriverDemographyKey] INT NOT NULL,
[DateKey] BIGINT NOT NULL,
FOREIGN KEY (BusKey) REFERENCES dimBusInformation(BusID),
FOREIGN KEY (BusFastChangeKey) REFERENCES miniDimBusInformation(BusFastChangeID),
FOREIGN KEY (RouteKey) REFERENCES dimRoutes(RouteID),
FOREIGN KEY (RouteFastChangeKey) REFERENCES miniDimRoutes(RouteFastChangeID),
FOREIGN KEY (DriverKey) REFERENCES dimDrivers(DriverID),
FOREIGN KEY (DriverDemographyKey) REFERENCES miniDimDriverDemography(DriverDemographyID),
FOREIGN KEY (DateKey) REFERENCES dimDate(DateID),
[MileagePerRace] INT NOT NULL,
[PassangerPerRace] INT NOT NULL,
[AmountOfLiterslPerRace] FLOAT NOT NULL,
[MoneyPerRace] MONEY NOT NULL,
[MoneyForFuel] MONEY NOT NULL,
[TotalMoney] MONEY NOT NULL,
[NumberOfRacePerDay] INT NOT NULL,
CONSTRAINT PKWD_fact PRIMARY KEY (ReportID, DateKey)
) ON PartSrchFactReport_Date (DateKey)

DROP TABLE factReport

CREATE TABLE ArchivalFactReport
(
[ReportID] INT NOT NULL,
[BusKey] INT NOT NULL,
[BusFastChangeKey] INT NOT NULL,
[RouteKey] INT NOT NULL,
[RouteFastChangeKey] INT NOT NULL,
[DriverKey] INT NOT NULL,
[DriverDemographyKey] INT NOT NULL,
[DateKey] BIGINT NOT NULL,
FOREIGN KEY (BusKey) REFERENCES dimBusInformation(BusID),
FOREIGN KEY (BusFastChangeKey) REFERENCES miniDimBusInformation(BusFastChangeID),
FOREIGN KEY (RouteKey) REFERENCES dimRoutes(RouteID),
FOREIGN KEY (RouteFastChangeKey) REFERENCES miniDimRoutes(RouteFastChangeID),
FOREIGN KEY (DriverKey) REFERENCES dimDrivers(DriverID),
FOREIGN KEY (DriverDemographyKey) REFERENCES miniDimDriverDemography(DriverDemographyID),
FOREIGN KEY (DateKey) REFERENCES dimDate(DateID),
[MileagePerRace] INT NOT NULL,
[PassangerPerRace] INT NOT NULL,
[AmountOfLiterslPerRace] FLOAT NOT NULL,
[MoneyPerRace] MONEY NOT NULL,
[MoneyForFuel] MONEY NOT NULL,
[TotalMoney] MONEY NOT NULL,
[NumberOfRacePerDay] INT NOT NULL,
CONSTRAINT PKWD_archive1 PRIMARY KEY (ReportID, DateKey)
) ON [PartSrchForArchivalTable] (DateKey)

--DROP TABLE ArchivalFactReport
