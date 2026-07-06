-- ====================================================================
-- Tool Name: PGUnitUtils
-- Description: A set of utility functions for PGUnit
--
-- Copyright (c) 2026, John Clarke
-- Licensed under the PostgreSQL License. 
-- See the LICENSE file in the project root for full license text.
-- ====================================================================

--- Create the PGUnitUtils schema
DROP SCHEMA if exists PGUnitUtils CASCADE;
CREATE SCHEMA PGUnitUtils AUTHORIZATION postgres;
COMMENT ON SCHEMA PGUnitUtils IS 'Utility functions for PGUnit';

---
--- For Table Comparison
---
CREATE OR REPLACE FUNCTION PGUnitUtils.compare_tables(
    in_expected TEXT, 
    in_actual TEXT
) 
RETURNS VOID AS $BODY$
DECLARE
    _sql TEXT;
    _diff_count INT;
    _safe_expected TEXT := in_expected;
    _safe_actual TEXT := in_actual;
BEGIN
    -- 1. Build the dynamic SQL using safely quoted table names
    _sql := 'CREATE TEMP TABLE expected_actual_data_differences AS '
         || 'SELECT * FROM ' || _safe_expected
         || ' EXCEPT '
         || 'SELECT * FROM ' || _safe_actual
         || ' UNION '
         || 'SELECT * FROM ' || _safe_actual
         || ' EXCEPT '
         || 'SELECT * FROM ' || _safe_expected || ';';

    -- 2. Execute the table creation
    EXECUTE _sql;

    -- 3. Get the count of the differences
    EXECUTE 'SELECT COUNT(*) FROM expected_actual_data_differences' INTO _diff_count;

    -- 4. Clean up the temp table immediately
    DROP TABLE expected_actual_data_differences;

    -- 5. Raise an exception if the tables do not match
    IF _diff_count > 0 THEN
        RAISE EXCEPTION 'Data mismatch detected: Tables % and % are not identical. Found % differing record(s).', 
            in_expected, in_actual, _diff_count;
    END IF;

END;
$BODY$ 
    LANGUAGE plpgsql;