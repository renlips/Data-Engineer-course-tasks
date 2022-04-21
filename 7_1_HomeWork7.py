#!/usr/bin/python3.4

import jaydebeapi
import pandas as pd

conn = jaydebeapi.connect('oracle.jdbc.driver.OracleDriver',
                           'jdbc:oracle:thin:de1m/samwisegamgee@de-oracle.chronosavant.ru:1521/deoracle',
                           ['de1m', 'samwisegamgee'],
                           '/home/de1m/ojdbc8.jar')

conn.jconn.setAutoCommit(False)
cur = conn.cursor()

cur.execute('''
	BEGIN
   	    EXECUTE IMMEDIATE 'DROP TABLE ' || 'de1m.ospv_medicine';
	EXCEPTION
   	    WHEN OTHERS THEN
      	        IF SQLCODE != -942 THEN
       	            RAISE;
	        END IF;
	END;
''')
conn.commit()


cur.execute('''

	CREATE TABLE de1m.ospv_medicine(
	id_patient	INT,
	id_analysis VARCHAR2(10),
	value		DECIMAL
	)
''')
conn.commit()

df = pd.read_excel('medicine.xlsx', sheet_name='easy', header=0, index_col=None)
df = df.astype(str)
cur.executemany( 'insert into de1m.ospv_medicine (id_patient, id_analysis, value) values(?,?,?)', df.values.tolist() )

cur.execute('''
    SELECT
        n.PHONE,
        n.NAME,
        a.NAME,
        CASE
            WHEN m.VALUE > a.MAX_VALUE THEN 'Повышен'
            WHEN m.VALUE < a.MIN_VALUE THEN 'Понижен'
            ELSE 'N'
        END AS evaluation
    FROM de.med_names n
    LEFT JOIN de1m.ospv_medicine m
        ON n.ID = m.ID_PATIENT
    LEFT JOIN de.med_an_name a
        ON m.ID_ANALYSIS = a.CODE 
    WHERE m.VALUE < a.MIN_VALUE OR m.VALUE > a.MAX_VALUE
''')

result = cur.fetchall()

raw = [x[0] for x in cur.description]
outcome = pd.DataFrame(result, columns = raw)

outcome.to_excel('med_outcome.xlsx', sheet_name="Sheet1")

cur.close()
conn.close()
