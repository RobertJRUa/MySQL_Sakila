# 1a. Display the first and last names of all actors from the table "actor."
USE sakila; 
SELECT first_name, last_name 
FROM actor; 

# 1b. Display the first and last name of each actor in a single column in upper case letters. 
# Name the column `Actor Name.`
SELECT concat(first_name, " ",  last_name) AS "Actor Name" 
FROM actor; 

# 2a. You need to find the ID number, first name, and last name of an actor named "Joe."
# What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

# 2b. Find all actors whose last name contain the letters `GEN.`
SELECT first_name, last_name
FROM actor 
WHERE last_name like "%GEN%";

# 2c. Find all actors whose last names contain the letters `LI.'
# This time, order the rows by last name and first name, in that order.
SELECT last_name, first_name
FROM actor 
WHERE last_name like "%LI%";

# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
# Afghanistan, Bangladesh, and China.
select country, country_id from country 
where country in ("Afghanistan", "Bangladesh", "China");

# 3a. You want to keep a description of each actor. 
# You don't think you will be performing queries on a description ...
# ... so create a column in the table `actor` named `description` and use the data type `BLOB` 
ALTER TABLE actor
ADD description blob after first_name;

# 3b. Very quickly you realize that entering descriptions for each actor ...
# is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP description;

# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) FROM actor 
	GROUP BY last_name;

# 4b. List last names of actors and the number of actors who have that last name ...
# but only for names that are shared by at least two actors.
SELECT last_name, COUNT(last_name) FROM actor 
	GROUP BY last_name HAVING COUNT(last_name) >= 2;

# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as ...
# `GROUCHO WILLIAMS`. Write a query to fix the record.
SET sql_safe_updates = 0;

UPDATE actor 
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO` ... 
# It turns out that `GROUCHO` was the correct name after all! 
# In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = CASE
    WHEN first_name = "HARPO" THEN "GROUCHO"
    ELSE first_name 
END
WHERE last_name = "WILLIAMS";

SET sql_safe_updates = 1;

# 5a. You cannot locate the schema of the `address` table. 
# Which query would you use to re-create it?
SHOW CREATE TABLE address;

# 6a. Use `JOIN` to display the first and last names ... 
# as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, staff.address_id, address.address
FROM staff
	INNER JOIN address ON staff.address_id = address.address_id;

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
# Use tables `staff` and `payment`.
SELECT staff.first_name, staff.last_name, concat("$", format(SUM(amount),2)) AS total_rung
FROM staff 
JOIN payment
USING (staff_id)
WHERE DATE(payment_date) LIKE "%2005-08%"
GROUP BY first_name, last_name;

# 6c. List each film and the number of actors who are listed for that film. 
# Use tables `film_actor` and `film`. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) AS actors_count FROM film
	INNER JOIN film_actor ON film.film_id = film_actor.film_id
    GROUP BY film.film_id;  

# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, COUNT(inventory.film_id) AS copy_count FROM film
	INNER JOIN inventory ON film.film_id = inventory.film_id
    GROUP BY film.film_id
    HAVING film.title = "Hunchback Impossible";

# 6e. Using the tables `payment` and `customer` and the `JOIN` command ...
# list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS total_paid FROM customer
	INNER JOIN payment ON customer.customer_id = payment.customer_id
    GROUP BY customer.customer_id
    ORDER BY customer.last_name;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
# As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
# Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT * FROM film; 
SELECT title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') 
AND language_id=(SELECT language_id FROM language where name='English');

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id
	IN (SELECT actor_id FROM film_actor WHERE film_id 
		IN (SELECT film_id from film where title='ALONE TRIP'));

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
# Use joins to retrieve this information.
SELECT * FROM customer, address; 
SELECT first_name, last_name, email FROM customer
JOIN address ON (customer.address_id = address.address_id)
JOIN city ON (address.city_id=city.city_id)
JOIN country ON (city.country_id=country.country_id);

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
# Identify all movies categorized as _family_ films.
SELECT film_id, title, rating FROM film
	WHERE film_id IN
	(SELECT film_id FROM film_category
		WHERE category_id IN
			(SELECT category_id FROM category 
				WHERE category_id = '8'));
                
# 7e. Display the most frequently rented movies in descending order.
SELECT * FROM rental;
SELECT title, COUNT(film.film_id) AS 'Rental_Count'
FROM  film 
JOIN inventory ON (film.film_id= inventory.film_id)
JOIN rental ON (inventory.inventory_id=rental.inventory_id)
GROUP BY title 
ORDER BY Rental_Count DESC;

 # 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM staff;
SELECT staff.store_id, SUM(payment.amount) 
FROM payment 
JOIN staff  ON (payment.staff_id=staff.staff_id)
GROUP BY store_id;

# 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country FROM store 
JOIN address  ON (store.address_id=address.address_id)
JOIN city  ON (address.city_id=city.city_id)
JOIN country  ON (country.country_id=country.country_id);

# 7h. List the top five genres in gross revenue in descending order. 
# (**Hint**: you may need to use the following tables: 
# category, film_category, inventory, payment, and rental.)
SELECT category.name, SUM(payment.amount) FROM category
	INNER JOIN film_category ON category.category_id = film_category.category_id
	INNER JOIN inventory ON film_category.film_id = inventory.film_id
	INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
    INNER JOIN payment ON rental.rental_id = payment.rental_id
	GROUP BY category.name
    ORDER BY SUM(payment.amount) DESC 
    LIMIT 5;

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
# Use the solution from the problem above to create a view. 
CREATE VIEW top_5_genres AS
	SELECT category.name AS "Genre", SUM(payment.amount) AS "Gross Revenue" FROM category
		INNER JOIN film_category ON category.category_id = film_category.category_id
		INNER JOIN inventory ON film_category.film_id = inventory.film_id
		INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
		INNER JOIN payment ON rental.rental_id = payment.rental_id
		GROUP BY category.name
		ORDER BY SUM(payment.amount) DESC
		LIMIT 5;

# 8b. How would you display the view that you created in 8a?
SELECT * FROM top_5_genres;

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_5_genres; 