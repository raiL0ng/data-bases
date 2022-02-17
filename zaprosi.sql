-- ������� 1
-- inner join ������������ ������� �� ������������� ������� 
select Drivers.Name, BusNumber, rt.Name, StartTimeOfWork, EndTimeOfWork, [DayOfWeek]
from Timetable as tbl inner join Drivers
on Drivers.DriverID = tbl.DriverID
inner join BusInformation as bus
on bus.BusID = tbl.BusID
inner join Routes as rt
on rt.RouteID = tbl.RouteID

-- left join ������� ��������� ������, ������� ��������� � ������� inner join,
-- ����� ��������� ������ ����� ������� �� �������� � ������ ������ 
select bus.BusNumber, Brand, PassangerCapacity, Mileage, Routes.Name 
from BusInformation as bus left join Timetable as tbl 
on bus.BusID = tbl.BusID
left join Routes
on Routes.RouteID = tbl.RouteID

-- right join ������� ��������� ������, ������� ��������� � ������� inner join,
-- ����� ��������� ������ ������ ������� �� �������� � ������ ������
select RepairOfBusID, Date, ProblemName
from Repair right join TechInspectionCharacteristics as tic
on Repair.CharacteristicID = tic.CharacteristicID

-- full join = left join + right join
select *
from RoutesAndStops full join Stops
on Stops.StopID = RoutesAndStops.StopID

-- cross join �������� �� �������� ����������� ������������ 
select *
from Repair cross join TechInspectionCharacteristics

-- cross apply ����������� ��������� inner join, �� � ������� cross apply
-- ����� ������� ���������� ����������� ������� (�� ��� � ���������) � 
-- ������� �������� �� ����������� ���������
select *
from BusInformation as b cross apply (select [Date], [DayOfWeek] from Timetable as t
where b.BusID = t.BusID) as BusTable

---------------------------------------------------------------------------------------------------
-- ������� 2
-- union c������� ���������� ���� �������� � ���� �������������� �����
-- union �� ��������� ������� Distinct (����������) ��������
select RouteID
from Stops s inner join RoutesAndStops rs
on s.StopID = rs.StopID
union
select rs.RouteID
from RoutesAndStops rs inner join Routes r
on r.RouteID = rs.RouteID

-- union all ���������� ��� ��������, ������� ���������
-- � ������ � �� ������ ��������
select RouteID
from Stops s inner join RoutesAndStops rs
on s.StopID = rs.StopID
union all
select rs.RouteID
from RoutesAndStops rs inner join Routes r
on r.RouteID = rs.RouteID

-- except ���������� ���������� ������ �� ������ �������� �������, ������� �� ��������� ������
-- ������� ��������
select BusID
from BusInformation
except
select BusID
from Timetable


-- intersect ���������� ���������� ������, ��������� ����� � ������ �������� ���������
select BusID
from BusInformation
intersect
select BusID
from Timetable
---------------------------------------------------------------------------------------------------
-- ������� 3
-- exists ����������� � �������, ����� ���������� ����� ��������, ��������������� ���������
-- �������... ������: ��������� ���������� � ��� ���������, ������� ���������� �� ���� � 
-- ������� Timetable
select *
from BusInformation b
where exists (select * from Timetable t where  b.BusID = t.BusID)

-- ����� ����� ������������ not exists
select *
from BusInformation b
where not exists (select * from TechnicalInspection t where  b.BusID = t.BusID)

-- in ��������� ����������, ��������� �� �������� ������� �� ��������� � ������
-- ������: ����� ������ ��� �����, ������� �������� ���������� � ��������� �
-- �������� ����������
select *
from RoutesAndStops rs
where Identification in ('S', 'E')

-- all ���������� �������, ���� ��� �������� ������������ ������� 
-- ������������� �������. ������: ������� ������� ���������, � ������� ������
-- ������ ������� ��������� ����� "�����"
select *
from BusInformation b
where Mileage < all (select Mileage from BusInformation where Brand = '�����') 

select * from BusInformation
-- any ���������� �������, ���� ����� �� �������� ������������ �������
-- ������������� �������
select *
from BusInformation b
where Mileage < any (select Mileage from BusInformation where Brand = '�����') 

-- between ���������� �������� TRUE, ���� �������� �������� ��������� ������
-- �������� ���������� ��������� ��� ����� ��� � ������ �������� ��������� ��������� ��� ����� ���
select *
from BusInformation
where FuelConsuption between 21 and 28

--like o���������, ��������� �� ��������� ���������� ������ � �������� ��������
select *
from BusInformation
where BusNumber like '�%'
---------------------------------------------------------------------------------------------------
-- ������� 4
-- ������� case ������� ������� � ������ n �����
select * from RoutesAndStops

select StopID, RouteID,
	case Identification
		when 'S' then 'Start stop'
		when 'I' then 'Interval stop'
		when 'E' then 'End stop'
		else null
	end as Description, NumberOfArrivals
from RoutesAndStops

-- ��������� case
select * from Routes
select RouteID, Name, TravelTime, AmountOfBuses, 'Current Price' =
	case
		when MoneyForTravel = 23 then '�� ������'
		when MoneyForTravel > 23 then '���-�����'
		else '��� ������'
	end
from Routes
---------------------------------------------------------------------------------------------------
-- ������� 5
-- cast ����������� ��������� ������ ���� � �������
select cast(StartTimeOfWork as nvarchar) + '-' + cast(EndTimeOfWork as nvarchar) + '; ' + 
cast(Date as nvarchar) as 'Time of work'
from Timetable

-- convert ����������� ��������� ������ ���� � ������� � ������������ ��������������
select convert(nvarchar, StartTimeOfWork, 8) + '-' + convert(nvarchar, EndTimeOfWork, 8) + '; ' + 
	   convert(nvarchar, Date, 106) as 'Time of work'
from Timetable

-- null o���������, ����� �� ��������� ��������� ���� null
select * 
from Engineers
where Salary is null

-- isnull �������� �������� null ��������� ���������� ���������
select 	Brand, BusNumber, ISNULL(FuelConsuption, 32)
from BusInformation
where Brand = 'MAN'

-- nullif ���������� �������� null, ���� ��� ��������� ��������� �����
-- � ������ ������ ����� ������ null, ��� ��� ������������ ���������� �������
select NUllIF(VolumeOfTheTank, VolumeOfTheTank) as Different
from BusInformation
where Brand = 'MAN'

-- coalesce ��������� ��������� �� ������� � ���������� ������� ��������
-- ������� ���������, ���������� �� ������������ ��� null
-- � ������ �������, ���� ������� coalisce ������� ������ �������� ������ null,
-- �� ��� ��������� �� ������� ��������, ������ �������� ������� ���������
select VolumeOfTheTank, Mileage, FuelConsuption, coalesce(VolumeOfTheTank, Mileage)
from BusInformation

-- choose ���������� ������� �� ���������� ������� �� ������ ��������
select Date, choose(Month(Date), '������', '�������','����','�������','���','����'
							   ,'����','������','��������','�������','������','�������')
from Repair

-- iif ���������� ���� �� ���� �������� � ����������� �� ����, ��������� ����������
-- ��������� �������� true ��� false
-- ����� ��������, ��� � ������ ������� ���������� ��������� ������������ ���� �������
select d.Salary, c.Salary, iif(d.Salary > c.Salary, 'True', 'False') as 'Test'
from Drivers d, Conductors c
---------------------------------------------------------------------------------------------------
-- ������� 6
-- replace �������� ��� ��������� ���������� ���������� �������� ������ ��������� ���������
select replace(Name, '��.', '�����')
from Stops

-- substring ���������� ����� �����������, ���������, ���������� ��� ������������ ���������
select SUBSTRING(BusNumber, 2, 3) as '������ ��������� (�����)'
from BusInformation

-- stuff ��������� ���� ������ � ������. ��� ������� ��������� ���������� �������� ������
-- ������ � ��������� ������� � ��������� �� �� ����� ������ ������
-- ����� ��������, ��� ������ ������� ���������� ������������ � ����� �������, ����� ������
-- ����������� ���������, ����� �������� ����, ��� � ���� �������...
select STUFF(Name, 3, 1, '��� ')
from Stops

-- str ���������� ���������� ������, ��������������� �� �������� ������
select STR(Cast(Salary as float), 7, 1)
from Drivers

-- unicode ���������� ������������� ��������, ��������������� ��������� ������, 
-- ��� ������� ������� �������� ���������
select UNICODE(Identification)
from RoutesAndStops

-- lower ���������� ���������� ��������� ����� �������������� �������� �������� ��������
-- � ������� ������� ��������
select LOWER(BusNumber)
from BusInformation

-- upper ���������� ���������� ���������, � ������� ������� ������� ��������
-- ������������� � ������� �������� ��������
select UPPER(Name)
from Stops
---------------------------------------------------------------------------------------------------
-- ������� 7
-- datepart - ������� ���������� ����� �����, �������������� ��������� ����� datepart ���������
-- ���� date. � ������� ��������� ����� ��� ������
select Date, DATEPART(WEEKDAY, Date) '����� ��� ������'
from Timetable

-- dateadd - ������� ��������� ��������� �������� number (����� ����� �� ������) � ���������
-- ��������� datepart �������� �������� date, � ����� ���������� ��� ���������� ��������
select DATEADD(day, 3, Date) '����� ����� ����'
from Repair

-- datediff - ������� ���������� ���������� ������������ ������ (����� ����� �� ������),
-- ��������� � ��������� datepart, �� ������ �������
select DATEDIFF(MONTH, '20210601', '20211001')
from Repair

-- getdate ���������� ������� ��������� ����� ������� ���� ������ � ���� �������� datetime
-- ��� �������� �������� ����� ���� ������
select GETDATE() as '������� �����'

-- sysdetetimeoffset ���������� �������� ���� datetimeoffset(7), ������� �������� ���� �
-- ����� ����������, �� ������� ������� ��������� SQL Server
select SYSDATETIMEOFFSET() as '������� �����'
---------------------------------------------------------------------------------------------------
-- ������� 8
-- group by ������������ ��� ����������� ����� �������� �����, � ������� ����� �����������
-- ���������� ������� (COUNT, MIN, MAX, AVG � SUM)
select rs.RouteID, COUNT(rs.RouteID) as '���������� ���������'
from RoutesAndStops rs
group by rs.RouteID

-- having �������� ���������� �� ��������� ���������� ���������� �������
select Brand, Count(Brand)
from BusInformation
group by Brand
having Brand <> '�����'
---------------------------------------------------------------------------------------------------