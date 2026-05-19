
--запрос считает общее количество покупателей из таблицы customers. И выводит данные в колонку customers_count.
Select
    Count(customers.customer_id) As customers_count
From
    customers;
