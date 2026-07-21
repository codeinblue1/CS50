# Test Case Management System

## Overview

The Test Case Management System is the final project developed for the CS50 SQL course from Harvard University, Summer 2026.

The Test Case Management System is a database project designed to help software testing teams organize and manage their testing activities.

The system allows users to manage projects, requirements, test suites, test cases, test executions, and defects in a structured database environment. The main goal of this project is to improve traceability between software requirements, test scenarios, execution results, and reported issues.

## Features

The system provides support for:

- Managing software projects and project status
- Storing and tracking system requirements
- Organizing test cases into test suites
- Defining test scenarios with execution steps and priority
- Recording test execution history
- Tracking defects found during testing
- Storing users involved in the testing process and their roles
- Monitoring test coverage and defect information

## Database Structure

The database contains the following main entities:

- **Projects:** Stores information about software projects and their current status.
- **Requirements:** Stores the features and business rules that need to be tested.
- **Test Suites:** Groups related test cases based on functionality or testing area.
- **Test Cases:** Defines the test scenarios, including steps and priority.
- **Test Executions:** Stores the history of executed tests, including the tester, execution date, result, and notes.
- **Defects:** Stores problems identified during testing, including severity, priority, status, reporter, and assigned user.
- **Users:** Stores information about people involved in the testing process and their roles.

![ER Diagram](ERDiagram.png)

## Technologies Used

- SQLite
- Entity Relationship Modeling
- Database Constraints
- SQL Queries
- Database Index Optimization

## Database Design

The database uses primary keys, foreign keys, and constraints to support data integrity and define the main relationships between entities. Some cross-entity business rules are documented as limitations of the current schema.

Indexes were added to improve the performance of common queries, especially searches involving foreign keys, project relationships, defects, and test execution history.

The database connects projects to their requirements and test suites. Test cases are associated with both requirements and test suites, and each test case can have multiple execution records and related defects.

This structure allows testing activities to be tracked from requirement definition and test case organization through test execution and defect management.

## Project Files

- `schema.sql` - Contains the database structure, table creation, constraints, and sample data.
- `queries.sql` - Contains SQL queries used to retrieve and analyze information from the database.
- `DESIGN.md` - Contains the detailed design documentation for the project.

## Example Use Cases

The database can be used to answer questions such as:

- Which requirements belong to each project?
- Which test cases are related to each requirement?
- Which tests were executed and what were the results?
- Which defects were identified during testing?
- Who reported a defect and who is responsible for resolving it?
- What is the current status of testing activities?

## Future Improvements

Possible improvements for this system include:

- Creating a web-based interface
- Adding user authentication and permissions
- Integrating automated testing tools
- Creating dashboards with testing metrics
- Adding test case version control

## Author

Created by Rosangela Lima
