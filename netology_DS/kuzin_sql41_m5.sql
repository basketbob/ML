--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим 
--так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.
select
	customer_id,	
	payment_id,
	payment_date,
	row_number() over () num_by_date,
	row_number() over (partition by customer_id order by payment_date) num_by_customer,
	sum(amount) over (partition by customer_id order by payment_date, amount) sum_by_customer,
	rank() over (partition by customer_id order by amount desc) num_by_amount
from 
	payment p
order by 
	customer_id


--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
select
	p.customer_id,
	p.payment_id,
	p.payment_date,
	amount,
	lag(amount, 1, 0.0) over (partition by p.customer_id order by payment_date) last_amount
from
	payment p
order by
	customer_id


--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
select
	p.customer_id,
	p.payment_id,
	p.payment_date,
	amount,
	amount - lead(amount) over (partition by p.customer_id order by payment_date) difference
from
	payment p
order by 
	customer_id


--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
select
	customer_id,
	payment_id,
	payment_date,
	amount
from (	
	select	
		customer_id,
		payment_id,
		payment_date,
		amount,
		last_value(payment_id) over (partition by customer_id order by payment_date
			rows between unbounded preceding and unbounded following)
	from
		payment
	order by 
		customer_id) t
where payment_id = last_value

--2 вариант решения, по рекомендации из доработки
with nums_pay as (
	select	
		customer_id,
		payment_id,
		payment_date,
		amount,
		row_number() over (partition by customer_id order by payment_date desc) num_pay
	from
		payment
	order by 
		customer_id
)
select
	customer_id,
	payment_id,
	payment_date,
	amount
from nums_pay
where num_pay = 1

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.
select 
	staff_id,
	payment_date,
	sum_amount,
	sum(sum_amount) over (partition by staff_id order by payment_date) "sum"
from (
	select
		s.staff_id, 
		p.payment_date::date,
		sum(p.amount) sum_amount
	from
		staff s
	join 
		payment p on p.staff_id = s.staff_id
	where 
		date_trunc('month', p.payment_date) = '2005-08-01 00:00:00.000'
	group by 
		s.staff_id, p.payment_date::date 
	order by 
		s.staff_id, p.payment_date::date) t



--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку
select
	customer_id,
	payment_date,
	payment_number
from (
	select 
		customer_id,
		payment_date,
		row_number() over () payment_number
	from 
		payment
	where
		payment_date::date = '2005-08-20') t
where 
	payment_number % 100 = 0



--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм

