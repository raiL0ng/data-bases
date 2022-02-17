 -- 1. ������ � �������������� ���������� �����������
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
 -- 2. �������� ������� � �������������� ��������������� ����������� � ����������� SELECT � WHERE

select rs.RouteID, (select name from Routes where rs.RouteID = Routes.RouteID),
	   rs.StopID, (select name from Stops where rs.StopID = Stops.StopID)
from RoutesAndStops as rs, Routes r

select BusNumber
from BusInformation b
where b.BusID = (select top(1) BusID from TechnicalInspection t where b.BusID = t.BusID)
---------------------------------------------------------------------------------------------------
-- 3. ������ � �������������� ��������� ������

select StopID, RouteID, Identification
into #newRoutesAndStops
from RoutesAndStops

select * from #newRoutesAndStops


---------------------------------------------------------------------------------------------------
-- 4. ������ � �������������� ���������� ��������� ��������� (CTE)

create view Bus_with_repair
as select Brand '����� ��������',
		  BusNumber '����� ��������',
		  iif(ti.TechInspectionID != 0 and ti.DateOfInspection = convert(date, getdate()), 
		      '��������� �� ���������', '� �������') '��������'
from BusInformation b
left join TechnicalInspection ti
on b.BusID = ti.BusID

select * from Bus_with_repair

with cte_free_bus_list (BusID, Brand, BusNumber, Date)
as
(
select BusID, Brand, BusNumber, convert(date, getdate()) from BusInformation
where BusNumber not in (select [����� ��������] from Bus_with_repair
						where [��������] = '��������� �� ���������')
)
select * from cte_free_bus_list
---------------------------------------------------------------------------------------------------
-- 5. ������� ������ (INSERT, UPDATE) c ������� ���������� MERGE.
create table new_engineers
(
EmplID int not null identity(1,1) primary key,
[Name] nvarchar(45) not null,
[Salary] int null,
);

insert into new_engineers (Name, Salary) values
(N'������� ������������� ����', 20000)
, (N'������� ���������� ��������', 20000)
, (N'���� ����������� �������', 20512)

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
where Name like '%����'

update Engineers
set Salary = 20000
where Salary > 20000
---------------------------------------------------------------------------------------------------
-- 6. ������ � �������������� ��������� PIVOT

select DateOfInspection, count(BusID)
from TechnicalInspection
group by DateOfInspection

select '���������� ���������' as '����', [2021-08-29], [2021-08-30], [2021-09-01], [2021-09-02]
from (select cast(DateOfInspection as nvarchar(12)) as [Date], BusID 
	  from TechnicalInspection
	 ) as src_tbl
pivot (count(BusID) for [Date] in ([2021-08-29], [2021-08-30], [2021-09-01], [2021-09-02])
	  ) as pvt_tbl

select Brand as '����� ���������', Count(Brand) as '���������� ���������'
from BusInformation
group by Brand

select '���������� ���������' as '����� ���������', [Daewoo], [MAN], [������ ���], [�����]
from
(
select Brand from BusInformation
) as source_table
pivot
(
count(Brand)
for Brand in ([Daewoo], [MAN], [������ ���], [�����])
) as pivot_table
-- ?

---------------------------------------------------------------------------------------------------
-- 7. ������ � �������������� ��������� UNPIVOT
-- ������������ �������������

-- Noted: ���������� �� ����������� � �����-���� ������������ ����� (��� ��������
-- ������ ���� ������ ����)
select [��������], [��������], [����������]  from 
(
select [��������], cast([����� ��������] as nvarchar(25)) as [����� ��������],
	   cast([����� ��������] as nvarchar(25)) as [����� ��������],
	   convert(nvarchar(25), [������ �������� ���], 108) as [�����������], 
	   convert(nvarchar(25), [����� �������� ���], 108) as [��������],
	   cast([���� ������] as nvarchar(25))[���� ������] from Driver_timetable
where [��������] = '������� ���������� ��������' and [���� ������] = '�����������'
) as source_
unpivot 
(
[����������] for [��������] in ([����� ��������], [����� ��������], [�����������]
				 , [��������], [���� ������])
) as unpivot_table
---------------------------------------------------------------------------------------------------
-- 8. ������ � �������������� GROUP BY � ����������� ROLLUP, CUBE � GROUPING SETS
  
-- Rollup - ��������, ������� ��������� ������������� ����� ��� ������� ����������
-- �������� � ����� ����

create table Report (
ReportID int not null identity(1,1) primary key,
[BusNumber] nvarchar(6) not null,
[WorkDay] date not null,
[MileagePerDay] int not null,
[PassangerPerDay] int not null
);

insert into Report (BusNumber, WorkDay, MileagePerDay, PassangerPerDay)
values (N'�207��', '20210901', 15, 170),
	   (N'�532��', '20210901', 23, 256),
	   (N'�207��', '20210902', 20, 234),
	   (N'�532��', '20210902', 27, 277),
	   (N'�207��', '20210903', 21, 242),
	   (N'�532��', '20210903', 26, 266),
	   (N'�207��', '20210904', 21, 212)

select BusNumber, WorkDay, Sum(MileagePerDay)
from Report
group by BusNumber, WorkDay, MileagePerDay

select BusNumber, WorkDay, Sum(MileagePerDay)
from Report
group by rollup (BusNumber, WorkDay, MileagePerDay)

-- Cube - ��������, ������� ��������� ���������� ��� ���� ��������� ������������ ����������
	
select BusNumber, WorkDay, Sum(MileagePerDay)
from Report
group by cube (BusNumber, WorkDay, MileagePerDay)


-- GROUPING SETS � ��������, ������� ��������� ���������� ���������� ����������� � ���� ����� 
-- ������, ������� �������, �� ������������ ����������� UNION ALL � ��������� ������� (�����
-- ������ ����������� � ��������� � �� ����� �������������)

select BusNumber, WorkDay, Sum(MileagePerDay)
from Report
group by grouping sets ((BusNumber, WorkDay, MileagePerDay), ())

---------------------------------------------------------------------------------------------------
-- 9. ��������������� � �������������� OFFSET FETCH.

select * from RoutesAndStopsTimetable
order by TripTimetableID
offset 9 rows fetch next 9 rows only
---------------------------------------------------------------------------------------------------
-- 10. ������� � �������������� ����������� ������� �������. ROW_NUMBER() ��������� �����. 
-- ������������ ��� ��������� ������ �����. RANK(), DENSE_RANK(), NTILE().

-- ROW_NUMBER() �������� �������� ������ ��������������� ������.
select row_number() over (order by TripTimetableID desc) as [�], *
from RoutesAndStopsTimetable

-- RANK() ���������� ���� ������ ������ � ������ ��������������� ������.
select
BusNumber,
rank() over (order by MileagePerDay desc) as [Rank],
MileagePerDay
from Report

-- DENSE_RANK() - ������� ���������� ���� ������ ������ �
-- ������ ��������������� ������ ��� ����������� � ��������� ������������.
select 
BusNumber,
dense_rank() over (partition by BusNumber order by PassangerPerDay desc) as [Dense_Rank],
PassangerPerDay
from Report

-- NTILE() ������������ ������ ������������� ������ � �������� ���������� �����
select
NTile(4) over (order by MileagePerDay desc) as [NTile],
MileagePerDay
from Report

select
NTile(4) over (order by WorkDay desc) as [NTile],
WorkDay
from Report
---------------------------------------------------------------------------------------------------
-- 11. ��������������� ������ � TRY/CATCH

begin try
	insert into TechnicalInspection (BusID, EngineerID, DateOfInspection)
	values ('afsd', 10, '20200901')
	print '������ �������� �������'
end try
begin catch
	print 'Error ' + convert(varchar, error_number()) + ':' + error_message()
end catch


begin try
	insert into TechnicalInspection (BusID, EngineerID, DateOfInspection)
	values (1, 10, '20200901')
	print '������ �������� �������'
end try
begin catch
	print 'Error ' + convert(varchar, error_number()) + ':' + error_message()
end catch

begin try
	insert into TechnicalInspection (BusID, EngineerID, DateOfInspection)
	values (1, 10, '20201301')
	print '������ �������� �������'
end try
begin catch
	print 'Error ' + convert(varchar, error_number()) + ':' + error_message()
end catch

---------------------------------------------------------------------------------------------------
-- 12. �������� ��������� ��������� ������ � ����� CATCH � �������������� ������� ERROR

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
-- 13. ������������� THROW, ����� �������� ��������� �� ������ �������

-- THROW - ��������, ������� �������� ���������� � ��������� ����� cathc ���������� try..catch
begin try
	insert into TechnicalInspection (TechInspectionID, BusID, EngineerID, DateOfInspection)
	values (4, 1, 10, '20201101')
	print '������ �������� �������'
end try
begin catch
	print '������ � ����� TRY';
	throw;
end catch

begin try
	insert into TechnicalInspection (TechInspectionID, BusID, EngineerID, DateOfInspection)
	values (4, 1, 10, '20201101')
	print '������ �������� �������'
end try
begin catch
	throw 50001, '������ � ����� TRY', 1;
end catch
---------------------------------------------------------------------------------------------------
-- 14. �������� ���������� � BEGIN � COMMIT

-- �������� �������� ���������� ����� ��� ������� ����������. ���� �������� @@TRANCOUNT ����� 1,
-- �� ���������� COMMIT TRANSACTION ������ ��� ���������, ������������� � ������ ����������,
-- ���������� ������ ���� ������, ����������� ������� ���������� � ��������� �������� ���������
-- @@TRANCOUNT �� 0. ���� �������� @@TRANCOUNT ������ 1, ���������� COMMIT TRANSACTION ���������
-- �������� @@TRANCOUNT ������ �� 1 � ��������� ���������� ��������.

begin transaction
select * from BusInformation

select @@TRANCOUNT as [Trancount_after_begin]

commit transaction

select @@TRANCOUNT as [Trancount_after_commit]
---------------------------------------------------------------------------------------------------
-- 15. ������������� XACT_ABORT

-- XACT_ABORT � ��� ��������, ������� ��������� Microsoft SQL Server, ��������� �� ����� ����
-- ���������� � ��������� �� ����� ������ � ������ ������������� ������ � ����������� ����
-- ����������.

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


-- ���� ��������� ���������� SET XACT_ABORT ON � ���������� ����� Transact-SQL �������� ������,
-- ��� ���������� ����������� � ����������� �� �����.
-- ���� ��������� ���������� SET XACT_ABORT OFF, � ��������� ������� ����������� ����� ������
-- ��������� ������ ���������� ����� Transact-SQL, � ��������� ���������� ������������.
-- � ����������� �� ����������� ������ �������� ����� ���� ���������� ��� �����������
-- ���������� SET XACT_ABORT OFF.
-- �� ��������� XACT_ABORT ���������� � OFF(� � ��������� �� ��������� ON)

---------------------------------------------------------------------------------------------------
-- 16. ���������� ������ ��������� ���������� � ����� CATCH
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
