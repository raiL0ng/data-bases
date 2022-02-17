use [BusRouteSchedule]
go

create table Timetable
(
[TimetableID] int not null identity(1,1) primary key,
[RouteID] int not null,
[BusID] int not null,
[DriverID] int not null,
[ConductorID] int not null,
[Date] date not null,
[StartTimeOfWork] time not null,
[EndTimeOfWork] time not null,
[DayOfWeek] nvarchar(12) not null
);

create table Routes
(
[RouteID] int not null identity(1,1) primary key,
[Name] nvarchar(10) not null,
[Extent] int not null,
[TravelTime] time not null,
[AmountOfBuses] int not null,
[MoneyForTravel] int null
);

create table Stops
(
[StopID] int not null identity(1,1) primary key,
[Name] nvarchar(45) not null
);

create table RoutesAndStops
(
[StopID] int not null,
[RouteID] int not null,
[Identification] int not null,
[NumberOfArrivals] int not null
);

create table RoutesAndStopsTimetable
(
[TripTimetableID] int not null identity(1,1) primary key,
[StopID] int not null,
[RouteID] int not null,
[DayOfWeek] nvarchar(12) not null,
[Time] time not null
);

create table Drivers
(
[DriverID] int not null identity(1,1) primary key,
[Name] nvarchar(45) not null,
[Salary] int null
);

create table Conductors
(
[ConductorID] int not null identity(1,1) primary key,
[Name] nvarchar(45) not null,
[Salary] int null
);

create table Engineers
(
[EngineerID] int not null identity(1,1) primary key,
[Name] nvarchar(45) not null,
[Salary] int null
);

create table TechnicalInspection
(
[TechInspectionID] int not null identity(1,1) primary key,
[BusID] int not null,
[EngineerID] int not null,
[DateOfInspection] date not null 
);

create table BusInformation
(
[BusID] int not null identity(1,1) primary key,
[Brand] nvarchar(45) not null,
[BusNumber] nvarchar(6) not null,
[PassangerCapacity] int not null,
[Mileage] int not null,
[FuelConsuption] int null,
[VolumeOfTheTank] int null
);

create table Repair
(
[RepairOfBusID] int not null identity(1,1) primary key,
[CharacteristicID] int not null,
[TechInspectionID] int not null,
[Date] date not null
);

create table TechInspectionCharacteristics
(
[CharacteristicID] int not null identity(1,1) primary key, 
[ProblemName] nvarchar(45) not null
);

-------------------------------------------------------------------------------------------
alter table Timetable
add foreign key (RouteID) references Routes(RouteID)

alter table Timetable
add foreign key (BusID) references BusInformation(BusID)

alter table Timetable
add foreign key (DriverID) references Drivers(DriverID)

alter table Timetable
add foreign key (ConductorID) references Conductors(ConductorID)

alter table RoutesAndStops
add foreign key (RouteID) references Routes(RouteID)

alter table RoutesAndStops
add foreign key (StopID) references Stops(StopID)

alter table RoutesAndStopsTimetable
add foreign key (RouteID) references Routes(RouteID)

alter table RoutesAndStopsTimetable
add foreign key (StopID) references Stops(StopID)

alter table TechnicalInspection
add foreign key (BusID) references BusInformation(BusID)

alter table TechnicalInspection
add foreign key (EngineerID) references Engineers(EngineerID)

alter table Repair
add foreign key (CharacteristicID) references TechInspectionCharacteristics(CharacteristicID)

alter table Repair
add foreign key (TechInspectionID) references TechnicalInspection(TechInspectionID)

alter table RoutesAndStops
add primary key (RouteID, StopID)
---------------------------------------------------------------------------------------------

insert Drivers (Name, Salary) values
( N'Армен Гургенович Григорян', 18000)
, (N'Аркадий Васильевич Бутылкин', 18000)
, (N'Андрей Константинович Бочкин', 18000)
, (N'Валентина Петровна Воршина', 18000 )


insert Conductors (Name, Salary) values
( N'Антон Валерьевич Камушкин', 15000)
, (N'Кирилл Тагирович Озанян', 15000)
, (N'Ольга Андреевна Доронина', 15000)
, (N'Марина Петровна Крупнова', 15000 )


insert Engineers(Name, Salary) values
( N'Василий Аркадьевич Шестеренкин', 20000)
, (N'Владимир Владимирович Водкин', 20000)
, (N'Ефим Альбертович Гвоздев', 20000 )


insert BusInformation(Brand, BusNumber, PassangerCapacity, Mileage, FuelConsuption, VolumeOfTheTank) values
( N'Группа ГАЗ', N'Р207ТО', 53, 10243, 21, 80)
, (N'Группа ГАЗ', N'К532ВУ', 53, 20235, 21, 80)
, (N'НефАЗ', N'Р421ЛШ', 64, 54627, 24, 250)
, (N'НефАЗ', N'О165ОВ', 64, 203451, 24, 250)
, ('Daewoo', N'В821ЕЕ', 104, 33245, 28, 200)
, ('Daewoo', N'Р491ММ', 104, 28122, 28, 200 )
, ('MAN', N'К128ЛУ', 130, 31423, 32, 480)
, ('MAN', N'Р154ЛУ', 130, 12435, 32, 480) 



insert Stops(Name) values
( N'ул. Пушкина')
, (N'ул. Крупская')
, (N'ул. Вольская')
, (N'ул. Новая')
, (N'Техстекло')
, (N'Дворец Пионеров')
, (N'ул. Красная' )


insert Routes(Name, Extent, TravelTime, AmountOfBuses, MoneyForTravel) values
( N'13А', 16, 22, 3, 23)
, (N'210Б', 28, 38, 2, 26 )


--insert RoutesAndStops(Identification, NumberOfArrivals) values

insert TechnicalInspection (DateOfInspection) values
( 2021-08-28)
, (2021-08-29 )


