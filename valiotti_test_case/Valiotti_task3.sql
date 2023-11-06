-- Пользователи
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    installed_at DATE NOT NULL
);

-- Примеры юзеров
INSERT INTO users (user_id, installed_at)
VALUES (1, '2022-01-10'),
       (2, '2022-01-15'),
       (3, '2022-02-05'),
       (4, '2022-02-10'),
       (5, '2022-03-01');

-- Сессии
CREATE TABLE client_session (
    user_id INT,
    created_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Примеры сессий
INSERT INTO client_session (user_id, created_at)
VALUES (1, '2022-01-11 12:00:00'),
       (1, '2022-01-14 14:00:00'),
       (2, '2022-01-16 15:00:00'),
       (2, '2022-01-18 16:00:00'),
       (2, '2022-01-22 17:00:00'),
       (3, '2022-02-06 18:00:00'),
       (4, '2022-02-11 19:00:00'),
       (4, '2022-02-14 20:00:00'),
       (5, '2022-03-02 21:00:00');

WITH MonthlyCohorts AS (
    SELECT
        user_id,
        installed_at,
        DATE_TRUNC('month', installed_at) AS cohort_month
    FROM
        "users"
    WHERE
        installed_at >= '2022-01-01'
),

RetentionDays AS (
    SELECT
        m.user_id,
        m.cohort_month,
        cs.created_at,
        (cs.created_at::DATE - m.installed_at) AS days_after_install -- Изменим эту строку
    FROM
        MonthlyCohorts m
    JOIN
        client_session cs ON m.user_id = cs.user_id
    WHERE
        cs.created_at::DATE > m.installed_at
)

SELECT
    r.cohort_month,
    COUNT(DISTINCT r.user_id) AS total_users,
    COUNT(DISTINCT CASE WHEN r.days_after_install = 1 THEN r.user_id END) AS retention_day_1,
    COUNT(DISTINCT CASE WHEN r.days_after_install = 3 THEN r.user_id END) AS retention_day_3,
    COUNT(DISTINCT CASE WHEN r.days_after_install = 7 THEN r.user_id END) AS retention_day_7
FROM
    RetentionDays r
GROUP BY
    r.cohort_month
ORDER BY
    r.cohort_month;
