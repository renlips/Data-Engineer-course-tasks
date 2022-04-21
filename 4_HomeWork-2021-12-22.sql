-- 1 --
SELECT
    e.last_name,
    e.first_name,
    rank() OVER (ORDER BY SUM(o.order_total) DESC NULLS LAST) AS rank,
    COALESCE(SUM(o.order_total), 0) AS total,
    e.salary,
    CAST(COALESCE(SUM(o.order_total),0) * 0.001 AS DECIMAL(7,2)) AS premium
FROM (  SELECT *
        FROM HR.employees
        WHERE department_id = 80
    ) e
LEFT JOIN ( SELECT *
            FROM OE.orders
            WHERE order_date BETWEEN TO_DATE('01-01-2007','DD-MM-YYYY') AND TO_DATE('31-12-2007','DD-MM-YYYY')
        ) o
    ON e.employee_id = o.sales_rep_id
GROUP BY e.first_name, e.last_name, e.salary;



-- 2 --
CREATE TABLE DE1M.OSPV_SALARY_HIST AS
SELECT
	person,
	class,
	salary,
	DT AS EFFECTIVE_FROM,
	COALESCE( LEAD(DT) OVER(PARTITION BY person ORDER BY DT) - 1/86400, TO_DATE('31-12-2999', 'DD-MM-YYYY') ) AS EFFECTIVE_TO
FROM DE.HISTGROUP
ORDER BY DT;

-- проверка таблицы DE1M.OSPV_SALARY_HIST на корректность --
SELECT
    *
FROM DE1M.OSPV_SALARY_HIST
WHERE ROWNUM <= 20;

SELECT
    payment_dt,
    person,
    payment,
    month_paid,
    salary - month_paid AS MONTH_REST
FROM    (SELECT
            P1.*,
            SUM(P1.payment) OVER(PARTITION BY TO_CHAR(p1.payment_dt, 'MM-YYYY'), p1.person ORDER BY p1.payment_dt) AS MONTH_PAID,
            SH.salary
        FROM DE.payments P1
        INNER JOIN DE1M.OSPV_SALARY_HIST SH
            ON p1.person = sh.person AND p1.payment_dt BETWEEN sh.effective_from AND sh.effective_to
        )
ORDER BY payment_dt;