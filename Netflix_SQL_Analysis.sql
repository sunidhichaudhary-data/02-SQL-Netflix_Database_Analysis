use netflix;
# 1. Using the Viewing History table, identify the top 3 most-watched movies based on viewing hours.
SELECT 
    c.titlename AS MovieName, SUM(v.runtime) AS MostWatched
FROM
    content c
        JOIN
    viewinghistory v ON c.contentid = v.contentid
GROUP BY c.titlename
ORDER BY mostwatched DESC
LIMIT 3;


# 2. Partition the viewing hours by category and genre to find the top genre in each category. 
# Use the rank function to rank genres within each category.
WITH GenreViewingHours AS (
    SELECT 
        c.category AS Category,
        c.genre AS Genre,
        SUM(v.runtime) AS Total_Viewing_Hours,
        RANK() OVER (
            PARTITION BY c.category 
            ORDER BY SUM(v.runtime) DESC
        ) AS Genre_Rank
    FROM content AS c
    JOIN viewinghistory AS v 
        ON c.contentid = v.contentid
    GROUP BY c.category, c.genre
)
SELECT 
    Category,
    Genre,
    Total_Viewing_Hours
FROM GenreViewingHours
WHERE Genre_Rank = 1;

# 3. Determine the number of subscriptions for each plan. 
# Display Plan ID, Plan Name and Subscriber count in descending order of Subscriber count.
SELECT 
    *
FROM
    plans;
SELECT 
    *
FROM
    subscribes;
SELECT 
    s.planID, p.planname, COUNT(s.custID)
FROM
    subscribes AS s
        JOIN
    plans AS p ON p.planID = s.planID
GROUP BY 1;

# 4. Which device type is most commonly used to access Netflix content? Provide the Device Type and count of accesses.
SELECT 
    *
FROM
    devices;
SELECT 
    DeviceType, COUNT(deviceID) AS counts
FROM
    devices
GROUP BY DeviceType
ORDER BY counts DESC
LIMIT 1;

# 5. Compare the viewing trends of movies versus TV shows. What is the average viewing time for movies and TV shows separately?
SELECT 
    c.category, ROUND(AVG(v.runtime), 2)
FROM
    content c
        JOIN
    viewinghistory v ON c.contentid = v.contentid
GROUP BY c.category;

# 6. Identify the most preferred language by customers. Provide the number of customers, and language.
SELECT 
    Language, COUNT(custid)
FROM
    customerslanguagepreferred
GROUP BY language;

# 7. How many customers have adult accounts versus child accounts? Provide the count for each type.

SELECT 'Adult' AS account_type,
       COUNT(DISTINCT p.CustID) AS total_customers
FROM profiles p
JOIN adultacc a
ON p.ProfileID = a.ProfileID

UNION ALL

SELECT 'Child',
       COUNT(DISTINCT p.CustID)
FROM profiles p
JOIN childacc c
ON p.ProfileID = c.ProfileID;

# 8. Determine the average number of profiles created per customer account.

SELECT 
    COUNT(ProfileID) * 1.0 /
    COUNT(DISTINCT CustID) AS avg_profiles
FROM profiles;

# 9. Identify the content that has the lowest average viewing time per user. Provide the titles and their average viewing time.

SELECT 
    c.titlename AS title_name,
    ROUND(AVG(v.runtime)) AS avg_viewing_time
FROM
    content c
        JOIN
    viewinghistory v ON c.contentid = v.contentid
GROUP BY c.titlename
ORDER BY 2 ASC
LIMIT 1;


# 10. Determine the count for each content type.

SELECT 
    category, COUNT(contentid)
FROM
    content
GROUP BY category;


# 11. Compare the number of customers that have unlimited access and who do not.

SELECT 
    CASE
        WHEN p.planid = 'P1' THEN 'limited'
        ELSE 'unlimited'
    END AS content_access,
    COUNT(DISTINCT s.custid) AS Total_Customers
FROM
    plans AS p
        JOIN
    subscribes AS s ON p.planid = s.planid
GROUP BY CASE
    WHEN p.planid = 'P1' THEN 'limited'
    ELSE 'unlimited'
END;

# 12. Find Average monthly price for plans with Content Access as "unlimited".
SELECT 
    AVG(monthlyprice) AS Avg_montly_price_unlimited
FROM
    plans
WHERE
    contentaccess = 'unlimited';

# 13. List all the customers who have taken the plan for till 2028 and later.
# Display CustomerID, Customer name and Expiration Date of the plan, ordered by Expiration Date in descending order first, and then by Customer Name.

SELECT 
    c.custid AS Customer_ID,
    CONCAT(c.fname, ' ', c.lname) AS Customer_fullname,
    pm.expirationdate
FROM
    customers c
        JOIN
    paymentmethod pm ON c.custid = pm.custid
WHERE
    YEAR(pm.expirationdate) >= 2028
ORDER BY 3 DESC , 2 ASC;

# 14. Display Average Revenue generated from each city. Rank city based on average revenue.

WITH CityRevenue AS (
    SELECT 
        pm.city AS City,
        ROUND(AVG(ph.paymentamount), 2) AS Avg_Revenue
    FROM paymentmethod AS pm
    JOIN paymenthistory AS ph 
        ON pm.cardid = ph.cardid
    GROUP BY pm.city
)
SELECT 
    City,
    Avg_Revenue,
    dense_RANK() OVER (ORDER BY Avg_Revenue DESC) AS City_Rank
FROM CityRevenue;


# 15. Display most frequently viewed genre among adults for each category.

WITH AdultGenreViews AS (
    SELECT 
        c.category AS Category,
        c.genre AS Genre,
        COUNT(v.contentid) AS View_Count,
        DENSE_RANK() OVER (
            PARTITION BY c.category 
            ORDER BY COUNT(v.contentid) DESC
        ) AS Genre_Rank
    FROM content AS c
    JOIN viewinghistory AS v ON c.contentid = v.contentid
    JOIN profiles AS p ON v.profileid = p.profileid
    JOIN adultacc AS a ON p.profileid = a.profileid 
    GROUP BY c.category, c.genre
)
SELECT 
    Category,
    Genre,
    View_Count
FROM AdultGenreViews
WHERE Genre_Rank = 1;





