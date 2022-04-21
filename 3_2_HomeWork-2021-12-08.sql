/*		Marathon Event 2	*/ 

/* DDL SQL code */
CREATE TABLE OSPV_Runner (
	ID INT NOT NULL,
	First_Name VARCHAR2(30) NOT NULL,
	Last_Name VARCHAR2(30),
	DOB DATE NOT NULL,
	Sex VARCHAR2(6),
	Tshirt_Size VARCHAR2(3),
	Status INT NOT NULL,
	Pace_Interval INT NOT NULL,
	ID_start_num INT NOT NULL,
	constraint OSPV_RUNNER_PK PRIMARY KEY (ID)
	);

CREATE TABLE OSPV_Finisher (
	ID_bib_number INT NOT NULL,
	CHIP_RF_ID INT UNIQUE NOT NULL,
	Finish_Time TIMESTAMP NOT NULL,
	AVG_Pace DATE NOT NULL,
	constraint OSPV_FINISHER_PK PRIMARY KEY (ID_bib_number)
	);

CREATE TABLE OSPV_ChosenPace (
	ID_pace INT NOT NULL,
	Chosen_Pace VARCHAR2(12) NOT NULL,
	constraint OSPV_CHOSENPACE_PK PRIMARY KEY (ID_pace)
	);

CREATE TABLE OSPV_RunnerStatus (
	ID_status INT NOT NULL,
	Type VARCHAR2(10) UNIQUE NOT NULL,
	constraint OSPV_RUNNERSTATUS_PK PRIMARY KEY (ID_status)
	);

CREATE TABLE OSPV_Runner_Club (
	ID_runner INT UNIQUE NOT NULL,
	ID_Club INT
	);

CREATE TABLE OSPV_RunningClub (
	ID_Club INT NOT NULL,
	Name VARCHAR2(30) UNIQUE NOT NULL,
	City VARCHAR2(30) NOT NULL,
	Country VARCHAR2(30) NOT NULL,
	is_Pro CHAR(1) CHECK (is_Pro IN ('N','Y')) NOT NULL,
	constraint OSPV_RUNNINGCLUB_PK PRIMARY KEY (ID_Club)
	);

ALTER TABLE OSPV_Runner ADD CONSTRAINT OSPV_Runner_fk0 FOREIGN KEY (Status) REFERENCES OSPV_RunnerStatus(ID_status);
ALTER TABLE OSPV_Runner ADD CONSTRAINT OSPV_Runner_fk1 FOREIGN KEY (Pace_Interval) REFERENCES OSPV_ChosenPace(ID_pace);
ALTER TABLE OSPV_Runner ADD CONSTRAINT OSPV_Runner_fk2 FOREIGN KEY (ID_start_num) REFERENCES OSPV_Finisher(ID_bib_number);

ALTER TABLE OSPV_Runner_Club ADD CONSTRAINT OSPV_Runner_Club_fk0 FOREIGN KEY (ID_runner) REFERENCES OSPV_Runner(ID);
ALTER TABLE OSPV_Runner_Club ADD CONSTRAINT OSPV_Runner_Club_fk1 FOREIGN KEY (ID_Club) REFERENCES OSPV_RunningClub(ID_Club);


/* DML SQL code for inserting the data in the database */

--OSPV_Runner-----------------
INSERT INTO OSPV_Runner VALUES (1,	'Inglebert', 'Dovidaitis', TO_DATE('8/12/1991', 'MM/DD/YYYY'), 'M', 'S', 3, 3, 1521);
INSERT INTO OSPV_Runner VALUES (2, 'Myrtia', 'Swaden', TO_DATE('12/16/1940', 'MM/DD/YYYY'), 'F', 'L', 2, 1, 4325);
INSERT INTO OSPV_Runner VALUES (3, 'Flem', 'Clewer', TO_DATE('6/14/1967', 'MM/DD/YYYY'), 'M', 'M', 2, 4, 7643);
--OSPV_Finisher-----------------
INSERT INTO OSPV_Finisher VALUES (1521, 1234567890123, TO_TIMESTAMP('05:08:47.87', 'hh24:mi:ss.ff'), TO_DATE('05:35', 'mi:ss'));
INSERT INTO OSPV_Finisher VALUES (4325, 3456176389506, TO_TIMESTAMP('03:44:02.32', 'hh24:mi:ss.ff'), TO_DATE('03:43', 'mi:ss'));
INSERT INTO OSPV_Finisher VALUES (7643, 3456197509863, TO_TIMESTAMP('04:22:24.45', 'hh24:mi:ss.ff'), TO_DATE('04:28', 'mi:ss'));
--OSPV_ChosenPace-----------------
INSERT INTO OSPV_ChosenPace VALUES (1, '2:30 - 3:00');
INSERT INTO OSPV_ChosenPace VALUES (2, '3:00 - 3:30');
INSERT INTO OSPV_ChosenPace VALUES (3, '3:30 - 4:00');
INSERT INTO OSPV_ChosenPace VALUES (4, '4:00 - 4:30');
INSERT INTO OSPV_ChosenPace VALUES (5, '4:30 - 5:30');
--OSPV_RunnerStatus-----------------
INSERT INTO OSPV_RunnerStatus VALUES (1, 'Finished');
INSERT INTO OSPV_RunnerStatus VALUES (2, 'DNF');
INSERT INTO OSPV_RunnerStatus VALUES (3, 'DNS');
--OSPV_Runner_Club-----------------
INSERT INTO OSPV_Runner_Club VALUES (1, 3);
INSERT INTO OSPV_Runner_Club VALUES (2, NULL);
INSERT INTO OSPV_Runner_Club VALUES (3, 2);
--OSPV_RunningClub-----------------
INSERT INTO OSPV_RunningClub VALUES (1, 'Heidenreich','Itéa','Greece','Y'); 
INSERT INTO OSPV_RunningClub VALUES (2, 'Schuppe','Hongshan','China','N');
INSERT INTO OSPV_RunningClub VALUES (3, 'Bruen-Cassin','Béziers','France','Y'); 

SELECT 
	ID_bib_number,
	CHIP_RF_ID,
	TO_CHAR(finish_time, 'HH24:MI:SS.FF2'),
	TO_CHAR(AVG_Pace, 'MI:SS')
FROM OSPV_Finisher