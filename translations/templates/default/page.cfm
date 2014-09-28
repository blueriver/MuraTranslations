<cfoutput><page id="#contentData.contentID#" siteID="#contentData.siteID#">
<title><![CDATA[
#contentData.title#]]>
</title><cfif contentData.htmltitle neq contentData.title>
<htmltitle><![CDATA[
#contentData.htmltitle#]]>
</htmltitle></cfif><cfif contentData.menutitle neq contentData.title>
<menutitle><![CDATA[
#contentData.menutitle#]]>
</menutitle></cfif><cfif len(contentData.summary)>
<summary><![CDATA[
#contentData.summary#]]>
</summary></cfif><cfif len(contentData.body)>
<body><![CDATA[
#contentData.body#]]>
</body></cfif><cfif len(contentData.metakeywords)>
<metakeywords><![CDATA[
#contentData.metakeywords#]]>
</metakeywords></cfif><cfif len(contentData.metadesc)>
<metadesc><![CDATA[
#contentData.metadesc#]]>
</metadesc></cfif><cfif len(contentData.credits)>
<credits>
#contentData.credits#
</credits></cfif><cfif len(contentData.audience)>
<audience>
#contentData.audience#
</audience></cfif><cfif len(contentData.notes)>
<notes><![CDATA[
#contentData.notes#]]>
</notes></cfif><cfif len(contentData.responsemessage)>
<responsemessage><![CDATA[
#contentData.responsemessage#]]>
</responsemessage></cfif><cfif len(contentData.tags)>
<tags>
#contentData.tags#
</tags></cfif><cfif extendData.recordcount>
<extended><cfloop query="extendData"><cfif len(extendData.attributevalue)>
	<#extendData.name#><![CDATA[#extendData.attributevalue#]]></#extendData.name#></cfif></cfloop>
</extended></cfif>
</page></cfoutput>