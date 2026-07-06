# PGUnit User Manual

Unit Testing for PostgreSQL

## Get PGUnit Source Code

Download production source files, utilities, and sample code directly to your local development workspace.

[Download Repository](https://github.com/DigitalDimensions72/PGUnit)

---

## Manual Index

1. [Introduction to PGUnit](https://www.google.com/search?q=%231-introduction-to-pgunit)
2. [Installing PGUnit](https://www.google.com/search?q=%232-installing-pgunit)
3. [Explaining the Structure of a PGUnit Test Case](https://www.google.com/search?q=%233-explaining-the-structure-of-a-pgunit-test-case)
4. [Running PGUnit Tests](https://www.google.com/search?q=%234-running-pgunit-tests)
5. [Reading PGUnit Results](https://www.google.com/search?q=%235-reading-pgunit-results)
6. [PGUnit Utility Functions](https://www.google.com/search?q=%236-pgunit-utility-functions)
7. [Contact the Developer](https://www.google.com/search?q=%237-contact-the-developer)

---

## 1. Introduction to PGUnit

I developed PGUnit as a unit testing tool that is simple to install and use in PostgreSQL. It consists of a set of database functions designed to help developers validate database logic efficiently.

### Files for PGUnit

The system includes the following core and supporting files:

* **PGUnit.SQL**: The core source code for the system.
* **PGUnitUtils.sql**: Utility functions for PGUnit.
* **Sample/StudentsDatabase.sql**: The test database used to demonstrate how the system works.
* **Sample/StudentsDatabaseTestCases.sql**: The test cases for the student database.
* **Sample/PGUnitTests.sql**: The test cases used to test PGUnit itself.

---

## 2. Installing PGUnit

To install PGUnit, execute the following steps:

1. Open the file called `PGUnit.SQL` in an editor like Notepad.
2. Copy all of the code.
3. Open your preferred **SQL Client**.
4. Open an SQL Window.
5. Paste the PGUnit code into the SQL Window.
6. Run the PGUnit source code.

Upon successful execution, you will see a query completion notice in the messages pane. Refreshing your SQL Client object browser will reveal a brand-new schema named pgunit.

### Installing PGUnit Examples & Samples

#### 1. StudentsDatabase.sql

**Purpose:** This file builds the core schema, mock tables, and business logic for a simulated student database. It acts as the reference codebase used to safely demonstrate how PGUnit operates.

**Installation:** Open `Sample/StudentsDatabase.sql` in Notepad, copy all of the code, paste it into an open SQL Client window, and execute it.

#### 2. StudentsDatabaseTestCases.sql

**Purpose:** This script installs the suite of functional test cases for the sample student database. It provides real-world examples of how to construct test functions, write assertions, and properly organise test blocks using the PGUnit markup syntax.

**Installation:** Open `Sample/StudentsDatabaseTestCases.sql` in Notepad, copy the entire block of code, paste it into your SQL Client window, and run it to install the test functions.

#### 3. PGUnitTests.sql

**Purpose:** This script contains the internal test suite used to test PGUnit itself. The tests are run directly against the PGUnit code, serving as a comprehensive verification layer to guarantee the framework is operating correctly.

**Installation:** Open `Sample/PGUnitTests.sql` in Notepad, copy all of the code, paste it into an SQL window within your SQL Client, and execute it.

---

## 3. Explaining the Structure of a PGUnit Test Case

All PGUnit unit tests follow a strictly defined baseline structure. The name of the test function **must** start with `test_` and follow the structure outlined below:

```sql
CREATE OR REPLACE FUNCTION pgunittests.test_one_setup_no_test_sections()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        --@Rollback(TRUE/FALSE/T/F/YES/NO/Y/N)
        --@ExitOnFailFirstTest(TRUE/FALSE/T/F/YES/NO/Y/N)
        --@setup([description=<a description of the test>])
        --@test(description=<a description of the test>)
    $$);
$body$
LANGUAGE sql;

```

### The Importance of `SELECT pgunit.testcase($$...$$);`

Calling the `pgunit.testcase` wrapper with dollar-quoted strings is a crucial structural requirement. This block allows PGUnit to successfully extract, parse, and evaluate the specific blocks that make up your test cases.

### Test Markup and Sections

PGUnit has a specific markup that it uses to identify sections of your test cases:

* **`--@variables`**: If your test code uses variables, define those variables inside this section. This tag can only appear **once** per test function.
* **`--@Rollback(TRUE/FALSE/T/F/YES/NO/Y/N)`**: This tells PGUnit if it must rollback data modifications applied during test execution. If set to `TRUE`, `T`, `YES`, or `Y`, the system automatically rolls back every modification made during the execution of the test cases in the function. Conversely, if configured to `FALSE`, `F`, `NO`, or `N`, modifications persist. If omitted entirely, it defaults to **`TRUE`**. This tag can only appear **once** per test function.
* **`--@ExitOnFailFirstTest(TRUE/FALSE/T/F/YES/NO/Y/N)`**: Controls abort mechanics when multiple consecutive test sections reside in a single test function. If it is set to `TRUE`, `T`, `YES`, or `Y`, execution terminates the moment a test case in the function fails. If `FALSE`, `F`, `NO`, or `N` the tests continue to execute regardless of early validation errors. If unspecified, it defaults to **`FALSE`**. This tag can only appear **once** per test function.
* **`--@setup([description=<a description of the test>])`**: Contains all of the setup code that your test cases require. The `description` parameter is entirely optional. This tag can only appear **once** per test function.
* **`--@test(description=<a description of the test>)`**: Defines Test case. Multiple test blocks may be specified in a test function to cleanly support test suites. Every test block **must** provide a `description` and you must supply a minimum of one active test section per test function.

---

## 4. Running PGUnit Tests

PGUnit uses the `pgunit.testrunner` function to execute test functions. This locates test functions, executes them and formats test results to closely replicate traditional XUnit layout conventions.

### Function Parameters

* **Schema Name** : The specific database schema containing target test functions.
* **Test Case Function Name** : The exact target function name to execute. Passing only the schema name automatically executes all tests functions discovered in the specified schema.

### Example 1: Running a Single Test

Run this statement directly inside your SQL Client to execute a specific test function:

```sql
SELECT * FROM pgunit.testrunner('pgunittraining', 'test_boundary_pass_result');

```

### Example 2: Running Multiple Tests

Execute this statement to scan, collect, and automatically run every test case function declared within the specified schema:

```sql
SELECT * FROM pgunit.testrunner('pgunittraining');

```

---

## 5. Reading PGUnit Results

PGUnit provides two sets of test result information to your SQL Client:

1. **The Test Results Table**: This lists the number of test functions executed, the total number of test cases that are available, the number of test cases that were not executed and the number of test cases that passed/failed.
2. **The Messages/Notice Information**: Provides more information about the test cases that were executed.

### The Test Results Table

| test_case_functions | tests_cases | tests_cases_not_run | passed | failed |
| --- | --- | --- | --- | --- |
| 15 | 36 | 0 | 33 | 3 |

* **`test_case_functions`**: The number of test case functions executed.
* **`tests_cases`**: The total number of test cases contained across those functions.
* **`tests_cases_not_run`**: The total number of test cases that haven't been run (for instance, skipped due to exit abort flags).
* **`passed`**: The number of test cases that have successfully passed validation.
* **`failed`**: The number of test cases that have failed validation.

---

## 6. PGUnit Utility Functions

The following utility function is used to handle table comparisons.

### `PGUnitUtils.compare_tables`

**Description:** Check to see if two tables contain matching content.

**Parameters:**

* `in_expected` : The name of the table containing the expected values.
* `in_actual` : The name of the table containing the actual values.

**Example Syntax:**

```sql
SELECT * FROM PGUnitUtils.compare_tables('temp.expected_studentsgrades', 'temp.actual_studentsgrades');

```

---

## 7. Contact the Developer

If you have questions, feedback, or require deployment support for PGUnit, feel free to get in touch:

* **Developer:** John Clarke
* **Email:** [jclarke@digitaldimensions.co.uk](https://www.google.com/search?q=mailto%3Ajclarke%40digitaldimensions.co.uk)
* **Website:** [www.digitaldimensions.co.uk](https://www.digitaldimensions.co.uk)
