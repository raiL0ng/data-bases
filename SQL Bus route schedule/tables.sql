create DATABASE bus_route_schedule;

create table Timetable
(
[TimetableID] int not null identity(1,1) primary key,
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
[Identification] int not null,
[NumberOfArrivals] int not null
);

create table RoutesAndStopsTimetable
(
[TripTimetableID] int not null,
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
[Tech-InspectionID] int not null identity(1,1) primary key,
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
[Date] date not null
);

create table TechInspectionCharacteristics
(
[CharacteristicID] int not null identity(1,1) primary key, 
[ProblemName] nvarchar(45) not null
);

alter table Timetable
add foreign key (RouteID) references Routes(RouteID)