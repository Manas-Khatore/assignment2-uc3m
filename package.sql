CREATE OR REPLACE PACKAGE caffeine AS 
  PROCEDURE set_replacement_orders;
  PROCEDURE provider_report(p_TaxID IN Providers.taxID%TYPE); 
END caffeine;
/

CREATE OR REPLACE PACKAGE BODY caffeine AS
  PROCEDURE set_replacement_orders AS
  BEGIN
    UPDATE replacements
    SET STATUS = 'P'
    WHERE STATUS = 'D';
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Status updated successfully.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
      ROLLBACK;
  END set_replacement_orders;

  PROCEDURE provider_report(p_taxID IN Providers.taxID%TYPE) AS
    v_total_orders NUMBER;
    v_fulfilled_orders NUMBER;
    v_avg_delivery_period NUMBER;
    v_ref_cursor SYS_REFCURSOR;
    v_ref_code References.barCode%TYPE;
    v_curr_cost References.price%TYPE;
    v_min_cost References.price%TYPE;
    v_max_cost References.price%TYPE;
    v_diff_curr_avg_cost NUMBER;
    v_diff_curr_best_cost NUMBER;
  BEGIN
    -- Calculate total number of orders placed by the provider in the last year
    SELECT COUNT(*)
    INTO v_total_orders
    FROM Replacements  oa
    WHERE oa.orderdate >= ADD_MONTHS(SYSDATE, -12)
    AND oa.taxID IN (SELECT taxID FROM Providers WHERE taxID = p_taxID);

    DBMS_OUTPUT.PUT_LINE('ID: ' || p_TaxID);

    -- Print statistics
    DBMS_OUTPUT.PUT_LINE('Number of orders placed in the last year: ' || v_total_orders);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
  END provider_report; 
  
END caffeine; 
/