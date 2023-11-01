--Приложение №2

--1. В каких городах больше одного аэропорта?
--В данном запросе, основываясь на требовании задачи мы выбираем название города, группируем по названию 
--и в select добавляем агрегирующую функцию подсчета количества аэропортов. 
--В самом конце, с помощью оператора HAVING убираем города, в которых аэропортов меньше двух.
SELECT 
	city, 
	count(airport_code) port_cnt 
FROM 
	airports
GROUP BY 
	city
HAVING 
	count(airport_code) > 1;


--2. В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета? - Подзапрос
--По условию задачи нам нужно вывести аэропорты, значит в SELECT добавляем название аэропорта и добавляем DISTINCT, чтобы не было повторений.
--Основная выборка из таблицы airports, к ней присоединяем полеты, чтобы выяснить какие самолеты в этих городах летают.
--Далее с помощью подзапроса выясняем какой самолет имеет самый дальний запас хода и по этому самолету фильтруем полеты. 
SELECT 
	DISTINCT ap.airport_name
FROM 
	airports ap
JOIN 
	flights f ON
		f.departure_airport = ap.airport_code OR 
		f.arrival_airport = ap.airport_code
WHERE
	f.aircraft_code = (
		SELECT aircraft_code 
		FROM aircrafts
		ORDER BY "range" DESC
		LIMIT 1
	);


--3. Вывести 10 рейсов с максимальным временем задержки вылета. - Оператор LIMIT
--Первым делом в подзапросе вычисляем время задержки вылетов у всех рейсов,
--затем из получившейся таблицы фильтруем те рейсы у которых задержка не посчиталась (NULL - у них нету актуального вылета)
--сортируем по времени задержки от большего к меньшему
--ограничиваем вывод 10 записями 
SELECT *
FROM (
	SELECT 
		flight_no, 
		(actual_departure - scheduled_departure) delayed
	FROM 
		flights f
) t
WHERE 
	delayed is not NULL 
ORDER BY 
	delayed DESC 
LIMIT 10


--4. Были ли брони, по которым не были получены посадочные талоны? - Верный тип JOIN
--Выбираем все брони.
--Присоединяем к ним таблицу с билетами.
--Затем присоединяем таблицу с посадочными и фильтруем по тем записям, где посадочных не было.
SELECT 
	t.book_ref, 
	t.ticket_no 
FROM
	tickets t
LEFT JOIN
	boarding_passes bp USING (ticket_no)
WHERE
	bp.boarding_no is null


--5. Найдите количество свободных мест для каждого рейса, их % отношение к общему количеству мест в самолете.
--Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. 
--Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более 
--ранних рейсах в течении дня.
---- - Оконная функция
---- - Подзапросы или/и cte
--С помощью CTE выполняем первую часть задания по кол-ву свободных мест.
--Выбираем рейсы, по коду самолета соединяем таблицу с посадочными местами, 
--по номеру рейса соединяем табл. с посадочными талонами, чтоб понять какие места уже распределены между пассажирами.
--далее с помощью агрегирующей функции считаем общее количество мест в конкретном самолете и количество занятых мест пассажирами, 
--с этими результатами производим необходимые математические вычисления.
--Следующим шагом пишем подзапрос, который считает количество пассажиров получивших посадочный талон по конкретному рейсу (по логике это те пассажиры, которые улетят).
--Соединяем CTE и подзапрос с помощью left join, с помощью оконной функции считаем суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день.
with free_seats as (
	select 
		f.flight_id,
		f.flight_no,
		f.aircraft_code,
		f.departure_airport,
		f.actual_departure,
		(count(s.seat_no) - count(bp.seat_no)) "Кол-во свободных мест",
		(count(s.seat_no) - count(bp.seat_no)) * 100 / count(s.seat_no) "% отношение"
	from
		flights f 
	join 
		seats s using (aircraft_code)
	left join 
		boarding_passes bp on bp.flight_id = f.flight_id and bp.seat_no = s.seat_no
	group by
		f.flight_id
)
select 
	frs.*,
	sum(t.cnt_pass) over (partition by t.departure_airport, t.actual_departure::date order by t.actual_departure) "Кол-во вывезенных пассажиров"
from 
	free_seats frs
left join (
	select
		f.flight_id,
		f.departure_airport,
		f.actual_departure,
		count(bp.boarding_no) cnt_pass
	from
		flights f
	left join 
		boarding_passes bp on bp.flight_id = f.flight_id
	where 
		bp.boarding_no is not null
	group by 
		f.flight_id
) t on 
	t.flight_id = frs.flight_id
order by 
	frs.departure_airport, 
	frs.actual_departure


--6. Найдите процентное соотношение перелетов по типам самолетов от общего количества.
-- - Подзапрос или окно
-- - Оператор ROUND
--В подзапросе посчитал общее количество. В основном запросе сгрупировал по типам самолетов и посчитал количество рейсов по ним.
--Затем процентное соотношение.
explain analyze --cost=1695.02    t=22.601
select 
	f.aircraft_code,
	ROUND((count(f.flight_id) * 100 / (select count(*) from flights)::decimal), 2) rnd
from flights f 
group by f.aircraft_code 

explain analyze --cost=2109.04   t=30.78
select 
	f.aircraft_code,
	ROUND((count(f.flight_id) * 100 / f2.cnt::decimal), 2) rnd
from flights f,  (select count(*) cnt from flights) f2
group by f.aircraft_code, f2.cnt


--7. Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?
-- - CTE
--Выбрал отдельно в двух запросах цены по бизнесу и эконому. Затем соединил их по номерам рейсов и сравнил мин. цену бизнеса и макс. цену эконома.
with ticket_economy as (
	select flight_id, max(amount) ecost
	from ticket_flights
	where fare_conditions = 'Economy'
	group by flight_id
)
select tb.flight_id, tb.bcost, te.ecost
from (
	select flight_id, min(amount) bcost
	from ticket_flights
	where fare_conditions = 'Business'
	group by flight_id
) tb
join 
	ticket_economy te on te.flight_id = tb.flight_id 
where
	tb.bcost < te.ecost


--8. Между какими городами нет прямых рейсов?
-- - Декартово произведение в предложении FROM
-- - Самостоятельно созданные представления (если облачное подключение, то без представления)
-- - Оператор EXCEPT
--
--Представление с декартовым произведением.
create view city1_city2 as (
	select a.airport_code acode1, a.city city1, a2.airport_code acode2,  a2.city city2
	from airports a , airports a2
	where a.city > a2.city
);

--основной запрос, практически 2 одинаковых подзапроса, в первом выбираем все сочетания городов,
--во втором только те сочетания, где есть рейсы
--используя except, исключил из первого запроса существующие рейсы.
select distinct cc.city1, cc.city2 
from city1_city2 cc 
left join flights f on f.departure_airport = cc.acode1
except
select distinct cc.city1, cc.city2
from city1_city2 cc 
join flights f on f.departure_airport = cc.acode1 AND f.arrival_airport = cc.acode2

--Проверил несколько сочетаний городов вручную, запрос работает корректно.
select *
from flights f 
where 
	(departure_airport = 'PEZ' and arrival_airport = 'UFA') or
	(departure_airport = 'UFA' and arrival_airport = 'PEZ')


--9. Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов  в самолетах, 
--обслуживающих эти рейсы *
-- - Оператор RADIANS или использование sind/cosd
-- - CASE 
-- В подзапросе вычисляем расстояние по формуле.
-- В основном запросе переводим мили в километры и сравниваем максимальную дальность полета самолета и расстояние между аэропортами.
select 
	t.*,
	a."range",
	t."L" * 1.621371 / 100 km,
	CASE WHEN a."range" > t."L" * 1.621371 / 100 THEN 'OK'
        ELSE 'не хватит долететь'
    end
from (
	select 
		distinct 
		concat(ap.airport_name, ' (', ap.city, ')') airport1, 
		concat(ap2.airport_name, ' (', ap2.city, ')') airport2,
		acosd(sind(ap.latitude) * sind(ap2.latitude) + cosd(ap.latitude) * cosd(ap2.latitude) * cosd(ap.longitude - ap2.longitude)) * 6371 "L",
		f.aircraft_code
	from flights f
	join airports ap on ap.airport_code = f.departure_airport 
	join airports ap2 on ap2.airport_code = f.arrival_airport
) t
join aircrafts a using (aircraft_code)
