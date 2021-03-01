/* 
    Procedure:  DBAEVM.LOCK_EVMON_HTML_RPT 
   
    Description 
        Calls SP DBAEVM.AGGREGATED_XML_FROM_UE to retrieve the base aggregated xml data. 
        Transforms the xml into html using the provided xls parameter 
        Output final html and saves it into a DGTT to be used later (like exporting it to a remote location)

    Version:  1.0 

    Syntax: 
        DBAEVM.LOCK_EVMON_HTML_RPT ( ? , bKeepRpt , XLS_DOC_NAME, EVMON_TABLE_SCHEMA, EVMON_UE_TABLE, MEMBER, EVENT_TYPE, EVENT_START, EVENT_END  )

    Inputs: 
        bKeepRpt           : Boolean.  Indicates to save the html report in a temporary table: DBAEVM.LOCK_EVMON_HTML_REPORT 
                             Default = FALSE 
                             Data is only temporarily available (session scope). Data is gone after disconected from database. 
                             Only last execution is saved. Data is overwritten on every call (for the same connection) 

        XSL_DOC_NAME       : xsl docname to be assigned  "xml-stylesheet" attribute in the final xml declaration. 
                              Must be a valid xls doc name registered in DBAEVM.EVMON_XML_XSLT table. 

        EVMON_TABLE_SCHEMA : SCHEMA where the desired base UE table holding the event monitor data resides 

        EVMON_UE_TABLE     : UE table name where data is captured by the desired event monitor 

        MEMBER             : extract only events capured at the specified db-partition/member. 
                             If null, all members will be extracted. 
                             If -1,  only data from current member will be extracted. 

        EVENT_TYPE         : extract only events of the desired type.  Eg. LOCKTIMEOUT , DEADLOCK,  LOCKWAIT 
                             if null,  all event types are extracted. 

        EVENT_START        : extract only events newer than or equal to the specified timestamp (>=) 
                             if null,  no filter is applied.

        EVENT_END          : extract only events older than or equal to the specified timestamp (<=)
                             if null, no filter is applied. 

    OutPuts: 
        htmlOut : Final locking event monitor data transformed into html report by specified xsl. 
                  CLOB (100 MB). avoid generating too much information in the same html report, as rendering it on browser will consume too much time and resources. 

    Author: Samuel Pizarro  samuel@pizarros.com.br 

    Revision History 
    Reviewed by          Date       Version   Description 
    -------------------- ---------- --------- ----------------------------------------------------------------------------------
    S. Pizarro           2020-11-23       1.0 Initial Release 
    
*/

CREATE OR REPLACE PROCEDURE DBAEVM.LOCK_EVMON_HTML_RPT
 ( OUT htmlOut                CLOB (100 M ) , 
   IN  bKeepRpt               BOOLEAN       DEFAULT FALSE ,
   IN  XSL_DOC_NAME           VARCHAR(100), 
   IN  EVMON_TABLE_SCHEMA     VARCHAR(128), 
   IN  EVMON_UE_TABLE         VARCHAR(128) ,  
   IN  MEMBER                 SMALLINT      DEFAULT NULL, 
   IN  EVENT_TYPE             VARCHAR(128)  DEFAULT NULL,
   IN  EVENT_START            TIMESTAMP(10) DEFAULT NULL, 
   IN  EVENT_END              TIMESTAMP(10) DEFAULT NULL
 )

LANGUAGE SQL
SPECIFIC LOCK_EVMON_HTML_RPT
NO EXTERNAL ACTION 
MODIFIES SQL DATA 

BEGIN  
    -- variable sections
    DECLARE clbXML XML ; 
    
    CALL DBAEVM.AGGREGATED_XML_FROM_UE (clbXml, XSL_DOC_NAME, EVMON_TABLE_SCHEMA, EVMON_UE_TABLE, MEMBER, EVENT_TYPE, EVENT_START, EVENT_END ) ;
    
    SELECT XSLTRANSFORM ( clbXml USING XSLT.XSL_DOC AS CLOB(100 M) ) 
        INTO htmlOut 
    FROM DBAEVM.EVMON_XML_XSLT XSLT WHERE XSLT.XSL_NAME = XSL_DOC_NAME ;
        
    IF ( bKeepRpt = TRUE) THEN 

        DELETE FROM DBAEVM.LOCK_EVMON_HTML_REPORT ; 
        INSERT INTO DBAEVM.LOCK_EVMON_HTML_REPORT VALUES ( htmlOut ) ; 

    END IF ; 
END@