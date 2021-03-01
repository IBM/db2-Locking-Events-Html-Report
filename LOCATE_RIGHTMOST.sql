/* 
    Function: DBAEVM.LOCATE_RIGHTMOST 

    Description
        locates the rightmost occurrece of search-string in a source-string, and returns its (left based) position  
        similar to LOCATE function, but it finds the right-most occurrence. 
    
    Syntax: 
        DBAEVM.LOCATE_RIGHTMOST( SOURCE_STRING, SEARCH_STRING )

    Inputs: 
        SOURCE_STRING : base string where the search will be performed on. 

        SEARCH_STRING : substring to search on source_string.  

    Returns: 
        Position of search_string is found on source_string. Otherwise 0 


    Author: Samuel Pizarro  samuel@pizarros.com.br 

    Revision History 
    Reviewed by          Date       Version   Description 
    -------------------- ---------- --------- ----------------------------------------------------------------------------------
    S. Pizarro           2020-11-23       1.0 Initial Release 

*/ 

CREATE OR REPLACE FUNCTION DBAEVM.LOCATE_RIGHTMOST ( IN  SOURCE_STRING VARCHAR(32672 OCTETS ) , IN SEARCH_STRING VARCHAR(100 OCTETS) ) RETURNS INTEGER 
 LANGUAGE SQL 
 SPECIFIC LOCATE_RIGHTMOST 
 NO EXTERNAL ACTION 
 DETERMINISTIC
 CONTAINS SQL 

BEGIN ATOMIC 
    DECLARE bLoop      SMALLINT DEFAULT 1  ; 
    DECLARE iSourceLen INTEGER ; 
    DECLARE iSearchLen INTEGER ; 
    DECLARE iPos       INTEGER ; 
    
    SET iSourceLen = LENGTH(SOURCE_STRING) ; 
    SET iSearchLen = LENGTH(SEARCH_STRING) ; 
    SET iPos = (iSourceLen - iSearchLen + 1 ) ; 

    WHILE ( (bLoop > 0 ) AND (iPos > 0) ) DO
        
        IF (SUBSTR(SOURCE_STRING, iPos, iSearchLen) = SEARCH_STRING ) THEN 
            SET bLoop = 0 ; 
        ELSE 
            SET iPos = iPos -1 ; 
        END IF ; 

    END WHILE ; 

    RETURN iPos ; 
END@ 
