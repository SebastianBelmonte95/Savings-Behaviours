DROP TABLE IF EXISTS catalog_table
-- Creating catalog table
CREATE TABLE catalog_table(
	catalog_id TEXT,
	catalog_name TEXT,
	catalog_type TEXT
)

--------- Importing data from a single CSV file into the DB ---------
COPY catalog_table(catalog_id, catalog_name, catalog_type) 
FROM 'D:\Google Drive\Professional Projects\Portfolio\Data Analysis\Comportamiento de Ahorradores\data\catalog.csv' 
DELIMITER ',' 
CSV HEADER;

DROP TABLE IF EXISTS test_projects
-- Creating projects table
CREATE TABLE test_projects(
	project_id TEXT,
	project_name TEXT,
	goal_date TIMESTAMP,
	user_id TEXT,
	project_category_id TEXT,
	project_total NUMERIC
)

--------- Importing data from a single CSV file into the DB ---------
COPY test_projects(project_id, project_name, goal_date, user_id, project_category_id, project_total) 
FROM 'D:\Google Drive\Professional Projects\Portfolio\Data Analysis\Comportamiento de Ahorradores\data\test_projects.csv' 
DELIMITER ',' 
CSV HEADER;
 
DROP TABLE IF EXISTS test_rules
-- Creating rules table
CREATE TABLE test_rules(
	rule_id TEXT,
	project_id TEXT,
	rule_type_id TEXT,
	amount NUMERIC,
	frequency NUMERIC,
	categories TEXT
)

--------- Importing data from a single CSV file into the DB ---------
COPY test_rules(rule_id, project_id, rule_type_id, amount, frequency, categories) 
FROM 'D:\Google Drive\Professional Projects\Portfolio\Data Analysis\Comportamiento de Ahorradores\data\test_rules.csv' 
DELIMITER ',' 
CSV HEADER;
 
DROP TABLE IF EXISTS transactions
-- Creating transactions table
CREATE TABLE transactions(
	user_id TEXT,
	description TEXT,
	t_date TIMESTAMP,
	amount NUMERIC
)
--------- Importing data from a single CSV file into the DB ---------
COPY transactions(user_id, description, t_date, amount) 
FROM 'D:\Google Drive\Professional Projects\Portfolio\Data Analysis\Comportamiento de Ahorradores\data\test_transactions.csv' 
DELIMITER ',' 
CSV HEADER;
 
-- Identify trends on project categories
SELECT catalog_name as category, SUM(project_total) AS category_sum, ROUND(AVG(project_total),2) AS average, ROUND((SUM(project_total) / SUM(SUM(project_total)) OVER ()) * 100, 2) AS "% of total", COUNT(*) AS project_num, ROUND((COUNT(*) / SUM(COUNT(*)) OVER ()) * 100, 2) AS "% of projects" 
FROM test_projects, catalog_table
WHERE project_category_id = catalog_id AND project_total < 1000000000 --1000M
GROUP BY catalog_name
ORDER BY SUM(project_total) DESC

-- Identify trends on rules
SELECT catalog_name as category, 
COUNT(*) AS total_transactions, ROUND((COUNT(*) / SUM(COUNT(*)) OVER ()) * 100, 2) AS "% of transactions",
SUM(amount) AS total_sum, ROUND((SUM(amount) / SUM(SUM(amount)) OVER ()) * 100, 2) AS "% of total_sum" ,
ROUND(AVG(amount),2) AS avg_sum
FROM test_rules, catalog_table
WHERE rule_type_id = catalog_id
GROUP BY  catalog_name
ORDER BY COUNT(*) DESC


-- Total users
SELECT count(DISTINCT user_id) FROM test_projects
-- Total Projects 
SELECT count(DISTINCT project_id) FROM test_projects

-- Time analysis: Goal date vs total amount
SELECT goal_date, SUM(project_total)
FROM test_projects
WHERE project_total < 9000000000 --1000M
GROUP BY goal_date 
ORDER BY goal_date ASC

-- Time series analysis: date vs Money spent
SELECT t_date, sum(amount)
FROM transactions
GROUP BY t_date
ORDER BY t_date ASC

