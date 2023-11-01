--=============== МОДУЛЬ 2. РАБОТА С БАЗАМИ ДАННЫХ =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия городов из таблицы городов.
SELECT DISTINCT city FROM city;


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
--названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.
SELECT 
	DISTINCT c.city 
FROM 
	city c 
WHERE 
	c.city LIKE 'L%a' AND 
	STRPOS(c.city, ' ') = 0;


--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.
SELECT 
	payment_id,
	payment_date,
	amount
FROM 
	payment
WHERE 
	payment_date::date BETWEEN '2005-06-17' AND '2005-06-19' AND
	amount > 1.00
ORDER BY 
	payment_date ASC 


--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.
SELECT 
	payment_id,
	payment_date,
	amount
FROM 
	payment
ORDER BY 
	payment_date DESC 
LIMIT 10


--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.
SELECT 
	(last_name || ' ' || first_name) AS "Фамилия и имя",
	email AS "Электронная почта",
	character_length(email) AS "Длина Email",
	date(last_update) AS "Дата"
FROM 
	customer


--ЗАДАНИЕ №6
--Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE.
--Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.
SELECT
	lower(last_name) AS last_name,
	lower(first_name) AS first_name,
	active
FROM
	customer
WHERE 
	active = 1 AND 
	(first_name = 'KELLY' OR 
	first_name = 'WILLIE')


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите одним запросом информацию о фильмах, у которых рейтинг "R" 
--и стоимость аренды указана от 0.00 до 3.00 включительно, 
--а также фильмы c рейтингом "PG-13" и стоимостью аренды больше или равной 4.00.
SELECT 
	film_id,
	title,
	description,
	rating,
	rental_rate
FROM film
WHERE
	(rating = 'R' AND 
	rental_rate between 0.00 AND 3.00)
	OR 
	(rating = 'PG-13' AND 
	rental_rate >= 4.00)


--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.
SELECT 
	film_id,
	title,
	description
FROM film
ORDER BY CHARACTER_LENGTH(description) DESC, film_id  --в задании про film_id ничего не сказано, но добавил чтоб результат как на скрине был.
LIMIT 3


--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.
SELECT 
	customer_id,
	email,
	SUBSTRING(email FROM 0 FOR STRPOS(email, '@')) AS "Email before @",
	SUBSTRING(email FROM STRPOS(email, '@')+1) AS "Email after @"
FROM 
	customer


--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква должна быть заглавной, остальные строчными.
SELECT 
	customer_id,
	email,
	UPPER(SUBSTRING(email FROM 1 FOR 1)) || LOWER(SUBSTRING(email FROM 2 FOR STRPOS(email, '@')-2)) AS "Email before @",
	UPPER(SUBSTRING(email FROM STRPOS(email, '@')+1 FOR 1)) || SUBSTRING(email FROM STRPOS(email, '@')+2) AS "Email after @"
FROM customer
