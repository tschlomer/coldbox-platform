<cfoutput>
<table class="fw_debugTables">
  <thead>
  	<tr>
	  	<th class="fw_cacheReportObject">Object</th>
		<th class="fw_cacheReportHits">Hits</th>
		<th class="fw_cacheReportTimeout">Timeout</th>
		<th class="fw_cacheReportIdleTimeout">Idle Timeout</th>
		<th class="fw_cacheReportCreated">Created</th>
		<th class="fw_cacheReportLastAccessed">Last Accessed</th>
		<th class="fw_cacheReportStatus">Status</th>
		<th class="fw_cacheReportCMDS">CMDS</th>
 	</tr>
  </thead>
  <tbody>
  <cfloop from="1" to="#cacheKeysLen#" index="x">
  	<cfset thisKey = cacheKeys[x]>
  	<tr <cfif x mod 2 eq 0>class="even"</cfif> id="cbox_cache_tr_#urlEncodedFormat(thisKey)#">
	  	<!--- Link --->
		<td class="fw_cacheReportObject">
		  	<a href="javascript:fw_openwindow('#URLBase#?debugpanel=cacheviewer&cbox_cacheName=#arguments.cacheName#&key=#urlEncodedFormat( thisKey )#','CacheViewer',650,375,'resizable,scrollbars,status')"
			   title="#thisKey#">
		  	#left(thisKey,40)#<cfif len(thisKey) gt 40>...</cfif>
			</a>
		</td>
		<!--- Hits --->
		<td class="fw_cacheReportHits">#cacheMetadata[thisKey][ cacheMDKeyLookup.hits ]#</td>
		<!--- Timeout --->
		<td class="fw_cacheReportTimeout">#cacheMetadata[thisKey][ cacheMDKeyLookup.timeout ]#</td>
		<!--- Last Access Timeout --->
		<td class="fw_cacheReportIdleTimeout">#cacheMetadata[thisKey][ cacheMDKeyLookup.lastAccessTimeout ]#</td>
		<!--- Created --->
		<td class="fw_cacheReportCreated">#dateformat(cacheMetadata[thisKey][ cacheMDKeyLookup.Created ],"mmm-dd")# <Br/> #timeformat(cacheMetadata[thisKey][ cacheMDKeyLookup.created ],"hh:mm:ss tt")#</td>
		<!--- Last Accessed --->
		<td class="fw_cacheReportLastAccessed">#dateformat(cacheMetadata[thisKey][ cacheMDKeyLookup.lastAccesed ],"mmm-dd")# <br/> #timeformat(cacheMetadata[thisKey][ cacheMDKeyLookup.lastAccesed ],"hh:mm:ss tt")#</td>
	 	<!--- isExpired --->
		<td class="fw_cacheReportStatus">
			<cfif structKeyExists(cacheMDKeyLookup,"isExpired") and cacheMetadata[thisKey][ cacheMDKeyLookup.isExpired ]>
				<span class="fw_redText">Expired</span>
			<cfelse>
				<span class="fw_blueText">Alive</span>
			</cfif>
		</td>
		<!--- Commands --->
	 	<td class="fw_cacheReportCMDS">
			<input type="button" value="DEL"
				   name="cboxbutton_removeentry_#urlEncodedFormat(thisKey)#" id="cboxbutton_removeentry_#urlEncodedFormat(thisKey)#"
				   title="Remove this entry from the cache."
				   onclick="fw_cacheClearItem('#URLBase#','#urlEncodedFormat(thisKey)#','#arguments.cacheName#')">
		</td>
	  </tr>
  </cfloop>
  </tbody>
</table>
</cfoutput>