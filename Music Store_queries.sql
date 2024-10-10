SELECT e.first_name, e.last_name
FROM employee AS e
WHERE e.title = 'Senior General Manager';

SELECT i.billing_country, COUNT(i.invoice_id) AS invoice_count
FROM invoice AS i
GROUP BY i.billing_country
ORDER BY invoice_count DESC
LIMIT 1;

SELECT i.total
FROM invoice AS i
ORDER BY i.total DESC
LIMIt 3;

SELECT i.billing_city, sum(i.total) AS invoice_total
FROM invoice AS i
GROUP BY i.billing_city
ORDER BY invoice_total DESC
LIMIT 1;

--Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money

-- change the data type of customer_id
ALTER TABLE invoice
ADD COLUMN customer_id_varchar VARCHAR(255);

UPDATE invoice
SET customer_id_varchar = TO_VARCHAR(customer_id);

ALTER TABLE invoice
DROP COLUMN customer_id;

ALTER TABLE invoice
RENAME COLUMN customer_id_varchar TO customer_id;


SELECT c.customer_id, c.first_name, c.last_name, SUM(total) AS total_spending
FROM customer AS c
JOIN invoice AS i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spending DESC
LIMIT 1;


--Question Set2:moderate
--Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT c.email, c.first_name, c.last_name 
FROM customer AS c
JOIN invoice AS i ON c.customer_id = i.customer_id
JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
WHERE il.track_id IN(
    SELECT t.track_id 
    FROM track AS t
    JOIN genre AS g ON t.genre_id = g.genre_id
    WHERE g.name LIKE'Rock'
    )
ORDER BY email; 

--Q2: Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands

SELECT 
    artist.name, SUM(track.milliseconds) AS total_track
FROM 
    artist
JOIN 
    album ON artist.artist_id = album.artist_id
JOIN 
    track ON album.album_id = track.album_id 
WHERE 
    track.track_id IN (
        SELECT t.track_id 
        FROM track AS t
        JOIN genre AS g ON t.genre_id = g.genre_id  
        WHERE g.name LIKE 'Rock'  
    )
GROUP BY artist.name  -- Group by artist name for SUM aggregation
ORDER BY total_track DESC 
LIMIT 10;  

--Q3: Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

SELECT track.name
FROM track
WHERE 
    track.milliseconds > (
        SELECT AVG(track.milliseconds)  -- Use AVG() to calculate the mean
        FROM track
    )
ORDER BY track.milliseconds DESC;


--Question Set 3 – Advance

--Q1:Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

SELECT CONCAT(customer.first_name, '', customer.first_name) AS customer_name, artist.name, sum(invoice_line.unit_price*invoice_line.quantity) AS total_spent
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON track.album_id = album.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY customer_name, artist.name
ORDER BY total_spent DESC;


--Q2:We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres



WITH popular_genre AS 
(
    SELECT 
        customer.country, 
        genre.name, 
        genre.genre_id, 
        COUNT(invoice_line.invoice_id) AS purchases, 
        ROW_NUMBER() OVER (
            PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
    FROM invoice_line 
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
)
SELECT * 
FROM popular_genre 
WHERE RowNo = 1;


--Q3. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

    
WITH Customer_with_country AS (
    SELECT 
        customer.customer_id, 
        customer.first_name, 
        customer.last_name, 
        customer.country, 
        SUM(invoice.total) AS total_spending,
  
      ROW_NUMBER() OVER (
            PARTITION BY customer.country 
            ORDER BY SUM(invoice.total) DESC
        ) AS RowNo
    FROM invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, customer.first_name, customer.last_name, customer.country
    ORDER BY customer.country ASC, total_spending DESC
)
SELECT * 
FROM Customer_with_country 
WHERE RowNo = 1;
  




