-- Insertion script for populating the Replacements table

-- Inserting sample data for replacements
INSERT INTO Replacements (taxID, barCode, orderdate, status, units, deldate, payment)
VALUES ('J33103474B', 
        'IOO34325Q968141', 
        TO_DATE('2024-04-09', 'YYYY-MM-DD'), 
        'D', 
        2, 
        NULL, 
        25.50);

INSERT INTO Replacements (taxID, barCode, orderdate, status, units, deldate, payment)
VALUES ('J91536748Z', 
        'OIQ01481I324621', 
        TO_DATE('2024-04-10', 'YYYY-MM-DD'), 
        'F', 
        3, 
        TO_DATE('2024-04-15', 'YYYY-MM-DD'),
        30.75);