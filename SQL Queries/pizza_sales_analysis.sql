create Database pizzahut;

CREATE TABLE Orders (
    order_id INT NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE Order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

-- Retrieve the total number of orders placed?
SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales?
SELECT 
    ROUND(SUM(pizza.price * order_detail.quantity),2) AS total_revenue
FROM
    pizzas AS pizza
        JOIN
    order_details AS order_detail ON pizza.pizza_id = order_detail.pizza_id;
    
-- Identify the highest-priced pizza?
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types AS pizza_types
        JOIN
    pizzas AS pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered?
SELECT 
    pizzas.size, COUNT(order_details.quantity) AS Total_orders
FROM
    pizzas AS pizzas
        JOIN
    order_details AS order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY Total_orders DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities?
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS Total_quantity
FROM
    pizzas AS pizzas
        JOIN
    pizza_types AS pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details AS order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered?
SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY total_quantity ASC;

-- Determine the distribution of orders by hour of the day?
SELECT 
    HOUR(time) AS hour, COUNT(order_id) AS Order_count
FROM
    orders
GROUP BY hour;

-- Join relevant tables to find the category-wise distribution of pizzas?
SELECT 
    category, COUNT(name) AS Total_pizzas
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day?
SELECT 
    ROUND(AVG(quantity), 0) AS Avg_pizzas_ordered_per_day
FROM
    (SELECT 
        o.date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.date) AS Order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue?
SELECT 
    pt.name, SUM(p.price * od.quantity) AS revenue
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue?
SELECT 
    pt.category,
    SUM(p.price * od.quantity) AS revenue,
    ROUND(SUM(p.price * od.quantity) * 100.0 / (SELECT 
                    SUM(p.price * od.quantity)
                FROM
                    pizzas p
                        JOIN
                    order_details od ON p.pizza_id = od.pizza_id),
            2) AS percentage_contribution
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

-- Analyze the cumulative revenue generated over time?
SELECT 
    order_date,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM
(
    SELECT 
        DATE(o.date) AS order_date,
        SUM(p.price * od.quantity) AS daily_revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY DATE(o.date)
) AS daily_sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category?
select name, revenue from 
(select category, name, revenue, 
rank() over(partition by category order by revenue desc) as rnk
from
(select pizza_types.category, pizza_types.name, 
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by  pizza_types.category, pizza_types.name) as a) as b
where rnk <= 3;



