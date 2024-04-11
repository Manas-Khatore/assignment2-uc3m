
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

-- this is the trigger for part c


-- this is the trigger for part d




