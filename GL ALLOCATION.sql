--------------------------------------------------------
----------PCL GL Allocation(Done)-----------------------------
---OCL Factory Overhead Allocation Journal Program
---XX_GL_PKG.MFG_OCL_OVERHEAD_ALLOCATION_JV

---EBS GL Allocation Journal Program

--VS : PSG_GL_SUB_ACCOUNT
--------------------------------------------------------


SELECT PERIOD_NAME,
                     LAST_DAY (TO_DATE (PERIOD_NAME, 'MON-YY'))         ACCOUNTING_DATE,
                     LEDGER_ID,
                     ACC_COMPANY,-----COMPANY,
                     ACC_LOCATION,-----LOCATION,
                     ACC_COST_CENTER,-----COST_CENTER,
                     5030901 ACCOUNT_1,
                     CASE ALLOCATION_CODE
                         WHEN 'PCL DEPRECIATION' THEN 20004
                         WHEN 'PCL Factory Utilites' THEN 20003
                         WHEN 'PCL FACTORY OH'THEN 20002
                         WHEN 'PCL DIRECT LABOR' THEN 20001
                     END SUB_ACOUNT,
                     PRODUCT,
                     PROJECT,
                     LINE_OF_BUSINESS,
                     INTER_COMPANY,
                     FUTURE_1,
                     FUTURE_2,
                     ALLOCATION_CODE,
                     (ACC_COMPANY
                      || '.'
                      || ACC_LOCATION
                      || '.'
                      || ACC_COST_CENTER
                      || '.'
                      || 5030901
                      || '.'
                      ||CASE ALLOCATION_CODE
                         WHEN 'PCL DEPRECIATION' THEN 20004
                         WHEN 'PCL Factory Utilites' THEN 20003
                         WHEN 'PCL FACTORY OH'THEN 20002
                         WHEN 'PCL DIRECT LABOR' THEN 20001
                        END
                      || '.'
                      || PRODUCT
                      || '.'
                      || PROJECT
                      || '.'
                      || LINE_OF_BUSINESS
                      || '.'
                      || INTER_COMPANY
                      || '.'
                      || FUTURE_1
                      || '.'
                      || FUTURE_2) ACCOUNT_CODE_COMBINATIONS,
                     SUM (DR) DEBITS,
                     0 CREDITS,-----SUM (CR) CREDITS,
                     'Factory Overhead Allocation for '|| PERIOD_NAME    BATCH_NAME,
                     ----ALLOCATION_CODE||' '|| PERIOD_NAME    BATCH_NAME,
                     'Factory Overhead Allocation for ' || PERIOD_NAME    JOURNAL_NAME,
                     ----ALLOCATION_CODE||' '|| PERIOD_NAME    JOURNAL_NAME,
                     ----'Factory Overhead Allocation for ' 
                     ALLOCATION_CODE||' '|| PERIOD_NAME    LINE_DESCRIPTION
                FROM XX_MFG_COST_ALLOC_JV_V ---XX_MFG_OCL_COST_ALLOC_JV_V
               WHERE LEDGER_ID = :P_LEDGER_ID 
               AND   PERIOD_NAME = :P_PERIOD_NAME
            GROUP BY PERIOD_NAME,
                     LEDGER_ID,
                     ACC_COMPANY,-----COMPANY,
                     ACC_LOCATION,-----LOCATION,
                     ACC_COST_CENTER,-----COST_CENTER,
                   --  ACCOUNT,
                     CASE ALLOCATION_CODE
                         WHEN 'PCL DEPRECIATION' THEN 20004
                         WHEN 'PCL Factory Utilites' THEN 20003
                         WHEN 'PCL FACTORY OH'THEN 20002
                         WHEN 'PCL DIRECT LABOR' THEN 20001
                     END,
                     PRODUCT,
                     PROJECT,
                     LINE_OF_BUSINESS,
                     INTER_COMPANY,   
                     FUTURE_1,
                     FUTURE_2,                  
                     ALLOCATION_CODE
            --ORDER BY ACC_COST_CENTER
            UNION ALL
            SELECT PERIOD_NAME,
                     LAST_DAY (TO_DATE (PERIOD_NAME, 'MON-YY'))         ACCOUNTING_DATE,
                     LEDGER_ID,
                     ACC_COMPANY,-----COMPANY,
                     ACC_LOCATION,-----LOCATION,
                     ACC_COST_CENTER,-----COST_CENTER,
                     5030902 ACCOUNT_1,
                     CASE ALLOCATION_CODE
                         WHEN 'PCL DEPRECIATION' THEN 20004
                         WHEN 'PCL Factory Utilites' THEN 20003
                         WHEN 'PCL FACTORY OH'THEN 20002
                         WHEN 'PCL DIRECT LABOR' THEN 20001
                     END SUB_ACOUNT,
                     PRODUCT,
                     PROJECT,
                     LINE_OF_BUSINESS,
                     INTER_COMPANY,
                     FUTURE_1,
                     FUTURE_2,
                     ALLOCATION_CODE,
                     (ACC_COMPANY
                      || '.'
                      || ACC_LOCATION
                      || '.'
                      || ACC_COST_CENTER
                      || '.'
                      || 5030902
                      || '.'
                      ||'.'
                      ||CASE ALLOCATION_CODE
                         WHEN 'PCL DEPRECIATION' THEN 20004
                         WHEN 'PCL Factory Utilites' THEN 20003
                         WHEN 'PCL FACTORY OH'THEN 20002
                         WHEN 'PCL DIRECT LABOR' THEN 20001
                        END
                      || '.'
                      || PRODUCT
                      || '.'
                      || PROJECT
                      || '.'
                      || LINE_OF_BUSINESS
                      || '.'
                      || INTER_COMPANY
                      || '.'
                      || FUTURE_1
                      || '.'
                      || FUTURE_2) ACCOUNT_CODE_COMBINATIONS,
                     0 DEBITS,-----SUM (DR) DEBITS,
                     SUM (DR) CREDITS,
                     'Factory Overhead Allocation for '|| PERIOD_NAME    BATCH_NAME,
                     ----ALLOCATION_CODE||' '|| PERIOD_NAME    BATCH_NAME,
                     'Factory Overhead Allocation for ' || PERIOD_NAME    JOURNAL_NAME,
                     ----ALLOCATION_CODE||' '|| PERIOD_NAME    JOURNAL_NAME,
                     ----'Factory Overhead Allocation for ' 
                     ALLOCATION_CODE||' '|| PERIOD_NAME    LINE_DESCRIPTION
                FROM XX_MFG_COST_ALLOC_JV_V ---XX_MFG_OCL_COST_ALLOC_JV_V
               WHERE LEDGER_ID = :P_LEDGER_ID 
               AND   PERIOD_NAME = :P_PERIOD_NAME
            GROUP BY PERIOD_NAME,
                     LEDGER_ID,
                     ACC_COMPANY,-----COMPANY,
                     ACC_LOCATION,-----LOCATION,
                     ACC_COST_CENTER,-----COST_CENTER,
                   --  ACCOUNT,
                     CASE ALLOCATION_CODE
                         WHEN 'PCL DEPRECIATION' THEN 20004
                         WHEN 'PCL Factory Utilites' THEN 20003
                         WHEN 'PCL FACTORY OH'THEN 20002
                         WHEN 'PCL DIRECT LABOR' THEN 20001
                     END,
                     PRODUCT,
                     PROJECT,
                     LINE_OF_BUSINESS,
                     INTER_COMPANY,   
                     FUTURE_1,
                     FUTURE_2,                  
                     ALLOCATION_CODE;
           


DECLARE
 ERRBUF VARCHAR2(100);
 RETCODE VARCHAR2(100);
 P_USER_ID NUMBER;
 P_RESP_ID NUMBER;
BEGIN
 XX_GL_PKG.MFG_PCL_OVERHEAD_ALLOCATION_JV (ERRBUF,RETCODE,P_USER_ID,P_RESP_ID,2021,'JUL-23');
END;

SELECT *FROM GL_INTERFACE;

-----------------------------------------------------------------------------
--The output of this query have to send them to confirm the journal amount
-----------------------------------------------------------------------------
SELECT * FROM XX_MFG_COST_ALLOC_JV_V where period_name = 'FEB-24';

SELECT distinct ALLOCATION_CODE,ACC_COST_CENTER_DESC  FROM XX_MFG_COST_ALLOC_JV_V where period_name = 'FEB-24' 
-----------------------------------------------------------------------------