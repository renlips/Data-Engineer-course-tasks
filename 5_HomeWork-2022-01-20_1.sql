--=====  DEBUG SECTION  ========
DROP TABLE DE1M.OSPV_SOURCE;
DROP TABLE de1m.OSPV_STG;
DROP TABLE de1m.ospv_stg_del;
DROP TABLE de1m.OSPV_TARGET; 
DROP TABLE de1m.OSPV_META; 

SELECT * FROM DE1M.OSPV_SOURCE;
SELECT * FROM de1m.OSPV_STG; 
SELECT * FROM de1m.OSPV_STG_DEL;
SELECT * FROM de1m.OSPV_TARGET ORDER BY id,effective_from;
SELECT * FROM de1m.OSPV_META;

INSERT INTO de1m.ospv_source
--VALUES (4, 'D', current_date);
--VALUES (5, 'E', current_date);
--VALUES (6, 'F', current_date);
VALUES (7, 'G', current_date);
--VALUES (8, 'H', current_date);

UPDATE de1m.ospv_source SET val = 'X', UPDATE_DT = CURRENT_DATE WHERE id = 3
UPDATE de1m.ospv_source SET val = 'Z', UPDATE_DT = CURRENT_DATE WHERE id = 5
UPDATE de1m.ospv_source SET val = 'U', UPDATE_DT = CURRENT_DATE WHERE id = 5
UPDATE de1m.ospv_source SET val = 'Q', UPDATE_DT = CURRENT_DATE WHERE id = 2
UPDATE de1m.ospv_source SET val = 'K', UPDATE_DT = CURRENT_DATE WHERE id = 2
UPDATE de1m.ospv_source SET val = 'P', UPDATE_DT = CURRENT_DATE WHERE id = 8
DELETE FROM de1m.ospv_source WHERE id = 3;
--=============================



--===== DDL SECTION ==========
-- Create SOURCE table
CREATE TABLE de1m.ospv_source AS
SELECT * FROM de.INCREMENTAL;
-- create the STAGING empty table
CREATE TABLE de1m.ospv_stg AS
SELECT * FROM de1m.ospv_source
WHERE 1=0;
-- create the TARGET empty table
CREATE TABLE de1m.ospv_target(
	id NUMBER,
	val varchar2(50),
	effective_from DATE,
	effective_to DATE,
	deleted_flg CHAR(1) NOT NULL
	);
-- create the METADATA empty table
CREATE TABLE de1m.ospv_meta(
	schema_name VARCHAR(30),
	table_name VARCHAR2(30),
	max_effective_from DATE
	);
--First entry in META
INSERT INTO de1m.ospv_meta
VALUES ('DE1M', 'OSPV_SOURCE',to_date('01.01.1900 00:00:00','DD.MM.YYYY HH24:MI:SS'));

CREATE TABLE de1m.ospv_stg_del AS
SELECT id FROM de1m.ospv_source
WHERE 1=0;
--=============================



/* -= START OF THE ETL script =- */

-- 1 EXTRACT
TRUNCATE TABLE de1m.ospv_stg;
TRUNCATE TABLE de1m.ospv_stg_del;

INSERT INTO de1m.ospv_stg
SELECT
	ID,
	VAL,
	UPDATE_DT
FROM de1m.ospv_source
WHERE update_dt > (SELECT max_effective_from
					FROM de1m.ospv_meta
					WHERE schema_name = 'DE1M' AND table_name = 'OSPV_SOURCE'
					);

INSERT INTO de1m.ospv_stg_del ( id )
SELECT id FROM de1m.ospv_source;				

-- 2 TRANSFORM and LOAD
MERGE INTO de1m.ospv_target t
USING de1m.ospv_stg s
ON (s.id = t.id)
WHEN MATCHED THEN
	UPDATE SET t.effective_to = s.update_dt - INTERVAL '1' SECOND
	WHERE 		(1=0
				OR s.val <> t.val
	    		OR (s.val IS NULL AND t.val IS NOT NULL)
	    		OR (s.val IS NOT NULL AND t.val IS NULL)
	    		)
WHEN NOT MATCHED THEN 
	INSERT (id, val, effective_from, effective_to, deleted_flg)
	VALUES (s.id,
			s.val,
			s.update_dt,
			TO_DATE('9999-12-31','YYYY-MM-DD'),
			'N'
			);
 
INSERT INTO de1m.ospv_target
SELECT 
	s.ID,
	s.VAL,
	s.UPDATE_DT,
	TO_DATE('9999-12-31','YYYY-MM-DD'),
	'N'
FROM de1m.ospv_stg s
LEFT JOIN de1m.ospv_target t
	ON s.ID = t.ID
WHERE t.val <> s.val AND t.effective_to > (SELECT max_effective_from FROM de1m.OSPV_META);


-- 3 DELETE 
UPDATE de1m.ospv_target SET effective_to = CURRENT_DATE - INTERVAL '1' SECOND
WHERE id IN  (
				SELECT DISTINCT t.id
				FROM de1m.ospv_target t
				LEFT JOIN de1m.ospv_stg_del sd
					ON t.id = sd.id
				WHERE sd.id IS NULL
			);
INSERT INTO de1m.ospv_target
SELECT 
	ID,
	VAL,
	EFFECTIVE_TO + INTERVAL '1' SECOND ,
	TO_DATE('9999-12-31','YYYY-MM-DD'),
	'Y'
FROM de1m.ospv_target t
WHERE t.id 	IN  (
				SELECT DISTINCT t.id
				FROM de1m.ospv_target t
				LEFT JOIN de1m.ospv_stg_del sd
					ON t.id = sd.id
				WHERE sd.id IS NULL
			);	

-- 4 Metadata UPDATE 
UPDATE de1m.ospv_meta
SET max_effective_from = (SELECT MAX (update_dt)
					 		FROM de1m.ospv_stg)
WHERE schema_name = 'DE1M' AND table_name = 'OSPV_SOURCE';

COMMIT;