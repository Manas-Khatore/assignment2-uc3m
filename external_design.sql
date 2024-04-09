/* use USER function provided by SQL, is it supposed to have a different value? */

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

CREATE TABLE OLD_POSTS (
  username   VARCHAR2(30),
  postdate   DATE,
  barCode    CHAR(15),
  product    VARCHAR2(50) NOT NULL,
  score      NUMBER(1) NOT NULL, 
  title      VARCHAR2(50),
  text       VARCHAR2(2000) NOT NULL, 
  likes      NUMBER(9) DEFAULT(0) NOT NULL, 
  endorsed   DATE, 
  action_taken     VARCHAR2(50)
);

/* created */

CREATE OR REPLACE TRIGGER insert_new_posts 
  AFTER INSERT ON POSTS 
  FOR EACH ROW 
  BEGIN 
  INSERT INTO POSTS (username, postdate, barCode, product, score, title, text, likes) 
  VALUES (:NEW.username, :NEW.postdate, :NEW.barCode, :NEW.product, :NEW.score, :NEW.title, :NEW.text, :NEW.likes); 
END;

/* created */

CREATE OR REPLACE TRIGGER delete_posts 
BEFORE DELETE ON POSTS 
FOR EACH ROW 
BEGIN 
  IF :OLD.LIKES = 0 THEN 
  INSERT INTO OLD_POSTS (username, postdate, barCode, product, score, title, text, likes, endorsed, action_taken) 
  VALUES (:OLD.username, :OLD.postdate, :OLD.barCode, :OLD.product, :OLD.score, :OLD.title, :OLD.text, :OLD.likes, :OLD.endorsed, 'DELETE'); 
END IF; 
END;

/* created */

CREATE OR REPLACE TRIGGER update_text 
BEFORE UPDATE OF text on POSTS 
FOR EACH ROW 
BEGIN 
  UPDATE POSTS set text = :NEW.text 
  WHERE text = :OLD.text;
END;
