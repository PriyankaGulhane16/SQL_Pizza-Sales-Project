---Creating Tables---

create table orders(
order_id serial primary key,
order_date date not null,
order_time time not null
);

--Checking Null Values from Orders

select * from orders
where order_id is null
or 
order_date is null
or
order_time is null;


---Creating Tables---

create table orders_details(
order_detail_id serial primary key,
quantity integer,
pizza_id varchar(100),
order_id integer, 
foreign key (order_id)
references orders(order_id)
);

--Checking Null Values from Orders_details

select * from orders_details
where order_detail_id is null
or
quantity is null
or
pizza_id is null
or
order_id is null;


---Creating Tables---

create table pizza_types(
pizza_type_id varchar(100) primary key,
name varchar(100),
category varchar(50),
ingredients text
);

--Checking Null Values from pizza_types

select * from pizza_types
where pizza_type_id is null
or
name is null
or
category is null
or
ingredients is null;


---Creating Tables---

create table pizzas(
pizza_id varchar(100) Primary key,
pizza_type_id varchar(100),
size varchar(10),
price decimal(10,2),
foreign key (pizza_type_id)
references pizza_types(pizza_type_id)
);

--Checking Null Values from pizza_types

select * from pizzas
where pizza_type_id is null
or
pizza_id is null
or
size is null
or
price is null;




---Calling Tables---

select count(*) from orders; --21350
select count(*) from orders_details; --48620
select count(*) from pizzas; -- 96
select count(*) from pizza_types; --32





--Q1: Retrieve the total number of orders placed.

select count(order_id) as Total_Orders from orders;


--Q2: Calculate the total revenue generated from pizza sales.

select sum(round(orders_details.quantity * pizzas.price,2)) as Revenue  
from orders_details 
join pizzas on pizzas.pizza_id= orders_details.pizza_id;



--Q3: Identify the highest-priced pizza.

select pizza_types.name, pizzas.price as Max_Price 
from pizzas 
join pizza_types
on pizzas.pizza_type_id=pizza_types.pizza_type_id
order by Max_Price desc
limit 1;



--Q4: Identify the most common pizza size ordered.

select pizzas.size, count(orders_details.order_detail_id) as Size_count 
from pizzas
join orders_details
on pizzas.pizza_id=orders_details.pizza_id
group by pizzas.size
order by Size_count desc;



--Q5: List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name, sum(orders_details.quantity) as orders
from pizza_types 
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.name
order by orders desc
limit 5;



--Q6: Join the necessary tables to find the total quantity of each pizza category ordered

select pizza_types.category, sum(orders_details.quantity) as Total_Quantity
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by Total_Quantity desc;



--Q7: Determine the distribution of orders by hour of the day.

select extract(hour from order_time) as order_hour, count(order_id) as Orders
from orders
group by order_hour
order by Orders;



--Q8: Join relevant tables to find the category-wise distribution of pizzas.

select category, count(name)
from pizza_types
group by category



--Q9: Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity),2) from
(
select  orders.order_date, sum(orders_details.quantity) as quantity
from orders
left join orders_details on orders_details.order_id = orders.order_id
group by orders.order_date) as quanty;



--Q10:  Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name as Pizza_Type, sum(pizzas.price * orders_details.quantity) as Revenue
from orders_details
join pizzas on pizzas.pizza_id = orders_details.pizza_id
join pizza_types on pizza_types.pizza_type_id =  pizzas.pizza_type_id
group by Pizza_type
order by Revenue desc
limit 3;



--Q11: Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category, (sum(orders_details.quantity * pizzas.price)/
             
			 (select round(sum(orders_details.quantity * pizzas.price),2)
from orders_details
join pizzas on pizzas.pizza_id = orders_details.pizza_id))*100 as Revenue
             from pizza_types
			 
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.category
order by Revenue desc;



--Q12: Analyze the cumulative revenue generated over time.

select order_date, 
sum (Revenue) over (order by order_date)
from
(select orders.order_date , sum(pizzas.price * orders_details.quantity) as Revenue
from orders_details
join pizzas on pizzas.pizza_id = orders_details.pizza_id
join orders on  orders.order_id = orders_details.order_id
group by orders.order_date
order by Revenue) as Sales;



--Q13: Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name, revenue
from
(
select category, name, revenue,
rank() over (partition by category order by revenue) as ran
from
(
select pizza_types.category, pizza_types.name, sum(pizzas.price * orders_details.quantity) as Revenue
from orders_details
join pizzas on pizzas.pizza_id = orders_details.pizza_id
join pizza_types on pizza_types.pizza_type_id =  pizzas.pizza_type_id
group by pizza_types.category, pizza_types.name
))
where ran <=3;





