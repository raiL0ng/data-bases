 -- 1. Запрос с использованием автономных подзапросов
select BusID, BusNumber
from BusInformation
where BusID not in (select BusID from Timetable)

select BusID, BusNumber
from BusInformation
where BusID in (select BusID from Timetable)


insert into TechnicalInspection(BusID, EngineerID, DateOfInspection) values
((select top(1) BusID from BusInformation
  where BusID not in (select BusID from TechnicalInspection) order by rand())
, (select top(1) EngineerID from Engineers
   where EngineerID not in (select EngineerID from TechnicalInspection) order by rand())
, convert(date, getdate()))

select * from TechnicalInspection

delete from TechnicalInspection
where DateOfInspection = convert(date, getdate())

select top(1) EngineerID from Engineers
where EngineerID not in (select EngineerID from TechnicalInspection)
order by rand()


 --------------------------------------------------------------------------------------------------
 -- 2. Создание запроса с использованием коррелированных подзапросов в предложении SELECT и WHERE

select rs.RouteID, (select name from Routes where rs.RouteID = Routes.RouteID),
	   rs.StopID, (select name from Stops where rs.StopID = Stops.StopID)
from RoutesAndStops as rs, Routes r

select BusNumber
from BusInformation b
where b.BusID = (select top(1) BusID from TechnicalInspection t where b.BusID = t.BusID)
---------------------------------------------------------------------------------------------------
-- 3. Запрос с использованием временных таблиц

select StopID, RouteID, Identification
into #newRoutesAndStops
from RoutesAndStops

select * from #newRoutesAndStops


---------------------------------------------------------------------------------------------------
-- 4. Запрос с использованием обобщенных табличных выражений (CTE)

create view Bus_with_repair
as select Brand 'Марка автобуса',
		  BusNumber 'Номер автобуса',
		  iif(ti.TechInspectionID != 0 and ti.DateOfInspection = convert(date, getdate()), 
		      'Отправлен на техосмотр', 'В наличии') 'Описание'
from BusInformation b
left join TechnicalInspection ti
on b.BusID = ti.BusID

select * from Bus_with_repair

with cte_free_bus_list (BusID, Brand, BusNumber, Date)
as
(
select BusID, Brand, BusNumber, convert(date, getdate()) from BusInformation
where BusNumber not in (select [Номер автобуса] from Bus_with_repair
						where [Описание] = 'Отправлен на техосмотр')
)
select * from cte_free_bus_list
---------------------------------------------------------------------------------------------------
-- 5. Слияние данных (INSERT, UPDATE) c помощью инструкции MERGE.
create table new_engineers
(
EmplID int not null identity(1,1) primary key,
[Name] nvarchar(45) not null,
[Salary] int null,
);

insert into new_engineers (Name, Salary) values
(N'Валерий Александрович Шпак', 20000)
, (N'Николай Арсеньевич Шурупкин', 20000)
, (N'Ефим Альбертович Гвоздев', 20512)

select * from new_engineers

delete new_engineers

merge Engineers as BaseTbl
using new_engineers as SourceTbl
on BaseTbl.Name = SourceTbl.Name
when Matched then
	update set BaseTbl.Salary = SourceTbl.Salary
when not Matched then
	insert (Name, Salary)
	values (SourceTbl.Name, SourceTbl.Salary)
output $action, inserted.*;

select * from Engineers

delete from Engineers
where Name like '%Шпак'

update Engineers
set Salary = 20000
where Salary > 20000
---------------------------------------------------------------------------------------------------
-- 6. Запрос с использованием оператора PIVOT

select DateOfInspection, count(BusID)
from TechnicalInspection
group by DateOfInspection

select 'Количество автобусов' as 'Дата', [2021-08-29], [2021-08-30], [2021-09-01], [2021-09-02]
from (select cast(DateOfInspection as nvarchar(12)) as [Date], BusID 
	  from TechnicalInspection
	 ) as src_tbl
pivot (count(BusID) for [Date] in ([2021-08-29], [2021-08-30], [2021-09-01], [2021-09-02])
	  ) as pvt_tbl

select Brand as 'Марка автобусов', Count(Brand) as 'Количество автобусов'
from BusInformation
group by Brand

select 'Количество автобусов' as 'Марки автобусов', [Daewoo], [MAN], [Группа ГАЗ], [НефАЗ]
from
(
select Brand from BusInformation
) as source_table
pivot
(
count(Brand)
for Brand in ([Daewoo], [MAN], [Группа ГАЗ], [НефАЗ])
) as pivot_table
-- ?

---------------------------------------------------------------------------------------------------
-- 7. Запрос с использованием оператора UNPIVOT
-- Используется представление

-- Noted: необходимо всё согласовать с каким-либо определенным типом (все значения
-- должны быть одного типа)
select [Водитель], [Значения], [Информация]  from 
(
select [Водитель], cast([Номер автобуса] as nvarchar(25)) as [Номер автобуса],
	   cast([Номер маршрута] as nvarchar(25)) as [Номер маршрута],
	   convert(nvarchar(25), [Начало рабочего дня], 108) as [Отправление], 
	   convert(nvarchar(25), [Конец рабочего дня], 108) as [Прибытие],
	   cast([День недели] as nvarchar(25))[День недели] from Driver_timetable
where [Водитель] = 'Аркадий Васильевич Бутылкин' and [День недели] = 'Воскресенье'
) as source_
unpivot 
(
[Информация] for [Значения] in ([Номер автобуса], [Номер маршрута], [Отправление]
				 , [Прибытие], [День недели])
) as unpivot_table
---------------------------------------------------------------------------------------------------
-- 8. Запрос с использованием GROUP BY с операторами ROLLUP, CUBE и GROUPING SETS
  
-- Rollup - оператор, который формирует промежуточные итоги для каждого указанного
-- элемента и общий итог

create table Report (
ReportID int not null identity(1,1) primary key,
[BusNumber] nvarchar(6) not null,
[WorkDay] date not null,
[MileagePerDay] int not null,
[PassangerPerDay] int not null
);

insert into Report (BusNumber, WorkDay, MileagePerDay, PassangerPerDay)
values (N'Р207ТО', '20210901', 15, 170),
	   (N'К532ВУ', '20210901', 23, 256),
	   (N'Р207ТО', '20210902', 20, 234),
	   (N'К532ВУ', '20210902', 27, 277),
	   (N'Р207ТО', '20210903', 21, 242),
	   (N'К532ВУ', '20210903', 26, 266),
	   (N'Р207ТО', '20210904', 21, 212)

select BusNumber, WorkDay, Sum(MileagePerDay)
from Report
group by BusNumber, WorkDay, MileagePerDay

select BusNumber, WorkDay, Sum(MileagePerDay)
from Report
group by rollup (BusNumber, WorkDay, MileagePerDay)

-- Cube - оператор, который формирует результаты для всех возможных перекрестных вычислений
	
select BusNumber, WorkDay, Sum(MileagePerDay)
from Report
group by cube (BusNumber, WorkDay, MileagePerDay)


-- GROUPING SETS – оператор, который формирует результаты нескольких группировок в один набор 
-- данных, другими словами, он эквивалентен конструкции UNION ALL к указанным группам (такие
-- группы указываются в скобочках и их можно комбинировать)

select BusNumber, WorkDay, Sum(MileagePerDay)
from Report
group by grouping sets ((BusNumber, WorkDay, MileagePerDay), ())

---------------------------------------------------------------------------------------------------
-- 9. Секционирование с использованием OFFSET FETCH.

select * from RoutesAndStopsTimetable
order by TripTimetableID
offset 9 rows fetch next 9 rows only
---------------------------------------------------------------------------------------------------
-- 10. Запросы с использованием ранжирующих оконных функций. ROW_NUMBER() нумерация строк. 
-- Использовать для нумерации внутри групп. RANK(), DENSE_RANK(), NTILE().

-- ROW_NUMBER() нумерует выходные данные результирующего набора.
select row_number() over (order by TripTimetableID desc) as [№], *
from RoutesAndStopsTimetable

-- RANK() возвращает ранг каждой строки в секции результирующего набора.
select
BusNumber,
rank() over (order by MileagePerDay desc) as [Rank],
MileagePerDay
from Report

-- DENSE_RANK() - функция возвращает ранг каждой строки в
-- секции результирующего набора без промежутков в значениях ранжирования.
select 
BusNumber,
dense_rank() over (partition by BusNumber order by PassangerPerDay desc) as [Dense_Rank],
PassangerPerDay
from Report

-- NTILE() распределяет строки упорядоченной секции в заданное количество групп
select
NTile(4) over (order by MileagePerDay desc) as [NTile],
MileagePerDay
from Report

select
NTile(4) over (order by WorkDay desc) as [NTile],
WorkDay
from Report
---------------------------------------------------------------------------------------------------
-- 11. Перенаправление ошибки в TRY/CATCH

begin try
	insert into TechnicalInspection (BusID, EngineerID, DateOfInspection)
	values ('afsd', 10, '20200901')
	print 'Запрос выполнен успешно'
end try
begin catch
	print 'Error ' + convert(varchar, error_number()) + ':' + error_message()
end catch


begin try
	insert into TechnicalInspection (BusID, EngineerID, DateOfInspection)
	values (1, 10, '20200901')
	print 'Запрос выполнен успешно'
end try
begin catch
	print 'Error ' + convert(varchar, error_number()) + ':' + error_message()
end catch

begin try
	insert into TechnicalInspection (BusID, EngineerID, DateOfInspection)
	values (1, 10, '20201301')
	print 'Запрос выполнен успешно'
end try
begin catch
	print 'Error ' + convert(varchar, error_number()) + ':' + error_message()
end catch

---------------------------------------------------------------------------------------------------
-- 12. Создание процедуры обработки ошибок в блоке CATCH с использованием функций ERROR

create procedure amount_of_stops_ @name nvarchar(45)
as
begin
		declare @id int
		begin try
			set @id = (select RouteID from Routes where @name = Name)
			select count(RouteID)
			from RoutesAndStops where @id = RouteID
		end try
		begin catch
			print 'Error ' + convert(varchar, error_number()) + ':' + error_message()
		end catch
end


exec amount_of_stops_ @name = '13F'

drop procedure amount_of_stops_

---------------------------------------------------------------------------------------------------
-- 13. Использование THROW, чтобы передать сообщение об ошибке клиенту

-- THROW - оператор, который вызывает исключение и передеает блоку cathc инструкции try..catch
begin try
	insert into TechnicalInspection (TechInspectionID, BusID, EngineerID, DateOfInspection)
	values (4, 1, 10, '20201101')
	print 'Запрос выполнен успешно'
end try
begin catch
	print 'Ошибка в блоке TRY';
	throw;
end catch

begin try
	insert into TechnicalInspection (TechInspectionID, BusID, EngineerID, DateOfInspection)
	values (4, 1, 10, '20201101')
	print 'Запрос выполнен успешно'
end try
begin catch
	throw 50001, 'Ошибка в блоке TRY', 1;
end catch
---------------------------------------------------------------------------------------------------
-- 14. Контроль транзакций с BEGIN и COMMIT

-- Отмечает успешное завершение явной или неявной транзакции. Если значение @@TRANCOUNT равно 1,
-- то инструкция COMMIT TRANSACTION делает все изменения, произведенные с начала транзакции,
-- постоянной частью базы данных, освобождает ресурсы транзакции и уменьшает значение параметра
-- @@TRANCOUNT до 0. Если значение @@TRANCOUNT больше 1, инструкция COMMIT TRANSACTION уменьшает
-- значение @@TRANCOUNT только на 1 и оставляет транзакцию активной.

begin transaction
select * from BusInformation

select @@TRANCOUNT as [Trancount_after_begin]

commit transaction

select @@TRANCOUNT as [Trancount_after_commit]
---------------------------------------------------------------------------------------------------
-- 15. Использование XACT_ABORT

-- XACT_ABORT – это параметр, который указывает Microsoft SQL Server, выполнять ли откат всей
-- транзакции и прерывать ли пакет команд в случае возникновения ошибки в инструкциях этой
-- транзакции.

set xact_abort off;

begin transaction

update Conductors
set Salary = 15001
where ConductorID = 1

update Conductors
set Salary = Salary / 0
where ConductorID = 2

commit transaction

select * from Conductors


set xact_abort on;

begin transaction

update Conductors
set Salary = 15002
where ConductorID = 1

update Conductors
set Salary = Salary / 0
where ConductorID = 2

commit transaction

select * from Conductors


-- Если выполнена инструкция SET XACT_ABORT ON и инструкция языка Transact-SQL вызывает ошибку,
-- вся транзакция завершается и выполняется ее откат.
-- Если выполнена инструкция SET XACT_ABORT OFF, в некоторых случаях выполняется откат только
-- вызвавшей ошибку инструкции языка Transact-SQL, а обработка транзакции продолжается.
-- В зависимости от серьезности ошибки возможен откат всей транзакции при выполненной
-- инструкции SET XACT_ABORT OFF.
-- По умолчанию XACT_ABORT установлен в OFF(а в триггерах по умолчанию ON)

---------------------------------------------------------------------------------------------------
-- 16. Добавление логики обработки транзакций в блоке CATCH
begin  transaction

begin try
	delete from Conductors
	where ConductorID = 21 / 0
end try
begin catch
	select ERROR_NUMBER() as ErrorNumber,
		   ERROR_STATE() as ErrorState,
		   ERROR_MESSAGE() as ErrorMessage;
	
	select @@TRANCOUNT
	if @@TRANCOUNT > 0
		rollback transaction
end catch

if @@TRANCOUNT > 0
	commit transaction

select * from Conductors
