CREATE VIEW my_purchases AS 
SELECT * FROM ORDERS_CLIENTS WHERE ORDERS_CLIENTS.username = (SELECT USER FROM DUAL);

CREATE TABLE CLIENT_ADDRESSES_DUP AS  
  SELECT * FROM CLIENT_ADDRESSES;

ALTER TABLE CLIENT_ADDRESSES_DUP RENAME COLUMN username TO add_username;

CREATE TABLE CLIENT_CARDS_DUP AS 
  SELECT * FROM CLIENT_CARDS;

ALTER TABLE CLIENT_CARDS_DUP RENAME COLUMN username to card_username;

CREATE VIEW my_profile AS 
SELECT * FROM CLIENTS
INNER JOIN CLIENT_ADDRESSES_DUP ON CLIENTS.username = CLIENT_ADDRESSES_DUP.add_username 
INNER JOIN CLIENT_CARDS_DUP ON CLIENT_ADDRESSES_DUP.add_username = CLIENT_CARDS_DUP.card_username 
WHERE CLIENTS.username = (SELECT USER FROM DUAL);

CREATE VIEW my_posts AS 
SELECT * FROM POSTS WHERE POSTS.username = (SELECT USER FROM DUAL);

CREATE OR REPLACE TRIGGER insert_new_posts 
  INSTEAD OF INSERT ON my_posts 
  FOR EACH ROW 
  BEGIN 
  INSERT INTO POSTS (username, postdate, barCode, product, score, title, text, likes) 
  VALUES (:NEW.username, :NEW.postdate, :NEW.barCode, :NEW.product, :NEW.score, :NEW.title, :NEW.text, :NEW.likes); 
END;

DECLARE EXCEPTION cannot_delete dbms_output.put_line('This post has more than zero likes, cannot delete!');

CREATE OR REPLACE TRIGGER delete_posts 
  BEFORE DELETE ON POSTS 
  FOR EACH ROW 
BEGIN 
  IF :OLD.LIKES > 0 THEN 
   RAISE_APPLICATION_ERROR(-20001, 'Cannot delete the post because it more than zero likes.'); 
END IF; 
END;

CREATE OR REPLACE TRIGGER update_text 
  BEFORE UPDATE OF text on POSTS 
  FOR EACH ROW 
BEGIN 
  IF :OLD.LIKES > 0 THEN 
  RAISE_APPLICATION_ERROR(-20001, 'Cannot update the post text because it more than zero likes.'); 
END IF;
END;

/* TESTS */

INSERT INTO CLIENTS (username, reg_datetime, user_passw, name, surn1, surn2, email, mobile, preference, voucher, voucher_exp) 
  VALUES ('FSDB253', TO_DATE('2022-04-10', 'YYYY-MM-DD'), 'hello', 'manas', 'khatore', 'hello', 'abc@gmail.com', 805905040, 'SMS', 34, TO_DATE('2022-04-10', 'YYYY-MM-DD'));

INSERT INTO CLIENT_ADDRESSES (username, waytype, wayname, gate, block, stairw, floor, door, ZIP, town, country) 
  VALUES ('FSDB253', 'avenue', 'hello', 'fsd', 'd', 'd', 'd', 'df', '39402', 'Madrid', 'Spain');

INSERT INTO CLIENT_CARDS (cardnum, username, card_comp, card_holder, card_expir) 
  VALUES (38920392, 'FSDB253', 'amex', 'manas', TO_DATE('2022-04-10', 'YYYY-MM-DD'));

INSERT INTO ORDERS_CLIENTS (orderdate, username, town, country, dliv_datetime, bill_town, bill_country, discount) 
VALUES (TO_DATE('2022-04-10', 'YYYY-MM-DD'), 'FSDB253', 'Madrid', 'Spain', TO_DATE('2022-04-10', 'YYYY-MM-DD'), 'Madrid', 'Spain', 45);

INSERT INTO POSTS (username, postdate, barCode, product, score, title, text, likes, endorsed) 
VALUES ('FSDB253', TO_DATE('2022-04-10', 'YYYY-MM-DD'), 'QQO41416Q877187', 'Charca', 4, 'Good product', 'Loved this!', 2, TO_DATE('2022-04-10', 'YYYY-MM-DD'));

INSERT INTO POSTS (username, postdate, barCode, product, score, title, text, likes, endorsed) 
VALUES ('FSDB253', TO_DATE('2022-04-11', 'YYYY-MM-DD'), 'OOI21363Q853914', 'Cestero', 1, 'Bad product', 'Not good!', 0, TO_DATE('2022-04-11', 'YYYY-MM-DD'));

DELETE FROM POSTS WHERE username = 'FSDB253' AND postdate = TO_DATE('2022-04-10', 'YYYY-MM-DD');

DELETE FROM POSTS WHERE username = 'FSDB253' AND postdate = TO_DATE('2022-04-11', 'YYYY-MM-DD');

UPDATE POSTS SET text = 'new text (should not work)' WHERE username = 'FSDB253' AND postdate = TO_DATE('2022-04-10', 'YYYY-MM-DD');

UPDATE POSTS SET text = 'new text (should work)' WHERE username = 'FSDB253' AND postdate = TO_DATE('2022-04-11', 'YYYY-MM-DD');

