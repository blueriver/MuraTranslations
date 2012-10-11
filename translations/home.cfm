<cfoutput>
	<form action="translations/index.cfm" method="post" onsubmit="return validateForm(this);">
	<h3>Action</h3>
	<table class="stripe">
	<tr>
	<td><input type="radio" name="export_action" value="export" checked="checked"></td>
	<td>Export</td>
	</tr>
	<tr>
	<td><input type="radio" name="export_action" value="import"></td>
	<td>Import</td>
	</tr>
	</table>
	<input type="submit" value="Next"/>
	<input type="hidden" name="doaction" value="update"/>
	</form>
</cfoutput>