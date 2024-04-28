--------------------------------------------------
-----------------PCL Allocation Basis-------------
--------------------------------------------------
---Done For PCL
---EBS Expense Percentage Allocation API
---XX_EXP_ALLOC_DETAILS_PROC
----
---EBS Expense Allocation Percentage Procedure
---XX_EXP_ALLOC_BASIS_INSERT
---------------------------------------------------------------

SELECT *FROM MTL_MATERIAL_TRANSACTIONS

SELECT ORGANIZATION_NAME,SUM(PER_ITEM_EXPENSE) FROM XX_EXP_ALLOC_DETAILS
GROUP BY ORGANIZATION_NAME;

select *from XX_EXP_ALLOC_DETAILS --where ORGANIZATION_NAME = 'Wooden Plant'

DECLARE
 ERRBUFF VARCHAR2(100);
 RETCODE VARCHAR2(100);
 P_LEGAL_ENTITY_ID NUMBER;
 P_FROM_DT date;
 P_TO_DT date;
BEGIN
 XX_EXP_ALLOC_DETAILS_PROC(ERRBUFF,RETCODE,P_LEGAL_ENTITY_ID,P_FROM_DT,P_TO_DT);
END;




CREATE OR REPLACE PROCEDURE XX_EXP_ALLOC_DETAILS_PROC(
                                   ERRBUFF             OUT VARCHAR2,
                                   RETCODE             OUT VARCHAR2,                                   
                                   P_LEGAL_ENTITY_ID   IN     NUMBER,
                                   ----P_ORGANIZATION_ID       NUMBER,
                                   P_FROM_DT               VARCHAR2,
                                   P_TO_DT                 VARCHAR2 )
IS

V_FROM_DT   DATE := TO_DATE (P_FROM_DT,'DD-MM-YYYY'); ----'RRRR/MM/DD  HH24:MI:SS');
V_TO_DT     DATE := TO_DATE (P_TO_DT,'DD-MM-YYYY'); ----'RRRR/MM/DD  HH24:MI:SS');

CURSOR C1 IS
SELECT   OOD.LEGAL_ENTITY,
         MSIK.ORGANIZATION_ID,
         OOD.ORGANIZATION_NAME,
         MSIK.INVENTORY_ITEM_ID,
         MSIK.CONCATENATED_SEGMENTS ITEM_CODE,
         MSIK.DESCRIPTION ITEM_NAME,
         MSIK.PRIMARY_UOM_CODE UOM,         
         MCB.SEGMENT1 ITEM_MJR_CAT,
         MCB.SEGMENT2 ITEM_MNR_CAT,
         MSIK.SECONDARY_UOM_CODE,SUM(PRIMARY_QUANTITY) PRIMARY_QUANTITY,                                               
         INV_CONVERT.INV_UM_CONVERT (MSIK.INVENTORY_ITEM_ID, MSIK.PRIMARY_UOM_CODE, 'KG') KG_CONVERSION,                                            
         ( SUM(PRIMARY_QUANTITY) * INV_CONVERT.INV_UM_CONVERT (MSIK.INVENTORY_ITEM_ID, MSIK.PRIMARY_UOM_CODE, 'KG')) AS KG_QTY,         
        SUM( SUM(PRIMARY_QUANTITY) * INV_CONVERT.INV_UM_CONVERT (MSIK.INVENTORY_ITEM_ID, MSIK.PRIMARY_UOM_CODE, 'KG')) OVER (PARTITION BY MSIK.ORGANIZATION_ID) TOTAL_WEIGHT,
         (NVL(ROUND((( SUM(PRIMARY_QUANTITY) * INV_CONVERT.INV_UM_CONVERT (MSIK.INVENTORY_ITEM_ID, MSIK.PRIMARY_UOM_CODE, 'KG')) / 
            SUM( SUM(PRIMARY_QUANTITY) * INV_CONVERT.INV_UM_CONVERT (MSIK.INVENTORY_ITEM_ID, MSIK.PRIMARY_UOM_CODE, 'KG')) OVER (PARTITION BY MSIK.ORGANIZATION_ID)), 9), 0)*100) AS PER_ITEM_EXPENSE      
       FROM   ORG_ORGANIZATION_DEFINITIONS OOD,
           MTL_SYSTEM_ITEMS_B_KFV MSIK,
           MTL_ITEM_CATEGORIES MIC,
           MTL_CATEGORIES_B MCB,
           MTL_MATERIAL_TRANSACTIONS MMT
      WHERE   TRANSACTION_ACTION_ID != 24             
        AND MMT.TRANSACTION_TYPE_ID IN (44, 17)     
        AND MCB.STRUCTURE_ID=50448
        AND ((OOD.ORGANIZATION_CODE IN ('002') AND MCB.SEGMENT1 IN ('FG') ) or (OOD.ORGANIZATION_CODE NOT IN ('002') AND MCB.SEGMENT1 IN ('SFG')))
        AND MSIK.ORGANIZATION_ID = MIC.ORGANIZATION_ID
        AND MSIK.ORGANIZATION_ID = OOD.ORGANIZATION_ID
        AND OOD.ORGANIZATION_ID = MIC.ORGANIZATION_ID
        AND MSIK.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
        AND OOD.ORGANIZATION_ID = MMT.ORGANIZATION_ID
        AND MSIK.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
        AND MIC.CATEGORY_ID = MCB.CATEGORY_ID
        AND LEGAL_ENTITY = P_LEGAL_ENTITY_ID 
        AND TRUNC(MMT.TRANSACTION_DATE) BETWEEN NVL(V_FROM_DT, TRUNC(MMT.TRANSACTION_DATE))  AND NVL(TRUNC(V_TO_DT),MMT.TRANSACTION_DATE)  
        AND MCB.SEGMENT2 IS NOT NULL
     GROUP BY  OOD.LEGAL_ENTITY,MSIK.ORGANIZATION_ID, OOD.ORGANIZATION_NAME, MSIK.INVENTORY_ITEM_ID, MSIK.CONCATENATED_SEGMENTS, MSIK.DESCRIPTION, MSIK.PRIMARY_UOM_CODE ,
        MCB.SEGMENT1, MCB.SEGMENT2, MSIK.SECONDARY_UOM_CODE, OOD.ORGANIZATION_CODE
     ORDER BY OOD.ORGANIZATION_CODE, MSIK.CONCATENATED_SEGMENTS ASC;       
BEGIN
    BEGIN
     DELETE FROM XX_EXP_ALLOC_DETAILS;
    EXCEPTION
        WHEN OTHERS THEN
        NULL;
    END;    
    FOR I IN C1 LOOP
     INSERT INTO XX_EXP_ALLOC_DETAILS(
          LEGAL_ENTITY,
          ORGANIZATION_ID,
          ORGANIZATION_NAME,
          INVENTORY_ITEM_ID,
          ITEM_CODE,
          ITEM_NAME,
          UOM,
          ITEM_MJR_CAT,
          ITEM_MNR_CAT,
          SECONDARY_UOM_CODE,
          PRIMARY_QUANTITY,
          KG_CONVERSION,
          KG_QTY,
          TOTAL_WEIGHT,
          PER_ITEM_EXPENSE)
          VALUES(
          I.LEGAL_ENTITY,
          I.ORGANIZATION_ID,
          I.ORGANIZATION_NAME,
          I.INVENTORY_ITEM_ID,
          I.ITEM_CODE,
          I.ITEM_NAME,
          I.UOM,
          I.ITEM_MJR_CAT,
          I.ITEM_MNR_CAT,
          I.SECONDARY_UOM_CODE,
          I.PRIMARY_QUANTITY,
          I.KG_CONVERSION,
          I.KG_QTY,
          I.TOTAL_WEIGHT,
          I.PER_ITEM_EXPENSE);
         END LOOP;
EXCEPTION
    WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'::::::::::::::::::::::::::::::::');
    FND_FILE.PUT_LINE(FND_FILE.LOG,':EXCEPTION RAISED:');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'::::::::::::::::::::::::::::::::');
END XX_EXP_ALLOC_DETAILS_PROC;
 
 



select *from org_organization_definitions where ORGANIZATION_CODE = '002';

SELECT *FROM GL_ALOC_BAS WHERE ALLOC_ID IN  (11)

DECLARE
 ERRBUFF VARCHAR2(100);
 RETCODE VARCHAR2(100);
 P_LEGAL_ENTITY_ID NUMBER;
BEGIN
 XX_EXP_ALLOC_BASIS_INSERT(ERRBUFF,RETCODE,23274,141,11,);
END;




CREATE OR REPLACE PROCEDURE XX_EXP_ALLOC_BASIS_INSERT (
   errbuf                 OUT VARCHAR2,
   retcod                 OUT VARCHAR2,
   V_LEGAL_ENTITY_ID   IN     NUMBER,
   V_ORGANIZATION_ID   IN     NUMBER,
   V_ALLOC_ID          IN     NUMBER,
   V_COMP_CLASS_ID     IN     NUMBER)
IS
   CURSOR C1
   IS   
      SELECT ROWNUM LINE_NO, A.*      
        FROM XX_EXP_ALLOC_DETAILS A
       WHERE 1=1--ORGANIZATION_ID = V_ORGANIZATION_ID
       AND NVL(PER_ITEM_EXPENSE,0) <> 0
       AND LEGAL_ENTITY = V_LEGAL_ENTITY_ID  ---23274
       AND ORGANIZATION_ID = V_ORGANIZATION_ID ---141
       ORDER BY ORGANIZATION_ID,ITEM_CODE;
       
           --  AND ALLOC_ID = V_ALLOC_ID
         /*    AND NOT EXISTS
                    (SELECT ALLOC_ID
                       FROM GL_ALOC_BAS
                      WHERE ALLOC_ID = A.ALLOC_ID)
             AND EXISTS
                    (  SELECT ALLOC_ID
                         FROM XX_PERCENTAGE_ALLOC
                        WHERE ALLOC_ID = A.ALLOC_ID
                     GROUP BY ALLOC_ID
                       HAVING SUM(NVL(ROUND(FIXED_PERCENT,9),0)) = 100); */

   V_USER_NAME           VARCHAR2 (150) := 'SYSADMIN';
   V_ALLOC_METHOD        NUMBER := 1;
   ----V_CMPNTCLS_ID         NUMBER := 8;
   V_CREATION_DATE       DATE := SYSDATE;
   V_CREATION_BY         NUMBER := 0;                               --SYSADMIN
   V_LAST_UPDATE_DATE    DATE := SYSDATE;
   V_LAST_UPDATE_LOGIN   NUMBER := 4342895;
   V_TRANSCNT            NUMBER := 0;
   V_DELETE_MARK         NUMBER;
   V_BASIS_TYPE          NUMBER := 1;
   V_MESSAGE             VARCHAR2 (400) := 'Message : Data already exists.';
   
   V_RECORD_COUNT       NUMBER;
   
   L_ORGANIZATION_CODE  VARCHAR2(10);
   L_ORGANIZATION_ID    NUMBER;
   
 --  V_DELETE_MARK        NUMBER;
   
BEGIN
   --DBMS_OUTPUT.ENABLE (1000000);

   SELECT COUNT(1) INTO V_DELETE_MARK
   FROM GL_ALOC_MST
   WHERE ALLOC_ID = V_ALLOC_ID
   AND   DELETE_MARK = 0;
 
   IF V_DELETE_MARK = 1 THEN  
       SELECT COUNT(1) INTO V_RECORD_COUNT
       FROM GL_ALOC_BAS
       WHERE ALLOC_ID = V_ALLOC_ID;
       
       IF V_RECORD_COUNT = 0 THEN 
           FOR C1_REC IN C1 LOOP
               
               /*IF C1_REC.ORGANIZATION_CODE IN ('FAN', 'MCB') THEN                
                  L_ORGANIZATION_CODE := 'BFG';
                  L_ORGANIZATION_ID   :=  215;
               ELSE
                  L_ORGANIZATION_CODE := C1_REC.ORGANIZATION_CODE;
                  L_ORGANIZATION_ID   := C1_REC.ORGANIZATION_ID;
               END IF;*/
               
             INSERT INTO GL_ALOC_BAS (ALLOC_ID,
                                      LINE_NO,
                                      ALLOC_METHOD,
                                      FIXED_PERCENT,
                                      CMPNTCLS_ID,
                                      ANALYSIS_CODE,
                                      CREATION_DATE,
                                      CREATED_BY,
                                      LAST_UPDATE_DATE,
                                      LAST_UPDATED_BY,
                                      LAST_UPDATE_LOGIN,
                                      TRANS_CNT,
                                      DELETE_MARK,
                                      BASIS_TYPE,
                                      INVENTORY_ITEM_ID,
                                      ORGANIZATION_ID
                                      )
                  VALUES (V_ALLOC_ID,
                          C1_REC.LINE_NO,
                          V_ALLOC_METHOD,
                          C1_REC.PER_ITEM_EXPENSE,
                          V_COMP_CLASS_ID,
                          ----V_CMPNTCLS_ID,
                          'IND',----L_ORGANIZATION_CODE,
                          V_CREATION_DATE,
                          V_CREATION_BY,
                          V_LAST_UPDATE_DATE,
                          V_CREATION_BY,
                          V_LAST_UPDATE_LOGIN,
                          V_TRANSCNT,
                          0,
                          V_BASIS_TYPE,
                          C1_REC.INVENTORY_ITEM_ID,
                          C1_REC.ORGANIZATION_ID
                          );                                
           END LOOP;
           COMMIT;
        END IF;
   END IF;
END;
/