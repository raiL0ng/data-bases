-- ������� 1 �������� �������������
-- ����� �������, �� ������� �����, ����� �������� � ����� ������� �������� �� ������ �������,
-- ����� ��������� ����� ������ � ���� ������, ����� ������� �������� ��������.
create view Driver_timetable
as select d.Name '��������',
	      BusNumber '����� ��������',
		  rt.Name '����� ��������',
		  StartTimeOfWork '������ �������� ���',
		  EndTimeOfWork '����� �������� ���',
		  [DayOfWeek] '���� ������'
from Timetable as tbl 
inner join Drivers as d
on d.DriverID = tbl.DriverID
inner join BusInformation as bus
on bus.BusID = tbl.BusID
inner join Routes as rt
on rt.RouteID = tbl.RouteID

drop view Driver_timetable

-- ����� �������, � ������� ��������� ��� ������� �������� �� ������ ������
-- � ���������� ��������� � �������� ���������.
create view Routes_list
as select rt.Name '�������� ��������',
		  s.Name '�������� ���������',
		  case Identification
			   when 'S' then '������ ��������'
			   when 'E' then '����� ��������'
			   else null
	      end as '��������'
from Routes rt
inner join RoutesAndStops rts
on rt.RouteID = rts.RouteID
inner join Stops s
on s.StopID = rts.StopID and Identification in ('S', 'E')

drop view Routes_list
-- ����� �������, � ������� ��������� ���������� �� ��������� ������������ � ������,
-- �������, ����������� �� ��������� ��������� � ������������ ������� �������.
create view Repair_list
as select e.Name '��� ����������',
   	      bus.Brand '����� ��������',
		  bus.BusNumber '����� ��������', 
		  tchar.ProblemName '������� �������'
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
-- ����� �������, ��� ������������ ��� ��������, ������� ������ � ������������ � �������
-- ��������� � ������ ������ �� ����������
create view Bus_with_repair
as select Brand '����� ��������',
		  BusNumber '����� ��������',
		  iif(ti.TechInspectionID != 0, '��������� �� ���������', '� �������') '��������'
from BusInformation b
left join TechnicalInspection ti
on b.BusID = ti.BusID

drop view Bus_with_repair
---------------------------------------------------------------------------------------------------
-- ������� 2 �������� ������������ �������������
-- ����������: ������ ������� ��� �������� ������, ���� ������������� ��������� �� ���������
-- ������� ������. ����� ��������� ������ �� �������, ������� ����������� � ����� ������� �������.

-- ������� �������� ������������� � ������� ������������ ������ � ����� ��������, ��� ���������
-- ���������� � ��� ���������, ������� �� ���������� �� ����, �������������� � ������� Timetable
create view Bus_list
as select *
from BusInformation b
where exists (select * from Timetable t where  b.BusID = t.BusID) 
WITH CHECK OPTION;

select * from Bus_list
-- ������ ������� �� ����� ���������, ��� ��� � ������������� ����� WITH CHECK OPTION. ������ ��
-- ����� ��������� ������ ��� � ������ ������������� ��� ����� ������ (�.�. ��� �� ���������).
-- ���� �������� ����� ������, ������� �� ����� �������������� ������������ � ������� �������������,
-- �� ��� �� ���������� ����� � � ������� ������� (� ���� ������ BusInformation)
insert into Bus_list ( Brand, BusNumber, PassangerCapacity,
							 Mileage, FuelConsuption, VolumeOfTheTank)
values ('Daewoo', N'�821��', 104, 2244, 28, 200);

--drop view Bus_list

select * from BusInformation

delete from BusInformation
where BusNumber = '�821��'

delete from Bus_list
where BusNumber = '�821��'
---------------------------------------------------------------------------------------------------
-- ������� 3 �������� ���������������� �������������

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