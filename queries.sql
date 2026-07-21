-- view all statuses for project
SELECT id, name AS "Project Status"
FROM project_status;

-- view all system users
SELECT id, name AS "Name", role AS "User Role"
FROM users;

-- view all possible statuses for defects
SELECT id, name AS "Defect Status"
FROM defect_status;

-- view information about each project managed by the system
-- EXPLAIN QUERY PLAN
SELECT projects.id, projects.name AS "Project", description AS "Description", project_status.name AS "Project Status"
FROM projects
JOIN project_status ON project_status.id = projects.status_id
WHERE status_id = 2;

-- view requirements that define the features or business rules that need to be tested
-- EXPLAIN QUERY PLAN
SELECT projects.id, projects.name AS "Project Name", code AS "Code", title AS "Requirement Title", requirements.description AS "Requirement Description"
FROM requirements
JOIN projects ON requirements.project_id = projects.id
WHERE requirements.id = 2;

-- view all groups of related test cases
-- EXPLAIN QUERY PLAN
SELECT project_id AS "Project ID", projects.name AS "Project Name", test_suites.id AS "Test Suite ID", test_suites.name AS "Test Suite Name", test_suites.description AS "Test Suite Description"
FROM test_suites
JOIN projects ON test_suites.project_id = projects.id;

-- view system requirements associated with test suites
-- EXPLAIN QUERY PLAN
SELECT test_suites.name AS "Test Suite Name", requirements.title AS "Requirement Name", test_cases.title AS "Title", steps as "Steps", priority AS "Priority"
FROM test_cases
JOIN test_suites  ON test_cases.test_suite_id  = test_suites.id
JOIN requirements ON test_cases.requirement_id = requirements.id;

-- view problems identified during test execution
-- EXPLAIN QUERY PLAN
SELECT defects.id, defects.title AS "Title", defects.description AS "Description", test_cases.title AS "Test Case",
    defects.severity AS "Severity", defects.priority AS "Priority", defect_status.name AS "Defect Status",
    reported_by.name AS "Reported By", COALESCE(assigned_to.name, 'Unassigned') AS "Assigned To"
FROM defects
JOIN test_cases                ON defects.test_case_id = test_cases.id
JOIN defect_status             ON defects.status_id = defect_status.id
JOIN users AS reported_by      ON defects.reported_by = reported_by.id
LEFT JOIN users AS assigned_to ON defects.assigned_to = assigned_to.id;

-- view history of test case executions
-- EXPLAIN QUERY PLAN
SELECT test_executions.id, test_cases.title AS "Test Case", users.name AS "Executed By", test_executions.execution_date AS "Execution Date",
       test_executions.status AS "Execution Status", test_executions.notes AS "Execution Notes"
FROM test_executions
JOIN test_cases ON test_executions.test_case_id = test_cases.id
JOIN users      ON test_executions.executed_by = users.id;

-- view all test cases for each project
-- EXPLAIN QUERY PLAN
SELECT projects.name AS "Project", test_suites.name AS "Test Suite", test_cases.title AS "Test Case", test_cases.priority AS "Priority"
FROM test_cases
JOIN test_suites ON test_cases.test_suite_id = test_suites.id
JOIN projects    ON test_suites.project_id   = projects.id;

-- view requirement test coverage for a specific project
-- EXPLAIN QUERY PLAN
SELECT requirements.code AS "Requirement Code", requirements.title AS "Requirement Title", COUNT(test_cases.id) AS "Number of Test Cases"
FROM requirements
LEFT JOIN test_cases ON requirements.id = test_cases.requirement_id
WHERE requirements.project_id = 1
GROUP BY requirements.id, requirements.code, requirements.title;

-- view test execution summary for a specific project
-- EXPLAIN QUERY PLAN
SELECT test_executions.status AS "Execution Status", COUNT(*) AS "Total Executions"
FROM  test_executions
JOIN  test_cases  ON test_executions.test_case_id = test_cases.id
JOIN  test_suites ON test_cases.test_suite_id = test_suites.id
WHERE test_suites.project_id = 1
GROUP BY test_executions.status;

-- view test cases that have not been executed for a specific project
-- EXPLAIN QUERY PLAN
SELECT test_cases.id AS "Test Case ID", test_cases.title AS "Test Case", test_suites.name AS "Test Suite", test_cases.priority AS "Priority"
FROM test_cases
JOIN test_suites          ON test_cases.test_suite_id = test_suites.id
LEFT JOIN test_executions ON test_cases.id = test_executions.test_case_id
WHERE test_suites.project_id = 1 AND test_executions.id IS NULL;

-- view requirements without test cases for a specific project
-- EXPLAIN QUERY PLAN
SELECT requirements.id AS "Requirement ID", requirements.code AS "Requirement Code", requirements.title AS "Requirement Title"
FROM requirements
LEFT JOIN test_cases ON requirements.id = test_cases.requirement_id
WHERE requirements.project_id = 1 AND test_cases.id IS NULL;

-- view all non-closed defects
-- EXPLAIN QUERY PLAN
SELECT defects.id, defects.title AS "Defect Title", severity AS "Severity", priority AS "Priority", defect_status.name AS "Status"
FROM defects
JOIN defect_status ON defects.status_id = defect_status.id
WHERE defect_status.name <> 'Closed';

-- view defects grouped by severity
-- EXPLAIN QUERY PLAN
SELECT defects.severity AS "Severity", COUNT(*) AS "Total Defects"
FROM defects
JOIN test_cases  ON defects.test_case_id = test_cases.id
JOIN test_suites ON test_cases.test_suite_id = test_suites.id
WHERE test_suites.project_id = 1
GROUP BY defects.severity;
