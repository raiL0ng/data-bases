use [BusRouteSchedule]

---------------------------------------------------------------------------------------------------
create table Routes
(
[RouteID] int not null identity(1,1) primary key,
[Name] nvarchar(10) not null,
[Extent] int not null,
[TravelTime] time not null,
[AmountOfBuses] int not null,
[MoneyForTravel] int
);

insert into [Routes] (Name, Extent, TravelTime, AmountOfBuses, MoneyForTravel) values
( N'13�', 16, '00:30:00', 2, 23)
, (N'210�', 28, '00:40:00', 1, 26 )
--, (N'51�', 25, '00:40:00', 0, 23 )
--delete from Routes
---------------------------------------------------------------------------------------------------
create table Stops
(
[StopID] int not null identity(1,1) primary key,
[Name] nvarchar(45) not null
);


insert into Stops (Name) values
( N'��. �������')
, (N'��. ��������')
, (N'��. ��������')
, (N'��. �����')
, (N'���������')
, (N'������ ��������')
, (N'��. �������' )
, (N'��. ����������')
, ('��. ����������')
, ('��. �������')
, ('���� ������')
, ('��. ��������' )

--delete from Stops
---------------------------------------------------------------------------------------------------
create table RoutesAndStops
(
[StopID] int not null,
[RouteID] int not null,
[Identification] varchar(2) not null,
[NumberOfArrivals] int not null
);

alter table RoutesAndStops
add foreign key (RouteID) references Routes(RouteID)

alter table RoutesAndStops
add foreign key (StopID) references Stops(StopID)


alter table RoutesAndStops
add primary key (RouteID, StopID)

-- Identification ����� ��� �������� S - ���������, I - �������������, E - ��������
-- NumberOfArrivals - ���������� �������� �������� �� ������� ���������
insert into RoutesAndStops (StopID, RouteID, Identification, NumberOfArrivals) values
(2, 1, 'S', 6),
(4, 1, 'I', 8), 
(6, 1, 'E', 4), 
(1, 2, 'S', 3), 
(3, 2, 'I', 4), 
(5, 2, 'I', 4), 
(7, 2, 'E', 2)
--, (8, 3, 'S', 3)
--, (9, 3, 'I', 4)
--, (10, 3, 'I', 4)
--, (11, 3, 'E', 2 )

--delete from RoutesAndStops
---------------------------------------------------------------------------------------------------
create table RoutesAndStopsTimetable
(
[TripTimetableID] int not null identity(1,1) primary key,
[StopID] int not null,
[RouteID] int not null,
[DayOfWeek] nvarchar(12) not null,
[Time] time not null
);

alter table RoutesAndStopsTimetable
add foreign key (RouteID) references Routes(RouteID)

alter table RoutesAndStopsTimetable
add foreign key (StopID) references Stops(StopID)


-- � ������ ������� ������� 2 ����� �� ������� ��������,
-- � ����� 1 ���� �� ������� ��������
insert into RoutesAndStopsTimetable (StopID, RouteID, [Time], [DayOfWeek]) values
( 2, 1, '12:00:00', N'�����������')
, (4, 1, '12:15:00', N'�����������')
, (6, 1, '12:30:00', N'�����������')
, (4, 1, '12:45:00', N'�����������')
, (2, 1, '13:00:00', N'�����������')
, (4, 1, '13:15:00', N'�����������')
, (6, 1, '13:30:00', N'�����������')
, (4, 1, '13:45:00', N'�����������')
, (2, 1, '14:00:00', N'�����������')
, (2, 1, '12:10:00', N'�����������')
, (4, 1, '12:25:00', N'�����������')
, (6, 1, '12:40:00', N'�����������')
, (4, 1, '12:55:00', N'�����������')
, (2, 1, '13:10:00', N'�����������')
, (4, 1, '13:25:00', N'�����������')
, (6, 1, '13:40:00', N'�����������')
, (4, 1, '13:55:00', N'�����������')
, (2, 1, '14:10:00', N'�����������')
, (1, 2, '12:00:00', N'�����������')
, (3, 2, '12:10:00', N'�����������')
, (5, 2, '12:30:00', N'�����������')
, (7, 2, '12:40:00', N'�����������')
, (5, 2, '12:50:00', N'�����������')
, (3, 2, '13:10:00', N'�����������')
, (1, 2, '13:20:00', N'�����������')
, (3, 2, '13:30:00', N'�����������')
, (5, 2, '13:50:00', N'�����������')
, (7, 2, '14:00:00', N'�����������')
, (5, 2, '14:10:00', N'�����������')
, (3, 2, '14:30:00', N'�����������')
, (1, 2, '14:40:00', N'�����������')
, (2, 1, '06:00:00', N'�����������')
, (4, 1, '06:15:00', N'�����������')
, (6, 1, '06:30:00', N'�����������')
, (4, 1, '06:45:00', N'�����������')
, (2, 1, '07:00:00', N'�����������')
, (2, 1, '06:00:00', N'�������')
, (4, 1, '06:15:00', N'�������')
, (6, 1, '06:30:00', N'�������')
, (4, 1, '06:45:00', N'�������')
, (2, 1, '07:00:00', N'�������')
, (2, 1, '06:00:00', N'�����')
, (4, 1, '06:15:00', N'�����')
, (6, 1, '06:30:00', N'�����')
, (4, 1, '06:45:00', N'�����')
, (2, 1, '07:00:00', N'�����')
, (2, 1, '06:00:00', N'�������')
, (4, 1, '06:15:00', N'�������')
, (6, 1, '06:30:00', N'�������')
, (4, 1, '06:45:00', N'�������')
, (2, 1, '07:00:00', N'�������')
, (2, 1, '06:00:00', N'�������')
, (4, 1, '06:15:00', N'�������')
, (6, 1, '06:30:00', N'�������')
, (4, 1, '06:45:00', N'�������')
, (2, 1, '07:00:00', N'�������')
, (2, 1, '08:00:00', N'�������')
, (4, 1, '08:15:00', N'�������')
, (6, 1, '08:30:00', N'�������')
, (4, 1, '08:45:00', N'�������')
, (2, 1, '09:00:00', N'�������')


--delete from RoutesAndStopsTimetable
---------------------------------------------------------------------------------------------------
create table Drivers
(
[DriverID] int not null identity(1,1) primary key,
[Name] nvarchar(45) not null,
[Salary] int null
);

insert into [Drivers] (Name, Salary) values
( N'����� ���������� ��������', 18000)
, (N'������� ���������� ��������', 18000)
, (N'������ �������������� ������', 18000)
, (N'��������� �������� �������', 18000 )

--delete from Drivers
---------------------------------------------------------------------------------------------------
create table Conductors
(
[ConductorID] int not null identity(1,1) primary key,
[Name] nvarchar(45) not null,
[Salary] int null
);

insert into Conductors (Name, Salary) values
( N'����� ���������� ��������', 15000)
, (N'������ ��������� ������', 15000)
, (N'����� ��������� ��������', 15000)
, (N'������ �������� ��������', 15000 )

--delete from Conductors
---------------------------------------------------------------------------------------------------
create table Engineers
(
[EngineerID] int not null identity(1,1) primary key,
[Name] nvarchar(45) not null,
[Salary] int null
);

insert into Engineers (Name, Salary) values
( N'������� ���������� �����������', 20000)
, (N'�������� ������������ ������', 20000)
, (N'���� ����������� �������', 20000)
, (N'������� ���������� ��������',null )

--delete from Engineers
---------------------------------------------------------------------------------------------------
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


insert into BusInformation (Brand, BusNumber, PassangerCapacity, Mileage, FuelConsuption, VolumeOfTheTank) values
( N'������ ���', N'�207��', 53, 10243, 21, 95)
, (N'������ ���', N'�532��', 53, 20235, 21, 95)
, (N'�����', N'�421��', 64, 54627, 24, 250)
, (N'�����', N'�165��', 64, 203451, 24, 250)
, ('Daewoo', N'�821��', 104, 33245, 28, 200)
, ('Daewoo', N'�491��', 104, 58122, 28, 200)
, ('MAN', N'�128��', 130, 31423, 32, 480)
, ('MAN', N'�154��', 130, 12435, 32, 480)
, ('MAN', N'�442��', 130, 11243, null, null )

--delete from BusInformation
--where Mileage >= 250000 or PassangerCapacity < 20
---------------------------------------------------------------------------------------------------
create table TechnicalInspection
(
[TechInspectionID] int not null identity(1,1) primary key,
[BusID] int not null,
[EngineerID] int not null,
[DateOfInspection] date not null 
);


alter table TechnicalInspection
add foreign key (BusID) references BusInformation(BusID)

alter table TechnicalInspection
add foreign key (EngineerID) references Engineers(EngineerID)


-- ����� ���. ������ ����� ������ ��������� ���� ������� (�.�. � ���� ���� ����� ����������� ������ ���� �������),
-- ���� �� ����� ���������, �� � ������� Repair ����� ���������� ��������� ������. (� ��� ����� �� �����)
insert into TechnicalInspection (BusID, EngineerID, DateOfInspection) values
(4, 1, '20210829'), 
(7, 3, '20210830')

insert into TechnicalInspection (BusID, EngineerID, DateOfInspection) values
(1, 2, '20210901'), 
(2, 1, '20210901'),
(3, 4, '20210901'),
(4, 3, '20210901'),
(5, 4, '20210902')
--delete from TechnicalInspection

---------------------------------------------------------------------------------------------------


create table TechInspectionCharacteristics
(
[CharacteristicID] int not null identity(1,1) primary key, 
[ProblemName] nvarchar(45) not null
);

insert into TechInspectionCharacteristics (ProblemName) values
( N'�������� � �������� ������')
, (N'������������� ��������')
, (N'��������� ��������������� � ��������')
, (N'������� ������ �� ��������� ������')
, (N'������������ ������ ���������')
, (N'��������� �������� ����� �������� ������')
, (N'����� �� ����� ������� ��������')

--delete from TechInspectionCharacteristics
---------------------------------------------------------------------------------------------------
create table Repair
(
[RepairOfBusID] int not null identity(1,1) primary key,
[CharacteristicID] int not null,
[TechInspectionID] int not null,
[Date] date not null
);

alter table Repair
add foreign key (CharacteristicID) references TechInspectionCharacteristics(CharacteristicID)

alter table Repair
add foreign key (TechInspectionID) references TechnicalInspection(TechInspectionID)


insert into Repair (TechInspectionID, CharacteristicID, [Date]) values
( 1, 4, '20210830')
, (2, 1, '20210831')

--delete from Repair
---------------------------------------------------------------------------------------------------
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

alter table Timetable
add foreign key (RouteID) references Routes(RouteID)

alter table Timetable
add foreign key (BusID) references BusInformation(BusID)

alter table Timetable
add foreign key (DriverID) references Drivers(DriverID)

alter table Timetable
add foreign key (ConductorID) references Conductors(ConductorID)

insert into Timetable 
(DriverID, ConductorID, BusID, RouteID, [Date], StartTimeOfWork, EndTimeOfWork, [DayOfWeek]) values
( 1, 1, 1, 1, '20210904', '12:00:00', '14:00:00', N'�����������')
, (2, 2, 2, 1, '20210904', '12:10:00', '14:10:00', N'�����������')
, (3, 3, 3, 2, '20210904', '12:00:00', '13:20:00', N'�����������')
, (4, 4, 3, 2, '20210904', '13:20:00', '14:40:00', N'�����������')
, (1, 2, 1, 1, '20210905', '06:00:00', '07:00:00', N'�����������')

--delete from Timetable
---------------------------------------------------------------------------------------------------
