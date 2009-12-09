<cfcomponent displayname="OpenID" hint="RPX User Directory" extends="farcry.core.packages.security.UserDirectory" output="false" key="rpx">
	
	<cffunction name="getLoginForm" access="public" output="false" returntype="string" hint="Returns the form component to use for login">
		
		<cfreturn "rpxLogin" />
	</cffunction>
	
	<cffunction name="authenticate" access="public" output="false" returntype="struct" hint="Attempts to process a user. Runs every time the login form is loaded.">
		<cfset var stResult = structnew() />
		<cfset var stResponse = structnew() />
		<cfset var xmlInfo = "" />
		<cfset var qMatch = "" />
		<cfset var oUser = application.fapi.getContentType(typename="rpxUser") />
		<cfset var stUser = structnew() />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfif structkeyexists(form,"token")>
			<cfhttp url="https://rpxnow.com/api/v2/auth_info?format=xml" method="POST" result="stResponse">
				<cfhttpparam type="formfield" name="apiKey" value="#application.config.rpx.apikey#" />
				<cfhttpparam type="formfield" name="token" value="#form.token#" />
			</cfhttp>
			
			<cfset xmlInfo = xmlparse(stResponse.filecontent) />
			
			<cfif xmlInfo.rsp.XMLAttributes.stat eq "ok">
				<cfset session.openid = xmlInfo />
				
				<cfquery datasource="#application.dsn#" name="qMatch">
					select	u.objectid
					from	rpxUser u
					where	openid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.openid.rsp.profile.identifier.xmlText#" />
				</cfquery>
				
				<cfif qMatch.recordcount>
				
					<cfset stResult.authenticated = "true" />
					<cfset stResult.userid = qMatch..objectid />
					<cfset stResult.ud = "RPX" />
					
				<cfelse>
				
					<cfset stUser = oUser.getData(objectid=createuuid()) />
					<cfset stUser.openid = session.openid.rsp.profile.identifier.xmlText />
					<cfif len(application.config.rpx.defaultgroup)>
						<cfset arrayappend(stUser.aGroups,application.config.rpx.defaultgroup) />
						<cfset stUser.lGroups = listappend(stUser.lGroups,application.config.rpx.defaultgroup) />
					</cfif>
					<cfset oUser.setData(stProperties=stUser) />
					
					<cfset stResult.authenticated = "true" />
					<cfset stResult.userid = stUser.objectid />
					<cfset stResult.ud = "RPX" />
					
				</cfif>
				
			<cfelse>
			
				<cfset stResult.authenticated = "false" />
				<cfset stResult.message = "OpenID authentication failed" />
				<cfset stResult.userid = "" />
				<cfset stResult.ud = "RPX" />
				
			</cfif>
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getUserGroups" access="public" output="false" returntype="array" hint="Returns the groups that the specified user is a member of">
		<cfargument name="UserID" type="string" required="true" hint="The user being queried" />
		
		<cfset var qGroups = "" />
		<cfset var aGroups = arraynew(1) />
		
		<cfquery datasource="#application.dsn#" name="qGroups">
			select	g.title
			from	(
						#application.dbowner#rpxUser u
						inner join
						#application.dbowner#rpxUser_aGroups ug
						on u.objectid=ug.parentid
					)
					inner join
					#application.dbowner#rpxGroup g
					on ug.data=g.objectid
			where	u.objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#" />
		</cfquery>
		
		<cfloop query="qGroups">
			<cfset arrayappend(aGroups,title) />
		</cfloop>
		
		<cfreturn aGroups />
	</cffunction>
	
	<cffunction name="getAllGroups" access="public" output="false" returntype="array" hint="Returns all the groups that this user directory supports">
		<cfset var qGroups = "" />
		<cfset var aGroups = arraynew(1) />
		
		<cfquery datasource="#application.dsn#" name="qGroups">
			select		*
			from		#application.dbowner#rpxGroup
			order by	title
		</cfquery>
		
		<cfloop query="qGroups">
			<cfset arrayappend(aGroups,title) />
		</cfloop>

		<cfreturn aGroups />
	</cffunction>

	<cffunction name="getGroupUsers" access="public" output="false" returntype="array" hint="Returns all the users in a specified group">
		<cfargument name="group" type="string" required="true" hint="The group to query" />
		
		<cfset var qUsers = "" />
		
		<cfquery datasource="#application.dsn#" name="qUsers">
			select	objectid
			from	(
						#application.dbowner#rpxUser u
						inner join
						#application.dbowner#rpxUser_aGroups ug
						on u.objectid=ug.parentid
					)
					inner join
					#application.dbowner#rpxGroup g
					on ug.data=g.objectid
			where	g.title=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.group#" />
		</cfquery>
		
		<cfreturn listtoarray(valuelist(qUsers.objectid)) />
	</cffunction>
	
	<cffunction name="getProfile" access="public" output="false" returntype="struct" hint="Returns profile data available through the user directory">
		<cfargument name="userid" type="string" required="true" hint="The user directory specific user id" />
		<cfargument name="currentprofile" type="struct" required="false" hint="The current user profile" />
		
		<cfset var stProfile = structnew() />
		
		<cfif isdefined("session.openid")>
			<cfset stProfile.firstname = session.openid.rsp.profile.name.givenName.xmlText />
			<cfset stProfile.lastname = session.openid.rsp.profile.name.familyName.xmlText />
			<cfset stProfile.emailaddress = session.openid.rsp.profile.verifiedEmail.xmlText />
			<cfset stProfile.override = true />
		</cfif>
		
		<cfreturn stProfile />
	</cffunction>
	
	<cffunction name="isEnabled" access="public" output="false" returntype="boolean" hint="Returns true if this user directory is active. This function can be overridden to check for the existence of config settings.">
		
		<cfreturn application.factory.oAltertype.isCFCDeployed(typename="rpxUser") and application.factory.oAltertype.isCFCDeployed(typename="rpxGroup") and isdefined("application.config.rpx.realm") and len(application.config.rpx.realm) and isdefined("application.config.rpx.apikey") and len(application.config.rpx.apikey) />
	</cffunction>
	
</cfcomponent>