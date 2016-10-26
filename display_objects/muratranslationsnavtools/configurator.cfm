<cfscript>
/**
*
* This file is part of Mura Translations
*
* Copyright 2011-2016 Blue River Interactive
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/
  param name="objectparams.muratranslationstooltype" default="list";
</cfscript>
<cfoutput>
  <div class="mura-control-group">
  		<label class="mura-control-label" for="muratranslationstooltype">Tool Type</label>
  		<label class="radio inline">
  			<input type="radio" class="objectParam" name="muratranslationstooltype" value="list" <cfif objectparams.muratranslationstooltype eq 'list'> checked="checked"</cfif> />
  			List
  		</label>
  		<label class="radio inline">
  			<input type="radio" class="objectParam" name="muratranslationstooltype" value="selectbox" <cfif objectparams.muratranslationstooltype eq 'selectbox'> checked="checked"</cfif> />
  			SelectBox
  		</label>
  	</div>
</cfoutput>
