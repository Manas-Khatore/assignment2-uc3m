
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


-- this is the trigger for part c


-- this is the trigger for part d




