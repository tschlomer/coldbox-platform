<cfoutput>
<div class="fw_container">
    <cfif true>
        <cfset panelState = 'fw_expanded' />
    <cfelse>
        <cfset panelState = 'fw_closed' />
    </cfif>
    <div class="fw_panelHeader  fw_info_header">
        <div class="fw_panelHeadline" onClick="fw_toggle('fw_modules')">Modules Panel</div>
        <div id="fw_modules_minor_menu" class="#panelState#">#fw_vwlt_ControlBarMinorMenu#</div>
    </div>
	<div class="fw_debugContent<cfif getDebuggerConfig().getExpandedModulesPanel()>View</cfif>" id="fw_modules">

		<div>
			<!--- Module Commands --->
			<input type="button" value="Reload All"
				   name="cboxbutton_reloadModules"
				   title="Reload All Modules"
				   onClick="location.href='#URLBase#?cbox_command=reloadModules'" />
			<input type="button" value="Unload All"
				   name="cboxbutton_unloadModules"
				   title="Unload all modules from the application"
				   onClick="location.href='#URLBase#?cbox_command=unloadModules'" />

		</div>
		<p>Below you can see the loaded application modules.</p>
		<div>
			<!--- Module Charts --->
			<table border="0" cellpadding="0" cellspacing="1" class="fw_debugTables">
				<tr>
					<th class="fw_modulesModule">Module</th>
					<th class="fw_modulesAuthor">Author</th>
					<th class="fw_modulesVersion">Version</th>
					<th class="fw_modulesVPL">V.P.L</th>
					<th class="fw_modulesLPL">L.P.L</th>
					<th class="fw_modulesAuthor">Load Time</th>
					<th class="fw_modulesCMDS">CMDS</th>
				</tr>
				<cfloop from="1" to="#arrayLen(loadedModules)#" index="loc.x">
				<cfset loc.mod = moduleSettings[loadedModules[loc.x]]>
				<tr>
					<td title=" Invocation Path: #loc.mod.invocationPath#">
						<strong>#loc.mod.Title#</strong><br />
						#loc.mod.description# <br /><br />
						<cfif len(moduleSettings[loadedModules[loc.x]].entryPoint)>
						<a href="#event.buildLink(loc.mod.entryPoint)#" title="#event.buildLink(loc.mod.entryPoint)#">Open Module Entry Point</a>
						<cfelse>
							<em>No Entry Point Defined</em>
						</cfif>
					</td>
					<td class="fw_center">
						<a href="#loc.mod.webURL#" title="#loc.mod.webURL#">#loc.mod.Author#</a>
					</td>
					<td class="fw_center">
						#loc.mod.Version#
					</td>
					<td class="fw_center">
						#yesNoFormat(loc.mod.viewParentLookup)#
					</td>
					<td class="fw_center">
						#yesNoFormat(loc.mod.layoutParentLookup)#
					</td>
					<td class="fw_center">
						#dateFormat(loc.mod.loadTime,"mmm-dd")# <br />
						#timeFormat(loc.mod.loadTime,"hh:mm:ss tt")#
					</td>
					<td class="fw_center">
						<input type="button" value="Unload"
							   name="cboxbutton_unloadModule"
							   title="Unloads This Module Only!"
						   	   onClick="location.href='#URLBase#?cbox_command=unloadModule&module=#loadedModules[loc.x]#'">
						<input type="button" value="Reload"
							   name="cboxbutton_unloadModule"
							   title="Reloads This Module Only!"
						   	   onClick="location.href='#URLBase#?cbox_command=reloadModule&module=#loadedModules[loc.x]#'">
					</td>
				</tr>
				</cfloop>

			</table>
			<p class="fw_minor">
				<em>* V.P.L = View Parent Lookup Order<br />* L.P.L = Layout Parent Lookup Order</em>
			</p>
		</div>

	</div>
</div>
</cfoutput>