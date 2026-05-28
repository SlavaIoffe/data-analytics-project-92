--запрос считает общее количество покупателей из таблицы customers. И выводит данные в колонку customers_count.
--customers_count.csv

    SELECT
      Count(customers.customer_id) AS customers_count
FROM
    customers
