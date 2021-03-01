/* 
    Create base tables required/used by lock_evmon_html* procedures 

    Version:  1.0 

    DBAEVM.EVMON_XML_XSLT:  this table holds the XSL stylesheets documents that may be used to transform the XML into html reports. 
                            one base xsl is provided (db2_EvMonLocking_html.xsl), but users are free to change / enhance and create new ones,  
                             in order to create richer and better html layouts. 
                            Each xsl doc must have a unique name (XSL_NAME coulumn)

    DBAEVM.LOCK_EVMON_HTML_REPORT: User Temporary table that may hold the last generated html report. 
                                   this table can be usefull if user wants to execute the SP remotely,  and then export the html report remotelly using EXPORT utility with lobinsepfile modifier. 

    You may edit the 'IN  <tbspace>'  clause to create the tables in a specific tablespace. 

    Author: Samuel Pizarro  samuel@pizarros.com.br 

    Revision History 
    Reviewed by          Date       Version   Description 
    -------------------- ---------- --------- ----------------------------------------------------------------------------------
    S. Pizarro           2020-11-23       1.0 Initial Release 

*/


CREATE TABLE  DBAEVM.EVMON_XML_XSLT (
   DOC_ID INTEGER,   
   XSL_NAME VARCHAR(100) NOT NULL , 
   DESCRIPTION VARCHAR(255) , 
   XSL_DOC XML) 
--   IN  <tbspace>
@ 

CREATE UNIQUE INDEX DBAEVM.EVMON_XML_XSLT_NAME ON DBAEVM.EVMON_XML_XSLT ( XSL_NAME ASC ) @


CREATE GLOBAL TEMPORARY TABLE DBAEVM.LOCK_EVMON_HTML_REPORT 
    ( HTML_RPT CLOB(100 M) )
    ON COMMIT PRESERVE ROWS 
 --   IN  <tbspace>
 @