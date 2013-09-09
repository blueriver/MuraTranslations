<!---
   Copyright 2011 Blue River Interactive

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
--->
<cfcomponent output="false">

	<cfset variables.config=""/>
	
	<cffunction name="init" returntype="any" access="public" output="false">
		<cfargument name="config"  type="any" default="">
		<cfset variables.config = arguments.config>
		
		<cfset variables.cfcPath="plugins." & config.getDirectory() & ".cfcs">
		<cfset variables.translationManager=createObject("component","#variables.cfcPath#.translationManager").init(config.getConfigBean(),config)>

	</cffunction>
	
	<cffunction name="install" returntype="void" access="public" output="false">
		<cfset var sql = "">
		<cfset var x = "">
		<cfset var aSql = "">
		
        <cfif application.configBean.getDBType() eq "mysql">
            <cfsavecontent variable="sql">
                <cfinclude template="../dbScripts/mysqlInstall.cfm">
            </cfsavecontent>
            
            <cfset aSql = ListToArray(sql, ';')>
    
            <cfloop index="x" from="1" to="#arrayLen(aSql)#">
                <cfif len(trim(aSql[x]))>
				<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
                    #keepSingleQuotes(aSql[x])#
                </cfquery>
				</cfif>
            </cfloop>
			
			<cfset applyUpdates()/>

        <cfelseif application.configBean.getDBType() eq "postgresql">
            <cfsavecontent variable="sql">
                <cfinclude template="../dbScripts/postgresqlInstall.cfm">
            </cfsavecontent>

            <cfset aSql = ListToArray(sql, ';')>

            <cfloop index="x" from="1" to="#arrayLen(aSql)#">
                <cfif len(trim(aSql[x]))>
				<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
                    #keepSingleQuotes(aSql[x])#
                </cfquery>
				</cfif>
            </cfloop>

			<cfset applyUpdates()/>
            
        <cfelseif application.configBean.getDBType() eq "mssql">
        	<cfsavecontent variable="sql">
                <cfinclude template="../dbScripts/mssqlInstall.cfm">
            </cfsavecontent>
    
            <cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
                #keepSingleQuotes(sql)#
            </cfquery>
            
			<cfset applyUpdates()/>
			
		<cfelseif application.configBean.getDBType() eq "oracle">
	        	<cfsavecontent variable="sql">
	                <cfinclude template="../dbScripts/oracleInstall.cfm">
	            </cfsavecontent>

	             <cfset aSql = ListToArray(sql, ';')>

		         <cfloop index="x" from="1" to="#arrayLen(aSql) - 1#">
		             <cfif len(trim(aSql[x]))>
		             <cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
		                 #keepSingleQuotes(aSql[x])#
		             </cfquery>
		             </cfif>
		         </cfloop>
		         
		         <cfset applyUpdates()/>
        <cfelse>
        		<h1>Only MySQL, Microsoft SQL Server, PostgreSQL and Oracle are supported.</h1>
        	<cfabort>
        </cfif>
	</cffunction>
	
	<cffunction name="update" returntype="void" access="public" output="false">
		<cfset applyUpdates()/>
	</cffunction>
	
	<cffunction name="delete" returntype="void" access="public" output="false">
		<cfset var sql = "">
		<cfset var x = "">
		<cfset var aSql = "">
		
		<cfif application.configBean.getDBType() eq "mysql">
            <cfsavecontent variable="sql">
                <cfinclude template="../dbScripts/mysqlDelete.cfm">
            </cfsavecontent>
            
            <cfset aSql = ListToArray(sql, ';')>
            
            <cfloop index="x" from="1" to="#arrayLen(aSql) - 1#">
                <cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
                    #keepSingleQuotes(aSql[x])#
                </cfquery>		
            </cfloop>

		<cfelseif application.configBean.getDBType() eq "postgresql">
            <cfsavecontent variable="sql">
                <cfinclude template="../dbScripts/postgresqlDelete.cfm">
            </cfsavecontent>

            <cfset aSql = ListToArray(sql, ';')>

            <cfloop index="x" from="1" to="#arrayLen(aSql) - 1#">
                <cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
                    #keepSingleQuotes(aSql[x])#
                </cfquery>
            </cfloop>
       
        <cfelseif application.configBean.getDBType() eq "mssql">
        	<cfsavecontent variable="sql">
                <cfinclude template="../dbScripts/mssqlDelete.cfm">
            </cfsavecontent>
        
            <cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
                #keepSingleQuotes(sql)#
            </cfquery>		
            
		<cfelseif application.configBean.getDBType() eq "oracle"> 
			<cfsavecontent variable="sql">
                <cfinclude template="../dbScripts/oracleDelete.cfm">
            </cfsavecontent>
        
             <cfset aSql = ListToArray(sql, ';')>

	         <cfloop index="x" from="1" to="#arrayLen(aSql) - 1#">
	             <cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
	                 #keepSingleQuotes(aSql[x])#
	             </cfquery>
	         </cfloop>
        <cfelse>
        	<h1>Only MySQL, Microsoft SQL Server, PostgreSQL and Oracle are supported.</h1>
        	<cfabort>
        </cfif>
	</cffunction>
	
	<cffunction name="keepSingleQuotes" returntype="string" output="false">
		<cfargument name="str">
		<cfreturn preserveSingleQuotes(arguments.str)>
	</cffunction>
	
	<cffunction name="applyUpdates" returntype="void" access="public" output="false">

	<cfset var rsCheck ="" />
	<cfset var rsUpdates ="" />

	<cfdirectory action="list" directory="#expandPath('/plugins')#/#config.getDirectory()#/plugin/updates" name="rsUpdates" filter="*.cfm" sort="name asc">

	<cfloop query="rsUpdates">
		<cfinclude template="updates/#rsUpdates.name#">
	</cfloop>
	
</cffunction>
</cfcomponent>
