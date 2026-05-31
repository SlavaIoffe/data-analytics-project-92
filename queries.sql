--запрос считает общее количество покупателей из таблицы customers. И выводит данные в колонку customers_count.
--customers_count.csv

    SELECT
      Count(customers.customer_id) AS customers_count
FROM
    customers
    
    ------------------------------
    
    /*
Проект: Продажи
Анализ отдела продаж
Отчет 1: top_10_total_income.csv
О десятке лучших продавцов. 
Таблица состоит из трех колонок - данных о продавце, 
суммарной выручке с проданных товаров и количестве проведенных сделок, 
и отсортирована по убыванию выручки:

seller — имя и фамилия продавца
operations - количество проведенных сделок
income — суммарная выручка продавца за все время
*/


SELECT
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY seller
ORDER BY income DESC
LIMIT 10;

-------------------------------

/*
Проект: Продажи
Анализ отдела продаж
Отчет 2: lowest_average_income.csv
Второй отчет содержит информацию о продавцах, 
чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. 
Таблица отсортирована по выручке по возрастанию.

seller — имя и фамилия продавца
average_income — средняя выручка продавца за сделку с округлением до целого
*/

WITH avg_sales AS (
    SELECT
        s.sales_person_id,
        FLOOR(AVG(s.quantity * p.price)) AS avg_sal
    FROM sales s
    JOIN employees e ON s.sales_person_id = e.employee_id
    JOIN products p ON s.product_id = p.product_id
    GROUP BY s.sales_person_id
)
SELECT
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
    avs.avg_sal AS average_income
FROM avg_sales avs
JOIN employees e ON e.employee_id = avs.sales_person_id
WHERE avs.avg_sal < (SELECT AVG(avg_sal) AS avg
    FROM avg_sales)
ORDER BY avs.avg_sal;

----------------------------------------------------

/*
Проект: Продажи
Анализ отдела продаж
Отчет 3: day_of_the_week_income.csv
Третий отчет содержит информацию о выручке по дням недели. 
Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку. 
Отсортируйте данные по порядковому номеру дня недели и seller

seller — имя и фамилия продавца
day_of_week — название дня недели на английском языке
income — суммарная выручка продавца в определенный день недели, округленная до целого числа
*/


SELECT
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
    TO_CHAR(s.sale_date, 'FMDay') AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY seller, day_of_week, EXTRACT(DOW FROM s.sale_date)
ORDER BY EXTRACT(DOW FROM s.sale_date), seller;

--------------------------------------------------------------------

/*
Анализ покупателей
Отчет 1: age_groups.csv 
Первый отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+. 
Итоговая таблица должна быть отсортирована по возрастным группам и содержать следующие поля:

age_category - возрастная группа
age_count - количество человек в группе
*/

SELECT
    CASE
        WHEN customers.age BETWEEN 16 AND 25 THEN '16-25'
        WHEN customers.age BETWEEN 26 AND 40 THEN '26-40'
        WHEN customers.age > 40 THEN '40+'
        ELSE 'unknown'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY
    CASE
        WHEN customers.age BETWEEN 16 AND 25 THEN '16-25'
        WHEN customers.age BETWEEN 26 AND 40 THEN '26-40'
        WHEN customers.age > 40 THEN '40+'
        ELSE 'unknown'
    END
ORDER BY age_category;

-----------------------------------------

/*
Анализ покупателей
Отчет 2: customers_by_month.csv 
Во втором отчете предоставьте данные по количеству уникальных покупателей и выручке, которую они принесли. 
Сгруппируйте данные по дате, которая представлена в числовом виде ГОД-МЕСЯЦ. 
Итоговая таблица должна быть отсортирована по дате по возрастанию и содержать следующие поля:

selling_month - дата в указанном формате
total_customers - количество покупателей
income - принесенная выручка
*/

SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN products p ON p.product_id = s.product_id
GROUP BY selling_month
ORDER BY selling_month ASC;

--------------------------------------------

/*
Анализ покупателей
Отчет 3: special_offer.csv
Третий отчет следует составить о покупателях, первая покупка которых была в ходе проведения акций 
(акционные товары отпускали со стоимостью равной 0). 
Итоговая таблица должна быть отсортирована по id покупателя. 
Таблица состоит из следующих полей:

customer - имя и фамилия покупателя
sale_date - дата покупки
seller - имя и фамилия продавца
*/

WITH
    first_sales AS (
                    SELECT
                          s.customer_id,
                          Min(s.sale_date) AS first_sale_date
                    FROM
                        sales s
                        INNER JOIN products p ON p.product_id = s.product_id
                    WHERE
                         p.price = 0
                    GROUP BY
                            s.customer_id
                   )
SELECT
      Trim(c.first_name) || ' ' || Trim(c.last_name) AS customer,
      fs.first_sale_date AS sale_date,
      Trim(e.first_name) || ' ' || Trim(e.last_name) AS seller
FROM
    first_sales fs
    INNER JOIN sales s ON s.customer_id = fs.customer_id
                          AND s.sale_date = fs.first_sale_date
    INNER JOIN customers c ON c.customer_id = fs.customer_id
    INNER JOIN employees e ON e.employee_id = s.sales_person_id
GROUP BY
        Trim(c.first_name) || ' ' || Trim(c.last_name),
        fs.first_sale_date,
        Trim(e.first_name) || ' ' || Trim(e.last_name),
        c.customer_id
ORDER BY
        c.customer_id;

------------------------------------------------