<?xml version="1.0" encoding="UTF-8"?>
<!-- ************************************************************************** -->
<!-- XSLT Transformation db2_EvMonLocking_html.xsl                              -->
<!-- release 0.1.20200717                                                       -->
<!-- Description:                                                               -->
<!--   This stylesheet was designed to transform xml extracted from  UE Tables  -->
<!--   UE LOCKING EVENT MONITOR Tables into an html report                      -->
<!--                                                                            -->
<!-- Author:  Samuel Pizarro (samuel@pizarros.com.br)                           -->
<!--                                                                            -->
<!-- The Sample code is provided to you on an "AS IS" basis, without warranty   -->
<!-- of any kind. IBM HEREBY EXPRESSLY DISCLAIMS ALL WARRANTIES, EITHER         -->
<!-- EXPRESS OR  IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES -->
<!-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Some              -->
<!-- jurisdictions do not allow for the exclusion or limitation of implied      -->
<!-- warranties, so the above limitations or exclusions may not apply to you.   -->
<!-- IBM shall not be liable for any damages you suffer as a result of using,   -->
<!-- copying, modifying or distributing the Sample, even if IBM has been        -->
<!-- advised of the possibility of such damages.                                -->
<!--                                                                            -->
<!-- Revision history                                                           -->
<!-- Author           Version  Date       Change Description                    -->
<!-- **************** ******** ********** ************************************  -->
<!--                                                                            -->
<!-- ************************************************************************** -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:lm="http://www.ibm.com/xmlns/prod/db2/mon"
                xmlns:fn="http://www.w3.org/2005/02/xpath-functions" >

<xsl:output method="html"  encoding="UTF-8" omit-xml-declaration="yes" indent="no"/>

<!-- ========================================================================== -->
<!-- Template   : Main                                                          -->
<!-- Description: Main template to process the entire XML document              -->
<!-- ========================================================================== -->
<xsl:template match="lm:db2_evmon_format_ue_to_xml">
  <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&#10;</xsl:text>    
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <style type="text/css"> 
          @import url(https://fonts.googleapis.com/css?family=Montserrat:400,300,300italic,400italic,500,500italic,700,700italic,900,900italic,100italic,100);
          @import url(https://fonts.googleapis.com/css?family=Roboto:400,300,300italic,400italic,500,500italic,700,700italic,900,900italic,100italic,100);
          @import url(https://fonts.googleapis.com/css?family=Source+Code+Pro:400,300,300italic,400italic,500,500italic,700,700italic,900,900italic,100italic,100);
          
          html,body { 
            font-family: Roboto, Montserrat, Verdana,  Sans-serif ;
            font-size: 15px
          } 

          h4 { 
            margin: 5px 0px ;
          }

          /* Pure CSS collapse section */

          .collapse-list {
            margin-bottom: 0;
            padding-left: 0;
            list-style: none;
            border: none ; 
          }

          .collapse-open {
            display: none;
          }
          
          .collapse-painel {
            visibility: hidden;
            max-height: 0;
            opacity: 0;
            transition: max-height .1s,
            visibility .3s,
            opacity .3s;
          }
          
          .collapse-open:checked ~ .collapse-painel {
            max-height: 100%;
            opacity: 100;
            visibility: visible
          }
          
          .collapse-list li {
            margin: 3px 0 0 0 ;
          }
          
          .collapse-list .collapse-btn {
            background-color: #d9d9d9;
            /*border-top: 1px solid #e0e0e0; */
            border: none ; 
            cursor: pointer;
            display: block;
            padding: 15px 10px;
            margin-bottom: 0;
            color: #555;
            font-weight: normal;
            transition: background-color .2s ease;
          }

          .collapse-btn ul {
            display: inline ; 
            list-style-type: none;
            overflow: hidden;
            margin: 0px;
          }

          .collapse-btn li {
            float: left;
            max-width: 25% ;
            display: block;
            margin: 0px; 
          }

          .collapse-list .collapse-btn.collapse-truncate {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            padding-right: 5px ; 
          }
          
          .collapse-list .collapse-btn:hover {
            background: #eee;
          }

          .collapse-open:checked ~ .collapse-btn {
            background-color: #ccc;
          }


          .collapse-open ~ .collapse-btn:before {
            content: "\002B";
            float: right;
            padding-left: 5px;
            font-weight: bold;
          }
          
          .collapse-open:checked ~ .collapse-btn:before {
            content: "\2212";
          }
          
          .collapse-list .collapse-inner {
            padding: 10px ; 
          }
          
          /* Pure CSS collapse section - End */

          .grid-container-participant { 
            padding: 0 15px ; 
            background-color: white;
            overflow: hidden;
            display: grid ; 
            grid-gap: 10px;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            grid-auto-flow: dense;
          }

         

          div.tile {
            margin: 5px;
            border: 1px solid #ccc;
            float: left;
            min-width: 300px;
            font-size: 0.9em;
          }

          div.tile.participant {
            max-width: 48%;
            border: 1px solid #ccc;
          }

          table,th,td,tr {
            font-size: inherit;
            padding: 2px ; 
          }

          table.stmt_parameters {
            min-width:  60% ;   
          }
          table.style1 { 
            border-collapse: collapse;
            margin-bottom: 5px; 
          }

          table.style1 th {
            padding: 6px;
            background-color: #ccc ;
            text-align: left;
          }

          table.style1 td {
            padding: 2px 6px;
            border-bottom: 1px solid #ddd;
          }

          code, pre, .pre_wrap {
            font-family: "Source Code Pro", Consolas, monospaced; 
            white-space: pre-wrap ; 
            white-space: -moz-pre-wrap;  /* Mozilla, since 1999 */
            white-space: -pre-wrap;      /* Opera 4-6 */
            white-space: -o-pre-wrap;    /* Opera 7 */
            word-wrap: break-word;       /* Internet Explorer 5.5+ */                  
          }

          code.stmt_text, pre.stmt_text, .pre_wrap.stmt_text {
            margin: 5px 0px;
            padding: 6px; 
            background-color: BlanchedAlmond; 
          }


        </style>
      </head>
        <body>

          <h2>Db2 Event Monitor for Locking Report</h2>
          <ul class="collapse-list">

            <!-- ========================================================== -->
            <!-- Print out each lock event in details                       -->
            <!-- ========================================================== -->
            
            <xsl:for-each select="lm:db2_lock_event">
              
              <xsl:apply-templates select="." mode="details"/>

            </xsl:for-each>
            
            
          </ul>
 
        </body>
    </html>
</xsl:template>

<!-- ========================================================================== -->
<!-- Template   : Lock event details                                            -->
<!-- Description: Template will process each db2LockEvent node contained in the -->
<!--              XML document and print out the event details.                 -->
<!-- ========================================================================== -->
<xsl:template match="lm:db2_lock_event" mode="details">
  

  <!-- ========================================================== -->
  <!-- Print out the Event details header                         -->
  <!-- ========================================================== -->
  <xsl:variable name="lev_id" select="generate-id(.) " />
  <li>
    <input class="collapse-open" type="checkbox"> 
      <xsl:attribute name="id">
        <xsl:value-of select="$lev_id" />
      </xsl:attribute>
    </input>  
    <label class="collapse-btn">
      <xsl:attribute name="for">
        <xsl:value-of select="$lev_id" />
      </xsl:attribute>
        <ul>
          <li style="width:20ch"><xsl:value-of select="@type" /> </li>
          <li style="width:30ch">
            <xsl:call-template name="replace-string">
                <xsl:with-param name="text" select="@timestamp"/>
                <xsl:with-param name="replace" select="'T'" />
                <xsl:with-param name="with" select="' '"/>
            </xsl:call-template>
          </li>
          <li style="width:20ch">Event ID: <xsl:value-of select="@id" /> </li>
          <li>Db-Partition: <xsl:value-of select="@member" /></li>
        </ul>  
    </label>
    <div class="collapse-painel">
      <div class="collapse-inner">
        <!-- ========================================================== -->
        <!-- Print out the lock event report                            -->
        <!-- ========================================================== -->
      
        <xsl:choose>
          <xsl:when test="not(boolean(lm:db2_message))" >
            <xsl:if test="boolean(lm:db2_deadlock_graph)">
              <xsl:apply-templates select="lm:db2_deadlock_graph" />
            </xsl:if>

            <div class="grid-container-participant">
              <xsl:for-each select="lm:db2_participant">
                <xsl:apply-templates select="." mode="participants"/>
              </xsl:for-each>
            </div>

          </xsl:when>
          <xsl:when test="boolean(lm:db2_message)" >
            <xsl:value-of select="lm:db2_message/text()" />
            <xsl:if test="boolean(lm:db2_event_file)">
              <xsl:text>Filename: </xsl:text>
              <xsl:value-of select="lm:db2_event_file/text()" />
            </xsl:if>
            
          </xsl:when>
        </xsl:choose>
      </div>    
    </div>
  </li>
</xsl:template>


<!-- ========================================================================== -->
<!-- Template   : db2DeadlockGraph                                              -->
<!-- Description: Template will print in details the deadlock graph             -->
<!-- ========================================================================== -->
<xsl:template match="lm:db2_deadlock_graph">
  <h3>Deadlock Graph</h3>
  <div>
    <table class="style1">
      <tr>
        <td>Total number of deadlock participants</td>
        <td><xsl:value-of select="@dl_conns" /></td>
      </tr>
      <tr>
        <td>Participant that was rolled back</td>
        <td><xsl:value-of select="@rolled_back_participant_no" /></td>
      </tr>
      <tr>
        <td>Type of deadlock</td>
        <td><xsl:value-of select="@type" /></td>
      </tr>
    </table>
    <table class="style1">
      <tr>
        <th>Participant Requesting Lock</th>
        <th>Application Handle</th>
        <th>Application Name</th>
        <th>Participant Holding Lock</th>
        <th>Application Handle Holding Lock</th>
        <th>Deadlock Member</th>
      </tr>

      <xsl:for-each select="lm:db2_participant">
        <tr>
          <td><xsl:value-of select="@no" /></td>
          <td><xsl:value-of select="@application_handle" /></td>
          <td><xsl:value-of select="@appl_name" /></td>
          <td><xsl:value-of select="@participant_no_holding_lk" /></td>
          <td><xsl:value-of select="@application_handle_holding_lk" /></td>
          <td><xsl:value-of select="@deadlock_member" /></td>
        </tr>
      </xsl:for-each>
    </table>  
  </div>
</xsl:template>


<!-- ========================================================== -->
<!-- Template   : db2LockParticipant                            -->
<!-- Description: Print out the LockParticipant details         -->
<!--   /db2_lockevmon                                           -->
<!--     ./db2_lock_event/                                      -->
<!--        ./db2_participant                                   -->
<!-- ========================================================== -->
<xsl:template match="lm:db2_participant" mode="participants">
  <div>
    <div style="display: table">
      <h4>Participant #: <xsl:value-of select="@no" /> - <xsl:value-of select="@type" /></h4>
      <xsl:if test="boolean(lm:db2_app_details)">
        <xsl:apply-templates select="lm:db2_app_details" />
      </xsl:if>
      <xsl:if test="boolean(lm:db2_object_requested)">
        <xsl:apply-templates select="lm:db2_object_requested" />
      </xsl:if>
    </div>
    <!-- Participant Activities -->
    <div>
      <xsl:choose>
        <xsl:when test="boolean(lm:db2_activity)">
          <ul class="collapse-list">
            <li>
              <xsl:variable name="part_no" select="generate-id(.)" />
              <input class="collapse-open" type="checkbox">
                <xsl:attribute name="id"><xsl:value-of select="$part_no" /></xsl:attribute>
              </input>  
              <label class="collapse-btn" for="{$part_no}" >Participant Activities ...</label>
              <div class="collapse-painel">
                <div class="collapse-inner">
                  <!-- Current Activities block -->
                  <xsl:choose>
                    <xsl:when test="boolean(lm:db2_activity[@type='current'])">
                      <h4>Current Activities</h4>
                      <ul class="collapse-list">
                        <xsl:for-each select="lm:db2_activity[@type='current']">
                          <xsl:apply-templates select="."/>
                        </xsl:for-each>
                      </ul>
                    </xsl:when>
                    <xsl:otherwise>
                      <h4>Current Activities not available!</h4>
                    </xsl:otherwise>
                  </xsl:choose>
                  <!-- Past Activities block -->
                  <xsl:choose>
                    <xsl:when test="boolean(lm:db2_activity[@type='past'])">
                      <h4>Past Activities<span style="font-weight: normal;" > (Wrapped = <xsl:value-of select="lm:db2_app_details/lm:past_activities_wrapped" />) </span></h4>
                      <ul class="collapse-list">
                        <xsl:for-each select="lm:db2_activity[@type='past']">
                          <xsl:apply-templates select="."/>
                        </xsl:for-each>
                      </ul>
                    </xsl:when>
                    <xsl:otherwise>
                        <h4>No Past Activities!</h4>
                    </xsl:otherwise>
                  </xsl:choose>
                </div>
              </div>
            </li>
          </ul>
        </xsl:when>
        <xsl:otherwise>
            <div><h4>Activities not available or not collected</h4></div>
        </xsl:otherwise>
      </xsl:choose>
      
    </div>

  </div>
</xsl:template>

<!-- ========================================================== -->
<!-- Template   : db2ApplicationDetails                         -->
<!-- Description: Print out the App  details                    -->
<!--   /db2_lockevmon                                           -->
<!--     ./db2_lock_event/                                      -->
<!--        ./db2_participant/                                  -->
<!--           ./db2_app_details                                -->
<!-- ========================================================== -->
<xsl:template match="lm:db2_app_details">
  <div class="tile">
    <table>
      <tr>
        <th colspan="2">Application Details</th>
      </tr>
      <tr><td>Appl Handle</td><td>: <xsl:value-of select="lm:application_handle/text()" /></td></tr>
      <tr><td>Appl ID</td><td>: <xsl:value-of select="lm:appl_id/text()" /></td></tr>
      <tr><td>Appl Name</td><td>: <xsl:value-of select="lm:appl_name/text()" /></td></tr>
      <tr><td>Authentication ID</td><td>: <xsl:value-of select="lm:auth_id/text()" /></td></tr>
      <tr><td>Requesting AgentID</td><td>: <xsl:value-of select="lm:agent_tid/text()" /></td></tr>
      <tr><td>Coordinating AgentID</td><td>: <xsl:value-of select="lm:coord_agent_tid/text()" /></td></tr>
      <tr><td>Agent Status</td><td>: <xsl:value-of select="lm:agent_status/text()" /></td></tr>
      <tr><td>Application Action</td><td>: <xsl:value-of select="lm:appl_action/text()" /></td></tr>
      <tr><td>Lock timeout value (s)</td><td>: <xsl:value-of select="lm:lock_timeout_val/text()" /></td></tr>
      <tr><td>Lock wait value (ms)</td><td>: <xsl:value-of select="lm:lock_wait_val/text()" /></td></tr>
      <tr><td>Workload Name (ID)</td><td>: <xsl:value-of select="lm:workload_name/text()" /> (<xsl:value-of select="lm:workload_id/text()" />)</td></tr>
      <tr><td>Service superclass</td><td>: <xsl:value-of select="lm:service_superclass_name/text()" /></td></tr>
      <tr><td>Service Subclass (ID)</td><td>: <xsl:value-of select="lm:service_subclass_name/text()" /> (<xsl:value-of select="lm:service_class_id/text()" />)</td></tr>
      <tr><td>Current Request</td><td>: <xsl:value-of select="lm:current_request/text()" /></td></tr>
      <tr><td>TEntry state/flag1/flag2</td><td>: <xsl:value-of select="lm:tentry_state/@id" /> | <xsl:value-of select="lm:tentry_flag1/text()" /> | <xsl:value-of select="lm:tentry_flag2/text()" /></td></tr>
      <tr><td>Lock escalation</td><td>: <xsl:value-of select="lm:lock_escalation/text()" /></td></tr>
      <!-- this information is being reported in  'Past Activities section'
      <tr><td>Past Activities wrapped</td><td>: <xsl:value-of select="lm:past_activities_wrapped/text()" /></td></tr>
      -->
      <tr><td>Client userid</td><td>: <xsl:value-of select="lm:client_userid/text()" /></td></tr>
      <tr><td>Client wrkstnname</td><td>: <xsl:value-of select="lm:client_wrkstnname/text()" /></td></tr>
      <tr><td>Client applname</td><td style="word-break: break-all">: <xsl:value-of select="lm:client_applname/text()" /></td></tr>
      <tr><td>Client acctng</td><td style="word-break: break-all">: <xsl:value-of select="lm:client_acctng/text()" /></td></tr>
      <tr><td>Utility ID</td><td style="word-break: break-all">: <xsl:value-of select="lm:utility_invocation_id/text()" /></td></tr>
    </table>
  </div>
</xsl:template>

<!-- ========================================================== -->
<!-- Template   : db2ObjectRequested                            -->
<!-- Description: Print out the details regarding the lock in   -->
<!--              contention                                    -->
<!-- ========================================================== -->
<xsl:template match="lm:db2_object_requested">
  
  <div class="tile">
    <table>
      <xsl:choose>
        <xsl:when test="@type = 'lock'">
          
          <tr><th colspan="2">Object Requested details</th></tr>
          
          <tr><td><i>Participant Holding Lock</i></td><td>: <xsl:value-of select="../@participant_no_holding_lk" /></td></tr>
          <tr><td>Lock wait start time</td><td>: 
              <xsl:call-template name="replace-string">
                <xsl:with-param name="text" select="lm:lock_wait_start_time"/>
                <xsl:with-param name="replace" select="'T'" />
                <xsl:with-param name="with" select="' '"/>
              </xsl:call-template>
              <!--<xsl:value-of select="lm:lock_wait_start_time" />-->
          </td></tr>
          <tr><td>Lock wait end time</td><td>: 
              <xsl:call-template name="replace-string">
                <xsl:with-param name="text" select="lm:lock_wait_end_time"/>
                <xsl:with-param name="replace" select="'T'" />
                <xsl:with-param name="with" select="' '"/>
              </xsl:call-template>
              <!--<xsl:value-of select="lm:lock_wait_end_time" />--> 
          </td></tr>
          <tr><td>Lock Type</td><td>: <xsl:value-of select="lm:lock_object_type/text()" /></td></tr>
          <tr><td>Table Name (FID) </td><td>: <xsl:value-of select="lm:table_schema/text()" />.<xsl:value-of select="lm:table_name/text()" /> (<xsl:value-of select="lm:table_name/@id" />)</td></tr>
          
          <!-- ToDo: Try split the content into separete lines, to reduce the width.  --> 
          <!--        ex. 'ROWID=51,DATA_PARTITION_ID=0,PAGEID=1' --> 
          <!--          to  * ROWID = 51 ;  -->
          <!--              * DATA_PARTITION_ID = 0 ;  -->
          <!--              * PAGEID=1 = 0 ;  -->
          <!--<tr><td>Lock Specifics</td><td>: <xsl:value-of select="translate(lm:lock_specifics/text(),',','&lt;br&gt;')" /></td></tr> --> 
          <!--  references found about possible approaches   --> 
          <!--  https://stackoverflow.com/questions/8500652/comma-separated-string-parsing-xslt-to-for-each-node --> 
          
          <tr><td>Lock Specifics</td><td>: <xsl:value-of select="lm:lock_specifics/text()" /></td></tr>
          <tr><td>Tablespace Name (ID)</td><td>: <xsl:value-of select="lm:tablespace_name/text()" /> (<xsl:value-of select="lm:tablespace_name/@id" />)</td></tr>
          
          <tr><td>Lock Name</td><td>: 0x<xsl:value-of select="lm:lock_name/text()" /></td></tr>
          <tr><td>Lock Attributes</td><td>: <xsl:value-of select="lm:lock_attributes/text()" /></td></tr>
          <tr><td>Lock mode requested</td><td>: (<xsl:value-of select="lm:lock_mode_requested/@mode" />) <xsl:value-of select="lm:lock_mode_requested/text()" /></td></tr>
          <tr><td>Lock mode held</td><td>: (<xsl:value-of select="lm:lock_mode/@mode" />) <xsl:value-of select="lm:lock_mode/text()" /></td></tr>
          <xsl:if test="boolean(lm:current_lock_mode)">
            <tr><td>Current Lock mode</td><td>: <xsl:value-of select="lm:current_Lock_mode/text()" /></td></tr>
          </xsl:if>
          <tr><td>Lock Count</td><td>: <xsl:value-of select="lm:lock_count/text()" /></td></tr>
          <tr><td>Lock Hold Count</td><td>: <xsl:value-of select="lm:lock_hold_count/text()" /></td></tr>
          <tr><td>Lock rrIID</td><td>: <xsl:value-of select="lm:lock_rriid/text()" /></td></tr>
          <tr><td>Lock Status</td><td>: <xsl:value-of select="lm:lock_status/text()" /></td></tr>
          <tr><td>Lock release flags</td><td>: <xsl:value-of select="lm:lock_release_flags/text()" /></td></tr>
          
          
        </xsl:when>
        <xsl:when test="@type = 'ticket'">
          <tr><th colspan="2">Participant No <xsl:value-of select="../@no" /> requesting threshold ticket</th></tr>
          <tr><td>Threshold Name</td><td>: <xsl:value-of select="lm:threshold_name/text()" /></td></tr>
          <tr><td>Threshold Id</td><td>: <xsl:value-of select="lm:threshold_id/text()" /></td></tr>
          <tr><td>Queued agents</td><td>: <xsl:value-of select="lm:queued_agents/text()" /></td></tr>
          <tr><td>Queue start time</td><td>: 
              <xsl:call-template name="replace-string">
                <xsl:with-param name="text" select="lm:queue_start_time"/>
                <xsl:with-param name="replace" select="'T'" />
                <xsl:with-param name="with" select="' '"/>
              </xsl:call-template>
              <!-- <xsl:value-of select="lm:queue_start_time" /> --> 
          </td></tr>
        </xsl:when>
      </xsl:choose>
    </table>
  </div>
</xsl:template>

<!-- ========================================================== -->
<!-- Template   : db2ActivityDetails                            -->
<!-- Description: Print out the App  details                    -->
<!--   /db2_lockevmon                                           -->
<!--     ./db2_lock_event/                                      -->
<!--        ./db2_participant/                                  -->
<!--           ./db2_activity/db2_activity_details              -->
<!-- ========================================================== -->
<xsl:template match="lm:db2_activity">

  <xsl:variable name="pactiv_id" select="generate-id(.) " />
  <li>
    <input class="collapse-open" type="checkbox" id="{$pactiv_id}" />
    <label class="collapse-btn collapse-truncate" for="{$pactiv_id}"> 
      ID: <xsl:value-of select="lm:db2_activity_details/lm:activity_id/text()" /> | <xsl:value-of select="lm:db2_activity_details/lm:stmt_text/text()" />
    </label>
    <div class="collapse-painel">
      <div class="collapse-inner">

        <table>
          <tr><td>WOW Id / Activity</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:uow_id/text()" /> / <xsl:value-of select="lm:db2_activity_details/lm:activity_id/text()" /> </td></tr>
          <tr><td>Package</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:package_schema/text()" />.<xsl:value-of select="lm:db2_activity_details/lm:package_name/text()" /> </td></tr>
          <tr><td>Package Version</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:package_version_id/text()" /> </td></tr>
          <tr><td>Package Token</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:consistency_token/text()" /> </td></tr>
          <tr><td>Package Section Num</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:section_number/text()" /> </td></tr>
          <tr><td>Reopt Value</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:reopt/text()" /> </td></tr>
          <tr><td>Incremental Bind</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:incremental_bind/text()" /> </td></tr>
          <tr><td>Eff Isolation / Degree</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:effective_isolation/text()" /> / <xsl:value-of select="lm:db2_activity_details/lm:effective_query_degree/text()" /> </td></tr>
          <tr><td>Eff locktimeout</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:stmt_lock_timeout/text()" /> </td></tr>
          <tr><td>Stmt First Use</td><td>: 
              <xsl:call-template name="replace-string">
                <xsl:with-param name="text" select="lm:db2_activity_details/lm:stmt_first_use_time/text()"/>
                <xsl:with-param name="replace" select="'T'" />
                <xsl:with-param name="with" select="' '"/>
              </xsl:call-template>
              <!-- <xsl:value-of select="lm:db2_activity_details/lm:stmt_first_use_time/text()" />--> 
          </td></tr>
          <tr><td>Stmt Last Use</td><td>: 
              <xsl:call-template name="replace-string">
                <xsl:with-param name="text" select="lm:db2_activity_details/lm:stmt_last_use_time/text()"/>
                <xsl:with-param name="replace" select="'T'" />
                <xsl:with-param name="with" select="' '"/>
              </xsl:call-template>
              <!-- <xsl:value-of select="lm:db2_activity_details/lm:stmt_last_use_time/text()" /> --> 
          </td></tr>
          <tr><td>Stmt unicode</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:stmt_unicode/text()" /> </td></tr>
          <tr><td>Stmt query ID</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:stmt_query_id/text()" /> </td></tr>
          <tr><td>Stmt nesting level</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:stmt_nest_level/text()" /> </td></tr>
          <tr><td>Stmt invocation ID</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:stmt_invocation_id/text()" /> </td></tr>
          <tr><td>Stmt source ID</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:stmt_source_id/text()" /> </td></tr>
          <tr><td>Stmt pkgcache ID</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:stmt_pkgcache_id/text()" /> </td></tr>
          <tr><td>Stmt type</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:stmt_type/text()" /> </td></tr>
          <tr><td>Stmt operation</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:stmt_operation/text()" /> </td></tr>
          <tr><td>Stmt No</td><td>: <xsl:value-of select="lm:db2_activity_details/lm:stmtno/text()" /> </td></tr>
        </table>
        <!-- Full Stmt Text -->
        <pre class="stmt_text">
          <xsl:value-of select="lm:db2_activity_details/lm:stmt_text/text()" /> 
        </pre>

        <!-- Input Variable values for the statement -->
        <xsl:if test="boolean(lm:db2_input_variable)">
          <div style="overflow-x:auto;">
            <table class="stmt_parameters style1">
              <tr>
                <th>Index</th>
                <th>Type</th>
                <th>Reopt</th>
                <th>Null</th>
                <th>Data Value</th>
              </tr>
              <xsl:for-each select="lm:db2_input_variable">
                <tr>
                  <xsl:apply-templates select="." />
                </tr>
              </xsl:for-each>

            </table>
          </div>
        </xsl:if>
      </div>
    </div>
  </li>
</xsl:template>

<!-- ========================================================================== -->
<!-- Template   : Input variables                                               -->
<!-- Description: Template will print in details each input variable contained  -->
<!--              in the XML document for a statement.                          -->
<!--   /db2_lockevmon                                                           -->
<!--     ./db2_lock_event/                                                      -->
<!--        ./db2_participant/                                                  -->
<!--           ./db2_activity/db2_input_variable                                -->
<!-- ========================================================================== -->
<xsl:template match="lm:db2_input_variable">
  <!-- Index | Type | Reopt | Null | Data Value -->
  <td><xsl:value-of select="lm:stmt_value_index/text()" /></td>
  <td><xsl:value-of select="lm:stmt_value_type/text()" /></td>
  <td><xsl:value-of select="lm:stmt_value_isreopt/text()" /></td>
  <td>
    <xsl:choose>
      <xsl:when test="lm:stmt_value_isnull/text() = 1">NULL</xsl:when>
      <xsl:when test="lm:stmt_value_isnull/text() = 2">Default</xsl:when>
      <xsl:when test="lm:stmt_value_isnull/text() = 3">Unassigned</xsl:when>
      <xsl:otherwise>No</xsl:otherwise>
    </xsl:choose>
  </td>
  <td><xsl:value-of select="lm:stmt_value_data/text()" /></td>
  
</xsl:template>

<xsl:template name="replace-string">
    <xsl:param name="text"/>
    <xsl:param name="replace"/>
    <xsl:param name="with"/>
    <xsl:choose>
      <xsl:when test="contains($text,$replace)">
        <xsl:value-of select="substring-before($text,$replace)"/>
        <xsl:value-of select="$with"/>
        <xsl:call-template name="replace-string">
          <xsl:with-param name="text" select="substring-after($text,$replace)"/>
          <xsl:with-param name="replace" select="$replace"/>
          <xsl:with-param name="with" select="$with"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
