use mavenmovies;

-- CASE NUMBER 1
/*My partner and I want to come by each of the stores in person and meet the managers. Please send over
the managers’ names at each store, with the full address of each property (street address, district, city, and
country please).*/

/*expected result
store		first_name	last_name	address		district	city	country
store 1
store 2 
*/

-- ANSWER CASE NUMBER 1
SELECT 
	staff.first_name, 
    staff.last_name, 
    address.address, 
    address.district, 
    city.city, 
    country.country
FROM staff 
INNER JOIN address ON staff.address_id = address.address_id
INNER JOIN city ON city.city_id = address.city_id
INNER JOIN country ON country.country_id = city.country_id;

-- CASE NUMBER 2
/*I would like to get a better understanding of all of the inventory that would come along with the business.
Please pull together a list of each inventory item you have stocked, including the store_id number, the
inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost.*/

/*expected result
inventory_id store_id  title rating rental_rate replacement_cost
1
2
so on
*/

SELECT 
	inventory.inventory_id, 
    inventory.store_id, 
    film.title, 
    film.rating, 
    film.rental_rate, 
    film.replacement_cost
FROM film 
INNER JOIN inventory ON film.film_id = inventory.film_id;

-- CASE NUMBER 3
/*From the same list of films you just pulled, please roll that data up and provide a summary level overview of
your inventory. We would like to know how many inventory items you have with each rating at each store.
*/

/*
expected result:
store_id 	rating		count_of_inventory
1
1
1
1
1
2
2
2
2
2

*/

SELECT     
    inventory.store_id, 
    film.rating,
    COUNT(inventory_id) AS count_of_inventory
FROM film 
	INNER JOIN inventory ON film.film_id = inventory.film_id
GROUP BY 
	inventory.store_id,
    film.rating;
    
-- CASE NUMBER 4
/*Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
We would like to see the number of films, as well as the average replacement cost, and total replacement
cost, sliced by store and film category*/

SELECT *
FROM film;

SELECT 
	DISTINCT(name),
	COUNT(DISTINCT title) AS 'count_of_films',
	AVG(replacement_cost) AS 'avg_replacement_cost',
    SUM(replacement_cost) AS 'total_replacement_cost',
    inventory.store_id
FROM film 
	INNER JOIN inventory
		ON film.film_id = inventory.film_id
    INNER JOIN film_category
		ON film.film_id = film_category.film_id
	INNER JOIN category
		ON category.category_id = film_category.category_id
GROUP BY store_id, film_category.category_id
ORDER BY name, store_id; -- not obligatory

-- CASE NUMBER 5
/*We want to make sure you folks have a good handle on who your customers are. Please provide a list
of all customer names, which store they go to, whether or not they are currently active, and their full
addresses – street address, city, and country.*/

-- PRO TIPS : list all value in SELECT then add the table. 
-- example >> first_name, last_name, active, store_id
-- then add the table become customer.first_name, customer.last_name, customer.active, customer.store_id

SELECT customer.first_name, customer.last_name, customer.active, customer.store_id, address.address, city.city, country.country
FROM customer
	LEFT JOIN address
		ON customer.address_id = address.address_id
    LEFT JOIN city
		ON address.city_id = city.city_id
    LEFT JOIN country 
		ON city.country_id = country.country_id
ORDER BY country; -- not obligatory
        
-- CASE NUMBER 6
/*We would like to understand how much your customers are spending with you, and also to know who your
most valuable customers are. Please pull together a list of customer names, their total lifetime rentals, and the
sum of all payments you have collected from them. It would be great to see this ordered on total lifetime value,
with the most valuable customers at the top of the list.*/

SELECT customer_id, COUNT(rental_id)
FROM rental
GROUP BY customer_id;

SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id;

SELECT 
	customer.customer_id,
	customer.first_name,
    customer.last_name,
	COUNT(rental.rental_id) AS 'total_rent',
    SUM(payment.amount) AS 'total_spent'
FROM customer 
	LEFT JOIN rental
		ON customer.customer_id = rental.customer_id
	LEFT JOIN payment
		ON rental.rental_id = payment.rental_id
GROUP BY customer_id
-- ORDER BY total_rent DESC; -- we found ELEANOR HUNT is the most frequent customer who rent the film
ORDER BY total_spent DESC; -- whereas KARL SEAL is the most customer who spent the highest amount of money

-- CASE NUMBER 7
/*
My partner and I would like to get to know your board of advisors and any current investors. Could you
please provide a list of advisor and investor names in one table? Could you please note whether they are an
investor or an advisor, and for the investors, it would be good to include which company they work with.
*/

SELECT 
	'advisor' AS type, 
	advisor.first_name, 
    advisor.last_name,
    'NULL' AS company_name -- OR you can just write NULL 
FROM advisor
UNION
SELECT
	'investor' AS type,
    investor.first_name, 
	investor.last_name,
    investor.company_name
FROM investor;

-- CASE NUMBER 8 
/*
We're interested in how well you have covered the most-awarded actors. Of all the actors with three types of
awards, for what % of them do we carry a film? And how about for actors with two types of awards? Same
questions. Finally, how about actors with just one award?

it supposed to be :
awards		percentage in film 
awards 1 	
awards 2
awards 3
*/
SELECT *
FROM actor_award; -- 157 rows returned
SELECT DISTINCT awards
FROM actor_award;
SELECT COUNT(distinct actor_award_id)
FROM actor_award; -- 157 actors

SELECT 
	COUNT(CASE WHEN awards IN ('Emmy, Oscar, Tony ') THEN actor_award_id ELSE NULL END) AS get_3_awards, -- 7 actors get 3 awards
	COUNT(CASE WHEN awards IN ('Emmy, Oscar' , 'Emmy, Tony', 'Oscar, Tony') THEN actor_award_id ELSE NULL END) AS get_2_awards, -- 66 actors get 2 awards
    COUNT(CASE WHEN awards IN ('Emmy', 'Oscar', 'Tony') THEN actor_award_id ELSE NULL END) AS get_1_award -- 84 actors get 1 award
FROM  actor_award; 

-- exploratory data analysis not relate to this case
SELECT *
FROM actor 
	LEFT JOIN actor_award
		ON actor.actor_id = actor_award.actor_id
ORDER BY actor_award_id; -- 200 rows returned, means 43 actors have not received any award such as actor_id 3,4,7 and 40 others

SELECT *
FROM film_actor; -- 1000 rows
SELECT DISTINCT film_id
FROM film_actor; -- 997 rows, so there is 3 duplicate film_id either one up to three actors play 2 film_id or one actor play the same 3 film_id with other actors
SELECT DISTINCT actor_id
FROM film_actor; -- 200 rows returned, so we only have 200 unique actor and 997 unique film

-- solution
SELECT
	COUNT(CASE WHEN awards IN ('Emmy, Oscar, Tony ') THEN actor_award_id ELSE NULL END) AS get_3_awards, -- 7 actors get 3 awards
	COUNT(CASE WHEN awards IN ('Emmy, Oscar' , 'Emmy, Tony', 'Oscar, Tony') THEN actor_award_id ELSE NULL END) AS get_2_awards, -- 66 actors get 2 awards
    COUNT(CASE WHEN awards IN ('Emmy', 'Oscar', 'Tony') THEN actor_award_id ELSE NULL END) AS get_1_award, -- 84 actors get 1 award
    AVG(CASE WHEN actor_id IS NULL THEN 0 ELSE 1 END) AS pct_w_one_film
	
FROM actor_award
	
GROUP BY 
	CASE 
		WHEN awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN awards IN ('Emmy, Oscar','Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
		ELSE '1 award'
	END;
    
    
    SELECT 
		CASE
			WHEN awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
            WHEN awards IN ('Emmy, Oscar', 'Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
            ELSE '1 awards'
            END as 'number_of_awards',
            AVG(CASE WHEN actor_id IS NULL THEN 0 ELSE 1 END) AS 'percentage_with_one_film' -- we will not count actor_id = 0 because they must not have any film_id which means the actor is not listed in our film_id
	FROM actor_award
    
    GROUP BY 
		CASE
			WHEN awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
            WHEN awards IN ('Emmy, Oscar', 'Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
            ELSE '1 awards'
            END;