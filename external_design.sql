/* use USER function provided by SQL, is it supposed to have a different value? */

CREATE VIEW my_purchases AS 
SELECT * FROM ORDERS_CLIENTS WHERE ORDERS_CLIENTS.username = (SELECT USER FROM DUAL);

CREATE VIEW my_profile AS 
SELECT 
