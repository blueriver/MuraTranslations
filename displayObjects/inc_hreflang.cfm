<cfsilent>
    <cfset hrefLangArray = [] />
    <cfset theUrl = event.getvalue('murascope').createHREF( siteid=event.getValue('siteid'),filename=event.getValue('contentBean').getValue('filename'),contentid=event.getValue('contentBean').getValue('contentid'), complete=true) />
    <cfset hrefLang = translationManager.getHrefLang(application.settingsManager.getSite(event.getValue('siteid'))) />
    <cfset arrayAppend(hrefLangArray, '<link rel="alternate" hreflang="#hrefLang#" href="#theURL#" />') />

    <cfloop query="rslocales">
        <cfset theURL = translationManager.lookUpTranslation(event.getValue('crumbdata'),rsLocales.siteid,event.getContentRenderer(),true,true)/>
        <cfset hrefLang = translationManager.getHrefLang(application.settingsManager.getSite(rsLocales.siteid)) />
        <cfif find("://",theUrl)>
            <cfset arrayAppend(hrefLangArray, '<link rel="alternate" hreflang="#hrefLang#" href="#theURL#" />') />
        </cfif>
    </cfloop>
</cfsilent>
<cfoutput><cfloop array="#hrefLangArray#" index="hrefLangTag">
#hrefLangTag#</cfloop></cfoutput>