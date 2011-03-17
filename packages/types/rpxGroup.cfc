<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<cfcomponent displayname="RPX Group" extends="farcry.core.packages.types.types" output="false" bsystem="true" hint="Users can be assigned to any number of groups.  Groups in turn are mapped to roles within the system which determine what a user has permission to do.">
<!---------------------------------------------- 
type properties
----------------------------------------------->
	<cfproperty name="title" type="string" default="" hint="The title of this group" ftSeq="1" ftFieldset="" ftLabel="Title" ftType="string" />
	<cfproperty name="aDomains" type="array" ftSeq="2" ftFieldset="" ftRenderType="custom" ftLabel="Domains" ftHint="A list of domains (one per line) that should automatically be assigned this group. '*' for all users. Strict matching to http://your.domain/* and https://your.domain/*." />
	
	<!---------------------------------------------- 
	object methods
	----------------------------------------------->
	
	<cffunction name="ftEditADomains" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var nl = "
" />
		
		<cfsavecontent variable="html">
			<cfoutput>
				<div class="multiField">
					<div id="#arguments.fieldname#DIV">
						<div class="blockLabel">
							<textarea name="#arguments.fieldname#" id="#arguments.fieldname#" class="textareaInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#">#arraytolist(arguments.stMetadata.value,nl)#</textarea>
						</div>
					</div>
				</div>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="ftValidateADomains" access="public" output="false" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.It consists of value and stSupporting">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.Value>
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfset stResult.value = listtoarray(arguments.stFieldPost.value,"#chr(10)##chr(13)#") />

		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

	
	
	<cffunction name="getID" access="public" output="false" returntype="uuid" hint="Returns the objectid for the specified object (name can be the objectid or the title)">
		<cfargument name="name" type="string" required="true" hint="Pass in a role name and the objectid will be returned" />
		
		<cfset var qItem = "" />
		
		<cfif isvalid("uuid",arguments.name)>
			<cfreturn arguments.name />
		<cfelse>
			<cfquery datasource="#application.dsn#" name="qItem">
				select	*
				from	#application.dbOwner#farGroup
				where	lower(title)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.name)#" />
			</cfquery>
			
			<cfreturn qItem.objectid[1] />
		</cfif>
	</cffunction>
	
	<cffunction name="delete" access="public" hint="Removes any corresponding entries in farUser" returntype="struct" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<cfset var stUser = structnew() />
		<cfset var qUser = "" />
		<cfset var oUser = createObject("component", application.stcoapi["farUser"].packagePath) />
		
		<cfquery datasource="#application.dsn#" name="qUser">
			select	*
			from	#application.dbowner#farUser_aGroups
			where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<cfloop query="qUser">
			<cfset stUser = oUser.getData(parentid) />
			<cfset arraydeleteat(stUser.aGroups,seq) />
			<cfset oUser.setData(stProperties=stUser) />
		</cfloop>
		
		<cfreturn super.delete(objectid=arguments.objectid,user=arguments.user,auditNote=arguments.auditNote) />
	</cffunction>
	
	<cffunction name="afterSave" access="public" output="false" returntype="struct" hint="Processes new type content">
		<cfargument name="stProperties" type="struct" required="true" hint="The properties that have been saved" />
		
		<cfset application.security.initCache() />
		
		<cfreturn arguments.stProperties />
	</cffunction>
	
</cfcomponent>