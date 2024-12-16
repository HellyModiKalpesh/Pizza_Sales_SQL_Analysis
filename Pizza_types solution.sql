-- Retrieve the total number of orders placed.

select count(order_id) as Total_orders from orders;

-- Calculate the total revenue generated from pizza sales.

select round(sum(quantity*price),2) as total_revenue
 from order_details left join pizzas
on order_details.pizza_id=pizzas.pizza_id;

-- Identify the highest-priced pizza.

select name,price from
pizza_types left join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
order by price desc limit 1;

-- Identify the most common pizza size ordered.

select count(size) ,size from order_details left join pizzas
on order_details.pizza_id=pizzas.pizza_id
group by size order by count(size) desc
limit 1;

-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name,sum(order_details.quantity) as total_qty
from pizzas left join pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name order by total_qty desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category,sum(order_details.quantity) as total_quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by category;

-- Determine the distribution of orders by hour of the day.

select count(*) as orders, extract(hour from time) as hours from orders
group by extract(hour from time)
order by orders,hours asc;

-- Join relevant tables to find the category-wise distribution of pizzas.

select category,count(*) as pizza from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(total_orders) as no_of_pizzas from 
(
select date,sum(quantity) as total_orders 
from order_details
 join orders
on order_details.order_id=orders.order_id
group by date
) as daily;

-- Determine the top 3 most ordered pizza types based on revenue.

select name, sum(price*quantity) as revenue from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join pizza_types
on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by name
order by revenue desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

with cte as (
select pizza_types.category,sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by category
order by revenue desc
)
select category,round((revenue/(select sum(revenue) from cte))*100,2) as percentage from cte;

-- Analyze the cumulative revenue generated over time.

select orders.date,
SUM(sum(order_details.quantity*pizzas.price))over(order by orders.date)as revenue
from orders join order_details
on orders.order_id=order_details.order_id
join pizzas
on order_details.pizza_id=pizzas.pizza_id
group by orders.date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

-- revenue for pizza category 
-- piza 
-- top 3

with cte as (
select pizza_types.name,
category,
sum(order_details.quantity*pizzas.price) as revenue,
rank()over(partition by category order by sum(order_details.quantity*pizzas.price) desc) as rnk
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join pizza_types
on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by category,pizza_types.name
)
select * from cte where rnk<=3;

