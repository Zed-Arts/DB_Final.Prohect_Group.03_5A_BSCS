-- ====================================================================
-- SYSTEM NAME: HUMAN RESOURCE MANAGEMENT SYSTEM (HRMS)
-- UNIVERSITY: THE UNIVERSITY OF LAHORE (SPRING 2026)
-- COURSE: DATABASE SYSTEMS (CS LAB PROJECT)
-- INSTRUCTOR: MS. AMBREEN AKMAL
-- ====================================================================

-- ====================================================================
-- DDL & DCL: DATABASE CREATION & SECURITY ACCESS CONTROL
-- ====================================================================
DROP DATABASE IF EXISTS HRM_System;
CREATE DATABASE HRM_System;
USE HRM_System;

-- FEATURE 10 (Part 1): Data Control Language (DCL) Setup
-- Creating distinct enterprise database user roles for administrative security
CREATE USER IF NOT EXISTS 'hrm_admin'@'localhost' IDENTIFIED BY 'AdminPass2026!';
CREATE USER IF NOT EXISTS 'hrm_manager'@'localhost' IDENTIFIED BY 'ManagerPass2026!';

-- Granting explicit schema-level privileges to users
GRANT ALL PRIVILEGES ON HRM_System.* TO 'hrm_admin'@'localhost';
GRANT SELECT, INSERT, UPDATE ON HRM_System.Attendance TO 'hrm_manager'@'localhost';
GRANT SELECT, INSERT, UPDATE ON HRM_System.Leave_Request TO 'hrm_manager'@'localhost';
FLUSH PRIVILEGES;

-- ====================================================================
-- DDL SCHEMA: TABLES WITH AUTO_INCREMENT, KEYS, & CONSTRAINTS
-- ====================================================================

CREATE TABLE Department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(50) NOT NULL
);

CREATE TABLE Job (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    job_title VARCHAR(50) NOT NULL UNIQUE,
    base_salary DECIMAL(10,2) NOT NULL CHECK (base_salary >= 0)
);

CREATE TABLE Employee (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    phone VARCHAR(15),
    hire_date DATE NOT NULL,
    department_id INT,
    job_id INT,
    FOREIGN KEY (department_id) REFERENCES Department(department_id) ON DELETE SET NULL,
    FOREIGN KEY (job_id) REFERENCES Job(job_id) ON DELETE SET NULL
);

CREATE TABLE Attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    date DATE NOT NULL,
    status VARCHAR(10) NOT NULL CHECK (status IN ('Present', 'Absent', 'Late', 'Leave')),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE CASCADE,
    CONSTRAINT UNIQUE_employee_attendance_date UNIQUE (employee_id, date)
);

CREATE TABLE Leave_Request (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected')),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE CASCADE
);

CREATE TABLE Payroll (
    payroll_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    month VARCHAR(20) NOT NULL,
    year INT NOT NULL,
    basic_salary DECIMAL(10,2) NOT NULL CHECK (basic_salary >= 0),
    bonus DECIMAL(10,2) DEFAULT 0.00 CHECK (bonus >= 0),
    deductions DECIMAL(10,2) DEFAULT 0.00 CHECK (deductions >= 0),
    net_salary DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE CASCADE
);

-- ====================================================================
-- AUTOMATION LAYER: DATABASE TRIGGERS (COMPUTATIONAL INTEGRITY)
-- ====================================================================
DELIMITER $$

-- Automatically compute Net Salary before dynamic Insertion
CREATE TRIGGER trg_calculate_net_salary_insert
BEFORE INSERT ON Payroll
FOR EACH ROW
BEGIN
    SET NEW.net_salary = NEW.basic_salary + NEW.bonus - NEW.deductions;
END $$

-- Automatically re-compute Net Salary if metrics change during an Update operation
CREATE TRIGGER trg_calculate_net_salary_update
BEFORE UPDATE ON Payroll
FOR EACH ROW
BEGIN
    SET NEW.net_salary = NEW.basic_salary + NEW.bonus - NEW.deductions;
END $$

DELIMITER ;

-- ====================================================================
-- DML: SAMPLE DATA POPULATION
-- ====================================================================

INSERT INTO Department (department_name, location) VALUES 
('IT', 'Karachi'),
('HR', 'Lahore'),
('Finance', 'Islamabad');

INSERT INTO Job (job_title, base_salary) VALUES 
('Software Engineer', 80000.00),
('HR Manager', 60000.00),
('Financial Analyst', 75000.00);

INSERT INTO Employee (name, email, phone, hire_date, department_id, job_id) VALUES 
('Ali', 'ali@email.com', '03001234567', '2023-01-01', 1, 1),
('Ahmed', 'ahmed@email.com', '03111234567', '2023-02-01', 2, 2),
('Sana', 'sana@email.com', '03211234567', '2024-05-15', 1, 1),
('Bilal', 'bilal@email.com', '03331234567', '2025-08-20', 3, 3);

INSERT INTO Attendance (employee_id, date, status) VALUES 
(1, '2026-05-01', 'Present'),
(1, '2026-05-02', 'Absent'),
(2, '2026-05-01', 'Present'),
(2, '2026-05-02', 'Present'),
(3, '2026-05-01', 'Present'),
(3, '2026-05-02', 'Late');

INSERT INTO Leave_Request (employee_id, start_date, end_date, status) VALUES 
(1, '2026-05-10', '2026-05-12', 'Pending'),
(2, '2026-06-01', '2026-06-05', 'Approved'),
(1, '2026-04-15', '2026-04-16', 'Rejected');

INSERT INTO Payroll (employee_id, month, year, basic_salary, bonus, deductions) VALUES 
(1, 'May', 2026, 80000.00, 5000.00, 2000.00),
(2, 'May', 2026, 60000.00, 2000.00, 1000.00),
(3, 'May', 2026, 80000.00, 0.00, 1500.00);


-- ====================================================================
-- EXECUTION OF THE 10 SPECIFIC FUNCTIONAL SYSTEM FEATURES
-- ====================================================================

-- FEATURE 1: Add a New Employee to the System (Onboarding Process)
-- Type: Insert (DML)
INSERT INTO Employee (name, email, phone, hire_date, department_id, job_id) 
VALUES ('Zainab', 'zainab@email.com', '03451234567', '2026-06-01', 2, 2);


-- FEATURE 2: Update Employee Department upon Internal Transfer
-- Type: Update (DML)
UPDATE Employee 
SET department_id = 1 
WHERE employee_id = 4;


-- FEATURE 3: Clean De-provisioning of a Terminated Employee Record
-- Type: Delete (DML)
-- Note: Demonstrates structural safety using relational ON DELETE cascades.
DELETE FROM Employee 
WHERE employee_id = 5;


-- FEATURE 4: Comprehensive Search & Directory Listing Filtered by Criteria
-- Type: Multi-Join Search Filter (DML)
SELECT e.employee_id, e.name, d.department_name, j.job_title, e.email
FROM Employee e
INNER JOIN Department d ON e.department_id = d.department_id
INNER JOIN Job j ON e.job_id = j.job_id
WHERE d.department_name = 'IT' OR j.job_title LIKE '%Manager%';


-- FEATURE 5: Real-time Payroll Valuation & Department Financial Reporting
-- Type: Advanced Aggregation & Grouping (DML)
SELECT d.department_name, 
       COUNT(p.employee_id) AS total_paid_employees,
       SUM(p.net_salary) AS gross_departmental_payout,
       AVG(p.net_salary) AS average_salary_expenditure
FROM Payroll p
INNER JOIN Employee e ON p.employee_id = e.employee_id
INNER JOIN Department d ON e.department_id = d.department_id
GROUP BY d.department_name;


-- FEATURE 6: Strategic Identification of Highest Earner (Executive Metric)
-- Type: High-Performance Ordered Filter Optimization (DML)
SELECT e.name, d.department_name, j.job_title, p.net_salary
FROM Employee e
INNER JOIN Payroll p ON e.employee_id = p.employee_id
INNER JOIN Department d ON e.department_id = d.department_id
INNER JOIN Job j ON e.job_id = j.job_id
ORDER BY p.net_salary DESC
LIMIT 1;


-- FEATURE 7: Absenteeism & Leave Request Frequency Monitoring Tracker
-- Type: Grouped Conditional Metric Evaluation (DML)
SELECT e.name, COUNT(l.leave_id) AS total_requested_leaves
FROM Leave_Request l
INNER JOIN Employee e ON l.employee_id = e.employee_id
GROUP BY e.employee_id, e.name
HAVING total_requested_leaves >= 1;


-- FEATURE 8: System Metric Analyzer for Attendance Percentages
-- Type: Complex Numeric Aggregation Formulas (DML)
SELECT e.name,
       COUNT(a.attendance_id) AS total_tracked_days,
       ROUND((SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.attendance_id)), 2) AS attendance_percentage
FROM Attendance a
INNER JOIN Employee e ON a.employee_id = e.employee_id
GROUP BY e.employee_id, e.name;


-- FEATURE 9: Administrative Operational Approval Queue for Pending Leaves
-- Type: Specific Status Conditional Filter (DML)
SELECT l.leave_id, e.name, l.start_date, l.end_date, l.status
FROM Leave_Request l
INNER JOIN Employee e ON l.employee_id = e.employee_id
WHERE l.status = 'Pending';


-- FEATURE 10 (Part 2): Revoke System Security Privileges (Access Audit)
-- Type: Database Control Language (DCL) Command Execution
REVOKE UPDATE ON HRM_System.Leave_Request FROM 'hrm_manager'@'localhost';