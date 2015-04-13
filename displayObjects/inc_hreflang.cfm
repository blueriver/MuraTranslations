<cfoutput>
<cfsilent>
    <cfset hrefLang = translationManager.getHrefLang(application.settingsManager.getSite(event.getValue('siteid'))) />
    <cfif cgi.https eq "on">
        <cfset protocol = "https" />
    <cfelse>
        <cfset protocol = "http" />
    </cfif>
    <cfset theUrl = protocol & "://" & cgi.http_host & application.configBean.getContext() & "/" & event.getValue('siteid') & "/" & event.getValue('contentBean').getValue('filename') />
</cfsilent>
<link rel="alternate" hreflang="#hrefLang#" href="#theURL#" />
<cfloop query="rslocales"><cfsilent>
	<cfset theURL = application.configBean.getContext() & translationManager.lookUpTranslation(event.getValue('crumbdata'),rsLocales.siteid,event.getContentRenderer(),true,true)/>
	<cfset hrefLang = translationManager.getHrefLang(application.settingsManager.getSite(rsLocales.siteid)) />
</cfsilent><cfif find("://",theUrl)><link rel="alternate" hreflang="#hrefLang#" href="#theURL#" /></cfif>
</cfloop>
</cfoutput>