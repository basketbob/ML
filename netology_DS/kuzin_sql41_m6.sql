--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
select 
	film_id, 
	title, 
	special_features
from 
	film
where
	array_position(special_features, 'Behind the Scenes') is not null 


--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
--Вариант 1:
select 
	film_id, 
	title, 
	special_features
from 
	film
where
	special_features @> ARRAY['Behind the Scenes']

--Вариант 2:
select 
	film_id, 
	title, 
	special_features
from 
	film
where
	special_features && ARRAY['Behind the Scenes']

--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.
with behind_scene as (
	select 
		film_id, 
		title, 
		special_features
	from 
		film
	where
		array_position(special_features, 'Behind the Scenes') is not null
)
select
	r.customer_id,
	count(r.rental_id) film_count
from rental r
join inventory i using (inventory_id)
join behind_scene bs using (film_id)
group by r.customer_id
order by r.customer_id


--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.
select
	r.customer_id,
	count(r.rental_id) film_count
from rental r
join inventory i using (inventory_id)
join (
	select 
		film_id, 
		title, 
		special_features
	from 
		film
	where
		array_position(special_features, 'Behind the Scenes') is not null 
) bs using (film_id)
group by r.customer_id
order by r.customer_id


--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления
create materialized view film_count as (
	select
		r.customer_id,
		count(r.rental_id) film_count
	from rental r
	join inventory i using (inventory_id)
	join (
		select 
			film_id, 
			title, 
			special_features
		from 
			film
		where
			array_position(special_features, 'Behind the Scenes') is not null 
	) bs using (film_id)
	group by r.customer_id
	order by r.customer_id
)

REFRESH MATERIALIZED VIEW film_count;




--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания. 
--   ПОИСК значения в массиве происходит быстрее с помощью оператора @> или &&, функция array_position выполняется дольше.

--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса
-- Вложенный запрос отработал быстрее чем CTE, но значение стоимости очень близко на небольших данных.




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.
SELECT * 
FROM (
	SELECT 
		s.staff_id, 
		f.film_id,
		f.title,
		p.amount,
		p.payment_date,
		c.last_name customer_last_name,
		c.first_name customer_first_name,
		row_number() OVER (PARTITION BY s.staff_id ORDER BY p.payment_date) payment_num
	FROM 
		staff s
	LEFT JOIN 
		rental r USING (staff_id)
	JOIN 
		payment p USING (rental_id)
	JOIN 
		customer c ON c.customer_id = r.customer_id 
	JOIN 
		inventory i USING (inventory_id)
	JOIN 
		film f USING (film_id)) t
WHERE 
	payment_num = 1




--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день




