<cfcomponent>

	<cffunction name="createExport" returntype="string">
		<cfargument name="$" type="any" required="true" />
		<cfargument name="sinceDate" type="date" required="false" />
		<cfargument name="template" required="false" type="string" default="default">
		<cfargument name="pluginConfig" required="true" type="any">
		
		<cfset var exportObject = "" />
		<cfset var exportDirectory = expandPath("/#arguments.pluginConfig.getDirectory()#/exports") />

		<cfset var contentFeed = "" />
		<cfset var contentIterator = "" />
		<cfset var componentFeed = "" />
		<cfset var componentIterator = "" />

		<cfset var rsComponents = "" />
		<cfset var rsContentCategories = "" />
		
		<cfset var exportKey = "" />
		<cfset var rsUpdateExport = "" />

		<cfset var exportTemplate = rereplaceNoCase(arguments.template,"[^a-z]","","all") />
		<cfset var exportObject = createObject("component","#arguments.pluginConfig.getDirectory()#.translations.templates.#exportTemplate#.export") />

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

		<cfset exportKey = exportObject.export($,exportDirectory,contentIterator,componentIterator,rsContentCategories,arguments.pluginConfig) />

		<cfquery name="rsUpdateExport" datasource="#$.globalConfig().getDatasource()#" username="#$.globalConfig().getDBUsername()#" password="#$.globalConfig().getDBPassword()#">
			insert into p#arguments.pluginConfig.getPluginID()#_translationexports
			(siteID,exportdate,exportKey)
			VALUES
			('#$.event().getValue('siteID')#',#CreateODBCDateTime(now())#,'#exportKey#')
		</cfquery>
		
		<cfreturn exportKey />
	</cffunction>

	<cffunction name="getLatestExportDate" returntype="string">
		<cfargument name="$" type="any" required="true" />
		<cfargument name="pluginConfig" required="true" type="any">

		<cfset var rsExport = "" />

		<cfquery name="rsExport" datasource="#$.globalConfig().getDatasource()#" username="#$.globalConfig().getDBUsername()#" password="#$.globalConfig().getDBPassword()#">
			select max(exportdate) AS maxdate from p#arguments.pluginConfig.getPluginID()#_translationexports
			where siteID = '#$.event().getValue('siteID')#'
		</cfquery>

		<cfif rsExport.recordCount>
			<cfreturn rsExport.maxdate>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>

	<cffunction name="importTranslation" returntype="any">
		<cfargument name="$" type="any" required="true" />
		<cfargument name="template" required="false" type="string" default="default">
		<cfargument name="importDirectory" required="true" type="string">
		<cfargument name="importFile" required="true" type="string">
		<cfargument name="pluginConfig" required="true" type="any">

		<cfset var keyFactory = "" />
		<cfset var exportTemplate = rereplaceNoCase(arguments.template,"[^a-z]","","all") />
		<cfset var exportObject = createObject("component","#arguments.pluginConfig.getDirectory()#.translations.templates.#exportTemplate#.export") />
		<cfset var rsFiles = "" />
		<cfset var responseMessage = "" />

		<cfif not structKeyExists(request,"xcount")>
			<cfset request.xcount = StructNew() />
			<cfset request.xcount['ts'] = getTickCount() />
			<cfset request.xcount['xmlloop'] = StructNew() />
		</cfif>

		<cfset request.xcount['pre'] = getTickCount() - request.xcount['ts'] />

		<cfset responseMessage = exportObject.import($,importDirectory,importFile,arguments.pluginConfig) />
		
		<!--- cleanup --->
		<cfset rsFiles = directoryList("#expandPath("/#arguments.pluginConfig.getDirectory()#/temp")#",false,"query")>

		<cfloop query="rsFiles">
			<cftry>
				 <cfset directoryDelete("#rsFiles.directory#/#rsFiles.name#",true) />
			<cfcatch>
			</cfcatch>
			</cftry>
		</cfloop>

		<cfset request.xcount['clean'] = getTickCount() - request.xcount['ts'] />
		
		<cfdump var="#request.xcount#"><cfabort>
		
		<cfreturn responseMessage />
	</cffunction>
	
</cfcomponent>