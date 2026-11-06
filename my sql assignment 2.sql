-- Departments with fewer than 3 employees
SELECT d.department_id, d.department_name, COUNT(e.employee_id) AS emp_count
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) < 3;

-- Locations with female employees whose average age is below 30
SELECT l.location, AVG(e.age) AS avg_age
FROM employees e
JOIN location l ON e.location_id = l.location_id
WHERE e.gender = 'F'
GROUP BY l.location
HAVING AVG(e.age) < 30;

SELECT l.location, MAX(e.salary) AS max_salary
FROM employees e
JOIN location l ON e.location_id = l.location_id
GROUP BY l.location;