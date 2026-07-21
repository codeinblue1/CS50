PRAGMA foreign_keys = ON;

-- possible status that a project can have during its lifecycle
CREATE TABLE project_status (
    id   INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- information about system users
CREATE TABLE users (
    id   INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('Project Manager', 'QA Analyst', 'Developer'))
);

-- possible statuses for defects
CREATE TABLE defect_status (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- information about each project managed by the system
CREATE TABLE projects (
    id          INTEGER PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    description TEXT,
    status_id   INTEGER NOT NULL,
    FOREIGN KEY (status_id) REFERENCES project_status(id)
);

-- requirements that define the features or business rules that need to be tested
CREATE TABLE requirements (
    id          INTEGER PRIMARY KEY,
    project_id  INTEGER NOT NULL,
    code        TEXT NOT NULL,
    title       TEXT NOT NULL,
    description TEXT,
    FOREIGN KEY (project_id) REFERENCES projects(id),
    UNIQUE(project_id, code)
);

-- groups of related test cases
CREATE TABLE test_suites (
    id          INTEGER PRIMARY KEY,
    project_id  INTEGER NOT NULL,
    name        TEXT NOT NULL,
    description TEXT,
    FOREIGN KEY (project_id) REFERENCES projects(id)
);

-- test cases used to validate system requirements
CREATE TABLE test_cases (
    id             INTEGER PRIMARY KEY,
    test_suite_id  INTEGER NOT NULL,
    requirement_id INTEGER NOT NULL,
    title          TEXT NOT NULL,
    steps          TEXT NOT NULL,
    priority       TEXT NOT NULL CHECK(priority IN ('High', 'Medium', 'Low')),
    FOREIGN KEY    (test_suite_id)  REFERENCES test_suites(id),
    FOREIGN KEY    (requirement_id) REFERENCES requirements(id)
);

-- problems identified during test execution
CREATE TABLE defects (
    id           INTEGER PRIMARY KEY,
    test_case_id INTEGER NOT NULL,
    title        TEXT NOT NULL,
    description  TEXT,
    reported_by  INTEGER NOT NULL,
    assigned_to  INTEGER,
    severity     TEXT NOT NULL CHECK(severity IN ('Critical', 'High', 'Medium', 'Low')),
    priority     TEXT NOT NULL CHECK(priority IN ('High', 'Medium', 'Low')),
    status_id    INTEGER NOT NULL,
    created_at   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY  (test_case_id) REFERENCES test_cases(id),
    FOREIGN KEY  (reported_by)  REFERENCES users(id),
    FOREIGN KEY  (assigned_to)  REFERENCES users(id),
    FOREIGN KEY  (status_id)    REFERENCES defect_status(id)
);

-- the history of test case executions
CREATE TABLE test_executions (
    id             INTEGER PRIMARY KEY,
    test_case_id   INTEGER NOT NULL,
    executed_by    INTEGER NOT NULL,
    execution_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes          TEXT,
    status         TEXT NOT NULL CHECK(status IN ('Pass', 'Fail', 'Blocked')),
    FOREIGN KEY    (test_case_id) REFERENCES test_cases(id),
    FOREIGN KEY    (executed_by)  REFERENCES users(id)
);

-- trigger
CREATE TRIGGER update_defect_timestamp
AFTER UPDATE OF
    test_case_id, title, description, reported_by, assigned_to, severity, priority, status_id
ON defects
FOR EACH ROW
BEGIN
    UPDATE defects
    SET updated_at = CURRENT_TIMESTAMP
    WHERE id = OLD.id;
END;

-- indexes
CREATE INDEX idx_projects_status_id           ON projects(status_id);
CREATE INDEX idx_requirements_project_id      ON requirements(project_id);
CREATE INDEX idx_test_suites_project_id       ON test_suites(project_id);
CREATE INDEX idx_test_cases_test_suite_id     ON test_cases(test_suite_id);
CREATE INDEX idx_test_cases_requirement_id    ON test_cases(requirement_id);
CREATE INDEX idx_test_cases_priority          ON test_cases(priority);
CREATE INDEX idx_defects_test_case_id         ON defects(test_case_id);
CREATE INDEX idx_defects_status_id            ON defects(status_id);
CREATE INDEX idx_defects_assigned_to          ON defects(assigned_to);
CREATE INDEX idx_defects_reported_by          ON defects(reported_by);
CREATE INDEX idx_defects_severity             ON defects(severity);
CREATE INDEX idx_test_executions_test_case_id ON test_executions(test_case_id);
CREATE INDEX idx_test_executions_executed_by  ON test_executions(executed_by);
CREATE INDEX idx_test_executions_status       ON test_executions(status);

-- inserting data
INSERT INTO project_status (name) VALUES
('Planning'),
('Active'),
('On Hold'),
('Completed'),
('Cancelled'),
('Archived');

INSERT INTO users (id, name, role) VALUES
(1, 'Ann Perry',      'Project Manager'),
(2, 'Simone Johnson', 'QA Analyst'),
(3, 'David Robson',   'Developer');

INSERT INTO defect_status (id, name) VALUES
(1, 'Open'),
(2, 'In Progress'),
(3, 'Resolved'),
(4, 'Closed');

INSERT INTO projects (id, name, description, status_id) VALUES
(1, 'Online Banking System', 'System to manage transactions on bank accounts', 2),
(2, 'E-commerce System',     'Platform for online purchases', 1);

INSERT INTO requirements (id, project_id, code, title, description) VALUES
(1, 1, 'REQ-001', 'User Login',      'The system must allow users to log in'),
(2, 1, 'REQ-002', 'Account Balance', 'The system must display account balance'),
(3, 2, 'REQ-001', 'Product Search',  'The system must allow users to search products');

INSERT INTO test_suites (id, project_id, name, description) VALUES
(1, 1, 'Authentication Tests', 'Tests related to user authentication'),
(2, 1, 'Account Tests',        'Tests related to account features'),
(3, 2, 'Shopping Tests',       'Tests related to shopping features');

INSERT INTO test_cases
(id, test_suite_id, requirement_id, title, steps, priority)
VALUES
(1, 1, 1, 'Validate successful login',        '1. Enter valid username. 2. Enter valid password. 3. Click login.', 'High'),
(2, 1, 1, 'Validate invalid login',           '1. Enter invalid credentials. 2. Click login.',                     'Medium'),
(3, 2, 2, 'Validate account balance display', '1. Login. 2. Open account page. 3. Verify balance.',                'High'),
(4, 3, 3, 'Search products',                  '1. Enter product name. 2. Click search. 3. Verify results.',        'Low');

INSERT INTO defects
(id, test_case_id, title, description, reported_by, assigned_to, severity, priority, status_id, created_at, updated_at)
VALUES
(1, 2, 'Invalid login does not show error message', 'System allows login attempt without displaying an error message', 2, 3, 'High',   'High', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 4, 'Search returns incorrect products',         'Some unrelated products are displayed in search results',         2, 3, 'Medium', 'Low',  2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO test_executions
(id, test_case_id, executed_by, execution_date, notes, status)
VALUES
(1, 1, 2, CURRENT_TIMESTAMP, 'Login worked correctly',             'Pass'),
(2, 2, 2, CURRENT_TIMESTAMP, 'Error message not displayed',        'Fail'),
(3, 3, 2, CURRENT_TIMESTAMP, 'Balance displayed correctly',        'Pass'),
(4, 4, 2, CURRENT_TIMESTAMP, 'Search returned incorrect products', 'Fail');
