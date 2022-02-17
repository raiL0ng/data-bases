-- Задание 1 Создание представлений
-- Вывод таблицы, из которой видно, какой водитель и какой автобус назначен на данный маршрут,
-- также выводится время работы и день недели, когда текущий водитель работает.
create view Driver_timetable
as select d.Name 'Водитель',
	      BusNumber 'Номер автобуса',
		  rt.Name 'Номер маршрута',
		  StartTimeOfWork 'Начало рабочего дня',
		  EndTimeOfWork 'Конец рабочего дня',
		  [DayOfWeek] 'День недели'
from Timetable as tbl 
inner join Drivers as d
on d.DriverID = tbl.DriverID
inner join BusInformation as bus
on bus.BusID = tbl.BusID
inner join Routes as rt
on rt.RouteID = tbl.RouteID

drop view Driver_timetable

-- Вывод таблицы, в которой выводятся все текущие маршруты на данный момент
-- с названиями начальных и конечных остановок.
create view Routes_list
as select rt.Name 'Название маршрута',
		  s.Name 'Название остановки',
		  case Identification
			   when 'S' then 'Начало маршрута'
			   when 'E' then 'Конец маршрута'
			   else null
	      end as 'Описание'
from Routes rt
inner join RoutesAndStops rts
on rt.RouteID = rts.RouteID
inner join Stops s
on s.StopID = rts.StopID and Identification in ('S', 'E')

drop view Routes_list
-- Вывод таблицы, в которой выводится информация об автобусах отправленных в ремонт,
-- инженер, назначенный на техосмотр автобусов и обнаруживший причину поломки.
create view Repair_list
as select e.Name 'Имя сотрудника',
   	      bus.Brand 'Марка автобуса',
		  bus.BusNumber 'Номер автобуса', 
		  tchar.ProblemName 'Причина поломки'
from Repair r
inner join TechnicalInspection ti
on ti.TechInspectionID = r.TechInspectionID
inner join Engineers e
on e.EngineerID = ti.EngineerID
inner join BusInformation bus
on bus.BusID = ti.BusID
inner join TechInspectionCharacteristics tchar
on tchar.CharacteristicID = r.CharacteristicID

drop view Repair_list
-- Вывод таблицы, где отображаются все автобусы, которые готовы к эксплуатации и которые
-- находятся в данный момент на техосмотре
create view Bus_with_repair
as select Brand 'Марка автобуса',
		  BusNumber 'Номер автобуса',
		  iif(ti.TechInspectionID != 0, 'Отправлен на техосмотр', 'В наличии') 'Описание'
from BusInformation b
left join TechnicalInspection ti
on b.BusID = ti.BusID

drop view Bus_with_repair
---------------------------------------------------------------------------------------------------
-- Задание 2 Создание обновляемого представления
-- Примечание: Нельзя удалить или добавить строку, если представление ссылается на несколько
-- базовых таблиц. Можно обновлять только те столбцы, которые принадлежат к одной базовой таблице.

-- Поэтому создадим представление в котором производится работа с одной таблицей, где выводится
-- информация о тех автобусах, которые не поставлены на рейс, отображающихся в таблице Timetable
create view Bus_list
as select *
from BusInformation b
where exists (select * from Timetable t where  b.BusID = t.BusID) 
WITH CHECK OPTION;

select * from Bus_list
-- Данная вставка не будет выполнена, так как у представления стоит WITH CHECK OPTION. Строка не
-- будет добавлена потому что в данном представлении она будет мнимой (т.е. она не выводится).
-- Если добавить такую строку, которая бы точно гарантированно отобразилась в таблице представления,
-- то она бы добавилась также и в главную таблицу (в моем случае BusInformation)
insert into Bus_list ( Brand, BusNumber, PassangerCapacity,
							 Mileage, FuelConsuption, VolumeOfTheTank)
values ('Daewoo', N'К821ОТ', 104, 2244, 28, 200);

--drop view Bus_list

select * from BusInformation

delete from BusInformation
where BusNumber = 'К821ОТ'

delete from Bus_list
where BusNumber = 'К821ОТ'
---------------------------------------------------------------------------------------------------
-- Задание 3 Создание индексированного представления

SET NUMERIC_ROUNDABORT OFF;
SET ANSI_PADDING, ANSI_WARNINGS,
CONCAT_NULL_YIELDS_NULL, ARITHABORT, 
QUOTED_IDENTIFIER, ANSI_NULLS ON;

create view Bus_ind
with schemabinding
as select BusID, Brand, BusNumber, PassangerCapacity,
		  Mileage, FuelConsuption, VolumeOfTheTank
from dbo.BusInformation
where Mileage < 200000

create unique clustered index Cl_ind_Bus
on Bus_ind(BusID)

select *
from Bus_ind
with (noexpand)
where Mileage < 200000

drop index Cl_ind_Bus on Bus_ind

drop view Bus_ind