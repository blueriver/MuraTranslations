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
select * from p#variables.config.getPluginID()#_translationkeys
where 0=1
</cfquery>

<cfcatch type="database">

	<cfswitch expression="#application.configBean.getDBType()#">
	<cfcase value="oracle">
		<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			CREATE TABLE "#ucase('p#variables.config.getPluginID()#_translationkeys')#" 
			   (	"SITEID" VARCHAR2(25), 
					"NAME" VARCHAR2(100),	
					"SELECTORLABEL" VARCHAR2(100)
			   )
		</cfquery>
	
		<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			ALTER TABLE "#ucase('p#variables.config.getPluginID()#_translationkeys')#" ADD CONSTRAINT "#ucase('p#variables.config.getPluginID()#_translationkeys')#_SITEID" PRIMARY KEY ("SITEID") ENABLE
		</cfquery>
		
		<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			ALTER TABLE "#ucase('p#variables.config.getPluginID()#_translationkeys')#" MODIFY ("SITEID" NOT NULL ENABLE)
		</cfquery>
		
		<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			ALTER TABLE "#ucase('p#variables.config.getPluginID()#_translationkeys')#" MODIFY ("NAME" NOT NULL ENABLE)
		</cfquery>
		
		<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			ALTER TABLE "#ucase('p#variables.config.getPluginID()#_translationkeys')#" MODIFY ("SELECTORLABEL" NOT NULL ENABLE)
		</cfquery>
	</cfcase>
	
	<cfcase value="mysql">
		<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			CREATE TABLE `p#variables.config.getPluginID()#_translationkeys` (
	 	 	`siteID` varchar(25) NOT NULL,
	  		`name` varchar(100) NOT NULL,
	  		`selectorlabel` varchar(100) NOT NULL, 
	  		PRIMARY KEY  (`siteID`)
			) ENGINE=InnoDB DEFAULT CHARSET=utf8
		</cfquery>
	</cfcase>

	<cfcase value="postgresql">
		<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			CREATE TABLE p#variables.config.getPluginID()#_translationkeys (
	 	 	siteID varchar(25) NOT NULL,
	  		name varchar(100) NOT NULL,
	  		selectorlabel varchar(100) NOT NULL,
	  		CONSTRAINT PK_p#variables.config.getPluginID()#_translationkeys PRIMARY KEY (siteID)
			)
		</cfquery>
	</cfcase>
	
	<cfcase value="mssql">
		<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
		CREATE TABLE [dbo].[p#variables.config.getPluginID()#_translationkeys] (
			[siteID] [nvarchar] (25) NOT NULL ,
			[name] [nvarchar] (100) NOT NULL,
			[selectorlabel] [nvarchar] (100) NOT NULL
		) ON [PRIMARY] 
		</cfquery>
		
		<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
		ALTER TABLE [dbo].[p#variables.config.getPluginID()#_translationkeys] WITH NOCHECK ADD 
		CONSTRAINT [p#variables.config.getPluginID()#_PK_translationkeys] PRIMARY KEY  CLUSTERED 
		(
			[siteID]
		)  ON [PRIMARY] 
		</cfquery>
	
	</cfcase>
	
	</cfswitch>
	
	<cfset rsCheck=variables.translationManager.getAssignedSites()>
	
	<cfloop query="rsCheck">
		<cfset translationKeys=variables.translationManager.getTranslationKeys()>
		<cfset translationKeys.setSiteID(rsCheck.siteID)>
		<cfset translationKeys.load()>
		<cfif len(rsCheck.sitelocale)>
			<cfset translationKeys.setName(rsCheck.sitelocale)>
		<cfelse>
			<cfset translationKeys.setName(rsCheck.site)>
		</cfif>
		<cfset translationKeys.setSelectorLabel("Select Locale")>
		<cfset translationKeys.save()>
	</cfloop>
	

	</cfcatch>
</cftry>