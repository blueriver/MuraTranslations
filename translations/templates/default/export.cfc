<cfcomponent>

	<cffunction name="export" returntype="string">
		<cfargument name="$" type="any" required="true">
		<cfargument name="exportDirectory" type="string" required="true">
		<cfargument name="contentIterator" type="any" required="true">
		<cfargument name="componentIterator" type="any" required="true">
		<cfargument name="rsContentCategories" type="any" required="true">
		<cfargument name="pluginConfig" type="any" required="true">

		<cfset var exportContent = "" />
		<cfset var item = "" />
		<cfset var exportKey = rereplace(createUUID(),"-","","all") />
		<cfset var tempDir = exportKey />
		<cfset var workingDir = exportDirectory & "/#tempDir#" />

		<cfset var contentData = "" />
		<cfset var extendData = "" />
		<cfset var filename = "" />
		<cfset var changeSetBean = $.getBean('changeSetManager').read( siteID = $.event('siteID') ) />
		<cfset var changeSetIterator = "" />
		<cfset var zipTool	= createObject("component","mura.Zip") />

		<cfset directoryCreate(workingDir) />

		<cfset var hasChangesets = $.getBean('settingsManager').getSite($.event('siteID')).getValue('hasChangesets') />

		<cfif StructKeyExists(form,"changeset_existing") and len( form.changeset_existing )>
			<cfset changeSetBean = $.getBean('changeSetManager').read( changesetID = form.changeset_existing ) />
			<cfset changeSetIterator = $.getBean('changesetManager').getAssignmentsIterator( form.changeset_existing ) />
 		</cfif>

		<!---<cfdump var="#changeSetIterator.getQuery()#"><cfabort>--->

		<!--- change set --->
		<cfif not changeSetBean.getIsNew()>
			<cfloop condition="#changeSetIterator.hasNext()#">
				<cfset item = changeSetIterator.next() />

				<cfset contentData = item.getContentBean().getAllValues() />

				<cfset extendData = item.getExtendedData().getAllValues().data />
				<cfset filename = rereplace(item.getValue('filename'),"\/",".","all") />
				<cfset filename = rereplace(filename,"^\.","","all") />
				<cfif not len(filename)>
					<cfset filename = lcase(rereplace(item.getValue('title'),"[^a-zA-Z0-9]","-","all")) & "_" & contentIterator.currentIndex() />
				</cfif>

				<cfif len(filename) gte 140>
					<cfset filename = left(filename,40) & "..." & right(createUUID(),16)  & "..." & right(filename,40) />
				</cfif>

				<cfsavecontent variable="exportContent"><cfinclude template="./page.cfm"></cfsavecontent>
				<cffile action="write" file="#workingDir#/#filename#.xml" output="#exportContent#" >
			</cfloop>
		<!--- published content --->
		<cfelse>
			<cfloop condition="#contentIterator.hasNext()#">
				<cfset item = contentIterator.next() />

				<cfset contentData = item.getContentBean().getAllValues() />
				<cfset extendData = item.getExtendedData().getAllValues().data />

				<cfset filename = rereplace(item.getValue('filename'),"\/",".","all") />
				<cfif not len(filename)>
					<cfset filename = lcase(rereplace(item.getValue('title'),"[^a-zA-Z0-9]","-","all")) & "_" & contentIterator.currentIndex() />
				</cfif>

				<cfif len(filename) gte 140>
					<cfset filename = left(filename,40) & "..." & right(createUUID(),16)  & "..." & right(filename,40) />
				</cfif>

				<cfsavecontent variable="exportContent"><cfinclude template="./page.cfm"></cfsavecontent>
				<cffile action="write" file="#workingDir#/#filename#.xml" output="#exportContent#" >
			</cfloop>

			<cfloop condition="#componentIterator.hasNext()#">
				<cfset item = componentIterator.next() />

				<cfset contentData = item.getContentBean().getAllValues() />
				<cfset extendData = item.getExtendedData().getAllValues().data />

				<cfset filename = lcase(rereplace(item.getValue('htmltitle'),"[^a-zA-Z0-9]{1,}","-","all")) />
				<cfset filename = rereplace(filename,"^[^a-zA-Z]","") & "_" & componentIterator.currentIndex() />

				<cfif len(filename) gte 140>
					<cfset filename = left(filename,40) & "..." & right(createUUID(),16)  & "..." & right(filename,40) />
				</cfif>

				<cfsavecontent variable="exportContent"><cfinclude template="./component.cfm"></cfsavecontent>
				<cffile action="write" file="#workingDir#/#filename#.xml" output="#exportContent#" >
			</cfloop>



		</cfif>

		<cfif rsContentCategories.recordCount>
		<cfsavecontent variable="exportContent"><cfinclude template="./categories.cfm"></cfsavecontent>
		<cffile action="write" file="#workingDir#/categories.xml" output="#exportContent#" >
		</cfif>

		<cfset directoryCreate(workingDir & "-export") />

		<cfset zipTool.AddFiles(zipFilePath="#workingDir#-export/translations.zip",directory=workingDir,recurse="true",filter="*.xml")>

		<cftry>
			<cfset directoryDelete(workingDir,true) />
		<cfcatch>
			<cfdump var="#cfcatch#">
		</cfcatch>
		</cftry>

		<cfreturn exportKey />
	</cffunction>

	<cffunction name="import" returntype="any">
		<cfargument name="$" type="any" required="true">
		<cfargument name="importDirectory" type="string" required="true">
		<cfargument name="importFile" type="any" required="true">
		<cfargument name="pluginConfig" type="any" required="true">

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

		<cfset var translationManager = createObject('component','#arguments.pluginConfig.getDirectory()#.cfcs.translationManager').init($.globalConfig(),arguments.pluginConfig) />

		<cfset var feedIDList = "" />
		<cfset var contentIDList = "" />
		<cfset var sProcessed = StructNew() />
		<cfset var sResponse = StructNew() />
		<cfset var changeSets = StructNew() />
		<cfset var remoteChangeSetBean = "" />
		<cfset var changeSetBean = "" />
		<cfset var publishChangeSetBean = "" />
		<cfset var useChangeSets = 0 />
		<cfset var hasChangesets = $.getBean('settingsManager').getSite($.event('siteID')).getValue('hasChangesets') />
		<cfset var enforceChangesets = $.getBean('settingsManager').getSite($.event('siteID')).getValue('enforceChangesets') />
		<cfset var success = true />

		<cfset var rsFixComponentAssignments = "" />

		<cfset var x = "" />

		<cfif not structKeyExists(request,"xcount")>
			<cfset request.xcount = StructNew() />
			<cfset request.xcount['ts'] = getTickCount() />
			<cfset request.xcount['xmlloop'] = StructNew() />
		</cfif>

		<cfif fileExists("#importDirectory#/../report.txt")>
			<cftry>
				<cffile action="delete" file="#importDirectory#/../report.txt" >
			<cfcatch>
				<cffile action="write" file="#importDirectory#/../report.txt" output="">
			</cfcatch>
			</cftry>
		</cfif>

		<cfset request.xcount['vars'] = getTickCount() - request.xcount['ts'] />

		<cfparam name="form.staging_type" default="">

		<cfset zipTool.Extract(zipFilePath="#importDirectory#/#importFile#",extractPath="#importDirectory#",overwriteFiles=true)>

		<!--- duplicate and create mappings --->
		<cfset rsFiles = directoryList("#importDirectory#",true,"query","*.xml")>

		<cfif form['staging_type'] eq "existing">
			<cfset publishChangeSetBean = $.getBean('changeSetManager').read( changesetID = form.changeset_existing ) />
			<cfset var useChangeSets = 1 />
		<cfelseif form['staging_type'] eq "export">
			<cfset publishChangeSetBean = $.getBean('changeSetManager').read( remoteID = form.changeset_new ) />

			<cfif publishChangeSetBean.getIsNew()>
				<cfset publishChangeSetBean = $.getBean('changeSetManager').read( changesetID = form.changeset_new ) />
				<cfset publishChangeSetBean.setValue( 'remoteID',publishChangeSetBean.getchangesetID() ) />
				<cfset publishChangeSetBean.setValue( 'changesetID',createUUID() ) />
				<cfset publishChangeSetBean.setValue( 'isNew',1 ) />
				<cfset publishChangeSetBean.setValue('published',0) />
				<cfset publishChangeSetBean.setValue('siteID',$.event('siteID')) />
				<cfset publishChangeSetBean.save() />
			</cfif>

			<cfset var useChangeSets = 1 />
		<cfelseif form['staging_type'] eq "new">
			<cfset publishChangeSetBean = $.getBean('changeSetManager').read( siteID = $.event('siteID') ) />
			<cfset publishChangeSetBean.setValue('name',form.changeset_default) />
			<cfset publishChangeSetBean.save() />
			<cfset var useChangeSets = 1 />
		</cfif>

		<cfset request.xcount['read'] = getTickCount() - request.xcount['ts'] />

		<cfloop query="rsFiles">
			<cfset success = true />
			<cfset contentXML = fileRead(rsFiles.directory & "/" & rsFiles.name) />

			<cftry>
				<cfset xmlContent = xmlParse(contentXML) />
				<cfcatch>
					<cfset success = false />
					<cfif not fileExists("#importDirectory#/../report.txt")>
						<cffile action="append" file="#importDirectory#/../report.txt" output="Export report #dateFormat(now(),"dd/mm/yyyy hh:mm:ss")#" addnewline="true">
					</cfif>

					<cffile action="append" file="#importDirectory#/../report.txt" output="#chr(10)##chr(13)#FAILED [XML PARSE]: #rsFiles.name# (#cfcatch.detail#)" addnewline="true">
				</cfcatch>
			</cftry>

			<cfif rsFiles.name neq "categories.xml" and success>

				<cftry>

					<cfif not len(siteID)>
						<cfset siteID = xmlContent.xmlRoot.xmlAttributes.siteID />
					</cfif>

					<!--- woops, you are importing from the original! --->
					<cfif siteID eq $.event('siteID')>
						<cfreturn "The current SiteID (#siteID#) cannot import its own source as a translation. You must create a new site within this Mura CMS instance and import the translation there." />
					</cfif>

					<cfset contentID = xmlContent.xmlRoot.xmlAttributes.ID />
					<cfset sourceSiteID = xmlContent.xmlRoot.xmlAttributes.siteID />

					<cfelseif form['staging_type'] eq "publish">
						<cfset sResponse = $.getBean('contentUtility').duplicateExternalContent(contentID,$.event('siteID'),sourceSiteID,false,siteSynced,'','',1) />
					<cfelse>
						<cfset sResponse = $.getBean('contentUtility').duplicateExternalContent(contentID,$.event('siteID'),sourceSiteID,false,siteSynced,'','',0) />
					</cfif>

					<cfif sResponse.success>
						<cfif structKeyExists(sResponse, "feedIDlist") and len(sResponse.feedIDList)>
							<cfset feedIDList = listAppend(feedIDList,sResponse.feedIDList) />
						</cfif>
						<cfif structKeyExists(sResponse, "contentIDList") and len(sResponse.contentIDList)>
							<cfset contentIDList = listAppend(contentIDList,sResponse.contentIDList) />
						</cfif>
					</cfif>

					<cfif contentID neq "00000000000000000000000000000000001">
						<cfset siteSynced = true />
						<cfset contentBean = $.getBean('content').loadBy(remoteID=contentID,siteID=$.event('siteID')) />
					<cfelse>
						<cfset contentBean = $.getBean('content').loadBy(contentID="00000000000000000000000000000000001",siteID=$.event('siteID')) />
					</cfif>

					<cfif not contentBean.getIsNew()>
						<cfset contentBean.getAllValues() />

						<cfset contentBean.setTitle( xmlContent.xmlRoot["title"].xmlCData ) />
						<cfset contentBean.setMenuTitle("") />
						<cfset contentBean.setURLTitle("") />
						<cfset contentBean.setHTMLTitle("") />

						<cfif structKeyExists(xmlContent.xmlRoot,"summary")>
							<cfset contentBean.setSummary( xmlContent.xmlRoot["summary"].xmlText ) />
						</cfif>
						<cfif structKeyExists(xmlContent.xmlRoot,"body")>
							<cfset contentBean.setBody( xmlContent.xmlRoot["body"].xmlText ) />
						</cfif>
						<cfloop from="1" to="#$.getBean('settingsManager').getSite($.event('siteID')).getcolumncount()#" index="x">
							<cfset contentBean.getdisplayRegion(x) />
						</cfloop>

						<cfif useChangeSets>
							<cfset contentBean.setChangesetID( publishChangeSetBean.getChangesetID() ) />
						<cfelseif form['staging_type'] eq "publish">
							<cfset contentBean.setIsActive(1) />
						<cfelse>
							<cfset contentBean.setIsActive(0) />
						</cfif>

						<cfset contentBean.save() />

						<cfset translation=translationManager.getTranslation()>
						<cfset translation.setLocalSiteID($.event('siteID'))>
						<cfset translation.setLocalID(contentBean.getContentID())>
						<cfset translation.setRemoteSiteID(sourceSiteID)>
						<cfset translation.setRemoteID(contentID)>
						<cfset translation.save()>
					</cfif>

					<cfset request.xcount['xmlloop'][rsFiles.name] = getTickCount() - request.xcount['ts'] />

					<cfcatch>
						<cfif not fileExists("#importDirectory#/report.txt")>
							<cffile action="append" file="#importDirectory#/../report.txt" output="Export report #dateFormat(now(),"dd/mm/yyyy hh:mm:ss")##chr(10)##chr(13)#" addnewline="true">
						</cfif>
						<cffile action="append" file="#importDirectory#/../report.txt" output="#chr(10)##chr(13)#FAILED [PROCESSING]: #rsFiles.name# (#cfcatch.detail#)" addnewline="true">
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>

		<cfset request.xcount['xml'] = getTickCount() - request.xcount['ts'] />

		<!--- duplicate feeds --->
		<cfif len(feedIDList)>
			<cfloop list="#feedIDList#" index="x">
				<cfif not structKeyExists(sProcessed,x)>
					<cfset $.getBean('contentUtility').duplicateExternalFeed(x,$.event('siteID'),sourceSiteID)>
					<cfset sProcessed[x] = true />
				</cfif>
			</cfloop>
		</cfif>

		<cfset request.xcount['feed'] = getTickCount() - request.xcount['ts'] />


		<!--- update related content --->
		<cfif len(contentIDList)>
			<cfloop list="#contentIDList#" index="x">
				<cfif not structKeyExists(sProcessed,x)>
					<cfset $.getBean('contentUtility').updateRelatedContent(x,$.event('siteID'),sourceSiteID)>
					<cfset sProcessed[x] = true />
				</cfif>
			</cfloop>
		</cfif>

		<cfset request.xcount['related'] = getTickCount() - request.xcount['ts'] />

		<cfset $.getBean('contentUtility').duplicateExternalSortOrder( $.event('siteID'),siteID	 ) />

		<cfset request.xcount['dupextsortorder'] = getTickCount() - request.xcount['ts'] />

		<cftry>
			<cfif application.configBean.getDBtype() eq "mssql">
				<cfquery name="rsFixComponentAssignments">
					UPDATE tcontentobjects
					SET
						tcontentobjects.objectID = tcontent.contentID
					FROM tcontentobjects,tcontent
					WHERE
						tcontent.remoteID = tcontentobjects.objectid
					AND
						tcontent.active = 1
					AND
						tcontentobjects.siteID = <cfqueryparam value="#$.event('siteID')#" cfsqltype="cf_sql_varchar" maxlength="40">
				</cfquery>
			<cfelse>
				<cfquery name="rsFixComponentAssignments">
					UPDATE tcontentobjects,tcontent
					SET
						tcontentobjects.objectID = tcontent.contentID
					WHERE
						tcontent.remoteID = tcontentobjects.objectid
					AND
						tcontent.active = 1
					AND
						tcontentobjects.siteID = <cfqueryparam value="#$.event('siteID')#" cfsqltype="cf_sql_varchar" maxlength="40">
				</cfquery>
			</cfif>
		<cfcatch>
		</cfcatch>
		</cftry>

		<cfif fileExists(importdirectory & "/categories.xml")>
			<cfset contentXML = fileRead(importDirectory & "/categories.xml") />

			<cftry>
				<cfset xmlContent = xmlParse(contentXML) />
				<cfcatch type="any">
					<cfdump var="#contentXML#">
					<cfabort showerror="true">
				</cfcatch>
			</cftry>

			<cfset siteID = xmlContent.xmlRoot.xmlAttributes.siteID />
			<cfloop index="x" from="1" to="#ArrayLen(xmlContent.categories.XmlChildren)#">
				<cfset xmlItem = xmlContent.categories.XmlChildren[ x ] />
				<cfset categoryID = xmlItem.xmlAttributes.ID />
				<cfset categoryBean = $.getBean('categoryBean').loadBy(remoteID=categoryID,siteID=$.event('siteID')) />
				<!--- make sure we are not creating new categories that have been since deleted --->
				<cfif not categoryBean.getIsNew()>
					<cfset categoryBean.setName(xmlItem.xmlText)>
					<cfset categoryBean.setRemoteID(categoryID)>
					<cfset categoryBean.save()>
				</cfif>
			</cfloop>
		</cfif>

		<cfset request.xcount['cat'] = getTickCount() - request.xcount['ts'] />
		<cfreturn true />
	</cffunction>


</cfcomponent>
