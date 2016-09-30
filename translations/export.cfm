<cfdirectory action="list" directory="#expandPath("/#pluginConfig.getDirectory()#")#/translations/templates" name="rsTemplates" type="dir">
<cfset latestExportDate = exportTranslation.getLatestExportDate($,pluginConfig) />
<!--- haspendingapprovals --->
<cfsilent>
	<cfset hasChangesets = $.getBean('settingsManager').getSite($.event('siteID')).getValue('hasChangesets') />
	<cfset enforceChangesets = $.getBean('settingsManager').getSite($.event('siteID')).getValue('enforceChangesets') />
	<cfset rsChangeSets = $.getBean("changesetManager").getQuery( siteID=$.event('siteID'),published=0 ) />
</cfsilent>

<cfif isDate(latestExportDate)>
	<cfset showDate = dateFormat(latestExportDate,"mm/dd/yyyy" ) />
<cfelse>
	<cfset showDate = "" />
</cfif>

<cfoutput>
	<h2>Export Site(Beta)</h2>
	<form class="fieldset-wrap" action="./index.cfm" method="post" onsubmit="return validateForm(this);">
	<input type="hidden" name="export_action" value="export">
	<div class="fieldset">
		<div class="control-group">
			<div class="span6">
				<label class="control-label">
					From Date
				</label>
				<div class="controls">
				   <input class="datepicker" type="text" name="export_date" value="#showDate#">
				   (leave blank for all content)
				</div>
			</div>
		</div>
		<div class="control-group">
			<div class="span6">
				<label class="control-label">
					Template
				</label>
				<div class="controls">
				  <select name="template">
					<cfloop query="rsTemplates">
						<option>#rsTemplates.name#</option>
					</cfloop>		
				</select>
				</div>
			</div>
		</div>
		<div class="control-group sc-group" id="changeset_existing_section">
			<div class="span6">
				<label class="control-label">
					Export
				</label>
				<div class="controls">
				 <select name="changeset_existing">
					<option value="">Published Content</option>
					<optgroup label="Change Sets">
					<cfloop query="rsChangeSets">
						<cfset loopCS = $.getBean('changeSetManager').read( changesetID = changesetID ) />
						
						<cfif not StructKeyExists(loopCS,"hasPendingApprovals")
							or
							(
							not loopCS.hasPendingApprovals()
							and (
								not
									isDate(loopCS.getCloseDate())
								or ( isDate(loopCS.getCloseDate()) and loopCS.getCloseDate() lt now()	)
								)
							)>	
							<option value="#changesetID#">#name#</option>
						</cfif>
					</cfloop>
					</optgroup>
				</select>
				</div>
			</div>
		</div>
	</div>
	<div class="form-actions">
		<a href="../" class="btn">Cancel</a>
		<input type="submit" value="Create" class="btn"/>
		<input type="hidden" name="doaction" value="export"/>
	</div>
	</form>
</cfoutput>