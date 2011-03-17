<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: OpenID ObjectAdmin Cell --->
<cftry>
<cfset stLocal.stUser = application.fapi.getContentObject(objectid=application.factory.oUtils.listSlice(stObj.username,1,-2,"_"),typename="rpxUser") />

<cfif structkeyexists(stLocal.stUser,"openid") and len(stLocal.stUser.openid)>
	<cfoutput>#stLocal.stUser.openid#</cfoutput>
</cfif><cfcatch><cfdump var='#stObj#'></cfcatch></cftry>

<cfsetting enablecfoutputonly="false" />