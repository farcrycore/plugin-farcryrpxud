<cfsetting enablecfoutputonly="Yes">
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
<!--- @@displayname: Farcry UD login form --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfoutput>
<a class="rpxnow" onclick="return false;" href="https://#application.config.rpx.realm#.rpxnow.com/openid/v2/signin?token_url=#urlencodedformat('http://#cgi.http_host##cgi.script_name#?#cgi.query_string#')#">Sign In</a> 
</cfoutput>

<skin:loadJS id="rpxInclude">
<cfoutput>
  var rpxJsHost = (("https:" == document.location.protocol) ? "https://" : "http://static.");
  document.write(unescape("%3Cscript src='" + rpxJsHost + "rpxnow.com/js/lib/rpx.js' type='text/javascript'%3E%3C/script%3E"));
</cfoutput>
</skin:loadJS>
<skin:loadJS id="rpxSettings">
<cfoutput>
  RPXNOW.overlay = true;
  RPXNOW.language_preference = 'en';
</cfoutput>
</skin:loadJS>
