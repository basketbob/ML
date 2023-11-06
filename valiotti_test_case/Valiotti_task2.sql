SELECT ID,
       MAX(CASE WHEN Name = 'A' THEN Val END) AS A,
       MAX(CASE WHEN Name = 'B' THEN Val END) AS B,
       MAX(CASE WHEN Name = 'C' THEN Val END) AS C
FROM YourTableName
GROUP BY ID
order by ID;