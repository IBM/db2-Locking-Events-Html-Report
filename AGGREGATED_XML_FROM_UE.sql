/* 
    Procedure:  DBAEVM.AGGREGATED_XML_FROM_UE
     
    Descripition
        Calls EVMON_FORMAT_UE_TO_XML table-function to produce an aggregated xml for the desired target events. 

    Version:  1.0 

    Syntax: 
        DBAEVM.AGGREGATED_XML_FROM_UE ( XLS_DOC_NAME, EVMON_TABLE_SCHEMA, EVMON_UE_TABLE, MEMBER, EVENT_TYPE, EVENT_START, EVENT_END  )

    Inputs: 
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
        xmlOut : aggregated XML, encaptulating desired event monitor events in a single XML doc. 

    Author: Samuel Pizarro  samuel@pizarros.com.br 

    Revision History 
    Reviewed by          Date       Version   Description 
    -------------------- ---------- --------- ----------------------------------------------------------------------------------
    S. Pizarro           2020-11-23       1.0 Initial Release 
    
*/ 


CREATE OR REPLACE PROCEDURE DBAEVM.AGGREGATED_XML_FROM_UE 
 ( OUT xmlOut                XML ,  
   IN XSL_DOC_NAME           VARCHAR(100), 
   IN EVMON_TABLE_SCHEMA     VARCHAR(128), 
   IN EVMON_UE_TABLE         VARCHAR(128) ,  
   IN MEMBER                 SMALLINT      DEFAULT NULL, 
   IN EVENT_TYPE             VARCHAR(128)  DEFAULT NULL,
   IN EVENT_START            TIMESTAMP(10) DEFAULT NULL, 
   IN EVENT_END              TIMESTAMP(10) DEFAULT NULL 
 ) 
 
 
 LANGUAGE SQL
 SPECIFIC AGGREGATED_XML_FROM_UE
 READS SQL DATA 
 NO EXTERNAL ACTION 
 
 BEGIN
    -- variables section 
    DECLARE isTableValid   VARCHAR(128) ; 
    DECLARE rcount         INTEGER ; 
    DECLARE sAuxText       VARCHAR(100) ; 
    DECLARE v_dynSQL       VARCHAR(1000) ; 
    DECLARE v_innerSQL     VARCHAR(300) ; 
    DECLARE sWhere_Clause  VARCHAR(300) ; 
    DECLARE sMember_Clause VARCHAR(30) DEFAULT NULL ; 
    DECLARE sType_Caluse   VARCHAR(30) DEFAULT NULL ; 
    DECLARE sStart_Cluase  VARCHAR(30) DEFAULT NULL ; 
    DECLARE sEnd_Clause    VARCHAR(30) DEFAULT NULL ; 

    -- cursors section 
    DECLARE cSql CURSOR FOR stmt_hdl ; 

    /* validate parameters */ 
    /* xsl doc name, must exist */ 
    /*  this validation is to avoid sql-injection later on, when building the final dynamic sql */ 
    IF ( NVL(XSL_DOC_NAME, '') <> '') THEN 
        SELECT XSL_NAME INTO isTableValid FROM DBAEVM.EVMON_XML_XSLT WHERE XSL_NAME = XSL_DOC_NAME ; 
        GET DIAGNOSTICS rcount = ROW_COUNT ; 
        IF ( rcount = 0 ) THEN 
            SET sAuxText = ( XSL_DOC_NAME || '" is a unknown XSLT.' ) ;
            SIGNAL SQLSTATE '42704' SET  MESSAGE_TEXT = sAuxText ;
            RETURN  ; 
        END IF ; 
    END IF; 

    /* table schema */ 
    IF ( NVL(EVMON_TABLE_SCHEMA , '') = '') THEN 
        SIGNAL SQLSTATE '39004' SET MESSAGE_TEXT = 'Parameter "EVMON_TABLE_SCHEMA" can NOT be null or empty string.';
        RETURN  ; 
    END IF ; 
    /* table name */ 
    IF ( NVL(EVMON_UE_TABLE , '') = '') THEN 
        SIGNAL SQLSTATE '39004' SET MESSAGE_TEXT = 'Parameter "EVMON_UE_TABLE" can NOT be null or empty string.';
        RETURN  ; 
    ELSE 
        /* Check if table exists */ 
        SELECT TABNAME INTO isTableValid FROM SYSCAT.TABLES WHERE TABSCHEMA = EVMON_TABLE_SCHEMA AND  TABNAME = EVMON_UE_TABLE ; 
        GET DIAGNOSTICS rcount = ROW_COUNT;
        IF ( rcount = 0 ) THEN 
            SET sAuxText = ('Table "' || EVMON_TABLE_SCHEMA || '.' ||  EVMON_UE_TABLE || '" is an undefined name.' ) ;
            SIGNAL SQLSTATE '42704' SET  MESSAGE_TEXT = sAuxText ;
            RETURN  ; 
        END IF ; 
    END IF ;

    /* member */  
    IF (MEMBER = -1 ) THEN 
        SET MEMBER =  CURRENT MEMBER ; 
    ELSEIF ( MEMBER = -2 ) THEN 
        SET MEMBER = NULL ; 
    END IF ;


 
    -- SET the inner select from UE table. (2nd parameter from EVMON_FORMAT_UE_TO_XML 
    SET v_innerSQL = 'SELECT * from ' || EVMON_TABLE_SCHEMA || '.' || EVMON_UE_TABLE  ; 
     
    IF ( MEMBER IS NOT NULL )  THEN 
        SET sWhere_Clause = ' (MEMBER = ?) '  ;
    END IF ;
    IF ( EVENT_TYPE IS NOT NULL ) THEN 
        SET sWhere_Clause = ( NVL2(sWhere_Clause, sWhere_Clause || ' AND ', '') || ' (EVENT_TYPE = ?) ') ; 
    END IF ; 
    IF ( EVENT_START IS NOT NULL ) THEN 
        SET sWhere_Clause =  ( NVL2(sWhere_Clause, sWhere_Clause || ' AND ', '') || ' (EVENT_TIMESTAMP >= ?) ' ) ; 
    END IF ; 
    IF ( EVENT_END IS NOT NULL ) THEN 
        SET sWhere_Clause = ( NVL2(sWhere_Clause, sWhere_Clause || ' AND ', '') || ' (EVENT_TIMESTAMP <= ?) ' ); 
    END IF ; 
    SET sWhere_Clause = NVL2 ( sWhere_Clause, ' WHERE (' || sWhere_Clause || ') ', NULL ) ; 

    IF ( NVL(sWhere_Clause, '') <> '')  THEN 
        SET v_innerSQL = v_innerSQL || sWhere_Clause ;
    END IF; 

    SET v_innerSQL = v_innerSQL || ' ORDER BY EVENT_TIMESTAMP DESC, MEMBER ASC, EVENT_ID DESC, EVENT_TYPE' ;
    
    SET v_dynSQL = 'WITH BASE AS ( ' || 
                   ' SELECT XMLPARSE(DOCUMENT XMLREPORT) XMLRPT ' || 
                   '   FROM TABLE( EVMON_FORMAT_UE_TO_XML( ''SUPPRESS_PARTIAL_EVENTS_ERR'' ,  FOR EACH ROW OF( ' || v_innerSQL || ' ) )) ' || 
                   ' )   ' || 
                   ' SELECT XMLDOCUMENT( XMLCONCAT(   ' || 
                   '               XMLPI(NAME "xml-stylesheet", ''type="text/xsl" href="' || XSL_DOC_NAME || '"'' ), ' || 
                   '               XMLELEMENT( NAME "db2_evmon_format_ue_to_xml", XMLNAMESPACES(DEFAULT ''http://www.ibm.com/xmlns/prod/db2/mon''),  XMLAGG( XMLRPT  )) ) ' || 
                   '         ) XML_DOC FROM BASE  '  
    ;

    --CALL DBMS_OUTPUT.PUT_LINE (v_dynSQL) ; 
    
    PREPARE stmt_hdl FROM v_dynSQL ; 
    CASE 
        -- # 01: none
        WHEN ( MEMBER IS     NULL  AND EVENT_TYPE IS     NULL  AND EVENT_START IS     NULL  AND EVENT_END IS     NULL ) THEN 
            OPEN cSql  ; 
        -- only 1 / 3 combinations 
        -- # 02: only member
        WHEN ( MEMBER IS NOT NULL  AND EVENT_TYPE IS     NULL  AND EVENT_START IS     NULL  AND EVENT_END IS     NULL ) THEN 
            OPEN cSql USING MEMBER  ; 
        -- # 03: only event_type 
        WHEN ( MEMBER IS     NULL  AND EVENT_TYPE IS NOT NULL  AND EVENT_START IS     NULL  AND EVENT_END IS     NULL ) THEN 
            OPEN cSql USING EVENT_TYPE  ; 
        -- # 04: only event_start 
        WHEN ( MEMBER IS     NULL  AND EVENT_TYPE IS     NULL  AND EVENT_START IS NOT NULL  AND EVENT_END IS     NULL ) THEN 
            OPEN cSql USING EVENT_START  ; 
        -- # 05: only event_end 
        WHEN ( MEMBER IS     NULL  AND EVENT_TYPE IS     NULL  AND EVENT_START IS     NULL  AND EVENT_END IS NOT NULL ) THEN 
            OPEN cSql USING EVENT_END  ; 
        -- 2 / 2 conbinations
        -- # 06: member / event_type 
        WHEN ( MEMBER IS NOT NULL  AND EVENT_TYPE IS NOT NULL  AND EVENT_START IS     NULL  AND EVENT_END IS     NULL ) THEN 
            OPEN cSql USING MEMBER , EVENT_TYPE  ; 
        -- # 07: member / start 
        WHEN ( MEMBER IS NOT NULL  AND EVENT_TYPE IS     NULL  AND EVENT_START IS NOT NULL  AND EVENT_END IS     NULL ) THEN 
            OPEN cSql USING MEMBER , EVENT_START  ; 
        -- # 08: member / end  
        WHEN ( MEMBER IS NOT NULL  AND EVENT_TYPE IS     NULL  AND EVENT_START IS     NULL  AND EVENT_END IS NOT NULL ) THEN 
            OPEN cSql USING MEMBER , EVENT_END ; 
        --  #09: type / start 
        WHEN ( MEMBER IS     NULL  AND EVENT_TYPE IS NOT NULL  AND EVENT_START IS NOT NULL  AND EVENT_END IS     NULL ) THEN 
            OPEN cSql USING EVENT_TYPE , EVENT_START ; 
        -- # 10: type / end 
        WHEN ( MEMBER IS     NULL  AND EVENT_TYPE IS NOT NULL  AND EVENT_START IS     NULL  AND EVENT_END IS NOT NULL ) THEN 
            OPEN cSql USING EVENT_TYPE , EVENT_END  ; 
        -- # 11: start / end 
        WHEN ( MEMBER IS     NULL  AND EVENT_TYPE IS     NULL  AND EVENT_START IS NOT NULL  AND EVENT_END IS NOT NULL ) THEN 
            OPEN cSql USING EVENT_START , EVENT_END ; 
        -- 3 / 1 combinations
        -- # 12: member / type / start  
        WHEN ( MEMBER IS NOT NULL  AND EVENT_TYPE IS NOT NULL  AND EVENT_START IS NOT NULL  AND EVENT_END IS     NULL ) THEN 
            OPEN cSql USING MEMBER , EVENT_TYPE , EVENT_START ; 
        -- # 13: member / type / end  
        WHEN ( MEMBER IS NOT NULL  AND EVENT_TYPE IS NOT NULL  AND EVENT_START IS     NULL  AND EVENT_END IS NOT NULL ) THEN 
            OPEN cSql USING MEMBER , EVENT_TYPE , EVENT_END ; 
        -- # 14: member / start / end  
        WHEN ( MEMBER IS NOT NULL  AND EVENT_TYPE IS     NULL  AND EVENT_START IS NOT NULL  AND EVENT_END IS NOT NULL ) THEN 
            OPEN cSql USING MEMBER , EVENT_START , EVENT_END ; 
        -- # 15: type / start  / end 
        WHEN ( MEMBER IS     NULL  AND EVENT_TYPE IS NOT NULL  AND EVENT_START IS NOT NULL  AND EVENT_END IS NOT NULL ) THEN 
            OPEN cSql USING EVENT_TYPE , EVENT_START , EVENT_END ; 
        -- # 16: all 
        ELSE 
            OPEN cSql USING MEMBER, EVENT_TYPE, EVENT_START, EVENT_END ; 

    END CASE ; 
    FETCH cSql INTO  xmlOut ; 
    CLOSE cSql ; 
    
 END@