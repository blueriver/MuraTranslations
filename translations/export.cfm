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
	<h2>Export Translations (Beta)</h2>
	<form action="./index.cfm" method="post" onsubmit="return validateForm(this);">
	<input type="hidden" name="export_action" value="export">
		<div class="mura-control-group">
				<label>
					Start Date
				</label>
				   <input class="datepicker" type="text" name="export_date" value="#showDate#">
				   <div class="help-block">Export only content created since a specific date (leave blank for all content)</div>
		</div>
		<div class="mura-control-group">
				<label>
					Template
				</label>
				  <select name="template">
					<cfloop query="rsTemplates">
						<option>#rsTemplates.name#</option>
					</cfloop>		
				</select>
		</div>
		<div class="mura-control-group sc-group" id="changeset_existing_section">
				<label>
					Export
				</label>
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
	<div class="mura-actions">
		<div class="form-actions">
			<button class="btn" onclick="window.location.href='../index.cfm##tabTranslate'; return false;"><i class="mi-ban"></i> Cancel</button>
			<button type="submit" class="btn mura-primary"><i class="mi-sign-out"></i> Export</button>
			<input type="hidden" name="doaction" value="export"/>
		</div>
	</div>
	</form>
</cfoutput>