-- ====================================================================
-- Tool Name: StudentsDatabase.sql
-- Description: A sample database for use with PGUnit
--
-- Copyright (c) 2026, John Clarke
-- Licensed under the PostgreSQL License. 
-- See the LICENSE file in the project root for full license text.
-- ====================================================================


/*

	The Students Exam Results Database

*/

--- Create the Schema
DROP SCHEMA if exists pgunittraining CASCADE;
CREATE SCHEMA pgunittraining AUTHORIZATION postgres;
COMMENT ON SCHEMA pgunittraining IS 'Students Exam Results Database';

/*

	Tables that will be used 

*/

---
--- Students Table
---

--- Create the table
drop table if exists pgunittraining.students;
create table pgunittraining.students
(
	studentid INTEGER,
	firstname VARCHAR,
	surname VARCHAR
);

--- Insert the data into the table
insert into pgunittraining.students (studentid,firstname,surname)
values
(1,'Ila','Barela'),
(2,'Gloria','Lafollette'),
(3,'Shayne','Steveson'),
(4,'Britany','Mullin'),
(5,'Lemuel','Maury'),
(6,'Leia','Hansford'),
(7,'Daniel','Igoe'),
(8,'Jolyn','Hunsaker'),
(9,'Tonita','Ulm'),
(10,'Lauryn','Leaks'),
(11,'Melida','Belizaire'),
(12,'Irina','Boruff'),
(13,'Rubin','Tylor'),
(14,'Khalilah','Lazo'),
(15,'Amado','Marchese'),
(16,'Sid','Arnhold'),
(17,'Nyla','Harcrow'),
(18,'Velva','Winkles'),
(19,'Effie','Ritts'),
(20,'Tajuana','Jarvie');

---
--- Courses Table
---

--- Create the table
drop table if exists pgunittraining.courses;
create table pgunittraining.courses
(
	courseid INTEGER,
	coursecode VARCHAR,
	coursename VARCHAR	
);

--- Insert the data into the table
insert into pgunittraining.courses (courseid,coursecode,coursename)
values
(1,'MUS147','HOW TO HUM: LECTURE AND LAB'),
(2,'HIS024','U.S. HISTORY SINCE ABOUT AN HOUR AGO'),
(3,'GEO222','COUNTRIES THAT ARE ORANGE ON MAPS'),
(4,'ENG537','SURVEY IN ENG LIT: SIR FRANCIS BACON AND LORD HENRY SAUSAGE'),
(5,'POLS834','U.S. DOMESTIC POLICY: IF FROGS COULD VOTE'),
(6,'ANT248','AMISH PARTY GAMES'),
(7,'FR106','ELEMENTARY FRENCH TOAST'),
(8,'COM193','TOPICS FROM "GREEN ACRES": LIFE AND TIMES OF MR. HANEY'),
(9,'HIS456','THE HISTORY OF SOUP'),
(10,'CHE546','THE SCIENCE OF PLAY-DO'),
(11,'PHI101','THE RAMBLINGS OF DEAD'),
(12,'ARC555','ARCHITECTURE OF THE BRADY BUNCH HOME'),
(13,'MOO108','THE BOVINE ERA'),
(14,'ENG327','SHAKESPEAREAN MEMOS'),
(15,'ANT764','NOMADIC TRIBES OF SUB-SAHARAN AFRICA THAT ARE REALLY JUST LOST'),
(16,'MATH001','COMPREHENSIVE STUDY OF THE NUMBER SEVEN'),
(17,'POLS497','REPUBLICAN PARTY ETHICS'),
(18,'ARC123','DESIGNING MODERN CITIES USING LEGOS'),
(19,'MATH19875','MATHEMATICS SO HARD THAT NO ONE CAN DO IT'),
(20,'COM253','UNDERSTANDING THE PLOT TWISTS IN "TWIN PEAKS"'),
(21,'A-S546','TOPICS IN MODERN ART: USING A LIVE AS A PAINT BRUSH'),
(22,'HPR314','BEGINNING YAHTZEE'),
(23,'ENG893','THE ROMANTIC PROSE OF ALAN CUTLER'),
(24,'PHY276','HYPNOTIZING YOUR PETS'),
(25,'TEL115','MUNSTERS/ADDAMS FAMILY: A COMPARISON STUDY'),
(26,'BIO654','STUDENT CENTER SOUPS'),
(27,'POT267','POTPOURRI'),
(28,'ENG690','STOOGE CRITICISM: THE SHEMP YEARS'),
(29,'MUS532','THE BAGPIPES GO DISCO'),
(30,'MATH476','LEARNING POSSIBLE LOTTERY NUMBERS'),
(31,'BUS109','NEIL BUSH INVESTMENT SEMINAR'),
(32,'ZGH786','INTRO AM OP ED ACK OOP'),
(33,'HRP192','TAKING DOWN THE VOLLEYBALL NET'),
(34,'SCH465','UNDERSTANDING THE SCHEDULE BOOK');

---
--- Exam Results Table
---

--- Create the table
drop table if exists pgunittraining.examresults;
create table pgunittraining.examresults
(
	studentid INTEGER,
	courseid integer,
	year integer,
	result integer
);

--- Insert the data into the table
insert into pgunittraining.examresults (studentid,courseid,year,result)
values
(13,30,2011,22),
(9,33,1973,59),
(1,23,1976,15),
(19,17,1981,94),
(11,5,2003,70),
(17,25,2002,2),
(13,13,1981,93),
(18,16,1998,26),
(6,27,1985,68),
(20,11,1986,18),
(13,17,1979,90),
(6,27,2016,73),
(11,2,1977,86),
(7,4,1976,17),
(17,22,1979,77),
(10,1,2016,8),
(15,21,1998,25),
(12,19,2013,97),
(6,6,1978,78),
(16,17,1990,48),
(20,7,1978,92),
(14,4,1994,72),
(2,7,2015,89),
(8,13,1997,27),
(17,4,1991,41),
(19,14,2010,48),
(13,17,1993,80),
(5,20,1981,53),
(4,16,2009,9),
(3,15,1998,58),
(4,30,1982,54),
(9,32,1984,69),
(1,16,2005,53),
(2,13,1981,18),
(2,12,2016,10),
(5,15,1990,42),
(17,30,1989,14),
(12,11,2016,6),
(18,13,1986,25),
(15,26,2004,23),
(18,26,2007,97),
(12,7,1974,99),
(4,2,2008,79),
(11,23,2010,9),
(12,10,1992,32),
(19,30,2014,21),
(20,16,1994,49),
(20,26,2004,36),
(7,21,1979,96),
(14,11,2005,71),
(19,17,2015,49),
(9,2,2015,23),
(6,11,1986,36),
(7,28,1989,62),
(5,6,1989,69),
(2,2,1989,26),
(11,18,1977,81),
(7,11,2010,96),
(16,33,1984,26),
(6,17,1975,91),
(10,19,2015,89),
(18,1,1989,43),
(15,29,2008,28),
(7,31,1982,55),
(18,7,1985,31),
(4,23,1977,13),
(8,11,1990,42),
(10,16,1982,48),
(17,3,1972,52),
(10,10,2010,23),
(6,33,1989,18),
(20,7,1994,3),
(12,13,2003,32),
(11,2,1975,71),
(2,28,2007,51),
(12,19,1986,90),
(17,28,1998,33),
(18,28,1982,67),
(19,22,2002,7),
(16,30,1973,90),
(6,31,2002,62),
(16,33,1988,58),
(18,21,2000,80),
(11,19,1987,82),
(14,7,2005,60),
(1,3,1991,70),
(19,21,1998,2),
(20,10,2011,91),
(19,34,2012,9),
(17,28,2009,64),
(2,21,1993,0),
(13,1,2015,22),
(6,8,2007,58),
(18,13,2004,70),
(2,22,1995,60),
(6,24,2013,40),
(17,6,1995,77),
(16,1,1981,62),
(9,3,1992,86),
(13,29,1988,21),
(5,24,1997,69);

/*

	Functions that will be used 

*/

---
--- Function that returns a grade
---

--- Working Version
CREATE or REPLACE FUNCTION pgunittraining.getgrade(result int)
	RETURNS varchar as
$body$
BEGIN
	--- If the result is less than 0 or greater than 100 then it is VOID
	if result < 0  or result > 100 then
		return 'VOID';
	end if;

	--- Results of 40 - 59 are Pass	
	if result >= 40 and result <= 59 then 
		return 'PASS';
	end if;

	--- Results of 60 - 79 are Merit
	if result >= 60 and result <= 79 then 
		return 'MERIT';
	end if;		

	--- Results of 80 - 100 are Distinction
	if result >= 80 and result <= 100 then 
		return 'DISTINCTION';			
	end if;

	--- No result has been found so the student has failed	
	return 'FAIL';
	
END
$body$
LANGUAGE plpgsql;

--- Broken Version
CREATE or REPLACE FUNCTION pgunittraining.getgradebroken(result int)
	RETURNS varchar as
$body$
BEGIN
	--- Results of 40 - 59 are Pass	
	if result >= 40 and result <= 59 then 
		return 'PASS';
	end if;

	--- Results of 60 - 79 are Merit
	if result >= 60 and result <= 79 then 
		return 'MERIT';
	end if;		

	--- Results of 80 - 100 are Distinction
	if result >= 80 and result <= 100 then 
		return 'DISTINCTION';			
	end if;

	--- No result has been found so the student has failed	
	return 'FAIL';
	
END
$body$
LANGUAGE plpgsql;


/*

	Views that will be used 

*/

---
--- The students grade view
---
create or replace view pgunittraining.studentsgrades as
select studentid,
       firstname,
	   surname,
	   year,
	   coursecode,
	   coursename,
	   result,
	   pgunittraining.getgrade(result) as grade
	   
from pgunittraining.examresults
join pgunittraining.students using (studentid)
join pgunittraining.courses using (courseid);