/* primary changes on the table */
ALTER TABLE employees.`employees details`
RENAME COLUMN `experienceMas.4` TO experience,
RENAME COLUMN qualificationMas TO primary_qualification,
RENAME COLUMN qualificationMas2 TO secondary_qualification;

/* deleting invaild details */
DELETE FROM employees.`employees details` WHERE candidateName REGEXP "^-";

/* arranging the employees based on the primary and secondary qualification */
ALTER TABLE employees.`employees details`
ADD id INT PRIMARY KEY AUTO_INCREMENT,
ORDER BY primary_qualification,secondary_qualification;

/* identification of candidate without education background */
CREATE TABLE employees.`candidates without degree qualification` AS
SELECT candidateName, companyName,id
FROM employees.`employees details`
WHERE primary_qualification IS NULL AND secondary_qualification IS NULL;

/* classification of employees of based on their education qualification and designation and company */
CREATE TABLE employees.`education category` AS SELECT primary_qualification,
    secondary_qualification,
    designation,
    companyName,
    COUNT(candidateName) AS employee_count,
    ROUND(AVG(salary), 2) AS average_salary_lakhs FROM
    employees.`employees details`
WHERE salary>= (SELECT AVG(salary) FROM employees.`employees details`) AND designation NOT LIKE'%Currently Unemployed%' AND companyName NOT LIKE'%Currently Unemployed%'
GROUP BY primary_qualification , secondary_qualification , designation,companyName
ORDER BY COUNT(candidateName) DESC;

/* classification of employees of based on their job roles */
CREATE TABLE employees.employees_based_work AS
SELECT 
    count(candidateName) AS candidate_count,
    designation,
    round(avg(salary),2) AS average_salary
FROM
    employees.`employees details`
WHERE
designation NOT LIKE '%Currently Unemployed%'
        AND designation NOT LIKE '%Fresher%'
        AND designation NOT LIKE '%retired%'
GROUP BY designation
ORDER BY candidate_count DESC,average_salary DESC;

/*classification of employees based on their education */
CREATE TABLE employees.employees_based_education AS
SELECT count(id),primary_qualification,secondary_qualification
FROM employees.`employees details`
WHERE NOT(primary_qualification IS NULL AND secondary_qualification IS NULL)
group BY primary_qualification,secondary_qualification
ORDER BY primary_qualification,secondary_qualification;

/* unemployed candidate details */
CREATE TABLE employees.`unemployed candidates` AS SELECT 
id,
candidateName,
    primary_qualification,
    secondary_qualification FROM
    employees.`employees details`
WHERE
    (designation IS NULL
        AND companyName IS NULL)
        OR designation LIKE '%Currently Unemployed%'
        OR designation LIKE '%Fresher%'
ORDER BY primary_qualification;

/*classification of job roles based on the salary*/
CREATE TABLE employees.`job roles in Hyderabad` AS SELECT designation,
    COUNT(candidateName) AS candidate_count,
    ROUND(AVG(salary), 2) AS average_salary,
    ROUND(AVG(experience), 2) AS average_experience FROM
    employees.`employees details`
WHERE
    designation IS NOT NULL
GROUP BY designation , salary , experience
ORDER BY salary DESC;

/* employees list having salary greater than average salary */
CREATE TABLE employees.`salary` AS 
SELECT id,candidateName,salary
FROM employees.`employees details`
WHERE salary >= (SELECT AVG(salary) FROM employees.`employees details`) AND (designation IS NOT NULL AND companyName IS NOT NULL)
ORDER BY salary;