<cfdirectory action="list" directory="#expandPath("/#pluginConfig.getDirectory()#")#/translations/templates" name="rsTemplates" type="dir">


<cfoutput>
	<form action="./index.cfm" method="post" onsubmit="return validateForm(this);" enctype="multipart/form-data">
	<input type="hidden" name="export_action" value="import">
	<h3>Import</h3>
	<table class="stripe">
	<tr>
	<td>Zip File</td>
	<td><input type="file" name="import_file"></td>
	</tr>
	<tr>
	<td>Template</td>
	<td><select name="template">
			<cfloop query="rsTemplates">
				<option>#rsTemplates.name#</option>
			</cfloop>		
		</select>
	</td>
	</tr>
	</table>
	<input type="submit" value="Import"/>
	<input type="hidden" name="doaction" value="doimport"/>
	</form>
</cfoutput>