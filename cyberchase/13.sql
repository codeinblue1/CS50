--In 13.sql, write a SQL query to explore a question of your choice.
--This query should: Involve at least one condition, using WHERE with AND or OR
SELECT id, title, topic, season
FROM episodes
WHERE topic IS NOT NULL
AND season BETWEEN 5 AND 8;
