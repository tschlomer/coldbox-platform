<cfsetting enablecfoutputonly=true>
<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Template :  debug.cfm
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :
	The ColdBox debugger


Revised	 :  Aaron Greenlee (http://aarongreenlee.com/)
Date     :	August, 2010
Modified :  Reformatting to spring things up, make compliant. Have fun.

----------------------------------------------------------------------->
<cfoutput>

<!--- set cbox debugger header --->
<cfinclude template="DebugHeader.cfm">

<cfscript>
	/** Evaluate */
	panels = structNew();

	panelsStrings = structNew();
	panelsStrings.InfoPanel = 'Info';
	panelsStrings.CachePanel = 'Cache';
	panelsStrings.ModulesPanel = 'Modules';
	panelsStrings.DumpVarPanel = 'DumpVar';
	panelsStrings.RCPanel = 'Collections';


	if (getDebuggerConfig().getShowInfoPanel()) {
		panels.InfoPanel = true;
	} else {
		panels.InfoPanel = false;
	}
	if (getDebuggerConfig().getShowCachePanel()) {
		panels.CachePanel = true;
	}else {
		panels.CachePanel = false;
	}
	if (controller.getCFMLEngine().isMT() AND getDebuggerConfig().getShowModulesPanel()) {
		panels.ModulesPanel = true;
	} else {
		panels.ModulesPanel = false;
	}
	if (controller.getSetting("DebuggerSettings").EnableDumpVar) {
		panels.DumpVarPanel = true;
	} else {
		panels.DumpVarPanel = false;
	}
	if (getDebuggerConfig().getShowRCPanel()) {
		panels.RCPanel = true;
	} else {
		panels.RCPanel = false;
	}

	/** Small helper for this view. */
	fw_vwlt_ControlBarMinorMenu = '<div class="control_bar_minor fw_fp">';
	for (k in panels) {
		if (panels[k]) {
			fw_vwlt_ControlBarMinorMenu = fw_vwlt_ControlBarMinorMenu & '<div class="fw_fl"><a href="##fw_#lcase(k)#">#panelsStrings[k]#</a></div>';
		}
	}
	fw_vwlt_ControlBarMinorMenu = fw_vwlt_ControlBarMinorMenu & '</div>';

</cfscript>
<div></div>

<div id="fw_coldbox_debugger" class="fw_debugWrapper">
	<div class="fw_debugPanel">
		<!--- Debugger Header -- Always On --->
		<div id="fw_infopanel_main" class="fw_container">
			<div class="fw_fp control_bar">
				<div id="fw_cbTitle" class="fw_fl"></div>
				<div class="fw_cbTitleSub fw_fl">
					<span class="fw_strong">Debugging Information</span>
					<div class="fw_fp">
						<div class="fw_fl"><a href="http://wiki.coldbox.org/?r=appdbg" target="_blank">Wiki</a></div>
						<div class="fw_fl"><a href="http://www.coldbox.org/api?r=appdbg" target="_blank">API</a></div>
						<div class="fw_fl"><a href="http://coldbox.assembla.com/spaces/coldbox/new_dashboard?r=appdbg" target="_blank">Code Tracker</a></div>
						<div class="fw_fl"><a href="http://groups.google.com/group/coldbox?r=appdbg" target="_blank">Forum</a></div>
					</div>
				</div>

				<div class="fw_controls fw_fr">
					<!-- Begin form to control ColdBox -->
					<div id="fw_interactWithColdBoxForm">
						<form name="fw_reinitcoldbox" id="fw_reinitcoldbox" action="#URLBase#" method="POST">
							<input type="hidden" name="fwreinit" id="fwreinit" value="">
							<input type="button" value="Reinitialize Framework" name="reinitframework"
								   title="Reinitialize the framework."
								   onClick="fw_reinitframework(#iif(controller.getSetting('ReinitPassword').length(),'true','false')#)">
							<cfif getDebuggerConfig().getPersistentRequestProfiler()>
							&nbsp;
							<input type="button" value="Open Profiler Monitor" name="profilermonitor"
								   title="Open the profiler monitor in a new window."
								   onClick="window.open('#URLBase#?debugpanel=profiler','profilermonitor','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=850')">
							</cfif>
							&nbsp;
							<input type="button" value="Turn Debugger Off" name="debuggerButton"
								   title="Turn the ColdBox Debugger Off"
								   onClick="window.location='#URLBase#?debugmode=false'">
						</form>
						<br>
					</div>
				</div>
			</div>
		</div>
		<!--- **************************************************************--->
		<!--- TRACER STACK--->
		<!--- **************************************************************--->
		<cfinclude template="panels/TracersPanel.cfm">

		<!--- **************************************************************--->
		<!--- DEBUGGING PANEL --->
		<!--- **************************************************************--->
		<cfif panels.InfoPanel>
		    <div id="fw_infopanel" class="fw_container">
		        <cfif getDebuggerConfig().getExpandedInfoPanel()>
		            <cfset panelState = 'fw_expanded' />
		        <cfelse>
		            <cfset panelState = 'fw_closed' />
		        </cfif>
		        <div class="fw_panelHeader  fw_info_header">
		            <div class="fw_panelHeadline" onClick="fw_toggle('fw_info')">Information Panel</div>
		            <div id="fw_info_minor_menu" class="#panelState#">#fw_vwlt_ControlBarMinorMenu#</div>
		        </div>
		        <!--- Info Panel --->
		        <div class="fw_debugContent #panelState#" id="fw_info">
		            <!--- Col Wrapper --->
		            <div class="fw_fp fw_detailList">
		                <!--- Left Col --->
		                <div class="fw_fl fw_half_width">
		                    <div class="fw_group">
		                        <div class="fw_subline">Request Info</div>
		                        <dl>
		                            <dt>Routed URL</dt>
		                            <dd><cfif Event.getCurrentRoutedURL() eq ""><span class="fw_drawAttention">N/A</span><cfelse>#event.getCurrentRoutedURL()#</cfif></dd>
		                            <dt>Timestamp</dt>
		                            <dd>#dateformat(now(), "MMM-DD-YYYY")# #timeFormat(now(), "hh:MM:SS tt")#</dd>
		                        </dl>

		                        <div class="fw_subline">Application</div>
		                        <dl>
		                            <dt>Name</dt>
		                            <dd>&quot;#controller.getSetting("AppName")#&quot;</dd>
		                            <dt>Environment</dt>
		                            <dd>&quot;#lcase(controller.getSetting("Environment"))#&quot;</dd>
		                            <dt>Host</dt>
		                            <dd>&quot;#controller.getPlugin("Utilities").getInetHost()#&quot;</dd>
		                        </dl>

		                        <div class="fw_subline">Event State</div>
		                        <dl>
		                            <dt>Current Event</dt>
		                            <dd>
		                                <cfif Event.getCurrentEvent() eq ""><span class="fw_drawAttention">N/A</span><cfelse>#Event.getCurrentEvent()#</cfif>
		                                <cfif Event.isEventCacheable()><span class="fw_drawAttention">&nbsp;CACHED EVENT</span></cfif>
		                            </dd>
		                            <dt>Layout</dt>
		                            <dd>
		                                <cfif Event.getCurrentLayout() eq ""><span class="fw_drawAttention">N/A</span><cfelse>#Event.getCurrentLayout()#</cfif>
		                            </dd>

		                            <dt>Route</dt>
		                            <dd><cfif Event.getCurrentRoute() eq ""><span class="fw_drawAttention">N/A</span><cfelse>#event.getCurrentRoute()#</cfif></dd>

		                            <dt>View</dt>
		                            <dd><cfif Event.getCurrentView() eq ""><span class="fw_drawAttention">N/A</span><cfelse>#Event.getCurrentView()#</cfif></dd>
		                        </dl>
		                    </div>
		                </div>
		                <!--- /Left Col --->
		                <!--- Right Col --->
		                <div class="fw_fr fw_half_width">
		                    <div class="fw_group">
		                        <div class="fw_subline">ColdBox Framework Info</div>
		                        <dl>
		                            <dt>Framework</dt>
		                            <dd>#controller.getSetting("Codename",true)# #controller.getSetting("Version",true)# #controller.getSetting("Suffix",true)#</dd>
		                        </dl>

		                        <div class="fw_subline">LogBox</div>
		                        <dl>
		                            <dt>Appenders</dt>
		                            <dd>#controller.getLogBox().getCurrentAppenders()#</dd>
		                            <dt>RootLogger Levels</dt>
		                            <dd>
		                                #controller.getLogBox().logLevels.lookup(controller.getLogBox().getRootLogger().getLevelMin())# -
		                                #controller.getLogBox().logLevels.lookup(controller.getLogBox().getRootLogger().getLevelMax())#
		                            </dd>
		                        </dl>

		                        <div class="fw_subline">Modules</div>
		                        <dl>
		                            <dt>Loaded Modules</dt>
		                            <dd>
		                                <cfloop from="1" to="#arrayLen(loadedModules)#" index="loc.x">
		                                    <cfif len(moduleSettings[loadedModules[loc.x]].entryPoint)>
		                                        <a href="#event.buildLink(moduleSettings[loadedModules[loc.x]].entryPoint)#">#loadedModules[loc.x]#</a>
		                                    <cfelse>
		                                        #loadedModules[loc.x]#
		                                    </cfif>
		                                    <cfif loc.x NEQ arrayLen(loadedModules)>,</cfif>
		                                </cfloop>
		                            </dd>
		                        </dl>
		                    </div>
		                </div>
		                <!--- /Right Col --->
		            </div>
		            <!--- /Col Wrapper --->
		        </div>
		    </div><!--- /Info Panel --->
		</cfif>

		<!--- **************************************************************--->
		<!--- CACHE PANEL --->
		<!--- **************************************************************--->
		<cfif panels.CachePanel>
			#controller.getDebuggerService().renderCachePanel(monitor=false)#
		</cfif>
		<!--- **************************************************************--->
		<!--- DUMP VAR --->
		<!--- **************************************************************--->
		<cfif panels.DumpVarPanel>
			<cfif structKeyExists(rc,"dumpvar")>
			<!--- Dump Var --->
			<div id="fw_dumpvarpanel" class="fw_container">
				<div class="fw_titles" onClick="fw_toggle('fw_dumpvar')">&nbsp;Dumpvar</div>
				<div class="fw_debugContent" id="fw_dumpvar">
					<cfloop list="#rc.dumpvar#" index="i">
						<cfif isDefined("#i#")>
							<cfdump var="#evaluate(i)#" label="#i#" expand="false">
						<cfelseif event.valueExists(i)>
							<cfdump var="#event.getValue(i)#" label="#i#" expand="false">
						</cfif>
					</cfloop>
				</div>
			</div>
			</cfif>
		</cfif>
		<!--- **************************************************************--->
		<!--- ColdBox Modules --->
		<!--- **************************************************************--->
		<cfif controller.getCFMLEngine().isMT() AND panels.ModulesPanel>
			<cfinclude template="panels/ModulesPanel.cfm">
		</cfif>
		<!--- **************************************************************--->
		<!--- Request Collection Debug --->
		<!--- **************************************************************--->
		<cfif panels.RCPanel>
			<div id="fw_rcpanel" class="fw_container">
		        <cfif true>
		            <cfset panelState = 'fw_expanded' />
		        <cfelse>
		            <cfset panelState = 'fw_closed' />
		        </cfif>
		        <div class="fw_panelHeader  fw_info_header">
		            <div class="fw_panelHeadline" onClick="fw_toggle('fw_reqCollection')">Request Collection Panel</div>
		            <div id="fw_reqCollection_minor_menu" class="#panelState#">#fw_vwlt_ControlBarMinorMenu#</div>
		        </div>
				<div class="fw_debugContent<cfif getDebuggerConfig().getExpandedRCPanel()>View</cfif>" id="fw_reqCollection">
					<!--- Public Collection --->
					<cfset thisCollection = rc>
					<cfset thisCollectionType = "Public">
					<cfinclude template="panels/CollectionPanel.cfm">
					<!--- Private Collection --->
					<cfset thisCollection = prc>
					<cfset thisCollectionType = "Private">
					<cfinclude template="panels/CollectionPanel.cfm">
				</div>
			</div>
		</cfif>
		<div class="fw_renderTime fw_minor">Approximate Debug Rendering Time: #GetTickCount()-DebugStartTime# ms</div>
	</div>
</div>
</cfoutput>
<cfsetting enablecfoutputonly=false>