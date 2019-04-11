use sakila;

-- 1a : Display the first and last names of all actors from the table actor.

select distinct first_name,last_name from actor;

-- 1b : D1b. Display the first and last name of each actor in a single column 
-- in upper case letters. Name the column Actor Name.

select upper(concat(first_name,last_name)) from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only 
-- the first name, "Joe." What is one query would you use to obtain this information?

select actor_id,first_name, last_name from actor where first_name like 'Joe%'

-- 2b. Find all actors whose last name contain the letters GEN:

select * from actor where upper(last_name) like '%GEN%'

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:

select * from actor where upper(last_name) like '%LI%' order by last_name,first_name

-- 2d. Using IN, display the country_id and country columns of the following 
-- countries: Afghanistan, Bangladesh, and China:

select * from country where country in ('Afghanistan', 'Bangladesh','China');

-- 3a You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data 
-- type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

alter table actor
add description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort.
-- Delete the description column.

alter table actor
drop description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name,count(*) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select last_name,count(*) from actor group by last_name having count(*) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
select * from actor where upper(first_name) = 'GROUCHO' and upper(last_name) = 'WILLIAMS';
SET SQL_SAFE_UPDATES = 0;
update actor 
set    first_name = 'HARPO'
where upper(first_name) = 'GROUCHO' and upper(last_name) = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the 
-- correct name after all! In a single query, if the first name of the actor is currently 
-- HARPO, change it to GROUCHO

update actor 
set    first_name = 'GROUCHO'
where upper(first_name) = 'HARPO' and upper(last_name) = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

show create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
select a.first_name, a.last_name, b.*
from staff a, address b where a.address_id = b.address_id

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.

select a.first_name, a.last_name,sum(b.amount)
from   staff a,
	   payment b
where  a.staff_id = b.staff_id
and    b.payment_date like '2005-08%'
group by 1,2;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.

select a.film_id,a.title,count(distinct b.actor_id)
from  film a,
	  film_actor b
where a.film_id = b.film_id
group by a.film_id,a.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select count(*) from inventory where film_id in (
select film_id from film where title = 'Hunchback Impossible');

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:

select a.first_name,a.last_name,sum(b.amount)
from   customer a
		inner join payment b on a.customer_id = b.customer_id
group by a.first_name,a.last_name
order by a.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select * from language

select a.title from film a where (a.title like 'K%' or a.title like 'Q%')
	and a.language_id in (select language_id from language where name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select * from actor where actor_id in 
(select a.actor_id from film_actor a,film b where a.film_id = b.film_id and b.title = 'Alone Trip');

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names 
-- and email addresses of all Canadian customers. Use joins to retrieve this information.
select a.first_name,a.last_name,a.email 
from customer a,
	address b, 
    city c,
    country d
where a.address_id = b.address_id and
	  b.city_id = c.city_id and
      c.country_id = d.country_id and
      d.country = 'Canada';


-- 7d. Sales have been lagging among young families, and you wish to target all family movies 
-- for a promotion. Identify all movies categorized as family films.

select a.*
from   film a,
	   film_category b,
       category c
where  a.film_id = b.film_id and
	   b.category_id = c.category_id and
       c.name = 'Family';


-- 7e. Display the most frequently rented movies in descending order.

select  a.title,count(c.rental_id)
from    film a,
		inventory b,
        rental c
where   a.film_id = b.film_id and
		b.inventory_id = c.inventory_id
group by a.title
order by 2 desc;



-- 7f. Write a query to display how much business, in dollars, each store brought in.

select  c.store_id,sum(d.amount)
from     rental a,
		 inventory b,
         store c,
         payment d
where    a.inventory_id = b.inventory_id and
		 b.store_id = c.store_id and
		 a.rental_id = d.rental_id 
group by c.store_id
order by 1;

-- 7g. Write a query to display for each store its store ID, city, and country.
select a.store_id , c.city, d.country
from store a,
     address b,
     city c,
     country d
where a.address_id = b.address_id and
	b.city_id = c.city_id and
    c.country_id = d.country_id;
    
-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select a.name,sum(e.amount) tot_amount
from category a,
     film_category b,
     inventory c,
     rental d,
     payment e
where a.category_id = b.category_id and
	b.film_id = c.film_id and
    c.inventory_id = d.inventory_id and
    d.rental_id = e.rental_id
group by a.name
order by 2 desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the 
-- Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

create view v_top_5_genre_movies as
select a.name,sum(e.amount) tot_amount
from category a,
     film_category b,
     inventory c,
     rental d,
     payment e
where a.category_id = b.category_id and
	b.film_id = c.film_id and
    c.inventory_id = d.inventory_id and
    d.rental_id = e.rental_id
group by a.name
order by 2 desc
limit 5;


-- 8b. How would you display the view that you created in 8a?
select * from v_top_5_genre_movies;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view v_top_5_genre_movies;

