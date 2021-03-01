/* 
    Procedure:    DBAEVM.LOCK_EVMON_HTML_REPORT_TO_FILE 

    Description
        Calls LOCK_EVMON_HTML_RPT to produce an html report for locking event monitoring data, 
            and saves it into a local .html file at the server 
     
    Version:  1.0 

    Syntax: 
        DBAEVM.LOCK_EVMON_HTML_REPORT_TO_FILE ( ?, OUT_DIR, OUT_FILE,  XLS_DOC_NAME, EVMON_TABLE_SCHEMA, EVMON_UE_TABLE, MEMBER, EVENT_TYPE, EVENT_START, EVENT_END  )

    OutPut Params: 
        RESULT_MSG : string output indicating successfull or failures for the sp execution. 

    In-Out Params: 
        OUT_DIR            : Target directory where the html report shall be saved. This must be a local directory at the database server. 
                              Directory must already exist. the SP will not create any directory.  
                              It also must have write permission to the Instance Owner ID. 

        OUT_FILE           : Name of the html report file that will be created. File must end with '.html' 

    Input Params: 
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


    Author: Samuel Pizarro  samuel@pizarros.com.br 

    Revision History 
    Reviewed by          Date       Version   Description 
    -------------------- ---------- --------- ----------------------------------------------------------------------------------
    S. Pizarro           2020-11-23       1.0 Initial Release 
    
*/ 

CREATE OR REPLACE PROCEDURE DBAEVM.LOCK_EVMON_HTML_REPORT_TO_FILE 
 ( 
   OUT    RESULT_MSG           VARCHAR(100) ,
   INOUT  OUT_DIR              VARCHAR(250), 
   INOUT  OUT_FILE             VARCHAR(50) ,
   IN     XSL_DOC_NAME         VARCHAR(100), 
   IN     EVMON_TABLE_SCHEMA   VARCHAR(128), 
   IN     EVMON_UE_TABLE       VARCHAR(128) ,  
   IN     MEMBER               SMALLINT      DEFAULT NULL, 
   IN     EVENT_TYPE           VARCHAR(128)  DEFAULT NULL,
   IN     EVENT_START          TIMESTAMP(10) DEFAULT NULL, 
   IN     EVENT_END            TIMESTAMP(10) DEFAULT NULL
  )
LANGUAGE SQL 
SPECIFIC LOCK_EVMON_HTML_REPORT_TO_FILE
EXTERNAL ACTION 
MODIFIES SQL DATA 

BEGIN 
    DECLARE SQLCODE         INT DEFAULT 0;
    DECLARE SQLSTATE        CHAR(5) DEFAULT '00000';
    DECLARE v_fileHdl       UTL_FILE.FILE_TYPE ; 
    DECLARE isOpen          BOOLEAN ; 
    DECLARE v_dirAlias      VARCHAR(50) DEFAULT 'outdir';
    DECLARE cl_html         CLOB(100 M) ; 
    DECLARE ChunkData       VARCHAR(32672); 
    DECLARE iBlockLen       INTEGER DEFAULT 32672 ;  
    DECLARE iPos, Clob_Len  INTEGER DEFAULT 1 ; 
    DECLARE ibrkPos         INTEGER DEFAULT 0 ; 
    
    DECLARE FOPEN_error     CONDITION FOR SQLSTATE '58024'; 
    
    -- Handlers 
    DECLARE EXIT HANDLER FOR FOPEN_error 
    H1:  BEGIN
        SET RESULT_MSG = 'Unable to Open file in write mode at "' || OUT_DIR || '" directory. SQLSTATE=' || SQLSTATE  ; 
        RETURN -1 ; 
    END ; 

    /* input validations */ 
    /* File name must end with '.html' for security reasons */ 
    IF (LOWER(RIGHT(OUT_FILE, 5)) <> '.html') THEN 
        SET RESULT_MSG = 'Out_File must be a .html type'   ; 
        RETURN -2 ; 
    END IF ; 
    
    /*  */
    CALL UTL_DIR.CREATE_OR_REPLACE_DIRECTORY(v_dirAlias, OUT_DIR) ; 
    SET v_fileHdl = UTL_FILE.FOPEN(v_dirAlias, OUT_FILE, 'w', 32767 ) ; 
    SET isOpen = UTL_FILE.IS_OPEN(	v_fileHdl ) ; 
    IF ( isOpen != TRUE ) THEN 
        SET RESULT_MSG = 'Unable to Open file in write mode at "' || OUT_DIR || '" directory. SQLSTATE=' || SQLSTATE  ; 
        RETURN -3 ; 
    END IF; 

    -- CALL base LOCK_EVMON_HTML_RPT,  do not populate temp table. 
    CALL DBAEVM.LOCK_EVMON_HTML_RPT(cl_html, FALSE, XSL_DOC_NAME, EVMON_TABLE_SCHEMA, EVMON_UE_TABLE, MEMBER, EVENT_TYPE, EVENT_START, EVENT_END ) ; 


    VALUES LENGTH(cl_html) INTO Clob_Len ;    
    
    
    WHILE ( iPos <= Clob_Len  ) DO 
        SET ChunkData = SUBSTR( cl_html, iPos, MIN(iBlockLen, Clob_Len - iPos + 1)) ; 

        SET ibrkPos = DBAEVM.LOCATE_RIGHTMOST(ChunkData, chr(10)) ; 
        IF (ibrkPos > 0 ) THEN 
            -- breakline LF was found.  lets use it. 
            CALL UTL_FILE.PUT_LINE(v_fileHdl, LEFT(ChunkData, ibrkPos - 1)) ;	
            SET iPos = (iPos + ibrkPos ) ; 
        ELSE 
            -- no LF, lets try to break between two html tags >< 
            SET ibrkPos = DBAEVM.LOCATE_RIGHTMOST(ChunkData, '><') ; 
            IF (ibrkPos > 0 ) THEN 
                CALL UTL_FILE.PUT_LINE(v_fileHdl, LEFT(ChunkData, ibrkPos)) ;	
                SET iPos = (iPos + ibrkPos) ; 
            ELSE
                -- Probably, last chunk
                CALL UTL_FILE.PUT_LINE(v_fileHdl, ChunkData) ;
                SET iPos = (iPos + iBlockLen) ; 

            END IF ; 
        END IF ; 
        
    END WHILE ; 

    CALL UTL_FILE.FCLOSE (v_fileHdl) ; 
    CALL UTL_DIR.DROP_DIRECTORY(v_dirAlias) ; 
    
    SET RESULT_MSG = 'HTML Report file generated successfully at desired location' ; 
    RETURN 0 ; 

END@  