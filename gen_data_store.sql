



--заполнение таблицы дат
SET LANGUAGE Russian

declare @startday date = '2015-01-01'
declare @endday date = '2040-01-01'
declare @inc date
set @inc = @startday

while @inc<= @endday
begin
insert into [BusRouteStore].[dbo].[dimDate] values
(cast (convert (varchar(8),@inc, 112) as bigint),
convert(date, @inc, 104),
day(@inc),
month(@inc),
year(@inc),
datename(mm, @inc),
datename(dw, @inc)
)
set @inc = dateadd(day, 1, @inc)
end

select count(*) from [dbo].[dimDate]


-- заполнение таблицы водителей
delete from [dbo].[dimDrivers]

declare @n int = 0;
declare @k int = 20;
declare @d int = 25;
declare @ID int;
declare @a char = 'А', @z char = 'я', @w int, @l int
SET @w = ascii(@z) - ascii(@a);
SET @l = ascii(@a);
declare @TaxN bigint;
declare @TaxNumber varchar(12);
declare @PhoneNumber nvarchar(11);
declare @Date_of_entry Date;
declare @Name nvarchar(50) = 'Ник';
declare @Gender char(1);
declare @Email nvarchar(45);
declare @BirthDate Date;


while (@n<100000)
begin
	SET	@ID = ABS(CHECKSUM(NewId()));
	SET @TaxN = RAND()*1000000000000;
	SET @TaxNumber = cast(@TaxN as varchar(12));
	if (@k>80) SET @k=20;
	if (@d > 55) SET @d = 25;
	if (len(@Name)>25) SET @Name = 'Ник' else SET @Name = @Name+char(round(rand() * @w, 0) + @l);
	if (@k%3=0 or @k%5=0) SET @Gender = 'М' else SET @Gender = 'Ж';
	SET @Date_of_entry  = dateadd(day, -@d, Getdate());
	if (@d < 35) SET @Date_of_entry  = dateadd(year, -@d % 7, Getdate())
	else SET @Date_of_entry  = dateadd(year, -@d % 7 - 10, Getdate());
	SET @BirthDate = dateadd(year, -@d, Getdate());
	SET @BirthDate = dateadd(day, @d, @BirthDate);
	SET @PhoneNumber = '+79' + SUBSTRING(@TaxNumber, 1, 8);
	SET @Email = 'driver_' + cast(@n as nvarchar(8)) + '@mail.ru'

	insert into [BusRouteStore].[dbo].[dimDrivers]([DriverID], [Name], [Gender], [DateOfEntry], [BirthDate], [PhoneNumber], [Email], [Flag])
	values (@ID, @Name, @Gender, @Date_of_entry, @BirthDate, @PhoneNumber, @Email, 1)
	SET @n = @n + 1
	SET @k = @k + 1
	SET @d = @d + 1
end

select count(*) from [dbo].[dimDrivers]



--заполнение таблицы демография
insert into [BusRouteStore].[dbo].[miniDimDriverDemography]
	values ('18-22',0,0), ('18-22',0,1), ('18-22',0,2), ('18-22',1,1), ('18-22',1,2),('18-22',1,0),
	('23-26',0,0),('23-26',0,3), ('23-26',0,1), ('23-26',0,2), ('23-26',1,1), ('23-26',1,2),('23-26',1,0), ('23-26',1,3),
	('27-30',0,0),('27-30',0,3), ('27-30',0,1), ('27-30',0,2), ('27-30',1,1), ('27-30',1,2),('27-30',1,0), ('27-30',1,3),('27-30',1,4),('27-30',0,4),
	('31-35',0,0),('31-35',0,3), ('31-35',0,1), ('31-35',0,2), ('31-35',1,1), ('31-35',1,2),('31-35',1,0), ('31-35',1,3),('31-35',1,4),('31-35',0,4),
	('36-40',0,0),('36-40',0,3), ('36-40',0,1), ('36-40',0,2), ('36-40',1,1), ('36-40',1,2),('36-40',1,0), ('36-40',1,3),('36-40',1,4),('36-40',0,4),
	('36-40',1,5),('36-40',0,5),('36-40',1,6),('36-40',0,6), ('40-55',0,2), ('40-55',0,4), ('40-55',1,2), ('40-55',1,5)




-- заполнение таблицы маршрутов
delete from [dbo].[dimRoutes]

declare @n int = 0;
declare @ID int;
declare @a char = 'А', @z char = 'я', @w int, @l int
SET @w = ascii(@z) - ascii(@a);
SET @l = ascii(@a);
declare @TaxN bigint;
declare @TaxNumber nvarchar(12);
declare @Name nvarchar(20);
declare @StartStop nvarchar(45) = 'ул. А';
declare @EndStop nvarchar(45) = 'ул. Б';


while (@n<1000)
begin
	SET	@ID = ABS(CHECKSUM(NewId()));
	SET @TaxN = RAND()*1000000000000;
	SET @TaxNumber = cast(@TaxN as nvarchar(12));
	if (@n % 3 = 0) SET @Name = SUBSTRING(@TaxNumber, 1, 2) + char(round(rand() * @w, 0) + @l);
	else SET @Name = SUBSTRING(@TaxNumber, 1, 3) + char(round(rand() * @w, 0) + @l);
	if (len(@StartStop) > 30) SET @StartStop = 'ул. А' else SET @StartStop = @StartStop + char(round(rand() * @w, 0) + @l);
	if (len(@EndStop) > 30) SET @EndStop = 'ул. Б' else SET @EndStop = @EndStop + char(round(rand() * @w, 0) + @l);
	insert into [BusRouteStore].[dbo].[dimRoutes]([RouteID], [Name], [StartStop], [EndStop], [Flag])
	values (@ID, @Name, @StartStop, @EndStop, 1)
	SET @n = @n + 1
end


-- заполнение таблицы быстро изменяющихся параметров маршрута
delete from [dbo].[miniDimRoutes]

declare @n int = 0;
declare @ID int;
declare @TaxN bigint;
declare @TaxNumber nvarchar(12);
declare @PathLength int;
declare @Money money;
declare @Stops int;
declare @tmp int;

while (@n<1000)
begin
	SET	@ID = ABS(CHECKSUM(NewId()));
	SET @TaxN = RAND()*1000000000000;
	SET @TaxNumber = cast(@TaxN as nvarchar(12));
	SET @PathLength = CAST(SUBSTRING(@TaxNumber, 1, 2) as int);
	if (@PathLength < 10) SET @PathLength = @PathLength + 10;
	SET @Money = 20 + CAST(SUBSTRING(@TaxNumber, 3, 1) as money);
	SET @Stops = CAST(SUBSTRING(@TaxNumber, 3, 2) as int);
	if (@Stops > 30) SET @Stops = @Stops % 30;
	if (@Stops < 5) SET @Stops = @Stops + 5
	SET @tmp = @PathLength / @Stops;
	if (@tmp > 10) SET @PathLength = @tmp
	insert into [BusRouteStore].[dbo].[miniDimRoutes]([RouteFastChangeID], [PathLength], [MoneyForTravel], [NumberOfStops])
	values (@ID, @PathLength, @Money, @Stops)
	SET @n = @n + 1
end


-- заполнение таблицы, в которой содержится информация об автобусах
delete from dimBusInformation

declare @n int = 0;
declare @ID int;
declare @a char = 'А', @z char = 'я', @w int, @l int
SET @w = ascii(@z) - ascii(@a);
SET @l = ascii(@a);
declare @BusNumber nvarchar(6) = 'AAAAA';
declare @Brand nvarchar(20) = 'ВАЗ';
declare @Number int;

while (@n < 100000)
begin
	set	@ID = ABS(CHECKSUM(NewId()));
	set @Number = left(floor(rand() * 100000), 3);
	set @Number = cast(@Number as nvarchar);
	if (len(@brand) > 19) set @Brand = 'ВАЗ' else set @Brand = @Brand + char(round(rand() * @w, 0) + @l); 
	set @BusNumber = upper(@BusNumber+char(round(rand() * @w, 0) + @l));
	set @BusNumber = stuff(@BusNumber, 2,3, @Number);
	insert into [BusRouteStore].[dbo].[dimBusInformation] (BusID, Brand, BusNumber, PassangerCapacity, FuelConsumption, VolumeOfTheTank)
	values (@ID, @Brand, @BusNumber, CAST(RAND()*(210 - 70) + 70 as INT), ROUND(RAND()*(35 - 10) + 10, 2), ROUND(RAND()*(350 - 100) + 100, 2))
	set @n = @n + 1
end


-- заполнение таблицы быстро изменяющихся параметров автобуса
delete from miniDimBusInformation

declare @n int = 0;
declare @ID int;
while (@n < 100000)
begin
	set	@ID = ABS(CHECKSUM(NewId()));
	insert into [BusRouteStore].[dbo].[miniDimBusInformation] (BusFastChangeID, Mileage)
	values (@ID, CAST(RAND()*(250000 - 0) + 0 as INT))
	set @n = @n + 1
end


-- заполнение таблицы фактов "Отчет"
--delete from factReport


declare @n int = 0;
declare @cnt int = 0;
declare @ID int;
declare @FuelCost float = 51.34;
declare @AmountOfNotes int = RAND() * (25 - 6) + 6;
declare @CurDimDateID int;
select top 1 @CurDimDateID = DateID  from [BusRouteStore].[dbo].[dimDate]
declare @CurDimBusInfID int;
declare @CurMiniDimBusID int;
declare @CurDimRoutesID int;
declare @CurMiniDimRoutesID int;
declare @CurDimDriverID int;
declare @CurDimDriverDemoID int;
declare @MIleagePerRace int;
declare @PathLength int;
declare @AmountOfLiterslPerRace float;
declare @FuelConsum float;
declare @PassangerPerRace int;
declare @MoneyPerRace money;
declare @TravelMoney money;
declare @MoneyForFuel money;
declare @AmountOfRacePerDay int;

while (@n < 100000)
begin
	set	@ID = ABS(CHECKSUM(NewId()));
	-- определдение внешних ключей
	if (@cnt > @AmountOfNotes)
	begin
		set @cnt = 0;
		set @AmountOfNotes = RAND() * (25 - 6) + 6;
		set @CurDimDateID = @CurDimDateID + 1;
	end

	select top 1 @CurDimBusInfID = BusID from dimBusInformation order by NEWID()
	select top 1 @CurMiniDimBusID = BusFastChangeID from miniDimBusInformation order by NEWID()
	select top 1 @CurDimRoutesID = RouteID from dimRoutes order by NEWID()
	select top 1 @CurMiniDimRoutesID = RouteFastChangeID from miniDimRoutes order by NEWID()
	select top 1 @CurDimDriverID = DriverID from dimDrivers order by NEWID()
	select top 1 @CurDimDriverDemoID = DriverDemographyID from miniDimDriverDemography order by NEWID()

	-- определение количественных переменных
	set @AmountOfRacePerDay = Rand()*(20 - 1) + 1;
	select @PathLength = PathLength, @TravelMoney = MoneyForTravel from miniDimRoutes where RouteFastChangeID = @CurMiniDimRoutesID;
	set @MIleagePerRace = @AmountOfRacePerDay * @PathLength;
	select @FuelConsum = FuelConsumption from dimBusInformation where BusID = @CurDimBusInfID;
	set @AmountOfLiterslPerRace = ROUND((@MIleagePerRace * @FuelConsum) / 100, 2);
	set @PassangerPerRace = CAST(RAND() * (3000 - 120) + 120 as int);
	--select @TravelMoney = MoneyForTravel from miniDimRoutes where RouteFastChangeID = @CurMiniDimRoutesID;
	set @MoneyPerRace = CAST(@PassangerPerRace * @TravelMoney as money);
	set @MoneyForFuel = ROUND(CAST(@AmountOfLiterslPerRace * @FuelCost as money), 2)
	insert into [BusRouteStore].[dbo].[factReport] ([ReportID], [BusKey], [BusFastChangeKey], [RouteKey]
												   ,[RouteFastChangeKey], [DriverKey], [DriverDemographyKey]
												   ,[DateKey], [MileagePerRace], [PassangerPerRace]
												   ,[AmountOfLiterslPerRace], [MoneyPerRace], [MoneyForFuel], [TotalMoney], [NumberOfRacePerDay])
	values (@ID, @CurDimBusInfID, @CurMiniDimBusID, @CurDimRoutesID, @CurMiniDimRoutesID
		   , @CurDimDriverID, @CurDimDriverDemoID, @CurDimDateID, @MIleagePerRace
		   , @PassangerPerRace, @AmountOfLiterslPerRace, @MoneyPerRace, @MoneyForFuel
		   , @MoneyPerRace - @MoneyForFuel, @AmountOfRacePerDay)
	set @n = @n + 1
	set @cnt = @cnt + 1
end


SELECT MAX(DateKey) from factReport
SELECT COUNT(*) FROM factReport

---------------------------------------------------------------------------------------------------
CREATE PARTITION FUNCTION PartFuncFactReport_Date (BIGINT)
AS RANGE RIGHT FOR VALUES (20180101, 20190101, 20200101, 20210101, 20220101)

CREATE PARTITION SCHEME PartSrchFactReport_Date
AS PARTITION PartFuncFactReport_Date TO
( [Fast_Growing]
, [Fast_Growing]
, [Fast_Growing]
, [Frequently_Requested]
, [Frequently_Requested]
, [Frequently_Requested])

SELECT prt.partition_number, prt.rows, prv.value low_boundary, flg.name name_filegroup
FROM sys.partitions prt
	JOIN sys.indexes idx ON prt.object_id = idx.object_id
	JOIN sys.data_spaces dts ON dts.data_space_id = idx.data_space_id
	LEFT JOIN sys.partition_schemes prs ON prs.data_space_id = dts.data_space_id
	LEFT JOIN sys.partition_range_values prv ON prv.function_id = prs.function_id AND prv.boundary_id = prt.partition_number - 1
	LEFT JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = prs.data_space_id AND dds.destination_id =prt.partition_number
	LEFT JOIN sys.filegroups flg ON flg.data_space_id = dds.data_space_id
WHERE prt.object_id = (SELECT object_id FROM sys.tables WHERE name = 'factReport')

SELECT *
FROM factReport
where  DateKey >= 20180101 AND DateKey < 20190101



CREATE INDEX NonCL_Index_CheckData
ON factReport(PassangerPerRace)
INCLUDE (MileagePerRace) ON PartSrchFactReport_Date([DateKey])
WHERE MileagePerRace > 200

DROP INDEX NonCL_Index_CheckData ON factReport

CREATE INDEX NonCL_Index_CheckMileage
ON factReport(PassangerPerRace)
INCLUDE (MileagePerRace)
WHERE PassangerPerRace > 2000

DROP INDEX NonCL_Index_CheckMileage ON factReport

select top 100 PassangerPerRace from factReport

CREATE NONCLUSTERED COLUMNSTORE INDEX MyColStoreIndex 
ON factReport (DateKey, MileAgePerRace, totalMoney)

select DATEPART(yy, CAST(CONVERT(varchar(8), [DateKey]) as date)) as 'a', AVG(MileagePerRace), AVG(totalMoney) as 'Среднее' 
from factReport where DateKey >= 20190101 and DateKey < 20200101
group by DATEPART(yy, CAST(CONVERT(varchar(8), [DateKey]) as date))
order by 'a'

DROP INDEX MyColStoreIndex ON factReport


SELECT * FROM sys.partitions
WHERE OBJECT_ID = (SELECT OBJECT_ID FROM sys.tables WHERE name = 'factReport')


---------------------------------------------------------------------------------------------------
CREATE PARTITION FUNCTION PartFuncForArchivalTable (BIGINT)
AS RANGE RIGHT FOR VALUES (20180101)

CREATE PARTITION SCHEME PartSrchForArchivalTable
AS PARTITION PartFuncForArchivalTable TO
( [Fast_Growing]
, [Fast_Growing])

SELECT prt.partition_number, prt.rows, prv.value low_boundary, flg.name name_filegroup
FROM sys.partitions prt
	JOIN sys.indexes idx ON prt.object_id = idx.object_id
	JOIN sys.data_spaces dts ON dts.data_space_id = idx.data_space_id
	LEFT JOIN sys.partition_schemes prs ON prs.data_space_id = dts.data_space_id
	LEFT JOIN sys.partition_range_values prv ON prv.function_id = prs.function_id AND prv.boundary_id = prt.partition_number - 1
	LEFT JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = prs.data_space_id AND dds.destination_id =prt.partition_number
	LEFT JOIN sys.filegroups flg ON flg.data_space_id = dds.data_space_id
WHERE prt.object_id = (SELECT object_id FROM sys.tables WHERE name = 'ArchivalFactReport')


CREATE PROCEDURE Pr_SlidingWindow
AS
BEGIN
	DECLARE @DayForMaxPartFactReport varchar(8)
	DECLARE @DayForMaxPartArchival varchar(8)
	DECLARE @DayForMinPartFactReport varchar(8)
	DECLARE @DayForMinPartArchival varchar(8)
	-- получение верхней границы
	SET @DayForMaxPartFactReport = CAST((SELECT TOP 1 [value] FROM
	sys.partition_range_values
		WHERE function_id = (SELECT function_id FROM sys.partition_functions
							 WHERE name = 'PartFuncFactReport_Date')
		ORDER BY boundary_id DESC) as varchar(8))

	SET @DayForMaxPartArchival = CAST((SELECT TOP 1 [value] FROM
	sys.partition_range_values
		WHERE function_id = (SELECT function_id FROM sys.partition_functions
							 WHERE name = 'PartFuncForArchivalTable')
		ORDER BY boundary_id DESC) as varchar(8))

	-- определение граничных значений для новых секций
	DECLARE @Day_DT DATE
	SET @Day_DT = DATEADD(YEAR, 1, CAST(@DayForMaxPartFactReport AS DATE))

	DECLARE @DayArchival_DT DATE
	SET @DayArchival_DT = DATEADD(YEAR, 1, CAST(@DayForMaxPartArchival AS DATE))

	-- назначение файловой группы для вновь создаваемых секций
	ALTER PARTITION SCHEME PartSrchFactReport_Date
	NEXT USED [Frequently_Requested];

	ALTER PARTITION SCHEME PartSrchForArchivalTable
	NEXT USED [Frequently_Requested]

	-- Операция SPLIT на последней пустой секции таблицы фактов и архивной таблицы.
	ALTER PARTITION FUNCTION PartFuncFactReport_Date()
	SPLIT RANGE (CAST(CONVERT (VARCHAR(8),@Day_DT, 112) AS BIGINT))

	ALTER PARTITION FUNCTION PartFuncForArchivalTable()
	SPLIT RANGE (CAST(CONVERT (VARCHAR(8),@DayArchival_DT, 112) AS BIGINT))

	-- Перемещение данных из секции таблицы "FactReport" секцию архивной "ArchiveFactReport"
	ALTER TABLE FactReport
	SWITCH PARTITION 2
	TO ArchivalFactReport PARTITION 2

	-- нахождение нижних границ
	SET @DayForMinPartFactReport = CAST((SELECT TOP 1 [value] FROM
	sys.partition_range_values
	 WHERE function_id = (SELECT function_id 
	 FROM sys.partition_functions
	 WHERE name = 'PartFuncFactReport_Date')
	 ORDER BY boundary_id) AS VARCHAR(8))

	SET @DayForMinPartArchival = CAST((SELECT TOP 1 [value] FROM
	sys.partition_range_values
	 WHERE function_id = (SELECT function_id 
	 FROM sys.partition_functions
	 WHERE name = 'PartFuncForArchivalTable')
	 ORDER BY boundary_id) AS VARCHAR(8))
	 -- слияние относительно нижних границ
	ALTER PARTITION FUNCTION PartFuncFactReport_Date()
	MERGE RANGE (CAST(@DayForMinPartFactReport AS BIGINT));

	ALTER PARTITION FUNCTION PartFuncForArchivalTable()
	MERGE RANGE (CAST(@DayForMinPartArchival AS BIGINT));

END

select * from sys.partition_range_values


exec Pr_SlidingWindow

delete from ArchivalFactReport
drop procedure Pr_SlidingWindow


SELECT prt.partition_number, prt.rows, prv.value low_boundary, flg.name name_filegroup
FROM sys.partitions prt
	JOIN sys.indexes idx ON prt.object_id = idx.object_id
	JOIN sys.data_spaces dts ON dts.data_space_id = idx.data_space_id
	LEFT JOIN sys.partition_schemes prs ON prs.data_space_id = dts.data_space_id
	LEFT JOIN sys.partition_range_values prv ON prv.function_id = prs.function_id AND prv.boundary_id = prt.partition_number - 1
	LEFT JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = prs.data_space_id AND dds.destination_id =prt.partition_number
	LEFT JOIN sys.filegroups flg ON flg.data_space_id = dds.data_space_id
WHERE prt.object_id = (SELECT object_id FROM sys.tables WHERE name = 'factReport')

SELECT prt.partition_number, prt.rows, prv.value low_boundary, flg.name name_filegroup
FROM sys.partitions prt
	JOIN sys.indexes idx ON prt.object_id = idx.object_id
	JOIN sys.data_spaces dts ON dts.data_space_id = idx.data_space_id
	LEFT JOIN sys.partition_schemes prs ON prs.data_space_id = dts.data_space_id
	LEFT JOIN sys.partition_range_values prv ON prv.function_id = prs.function_id AND prv.boundary_id = prt.partition_number - 1
	LEFT JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = prs.data_space_id AND dds.destination_id =prt.partition_number
	LEFT JOIN sys.filegroups flg ON flg.data_space_id = dds.data_space_id
WHERE prt.object_id = (SELECT object_id FROM sys.tables WHERE name = 'ArchivalFactReport')


