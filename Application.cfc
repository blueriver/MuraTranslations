/*
   Copyright 2011-2017 Blue River Interactive

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
component {

	this.pluginPath = GetDirectoryFromPath(GetCurrentTemplatePath());
	this.muraroot = Left(this.pluginPath, Find('plugins', this.pluginPath) - 1);
	this.depth = ListLen(RemoveChars(this.pluginPath,1, Len(this.muraroot)), '\/');  
	this.includeroot = RepeatString('../', this.depth);

	if ( DirectoryExists(this.muraroot & 'core') ) {
		// Using 7.1
		this.muraAppConfigPath = this.includeroot & 'core/';
		include this.muraAppConfigPath & 'appcfc/applicationSettings.cfm';
	} else {
		// Pre 7.1
		this.muraAppConfigPath = this.includeroot & 'config';
		include this.includeroot & 'config/applicationSettings.cfm';

		try {
			include this.includeroot & 'config/mappings.cfm';
			include this.includeroot & 'plugins/mappings.cfm';
		} catch(any e) {}
	}

}
