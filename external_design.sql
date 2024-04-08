/* use USER function provided by SQL, is it supposed to have a different value? */

CREATE VIEW my_purchases AS 
SELECT * FROM ORDERS_CLIENTS WHERE ORDERS_CLIENTS.username = (SELECT USER FROM DUAL);

/* duplicate column error with below query */

CREATE VIEW my_profile AS 
SELECT * FROM CLIENTS 
INNER JOIN CLIENT_ADDRESSES ON CLIENTS.username = CLIENT_ADDRESSES.username 
INNER JOIN CLIENT_CARDS ON CLIENT_ADDRESSES.username = CLIENT_CARDS.username 
WHERE CLIENTS.username = (SELECT USER FROM DUAL);
