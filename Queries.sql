USE sakila;
-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column `Actor Name`.
SELECT CONCAT (first_name, ' ',last_name) AS `Actor Name`
	FROM actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know 
-- only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
	WHERE first_name = "Joe";	
-- 2b. Find all actors whose last name contain the letters `GEN`;

SELECT first_name, last_name FROM actor
	WHERE last_name LIKE '%GEN%';	

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by 
-- last name and first name, in that order:

SELECT last_name, first_name FROM actor
	WHERE last_name Like "%LI%"
    ORDER BY last_name, first_name;

 
-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
	WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- * 3a. Add a `middle_name` column to the table `actor`. Position it between
-- `first_name` and `last_name`. Hint: you will need to specify the data type.
 
ALTER TABLE actor
	ADD middle_name VARCHAR(45) AFTER first_name;
SELECT * FROM actor;

-- * 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor 
	MODIFY middle_name BLOB;

-- * 3c. Now delete the `middle_name` column.
ALTER TABLE actor
	DROP middle_name;
SELECT * FROM actor;

-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) FROM actor 
	WHERE last_name IS NOT NULL
    GROUP BY last_name;
-- * 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) FROM actor
	WHERE last_name IS NOT NULL 
    GROUP BY last_name
    HAVING COUNT(last_name)>1;

-- * 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as 
-- `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query 
-- to fix the record.
SELECT first_name FROM actor WHERE
	first_name = 'GROUCHO'AND last_name = 'WILLIAMS'; 
    -- only one row returned. Hence only one actor named GROUCHO WILLIAMS
UPDATE actor
	SET first_name = 'HARPO' WHERE
    first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that 
-- `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently 
-- `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the 
-- actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, 
-- HOWEVER! (Hint: update the record using a unique identifier.)
-- SET SQL_SAFE_UPDATES = 0;

UPDATE actor
	SET first_name = CASE 
					WHEN first_name = 'HARPO' AND last_name = 'WILLIAMS' THEN 'GROUCHO' 
					WHEN first_name = 'GROUCHO' THEN 'MUCHO GROUCHO'
					END; 
SELECT * FROM actor WHERE
	first_name = 'HARPO' OR first_name = 'GROUCHO' OR first_name = 'MUCHO GROUCHO';
		 
-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- DESCRIBE address;
-- SHOW TABLES;
SHOW CREATE TABLE address;

--   * Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>
-- 
-- * 6a. Use `JOIN` to display the first and last names, as well as the address, 
-- of each staff member. Use the tables `staff` and `address`:
SELECT s.first_name, s.last_name, a.address FROM
	 staff s INNER JOIN address a
     ON s.address_id = a.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in 
-- August of 2005. Use tables `staff` and `payment`.
SELECT s.staff_id, s.first_name, s.last_name, SUM(p.amount) AS `Total Amount` FROM
	staff s INNER JOIN payment p ON
    s.staff_id = p.staff_id 
    WHERE p.payment_date >='2005-08-01' AND p.payment_date <'2005-09-01' 
    GROUP BY staff_id;

-- * 6c. List each film and the number of actors who are listed for that film. Use tables
--  `film_actor` and `film`. Use inner join.
SELECT f.title, COUNT(fa.actor_id) AS `number of actors` FROM
	film f INNER JOIN film_actor fa ON
    f.film_id = fa.film_id GROUP BY f.title;
 
-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
-- using nested queries
SELECT COUNT(inventory_id) AS `copies of the film` FROM inventory
	WHERE film_id IN (SELECT film_id FROM film
					WHERE title = 'Hunchback Impossible');
-- using join
SELECT f.title, COUNT(i.inventory_id) FROM
	film f INNER JOIN inventory i ON
    f.film_id = i.film_id WHERE
    f.title = 'Hunchback Impossible';
    
-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, 
-- list the total paid by each customer. List the customers alphabetically by last name:
SELECT  c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS `Total Paid` FROM
	customer c INNER JOIN payment p ON
    c.customer_id = p.customer_id GROUP BY c.customer_id
    ORDER BY c.last_name ASC;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared
--  in popularity. Use subqueries to display the titles of movies starting with the letters
--  `K` and `Q` whose language is English.
SELECT title FROM film WHERE
	language_id IN (SELECT language_id FROM language WHERE
					name = 'english') HAVING
	title LIKE 'K%' OR title LIKE 'Q%';

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name FROM actor WHERE
	actor_id IN (SELECT actor_id FROM film_actor WHERE
				film_id IN(SELECT film_id FROM film WHERE
							title = 'Alone Trip'
						)
                );
-- * 7c. You want to run an email marketing campaign in Canada, for which you will need 
-- the names and email addresses of all Canadian customers. Use joins to retrieve this 
-- information.
-- USING SUBQUERIES
SELECT first_name, last_name, email FROM customer WHERE
	address_id IN (SELECT address_id FROM address WHERE
					city_id IN (SELECT city_id FROM city WHERE
								country_id IN (SELECT country_id FROM country WHERE
												country = 'canada'
												)
								)
					);
-- USING MULTIPLE JOINS	
SELECT cu.first_name, cu.last_name, cu.email, cou.country 
	FROM customer cu 
		INNER JOIN address ad ON 
		cu.address_id = ad.address_id
        INNER JOIN city cy ON
        ad.city_id = cy.city_id
        INNER JOIN country cou ON
        cy.country_id = cou.country_id
	HAVING cou.country = 'canada';
-- * 7d. Sales have been lagging among young families, and you wish to target all family 
-- movies for a promotion. Identify all movies categorized as famiy films.
SELECT title FROM film WHERE
	film_id IN (SELECT film_id FROM film_category WHERE
				category_id IN (SELECT category_id FROM category WHERE
								name = 'family'
								)
				);

 
-- * 7e. Display the most frequently rented movies in descending order.
SELECT  f.title, COUNT(r.rental_id) AS `Number of Rentals` FROM
	film f 
    INNER JOIN inventory inv ON f.film_id = inv.film_id
    INNER JOIN rental r ON inv.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY `Number of Rentals` DESC;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT st.store_id, SUM(pay.amount) 
	FROM store st 
    INNER JOIN customer cu
    ON st.store_id = cu.store_id
    INNER JOIN payment pay
    ON cu.customer_id = pay.customer_id
GROUP BY st.store_id;

-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT st.store_id, ci.city, cou.country
	FROM store st 
    INNER JOIN address ad ON
    st.address_id = ad.address_id
    INNER JOIN city ci ON
    ad.city_id = ci.city_id
    INNER JOIN country cou ON
    ci.country_id = cou.country_id;
 
-- * 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, 
-- inventory, payment, and rental.)
SELECT c.name, SUM(p.amount) AS `gross revenue`
	FROM category c
		INNER JOIN film_category fc
			ON c.category_id = fc.category_id
		INNER JOIN inventory i
			ON fc.film_id = i.film_id
		INNER JOIN rental r
			ON i.inventory_id = r.inventory_id
		INNER JOIN payment p
			ON r.rental_id = p.rental_id
	GROUP BY c.name
    ORDER BY `gross revenue` DESC LIMIT 5;
	

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing 
-- the Top five genres by gross revenue. Use the solution from the problem above to create
--  a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW category_maxrevenue AS 
SELECT c.name, SUM(p.amount) AS `gross revenue`
	FROM category c
		INNER JOIN film_category fc
			ON c.category_id = fc.category_id
		INNER JOIN inventory i
			ON fc.film_id = i.film_id
		INNER JOIN rental r
			ON i.inventory_id = r.inventory_id
		INNER JOIN payment p
			ON r.rental_id = p.rental_id
	GROUP BY c.name
    ORDER BY `gross revenue` DESC LIMIT 5;
-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM category_maxrevenue;
 
-- * 8c. You find that you no longer need the view `top_five_genres`. 
-- Write a query to delete it.
DROP VIEW category_maxrevenue;