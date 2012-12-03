<cfoutput>
	<form class="fieldset-wrap" action="translations/index.cfm" method="post" onsubmit="return validateForm(this);">
	<div class="fieldset">
		<div class="control-group">
			<div class="span6">
				<label class="control-label">Action</label>
				<div class="controls">
				  	<label for="isActionExport" class="radio inline">
				     <input type="radio" name="export_action" value="export" checked="checked" id="isActionExport">
				     Export
				    </label>
				    <label for="isActionImport" class="radio inline"> 
				     <input type="radio" name="export_action" value="import" checked="checked" id="isActionImport">
				     Import
				    </label>
				</div>
			</div>
		</div>
	</div>
	<div class="form-actions">
		<input type="submit" value="Next" class="btn"/>
		<input type="hidden" value="#rsSites.recordcount#" name="siteCount"/>
		<input type="hidden" name="doaction" value="update"/>
	</div>
	</form>
</cfoutput>