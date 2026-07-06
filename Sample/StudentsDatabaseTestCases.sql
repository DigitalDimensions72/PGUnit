-- ====================================================================
-- Tool Name: StudentsDatabaseTestCases.sql
-- Description: The test cases for the sample database for use with PGUnit
--
-- Copyright (c) 2026, John Clarke
-- Licensed under the PostgreSQL License. 
-- See the LICENSE file in the project root for full license text.
-- ====================================================================

/*

	The Students Exam Results Database Test Cases

*/


/*

	The Unit Tests that will be used

*/

---
--- Test Cases to test Normal Conditions
---

CREATE OR REPLACE FUNCTION pgunittraining.test_fail_result()
RETURNS TABLE(code VARCHAR) AS
$body$
    select pgunit.testcase(
	$sql$
		-- @variables
		result TEXT;

        -- @test(description = Check that pgunittraining.getgrade returns a pass grade)
        result = pgunittraining.getgrade(29);
		assert result = 'FAIL','The Result is not Fail';
    
    $sql$
);
$body$
    LANGUAGE sql;

--
-- Test case to test Pass Result
--
CREATE OR REPLACE FUNCTION pgunittraining.test_pass_result() 
RETURNS TABLE(code VARCHAR) AS
$body$
	SELECT pgunit.testcase(
    $sql$
		-- @variables
		result TEXT;

		-- @test(description = Check that pgunittraining.getgrade returns a pass grade)
        result = pgunittraining.getgrade(49);
		assert result = 'PASS','The Result is not PASS';
		
    $sql$
);
$body$
    LANGUAGE sql;
	
--
-- Test case to test Merit Result
--
CREATE OR REPLACE FUNCTION pgunittraining.test_merit_result () 
RETURNS TABLE(code VARCHAR) AS
$body$
SELECT pgunit.testcase(
    $sql$
		-- @variables
		result TEXT;

		-- @test(description = Check that pgunittraining.getgrade returns a merit grade)
        result = pgunittraining.getgrade(69);
		assert result = 'MERIT','The Result is not MERIT';
        
    $sql$
);
$body$
    LANGUAGE sql;	
	
--
-- Test case to test Distinction Result
--
CREATE OR REPLACE FUNCTION pgunittraining.test_distinction_result () 
RETURNS TABLE(code VARCHAR) AS
$body$
SELECT pgunit.testcase(
    $sql$
		-- @variables
		result TEXT;

		-- @test(description = Check that pgunittraining.getgrade returns a distinction grade)
		result = pgunittraining.getgrade(89);
		assert result = 'DISTINCTION','The Result is not DISTINCTION';
        
    $sql$
);
$body$
    LANGUAGE sql;		
	
---
--- Test Cases to test Unexpected Conditions
---

--- 
--- Test the getgrade function where the function correctly handles an invalid value : result < 0 should return VOID
---
CREATE OR REPLACE FUNCTION pgunittraining.test_badgrade1_result () 
RETURNS TABLE(code VARCHAR) AS
$body$
SELECT pgunit.testcase(
    $sql$
		-- @variables
		result TEXT;

		-- @test(description = Check that pgunittraining.getgrade traps an invalid result of -1)
		result = pgunittraining.getgrade(-1);
		assert result = 'VOID','The Result is not VOID';

    $sql$
);
$body$
    LANGUAGE sql;			
	
--- 
--- Test the getgrade function where the function correctly handles an invalid value : result < 0 or result > 100 should return VOID
---
CREATE OR REPLACE FUNCTION pgunittraining.test_badgrade2_result () 
RETURNS TABLE(code VARCHAR) AS
$body$
SELECT pgunit.testcase(
    $sql$
		-- @variables
		result TEXT;

		-- @test(description = Check that pgunittraining.getgrade traps an invalid result of -1)
		result = pgunittraining.getgradebroken(-1);
		assert result = 'VOID','The Result is not VOID';
    $sql$
);
$body$
    LANGUAGE sql;				

--- 
--- Test the getgrade function where the function correctly handles an invalid value : result < 0 or result > 100 should return VOID
---
CREATE OR REPLACE FUNCTION pgunittraining.test_badgrade3_result () 
RETURNS TABLE(code VARCHAR) AS
$body$
SELECT pgunit.testcase(
   $sql$
		-- @variables
		result TEXT;

		-- @test(description = Check that pgunittraining.getgrade traps an invalid result of 101)
		result = pgunittraining.getgrade(101);
		assert result = 'VOID','The Result is not VOID';
    $sql$
);
$body$
    LANGUAGE sql;				

--- 
--- Test the getgrade function where the function correctly handles an invalid value : result < 0 or result > 100 should return VOID
---
CREATE OR REPLACE FUNCTION pgunittraining.test_badgrade4_result () 
RETURNS TABLE(code VARCHAR) AS
$body$
SELECT pgunit.testcase(
   $sql$
   		-- @variables
		result TEXT;

		-- @test(description = Check that pgunittraining.getgrade traps an invalid result of 101)
		result = pgunittraining.getgradebroken(101);
		assert result = 'VOID','The Result is not VOID';

    $sql$
);
$body$
    LANGUAGE sql;				
	
	
---
--- Test Cases to test Boundary Conditions
---	

--
-- Test case to test boundary results for Fail Result
--
CREATE OR REPLACE FUNCTION pgunittraining.test_boundary_fail_result () 
RETURNS TABLE(code VARCHAR) AS
$body$
SELECT pgunit.testcase(
   $sql$
		---
		--- Lower Boundary : -1 gives a result of VOID, 0 and 1 gives a result of FAIL
		---

   		-- @variables
		result TEXT;

		-- @test(description = Check that pgunittraining.getgrade returns VOID for a grade of -1)
		result = pgunittraining.getgrade(-1);
		assert result = 'VOID','The Result is not VOID';

		-- @test(description = Check that pgunittraining.getgrade returns FAIL for a grade of 0)
		result = pgunittraining.getgrade(0);
		assert result = 'FAIL','The Result is not FAIL';

		-- @test(description = Check that pgunittraining.getgrade returns FAIL for a grade of 1)
		result = pgunittraining.getgrade(1);
		assert result = 'FAIL','The Result is not FAIL';
 		
		---
		--- Upper Boundary : 38 and 39 gives a result of FAIL, 40 gives a result of PASS
		---
	
		-- @test(description = Check that pgunittraining.getgrade returns FAIL for a grade of 38)
 		result = pgunittraining.getgrade(38);
		assert result = 'FAIL','The Result is not FAIL';

		-- @test(description = Check that pgunittraining.getgrade returns FAIL for a grade of 39)
 		result = pgunittraining.getgrade(39);
		assert result = 'FAIL','The Result is not FAIL';
 
		-- @test(description = Check that pgunittraining.getgrade returns PASS for a grade of 40)
 		result = pgunittraining.getgrade(40);
		assert result = 'PASS','The Result is not PASS';
    $sql$		
);
$body$
    LANGUAGE sql;

--
-- Test case to test boundary results for Pass Result
--
CREATE OR REPLACE FUNCTION pgunittraining.test_boundary_pass_result () 
RETURNS TABLE(code VARCHAR) AS
$body$
SELECT pgunit.testcase(
   $sql$
		---
		--- Lower Boundary : 39 gives a result of FAIL, 40 and 41 gives a result of PASS
		---

		-- @variables
		result TEXT;

		-- @test(description = Check that pgunittraining.getgrade returns FAIL for a grade of 39)
 		result = pgunittraining.getgrade(39);
		assert result = 'FAIL','The Result is not FAIL';
 
		-- @test(description = Check that pgunittraining.getgrade returns PASS for a grade of 40)
 		result = pgunittraining.getgrade(40);
		assert result = 'PASS','The Result is not PASS';

		-- @test(description = Check that pgunittraining.getgrade returns PASS for a grade of 41)
 		result = pgunittraining.getgrade(41);
		assert result = 'PASS','The Result is not PASS';
 		
		---
		--- Upper Boundary : 58 and 59 gives a result of PASS, 60 gives a result of MERIT
		---

		-- @test(description = Check that pgunittraining.getgrade returns PASS for a grade of 58)
 		result = pgunittraining.getgrade(58);
		assert result = 'PASS','The Result is not PASS';
 
		-- @test(description = Check that pgunittraining.getgrade returns PASS for a grade of 59)
 		result = pgunittraining.getgrade(59);
		assert result = 'PASS','The Result is not PASS';

		-- @test(description = Check that pgunittraining.getgrade returns MERIT for a grade of 60)
 		result = pgunittraining.getgrade(60);
		assert result = 'MERIT','The Result is not MERIT';
 
    $sql$		
);
$body$
    LANGUAGE sql;

--
-- Test case to test boundary results for Merit Result
--
CREATE OR REPLACE FUNCTION pgunittraining.test_boundary_merit_result () 
RETURNS TABLE(code VARCHAR) AS
$body$
SELECT pgunit.testcase(
   $sql$
	
		---
		--- Lower Boundary : 59 gives a result of PASS, 60 and 61 gives a result of MERIT
		---

		-- @variables
		result TEXT;

		-- @test(description = Check that pgunittraining.getgrade returns PASS for a grade of 59)
 		result = pgunittraining.getgrade(59);
		assert result = 'PASS','The Result is not PASS';
        
		-- @test(description = Check that pgunittraining.getgrade returns MERIT for a grade of 60)
 		result = pgunittraining.getgrade(60);
		assert result = 'MERIT','The Result is not MERIT';
 
		-- @test(description = Check that pgunittraining.getgrade returns MERIT for a grade of 61)
 		result = pgunittraining.getgrade(61);
		assert result = 'MERIT','The Result is not MERIT';
		
		---
		--- Upper Boundary : 78 and 79 gives a result of MERIT, 60 gives a result of DISTINCTION
		---
	
		-- @test(description = Check that pgunittraining.getgrade returns MERIT for a grade of 78)
 		result = pgunittraining.getgrade(78);
		assert result = 'MERIT','The Result is not MERIT';

		-- @test(description = Check that pgunittraining.getgrade returns MERIT for a grade of 79)
 		result = pgunittraining.getgrade(79);
		assert result = 'MERIT','The Result is not MERIT';

		-- @test(description = Check that pgunittraining.getgrade returns DISTINCTION for a grade of 80)
 		result = pgunittraining.getgrade(80);
		assert result = 'DISTINCTION','The Result is not DISTINCTION';
 
    $sql$		

);
$body$
    LANGUAGE sql;

--
-- Test case to test boundary results for Distinction Result
--
CREATE OR REPLACE FUNCTION pgunittraining.test_boundary_distinction_result () 
RETURNS TABLE(code VARCHAR) AS
$body$
SELECT pgunit.testcase(
   $sql$
	
		---
		--- Lower Boundary : 79 gives a result of MERIT, 80 and 81 gives a result of DISTINCTION
		---

		-- @variables
		result TEXT;
	
		-- @test(description = Check that pgunittraining.getgrade returns MERIT for a grade of 79)
 		result = pgunittraining.getgrade(79);
		assert result = 'MERIT','The Result is not MERIT';

		-- @test(description = Check that pgunittraining.getgrade returns DISTINCTION for a grade of 80)
 		result = pgunittraining.getgrade(80);
		assert result = 'DISTINCTION','The Result is not DISTINCTION';

		-- @test(description = Check that pgunittraining.getgrade returns DISTINCTION for a grade of 81)
 		result = pgunittraining.getgrade(81);
		assert result = 'DISTINCTION','The Result is not DISTINCTION';
		
		---
		--- Upper Boundary : 99 and 100 gives a result of DISTINCTION, 101 gives a result of VOID
		---
	
		-- @test(description = Check that pgunittraining.getgrade returns DISTINCTION for a grade of 99)
 		result = pgunittraining.getgrade(99);
		assert result = 'DISTINCTION','The Result is not DISTINCTION';

		-- @test(description = Check that pgunittraining.getgrade returns DISTINCTION for a grade of 100)
 		result = pgunittraining.getgrade(100);
		assert result = 'DISTINCTION','The Result is not DISTINCTION';

		-- @test(description = Check that pgunittraining.getgrade returns VOID for a grade of 101)
 		result = pgunittraining.getgrade(101);
		assert result = 'VOID','The Result is not VOID';
 
    $sql$		
);
$body$
    LANGUAGE sql;
	
/*

		Checking values from SQL Queries
		
*/
		
---
--- Checking that the firstname is Ila and the surname is Barela for the student with the studentid of 1
---	
--- This test will work
---	
CREATE OR REPLACE FUNCTION pgunittraining.test_check_student_name () 
RETURNS TABLE(code VARCHAR) AS
$body$
SELECT pgunit.testcase(
   $sql$

   		-- @variables
		firstname_test TEXT;
		surname_test TEXT;

		-- @test(description = Check that the firstname for the student with the id of 1 is Ila)
		Select firstname into firstname_test 
		from pgunittraining.students where 
		studentid = 1;

		assert firstname_test = 'Ila','Firstname is not Ila';
        
		-- @test(description = Check that the surname for the student with the id of 1 is Barela)
		Select surname into surname_test 
		from pgunittraining.students 
		where studentid = 1;

		assert surname_test = 'Barela','Surname is not Barela';

    $sql$
);
$body$
    LANGUAGE sql;			
	
/*

	Checking Complete Tables

*/	

---
--- Checking that the results from the pgunittraining.studentsgrades view are as we expect them
---

---
--- Checking that the pgunittraining.studentsgrades view provides the expected results
---	
--- This test will pass
---
CREATE OR REPLACE FUNCTION pgunittraining.test_check_studentsgrades1 () 
RETURNS TABLE(code VARCHAR) AS
$body$

SELECT pgunit.testcase(
   $sql$
		-- @setup(description = Create the expected results table)

        --- Create the expected results table
		drop table if exists temp.expected_studentsgrades;
		create table temp.expected_studentsgrades
		(
			studentid INTEGER,
			firstname VARCHAR,
			surname VARCHAR,
			year INTEGER,
			coursecode VARCHAR,
			coursename VARCHAR,
			result INTEGER,
			grade VARCHAR
		);
		
		insert into temp.expected_studentsgrades(studentid,firstname,surname,year,coursecode,coursename,result,grade)
		values
		(18,'Velva','Winkles',1989,'MUS147','HOW TO HUM: LECTURE AND LAB',43,'PASS'),
		(16,'Sid','Arnhold',1981,'MUS147','HOW TO HUM: LECTURE AND LAB',62,'MERIT'),
		(13,'Rubin','Tylor',2015,'MUS147','HOW TO HUM: LECTURE AND LAB',22,'FAIL'),
		(10,'Lauryn','Leaks',2016,'MUS147','HOW TO HUM: LECTURE AND LAB',8,'FAIL'),
		(11,'Melida','Belizaire',1977,'HIS024','U.S. HISTORY SINCE ABOUT AN HOUR AGO',86,'DISTINCTION'),
		(11,'Melida','Belizaire',1975,'HIS024','U.S. HISTORY SINCE ABOUT AN HOUR AGO',71,'MERIT'),
		(9,'Tonita','Ulm',2015,'HIS024','U.S. HISTORY SINCE ABOUT AN HOUR AGO',23,'FAIL'),
		(4,'Britany','Mullin',2008,'HIS024','U.S. HISTORY SINCE ABOUT AN HOUR AGO',79,'MERIT'),
		(2,'Gloria','Lafollette',1989,'HIS024','U.S. HISTORY SINCE ABOUT AN HOUR AGO',26,'FAIL'),
		(17,'Nyla','Harcrow',1972,'GEO222','COUNTRIES THAT ARE ORANGE ON MAPS',52,'PASS'),
		(9,'Tonita','Ulm',1992,'GEO222','COUNTRIES THAT ARE ORANGE ON MAPS',86,'DISTINCTION'),
		(1,'Ila','Barela',1991,'GEO222','COUNTRIES THAT ARE ORANGE ON MAPS',70,'MERIT'),
		(17,'Nyla','Harcrow',1991,'ENG537','SURVEY IN ENG LIT: SIR FRANCIS BACON AND LORD HENRY SAUSAGE',41,'PASS'),
		(14,'Khalilah','Lazo',1994,'ENG537','SURVEY IN ENG LIT: SIR FRANCIS BACON AND LORD HENRY SAUSAGE',72,'MERIT'),
		(7,'Daniel','Igoe',1976,'ENG537','SURVEY IN ENG LIT: SIR FRANCIS BACON AND LORD HENRY SAUSAGE',17,'FAIL'),
		(11,'Melida','Belizaire',2003,'POLS834','U.S. DOMESTIC POLICY: IF FROGS COULD VOTE',70,'MERIT'),
		(17,'Nyla','Harcrow',1995,'ANT248','AMISH PARTY GAMES',77,'MERIT'),
		(6,'Leia','Hansford',1978,'ANT248','AMISH PARTY GAMES',78,'MERIT'),
		(5,'Lemuel','Maury',1989,'ANT248','AMISH PARTY GAMES',69,'MERIT'),
		(20,'Tajuana','Jarvie',1978,'FR106','ELEMENTARY FRENCH TOAST',92,'DISTINCTION'),
		(20,'Tajuana','Jarvie',1994,'FR106','ELEMENTARY FRENCH TOAST',3,'FAIL'),
		(18,'Velva','Winkles',1985,'FR106','ELEMENTARY FRENCH TOAST',31,'FAIL'),
		(14,'Khalilah','Lazo',2005,'FR106','ELEMENTARY FRENCH TOAST',60,'MERIT'),
		(12,'Irina','Boruff',1974,'FR106','ELEMENTARY FRENCH TOAST',99,'DISTINCTION'),
		(2,'Gloria','Lafollette',2015,'FR106','ELEMENTARY FRENCH TOAST',89,'DISTINCTION'),
		(6,'Leia','Hansford',2007,'COM193','TOPICS FROM "GREEN ACRES": LIFE AND TIMES OF MR. HANEY',58,'PASS'),
		(20,'Tajuana','Jarvie',2011,'CHE546','THE SCIENCE OF PLAY-DO',91,'DISTINCTION'),
		(12,'Irina','Boruff',1992,'CHE546','THE SCIENCE OF PLAY-DO',32,'FAIL'),
		(10,'Lauryn','Leaks',2010,'CHE546','THE SCIENCE OF PLAY-DO',23,'FAIL'),
		(20,'Tajuana','Jarvie',1986,'PHI101','THE RAMBLINGS OF DEAD',18,'FAIL'),
		(14,'Khalilah','Lazo',2005,'PHI101','THE RAMBLINGS OF DEAD',71,'MERIT'),
		(12,'Irina','Boruff',2016,'PHI101','THE RAMBLINGS OF DEAD',6,'FAIL'),
		(8,'Jolyn','Hunsaker',1990,'PHI101','THE RAMBLINGS OF DEAD',42,'PASS'),
		(7,'Daniel','Igoe',2010,'PHI101','THE RAMBLINGS OF DEAD',96,'DISTINCTION'),
		(6,'Leia','Hansford',1986,'PHI101','THE RAMBLINGS OF DEAD',36,'FAIL'),
		(2,'Gloria','Lafollette',2016,'ARC555','ARCHITECTURE OF THE BRADY BUNCH HOME',10,'FAIL'),
		(18,'Velva','Winkles',1986,'MOO108','THE BOVINE ERA',25,'FAIL'),
		(18,'Velva','Winkles',2004,'MOO108','THE BOVINE ERA',70,'MERIT'),
		(13,'Rubin','Tylor',1981,'MOO108','THE BOVINE ERA',93,'DISTINCTION'),
		(12,'Irina','Boruff',2003,'MOO108','THE BOVINE ERA',32,'FAIL'),
		(8,'Jolyn','Hunsaker',1997,'MOO108','THE BOVINE ERA',27,'FAIL'),
		(2,'Gloria','Lafollette',1981,'MOO108','THE BOVINE ERA',18,'FAIL'),
		(19,'Effie','Ritts',2010,'ENG327','SHAKESPEAREAN MEMOS',48,'PASS'),
		(5,'Lemuel','Maury',1990,'ANT764','NOMADIC TRIBES OF SUB-SAHARAN AFRICA THAT ARE REALLY JUST LOST',42,'PASS'),
		(3,'Shayne','Steveson',1998,'ANT764','NOMADIC TRIBES OF SUB-SAHARAN AFRICA THAT ARE REALLY JUST LOST',58,'PASS'),
		(20,'Tajuana','Jarvie',1994,'MATH001','COMPREHENSIVE STUDY OF THE NUMBER SEVEN',49,'PASS'),
		(18,'Velva','Winkles',1998,'MATH001','COMPREHENSIVE STUDY OF THE NUMBER SEVEN',26,'FAIL'),
		(10,'Lauryn','Leaks',1982,'MATH001','COMPREHENSIVE STUDY OF THE NUMBER SEVEN',48,'PASS'),
		(4,'Britany','Mullin',2009,'MATH001','COMPREHENSIVE STUDY OF THE NUMBER SEVEN',9,'FAIL'),
		(1,'Ila','Barela',2005,'MATH001','COMPREHENSIVE STUDY OF THE NUMBER SEVEN',53,'PASS'),
		(19,'Effie','Ritts',1981,'POLS497','REPUBLICAN PARTY ETHICS',94,'DISTINCTION'),
		(19,'Effie','Ritts',2015,'POLS497','REPUBLICAN PARTY ETHICS',49,'PASS'),
		(16,'Sid','Arnhold',1990,'POLS497','REPUBLICAN PARTY ETHICS',48,'PASS'),
		(13,'Rubin','Tylor',1979,'POLS497','REPUBLICAN PARTY ETHICS',90,'DISTINCTION'),
		(13,'Rubin','Tylor',1993,'POLS497','REPUBLICAN PARTY ETHICS',80,'DISTINCTION'),
		(6,'Leia','Hansford',1975,'POLS497','REPUBLICAN PARTY ETHICS',91,'DISTINCTION'),
		(11,'Melida','Belizaire',1977,'ARC123','DESIGNING MODERN CITIES USING LEGOS',81,'DISTINCTION'),
		(12,'Irina','Boruff',2013,'MATH19875','MATHEMATICS SO HARD THAT NO ONE CAN DO IT',97,'DISTINCTION'),
		(12,'Irina','Boruff',1986,'MATH19875','MATHEMATICS SO HARD THAT NO ONE CAN DO IT',90,'DISTINCTION'),
		(11,'Melida','Belizaire',1987,'MATH19875','MATHEMATICS SO HARD THAT NO ONE CAN DO IT',82,'DISTINCTION'),
		(10,'Lauryn','Leaks',2015,'MATH19875','MATHEMATICS SO HARD THAT NO ONE CAN DO IT',89,'DISTINCTION'),
		(5,'Lemuel','Maury',1981,'COM253','UNDERSTANDING THE PLOT TWISTS IN "TWIN PEAKS"',53,'PASS'),
		(19,'Effie','Ritts',1998,'A-S546','TOPICS IN MODERN ART: USING A LIVE AS A PAINT BRUSH',2,'FAIL'),
		(18,'Velva','Winkles',2000,'A-S546','TOPICS IN MODERN ART: USING A LIVE AS A PAINT BRUSH',80,'DISTINCTION'),
		(15,'Amado','Marchese',1998,'A-S546','TOPICS IN MODERN ART: USING A LIVE AS A PAINT BRUSH',25,'FAIL'),
		(7,'Daniel','Igoe',1979,'A-S546','TOPICS IN MODERN ART: USING A LIVE AS A PAINT BRUSH',96,'DISTINCTION'),
		(2,'Gloria','Lafollette',1993,'A-S546','TOPICS IN MODERN ART: USING A LIVE AS A PAINT BRUSH',0,'FAIL'),
		(19,'Effie','Ritts',2002,'HPR314','BEGINNING YAHTZEE',7,'FAIL'),
		(17,'Nyla','Harcrow',1979,'HPR314','BEGINNING YAHTZEE',77,'MERIT'),
		(2,'Gloria','Lafollette',1995,'HPR314','BEGINNING YAHTZEE',60,'MERIT'),
		(11,'Melida','Belizaire',2010,'ENG893','THE ROMANTIC PROSE OF ALAN CUTLER',9,'FAIL'),
		(4,'Britany','Mullin',1977,'ENG893','THE ROMANTIC PROSE OF ALAN CUTLER',13,'FAIL'),
		(1,'Ila','Barela',1976,'ENG893','THE ROMANTIC PROSE OF ALAN CUTLER',15,'FAIL'),
		(6,'Leia','Hansford',2013,'PHY276','HYPNOTIZING YOUR PETS',40,'PASS'),
		(5,'Lemuel','Maury',1997,'PHY276','HYPNOTIZING YOUR PETS',69,'MERIT'),
		(17,'Nyla','Harcrow',2002,'TEL115','MUNSTERS/ADDAMS FAMILY: A COMPARISON STUDY',2,'FAIL'),
		(20,'Tajuana','Jarvie',2004,'BIO654','STUDENT CENTER SOUPS',36,'FAIL'),
		(18,'Velva','Winkles',2007,'BIO654','STUDENT CENTER SOUPS',97,'DISTINCTION'),
		(15,'Amado','Marchese',2004,'BIO654','STUDENT CENTER SOUPS',23,'FAIL'),
		(6,'Leia','Hansford',1985,'POT267','POTPOURRI',68,'MERIT'),
		(6,'Leia','Hansford',2016,'POT267','POTPOURRI',73,'MERIT'),
		(18,'Velva','Winkles',1982,'ENG690','STOOGE CRITICISM: THE SHEMP YEARS',67,'MERIT'),
		(17,'Nyla','Harcrow',1998,'ENG690','STOOGE CRITICISM: THE SHEMP YEARS',33,'FAIL'),
		(17,'Nyla','Harcrow',2009,'ENG690','STOOGE CRITICISM: THE SHEMP YEARS',64,'MERIT'),
		(7,'Daniel','Igoe',1989,'ENG690','STOOGE CRITICISM: THE SHEMP YEARS',62,'MERIT'),
		(2,'Gloria','Lafollette',2007,'ENG690','STOOGE CRITICISM: THE SHEMP YEARS',51,'PASS'),
		(15,'Amado','Marchese',2008,'MUS532','THE BAGPIPES GO DISCO',28,'FAIL'),
		(13,'Rubin','Tylor',1988,'MUS532','THE BAGPIPES GO DISCO',21,'FAIL'),
		(19,'Effie','Ritts',2014,'MATH476','LEARNING POSSIBLE LOTTERY NUMBERS',21,'FAIL'),
		(17,'Nyla','Harcrow',1989,'MATH476','LEARNING POSSIBLE LOTTERY NUMBERS',14,'FAIL'),
		(16,'Sid','Arnhold',1973,'MATH476','LEARNING POSSIBLE LOTTERY NUMBERS',90,'DISTINCTION'),
		(13,'Rubin','Tylor',2011,'MATH476','LEARNING POSSIBLE LOTTERY NUMBERS',22,'FAIL'),
		(4,'Britany','Mullin',1982,'MATH476','LEARNING POSSIBLE LOTTERY NUMBERS',54,'PASS'),
		(7,'Daniel','Igoe',1982,'BUS109','NEIL BUSH INVESTMENT SEMINAR',55,'PASS'),
		(6,'Leia','Hansford',2002,'BUS109','NEIL BUSH INVESTMENT SEMINAR',62,'MERIT'),
		(9,'Tonita','Ulm',1984,'ZGH786','INTRO AM OP ED ACK OOP',69,'MERIT'),
		(16,'Sid','Arnhold',1984,'HRP192','TAKING DOWN THE VOLLEYBALL NET',26,'FAIL'),
		(16,'Sid','Arnhold',1988,'HRP192','TAKING DOWN THE VOLLEYBALL NET',58,'PASS'),
		(9,'Tonita','Ulm',1973,'HRP192','TAKING DOWN THE VOLLEYBALL NET',59,'PASS'),
		(6,'Leia','Hansford',1989,'HRP192','TAKING DOWN THE VOLLEYBALL NET',18,'FAIL'),
		(19,'Effie','Ritts',2012,'SCH465','UNDERSTANDING THE SCHEDULE BOOK',9,'FAIL');
				
		--- Get the actual results
		drop table if exists temp.actual_studentsgrades;
		create table temp.actual_studentsgrades as
		select * from pgunittraining.studentsgrades;
		
 		-- @test(description = Check that the expected_studentsgrades table matches the actual_studentsgrades table)
        PERFORM pgunitutils.compare_tables('temp.expected_studentsgrades','temp.actual_studentsgrades');
    $sql$		
);
$body$
    LANGUAGE sql;			

---
--- Checking that the pgunittraining.studentsgrades view provides the expected results
---	
--- This test will fail because the first record inserted into the expected results doesn't match the actual results
---
CREATE OR REPLACE FUNCTION pgunittraining.test_check_studentsgrades2 () 
RETURNS TABLE(code VARCHAR) AS
$body$
SELECT pgunit.testcase(
    $sql$
		-- @setup(description = Create the expected results table)

       --- Create the expected results table
		drop table if exists temp.expected_studentsgrades;
		create table temp.expected_studentsgrades
		(
			studentid INTEGER,
			firstname VARCHAR,
			surname VARCHAR,
			year INTEGER,
			coursecode VARCHAR,
			coursename VARCHAR,
			result INTEGER,
			grade VARCHAR
		);
		
		insert into temp.expected_studentsgrades(studentid,firstname,surname,year,coursecode,coursename,result,grade)
		values
		(18,'James','Hunt',1989,'MUS147','HOW TO HUM: LECTURE AND LAB',43,'PASS'),
		(16,'Sid','Arnhold',1981,'MUS147','HOW TO HUM: LECTURE AND LAB',62,'MERIT'),
		(13,'Rubin','Tylor',2015,'MUS147','HOW TO HUM: LECTURE AND LAB',22,'FAIL'),
		(10,'Lauryn','Leaks',2016,'MUS147','HOW TO HUM: LECTURE AND LAB',8,'FAIL'),
		(11,'Melida','Belizaire',1977,'HIS024','U.S. HISTORY SINCE ABOUT AN HOUR AGO',86,'DISTINCTION'),
		(11,'Melida','Belizaire',1975,'HIS024','U.S. HISTORY SINCE ABOUT AN HOUR AGO',71,'MERIT'),
		(9,'Tonita','Ulm',2015,'HIS024','U.S. HISTORY SINCE ABOUT AN HOUR AGO',23,'FAIL'),
		(4,'Britany','Mullin',2008,'HIS024','U.S. HISTORY SINCE ABOUT AN HOUR AGO',79,'MERIT'),
		(2,'Gloria','Lafollette',1989,'HIS024','U.S. HISTORY SINCE ABOUT AN HOUR AGO',26,'FAIL'),
		(17,'Nyla','Harcrow',1972,'GEO222','COUNTRIES THAT ARE ORANGE ON MAPS',52,'PASS'),
		(9,'Tonita','Ulm',1992,'GEO222','COUNTRIES THAT ARE ORANGE ON MAPS',86,'DISTINCTION'),
		(1,'Ila','Barela',1991,'GEO222','COUNTRIES THAT ARE ORANGE ON MAPS',70,'MERIT'),
		(17,'Nyla','Harcrow',1991,'ENG537','SURVEY IN ENG LIT: SIR FRANCIS BACON AND LORD HENRY SAUSAGE',41,'PASS'),
		(14,'Khalilah','Lazo',1994,'ENG537','SURVEY IN ENG LIT: SIR FRANCIS BACON AND LORD HENRY SAUSAGE',72,'MERIT'),
		(7,'Daniel','Igoe',1976,'ENG537','SURVEY IN ENG LIT: SIR FRANCIS BACON AND LORD HENRY SAUSAGE',17,'FAIL'),
		(11,'Melida','Belizaire',2003,'POLS834','U.S. DOMESTIC POLICY: IF FROGS COULD VOTE',70,'MERIT'),
		(17,'Nyla','Harcrow',1995,'ANT248','AMISH PARTY GAMES',77,'MERIT'),
		(6,'Leia','Hansford',1978,'ANT248','AMISH PARTY GAMES',78,'MERIT'),
		(5,'Lemuel','Maury',1989,'ANT248','AMISH PARTY GAMES',69,'MERIT'),
		(20,'Tajuana','Jarvie',1978,'FR106','ELEMENTARY FRENCH TOAST',92,'DISTINCTION'),
		(20,'Tajuana','Jarvie',1994,'FR106','ELEMENTARY FRENCH TOAST',3,'FAIL'),
		(18,'Velva','Winkles',1985,'FR106','ELEMENTARY FRENCH TOAST',31,'FAIL'),
		(14,'Khalilah','Lazo',2005,'FR106','ELEMENTARY FRENCH TOAST',60,'MERIT'),
		(12,'Irina','Boruff',1974,'FR106','ELEMENTARY FRENCH TOAST',99,'DISTINCTION'),
		(2,'Gloria','Lafollette',2015,'FR106','ELEMENTARY FRENCH TOAST',89,'DISTINCTION'),
		(6,'Leia','Hansford',2007,'COM193','TOPICS FROM "GREEN ACRES": LIFE AND TIMES OF MR. HANEY',58,'PASS'),
		(20,'Tajuana','Jarvie',2011,'CHE546','THE SCIENCE OF PLAY-DO',91,'DISTINCTION'),
		(12,'Irina','Boruff',1992,'CHE546','THE SCIENCE OF PLAY-DO',32,'FAIL'),
		(10,'Lauryn','Leaks',2010,'CHE546','THE SCIENCE OF PLAY-DO',23,'FAIL'),
		(20,'Tajuana','Jarvie',1986,'PHI101','THE RAMBLINGS OF DEAD',18,'FAIL'),
		(14,'Khalilah','Lazo',2005,'PHI101','THE RAMBLINGS OF DEAD',71,'MERIT'),
		(12,'Irina','Boruff',2016,'PHI101','THE RAMBLINGS OF DEAD',6,'FAIL'),
		(8,'Jolyn','Hunsaker',1990,'PHI101','THE RAMBLINGS OF DEAD',42,'PASS'),
		(7,'Daniel','Igoe',2010,'PHI101','THE RAMBLINGS OF DEAD',96,'DISTINCTION'),
		(6,'Leia','Hansford',1986,'PHI101','THE RAMBLINGS OF DEAD',36,'FAIL'),
		(2,'Gloria','Lafollette',2016,'ARC555','ARCHITECTURE OF THE BRADY BUNCH HOME',10,'FAIL'),
		(18,'Velva','Winkles',1986,'MOO108','THE BOVINE ERA',25,'FAIL'),
		(18,'Velva','Winkles',2004,'MOO108','THE BOVINE ERA',70,'MERIT'),
		(13,'Rubin','Tylor',1981,'MOO108','THE BOVINE ERA',93,'DISTINCTION'),
		(12,'Irina','Boruff',2003,'MOO108','THE BOVINE ERA',32,'FAIL'),
		(8,'Jolyn','Hunsaker',1997,'MOO108','THE BOVINE ERA',27,'FAIL'),
		(2,'Gloria','Lafollette',1981,'MOO108','THE BOVINE ERA',18,'FAIL'),
		(19,'Effie','Ritts',2010,'ENG327','SHAKESPEAREAN MEMOS',48,'PASS'),
		(5,'Lemuel','Maury',1990,'ANT764','NOMADIC TRIBES OF SUB-SAHARAN AFRICA THAT ARE REALLY JUST LOST',42,'PASS'),
		(3,'Shayne','Steveson',1998,'ANT764','NOMADIC TRIBES OF SUB-SAHARAN AFRICA THAT ARE REALLY JUST LOST',58,'PASS'),
		(20,'Tajuana','Jarvie',1994,'MATH001','COMPREHENSIVE STUDY OF THE NUMBER SEVEN',49,'PASS'),
		(18,'Velva','Winkles',1998,'MATH001','COMPREHENSIVE STUDY OF THE NUMBER SEVEN',26,'FAIL'),
		(10,'Lauryn','Leaks',1982,'MATH001','COMPREHENSIVE STUDY OF THE NUMBER SEVEN',48,'PASS'),
		(4,'Britany','Mullin',2009,'MATH001','COMPREHENSIVE STUDY OF THE NUMBER SEVEN',9,'FAIL'),
		(1,'Ila','Barela',2005,'MATH001','COMPREHENSIVE STUDY OF THE NUMBER SEVEN',53,'PASS'),
		(19,'Effie','Ritts',1981,'POLS497','REPUBLICAN PARTY ETHICS',94,'DISTINCTION'),
		(19,'Effie','Ritts',2015,'POLS497','REPUBLICAN PARTY ETHICS',49,'PASS'),
		(16,'Sid','Arnhold',1990,'POLS497','REPUBLICAN PARTY ETHICS',48,'PASS'),
		(13,'Rubin','Tylor',1979,'POLS497','REPUBLICAN PARTY ETHICS',90,'DISTINCTION'),
		(13,'Rubin','Tylor',1993,'POLS497','REPUBLICAN PARTY ETHICS',80,'DISTINCTION'),
		(6,'Leia','Hansford',1975,'POLS497','REPUBLICAN PARTY ETHICS',91,'DISTINCTION'),
		(11,'Melida','Belizaire',1977,'ARC123','DESIGNING MODERN CITIES USING LEGOS',81,'DISTINCTION'),
		(12,'Irina','Boruff',2013,'MATH19875','MATHEMATICS SO HARD THAT NO ONE CAN DO IT',97,'DISTINCTION'),
		(12,'Irina','Boruff',1986,'MATH19875','MATHEMATICS SO HARD THAT NO ONE CAN DO IT',90,'DISTINCTION'),
		(11,'Melida','Belizaire',1987,'MATH19875','MATHEMATICS SO HARD THAT NO ONE CAN DO IT',82,'DISTINCTION'),
		(10,'Lauryn','Leaks',2015,'MATH19875','MATHEMATICS SO HARD THAT NO ONE CAN DO IT',89,'DISTINCTION'),
		(5,'Lemuel','Maury',1981,'COM253','UNDERSTANDING THE PLOT TWISTS IN "TWIN PEAKS"',53,'PASS'),
		(19,'Effie','Ritts',1998,'A-S546','TOPICS IN MODERN ART: USING A LIVE AS A PAINT BRUSH',2,'FAIL'),
		(18,'Velva','Winkles',2000,'A-S546','TOPICS IN MODERN ART: USING A LIVE AS A PAINT BRUSH',80,'DISTINCTION'),
		(15,'Amado','Marchese',1998,'A-S546','TOPICS IN MODERN ART: USING A LIVE AS A PAINT BRUSH',25,'FAIL'),
		(7,'Daniel','Igoe',1979,'A-S546','TOPICS IN MODERN ART: USING A LIVE AS A PAINT BRUSH',96,'DISTINCTION'),
		(2,'Gloria','Lafollette',1993,'A-S546','TOPICS IN MODERN ART: USING A LIVE AS A PAINT BRUSH',0,'FAIL'),
		(19,'Effie','Ritts',2002,'HPR314','BEGINNING YAHTZEE',7,'FAIL'),
		(17,'Nyla','Harcrow',1979,'HPR314','BEGINNING YAHTZEE',77,'MERIT'),
		(2,'Gloria','Lafollette',1995,'HPR314','BEGINNING YAHTZEE',60,'MERIT'),
		(11,'Melida','Belizaire',2010,'ENG893','THE ROMANTIC PROSE OF ALAN CUTLER',9,'FAIL'),
		(4,'Britany','Mullin',1977,'ENG893','THE ROMANTIC PROSE OF ALAN CUTLER',13,'FAIL'),
		(1,'Ila','Barela',1976,'ENG893','THE ROMANTIC PROSE OF ALAN CUTLER',15,'FAIL'),
		(6,'Leia','Hansford',2013,'PHY276','HYPNOTIZING YOUR PETS',40,'PASS'),
		(5,'Lemuel','Maury',1997,'PHY276','HYPNOTIZING YOUR PETS',69,'MERIT'),
		(17,'Nyla','Harcrow',2002,'TEL115','MUNSTERS/ADDAMS FAMILY: A COMPARISON STUDY',2,'FAIL'),
		(20,'Tajuana','Jarvie',2004,'BIO654','STUDENT CENTER SOUPS',36,'FAIL'),
		(18,'Velva','Winkles',2007,'BIO654','STUDENT CENTER SOUPS',97,'DISTINCTION'),
		(15,'Amado','Marchese',2004,'BIO654','STUDENT CENTER SOUPS',23,'FAIL'),
		(6,'Leia','Hansford',1985,'POT267','POTPOURRI',68,'MERIT'),
		(6,'Leia','Hansford',2016,'POT267','POTPOURRI',73,'MERIT'),
		(18,'Velva','Winkles',1982,'ENG690','STOOGE CRITICISM: THE SHEMP YEARS',67,'MERIT'),
		(17,'Nyla','Harcrow',1998,'ENG690','STOOGE CRITICISM: THE SHEMP YEARS',33,'FAIL'),
		(17,'Nyla','Harcrow',2009,'ENG690','STOOGE CRITICISM: THE SHEMP YEARS',64,'MERIT'),
		(7,'Daniel','Igoe',1989,'ENG690','STOOGE CRITICISM: THE SHEMP YEARS',62,'MERIT'),
		(2,'Gloria','Lafollette',2007,'ENG690','STOOGE CRITICISM: THE SHEMP YEARS',51,'PASS'),
		(15,'Amado','Marchese',2008,'MUS532','THE BAGPIPES GO DISCO',28,'FAIL'),
		(13,'Rubin','Tylor',1988,'MUS532','THE BAGPIPES GO DISCO',21,'FAIL'),
		(19,'Effie','Ritts',2014,'MATH476','LEARNING POSSIBLE LOTTERY NUMBERS',21,'FAIL'),
		(17,'Nyla','Harcrow',1989,'MATH476','LEARNING POSSIBLE LOTTERY NUMBERS',14,'FAIL'),
		(16,'Sid','Arnhold',1973,'MATH476','LEARNING POSSIBLE LOTTERY NUMBERS',90,'DISTINCTION'),
		(13,'Rubin','Tylor',2011,'MATH476','LEARNING POSSIBLE LOTTERY NUMBERS',22,'FAIL'),
		(4,'Britany','Mullin',1982,'MATH476','LEARNING POSSIBLE LOTTERY NUMBERS',54,'PASS'),
		(7,'Daniel','Igoe',1982,'BUS109','NEIL BUSH INVESTMENT SEMINAR',55,'PASS'),
		(6,'Leia','Hansford',2002,'BUS109','NEIL BUSH INVESTMENT SEMINAR',62,'MERIT'),
		(9,'Tonita','Ulm',1984,'ZGH786','INTRO AM OP ED ACK OOP',69,'MERIT'),
		(16,'Sid','Arnhold',1984,'HRP192','TAKING DOWN THE VOLLEYBALL NET',26,'FAIL'),
		(16,'Sid','Arnhold',1988,'HRP192','TAKING DOWN THE VOLLEYBALL NET',58,'PASS'),
		(9,'Tonita','Ulm',1973,'HRP192','TAKING DOWN THE VOLLEYBALL NET',59,'PASS'),
		(6,'Leia','Hansford',1989,'HRP192','TAKING DOWN THE VOLLEYBALL NET',18,'FAIL'),
		(19,'Effie','Ritts',2012,'SCH465','UNDERSTANDING THE SCHEDULE BOOK',9,'FAIL');
				
		--- Get the actual results
		drop table if exists temp.actual_studentsgrades;
		create table temp.actual_studentsgrades as
		select * from pgunittraining.studentsgrades;
		
 		-- @test(description = Check that the expected_studentsgrades table matches the actual_studentsgrades table)
        PERFORM pgunitutils.compare_tables('temp.expected_studentsgrades','temp.actual_studentsgrades');
    $sql$		
);
$body$
    LANGUAGE sql;			
	