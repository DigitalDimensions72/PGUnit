-- ====================================================================
-- Tool Name: PGUnitTests.sql
-- Description: A set of PGUnit test cases that test PGUnit
--
-- Copyright (c) 2026, John Clarke
-- Licensed under the PostgreSQL License. 
-- See the LICENSE file in the project root for full license text.
-- ====================================================================

--- Create the Schema
DROP SCHEMA if exists PGUnitTests CASCADE;
CREATE SCHEMA PGUnitTests AUTHORIZATION postgres;
COMMENT ON SCHEMA PGUnitTests IS 'Tests for PGUnit';

---
--- Utility Functions for PGUnit
---

--- Function to obtain the testable section of the testcode function
CREATE OR REPLACE FUNCTION pgunittests.get_testable_generated_code(test_function_name TEXT)
RETURNS TEXT
AS
$body$
DECLARE
    test_function_details RECORD;
    actual_test_code TEXT;
    extracted_declaration_block TEXT;
BEGIN
    -- 1. Get the generated code
    SELECT * INTO test_function_details 
    FROM pgunit.generate_testcase_code(test_function_name);

    actual_test_code = test_function_details.v_generated_code;

    -- 2. Extract from 'DECLARE' up to '$CODEBODY$'
    -- The regex pattern '(DECLARE.*?)(\$CODEBODY\$)' captures everything starting from DECLARE 
    -- up to, but not including, the first $CODEBODY$ tag.
    extracted_declaration_block := substring(actual_test_code from '(DECLARE.*?)(\$CODEBODY\$)');

    -- Trim any trailing/leading whitespaces or newlines if needed
    extracted_declaration_block := trim(extracted_declaration_block);

    --- Return the extracted code 
    RETURN extracted_declaration_block;

END;
$body$
LANGUAGE plpgsql;

---
--- Tests to check that the Validation System is working
---

--- Test for where there are no test sections at all
CREATE OR REPLACE FUNCTION pgunittests.test_zero_test_sections()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
    $$);
$body$
LANGUAGE sql;


--- Test where there is 1 setup section and no tests
CREATE OR REPLACE FUNCTION pgunittests.test_one_setup_no_test_sections()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@setup()
    $$);
$body$
LANGUAGE sql;

--- Test where there is 2 setup sections and no tests
CREATE OR REPLACE FUNCTION pgunittests.test_two_setup_no_test_sections_no_parameters()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@setup
        --@setup
    $$);
$body$
LANGUAGE sql;

--- Test where there is 2 setup sections and no tests
CREATE OR REPLACE FUNCTION pgunittests.test_two_setup_no_test_sections_and_parameters()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@setup()
        --@setup()
    $$);
$body$
LANGUAGE sql;

--- Test tag with no parameters therefore no description
CREATE OR REPLACE FUNCTION pgunittests.test_tag_no_parameters()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test
    $$);
$body$
LANGUAGE sql;

--- Test tag with () but no description
CREATE OR REPLACE FUNCTION pgunittests.test_parameters_no_description()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test()
    $$);
$body$
LANGUAGE sql;

--- Test tag with empty description
CREATE OR REPLACE FUNCTION pgunittests.test_with_empty_description()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test(description=   )
    $$);
$body$
LANGUAGE sql;

--- Test with multiple variables sections with no parameters
CREATE OR REPLACE FUNCTION pgunittests.test_with_multiple_variables_no_parameters()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        --@variables
        --@test(description=Test with multiple variables sections with no parameters)
    $$);
$body$
LANGUAGE sql;

--- Test with multiple variables sections and parameters
CREATE OR REPLACE FUNCTION pgunittests.test_with_multiple_variables_and_parameters()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables()
        --@variables()
        --@test(description=Test with multiple variables sections and parameters)
    $$);
$body$
LANGUAGE sql;

--- Test with multiple rollback sections with no parameters
CREATE OR REPLACE FUNCTION pgunittests.test_with_multiple_rollback_no_parameters()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@rollback
        --@rollback
        --@test(description=Test with multiple rollback sections with no parameters)
    $$);
$body$
LANGUAGE sql;

--- Test with multiple rollback sections and parameters
CREATE OR REPLACE FUNCTION pgunittests.test_with_multiple_rollback_and_parameters()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@rollback()
        --@rollback()
        --@test(description=Test with multiple rollback sections and parameters)
    $$);
$body$
LANGUAGE sql;

--- Test with multiple ExitOnFailFirstTest sections with no parameters
CREATE OR REPLACE FUNCTION pgunittests.test_with_multiple_exitonfailfirsttest_no_parameters()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@ExitOnFailFirstTest
        --@ExitOnFailFirstTest
        --@test(description=Test with multiple ExitOnFailFirstTest sections with no parameters)
    $$);
$body$
LANGUAGE sql;

--- Test with multiple ExitOnFailFirstTest sections with parameters
CREATE OR REPLACE FUNCTION pgunittests.test_with_multiple_exitonfailfirsttest_and_parameters()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@ExitOnFailFirstTest()
        --@ExitOnFailFirstTest()
        --@test(description=Test with multiple ExitOnFailFirstTest sections with parameters)
    $$);
$body$
LANGUAGE sql;

--- Test function with a description in the setup
CREATE OR REPLACE FUNCTION pgunittests.test_with_setup_with_a_description()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@setup(description=The setup description for this test)
        perform pg_sleep(1);
        --@test(description=Test function with a description in the setup)
        perform pg_sleep(2);
    $$);
$body$
LANGUAGE sql;


---
--- Test Case Generation Test Cases
---

--- Test function with just a single case in it
CREATE OR REPLACE FUNCTION pgunittests.test_function_with_one_test_case()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test(description=Test function with just a test case in it)
        perform pg_sleep(1);
    $$);
$body$
LANGUAGE sql;

--- Test function with just 2 cases in it
CREATE OR REPLACE FUNCTION pgunittests.test_function_with_two_test_cases()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test(description=Test case 1)
        perform pg_sleep(1);
        --@test(description=Test case 2)
        perform pg_sleep(1);
    $$);
$body$
LANGUAGE sql;

--- Test function with just 2 cases in it and ExitOnFailFirstTest set to False
CREATE OR REPLACE FUNCTION pgunittests.test_function_exitonfirst_test1()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@ExitOnFailFirstTest(False)
        --@test(description=Test case 1)
        perform pg_sleep(1);
        --@test(description=Test case 2)
        perform pg_sleep(1);
    $$);
$body$
LANGUAGE sql;

--- Test function with just 2 cases in it and ExitOnFailFirstTest set to F
CREATE OR REPLACE FUNCTION pgunittests.test_function_exitonfirst_test2()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@ExitOnFailFirstTest(F)
        --@test(description=Test case 1)
        perform pg_sleep(1);
        --@test(description=Test case 2)
        perform pg_sleep(1);
    $$);
$body$
LANGUAGE sql;

--- Test function with just 2 cases in it and ExitOnFailFirstTest set to NO
CREATE OR REPLACE FUNCTION pgunittests.test_function_exitonfirst_test3()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@ExitOnFailFirstTest(NO)
        --@test(description=Test case 1)
        perform pg_sleep(1);
        --@test(description=Test case 2)
        perform pg_sleep(1);
    $$);
$body$
LANGUAGE sql;

--- Test function with just 2 cases in it and ExitOnFailFirstTest set to N
CREATE OR REPLACE FUNCTION pgunittests.test_function_exitonfirst_test4()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@ExitOnFailFirstTest(N)
        --@test(description=Test case 1)
        perform pg_sleep(1);
        --@test(description=Test case 2)
        perform pg_sleep(1);
    $$);
$body$
LANGUAGE sql;

--- Test function with just 2 cases in it and ExitOnFailFirstTest set to AAA
CREATE OR REPLACE FUNCTION pgunittests.test_function_exitonfirst_test5()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@ExitOnFailFirstTest(AAA)
        --@test(description=Test case 1)
        perform pg_sleep(1);
        --@test(description=Test case 2)
        perform pg_sleep(1);
    $$);
$body$
LANGUAGE sql;

--- Test function with just 2 cases in it and ExitOnFailFirstTest set to TRUE
CREATE OR REPLACE FUNCTION pgunittests.test_function_exitonfirst_test6()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@ExitOnFailFirstTest(TRUE)
        --@test(description=Test case 1)
        perform pg_sleep(1);
        --@test(description=Test case 2)
        perform pg_sleep(1);
    $$);
$body$
LANGUAGE sql;

--- Test function with just 2 cases in it and ExitOnFailFirstTest set to T
CREATE OR REPLACE FUNCTION pgunittests.test_function_exitonfirst_test7()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@ExitOnFailFirstTest(T)
        --@test(description=Test case 1)
        perform pg_sleep(1);
        --@test(description=Test case 2)
        perform pg_sleep(1);
    $$);
$body$
LANGUAGE sql;

--- Test function with just 2 cases in it and ExitOnFailFirstTest set to YES
CREATE OR REPLACE FUNCTION pgunittests.test_function_exitonfirst_test8()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@ExitOnFailFirstTest(YES)
        --@test(description=Test case 1)
        perform pg_sleep(1);
        --@test(description=Test case 2)
        perform pg_sleep(1);
    $$);
$body$
LANGUAGE sql;

--- Test function with just 2 cases in it and ExitOnFailFirstTest set to Y
CREATE OR REPLACE FUNCTION pgunittests.test_function_exitonfirst_test9()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@ExitOnFailFirstTest(Y)
        --@test(description=Test case 1)
        perform pg_sleep(1);
        --@test(description=Test case 2)
        perform pg_sleep(1);
    $$);
$body$
LANGUAGE sql;

--- **************************************************************************
--- Test function with a setup section
--- **************************************************************************

--- Test function with setup 
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup1()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@setup()
        CREATE TABLE IF NOT EXISTS pgunittests.setup (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        --@test(description=Test case 1)
        EXECUTE pg_sleep(1);
    $$);
$body$
    LANGUAGE sql;

--- Check that pgunittest.setup doesn't exist
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup2()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test(description=Check that pgunittest.setup doesn't exist)
        DO $TESTBODY$
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'setup'
            ) THEN
                RAISE EXCEPTION 'pgunittest.setup should not exist!';
            END IF;
        END $TESTBODY$;
    $$);
$body$
LANGUAGE sql;

--- **************************************************************************
--- Test function with a setup section and rollback
--- **************************************************************************

--- Tests to ensure that the rollback takes place

--- Test function with setup and rollback set to TRUE
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_rollback_1()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@Rollback(TRUE)
        --@setup()
        CREATE TABLE IF NOT EXISTS pgunittests.rollback1 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        --@test(description=Test function with setup and rollback set to TRUE)
        EXECUTE pg_sleep(1);
    $$);
$body$
    LANGUAGE sql;

--- Check that pgunittest.rollback1 doesn't exist
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_rollback_2()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test(description=Check that pgunittests.rollback1 doesn't exist)
        DO $TESTBODY$
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'rollback1'
            ) THEN
                RAISE EXCEPTION 'pgunittests.rollback1 should not exist!';
            END IF;
        END $TESTBODY$;
    $$);
$body$
    LANGUAGE sql;

--- Test function with setup and rollback set to T
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_rollback_3()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@Rollback(T)
        --@setup()
        CREATE TABLE IF NOT EXISTS pgunittests.rollback2 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        --@test(description=Test function with setup and rollback set to T)
        EXECUTE pg_sleep(1);
    $$);
$body$
    LANGUAGE sql;

--- Check that pgunittest.rollback2 doesn't exist
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_rollback_4()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test(description=Check that pgunittests.rollback2 doesn't exist)
        DO $TESTBODY$
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'rollback2'
            ) THEN
                RAISE EXCEPTION 'pgunittests.rollback2 should not exist!';
            END IF;
        END $TESTBODY$;
    $$);
$body$
    LANGUAGE sql;

--- Test function with setup and rollback set to YES
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_rollback_5()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@Rollback(YES)
        --@setup()
        CREATE TABLE IF NOT EXISTS pgunittests.rollback3 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        --@test(description=Test function with setup and rollback set to YES)
        EXECUTE pg_sleep(1);
    $$);
$body$
    LANGUAGE sql;

--- Check that pgunittest.rollback3 doesn't exist
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_rollback_6()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test(description=Check that pgunittests.rollback3 doesn't exist)
        DO $TESTBODY$
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'rollback3'
            ) THEN
                RAISE EXCEPTION 'pgunittests.rollback3 should not exist!';
            END IF;
        END $TESTBODY$;
    $$);
$body$
    LANGUAGE sql;

--- Test function with rollback4 and rollback set to Y
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_rollback_7()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@Rollback(Y)
        --@setup()
        CREATE TABLE IF NOT EXISTS pgunittests.rollback4 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        --@test(description=Test function with setup and rollback set to Y)
        EXECUTE pg_sleep(1);
    $$);
$body$
    LANGUAGE sql;

--- Check that pgunittest.setup doesn't exist
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_rollback_8()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test(description=Check that pgunittests.rollback4 doesn't exist)
        DO $TESTBODY$
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'rollback4'
            ) THEN
                RAISE EXCEPTION 'pgunittests.rollback4 should not exist!';
            END IF;
        END $TESTBODY$;
    $$);
$body$
    LANGUAGE sql;

--- Tests to ensure that the rollback is prevent

--- Test function with setup and rollback set to FALSE
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_prevent_rollback_1()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@Rollback(FALSE)
        --@setup()
        CREATE TABLE IF NOT EXISTS pgunittests.prevent_rollback1 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        --@test(description=Test function with setup and rollback set to FALSE)
        EXECUTE pg_sleep(1);
    $$);
$body$
    LANGUAGE sql;

--- Check that pgunittests.rollback1 exist
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_prevent_rollback_2()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test(description=Check that pgunittests.prevent_rollback1 exists)
        DO $TESTBODY$
        BEGIN
            IF NOT EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'prevent_rollback1'
            ) THEN
                RAISE EXCEPTION 'pgunittests.prevent_rollback1 should exist!';
            END IF;
        END $TESTBODY$;
    $$);
$body$
    LANGUAGE sql;

--- Test function with setup and rollback set to F
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_prevent_rollback_3()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@Rollback(F)
        --@setup()
        CREATE TABLE IF NOT EXISTS pgunittests.prevent_rollback2 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        --@test(description=Test function with setup and rollback set to F)
        EXECUTE pg_sleep(1);
    $$);
$body$
    LANGUAGE sql;

--- Check that pgunittests.rollback2 exist
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_prevent_rollback_4()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test(description=Check that pgunittests.prevent_rollback2 exists)
        DO $TESTBODY$
        BEGIN
            IF NOT EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'prevent_rollback2'
            ) THEN
                RAISE EXCEPTION 'pgunittests.prevent_rollback2 should exist!';
            END IF;
        END $TESTBODY$;
    $$);
$body$
    LANGUAGE sql;

--- Test function with setup and rollback set to NO
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_prevent_rollback_5()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@Rollback(NO)
        --@setup()
        CREATE TABLE IF NOT EXISTS pgunittests.prevent_rollback3 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        --@test(description=Test function with setup and rollback set to NO)
        EXECUTE pg_sleep(1);
    $$);
$body$
    LANGUAGE sql;

--- Check that pgunittests.rollback3 exist
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_prevent_rollback_6()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test(description=Check that pgunittests.prevent_rollback3 exists)
        DO $TESTBODY$
        BEGIN
            IF NOT EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'prevent_rollback3'
            ) THEN
                RAISE EXCEPTION 'pgunittests.prevent_rollback3 should exist!';
            END IF;
        END $TESTBODY$;
    $$);
$body$
    LANGUAGE sql;

--- Test function with setup and rollback set to N
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_prevent_rollback_7()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@Rollback(N)
        --@setup()
        CREATE TABLE IF NOT EXISTS pgunittests.prevent_rollback4 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        --@test(description=Test function with setup and rollback set to N)
        EXECUTE pg_sleep(1);
    $$);
$body$
    LANGUAGE sql;

--- Check that pgunittests.rollback4 exist
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_prevent_rollback_8()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@test(description=Check that pgunittests.prevent_rollback4 exists)
        DO $TESTBODY$
        BEGIN
            IF NOT EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'prevent_rollback4'
            ) THEN
                RAISE EXCEPTION 'pgunittests.prevent_rollback4 should exist!';
            END IF;
        END $TESTBODY$;
    $$);
$body$
    LANGUAGE sql;

--- Cleanup Test Case for the tests that prevent rollback
--- Test function with setup and rollback set to N
CREATE OR REPLACE FUNCTION pgunittests.test_function_setup_prevent_rollback_9()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@Rollback(N)
        --@test(description=Clean up test for tables that have been created in previous tests)
        DROP TABLE IF EXISTS pgunittests.prevent_rollback1;
        DROP TABLE IF EXISTS pgunittests.prevent_rollback2;
        DROP TABLE IF EXISTS pgunittests.prevent_rollback3;
        DROP TABLE IF EXISTS pgunittests.prevent_rollback4;
    $$);
$body$
    LANGUAGE sql;

---
--- Test with Variable that divides by 0
---

--- This test case is intended to fail
CREATE OR REPLACE FUNCTION pgunittests.test_division_by_zero()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@Variables()
        result numeric;
        --@test(description=Test function with setup and rollback set to N)
        result := 1 / 0;
    $$);
$body$
    LANGUAGE sql;

---
--- Tests to check the generated code
---

--- Testing pgunittests.test_function_with_one_test_case
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_1()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test function with just a test case in it
        -- Test Case Function : pgunittests.test_function_with_one_test_case()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test function with just a test case in it';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_with_one_test_case');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_with_one_test_case)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_with_two_test_cases
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_2()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 1
        -- Test Case Function : pgunittests.test_function_with_two_test_cases()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 1';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 2
        -- Test Case Function : pgunittests.test_function_with_two_test_cases()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 2';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_with_two_test_cases');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_with_two_test_cases)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_exitonfirst_test1
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_3()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 1
        -- Test Case Function : pgunittests.test_function_exitonfirst_test1()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 1';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 2
        -- Test Case Function : pgunittests.test_function_exitonfirst_test1()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 2';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_exitonfirst_test1');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_exitonfirst_test1)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_exitonfirst_test2
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_4()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 1
        -- Test Case Function : pgunittests.test_function_exitonfirst_test2()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 1';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 2
        -- Test Case Function : pgunittests.test_function_exitonfirst_test2()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 2';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_exitonfirst_test2');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_exitonfirst_test2)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_exitonfirst_test3
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_5()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 1
        -- Test Case Function : pgunittests.test_function_exitonfirst_test3()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 1';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 2
        -- Test Case Function : pgunittests.test_function_exitonfirst_test3()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 2';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_exitonfirst_test3');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_exitonfirst_test3)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_exitonfirst_test4
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_6()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 1
        -- Test Case Function : pgunittests.test_function_exitonfirst_test4()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 1';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 2
        -- Test Case Function : pgunittests.test_function_exitonfirst_test4()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 2';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_exitonfirst_test4');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_exitonfirst_test4)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_exitonfirst_test5
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_7()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 1
        -- Test Case Function : pgunittests.test_function_exitonfirst_test5()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 1';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 2
        -- Test Case Function : pgunittests.test_function_exitonfirst_test5()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 2';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_exitonfirst_test5');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_exitonfirst_test5)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_exitonfirst_test6
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_8()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 1
        -- Test Case Function : pgunittests.test_function_exitonfirst_test6()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 1';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 2
        -- Test Case Function : pgunittests.test_function_exitonfirst_test6()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 2';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;
END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_exitonfirst_test6');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_exitonfirst_test6)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_exitonfirst_test7
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_9()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 1
        -- Test Case Function : pgunittests.test_function_exitonfirst_test7()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 1';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 2
        -- Test Case Function : pgunittests.test_function_exitonfirst_test7()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 2';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;
END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_exitonfirst_test7');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_exitonfirst_test7)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_exitonfirst_test8
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_10()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 1
        -- Test Case Function : pgunittests.test_function_exitonfirst_test8()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 1';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 2
        -- Test Case Function : pgunittests.test_function_exitonfirst_test8()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 2';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;
END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_exitonfirst_test8');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_exitonfirst_test8)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_exitonfirst_test9
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_11()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 1
        -- Test Case Function : pgunittests.test_function_exitonfirst_test9()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 1';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 2
        -- Test Case Function : pgunittests.test_function_exitonfirst_test9()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 2';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                perform pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;
END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_exitonfirst_test9');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_exitonfirst_test9)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup1
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_12()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : SETUP - 
        -- Test Case Function : pgunittests.test_function_setup1()
        -----------------------------------------------------------------
        section = 'SETUP';
        description = NULL;
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                CREATE TABLE IF NOT EXISTS pgunittests.setup (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'Setup Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
            RETURN; -- Stops execution of the whole function if Setup fails
        END;

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test case 1
        -- Test Case Function : pgunittests.test_function_setup1()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test case 1';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                EXECUTE pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup1');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup1)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup2
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_13()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Check that pgunittest.setup doesn't exist
        -- Test Case Function : pgunittests.test_function_setup2()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Check that pgunittest.setup doesn''t exist';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                DO $TESTBODY$
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'setup'
            ) THEN
                RAISE EXCEPTION 'pgunittest.setup should not exist!';
            END IF;
        END $TESTBODY$;
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup2');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup2)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_rollback_1
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_14()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : SETUP - 
        -- Test Case Function : pgunittests.test_function_setup_rollback_1()
        -----------------------------------------------------------------
        section = 'SETUP';
        description = NULL;
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                CREATE TABLE IF NOT EXISTS pgunittests.rollback1 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'Setup Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
            RETURN; -- Stops execution of the whole function if Setup fails
        END;

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test function with setup and rollback set to TRUE
        -- Test Case Function : pgunittests.test_function_setup_rollback_1()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test function with setup and rollback set to TRUE';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                EXECUTE pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_rollback_1');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_rollback_1)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_rollback_2
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_15()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Check that pgunittests.rollback1 doesn't exist
        -- Test Case Function : pgunittests.test_function_setup_rollback_2()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Check that pgunittests.rollback1 doesn''t exist';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                DO $TESTBODY$
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'rollback1'
            ) THEN
                RAISE EXCEPTION 'pgunittests.rollback1 should not exist!';
            END IF;
        END $TESTBODY$;
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_rollback_2');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_rollback_2)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_rollback_3
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_16()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : SETUP - 
        -- Test Case Function : pgunittests.test_function_setup_rollback_3()
        -----------------------------------------------------------------
        section = 'SETUP';
        description = NULL;
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                CREATE TABLE IF NOT EXISTS pgunittests.rollback2 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'Setup Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
            RETURN; -- Stops execution of the whole function if Setup fails
        END;

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test function with setup and rollback set to T
        -- Test Case Function : pgunittests.test_function_setup_rollback_3()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test function with setup and rollback set to T';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                EXECUTE pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_rollback_3');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_rollback_3)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_rollback_4
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_17()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Check that pgunittests.rollback2 doesn't exist
        -- Test Case Function : pgunittests.test_function_setup_rollback_4()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Check that pgunittests.rollback2 doesn''t exist';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                DO $TESTBODY$
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'rollback2'
            ) THEN
                RAISE EXCEPTION 'pgunittests.rollback2 should not exist!';
            END IF;
        END $TESTBODY$;
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_rollback_4');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_rollback_4)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_rollback_5
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_18()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : SETUP - 
        -- Test Case Function : pgunittests.test_function_setup_rollback_5()
        -----------------------------------------------------------------
        section = 'SETUP';
        description = NULL;
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                CREATE TABLE IF NOT EXISTS pgunittests.rollback3 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'Setup Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
            RETURN; -- Stops execution of the whole function if Setup fails
        END;

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test function with setup and rollback set to YES
        -- Test Case Function : pgunittests.test_function_setup_rollback_5()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test function with setup and rollback set to YES';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                EXECUTE pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_rollback_5');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_rollback_5)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_rollback_6
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_19()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Check that pgunittests.rollback3 doesn't exist
        -- Test Case Function : pgunittests.test_function_setup_rollback_6()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Check that pgunittests.rollback3 doesn''t exist';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                DO $TESTBODY$
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'rollback3'
            ) THEN
                RAISE EXCEPTION 'pgunittests.rollback3 should not exist!';
            END IF;
        END $TESTBODY$;
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_rollback_6');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_rollback_6)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_rollback_7
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_20()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : SETUP - 
        -- Test Case Function : pgunittests.test_function_setup_rollback_7()
        -----------------------------------------------------------------
        section = 'SETUP';
        description = NULL;
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                CREATE TABLE IF NOT EXISTS pgunittests.rollback4 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'Setup Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
            RETURN; -- Stops execution of the whole function if Setup fails
        END;

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test function with setup and rollback set to Y
        -- Test Case Function : pgunittests.test_function_setup_rollback_7()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test function with setup and rollback set to Y';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                EXECUTE pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_rollback_7');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_rollback_7)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_rollback_8
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_21()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Check that pgunittests.rollback4 doesn't exist
        -- Test Case Function : pgunittests.test_function_setup_rollback_8()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Check that pgunittests.rollback4 doesn''t exist';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                DO $TESTBODY$
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'rollback4'
            ) THEN
                RAISE EXCEPTION 'pgunittests.rollback4 should not exist!';
            END IF;
        END $TESTBODY$;
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_rollback_8');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_rollback_8)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_prevent_rollback_1
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_22()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : SETUP - 
        -- Test Case Function : pgunittests.test_function_setup_prevent_rollback_1()
        -----------------------------------------------------------------
        section = 'SETUP';
        description = NULL;
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                CREATE TABLE IF NOT EXISTS pgunittests.prevent_rollback1 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'Setup Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
            RETURN; -- Stops execution of the whole function if Setup fails
        END;

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test function with setup and rollback set to FALSE
        -- Test Case Function : pgunittests.test_function_setup_prevent_rollback_1()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test function with setup and rollback set to FALSE';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                EXECUTE pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_prevent_rollback_1');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_prevent_rollback_1)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_prevent_rollback_2
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_23()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Check that pgunittests.prevent_rollback1 exists
        -- Test Case Function : pgunittests.test_function_setup_prevent_rollback_2()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Check that pgunittests.prevent_rollback1 exists';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                DO $TESTBODY$
        BEGIN
            IF NOT EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'prevent_rollback1'
            ) THEN
                RAISE EXCEPTION 'pgunittests.prevent_rollback1 should exist!';
            END IF;
        END $TESTBODY$;
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_prevent_rollback_2');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_prevent_rollback_2)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_prevent_rollback_3
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_24()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : SETUP - 
        -- Test Case Function : pgunittests.test_function_setup_prevent_rollback_3()
        -----------------------------------------------------------------
        section = 'SETUP';
        description = NULL;
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                CREATE TABLE IF NOT EXISTS pgunittests.prevent_rollback2 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'Setup Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
            RETURN; -- Stops execution of the whole function if Setup fails
        END;

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test function with setup and rollback set to F
        -- Test Case Function : pgunittests.test_function_setup_prevent_rollback_3()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test function with setup and rollback set to F';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                EXECUTE pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_prevent_rollback_3');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_prevent_rollback_3)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_prevent_rollback_4
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_25()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Check that pgunittests.prevent_rollback2 exists
        -- Test Case Function : pgunittests.test_function_setup_prevent_rollback_4()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Check that pgunittests.prevent_rollback2 exists';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                DO $TESTBODY$
        BEGIN
            IF NOT EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'prevent_rollback2'
            ) THEN
                RAISE EXCEPTION 'pgunittests.prevent_rollback2 should exist!';
            END IF;
        END $TESTBODY$;
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_prevent_rollback_4');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_prevent_rollback_4)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_prevent_rollback_5
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_26()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : SETUP - 
        -- Test Case Function : pgunittests.test_function_setup_prevent_rollback_5()
        -----------------------------------------------------------------
        section = 'SETUP';
        description = NULL;
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                CREATE TABLE IF NOT EXISTS pgunittests.prevent_rollback3 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'Setup Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
            RETURN; -- Stops execution of the whole function if Setup fails
        END;

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test function with setup and rollback set to NO
        -- Test Case Function : pgunittests.test_function_setup_prevent_rollback_5()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test function with setup and rollback set to NO';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                EXECUTE pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_prevent_rollback_5');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_prevent_rollback_5)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_prevent_rollback_6
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_27()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Check that pgunittests.prevent_rollback3 exists
        -- Test Case Function : pgunittests.test_function_setup_prevent_rollback_6()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Check that pgunittests.prevent_rollback3 exists';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                DO $TESTBODY$
        BEGIN
            IF NOT EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'prevent_rollback3'
            ) THEN
                RAISE EXCEPTION 'pgunittests.prevent_rollback3 should exist!';
            END IF;
        END $TESTBODY$;
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_prevent_rollback_6');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_prevent_rollback_6)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_prevent_rollback_7
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_28()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN
    BEGIN

        -----------------------------------------------------------------
        -- Test Case : SETUP - 
        -- Test Case Function : pgunittests.test_function_setup_prevent_rollback_7()
        -----------------------------------------------------------------
        section = 'SETUP';
        description = NULL;
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                CREATE TABLE IF NOT EXISTS pgunittests.prevent_rollback4 (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'Setup Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
            RETURN; -- Stops execution of the whole function if Setup fails
        END;

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test function with setup and rollback set to N
        -- Test Case Function : pgunittests.test_function_setup_prevent_rollback_7()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test function with setup and rollback set to N';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                EXECUTE pg_sleep(1);
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_prevent_rollback_7');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_prevent_rollback_7)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_prevent_rollback_8
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_29()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Check that pgunittests.prevent_rollback4 exists
        -- Test Case Function : pgunittests.test_function_setup_prevent_rollback_8()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Check that pgunittests.prevent_rollback4 exists';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                DO $TESTBODY$
        BEGIN
            IF NOT EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_schema = 'pgunittests' 
                AND table_name = 'prevent_rollback4'
            ) THEN
                RAISE EXCEPTION 'pgunittests.prevent_rollback4 should exist!';
            END IF;
        END $TESTBODY$;
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_prevent_rollback_8');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_prevent_rollback_8)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_function_setup_prevent_rollback_9
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_30()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
    
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Clean up test for tables that have been created in previous tests
        -- Test Case Function : pgunittests.test_function_setup_prevent_rollback_9()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Clean up test for tables that have been created in previous tests';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                DROP TABLE IF EXISTS pgunittests.prevent_rollback1;
        DROP TABLE IF EXISTS pgunittests.prevent_rollback2;
        DROP TABLE IF EXISTS pgunittests.prevent_rollback3;
        DROP TABLE IF EXISTS pgunittests.prevent_rollback4;
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_function_setup_prevent_rollback_9');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_function_setup_prevent_rollback_9)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

--- Testing pgunittests.test_division_by_zero
CREATE OR REPLACE FUNCTION pgunittests.test_generated_code_31()
RETURNS TABLE(code VARCHAR) AS
$body$
    SELECT pgunit.testcase($$
        --@variables
        actual_test_code TEXT;
        expected_code TEXT;

        --@setup
        
        --- Set the expected test code
        expected_code = $EXPECTED$DECLARE
    test_start_time TIMESTAMP;
            result numeric;
BEGIN

    BEGIN

        -----------------------------------------------------------------
        -- Test Case : TEST - Test function with setup and rollback set to N
        -- Test Case Function : pgunittests.test_division_by_zero()
        -----------------------------------------------------------------
        section = 'TEST';
        description = 'Test function with setup and rollback set to N';
        passed = True;
        errormessage = '';
        test_start_time = clock_timestamp();

                result := 1 / 0;
    

        test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
        RETURN NEXT;
    EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = 'TEST Section Failed : ' || SQLERRM;
            test_duration = date_trunc('millisecond', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;

END;
$EXPECTED$;

        --- Get the actual generated code
        actual_test_code = pgunittests.get_testable_generated_code('pgunittests.test_division_by_zero');
        
        --@test(description=Test Generated Code in Test Function : pgunittests.test_division_by_zero)
        
        -- Verify if expected_code is a substring of actual_test_code
        IF actual_test_code NOT LIKE '%' || expected_code || '%' THEN
            RAISE EXCEPTION 'The generated code doesn''t match the expected code!';
        END IF;
    $$);
$body$
    LANGUAGE sql;

