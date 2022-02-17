-- Процедура, предназначенная для поиска водителя, (не)работающего в текущий день недели 
create procedure show_driver @x int = null
as
begin
	if not exists (select DriverID from Timetable where @x = DriverID)
		begin
			raiserror('This driver did not assign',16, 1)
			return
		end
	if @x is null or not exists (select * from Drivers where @x = DriverID)
		begin
			raiserror('Incorrect input of driver id',16, 1)
			return
		end
	else 
		begin
			select d.Name 'Водитель',
				   BusNumber 'Номер автобуса',
				   rt.Name 'Номер маршрута',
				   StartTimeOfWork 'Начало рабочего дня',
				   EndTimeOfWork 'Конец рабочего дня'
			from Timetable as tbl 
			inner join Drivers as d
			on d.DriverID = tbl.DriverID and d.DriverID = @x
			inner join BusInformation as bus
			on bus.BusID = tbl.BusID
			inner join Routes as rt
			on rt.RouteID = tbl.RouteID
		end
end

--Выполнение процедуры:
exec show_driver @x = 2

exec show_driver @x = 5

-- Удаление процедуры:
drop procedure show_driver

-- Процедура предназначенная для подсчета количества остановок в маршруте
create procedure amount_of_stops @name nvarchar(45)
as
begin
	declare @id int
	set @id = (select RouteID from Routes where @name = Name)
	if @id is null
		begin
			raiserror('Incorrect name of route',16, 1)
			return
		end
	else
		begin
			select count(RouteID)
			from RoutesAndStops where @id = RouteID
		end

end

-- Выполнение процедуры:
exec amount_of_stops '13А'

exec amount_of_stops @name = '13Г'

-- Удаление процедуры:
drop procedure amount_of_stops

-- Процедура в которой идет поиск автобусов с наименьшим пробегом
create procedure check_young_buses
as
begin
	declare @mileage int, @min int
	declare @cursor cursor
	set @min = 100000000
	set @cursor = cursor
	forward_only static for
		select Mileage from BusInformation
	open @cursor
	fetch next from @cursor into @mileage
	
	while @@FETCH_STATUS = 0
		begin
			if @mileage < @min
				begin
					set @min = @mileage
				end
			fetch next from @cursor into @mileage
		end
	close @cursor
	deallocate @cursor
	
	select * from BusInformation where @min = Mileage
end

-- Выполнение процедуры:
exec check_young_buses

-- Удаление процедуры:
drop procedure check_young_buses

-- Процедура, предназначенная для просмотра информации об остановке на каком-либо маршруте
create procedure show_stop @name_route nvarchar(45), @name_stop nvarchar(45), @message nvarchar(45) output
as
begin 
	declare @Rid int, @Sid int
	set @Rid = (select RouteID from Routes where @name_route = Name)
	set @Sid = (select StopID from Stops where @name_stop = Name)
	if (@Rid is null or @Sid is null
					 or not exists (select * from RoutesAndStops where StopID = @Sid and RouteID = @Rid))
		begin
			raiserror('Incorrect name of route or stop',16, 1)
			return
		end
	else
		begin
			set @message = (select case Identification
									  when 'S' then 'Начальная остановка'
									  when 'I' then 'Промежуточная остановка'
									  when 'E' then 'Конечная остановка'
								   end
							from RoutesAndStops where @Sid = StopID and @Rid = RouteID)
			select @message
		end
end

-- Выполнение процедуры:
exec show_stop @name_route = '13А', @name_stop = 'ул. Крупская', @message = ''

exec show_stop @name_route = '13А', @name_stop = 'ул. Крупная', @message = ''

exec show_stop @name_route = '13Г', @name_stop = 'ул. Крупская', @message = ''

exec show_stop @name_route = '210Б', @name_stop = 'ул. Крупская', @message = ''

--Удаление процедуры:
drop procedure show_stop


create procedure check_amount_of_buses @name_route nvarchar(45)
as
begin
	declare @Rid int
	set @Rid = (select RouteID from Routes where @name_route = Name)
	if @Rid is null
		begin
			raiserror('Incorrect name of route',16, 1)
			return
		end
	else
		begin
			declare @tmpid int, @ans int, @last int
			declare @cursor cursor
			set @cursor = cursor
			forward_only static for
			select BusID from Timetable where @Rid = RouteID order by BusID asc
			open @cursor
			fetch next from @cursor into @tmpid
			set @last = @tmpid
			fetch next from @cursor into @tmpid
			set @ans = 1
			while @@FETCH_STATUS = 0
				begin
					if @last != @tmpid
						begin
							set @ans = @ans + 1
							set @last = @tmpid
						end
					fetch next from @cursor into @tmpid
				end
			close @cursor
			deallocate @cursor
			select @ans
			return @ans
			-- Можно добавить сообщение на проверку данных таблиц Routes и Timetable
			--if (@ans = (select AmountOfBuses from Routes where @Rid = RouteID))
			--	begin
			--		raiserror('Всё корректно',16, 1)
			--		return		
			--	end
			--else 
			--	begin
			--		raiserror('Данные не сходятся!',16, 1)
			--		return		
			--	end
		end
end


-- Выполнение процедуры:
exec check_amount_of_buses @name_route = '13А'

exec check_amount_of_buses @name_route = '210Б'

-- Удаление процедуры:
drop procedure check_amount_of_buses
