<cfoutput>
	<!--- Wrap in a container for in-page --->
	<div id="fw_cachepanel" class="fw_container">
	    <cfif true>
			<!-- todo -->
	        <cfset panelState = 'fw_expanded' />
	    <cfelse>
	        <cfset panelState = 'fw_closed' />
	    </cfif>
	    <div id="fw_cache_header" class="fw_panelHeader fw_cachebox_header">
	        <div class="fw_panelHeadline" onClick="fw_toggle('fw_cache')">CacheBox Panel</div>
	        <div id="fw_cache_minor_menu" class="#panelState#">#fw_vwlt_ControlBarMinorMenu#</div>
	    </div>
		<div class="fw_debugContentView" id="fw_cache">
			<cfif isObject( controller.getCacheBox() )>
				<div class="fw_cacheControl">
					<ul>
						<cfif NOT isMonitor>
							<!--- Button: Open Cache Monitor --->
							<li><input type="button" value="Open Cache Monitor" name="cachemonitor" style="font-size:10px"
								   title="Open the cache monitor in a new window."
								   onClick="window.open('#URLBase#?debugpanel=cache','cachemonitor','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=850')"></li>
						<cfelse>
							<!--- Refresh Monitor --->
							<li><strong>Refresh Monitor: </strong>
							<select id="frequency" onChange="fw_pollmonitor('cache',this.value,'#URLBase#')" title="Refresh Frequency">
								<option value="0">No Polling</option>
								<cfloop from="5" to="30" index="i" step="5">
								<option value="#i#" <cfif url.frequency eq i>selected</cfif>>#i# sec</option>
								</cfloop>
							</select></li>
						</cfif>
						<cfif isObject( controller.getCacheBox() )>
							<!--- Button: CacheBox ExpireAll --->
							<li><input type="button" value="CacheBox ExpireAll()"
							   name="cboxbutton_cacheBoxExpireAll" id="cboxbutton_cacheBoxExpireAll"
							   style="font-size:10px"
							   title="Tell CacheBox to run an expireAll() on all caches"
							   onclick="fw_cacheBoxCommand('#URLBase#','cacheBoxExpireAll', this.id)" /></li>
							<!--- Button: CacheBox Reap All --->
							<li><input type="button" value="CacheBox ReapAll()"
							   name="cboxbutton_cacheBoxReapAll" id="cboxbutton_cacheBoxReapAll"
							   style="font-size:10px"
							   title="Tell CacheBox to run an reapAll() on all caches"
							   onclick="fw_cacheBoxCommand('#URLBase#','cacheBoxReapAll', this.id)" /></li>
						</cfif>
					</ul>
				</div>
	            <div class="fw_detailList">
	                <!--- Left Col --->
	                <div>
	                    <div class="fw_group">
	                        <div class="fw_subline">Caching Info</div>
	                        <dl>
	                            <dt>CacheBox ID</dt>
	                            <dd>#controller.getCacheBox().getFactoryID()#</dd>
	                            <dt>Configured Caches</dt>
	                            <cfloop from="1" to="#arrayLen(controller.getCacheBox().getCacheNames())#" index="i" step="1">
									<cfset fw_activecache = controller.getCacheBox().getCacheNames()[i] />
									<dd>
										<span class="fw_strong">#fw_activecache#</span>
										<br><a href="" onClick="javascript:fw_cacheGC('#URLBase#','#fw_activecache#','cboxbutton_gc')">run garbage collection</a>
									</dd>
								</cfloop>
	                            <dt>Scope Registration</dt>
	                            <dd>#controller.getCacheBox().getScopeRegistration().toString()#</dd>
	                        </dl>
	                    </div>
					</div>
				</div>
			</cfif>
			<!--- Cache Report Switcher --->
			<h3>Cache Performance Report</h3>
			Select Cache: <select name="fw_cachebox_selector" id="fw_cachebox_selector"
					title="Choose a cache from the list to generate the report"
					onChange="fw_cacheReport('#URLBase#',this.value)">
				<cfloop from="1" to="#arrayLen(cacheNames)#" index="x">
					<option value="#cacheNames[x]#" <cfif cacheNames[x] eq "default">selected="selected"</cfif>>#cacheNames[x]#</option>
				</cfloop>
			</select>
			Cache
			<!--- Reload Contents --->
			<input type="button" value="Regenerate Report"
				   name="cboxbutton_cachebox_regenerateReport"
				   style="font-size:10px"
				   title="Regenerate Report"
				   onClick="fw_cacheReport('#URLBase#',document.getElementById('fw_cachebox_selector').value)" />

			<span class="fw_hidden fw_debugContent" id="fw_cachebox_selector_loading">Loading...</span>


			<!--- Named Cache Report --->
			<div id="fw_cacheReport">
				#renderCacheReport()#
			</div>

		</div>
	</div>

</cfoutput>