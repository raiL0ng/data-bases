create view dbo.Repair_list
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
('��������� ���������� ��������', 'Daewoo', '�491��', '��������� ��������������� � ��������')

delete from Repair
where RepairOfBusID > 2
delete from TechnicalInspection
where TechInspectionID > 2
delete from Engineers
where EngineerID > 4

create view Test_repair
as select *
from Repair_list




create view Bus_with_repair
as select Brand '����� ��������',
		  BusNumber '����� ��������',
		  iif(ti.TechInspectionID != 0, '��������� �� ���������', '� �������') '��������'
from BusInformation b
left join TechnicalInspection ti
on b.BusID = ti.BusID

select * from Bus_with_repair

drop view Bus_with_repair

create trigger update_state_bus
on Bus_with_repair instead of update
as
begin
	if exists (select * from inserted where inserted.[��������] = '��������� �� ���������')
		begin
		insert into TechnicalInspection(BusID, EngineerID, DateOfInspection)
			select (select BusID from BusInformation b join inserted i on b.BusNumber = i.[����� ��������]),
				   (select top (1) e.EngineerID
				    from Engineers e join TechnicalInspection ti on e.EngineerID != ti.EngineerID),
				   convert(date, getdate(), 112)
		end
end

select * from Bus_with_repair
select * from TechnicalInspection

update Bus_with_repair
set [��������] = '��������� �� ���������'
where [����� ��������] = '�154��'


create view Conductor_timetable
as select c.Name '���������',
	      BusNumber '����� ��������',
		  rt.Name '����� ��������',
		  StartTimeOfWork '������ �������� ���',
		  EndTimeOfWork '����� �������� ���',
		  [DayOfWeek] '���� ������'
from Timetable as tbl 
inner join Conductors c
on c.ConductorID = tbl.ConductorID
inner join BusInformation as bus
on bus.BusID = tbl.BusID
inner join Routes as rt
on rt.RouteID = tbl.RouteID

select * from Driver_timetable where [��������] Like '%��������%'

execute show_stop '13�', '��. ��������', '';
