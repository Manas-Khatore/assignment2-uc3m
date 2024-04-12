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
    AND oa.taxID = p_TaxID; 

    -- Calculate number of fulfilled orders by the provider in the last year
    SELECT COUNT(*)
    INTO v_fulfilled_orders
    FROM Replacements r
    WHERE r.orderdate >= ADD_MONTHS(SYSDATE, -12)
    AND r.status = 'F'
    AND r.taxID = p_taxID;

    -- Calculate average delivery period for fulfilled offers
    SELECT AVG(EXTRACT(DAY FROM r.deldate) - EXTRACT(DAY FROM r.orderdate))
    INTO v_avg_delivery_period
    FROM Replacements r
    WHERE r.orderdate >= ADD_MONTHS(SYSDATE, -12)
    AND r.status = 'F'
    AND r.taxID = p_taxID;

    OPEN v_ref_cursor FOR
    SELECT r.barCode, 
           r.price AS current_cost,
           rl.min_cost,
           rl.max_cost,
           r.price - rl.avg_cost AS diff_curr_avg_cost,
           CASE
               WHEN r.price - rl.next_best_cost < 0 THEN NULL -- Ignore if current cost is the best
               ELSE r.price - rl.next_best_cost
           END AS diff_curr_best_cost
    FROM References r
    JOIN (
        SELECT sl.barCode,
               MIN(sl.cost) AS min_cost,
               MAX(sl.cost) AS max_cost,
               AVG(sl.cost) AS avg_cost,
               LEAD(sl.cost) OVER (PARTITION BY sl.barCode ORDER BY sl.cost) AS next_best_cost
        FROM Supply_Lines sl
	      GROUP BY sl.barCode, sl.cost
    ) rl ON r.barCode = rl.barCode;

    DBMS_OUTPUT.PUT_LINE('Number of orders placed in the last year: ' || v_total_orders);
    DBMS_OUTPUT.PUT_LINE('Number of orders fulfilled in the last year: ' || v_fulfilled_orders);
    DBMS_OUTPUT.PUT_LINE('Average delivery period for fulfilled offers: ' || v_avg_delivery_period || ' days');
    DBMS_OUTPUT.PUT_LINE('Details of offers:');
    DBMS_OUTPUT.PUT_LINE('BarCode | Current Cost | Min Cost | Max Cost | Diff Current Avg Cost | Diff Current Best Cost');
    LOOP
        FETCH v_ref_cursor INTO v_ref_code, v_curr_cost, v_min_cost, v_max_cost, v_diff_curr_avg_cost, v_diff_curr_best_cost;
        EXIT WHEN v_ref_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_ref_code || ' | ' || v_curr_cost || ' | ' || v_min_cost || ' | ' || v_max_cost || ' | ' 
		|| v_diff_curr_avg_cost || ' | ' || v_diff_curr_best_cost);
    END LOOP;
    CLOSE v_ref_cursor;

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
  END provider_report; 
  
END caffeine; 
/
