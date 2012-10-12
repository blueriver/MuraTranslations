<cfcomponent>

	<cffunction name="createExport" returntype="string">
		<cfargument name="$">
		<cfargument name="sinceDate">
		<cfargument name="template" default="default">
		
		<cfset var exportObject = "" />
		<cfset var pluginConfig = $.getPlugin('LocaleTransMgr')/>
		<cfset var exportDirectory = expandPath("/#pluginConfig.getDirectory()#/exports") />

		<cfset var contentFeed = "" />
		<cfset var contentIterator = "" />
		<cfset var componentFeed = "" />
		<cfset var componentIterator = "" />

		<cfset var rsComponents = "" />
		<cfset var rsContentCategories = "" />
		
		<cfset var exportKey = "" />
		<cfset var rsUpdateExport = "" />

		<cfset var exportTemplate = rereplaceNoCase(arguments.template,"[^a-z]","","all") />
		<cfset var exportObject = createObject("component","#pluginConfig.getDirectory()#.translations.templates.#exportTemplate#.export") />

		<cfif not directoryExists(exportDirectory)>
			<cfset directoryCreate(exportDirectory)>
		</cfif>

		<cfset contentFeed = $.getBean('feed').loadby(siteID=$.event('siteID')) />
		<cfset contentFeed.setMaxItems(0) />
		<cfif isDate(arguments.sinceDate)>
			<cfset contentFeed.addParam(field='tcontent.created',condition='GTE',criteria=createODBCDate(arguments.sinceDate),dataType='date') />
		</cfif>
		<cfset contentIterator = contentFeed.getIterator() />
		<cfset contentIterator.setNextN(0) />

		<cfquery name="rsComponents" datasource="#$.globalConfig().getDatasource()#" username="#$.globalConfig().getDBUsername()#" password="#$.globalConfig().getDBPassword()#">
			select * from tcontent where siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#$.event('siteID')#"/> 
			and type = 'Component'
				and (active = 1 or (changesetID is not null and approved=0))
			<cfif isDate(arguments.sinceDate)>
			and
				created >= #createODBCDate(arguments.sinceDate)# 
			</cfif>
		</cfquery>

		<cfset componentIterator = $.getBean('contentIterator').setQuery(rsComponents) />

		<cfquery name="rsContentCategories" datasource="#$.globalConfig().getDatasource()#" username="#$.globalConfig().getDBUsername()#" password="#$.globalConfig().getDBPassword()#">
			select * from tcontentcategories where siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#$.event('siteID')#"/>
			<cfif isDate(arguments.sinceDate)>
			and
				dateCreated >= #createODBCDate(arguments.sinceDate)# 
			</cfif>
		</cfquery>

		<cfset exportKey = exportObject.export($,exportDirectory,contentIterator,componentIterator,rsContentCategories) />

		<cfquery name="rsUpdateExport" datasource="#$.globalConfig().getDatasource()#" username="#$.globalConfig().getDBUsername()#" password="#$.globalConfig().getDBPassword()#">
			insert into p#pluginConfig.getPluginID()#_translationexports
			(siteID,exportdate,exportKey)
			VALUES
			('#$.event().getValue('siteID')#',#CreateODBCDateTime(now())#,'#exportKey#')
		</cfquery>
		
		<cfreturn exportKey />
	</cffunction>

	<cffunction name="getLatestExportDate" returntype="string">
		<cfargument name="$">

		<cfset var rsExport = "" />
		<cfset var pluginConfig = $.getPlugin('LocaleTransMgr')/>

		<cfquery name="rsExport" datasource="#$.globalConfig().getDatasource()#" username="#$.globalConfig().getDBUsername()#" password="#$.globalConfig().getDBPassword()#">
			select max(exportdate) AS maxdate from p#pluginConfig.getPluginID()#_translationexports
			where siteID = '#$.event().getValue('siteID')#'
		</cfquery>

		<cfif rsExport.recordCount>
			<cfreturn rsExport.maxdate>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>


	<cffunction name="importTranslation">
		<cfargument name="$">
		<cfargument name="template">
		<cfargument name="importDirectory">
		<cfargument name="importFile">

		<cfset var keyFactory = "" />
		<cfset var pluginConfig = $.getPlugin('LocaleTransMgr')/>
		<cfset var exportTemplate = rereplaceNoCase(arguments.template,"[^a-z]","","all") />
		<cfset var exportObject = createObject("component","#pluginConfig.getDirectory()#.translations.templates.#exportTemplate#.export") />
		<cfset var rsFiles = "" />

		<cfset exportObject.import($,importDirectory,importFile) />
		
		<!--- cleanup --->
		<cfset rsFiles = directoryList("#expandPath("/#pluginConfig.getDirectory()#/temp")#",false,"query")>

		<cfloop query="rsFiles">
			<cftry>
				 <cfset directoryDelete("#rsFiles.directory#/#rsFiles.name#",true) />
			<cfcatch>
			</cfcatch>
			</cftry>
		</cfloop>
	</cffunction>
	
</cfcomponent>