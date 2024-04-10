
-- this is the trigger for part a

CREATE OR REPLACE TRIGGER attribute_endorsed
BEFORE INSERT OR UPDATE ON Posts
FOR EACH ROW
BEGIN
    IF : NEW.product IN (
          SELECT product
          FROM References
          WHERE barCode IN (
              SELECT barCode
              FROM Supply_Lines
              WHERE taxID = :NEW.username
          )
      ) THEN
          :NEW.endorsed := SYSDATE; 
      ELSE 
          :NEW.endorsed := null;
      END IF;
END;

-- this is the trigger for part b

-- this is the trigger for part c


-- this is the trigger for part d




