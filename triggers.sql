---------------------------------------------------------------------------------------------------
--------------------------------------------INSERT + UPDATE
select * from BusInformation

create trigger push_bus
on BusInformation after insert, update
as
begin
	declare @brand nvarchar(50), @fuel int, @volume int
	declare @upt_cur cursor

	set @upt_cur = cursor scroll for
		select distinct Brand, FuelConsuption, VolumeOfTheTank
		from BusInformation where FuelConsuption is not null or VolumeOfTheTank is not null

	open @upt_cur
	fetch next from @upt_cur into @brand, @fuel, @volume

	while @@FETCH_STATUS = 0
		begin
			update BusInformation
			set FuelConsuption = @fuel
			where Brand = @brand

			update BusInformation
			set VolumeOfTheTank = @volume
			where Brand = @brand
			fetch next from @upt_cur into @brand, @fuel, @volume
		end
	close @upt_cur
	deallocate @upt_cur
end

drop trigger push_bus

insert into BusInformation (Brand, BusNumber, PassangerCapacity, Mileage, FuelConsuption, VolumeOfTheTank) values
( 'Группа ГАЗ', N'П542ШЛ', 53, 530, null, null),
( 'SuperBus', N'К921ОВ', 25, 0, null, null)

select * from BusInformation

---------------------------------------------------------------------------------------------------
---------------------------------------------DELETE
select * from Repair

create trigger del_repair_notes
on Repair after delete
as
begin
	declare @id_tech int
	declare @del_cur cursor
	
	set @Del_cur = cursor scroll for
		select TechInspectionID
		from deleted

	open @del_cur 
	fetch next from @del_cur into @id_tech
	
	while @@FETCH_STATUS = 0 
	begin
		delete from Repair
		where TechInspectionID = @id_tech

		delete from TechnicalInspection
		where TechInspectionID = @id_tech

		fetch next from @del_cur into @id_tech
	end
	close @del_cur
	deallocate @del_cur
end

drop trigger del_repair_notes

delete from Repair
where RepairOfBusID > 2

select * from Repair
select * from TechnicalInspection

insert into TechnicalInspection (BusID, EngineerID, DateOfInspection) values
( 4, 1, '20210929')
, (7, 3, '20210930' )

insert into Repair (TechInspectionID, CharacteristicID, [Date]) values
( 3, 4, '20210930')
, (4, 1, '20211001')
---------------------------------------------------------------------------------------------------
---------------------------------------------INSERTED
create view dbo.Repair_list
WITH SCHEMABINDING
as select e.Name EngineerName,
   	      bus.Brand BusBrand,
		  bus.BusNumber BusNumber, 
		  tchar.ProblemName ProblemName
from dbo.Repair r
join dbo.TechnicalInspection ti
on ti.TechInspectionID = r.TechInspectionID
join dbo.Engineers e
on e.EngineerID = ti.EngineerID
join dbo.BusInformation bus
on bus.BusID = ti.BusID
join dbo.TechInspectionCharacteristics tchar
on tchar.CharacteristicID = r.CharacteristicID

select * from Repair_list

drop view Repair_list

create trigger update_repair_list
on [BusRouteSchedule].dbo.Repair_list instead of insert
as
begin
	insert into Engineers(Name, Salary)
	select inserted.EngineerName, null
	from inserted

	insert into TechnicalInspection(BusID, EngineerID, DateOfInspection)
	select (select BusID from BusInformation b join inserted i on b.BusNumber = i.BusNumber),
		   (select EngineerID from Engineers join inserted on Name = EngineerName),
		   convert(date, getdate(), 112)

	insert into Repair(TechInspectionID, CharacteristicID, [Date])
	select (select TechInspectionID from TechnicalInspection where DateOfInspection = convert(date, getdate(), 112)),
		   (select CharacteristicID 
			from TechInspectionCharacteristics tchar join inserted i on tchar.ProblemName = i.ProblemName),
		   (select DATEADD(day, 1, DateOfInspection) 
			from TechnicalInspection where DateOfInspection = convert(date, getdate(), 112))
end

drop trigger update_repair_list
select * from BusInformation
select * from Engineers
select * from TechnicalInspection
select * from Repair

insert into Repair_list(EngineerName, BusBrand, BusNumber, ProblemName) values
('Александр Викторович Камушкин', 'Daewoo', 'Р491ММ', 'Засорение топливопроводов и фильтров')

---------------------------------------------------------------------------------------------------
---------------------------------------------UPDATE
delete from Repair
where RepairOfBusID > 2
delete from TechnicalInspection
where TechInspectionID > 2
delete from Engineers
where EngineerID > 4

create view Bus_with_repair
as select Brand 'Марка автобуса',
		  BusNumber 'Номер автобуса',
		  iif(ti.TechInspectionID != 0, 'Отправлен на техосмотр', 'В наличии') 'Описание'
from BusInformation b
left join TechnicalInspection ti
on b.BusID = ti.BusID

select * from Bus_with_repair

drop view Bus_with_repair

create trigger update_state_bus
on Bus_with_repair instead of update
as
begin
	if exists (select * from inserted where inserted.[Описание] = 'Отправлен на техосмотр')
		begin
		insert into TechnicalInspection(BusID, EngineerID, DateOfInspection)
			select (select BusID from BusInformation b join inserted i on b.BusNumber = i.[Номер автобуса]),
				   (select top (1) e.EngineerID
				    from Engineers e join TechnicalInspection ti on e.EngineerID != ti.EngineerID),
				   convert(date, getdate(), 112)
		end
end

select * from Bus_with_repair
select * from TechnicalInspection

update Bus_with_repair
set [Описание] = 'Отправлен на техосмотр'
where [Номер автобуса] = 'Р154ЛУ'
---------------------------------------------------------------------------------------------------
---------------------------------------------DELETE

-- Представление для вывода информации об автобусах находящихся на автостоянке(на работе)
create view state_of_buses
as
select b.BusID,
	   Brand,
	   BusNumber,
	   PassangerCapacity,
	   Mileage,
	   FuelConsuption,
	   VolumeOfTheTank,
	   iif( TimetableID != 0, 'На работе', 'На автостоянке') [State]
from BusInformation b
left join Timetable t
on b.BusID = t.BusID

select * from state_of_buses

drop view state_of_buses

-- Представление для вывода автобусов, которые в скором времени нужно списать
create view old_buses
as
select BusID 'ID автобуса', 
	   Brand 'Марка автобуса',
	   BusNumber 'Номер автобуса',
	   Mileage 'Пробег'
from BusInformation
where Mileage > 200000

select * from old_buses

-- Представление для простоты вывода автобусов и их позиции
create view Check_old_buses
as
select [ID автобуса],
	   [Марка автобуса],
	   [Номер автобуса],
	   [Пробег],
	   [State]
from old_buses
left join state_of_buses
on [ID автобуса] = BusID

select * from Check_old_buses

drop view Check_old_buses

create trigger del_old_buses
on Check_old_buses instead of delete
as
begin
	-- определение переменных
	declare @ind int, @indB int
	declare @check_id cursor, @check_idB cursor
	-- запись id списанных автобусов в курсор
	set @check_id = cursor scroll for
		select TechInspectionID
		from TechnicalInspection, deleted
		where BusID = deleted.[ID автобуса]
	
	set @check_idB = cursor scroll for
		select BusID
		from BusInformation, deleted
		where BusID = deleted.[ID автобуса]


	if exists (select * from deleted where deleted.[State] = 'На работе')
		begin
			-- Обновляем таблицу Timetable чтобы заменить списанные автобусы на новые
			update Timetable
			set BusID = (select top (1) BusID 
						 from state_of_buses where [State] = 'На автостоянке' and Mileage < 200000)
			from Timetable
			inner join deleted
			on BusID = [ID автобуса]
		end


		-- Удаление записей списанных автобусов, хранящихся в таблицах техосмотра и ремонта
		open @check_id 
		fetch next from @check_id into @ind
		
		while @@FETCH_STATUS = 0 
		begin
			delete from Repair
			where TechInspectionID = @ind

			delete from TechnicalInspection
			where TechInspectionID = @ind

			fetch next from @check_id into @ind
		end
		close @check_id

		--Удаление записей в таблице BusInformation
		open @check_idB 
		fetch next from @check_idB into @indB
		
		while @@FETCH_STATUS = 0 
		begin
			delete from BusInformation
			where BusID = @indB

			fetch next from @check_idB into @indB
		end
		close @check_idB

		deallocate @check_id
		deallocate @check_idB
end


select * from BusInformation
select * from TechnicalInspection
select * from Repair
select * from Timetable

drop trigger del_old_buses


delete from Check_old_buses


