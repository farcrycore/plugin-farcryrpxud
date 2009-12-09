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
<!---
|| DESCRIPTION ||
$Description: Permission administration. $

|| DEVELOPER ||
$Developer: Blair McKenzie (blair@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />

<!--- set up page header --->
<admin:header title="User Admin" />

<ft:processForm action="add">
	<skin:onReady>
		<cfoutput>
			$fc.objectAdminAction('Administration', '#application.url.farcry#/conjuror/invocation.cfm?objectid=#application.fc.utils.createJavaUUID()#&typename=rpxUser&method=edit&ref=iframe&module=#url.module#&plugin=#url.plugin#');
		</cfoutput>
	</skin:onReady>
	<cfset structdelete(form,"farcryformsubmitted") />
</ft:processForm>

<ft:objectadmin
	typename="dmProfile"
	title="RPX User Administration"
	columnList="firstname,lastname" 
	lCustomColumns="OpenID:displayCellOpenID"
	sortableColumns="firstname,lastname"
	lFilterFields="firstname,lastname"
	sqlorderby="lastname asc" 
	sqlwhere="userdirectory='RPX'"
	module="customlists/rpxProfile.cfm"
	plugin="farcryrpxud"
 />

<admin:footer />