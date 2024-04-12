
-- this is the trigger for part a

CREATE OR REPLACE TRIGGER attribute_endorsed
BEFORE INSERT OR UPDATE ON Posts
FOR EACH ROW
DECLARE
    v_purchased CHAR(1);
BEGIN
    SELECT 'Y'
    INTO v_purchased
    FROM Client_Lines cl
    JOIN Orders_Clients oc ON cl.username = oc.username AND cl.orderdate = oc.orderdate
    WHERE cl.barcode = :NEW.barCode
      AND oc.username = :NEW.username
      AND ROWNUM = 1; 

    :NEW.endorsed := 'Y';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        :NEW.endorsed := 'N';
END;

/* tests */

-- test case 1
INSERT INTO Clients (username, user_passw, name) VALUES ('testuser', 'password', 'TestUser');
INSERT INTO Products (product, coffea, varietal, origin, roast, decaf) VALUES ('Testprod', 'A', 'Arabica', 'Mexico', 'N', 'N');
INSERT INTO References (barcode, product, format, pack_type, pack_unit, quantity, price) VALUES ('12345', 'Testprod', 'C', 'box', 'units', 10, 15.99);
INSERT INTO Orders_Clients (orderdate, username, town, country, dliv_datetime, bill_town, bill_country) VALUES (SYSDATE, 'testuser', 'Town', 'Country', SYSDATE, 'Town', 'Country');
INSERT INTO Client_Lines (orderdate, username, town, country, barcode, price, quantity) VALUES (SYSDATE, 'testuser', 'Town', 'Country', '12345', 15.99, '1');

INSERT INTO Posts (username, postdate, barcode, product, score, title, text) VALUES ('testuser', SYSDATE, '12345', 'Test Product', 5, 'Great Coffee', 'Loved this coffee!');

SELECT endorsed FROM Posts WHERE username = 'testuser' AND barcode = '12345';





-- this is the trigger for part b

CREATE OR REPLACE TRIGGER del_client
AFTER DELETE ON Clients
FOR EACH ROW
BEGIN

  FOR rec IN (SELECT * FROM Orders_Clients WHERE username = OLD.username) LOOP
    INSERT INTO Orders_Anonym (orderdate, contact, contact2, dliv_datetime, name, 
    surn1, surn2, bill_waytype, bill_wayname, bill_gate, bill_block, bill_stairw, bill_floor, bill_door, bill_ZIP, bill_town, bill_country, dliv_waytype, 
    dliv_wayname, dliv_gate, dliv_block, dliv_stairw, dliv_floor, dliv_door, dliv_ZIP, dliv_town, dliv_country)
    VALUES (rec.orderdate, NULL, NULL, rec.dliv_datetime, rec.name, rec.surn1,
    rec.surn2, rec.bill_waytype, rec.bill_wayname, rec.bill_gate, rec.bill_block, rec.bill_stairw, 
    rec.bill_floor, rec.bill_door, rec.bill_ZIP, rec.bill_town, rec.bill_country, rec.dliv_waytype, rec.dliv_wayname, 
    rec.dliv_gate, rec.dliv_block, rec.dliv_stairw, rec.dliv_floor, rec.dliv_door, rec.dliv_ZIP, rec.dliv_town, rec.dliv_country);


  END LOOP;

  FOR post_rec IN (SELECT * FROM Posts WHERE username = OLD.username) LOOP
    INSERT INTO AnonyPosts (postdate, barCode, product, score, title, text, likes, endorsed)
    VALUES (post_rec.postdate, post_rec.barCode, post_rec.product, post_rec.score, post_rec.title, post_rec.text, post_rec.likes, post_rec.endorsed);
  END LOOP;

END;


/* tests */

BEGIN
  INSERT INTO Clients (username, user_passw, name) VALUES ('test2', 'password', 'test1');
  INSERT INTO Orders_Clients (orderdate, username, town, country, dliv_datetime, bill_town, bill_country) VALUES (SYSDATE, 'test2', 'Town', 'Country', SYSDATE, 'Town', 'Country');
  INSERT INTO Posts (username, postdate, barcode, product, score, title, text) VALUES ('test2', SYSDATE, '12345', 'Test Product', 5, 'Must Try', 'Good purchase!');
  DELETE FROM Clients WHERE username = 'test2';
  SELECT * FROM Orders_Anonym;
  SELECT * FROM AnonyPosts;
END;



-- this is the trigger for part c



CREATE OR REPLACE TRIGGER repeats
BEFORE INSERT ON Lines_Anonym
FOR EACH ROW
DECLARE
  c_exist NUMBER;
BEGIN
    
  IF UPPER(:NEW.pay_type) = 'CREDIT CARD' THEN
    SELECT COUNT(*)
    INTO c_exist
    FROM Client_Cards
    WHERE cardnum = :NEW.card_num;

    IF v_exists > 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Invalid Credit Card');
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;

/* test case 1 */

INSERT INTO Client_Cards (cardnum, username, card_comp, card_holder, card_expir) VALUES (1234567890123456, 'user1', 'Visa', 'User', TO_DATE('31-DEC-2025', 'DD-MON-YYYY'));
INSERT INTO Lines_Anonym (orderdate, contact, dliv_town, dliv_country, barcode, price, quantity, pay_type, card_num) VALUES (SYSDATE, 'user1@example.com', 'Town', 
    'Country', '12345', 19.99, 2, 'CREDIT CARD', 1234567890123456);
SELECT * FROM Lines_Anonym WHERE contact = 'user1@example.com';


/* test case 2 */
BEGIN
  INSERT INTO Lines_Anonym (orderdate, contact, dliv_town, dliv_country, barcode, price, quantity, pay_type, card_num) VALUES (SYSDATE, 'user2@example.com', 
    'Town', 'Country', '12345', 19.99, 1, 'CREDIT CARD', 8389724792204);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;




-- this is the trigger for part d

CREATE OR REPLACE TRIGGER update_stock
AFTER INSERT ON Client_Lines
FOR EACH ROW
DECLARE
    update1 NUMBER;
BEGIN
    UPDATE References
    SET cur_stock = cur_stock - :NEW.quantity
    WHERE barcode = :NEW.barcode;
    SELECT cur_stock INTO update1 FROM References WHERE barcode = :NEW.barcode;
    IF new_stock <= min_stock THEN
        INSERT INTO Replacements (taxID, barCode, orderdate, status, units, payment)
        VALUES (
            'DEFAULT_TAX_ID',
            :NEW.barcode,
            SYSDATE,
            'D', 
            max_stock - update1,
            0 
        );
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, SQLERRM);
END;


/* tests */



