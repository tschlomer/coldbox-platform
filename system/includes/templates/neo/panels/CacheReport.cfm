<cfoutput>
<!--- Id & Name --->
<cfif isObject( controller.getCacheBox() ) >
	<div class="fw_detailList fw_fp">
        <div class="fw_half_width fw_fl">
            <div class="fw_group">
                <div class="fw_subline"> Cache Details</div>
                <dl>
                    <dt>Cache Name</dt>
                    <dd>#cacheProvider.getName()#</dd>
					<dt class="fw_notStrong">#getMetadata(cacheProvider).name#</dt>
					<dd>&nbsp;</dd>
                </dl>

                <div class="fw_subline">Performance</div>
                <dl>
                    <dt>Hit Ratio</dt>
                    <dd>#NumberFormat(cacheStats.getCachePerformanceRatio(),"999.99")#%</dd>

					<dt>Hits</dt>
                    <dd>#cacheStats.getHits()#</dd>

					<dt>Misses</dt>
                    <dd>#cacheStats.getMisses()#</dd>

					<dt>Evictions</dt>
                    <dd>#cacheStats.getEvictionCount()#</dd>

					<dt>Garbage Collections</dt>
                    <dd>#cacheStats.getGarbageCollections()#</dd>

					<dt>Object Count</dt>
                    <dd>#cacheSize#</dd>

					<dt>Last Reap</dt>
					<cfif len(cacheStats.getlastReapDatetime())>
						<dd>#DateFormat(cacheStats.getlastReapDatetime(),"MMM-DD-YYYY")#
							#TimeFormat(cacheStats.getlastReapDatetime(),"hh:mm:ss tt")#
						</dd>
					<cfelse>
						<dd><span class="fw_drawAttention">N/A</span></dd>
					</cfif>
                </dl>
			</div>
		</div>
		<div class="fw_half_width fw_fl">
			<div class="fw_group">
                <div class="fw_subline">JVM Memory</div>
                <dl>
					<dt>Free</dt>
                    <dd>#NumberFormat((JVMFreeMemory/JVMMaxMemory)*100,"99.99")# %</dd>
					<dt>Total Assigned</dt>
					<dd>#NumberFormat(JVMTotalMemory)# KB</dd>
					<dt>Max</dt>
					<dd>#NumberFormat(JVMMaxMemory)# KB</dd>
                </dl>

                <div class="fw_subline">Last Reap</div>
                <dl>
					<dt>Free</dt>
                    <dd>#NumberFormat((JVMFreeMemory/JVMMaxMemory)*100,"99.99")# %</dd>
					<dt>Total Assigned</dt>
					<dd>#NumberFormat(JVMTotalMemory)# KB</dd>
					<dt>Max</dt>
					<dd>#NumberFormat(JVMMaxMemory)# KB</dd>
                </dl>
            </div>
		</div>
	</div>
</cfif>

<!--- Cache Charting --->
<cfinclude template="CacheCharting.cfm">

<!--- Cache Configuration --->
<h3>Cache Configuration
	<input type="button" value="Show/Hide"
		   name="cboxbutton_cacheproperties"
		   title="View Cache Properties"
		   onClick="fw_toggleDiv('fw_cacheConfigurationTable','table')" />
</h3>

<cfset fw_SortedCacheKeys = structKeyArray(cacheConfig) />
<cfset fw_startColTwo = round(arrayLen(fw_SortedCacheKeys) / 2) />


<cfset arraySort(fw_SortedCacheKeys, 'textnocase', 'asc') />
<div class="fw_detailList fw_fp">
	<div class="fw_group">
		<div class="fw_half_width fw_fl">
            <div class="fw_subline">Cache Configuration</div>
			<dl>
				<cfloop from="1" to="#fw_startColTwo#" index="i" step="1">
					<dt>#lcase(fw_SortedCacheKeys[i])#</dt>
					<dd>#cacheConfig[fw_SortedCacheKeys[i]].toString()#</dd>
				</cfloop>
			</dl>
		</div>
		<div class="fw_half_width fw_fl">
            <div class="fw_subline">&nbsp;</div>
			<dl>
				<cfloop from="#fw_startColTwo + 1#" to="#arrayLen(fw_SortedCacheKeys)#" index="i" step="1">
					<dt>#lcase(fw_SortedCacheKeys[i])#</dt>
					<dd>#cacheConfig[fw_SortedCacheKeys[i]].toString()#</dd>
				</cfloop>
			</dl>
		</div>
	</div>
</div>

<!--- Check if reporting enabled --->
<cfif isCacheBox and NOT cacheProvider.isReportingEnabled()><cfexit></cfif>

<!--- Content Report --->
<h3>Cache Content Report</h3>

<!--- Reload Contents --->
<input type="button" value="Reload Contents"
	   name="cboxbutton_reloadContents"
	   title="Reload the contents"
	   onClick="fw_cacheContentReport('#URLBase#','#arguments.cacheName#')" />
<!--- Expire All Keys --->
<input type="button" value="Expire All Keys"
	   name="cboxbutton_expirekeys" id="cboxbutton_expirekeys"
	   title="Expire all the keys in the cache"
	   onclick="fw_cacheContentCommand('#URLBase#','expirecache', '#arguments.cacheName#')" />
<!--- Clear All Events --->
<input type="button" value="Clear All Events"
	   name="cboxbutton_clearallevents" id="cboxbutton_clearallevents"
	   title="Remove all the events in the cache"
	   onclick="fw_cacheContentCommand('#URLBase#','clearallevents', '#arguments.cacheName#')" />
<!--- Clear All Views --->
<input type="button" value="Clear All Views"
	   name="cboxbutton_clearallviews" id="cboxbutton_clearallviews"
	   	   title="Remove all the views in the cache"
	   onclick="fw_cacheContentCommand('#URLBase#','clearallviews', '#arguments.cacheName#')" />

<!--- Loader --->
<span class="fw_redText fw_debugContent fw_hidden" id="fw_cacheContentReport_loader">Please Wait, Processing...</span>

<!--- Content Report --->
<div class="fw_cacheContentReport" id="fw_cacheContentReport">
	#renderCacheContentReport(arguments.cacheName)#
</div>
</cfoutput>