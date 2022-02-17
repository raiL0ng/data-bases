-- Задание 1
-- inner join сопоставляет таблицы по определенному условию 
select Drivers.Name, BusNumber, rt.Name, StartTimeOfWork, EndTimeOfWork, [DayOfWeek]
from Timetable as tbl inner join Drivers
on Drivers.DriverID = tbl.DriverID
inner join BusInformation as bus
on bus.BusID = tbl.BusID
inner join Routes as rt
on rt.RouteID = tbl.RouteID

-- left join сначала выводятся строки, которые выводятся с помощью inner join,
-- затем выводятся строки ЛЕВОЙ таблицы не вошедшие в данный запрос 
select bus.BusNumber, Brand, PassangerCapacity, Mileage, Routes.Name 
from BusInformation as bus left join Timetable as tbl 
on bus.BusID = tbl.BusID
left join Routes
on Routes.RouteID = tbl.RouteID

-- right join сначала выводятся строки, которые выводятся с помощью inner join,
-- затем выводятся строки ПРАВОЙ таблицы не вошедшие в данный запрос
select RepairOfBusID, Date, ProblemName
from Repair right join TechInspectionCharacteristics as tic
on Repair.CharacteristicID = tic.CharacteristicID

-- full join = left join + right join
select *
from RoutesAndStops full join Stops
on Stops.StopID = RoutesAndStops.StopID

-- cross join работает по принципу декартового произведения 
select *
from Repair cross join TechInspectionCharacteristics

-- cross apply практически идентично inner join, но с помощью cross apply
-- можно сделать корреляцию внутреннего запроса (то что в скобочках) с 
-- внешним запросом по совпадающим значениям
select *
from BusInformation as b cross apply (select [Date], [DayOfWeek] from Timetable as t
where b.BusID = t.BusID) as BusTable

---------------------------------------------------------------------------------------------------
-- Задание 2
-- union cцепляет результаты двух запросов в один результирующий набор
-- union по умолчанию выводит Distinct (уникальные) значения
select RouteID
from Stops s inner join RoutesAndStops rs
on s.StopID = rs.StopID
union
select rs.RouteID
from RoutesAndStops rs inner join Routes r
on r.RouteID = rs.RouteID

-- union all объединяет все значения, которые выводятся
-- в первом и во втором запросах
select RouteID
from Stops s inner join RoutesAndStops rs
on s.StopID = rs.StopID
union all
select rs.RouteID
from RoutesAndStops rs inner join Routes r
on r.RouteID = rs.RouteID

-- except возвращает уникальные строки из левого входного запроса, которые не выводятся правым
-- входным запросом
select BusID
from BusInformation
except
select BusID
from Timetable


-- intersect возвращает уникальные строки, выводимые левым и правым входными запросами
select BusID
from BusInformation
intersect
select BusID
from Timetable
---------------------------------------------------------------------------------------------------
-- Задание 3
-- exists применяется в случаях, когда необходимо найти значения, соответствующие основному
-- условию... пример: выводится информация о тех автобусах, которые поставлены на рейс в 
-- таблице Timetable
select *
from BusInformation b
where exists (select * from Timetable t where  b.BusID = t.BusID)

-- также можно использовать not exists
select *
from BusInformation b
where not exists (select * from TechnicalInspection t where  b.BusID = t.BusID)

-- in позволяет определить, совпадает ли значение объекта со значением в списке
-- пример: вывод только тех строк, которые содержат информацию о начальных и
-- конечных остановках
select *
from RoutesAndStops rs
where Identification in ('S', 'E')

-- all возвращает таблицу, если все значения подчиненного запроса 
-- удовлетворяют условию. пример: вывести таблицу автобусов, у которых пробег
-- меньше пробега автобусов марки "НефАЗ"
select *
from BusInformation b
where Mileage < all (select Mileage from BusInformation where Brand = 'НефАЗ') 

select * from BusInformation
-- any возвращает таблицу, если любое из значений подчиненного запроса
-- удовлетворяет условию
select *
from BusInformation b
where Mileage < any (select Mileage from BusInformation where Brand = 'НефАЗ') 

-- between возвращает значение TRUE, если значение внешнего аргумента больше
-- значения начального выражения или равно ему и меньше значения конечного выражения или равно ему
select *
from BusInformation
where FuelConsuption between 21 and 28

--like oпределяет, совпадает ли указанная символьная строка с заданным шаблоном
select *
from BusInformation
where BusNumber like 'Р%'
---------------------------------------------------------------------------------------------------
-- Задание 4
-- простой case выводит таблицу с учетом n опций
select * from RoutesAndStops

select StopID, RouteID,
	case Identification
		when 'S' then 'Start stop'
		when 'I' then 'Interval stop'
		when 'E' then 'End stop'
		else null
	end as Description, NumberOfArrivals
from RoutesAndStops

-- поисковый case
select * from Routes
select RouteID, Name, TravelTime, AmountOfBuses, 'Current Price' =
	case
		when MoneyForTravel = 23 then 'По городу'
		when MoneyForTravel > 23 then 'Меж-город'
		else 'Нет данных'
	end
from Routes
---------------------------------------------------------------------------------------------------
-- Задание 5
-- cast преобразует выражение одного типа к другому
select cast(StartTimeOfWork as nvarchar) + '-' + cast(EndTimeOfWork as nvarchar) + '; ' + 
cast(Date as nvarchar) as 'Time of work'
from Timetable

-- convert преобразует выражение одного типа к другому с возможностью форматирования
select convert(nvarchar, StartTimeOfWork, 8) + '-' + convert(nvarchar, EndTimeOfWork, 8) + '; ' + 
	   convert(nvarchar, Date, 106) as 'Time of work'
from Timetable

-- null oпределяет, может ли указанное выражение быть null
select * 
from Engineers
where Salary is null

-- isnull заменяет значение null указанным замещающим значением
select 	Brand, BusNumber, ISNULL(FuelConsuption, 32)
from BusInformation
where Brand = 'MAN'

-- nullif возвращает значение null, если два указанных выражения равны
-- В данном пример везде выдает null, так как сравниваются одинаковые столбцы
select NUllIF(VolumeOfTheTank, VolumeOfTheTank) as Different
from BusInformation
where Brand = 'MAN'

-- coalesce вычисляет аргументы по порядку и возвращает текущее значение
-- первого выражения, изначально не вычисленного как null
-- В данном примере, если функция coalisce находит первое значение равное null,
-- то она переходит ко второму значению, выводя значение второго аргумента
select VolumeOfTheTank, Mileage, FuelConsuption, coalesce(VolumeOfTheTank, Mileage)
from BusInformation

-- choose возвращает элемент по указанному индексу из списка значений
select Date, choose(Month(Date), 'Январь', 'Февраль','Март','Авпрель','Май','Июнь'
							   ,'Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь')
from Repair

-- iif возвращает одно из двух значений в зависимости от того, принимает логическое
-- выражение значение true или false
-- Стоит отметить, что в данном запросе получается декартово произведение всех зарплат
select d.Salary, c.Salary, iif(d.Salary > c.Salary, 'True', 'False') as 'Test'
from Drivers d, Conductors c
---------------------------------------------------------------------------------------------------
-- Задание 6
-- replace заменяет все вхождения указанного строкового значения другим строковым значением
select replace(Name, 'ул.', 'улица')
from Stops

-- substring возвращает часть символьного, двоичного, текстового или графического выражения
select SUBSTRING(BusNumber, 2, 3) as 'Номера автобусов (цифры)'
from BusInformation

-- stuff вставляет одну строку в другую. Она удаляет указанное количество символов первой
-- строки в начальной позиции и вставляет на их место вторую строку
-- Стоит отметить, что данную функцию необходимо использовать в таких случаях, когда строки
-- практически одинаковы, иначе случится беда, как в этом примере...
select STUFF(Name, 3, 1, 'ица ')
from Stops

-- str возвращает символьные данные, преобразованные из числовых данных
select STR(Cast(Salary as float), 7, 1)
from Drivers

-- unicode возвращает целочисленное значение, соответствующее стандарту Юникод, 
-- для первого символа входного выражения
select UNICODE(Identification)
from RoutesAndStops

-- lower возвращает символьное выражение после преобразования символов верхнего регистра
-- в символы нижнего регистра
select LOWER(BusNumber)
from BusInformation

-- upper возвращает символьное выражение, в котором символы нижнего регистра
-- преобразованы в символы верхнего регистра
select UPPER(Name)
from Stops
---------------------------------------------------------------------------------------------------
-- Задание 7
-- datepart - функция возвращает целое число, представляющее указанную часть datepart заданного
-- типа date. В примере выводится номер дня недели
select Date, DATEPART(WEEKDAY, Date) 'Вывод дня недели'
from Timetable

-- dateadd - функция добавляет указанное значение number (целое число со знаком) к заданному
-- аргументу datepart входного значения date, а затем возвращает это измененное значение
select DATEADD(day, 3, Date) 'Вывод новой даты'
from Repair

-- datediff - функция возвращает количество пересеченных границ (целое число со знаком),
-- указанных в аргументе datepart, за период времени
select DATEDIFF(MONTH, '20210601', '20211001')
from Repair

-- getdate возвращает текущую системную метку времени базы данных в виде значения datetime
-- без смещения часового пояса базы данных
select GETDATE() as 'Текущее время'

-- sysdetetimeoffset возвращает значение типа datetimeoffset(7), которое содержит дату и
-- время компьютера, на котором запущен экземпляр SQL Server
select SYSDATETIMEOFFSET() as 'Текущее время'
---------------------------------------------------------------------------------------------------
-- Задание 8
-- group by используется для определения групп выходных строк, к которым могут применяться
-- агрегатные функции (COUNT, MIN, MAX, AVG и SUM)
select rs.RouteID, COUNT(rs.RouteID) as 'Количество остановок'
from RoutesAndStops rs
group by rs.RouteID

-- having является указателем на результат выполнения агрегатных функций
select Brand, Count(Brand)
from BusInformation
group by Brand
having Brand <> 'НефАЗ'
---------------------------------------------------------------------------------------------------