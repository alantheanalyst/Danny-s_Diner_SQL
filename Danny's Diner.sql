--Exploring tables
select *
from [Danny's Diner].dbo.sales

select * 
from [Danny's Diner].dbo.menu

select *
from [Danny's Diner].dbo.members

--1. Total amount each customer has spent at the Diner
--Customer A
select customer_id, sum(price) total_sales
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.menu menu
	on sales.product_id = menu.product_id
group by customer_id
--Customer A spent the most while customer C spent the least. 

--2. Total amount of times each customer visited the resuturant.
select customer_id, count(distinct order_date) total_visits
from [Danny's Diner].dbo.sales
group by customer_id
order by total_visits
--customers C visited the least while customer B visited the most.

--3. 1st item purchased by each customer.
select distinct customer_id, order_date, product_name
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.menu menu
	on sales.product_id = menu.product_id
where order_date = '2021-01-01'
order by order_date
--Customer A order curry and sushi during his/her first order. 
--While examining the table I realised that all customers order on the first of January so which is the fist date on the order_date column.

--4. The most purhcased item and the amount of times it was ordered.
--4.1 Most puuchased meal
select top 1 product_name Most_Purchased_Meal, count(product_name) Times_a_Meal_was_Purchased
from [Danny's Diner].dbo.menu menu
join [Danny's Diner].dbo.sales sales
	on menu.product_id = sales.product_id
group by product_name
order by Times_a_Meal_was_Purchased desc

--4.2 Times a meal was purchased.
select customer_id, product_name, count(product_name) ramen_count
from [Danny's Diner].dbo.menu menu
join [Danny's Diner].dbo.sales sales
	on menu.product_id = sales.product_id
where product_name = 'Ramen'
group by customer_id, product_name
order by ramen_count
--Ramen was the most purchased item. It was purchased three times by customer A and C and two times by B

--5. Most popular meal for each customer.
select distinct customer_id, product_name, count(product_name) order_count
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.menu menu
	on sales.product_id = menu.product_id
where not customer_id = 'A' or not product_name in ('sushi', 'curry')
group by customer_id, product_name
order by customer_id, order_count desc
--Ramen was the most popular meal for customers A and C. Customer B purhcased each male twice.

--6. First item purchased by each customer after they became a member.
with cte_member_sales as
(
select sales.customer_id, join_date, order_date, product_id,
	dense_rank() over(partition by sales.customer_id order by order_date) rank
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.members members
	on sales.customer_id = members.customer_id
where order_date > join_date
)
select customer_id, order_date, product_name
from cte_member_sales cte
join [Danny's Diner].dbo.menu menu
	on cte.product_id = menu.product_id
where rank = 1
--Ramen was the first meal purchased by customer A following membership while Sushi was purchased by customer B after membership.

--7. First otem purchased right before customer became a member.
with member_sales_cte as
(select sales.customer_id, join_date, order_date, product_id,
dense_rank() over(partition by sales.customer_id order by order_date desc) rank
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.members members
	on sales.customer_id = members.customer_id
where order_date < join_date
)
select customer_id, order_date, product_name, rank
from member_sales_cte cte
join [Danny's Diner].dbo.menu menu
	on cte.product_id = menu.product_id
where rank = 1

--checking to see if my answer is correct
select sales.customer_id, join_date, order_date
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.members members
	on sales.customer_id = members.customer_id
where order_date < join_date
order by order_date
--Customer A's first orders before becoming a member are sushi and curry while customer B only order curry.

--8. The total items and amount spent customers A and B before thier memberships
with total_cte as
(select sales.customer_id, join_date, order_date, product_id
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.members members
	on sales.customer_id = members.customer_id
where order_date < join_date)
select customer_id, sum(cte.product_id) total_items_purhcased, sum(price) total_amount
from total_cte cte
join [Danny's Diner].dbo.menu menu
	on cte.product_id = menu.product_id
group by cte.customer_id
--Prior to thier memberships, customer A made 3 purhchases amounting to $25.00 while customer B made 5 purchases amoutning to $40.00.

--9. The points each customer accumulated is each $1 spent = 10 points and Sushi has a 2x points multiplier.
select customer_id,
sum(case
	when product_name in ('curry', 'ramen') then (price * 10)
	else (price * 20)
end) points
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.menu menu
	on sales.product_id = menu.product_id
group by customer_id
order by points

--10. Members earn 2x for all purchases on their first week including their intial membership date. 
--The amount of points customer's A and B earned at the end of Januray
with cte_points as
(
select sales.customer_id, join_date, order_date, product_id
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.members members
	on sales.customer_id = members.customer_id
where order_date >= join_date
)
select customer_id,
sum(case
	when product_name in ('curry', 'ramen') then (price * 20)
	else (price * 400)
end) points
from cte_points cte
join [Danny's Diner].dbo.menu menu
	on cte.product_id = menu.product_id
where order_date < '2021-02-01'
group by customer_id

--11. Recreating the table per specifications
select *
from [Danny's Diner].dbo.members

select customer_id, order_date, product_name, price,
case 
	when customer_id = 'A' and order_date >= '2021-01-07' then 'Y'
	when customer_id = 'B' and order_date >= '2021-01-09' then 'Y'
	else 'N'
end member,
case 
	when customer_id = 'A' and product_name = 'curry' and order_date >= '2021-01-07' then 1
	when customer_id = 'A' and product_name = 'ramen' and order_date >= '2021-01-07' then 2
	when customer_id = 'B' and product_name = 'sushi' and order_date >= '2021-01-09' then 1
	when customer_id = 'B' and product_name = 'ramen' and order_date >= '2021-01-09' and order_date < '2021-02-01' then 2
	when customer_id = 'B' and order_date = '2021-02-01' then 3
end ranking
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.menu menu
	on sales.product_id = menu.product_id
order by customer_id asc, order_date asc, price desc



