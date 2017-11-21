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
	this.pluginPath=getDirectoryFromPath(getCurrentTemplatePath());
	this.depth = ListFind(this.pluginPath, 'plugins', '\/');
	this.webRoot = RepeatString('../', this.depth);
	this.appSettingsFile = this.webRoot & 'config/applicationSettings.cfm';

	try {
		include this.appSettingsFile;
	} catch(MissingInclude e) {
		include this.webRoot & 'core/appcfc/applicationSettings.cfm';
	}

	try {
		include this.webRoot & 'config/mappings.cfm';
		include this.webRoot & 'plugins/mappings.cfm';
	} catch(any e) {}
}
