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
<cftry>

<cfquery name="rsCheck" datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
select * from p#variables.config.getPluginID()#_translationexports
where 0=1
</cfquery>

<cfcatch type="database">
	<cfswitch expression="#application.configBean.getDBType()#">
	<cfcase value="oracle">
		<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			CREATE TABLE "#ucase('p#variables.config.getPluginID()#_translationexports')#" 
			   (
					"EXPORTKEY" VARCHAR2(35),
				   	"SITEID" VARCHAR2(25), 
					"EXPORTDATE" DATETIME
			   )
		</cfquery>
	</cfcase>
	
	<cfcase value="mysql">
		<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			CREATE TABLE `p#variables.config.getPluginID()#_translationexports` (
	  		`exportkey` varchar(35),
	 	 	`siteID` varchar(25),
	  		`exportdate` datetime, 
	  		PRIMARY KEY  (`exportkey`)
			) ENGINE=InnoDB DEFAULT CHARSET=utf8
		</cfquery>
	</cfcase>
	
	<cfcase value="mssql">
		<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
		CREATE TABLE [dbo].[p#variables.config.getPluginID()#_translationexports] (
			[exportkey] [nvarchar] (35),
			[siteID] [nvarchar] (25),
			[exportdate] [datetime]
		) ON [PRIMARY] 
		</cfquery>
	</cfcase>
	
	</cfswitch>
	</cfcatch>
</cftry>