<cfdirectory action="list" directory="#expandPath("/#pluginConfig.getDirectory()#")#/translations/templates" name="rsTemplates" type="dir">
<cfset latestExportDate = exportTranslation.getLatestExportDate($) />

<cfif isDate(latestExportDate)>
	<cfset showDate = dateFormat(latestExportDate,"mm/dd/yyyy" ) />
<cfelse>
	<cfset showDate = "" />
</cfif>

<cfoutput>
	<form action="./index.cfm" method="post" onsubmit="return validateForm(this);">
	<input type="hidden" name="export_action" value="export">
	<h3>Export Site</h3>
	<table class="stripe">
	<tr>
	<td>From Date</td>
	<td><input type="text" name="export_date" value="#showDate#"></td>
		<td colspan=2>(leave blank for all content)</td>
	</tr>
	<td>Template</td>
	<td><select name="template">
			<cfloop query="rsTemplates">
				<option>#rsTemplates.name#</option>
			</cfloop>		
		</select>
	</td>
	</tr>
	</table>
	<input type="submit" value="Create"/>
	<input type="hidden" name="doaction" value="export"/>
	</form>
</cfoutput>