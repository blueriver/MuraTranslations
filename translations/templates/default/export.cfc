<cfcomponent>

	<cffunction name="export" returntype="string">
		<cfargument name="$">
		<cfargument name="exportDirectory">
		<cfargument name="contentIterator">
		<cfargument name="componentIterator">
		<cfargument name="rsContentCategories">
				
		<cfset var exportContent = "" />
		<cfset var item = "" />
		<cfset var exportKey = rereplace(createUUID(),"-","","all") />
		<cfset var tempDir = exportKey />
		<cfset var workingDir = exportDirectory & "/#tempDir#" />

		<cfset var contentData = "" />
		<cfset var extendData = "" />
		<cfset var filename = "" />
		<cfset var zipTool	= createObject("component","mura.Zip") />

		<cfset directoryCreate(workingDir) />

		<cfloop condition="#contentIterator.hasNext()#">
			<cfset item = contentIterator.next() />
			<cfset contentData = item.getAllValues() />
			<cfset extendData = item.getExtendedData().getAllValues().data />
			<cfset filename = rereplace(contentData.filename,"\/",".","all") />
			<cfif not len(filename)>
				<cfset filename = lcase(rereplace(contentData.title,"[^a-zA-Z0-9]","-","all")) & "_" & contentIterator.currentIndex() />
			</cfif>
			<cfsavecontent variable="exportContent"><cfinclude template="./page.cfm"></cfsavecontent>
			<cffile action="write" file="#workingDir#/#filename#.xml" output="#exportContent#" >
		</cfloop>
		
		<cfloop condition="#componentIterator.hasNext()#">
			<cfset item = componentIterator.next() />
			<cfset contentData = item.getAllValues() />
			<cfset extendData = item.getExtendedData().getAllValues().data />

			<cfset filename = lcase(rereplace(contentData.htmltitle,"[^a-zA-Z0-9]{1,}","-","all")) />
			<cfset filename = rereplace(filename,"^[^a-zA-Z]","") & "_" & contentIterator.currentIndex() />

			<cfsavecontent variable="exportContent"><cfinclude template="./component.cfm"></cfsavecontent>
			<cffile action="write" file="#workingDir#/#filename#.xml" output="#exportContent#" >
		</cfloop>

		<cfif rsContentCategories.recordCount>
		<cfsavecontent variable="exportContent"><cfinclude template="./categories.cfm"></cfsavecontent>
		<cffile action="write" file="#workingDir#/categories.xml" output="#exportContent#" >
		</cfif>
		
		<cfset zipTool.AddFiles(zipFilePath="#workingDir#/translations.zip",directory=workingDir,recurse="true")>
		
		<cfreturn exportKey />
	</cffunction>
	
	<cffunction name="import" returntype="void">
		<cfargument name="$">
		<cfargument name="importDirectory">
		<cfargument name="importFile">

		<cfset var keyFactory = "" />
		<cfset var zipTool	= createObject("component","mura.Zip") />
		<cfset var siteID = "" />
		<cfset var sourceSiteID = "" />
		<cfset var contentID = "" />
		<cfset var contentBean = "" />
		
		<cfset var xmlFile = "" />
		<cfset var xmlContent = "" />
		<cfset var rsFiles = "" />
		<cfset var siteSynced = false />
		<cfset var translation = "" />
		
		<cfset var translationManager = createObject('component','LocaleTransMgr.cfcs.translationManager').init($.globalConfig(),$.getPlugin('LocaleTransMgr')) />
		
		<cfset zipTool.Extract(zipFilePath="#importDirectory#/#importFile#",extractPath="#importDirectory#",overwriteFiles=true)>

		<!--- duplicate and create mappings --->
		<cfset rsFiles = directoryList("#importDirectory#",true,"query","*.xml")>

		<cfloop query="rsFiles">
			<cfset contentXML = fileRead(rsFiles.directory & "/" & rsFiles.name) />

			<cfset xmlContent = xmlParse(contentXML) />

			<cfif rsFiles.name neq "categories.xml">
				<cftry>
	
					<cfif not len(siteID)>
						<cfset siteID = xmlContent.xmlRoot.xmlAttributes.siteID />
					</cfif>
					
					<cfset contentID = xmlContent.xmlRoot.xmlAttributes.ID />
					<cfset sourceSiteID = xmlContent.xmlRoot.xmlAttributes.siteID />
					<cfset $.getBean('contentUtility').duplicateExternalContent(contentID,$.event('siteID'),sourceSiteID,false,siteSynced) />

					<cfif contentID neq "00000000000000000000000000000000001">
						<cfset siteSynced = true />
						<cfset contentBean = $.getBean('content').loadBy(remoteID=contentID,siteID=$.event('siteID')) />
					<cfelse>
						<cfset contentBean = $.getBean('content').loadBy(contentID="00000000000000000000000000000000001",siteID=$.event('siteID')) />
					</cfif>

					<cfset contentBean.getAllValues() />

					<cfset contentBean.setTitle( xmlContent.xmlRoot["title"].xmlCData ) />
					
					<cfif structKeyExists(xmlContent.xmlRoot,"summary")>
						<cfset contentBean.setSummary( xmlContent.xmlRoot["summary"].xmlText ) />
					</cfif>
					<cfif structKeyExists(xmlContent.xmlRoot,"body")>
						<cfset contentBean.setBody( xmlContent.xmlRoot["body"].xmlText ) />
					</cfif>
					<cfloop from="1" to="#$.getBean('settingsManager').getSite($.event('siteID')).getcolumncount()#" index="x">
						<cfset contentBean.getdisplayRegion(x) />
					</cfloop>
						<!---<cfdump var="#contentBean.getAllValues()#">--->
					<cfset contentBean.save() />
<!---					
					<cfset translation=translationManager.getTranslation()>
					<cfset translation.setLocalSiteID($.event('siteID'))>
					<cfset translation.setLocalID(contentBean.getContentID())>
					<cfset translation.setRemoteSiteID(sourceSiteID)>
					<cfset translation.setRemoteID(contentID)>
					<cfset translation.save()>
						
--->	
					<cfcatch>
						<cfoutput>#rsFiles.name#:<cfdump var="#cfcatch#"><hr></cfoutput>
					</cfcatch>
				</cftry>
			</cfif>		
		</cfloop>

		<cfif fileExists(importdirectory & "/categories.xml")>
			<cfset contentXML = fileRead(importDirectory & "/categories.xml") />
			<cfset xmlContent = xmlParse(contentXML) />
			<cfset siteID = xmlContent.xmlRoot.xmlAttributes.siteID />
		
			<cfloop index="x" from="1" to="#ArrayLen(xmlContent.categories.XmlChildren)#">
								
				<cfset xmlItem = xmlContent.categories.XmlChildren[ x ] />
				
				<cfset categoryID = xmlItem.xmlAttributes.ID />
				<cfset categoryBean = $.getBean('categoryBean').loadBy(remoteID=categoryID,siteID=$.event('siteID')) />
				<!--- make sure we are not creating new categories that have been since deleted --->
				<cfif not categoryBean.getIsNew()>
					<cfset categoryBean.setName(xmlItem.xmlText)>
					<cfset categoryBean.save() />
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn />
	</cffunction>


</cfcomponent>