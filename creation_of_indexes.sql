select top(0) *
into CopyBusInformation
from BusInformation

declare @n int = 0;
declare @a char = '�', @z char = '�', @w int, @l int
SET @w = ascii(@z) - ascii(@a);
SET @l = ascii(@a);
declare @BusNumber nvarchar(6) = 'AAAAA';
declare @Brand nvarchar(20) = '���';
declare @Number int;

while (@n < 100000)
begin
	set @Number = left(floor(rand() * 100000), 3);
	set @Number = cast(@Number as nvarchar);
	if (len(@brand) > 19) set @Brand = '���' else set @Brand = @Brand + char(round(rand() * @w, 0) + @l); 
	set @BusNumber = upper(@BusNumber+char(round(rand() * @w, 0) + @l));
	set @BusNumber = stuff(@BusNumber, 2,3, @Number);
	insert into CopyBusInformation (Brand, BusNumber, PassangerCapacity, Mileage, FuelConsuption, VolumeOfTheTank)
	values (@Brand, @BusNumber, rand() * 100, rand() * 10000, rand() * 100, rand() * 1000)
	set @n = @n + 1
end
---------------------------------------------------------------------------------------------------
SET STATISTICS IO ON
SET STATISTICS TIME ON
--select * from CopyBusInformation

drop index 

select count(b.PassangerCapacity)
from CopyBusInformation b
where b.PassangerCapacity < 40

create clustered index CL_IndexPasCap
on CopyBusInformation(PassangerCapacity)

drop index CL_IndexPasCap on CopyBusInformation
---------------------------------------------------------------------------------------------------
--��������� ������
select PassangerCapacity, VolumeOfTheTank
from CopyBusInformation
where PassangerCapacity = 30 and VolumeOfTheTank = 200

create index NonCL_IndexPasAndVol
on CopyBusInformation(PassangerCapacity, VolumeOfTheTank)

drop index NonCL_IndexPasAndVol on CopyBusInformation

---------------------------------------------------------------------------------------------------
--����������� ������
select *
from CopyBusInformation
where PassangerCapacity > 30 
	  and BusNumber like '_1%'
	  and Brand like '����'
	  and VolumeOfTheTank < 300
	  and Mileage > 5000
	  and FuelConsuption > 10

create index NonCL_Index_AllColumns
on CopyBusInformation(PassangerCapacity)
include (BusID, Brand, BusNumber, Mileage, FuelConsuption, VolumeOfTheTank)

drop index NonCL_Index_AllColumns on CopyBusInformation
---------------------------------------------------------------------------------------------------
--���������� ������
select BusID
from CopyBusInformation
where BusID % 5 = 0

create unique index Unique_Index_BusId
on CopyBusInformation (BusID)

drop index Unique_Index_BusId on CopyBusInformation
---------------------------------------------------------------------------------------------------
--������ � ����������� ���������
select Brand, BusNumber, PassangerCapacity, VolumeOfTheTank
from CopyBusInformation
where PassangerCapacity > 30 
	  and BusNumber like '%��'
	  and Brand like '����'
	  and VolumeOfTheTank < 300

create index NonCL_IndexPas_BusNum_Brand_Vol
on CopyBusInformation(PassangerCapacity)
include (BusNumber, Brand, VolumeOfTheTank)

drop index NonCL_IndexPas_BusNum_Brand_Vol on CopyBusInformation
---------------------------------------------------------------------------------------------------
--��������������� ������
select count(PassangerCapacity)
from CopyBusInformation
where PassangerCapacity > 20
	  and PassangerCapacity < 50

create index NonCL_Index_PasCap
on CopyBusInformation (PassangerCapacity)
where PassangerCapacity = 24

create index NonCL_Index_PasCap
on CopyBusInformation (PassangerCapacity)
where PassangerCapacity > 20
	  and PassangerCapacity < 50

drop index NonCL_Index_PasCap on CopyBusInformation
---------------------------------------------------------------------------------------------------


--delete from CopyBusInformation
