
use sakila;

-- 1a.  Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b.  Display the first and last name of each actor in a single column in upper case letters.
-- Name the column Actor Name.
select concat(first_name, ' ', last_name) from actor;

-- 2a.  You need to find the ID number, first name, and last name of an actor, of whom you know only 
-- the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor
where first_name = 'Joe';

-- 2b.  Find all actors whose last name contain the letters GEN:
select * from actor
where last_name like "%GEN%";


-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name,
-- in that order:
select * from actor
where last_name like "%LI%"
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');


-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to 
-- specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(30) AFTER first_name;

select * from actor;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name 
-- column to blobs.
ALTER TABLE `sakila`.`actor` 
CHANGE COLUMN `middle_name` `middle_name` BLOB NULL DEFAULT NULL ;

SHOW FIELDS FROM actor;

-- 3c. Now delete the middle_name column.
ALTER TABLE `sakila`.`actor` 
DROP COLUMN `middle_name`;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at 
-- least two actors
CREATE VIEW name_count AS
SELECT last_name, COUNT(last_name) as 'name_ount' FROM actor
GROUP BY last_name;

SELECT last_name, name_count from name_count
WHERE name_count > 1;


-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's 
-- second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE `sakila`.`actor` SET `first_name` = 'HARPO' WHERE (`actor_id` = '172');

SELECT * FROM actor
WHERE last_name = 'WILLIAMS';


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a
-- single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)

SET SQL_SAFE_UPDATES = 0;
UPDATE `sakila`.`actor` 
SET `first_name` = 'GROUCHO' 
WHERE (`first_name` = 'HARPO');
SET SQL_SAFE_UPDATES = 1;

SELECT * FROM actor
WHERE last_name = 'WILLIAMS';


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
CREATE SCHEMA `new_sakila_schema`;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff 
-- and address:
SELECT staff.first_name, staff.last_name, address.address FROM staff
JOIN address ON
staff.address_id = address.address_id;



-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select * from staff;
select * from payment;

CREATE VIEW staff_payments AS
SELECT payment.amount, staff.first_name, staff.last_name FROM payment
INNER JOIN staff
ON staff.staff_id = payment.staff_id;

SELECT * from staff_payments;

SELECT first_name, last_name, SUM(amount) FROM staff_payments
GROUP BY first_name;

SELECT SUM(payment.amount) AS 'Total Rung Up', staff.first_name as "first name", staff.last_name AS "last name" FROM payment
INNER JOIN staff
ON payment.staff_id = staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select * from film_actor;
select film.title, COUNT(film_actor.film_id) AS 'Actor Count' FROM film_actor
INNER JOIN film
ON film.film_id = film_actor.film_id
GROUP BY title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
CREATE VIEW hunchCopies AS
SELECT film.title, inventory.film_id from film
INNER JOIN inventory
where (film.film_id = inventory.film_id) AND (film.title = 'Hunchback Impossible');

SELECT count(film_id) as 'Hunchback Copies' FROM hunchCopies;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers 
-- alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)
select * from payment;

SELECT SUM(payment.amount) AS "Total Paid", customer.first_name, customer.last_name FROM payment
INNER JOIN customer
WHERE payment.customer_id = customer.customer_id
GROUP BY customer.customer_id
ORDER BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies 
-- starting with the letters K and Q whose language is English.
SELECT * FROM film;
SELECT * FROM language;

SELECT title from film
WHERE (title LIKE 'H%' OR title LIKE 'K%') AND language_id = 1;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT * FROM film_actor;
SELECT * FROM actor;


SELECT first_name, last_name FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
    SELECT film_id
    FROM film
    WHERE title = 'Alone Trip'
  )
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all 
-- Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email FROM customer
WHERE address_id IN
(
  SELECT address_id FROM address
  WHERE city_id IN
  (
    SELECT city_id FROM city
    WHERE country_id IN
    (
      SELECT country_id FROM country
      WHERE country = "Canada"
	)
  )
);

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all 
-- movies categorized as famiy films.
SELECT * from category;
SELECT * FROM film_category;
SELECT * FROM film;


SELECT title FROM film
WHERE film_id IN
(
  SELECT film_id FROM category
  WHERE category_id IN
  (
    SELECT category_id FROM category	
    WHERE name = 'Family'
  )
);

-- 7e. Display the most frequently rented movies in descending order.
SELECT * FROM rental;
SELECT * FROM film;
SELECT * FROM inventory;

CREATE VIEW filmInventoryID AS
SELECT film.title as 'title', inventory.inventory_id FROM film
JOIN inventory
WHERE film.film_id = inventory.film_id;

SELECT * FROM filmInventoryID;

SELECT filmInventoryID.title, COUNT(rental.rental_id) AS "Rental Count" FROM filmInventoryID
JOIN rental
WHERE filmInventoryID.inventory_id = rental.inventory_id
GROUP BY filmInventoryID.title
ORDER BY `Rental Count` DESC;



-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM store;
SELECT * FROM payment;
SELECT * FROM rental;
SELECT * FROM inventory;

CREATE VIEW payRental AS
SELECT rental.rental_id, payment.amount FROM payment
INNER JOIN rental WHERE payment.rental_id = rental.rental_id;

SELECT * FROM payRental;

CREATE VIEW payInventory AS
SELECT payRental.amount, rental.inventory_id FROM payRental
INNER JOIN rental
WHERE rental.rental_id = payRental.rental_id;

SELECT * FROM payInventory;

SELECT inventory.store_id, SUM(payInventory.amount) AS 'Total Revenue' from payInventory
INNER JOIN inventory
WHERE inventory.inventory_ID = payInventory.inventory_ID
GROUP BY inventory.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, address.address_id FROM store
JOIN address
WHERE store.address_id = address.address_id;
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: 
-- category, film_category, inventory, payment, and rental.)
SELECT * FROM rental;
SELECT * FROM inventory;
SELECT * FROM film;
SELECT * FROM film_category;
SELECT * FROM category;
SELECT * FROM payInventory;

CREATE VIEW payFilm AS
SELECT payInventory.amount, inventory.film_id FROM payInventory
INNER JOIN inventory
WHERE inventory.inventory_id = payInventory.inventory_id;

SELECT * FROM payFilm;

CREATE VIEW payCat AS
SELECT payFilm.amount, payFilm.film_id, film_category.category_id FROM payFilm
INNER JOIN film_category
ON payFilm.film_id = film_category.film_id
ORDER BY amount;

SELECT * FROM payCat
WHERE category_id>1;

DROP VIEW catAmounts;

CREATE VIEW catAmounts AS
SELECT category.name, SUM(payCat.amount) as "Total Paid" FROM payCat
INNER JOIN category
ON category.category_id = payCat.category_id
GROUP BY category.name
ORDER BY SUM(payCat.amount) DESC;


SELECT * FROM catAmounts;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to 
-- create a view.
SET SQL_SAFE_UPDATES = 0;

CREATE VIEW topCatAmounts AS
SELECT * FROM catAmounts
WHERE `Total Paid` > 4376;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM topCatAmounts;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW topCatAmounts;



