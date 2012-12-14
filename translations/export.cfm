<cfdirectory action="list" directory="#expandPath("/#pluginConfig.getDirectory()#")#/translations/templates" name="rsTemplates" type="dir">
<cfset latestExportDate = exportTranslation.getLatestExportDate($,pluginConfig) />

<cfif isDate(latestExportDate)>
	<cfset showDate = dateFormat(latestExportDate,"mm/dd/yyyy" ) />
<cfelse>
	<cfset showDate = "" />
</cfif>

<cfoutput>
	<h2>Export Site</h2>
	<form class="fieldset-wrap" action="./index.cfm" method="post" onsubmit="return validateForm(this);">
	<input type="hidden" name="export_action" value="export">
	<div class="fieldset">
		<div class="control-group">
			<div class="span6">
				<label class="control-label">
					From Date
				</label>
				<div class="controls">
				   <input class="text" type="text" name="export_date" value="#showDate#">
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
	</div>
	<div class="form-actions">
		<a href="../" class="btn">Cancel</a>
		<input type="submit" value="Create" class="btn"/>
		<input type="hidden" name="doaction" value="export"/>
	</div>
	</form>
</cfoutput>