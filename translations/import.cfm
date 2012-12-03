<cfdirectory action="list" directory="#expandPath("/#pluginConfig.getDirectory()#")#/translations/templates" name="rsTemplates" type="dir">
<cfoutput>


	<h2>Import Site</h2>
	<form class="fieldset-wrap" action="./index.cfm" method="post" onsubmit="return validateForm(this);" enctype="multipart/form-data">
	<input type="hidden" name="export_action" value="import">
	<div class="fieldset">
		<div class="control-group">
			<div class="span6">
				<label class="control-label">
					Zip File
				</label>
				<div class="controls">
				  <input class="text" type="file" name="import_file">
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
			<input type="submit" value="Import" class="btn"/>
			<input type="hidden" name="doaction" value="doimport"/>
		</div>

	</form>
</cfoutput>