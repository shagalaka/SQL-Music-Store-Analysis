-- SQL Project by Shagun Kadam
-- Dataset Attached

-- Most senior employee based on job title
SELECT first_name, last_name, title 
FROM employee
ORDER BY levels DESC
LIMIT 1

-- Country that has most invoices
SELECT COUNT(*) as no_of_invoices, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY no_of_invoices DESC

-- Top 3 values of the invoices
SELECT total
FROM invoice
ORDER BY total DESC

-- Countries that has best customers. Write a query that returns one city that has the
-- highest sum of invoice totals. Return both the city name & sum of all invoice total
SELECT billing_city, SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1

-- The customer who spent the most money
SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1

-- Query to return the email, first name, last name, & Genre of all Rock Music listeners.
-- Order the list alphabetically by email starting with A.
SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email

-- Artists who has written most "Rock" music in the dataset, with "Artist name" and total
-- track count of the top 10 rock bands.
SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS no_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY no_of_songs DESC
LIMIT 10

-- Track names that have a song length longer than the average song length with the Name
-- and Milliseconds for each track. Order the song length with the longest songs.
SELECT name, milliseconds
FROM track
WHERE milliseconds > 
	(
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track
	)
ORDER BY milliseconds DESC

-- Amount spent by each customer on artists. Return cutomer name, artist name, total spend
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN (
    SELECT artist.artist_id, artist.name AS artist_name
    FROM artist
    JOIN album ON artist.artist_id = album.artist_id
    JOIN track ON album.album_id = track.album_id
    JOIN invoice_line ON track.track_id = invoice_line.track_id
    GROUP BY artist.artist_id, artist.name
    ORDER BY SUM(invoice_line.unit_price * invoice_line.quantity) DESC
    LIMIT 1
) AS bsa ON alb.artist_id = bsa.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC

-- Most popular music Genre for each country. 
WITH popular_genre AS 
(
    SELECT COUNT(il.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(il.quantity) DESC) AS Row_No 
    FROM invoice_line as il
	JOIN invoice ON invoice.invoice_id = il.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = il.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id
	ORDER BY customer.country ASC, purchases DESC
)
SELECT * FROM popular_genre WHERE Row_No <= 1


-- Customer who has most on music for each country. Show country along with top customer and how much
-- they spent, also show all customers who spent that amount
WITH Customer_with_country AS
	(
		SELECT c.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS Row_No 
		FROM invoice as i
		JOIN customer as c ON c.customer_id = i.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC
	)
SELECT * FROM Customer_with_country WHERE Row_No <= 1


-- Thank You
-- Shagun Kadam