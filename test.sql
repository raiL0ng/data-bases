create trigger push_bus
on Repair after insert
as
begin 
	if (select top (1) Date 
		from inserted order by RepairOfBusID desc ) != 
		DATEADD(day, 1, (select top (1) DateOfInspection 
						 from TechnicalInspection order by TechInspectionID desc))
	begin
		select * from inserted
		update Repair
		set Date = (select TOP (1) Dateadd(day, 1, DateOfInspection)
					from TechnicalInspection order by TechInspectionID desc)
		where Repair.Date = (select top (1) Date from inserted order by RepairOfBusID desc)
		raiserror('На ремонт автобус отправляется на следующий день после техосмотра!', 16, 1)
	end
	else print('Строка добавлена корректно')
end

drop trigger push_bus



insert into TechnicalInspection (BusID, EngineerID, DateOfInspection) values
( 4, 1, '20210911')

insert into Repair (TechInspectionID, CharacteristicID, [Date]) values
( 3, 4, '20210914')

select * from TechnicalInspection
select * from Repair

delete from Repair
where RepairOfBusID > 2



create trigger push_trip
on Timetable after insert
as
begin 
	if @@ROWCOUNT = 0
		return
	update Routes
	set AmountOfBuses = AmountOfBuses + @k
	from Routes join inserted i
	on Routes.RouteID =  i.RouteID
		
	print('Строка добавлена корректно')
end



create trigger push_techInsp
on dbo.Timetable after insert
as
begin 
	if @@ROWCOUNT = 0
		return
		
	print('Строка добавлена корректно')
end

drop trigger push_techInsp

---------------------------------------------TRIGGERS?---------------------------------------------
if exists (select t.BusID, count(t.BusID)
from Timetable t
group by t.BusID
having count(t.BusID) = 1)
select * from Timetable
else select BusID from Timetable

if exists (select t.BusID,count(t.BusID)
from Timetable t
group by t.BusID
having count(t.BusID) > 1)
select * from Timetable
else select BusID from Timetable

if exists (select t.RouteID, t.BusID,count(t.RouteID)
from Timetable t
group by t.RouteID, t.BusID
having count(t.BusID) =	1)

select * from Timetable
else select BusID from Timetable


create table table1 
(
[testID] int not null identity(1,1) primary key,
[test1] int not null,
[test2] int null
);

insert into table1 ([test1], [test2]) values
(1, null),
(2, null),
(3, null)

create table table2 
(
[testID] int not null identity(1,1) primary key,
[test1] int not null,
[test2] int null
);

insert into table2 ([test1], [test2]) values
(6, null),
(2, null),
(3, null)

update table1
set test1 = 555
from table1 t1
inner join table2 t2
on t1.test1 = t2.test1 

delete from table1
where testID = 1
declare @s int
set @s = (select t1.test1 from table1 t1 inner join table2 t2 on t1.test1 = t2.test1)
delete from table1
where test1 = @s
select * from table1
select * from table2
drop table table1
drop table table2



create procedure show_driver_with_cursor @cur cursor varying output, @y int
as
begin
	set @cur = cursor
	forward_only static for
		select BusID from BusInformation
	open @cur
	fetch next from @cur into @y
end

declare @cursor cursor
declare @chto int
set @chto = 2
exec show_driver_with_cursor @x = @cursor output
while (@@FETCH_STATUS = 0)  
begin  
	select BusNumber from BusInformation where BusID = @chto
	fetch next from @cursor into @chto;  
end  
close @cursor  
deallocate @cursor

drop procedure show_driver_with_cursor


select Brand 'Марка автобуса',
		  BusNumber 'Номер автобуса',
		  iif(ti.TechInspectionID != 0, 'Отправлен на техосмотр', 'В наличии') 'Описание'
from BusInformation b
inner join TechnicalInspection ti
on b.BusID = ti.BusID

SELECT TABLE_NAME FROM information_schema.TABLES
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'BusInformation'

select * from Timetable




-- Используется представление, где отображаются все автобусы, которые готовы к эксплуатации и которые
-- находятся в данный момент на техосмотре
create view Bus_with_repair
as select Brand 'Марка автобуса',
		  BusNumber 'Номер автобуса',
		  iif(ti.TechInspectionID != 0 and ti.DateOfInspection = convert(date, getdate()), 
		      'Отправлен на техосмотр', 'В наличии') 'Описание'
from BusInformation b
left join TechnicalInspection ti
on b.BusID = ti.BusID

select * from Bus_with_repair

drop view Bus_with_repair

select top(1) BusID from BusInformation
where BusNumber not in (select [Номер автобуса] from Bus_with_repair
						where [Описание] <> 'В наличии')
order by rand(BusID)


insert into TechnicalInspection(BusID, EngineerID, DateOfInspection) values
((select top(1) BusID from BusInformation
where BusNumber not in (select [Номер автобуса] from Bus_with_repair
						where [Описание] <> 'В наличии') order by rand())
, (select top(1) EngineerID from Engineers
   where EngineerID not in (select EngineerID from TechnicalInspection) order by rand())
, convert(date, getdate()))
