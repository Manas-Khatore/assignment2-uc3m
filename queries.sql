/* translate all of these into single queries */

/* Query for Bestsellers Geographic Report */

/* FINAL QUERY -- translate to relational algebra */

WITH ALL_ORDERS AS (
    SELECT 
        barcode, 
        orderdate, 
        price, 
        TO_CHAR(quantity) as quantity, 
        country 
    FROM 
        CLIENT_LINES 
    UNION ALL 
    SELECT 
        barcode, 
        orderdate, 
        price, 
        TO_CHAR(quantity) as quantity, 
        dliv_country as country 
    FROM 
        LINES_ANONYM),
       VARIETAL_ROW_NUM AS (
    SELECT 
        PRODUCTS.varietal, 
        CLIENT_LINES.country, 
        ROW_NUMBER() OVER (PARTITION BY CLIENT_LINES.country ORDER BY COUNT(*) DESC) AS row_number 
    FROM 
        REFERENCES 
    INNER JOIN 
        PRODUCTS ON PRODUCTS.product = REFERENCES.product 
    INNER JOIN 
        CLIENT_LINES ON CLIENT_LINES.barcode = REFERENCES.barcode 
    WHERE 
        EXTRACT(YEAR FROM orderdate) = 2023
    GROUP BY 
        CLIENT_LINES.country, PRODUCTS.varietal
)
SELECT 
    PRODUCTS.varietal, 
    CLIENT_LINES.country, 
    PRODUCTS.product, 
    COUNT(*) as num_buyers, 
    SUM(CLIENT_LINES.quantity) as num_units, 
    SUM(CLIENT_LINES.quantity * CLIENT_LINES.price) as income, 
    AVG(CLIENT_LINES.quantity) 
FROM 
    REFERENCES 
INNER JOIN 
    PRODUCTS ON PRODUCTS.product = REFERENCES.product 
INNER JOIN 
    CLIENT_LINES ON CLIENT_LINES.barcode = REFERENCES.barcode  
INNER JOIN 
    VARIETAL_ROW_NUM ON PRODUCTS.varietal = VARIETAL_ROW_NUM.varietal 
    AND CLIENT_LINES.country = VARIETAL_ROW_NUM.country 
WHERE 
    EXTRACT(YEAR FROM orderdate) = 2023 
    AND VARIETAL_ROW_NUM.row_number = 1 
GROUP BY 
    PRODUCTS.varietal, 
    CLIENT_LINES.country, 
    PRODUCTS.product;


/* Query for Business way of life */


WITH ALL_ORDERS AS (
    SELECT 
        barcode, 
        orderdate, 
        price, 
        TO_CHAR(quantity) as quantity, 
        country 
    FROM 
        CLIENT_LINES 
    UNION ALL 
    SELECT 
        barcode, 
        orderdate, 
        price, 
        TO_CHAR(quantity) as quantity, 
        dliv_country as country 
    FROM 
        LINES_ANONYM),
REF_MONTH_ROW_NUM AS (
    SELECT 
        REFERENCES.barcode, 
        EXTRACT(MONTH FROM ALL_ORDERS.orderdate) as month, 
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(MONTH FROM ALL_ORDERS.orderdate) ORDER BY SUM(ALL_ORDERS.quantity) DESC) AS row_number 
    FROM 
        REFERENCES 
    INNER JOIN 
        ALL_ORDERS ON ALL_ORDERS.barcode = REFERENCES.barcode 
    WHERE 
        ALL_ORDERS.orderdate >= ADD_MONTHS(TRUNC(SYSDATE), -12)
    GROUP BY 
        REFERENCES.barcode, EXTRACT(MONTH FROM ALL_ORDERS.orderdate)
)
SELECT 
    REFERENCES.barcode, 
    EXTRACT(MONTH FROM ALL_ORDERS.orderdate) as month, 
    COUNT(*) as num_buyers, 
    SUM(ALL_ORDERS.quantity) as num_units, 
    SUM(ALL_ORDERS.quantity * ALL_ORDERS.price) as income, 
    SUM(ALL_ORDERS.price) - SUM(SUPPLY_LINES.cost) as profit 
FROM 
    REFERENCES 
INNER JOIN 
    SUPPLY_LINES ON REFERENCES.barcode = SUPPLY_LINES.barcode 
INNER JOIN 
    ALL_ORDERS ON REFERENCES.barcode = ALL_ORDERS.barcode 
INNER JOIN 
    REF_MONTH_ROW_NUM ON REFERENCES.barcode = REF_MONTH_ROW_NUM.barcode 
    AND EXTRACT(MONTH FROM ALL_ORDERS.orderdate) = REF_MONTH_ROW_NUM.month 
WHERE 
    ALL_ORDERS.orderdate >= ADD_MONTHS(TRUNC(SYSDATE), -12) AND row_number = 1 
GROUP BY 
    REFERENCES.barcode, EXTRACT(MONTH FROM ALL_ORDERS.orderdate);

