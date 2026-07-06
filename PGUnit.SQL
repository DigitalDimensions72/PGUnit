-- ====================================================================
-- Tool Name: PGUnit
-- Description: A unit testing solution for PostgreSQL
--
-- Copyright (c) 2026, John Clarke
-- Licensed under the PostgreSQL License. 
-- See the LICENSE file in the project root for full license text.
-- ====================================================================

--- Create the PGUnit schema
DROP SCHEMA if exists pgunit CASCADE;
CREATE SCHEMA pgunit AUTHORIZATION postgres;
COMMENT ON SCHEMA pgunit IS 'Unit testing tool for PostgreSQL';

--- ******************
--- * Core Functions *
--- ******************

---
--- Version
---
CREATE or REPLACE FUNCTION pgunit."version" () 
RETURNS character varying
AS
$BODY$
SELECT 'PGUnit Version 1.0 by John Clarke'::VARCHAR
$BODY$
    LANGUAGE sql;

---
--- The Test Case details
---

CREATE OR REPLACE FUNCTION pgunit.testcase(raw_block character varying)   
RETURNS TABLE (code VARCHAR) 
AS
$BODY$
BEGIN
    code = raw_block;
    RETURN NEXT;
END;
$BODY$ 
    LANGUAGE plpgsql;

---
--- Code for processing the test cases
---

--- Code to get the Unit Test Code
CREATE OR REPLACE FUNCTION pgunit.get_unittest_code(test_function_name text)
RETURNS text 
AS $BODY$
DECLARE
    returned_code text;
BEGIN
    EXECUTE 'SELECT code FROM ' || test_function_name || '()'
    INTO returned_code;
    
    RETURN returned_code;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION pgunit.extract_test_case_annotations(text_value TEXT)
RETURNS TABLE (
    name              TEXT,
    name_position     INT,
    value             TEXT, 
    description       TEXT,
    occurence_number  INT,
    code_block        TEXT
)
AS
$BODY$
BEGIN
    RETURN QUERY
    WITH split_lines AS (
        -- Step 1: Split string into distinct rows per line, allowing for varied leading dashes and spacing
        SELECT 
            line_id,
            line,
            regexp_match(line, '-+\s*@([A-Za-z0-9_]+)(?:\((.*)\))?\s*$') AS match_data
        FROM unnest(regexp_split_to_array(text_value, E'\r?\n')) WITH ORDINALITY AS t(line, line_id)
    ),
    grouped_blocks AS (
        -- Step 2: Use a rolling count to assign every line to its respective parent annotation group
        SELECT 
            line_id,
            line,
            match_data,
            count(match_data) OVER (ORDER BY line_id) AS group_id
        FROM split_lines
    ),
    aggregated_data AS (
        -- Step 3: Group lines together using MAX to safely pull the non-null annotation signature per group
        SELECT 
            group_id,
            min(line_id) AS first_line_id,
            upper(trim((max(match_data))[1])) AS r_name,
            nullif(trim((max(match_data))[2]), '') AS r_args,
            nullif(string_agg(line, E'\n' ORDER BY line_id) FILTER (WHERE match_data IS NULL), '') AS r_block
        FROM grouped_blocks
        WHERE group_id > 0
        GROUP BY group_id
    ),
    annotated_data AS (
        -- Step 4: Map arguments, parse descriptions, and compute localized occurrence counts safely
        SELECT 
            first_line_id,
            r_name,
            CASE WHEN r_args !~* '^description\s*=' THEN r_args END AS val_extract,
            CASE WHEN r_args ~* '^description\s*=' THEN nullif(trim(regexp_replace(r_args, '^description\s*=\s*', '', 'i')), '') END AS desc_extract,
            row_number() OVER (PARTITION BY r_name ORDER BY first_line_id)::int AS occ_num,
            r_block,
            CASE 
                WHEN r_name = 'SETUP' THEN 1
                WHEN r_name = 'TEST'  THEN 2
                ELSE 3
            END AS pos_extract
        FROM aggregated_data
    )
    -- Step 5: Format final output structured logically by their appearance sequence in the script
    SELECT 
        r_name AS name,
        pos_extract AS name_position,
        val_extract AS value, 
        desc_extract AS description,
        occ_num AS occurence_number,
        r_block AS code_block
        
    FROM annotated_data
    ORDER BY first_line_id;
END;
$BODY$ LANGUAGE plpgsql;

--- Get specific sections of the code
DROP FUNCTION IF EXISTS pgunit.get_test_section_details(TEXT, TEXT);

CREATE OR REPLACE FUNCTION pgunit.get_test_section_details(
    functionname TEXT,
    sectionname TEXT
)
RETURNS TABLE (
    name TEXT,
    value TEXT,
    description TEXT,
    code_block TEXT
) AS $BODY$
BEGIN
    RETURN QUERY EXECUTE format('
        SELECT 
            ann.name,
            ann.value,
            ann.description,
            ann.code_block
        FROM pgunit.extract_test_case_annotations(
            (SELECT code FROM %s())
        ) ann
        WHERE UPPER(TRIM(ann.name)) = UPPER(TRIM(%L))', 
        functionname, 
        sectionname
    );
END;
$BODY$ 
    LANGUAGE plpgsql;

--- Get the settings for the test
CREATE OR REPLACE FUNCTION pgunit.get_test_settings(function_name TEXT)
RETURNS TABLE (
    variables TEXT,
    exit_on_fail BOOLEAN,
    rollback_code BOOLEAN
) AS $BODY$
DECLARE
    dynamic_query TEXT;
    row_record RECORD;
    collected_variables TEXT = '';
    exit_flag BOOLEAN = FALSE;
    rollback_flag BOOLEAN = TRUE; 
BEGIN
    -- Construct the dynamic SQL query using %s for the function name execution
    dynamic_query := format('
        SELECT name, value, code_block 
        FROM pgunit.extract_test_case_annotations(
            (SELECT code FROM %s())
        )', 
        function_name
    );

    -- Loop through the dynamically executed query results
    FOR row_record IN EXECUTE dynamic_query LOOP
        
        -- Case 1: Capture code_block when name is 'VARIABLES'
        IF row_record.name = 'VARIABLES' THEN
            --- RAISE NOTICE 'row_record.code_block = %',row_record.code_block;
            IF collected_variables = '' THEN
                collected_variables = row_record.code_block;
            ELSE
                collected_variables = collected_variables || E'\n' || row_record.code_block;
            END IF;
        END IF;

        -- Case 2: Evaluate Boolean flag when name is 'EXITONFAILFIRSTTEST'
        IF row_record.name = 'EXITONFAILFIRSTTEST' THEN
            --- RAISE NOTICE 'UPPER(TRIM(row_record.value)) = %',UPPER(TRIM(row_record.value));
            IF UPPER(TRIM(row_record.value)) IN ('FALSE', 'F', 'NO', 'N') THEN
                exit_flag = FALSE;
            END IF;
            IF UPPER(TRIM(row_record.value)) IN ('TRUE', 'T', 'YES', 'Y') THEN
                exit_flag = TRUE;
            END IF;
        END IF;
      
        -- Case 3: Evaluate Boolean flag when name is 'ROLLBACK'
        IF row_record.name = 'ROLLBACK' THEN
            --- RAISE NOTICE 'UPPER(TRIM(row_record.value)) = %',UPPER(TRIM(row_record.value));
            IF UPPER(TRIM(row_record.value)) IN ('FALSE', 'F', 'NO', 'N') THEN
                rollback_flag = FALSE;
            END IF;
            IF UPPER(TRIM(row_record.value)) IN ('TRUE', 'T', 'YES', 'Y') THEN
                rollback_flag = TRUE;
            END IF;
        END IF;

    END LOOP;

    -- Assign local state to the output columns
    variables = collected_variables;
    exit_on_fail = exit_flag;
    rollback_code = rollback_flag;

    RETURN NEXT;
END;
$BODY$ 
    LANGUAGE plpgsql;

---
--- Code to generate the functions to execute the test case
---

--- Generate the test case code
CREATE OR REPLACE FUNCTION pgunit.generate_testcase_code(
    IN test_function_name TEXT,
    OUT test_code_function_name TEXT,
    OUT v_generated_code TEXT
) 
AS $BODY$
DECLARE
    test_variables TEXT; 
    test_exit_on_fail BOOLEAN;
    test_setup_code TEXT;
    test_code TEXT;
BEGIN
    -- Get the test case settings
    SELECT variables, exit_on_fail 
    INTO test_variables, test_exit_on_fail
    FROM pgunit.get_test_settings(test_function_name);
    
    -- Generate the unique temporary function name
    test_code_function_name = 'pgunit_testcode_tmp_' || md5(clock_timestamp()::VARCHAR);

    -- Build the CREATE FUNCTION definition block
    v_generated_code = 'CREATE OR REPLACE FUNCTION ' || test_code_function_name || '() ' ||
                        'RETURNS TABLE (' || E'\n' ||
                        '  section text,' || E'\n' ||
                        '  description text,' || E'\n' ||
                        '  passed boolean,' || E'\n' ||
                        '  errormessage text,' || E'\n' ||
                        '  test_duration interval' || E'\n' ||
                        ') ' || E'\n' ||
                        'AS ' || E'\n' ||
                        '$CODEBODY$' || E'\n';

    -- Always create the DECLARE block with test_start_time, and append test_variables if present
    v_generated_code = v_generated_code || 
                        'DECLARE' || E'\n' ||
                        '    test_start_time TIMESTAMP;' || E'\n';

    IF test_variables IS NOT NULL THEN
        v_generated_code = v_generated_code || 
                            '    ' || test_variables || E'\n';
    END IF;

    --- Get the setup and test code
    test_setup_code = pgunit.generate_test_section_code(test_function_name,'SETUP',test_exit_on_fail);
    test_code = pgunit.generate_test_section_code(test_function_name,'TEST',test_exit_on_fail);

    -- Add the body block and language attributes
    v_generated_code = v_generated_code || 
                        'BEGIN' || E'\n' ||
                        test_setup_code || E'\n' ||
                        test_code || E'\n' ||
                        'END;' || E'\n' ||
                        '$CODEBODY$' || E'\n' ||
                        ' LANGUAGE ''plpgsql'' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;';

    --- Create the Test Function
    EXECUTE v_generated_code;
    --- RAISE NOTICE 'GENERATED CODE : %',v_generated_code;

    -- Format final output function name
    test_code_function_name = test_code_function_name || '()';
    
END;
$BODY$
    LANGUAGE plpgsql;

--- Create the code for each section
CREATE OR REPLACE FUNCTION pgunit.generate_test_section_code(
    p_test_function_name text,
    p_section text,
    p_exit_on_first_fail boolean DEFAULT false
)
RETURNS text 
AS $BODY$
DECLARE
    v_record record;
    v_generated_code text = '';
    v_individual_block text;
    v_exception_block text = '';
    v_final_output text = '';
BEGIN
    -- 1. Explicitly define the exception block string based on section type
    -- Fixed syntax error in upper() and catch block condition ordering
    IF upper(p_section) = 'SETUP' THEN
        v_exception_block = 'EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = ''Setup Section Failed : '' || SQLERRM;
            test_duration = date_trunc(''millisecond'', clock_timestamp() - test_start_time);
            RETURN NEXT;
            RETURN; -- Stops execution of the whole function if Setup fails
        END;';
    ELSE
        -- Fallback exception handler for non-SETUP sections
        v_exception_block = 'EXCEPTION
        WHEN assert_failure OR OTHERS THEN
            passed = False;
            errormessage = ''' || p_section || ' Section Failed : '' || SQLERRM;
            test_duration = date_trunc(''millisecond'', clock_timestamp() - test_start_time);
            RETURN NEXT;
        END;';
    END IF;

    -- 2. Loop through the test records
    FOR v_record IN 
        SELECT name, value, description, code_block 
        FROM pgunit.get_test_section_details(p_test_function_name, p_section)
    LOOP
 
        -- Construct the core code block for this specific record
        v_individual_block = format('
        -----------------------------------------------------------------
        -- Test Case : %s - %s
        -- Test Case Function : %s()
        -----------------------------------------------------------------
        section = %L;
        description = %L;
        passed = True;
        errormessage = '''';
        test_start_time = clock_timestamp();

        %s

        test_duration = date_trunc(''millisecond'', clock_timestamp() - test_start_time);
        RETURN NEXT;
',
            v_record.name,
            v_record.description,
            p_test_function_name,
            v_record.name,
            v_record.description,
            v_record.code_block
        );

        -- Logic Branch: Each block wrapped individually
        IF p_exit_on_first_fail = false THEN
            v_generated_code = v_generated_code || E'    BEGIN\n' || v_individual_block || '    ' || v_exception_block || E'\n';
        -- Logic Branch: Accumulate blocks bare (to be wrapped globally later)
        ELSE
            v_generated_code = v_generated_code || v_individual_block;
        END IF;

    END LOOP;

    -- 3. Logic Branch: Wrap everything globally if exit on first fail is true
    if LENGTH(TRIM(v_generated_code)) > 0 THEN
        IF p_exit_on_first_fail = true THEN
            v_final_output = E'BEGIN\n' || v_generated_code || v_exception_block;
        ELSE
            v_final_output = v_generated_code;
        END IF;
    END IF;

    RETURN v_final_output;
END;
$BODY$
LANGUAGE plpgsql;

--- Count the sections in a test case
CREATE OR REPLACE FUNCTION pgunit.count_test_suite_sections(
    text_value text,
    target_section_name text
)
  RETURNS int 
AS $BODY$
DECLARE
    section_count int;
BEGIN
    ---
    --- 1. Extract, clean, and filter annotations matching the target name
    ---
    WITH annotations AS (
        SELECT 
            UPPER(TRIM(a.name)) AS ann_name
        FROM pgunit.extract_test_case_annotations(text_value) a
    )
    SELECT 
        COUNT(*)
    INTO 
        section_count
    FROM 
        annotations
    WHERE 
        ann_name = UPPER(TRIM(target_section_name));

    ---
    --- 2. Return the final count
    ---
    RETURN section_count;

END;
$BODY$
LANGUAGE plpgsql;

---
--- Test Case Validation
--- 
CREATE OR REPLACE FUNCTION pgunit.validate_test_suite(text_value text)
  RETURNS void 
AS $BODY$
DECLARE
    setup_count              int;
    test_count               int;
    variables_count          int;
    exit_on_fail_count       int;
    test_missing_desc_count  int;
    rollback_count           int;
    errors                   text[] = '{}'; -- Accumulates all errors
BEGIN
    ---
    --- 1. Metric Aggregation (Using aliases to avoid any naming ambiguity)
    ---
    WITH annotations AS (
        SELECT 
            UPPER(TRIM(a.name)) AS ann_name,
            a.description AS ann_desc
        FROM pgunit.extract_test_case_annotations(text_value) a
    )
    SELECT 
        COUNT(*) FILTER (WHERE ann_name = 'SETUP'),
        COUNT(*) FILTER (WHERE ann_name = 'TEST'),
        COUNT(*) FILTER (WHERE ann_name = 'VARIABLES'),
        COUNT(*) FILTER (WHERE ann_name = 'EXITONFAILFIRSTTEST'),
        COUNT(*) FILTER (WHERE ann_name = 'TEST' AND (ann_desc IS NULL OR TRIM(ann_desc) = '')),
        COUNT(*) FILTER (WHERE ann_name = 'ROLLBACK')
    INTO 
        setup_count, 
        test_count, 
        variables_count, 
        exit_on_fail_count, 
        test_missing_desc_count,
        rollback_count
    FROM annotations;

    ---
    --- 2. Enforce Rules Matrix
    ---

    -- Rule: If there are more than 1 setup it fails
    IF setup_count > 1 THEN
        errors = array_append(errors, 'Multiple @SETUP sections found. Only one allowed.');
    END IF;

    -- Rule: If there are 0 tests it fails
    IF test_count = 0 THEN
        errors = array_append(errors, 'No @TEST sections found. A test suite must contain at least one test.');
    END IF;

    -- Rule: If there are tests with no descriptions it fails (Optional sections ignored)
    IF test_missing_desc_count > 0 THEN
        errors = array_append(errors, 'One or more @TEST annotations are missing a description.');
    END IF;

    -- Rule: If there are more than one variables it fails
    IF variables_count > 1 THEN
        errors = array_append(errors, 'Multiple @VARIABLES sections found. Only one allowed.');
    END IF;

  -- Rule: If there are more than one rollback it fails
    IF rollback_count > 1 THEN
        errors = array_append(errors, 'Multiple @ROLLBACK sections found. Only one allowed.');
    END IF;

    -- Rule: If there are more than one ExitOnFailFirstTest it fails
    IF exit_on_fail_count > 1 THEN
        errors = array_append(errors, 'Multiple @ExitOnFailFirstTest sections found. Only one allowed.');
    END IF;

    ---
    --- 3. Raise Combined Exceptions if needed
    ---
    IF array_length(errors, 1) > 0 THEN
        RAISE EXCEPTION 'Validation Failed:%', 
            E'\n- ' || array_to_string(errors, E'\n- ')
            USING ERRCODE = 'check_violation';
    END IF;

END;
$BODY$
LANGUAGE plpgsql;

---
--- Test Case Discovery Function
---

CREATE OR REPLACE FUNCTION pgunit.get_test_functions(
    p_schema TEXT,
    p_function_name TEXT DEFAULT NULL
)
RETURNS TEXT[] 
AS $BODY$
DECLARE
    v_functions TEXT[];
BEGIN
    -- Ensure schema is provided
    IF p_schema IS NULL OR TRIM(p_schema) = '' THEN
        RAISE EXCEPTION 'Schema parameter is mandatory';
    END IF;

    SELECT array_agg(routine_schema || '.' || routine_name)
    INTO v_functions
    FROM information_schema.routines
    WHERE routine_schema = p_schema
      AND routine_type = 'FUNCTION'
      AND (
          -- If FunctionName is null/omitted, find names starting with 'test_'
          (p_function_name IS NULL AND routine_name LIKE 'test\_%' ESCAPE '\') 
          OR 
          -- Otherwise, find the exact match
          (p_function_name IS NOT NULL AND routine_name = p_function_name)
      );

    -- Return an empty array instead of NULL if no functions are found
    RETURN COALESCE(v_functions, ARRAY[]::TEXT[]);
END;
$BODY$
LANGUAGE plpgsql;


---
--- Test Case Execution Functions
---


---
--- Test Runner
---
CREATE OR REPLACE FUNCTION pgunit.testrunner(
    IN p_test_case_schema character varying DEFAULT NULL,
    IN p_test_case_function character varying DEFAULT NULL)
  RETURNS TABLE(
    test_case_functions integer,
    tests_cases integer, 
    tests_cases_not_run integer, 
    passed integer, 
    failed integer) AS
$BODY$
DECLARE
    test_count_in_test_function INTEGER;            --- The count of the tests in a test function
    unit_test_code TEXT;                            --- The code for the unit test
    test_functions_array TEXT[];                    --- The array that will contain the list of test functions
    test_function_details RECORD;                   --- A record object containing the test code function details
    test_function_name TEXT;                        --- The name of the test function
    test_function_code_name TEXT;                   --- The name of the actual test function to run
    test_function_loop INTEGER;                     --- Loop counter variable
    testrunner_execution_timing_start TIMESTAMP;    --- The start time for when the testrunner started running the tests
    testrunner_execution_time_taken INTERVAL;       --- The time taken for the testrunner to run all of the tests
    perform_rollback BOOLEAN = TRUE;                --- Rollback the code
    current_test_loop_position INTEGER = 0;         --- The current test loop position
    test_result RECORD;                             --- Record variable to hold individual test step results
BEGIN
    --- Ensure that the user is only informed about information that might be helpful
    SET client_min_messages TO 'NOTICE';
  
    --- Initialize the implicit output table columns directly
    test_case_functions = 0;
    tests_cases = 0;
    tests_cases_not_run = 0;
    passed = 0;
    failed = 0;
    
    --- Set the start time for when the test runner started the tests
    testrunner_execution_timing_start = clock_timestamp();

    --- Inform the user of the Version of PGUnit
    RAISE NOTICE '%', pgunit.version();

    --- Get a list of the functions
    test_functions_array = pgunit.get_test_functions(p_test_case_schema, p_test_case_function);

    --- If there are tests to run then run them
    IF array_length(test_functions_array, 1) > 0 THEN

        --- Loop through the list of test functions in test_functions_array
        FOR test_function_loop IN array_lower(test_functions_array, 1) .. array_upper(test_functions_array, 1) 
        LOOP

            --- Increment the number of test case functions
            test_case_functions = test_case_functions + 1;

            --- Increment the current test loop position
            current_test_loop_position = current_test_loop_position + 1;

            --- Start the transaction for this test case
            BEGIN

                --- Get the name of the test function
                test_function_name = test_functions_array[test_function_loop];

                -- Get the test case settings
                SELECT rollback_code 
                INTO perform_rollback
                FROM pgunit.get_test_settings(test_function_name);

                --- Obtain the unit test code
                unit_test_code = pgunit.get_unittest_code(test_function_name);
            
                --- Build the test case function
                test_function_details = pgunit.generate_testcase_code(test_function_name);
                test_function_code_name = test_function_details.test_code_function_name;
                RAISE NOTICE 'Test Function : %',test_function_name;
                --- RAISE NOTICE 'Test Function Code : %',unit_test_code;

                --- Count the tests in the test function
                test_count_in_test_function = pgunit.count_test_suite_sections(unit_test_code,'TEST');
                RAISE NOTICE 'Test Cases in Function : % tests',test_count_in_test_function;

                --- Increment the number of tests
                tests_cases = tests_cases + test_count_in_test_function;
                
                --- Validate the unit test code
                PERFORM pgunit.validate_test_suite(unit_test_code);

                --- Execute the dynamically generated function and loop through its rows
                SET client_min_messages TO 'WARNING';
                FOR test_result IN EXECUTE format('SELECT section, description, passed, errormessage, test_duration FROM %s', test_function_code_name)
                LOOP
                    --- Ensure that the user is only informed about information that might be helpful
                    SET client_min_messages TO 'NOTICE';

                    --- Record the result
                    IF test_result.passed THEN

                        if TRIM(UPPER(test_result.section)) = 'SETUP' THEN

                            if LENGTH(TRIM(test_result.description)) > 0 then
                                RAISE NOTICE 'SETUP : % - OK (% ms)', 
                                test_result.description, 
                                test_result.test_duration;
                            ELSE

                                RAISE NOTICE 'SETUP : OK (% ms)', 
                                test_result.test_duration;

                            END IF;

                        ELSE
                            --- Output the result of the test
                            RAISE NOTICE 'TEST : % - OK (% ms)',  
                                test_result.description, 
                                test_result.test_duration;

                            --- Increment global passed counter only if the section is 'test'
                            IF lower(test_result.section) = 'test' THEN
                                passed = passed + 1;
                            END IF;
                        END IF;
                    ELSE
                        RAISE NOTICE '% - % - Failed (% ms)', 
                            test_result.section, 
                            test_result.description, 
                            test_result.test_duration;
                        RAISE NOTICE 'ERROR : %', test_result.errormessage;
                        
                        --- Increment global failed counter only if the section is 'test'
                        IF lower(test_result.section) = 'test' THEN
                            failed = failed + 1;
                        END IF;
                    END IF;
  
                END LOOP;

                --- Ensure that the user is informed about errors that caused the current command to abort.
                SET client_min_messages TO 'ERROR'; 
                
                --- Rollback all changes 
                IF perform_rollback THEN
                    RAISE EXCEPTION 'ROLLBACK';
                END IF;
  
                --- Remove the function
	            EXECUTE 'DROP FUNCTION IF EXISTS ' || test_function_code_name; 
  
            EXCEPTION
                WHEN raise_exception THEN
                    --- If the error is not a rollback then we need to record it
                    IF SQLERRM <> 'ROLLBACK' THEN
                        RAISE NOTICE '%', SQLERRM;
                    END IF;
            
                WHEN others THEN 
                    RAISE NOTICE '%', SQLERRM;
            END;

            IF current_test_loop_position < array_length(test_functions_array, 1) THEN
                SET client_min_messages TO 'NOTICE';
                RAISE NOTICE '------------------------------------------------------';
            END IF;

        END LOOP;

    END IF;

     --- Ensure that the user is only informed about information that might be helpful
    SET client_min_messages TO 'NOTICE';

    --- Calculate and show the total length of time it has taken to run all of the tests
    testrunner_execution_time_taken = date_trunc('millisecond', clock_timestamp() - testrunner_execution_timing_start);
        
    ---
    --- Display the details 
    ---

    --- Update the tests not run
    tests_cases_not_run = tests_cases - (passed+failed);

    --- Display the details
    RAISE NOTICE '======================================================';
    RAISE NOTICE 'Total Execution Time: %', testrunner_execution_time_taken;
    RAISE NOTICE 'Total Number of functions with test cases : %',test_case_functions;
    RAISE NOTICE 'Total Number of Tests : %', tests_cases;
    RAISE NOTICE 'Total Number of Tests not executed : %', tests_cases_not_run;
    RAISE NOTICE 'Passed : %', passed;
    RAISE NOTICE 'Failed : %', failed;

    --- Append the current values of (tests, passed, failed) into the return table
    RETURN NEXT;
    
    --- Hand control back to the caller and deliver the rows
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql;