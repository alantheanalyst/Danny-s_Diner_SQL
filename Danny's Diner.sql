--1. Total amount and time spent each customer spent at the diner.
select customer_id, sum(price) total_sales
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.menu menu
	on sales.product_id = menu.product_id
group by customer_id
order by total_sales

--2. Total amount of times a customer visited the diner.
select customer_id, count(distinct order_date) total_visits
from [Danny's Diner].dbo.sales
group by customer_id
order by total_visits

--3. The first item purchased by each customer.
select distinct customer_id, order_date, product_name
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.menu menu
	on sales.product_id = menu.product_id
where order_date = '2021-01-01'
order by order_date 

--4. The most popular item on the menu and the amount of times it was purchased by each customer. 

--4.1 Most puuchased meal
select top 1 product_name Most_Purchased_Meal, count(product_name) Times_a_Meal_was_Purchased
from [Danny's Diner].dbo.menu menu
join [Danny's Diner].dbo.sales sales
	on menu.product_id = sales.product_id
group by product_name
order by Times_a_Meal_was_Purchased desc

--4.2 Times a meal was purchased by each customer.
select customer_id, product_name, count(product_name) ramen_count
from [Danny's Diner].dbo.menu menu
join [Danny's Diner].dbo.sales sales
	on menu.product_id = sales.product_id
where product_name = 'Ramen'
group by customer_id, product_name
order by ramen_count



--5. The most popular item for each customer.
select distinct customer_id, product_name, count(sales.product_id) order_count
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.menu menu
	on sales.product_id = menu.product_id
where not customer_id = 'A' or not sales.product_id in (1, 2)
group by customer_id, product_name
order by customer_id, order_count desc

--6. The first items purchased by customers A and B right after they became members.
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

--7.First items purchased by customers A and B  right before their memberships.
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

--8. Total items purchased and amount spent by customers A and B before their memberships
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

--9. Points earned by each customer when each dollar spent = ten points and sushi includes a 2x multiplier.
select customer_id,
sum(case
	when sales.product_id in (2, 3) then (price * 10)
	else (price * 20)
end) points
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.menu menu
	on sales.product_id = menu.product_id
group by customer_id
order by points

--10. The number of points earned by customers A and B in January 
--Members get twice the points on all their purchases on the first week of their membership including the day they became a member.
select sales.customer_id,
sum(case
	when order_date < join_date and sales.product_id in (2,3) then (price * 10)
	when order_date < join_date and sales.product_id = 1 then (price * 20)
	when order_date >= join_date and sales.product_id in (2,3) then (price * 20)
	when order_date >= join_date and sales.product_id = 1 then (price * 400)
end) points
from [Danny's Diner].dbo.sales sales
join [Danny's Diner].dbo.menu menu
	on sales.product_id = menu.product_id
join [Danny's Diner].dbo.members members
	on sales.customer_id = members.customer_id
where order_date < '2021-02-01'
group by sales.customer_id

--11. Recreating the table according to Danny's specifications.
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

-- Highest ranked items for each customer
select top 5 customer_id, product_name,
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
order by ranking desc, customer_id asc
