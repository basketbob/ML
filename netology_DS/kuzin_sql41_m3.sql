--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
select
    c.last_name || ' ' || c.first_name "Customer name", 
    a.address, 
    ct.city, 
    cntr.country
from
    customer c 
join 
    address a on a.address_id = c.address_id 
join 
    city ct on ct.city_id = a.city_id
join 
    country cntr on cntr.country_id = ct.country_id


--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select 
    s.store_id "ID магазина", 
    count(c.customer_id) "Количество покупателей"
from
    store s 
left join
    customer c on c.store_id = s.store_id 
group by 
    s.store_id 


--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select 
    s.store_id "ID магазина",
    count(c.customer_id) "Количество покупателей"
from
    store s 
left join
    customer c on c.store_id = s.store_id 
group by 
    s.store_id 
having 
    count(c.customer_id) > 300


-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
select 
    s.store_id "ID магазина",
    count(c.customer_id) "Количество покупателей",
    ct.city "Город",
    concat(stf.last_name, ' ', stf.first_name) "Имя сотрудника"
from
    store s
join
    address a on a.address_id = s.address_id
join
    staff stf on stf.store_id = s.store_id
join 
    city ct on ct.city_id = a.city_id 
left join
    customer c on c.store_id = s.store_id
group by 
    1, 3, 4
having
    count(c.customer_id) > 300


--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select 
    concat(c.last_name, ' ', c.first_name) "Фамилия и имя покупателя",
    count(r.rental_id) "Количество фильмов"
from 
    customer c 
join 
    rental r on r.customer_id = c.customer_id 
group by 
    c.customer_id
order by 
    "Количество фильмов" desc
limit 5


--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
select 
    concat(c.last_name, ' ', c.first_name) "Фамилия и имя покупателя",
    count(r.rental_id) "Количество фильмов",
    round(sum(p.amount)) "Общая стоимость платежей",
    min(p.amount) "Минимальная стоимость платежа",
    max(p.amount) "Максимальная стоимость платежа"
from 
    customer c
join 
    rental r on r.customer_id = c.customer_id
join 
    payment p 
    on 
        p.rental_id = r.rental_id and 
        p.customer_id = c.customer_id
group by 
    c.customer_id


--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
select 
    c.city "Город 1", 
    c2.city "Город 2"
from 
    city c 
cross join 
    city c2
where 
    c.city != c2.city


--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
select 
    customer_id "ID покупателя",
    round(avg(return_date::date - rental_date::date), 2) "Среднее количество дней на возврат"
from
    rental
group by 
    customer_id
order by 
    customer_id


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
select 
    f.title "Название фильма",
    f.rating "Рейтинг",
    c."name" "Жанр",
    f.release_year "Год выпуска",
    l."name" "Язык",
    count(r.rental_id) "Количество аренд",
    sum(p.amount) "Общая стоимость аренды"
from
    film f
join 
    film_category fc on fc.film_id = f.film_id 
join 
    category c on c.category_id = fc.category_id
join 
    "language" l on l.language_id = f.language_id
left join 
    inventory i on i.film_id = f.film_id 
left join 
    rental r on r.inventory_id = i.inventory_id
left join
    payment p on p.rental_id = r.rental_id 
group by 
    f.film_id, c."name", l."name"


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.
select 
    f.title "Название фильма",
    f.rating "Рейтинг",
    c."name" "Жанр",
    f.release_year "Год выпуска",
    l."name" "Язык",
    count(r.rental_id) "Количество аренд",
    sum(p.amount) "Общая стоимость аренды"
from
    film f
join 
    film_category fc on fc.film_id = f.film_id 
join 
    category c on c.category_id = fc.category_id
join 
    "language" l on l.language_id = f.language_id
left join 
    inventory i on i.film_id = f.film_id 
left join 
    rental r on r.inventory_id = i.inventory_id
left join
    payment p on p.rental_id = r.rental_id 
group by 
    f.film_id, c."name", l."name"
having 
    count(r.rental_id) = 0


--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
select 
    s.staff_id, 
    count(p.payment_id) "Количество продаж",
    (case when count(p.payment_id) > 7300 then 'Да' else 'Нет' end) "Премия"
from 
    staff s 
join 
    payment p on p.staff_id = s.staff_id 
group by 
    s.staff_id 
