CREATE DATABASE  marketing_ab_testing;

ALTER TABLE marketing_ab
RENAME COLUMN `user id` TO user_id ;

ALTER TABLE marketing_ab
RENAME COLUMN `test group` TO  test_group ;

ALTER TABLE marketing_ab
RENAME COLUMN `total ads` TO total_ads;

ALTER TABLE marketing_ab
RENAME COLUMN `most ads day` TO most_ads_day ;

ALTER TABLE marketing_ab
RENAME COLUMN `most ads hour` TO  most_ads_hour;

-- HOW MANY ROWS DO WE HAVE ?
SELECT COUNT(*) AS total_rows
FROM marketing_ab;

-- HOW MANY USERS SPLIT BETWEEN THE TWO GROUPS ?
SELECT 
test_group,
COUNT(*) AS Users,
ROUND(COUNT(*) * 100.0/ SUM(COUNT(*))OVER(),2) AS pct_of_total
FROM marketing_ab
GROUP BY test_group;


-- we say 96% of users are in the ad group and only 4% are in psa ,this is not a balanced experiment

-- Calculate conversion rates:
SELECT test_group,
COUNT(*) AS total_users,
SUM(CASE WHEN converted = 'True' THEN 1 ELSE 0 END) AS converted_users,
ROUND(
SUM(CASE WHEN converted = 'True' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2
) AS conversion_rate_pct
FROM marketing_ab
GROUP BY test_group;

-- validating the result
SELECT test_group,
COUNT(*) total_users,
SUM(converted='True') converted_users
FROM marketing_ab
GROUP BY test_group;
-- the ad group converted at 4.37% while the psa converted at 2.74% .
-- This represent a ~59.5% relative lift in conversions for users exposed to the ad.

-- ad Exposure
WITH stats AS (
	SELECT test_group,
		ROUND(AVG(total_ads),1) AS avg_ads_seen,
        MIN(total_ads) AS min_ads,
        MAX(total_ads) AS max_ads
    FROM marketing_ab
    GROUP BY test_group
),
med AS(
		SELECT test_group,
			AVG(total_ads) AS median_ads
        FROM (
        SELECT test_group,
               total_ads,
               ROW_NUMBER() OVER (PARTITION BY test_group ORDER BY total_ads) AS rn,
               COUNT(*) OVER (PARTITION BY test_group) AS cnt
        FROM marketing_ab
    ) x
    WHERE rn IN (FLOOR((cnt + 1)/2), FLOOR((cnt + 2)/2))
    GROUP BY test_group
)
SELECT s.test_group,
       s.avg_ads_seen,
       s.min_ads,
       s.max_ads,
       ROUND(m.median_ads,1) AS median_ads
FROM stats s
JOIN med m ON s.test_group = m.test_group;
--- Both group has average of 41.6 and median of 13 

-- conversion rate by ad volume
SELECT 
CASE 
	WHEN total_ads BETWEEN 1 AND 10 THEN '1-10 ads'
    WHEN total_ads BETWEEN 11 AND 50 THEN '11-50 ads'
    WHEN total_ads BETWEEN 51 AND 100  THEN '51-100 ads'
    ELSE '100+ ads'
    END AS ads_bucket,
    COUNT(*) AS users,
    ROUND(SUM(CASE WHEN converted= 'True' THEN 1 ELSE 0 END) * 100.0/COUNT(*),2) AS conversion_rate_pct
    FROM marketing_ab
    WHERE test_group ='ad'
    GROUP BY ads_bucket
    ORDER BY  MIN(total_ads); 
    ;
   -- conversion rates increases consistently with ad exposure -there is no drop=off at high volumes,
   -- users who saw 100 or more ads coverted at 16.54% compared to 0.84% for those who saw fewer than 10
   
   
-- FInd the best day and hour to show ads
-- which day of the week drives the most conversions
SELECT 
most_ads_day,
COUNT(*) AS users,
SUM(CASE WHEN converted ='True' THEN 1 ELSE 0 END)AS conversions,
ROUND(SUM(CASE WHEN converted ='True' THEN 1 ELSE 0 END) *100.0/COUNT(*),2) AS conversion_rate_pct
FROM marketing_ab
WHERE test_group ='ad'
GROUP BY most_ads_day
ORDER BY conversion_rate_pct DESC;

-- most_ads_hour
SELECT most_ads_hour,
COUNT(*) AS users,
SUM(CASE WHEN converted ='True' THEN 1 ELSE 0 END) AS conversions,
ROUND(SUM(CASE WHEN converted ='True' THEN 1 ELSE 0 END) *100.0/COUNT(*) ,2) AS conversion_rate_pct
FROM marketing_ab
WHERE test_group ='ad'
GROUP BY most_ads_hour
ORDER BY conversion_rate_pct DESC;


-- 1.  Monday has the most ads per day with 5.40% conversion rate and saturday the weakest at 3.83%.

-- 2.The top hours are 16:00 (5.44%) and 19:00 (4.88%), followed closely by 14:00 and 20:00. Mid-to-late afternoon
-- and early evening consistently outperform other time windows. 

-- summarise findings:
SELECT 
test_group,
COUNT(*) AS users,
SUM(CASE WHEN converted ='True' THEN 1 ELSE 0 END) AS conversions,
ROUND(SUM(CASE WHEN converted ='True' THEN 1 ELSE 0 END) *100.0/COUNT(*) ,2) AS conversion_rate_pct,
ROUND(avg(total_ads),1) AS avg_ads_seen
FROM marketing_ab
GROUP BY test_group;
