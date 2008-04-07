<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	02/29/2008
Description :

This interceptor provides security to an application. It is very flexible
and customizable. It bases off on the ability to secure events by creating
rules. This interceptor will then try to match a rule to the incoming event
and the user's credentials on roles and/or permissions. 
	
Default Security:
This interceptor will try to use ColdFusion's cflogin + cfloginuser authentication
by default. However, if you are using your own authentication mechanisims you can
still use this interceptor by implementing a Security Validator Object.

Ex:
<cflogin>
	Your login logic here
	<cfloginuser name="name" password="password" roles="ROLES HERE">
</cflogin>

When in default mode, the permissions are ignored and only roles are checked.

Security Validator Object:
A security validator object is a simple cfc that implements the following function:

userValidator(rule:struct) : boolean

This function must return a boolean variable and it must validate a user according
to the rule that just ran by testing the rule that got sent in. The rule will contain
all the fields contained in the database or xml validation file.

Declaring the Validator:
You have three ways to declare the security validator: 

1) This validator object can be set as a property in the interceptor declaration as an 
instantiation path. The interceptor will create it and try to execute it.  

2) You can register the validator via the "registerValidator()" method on this interceptor. 
This must be called from the application start handler or other interceptors as long as it 
executes before any preProcess execution occurs:

<cfset getInterceptor('coldbox.system.interceptors.security').registerValidator(myValidator)>

That validator object can from anywhere you want using the mentioned technique above.

3) Using the validatorIOC property. You set the name of the bean to extract from the IoC
   plugin and it will autowire this interceptor.

Interceptor Properties:

 - useRegex : boolean [default=true] Whether to use regex on event matching
 - useRoutes : boolean [default=false] Whether to redirec to events or routes
 - rulesSource : string [xml|db|ioc|ocm] Where to get the rules from.
 - debugMode : boolean [default=false] If on, then it logs actions via the logger plugin.
 - validator : string [default=""] If set, it must be a valid instantiation path to a security validator object.
 - validatorIOC : string [default=''] If set, it is the name of the bean to autowire this interceptor from.

* Please note that when using regular expressions, you specify and escape the metadata characters.
* If the validator property is used, the interceptor will create it and store it in the interceptor.

XML properties:
The rules will be extracted from an xml configuration file. The format is
defined in the sample.
 - rulesFile : string The relative or absolute location of the rules file.

DB properties:
The rules will be taken off a cfquery using the properties below.
 - rulesDSN : string The datasource to use to connect to the rules table.
 - rulesTable : string The table of where the rules are
 - rulesSQL* : string You can write your own sql if you want. (optional)
 - rulesOrderBy* : string How to order the rules (optional)

The table MUST have the following columns:
Rules Query
 - whitelist : varchar [null]
 - securelist : varchar
 - roles : varchar [null]
 - permissions : varchar [null]
 - redirect : varchar

IOC properties:
The rules will be grabbed off an IoC bean as a query. They must be a valid rules query.
 - rulesBean : string The bean to call on the IoC container
 - rulesBeanMethod : string The method to call on the bean
 - rulesBeanArgs* : string The arguments to send if any (optional)

OCM Properties:
The rules will be placed by the user in the ColdBox cache manager
and then extracted by this interceptor. They must be a valid rules query.
 - rulesOCMkey : string The key of the rules that will be placed in the OCM.

* Optional properties
----------------------------------------------------------------------->
<cfcomponent name="security"
			 hint="This is a security interceptor"
			 output="false"
			 extends="coldbox.system.interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		<cfscript>
			/* Start processing properties */
			if( not propertyExists('useRegex') or not isBoolean(getproperty('useRegex')) ){
				setProperty('useRegex',true);
			}
			if( not propertyExists('useRoutes') or not isBoolean(getproperty('useRoutes')) ){
				setProperty('useRoutes',false);
			}
			if( not propertyExists('debugMode') or not isBoolean(getproperty('debugMode')) ){
				setProperty('debugMode',false);
			}
			/* Source Checks */
			if( not propertyExists('rulesSource') ){
				throw(message="The rulesSource property has not been set.",type="interceptors.security.settingUndefinedException");
			}
			if( not reFindnocase("^(xml|db|ioc|ocm)$",getProperty('rulesSource')) ){
				throw(message="The rules source you set is invalid: #getProperty('rulesSource')#.",
					  detail="The valid sources are xml,db,ioc, and ocm.",
					  type="interceptors.security.settingUndefinedException");
			}
			/* Now Call sourcesCheck */
			RulesSourceChecks();
			
			/* Create the internal properties now */
			setProperty('rules',Arraynew(1));
			setProperty('rulesLoaded',false);
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<!--- After Aspects Load --->
	<cffunction name="afterAspectsLoad" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
		<cfscript>
			/* Load Rules */
			switch( getProperty('rulesSource') ){
				case "xml" : { 
					loadXMLRules(); 
					break; 
				}
				case "db" : { 
					loadDBRules(); 
					break; 
				}
				case "ioc" : { 
					loadIOCRules(); 
					break; 
				}		
			}//end of switch
			
			/* See if using validator */
			if( propertyExists('validator') ){
				/* Try to create Validator */
				try{
					setValidator(CreateObject("component",getProperty('validator')));
				}
				catch(Any e){
					throw("Error creating validator",e.message & e.details, "interceptors.security.validatorCreationException");
				}
			}
			
			/* See if using validator from ioc */
			if( propertyExists('validatorIOC') ){
				/* Try to create Validator */
				try{
					setValidator( getPlugin("ioc").getProperty('validatorIOC') );
				}
				catch(Any e){
					throw("Error creating validator",e.message & e.details, "interceptors.security.validatorCreationException");
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- pre-process --->
	<cffunction name="preProcess" access="public" returntype="void" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
		<cfscript>
			var rules = getProperty('rules');
			var rulesLen = arrayLen(rules);
			var x = 1;
			var currentEvent = event.getCurrentEvent();
			
			/* Load OCM rules */
			if( getProperty('rulesSource') eq "ocm" and not getProperty('rulesLoaded') ){
				loadOCMRules();
			}
			
			/* Loop through Rules */
			for(x=1; x lte rulesLen; x=x+1){
				/* is current event in this whitelist pattern? then continue to next rule */
				if( isEventInPattern(currentEvent,rules[x].whitelist) ){
					if( getProperty('debugMode') ){
						getPlugin("logger").logEntry("information","#currentEvent# found in whitelist: #rules[x].whitelist#");
					}
					continue;
				}
				/* is currentEvent in the secure list and is user in role */
				if( isEventInPattern(currentEvent,rules[x].securelist) ){
					/* Verify if user is logged in and in a secure state */	
					if( _isUserInValidState(rules[x]) eq false ){
						/* Log if Necessary */
						if( getProperty('debugMode') ){
							getPlugin("logger").logEntry("warning","User not in appropriate roles #rules[x].roles# for event=#currentEvent#");
						}
						/* Redirect */
						if( getProperty('useRoutes') ) 
							setNextRoute(rules[x].redirect);
						else 
							setNextEvent(rules[x].redirect);
						break;
					}//end user in roles
					else{
						if( getProperty('debugMode') ){
							//User is in role. continue.
							getPlugin("logger").logEntry("information","Secure event=#currentEvent# matched and user is in roles=#rules[x].roles#. Proceeding");
						}
						break;
					}
				}//end if current event did not match a secure event.
				else{
					if( getProperty('debugMode') ){
						getPlugin("logger").logEntry("information","#currentEvent# Did not match this rule: #rules[x].toString()#");
					}
				}							
			}//end of rules checks
		</cfscript>
	</cffunction>
	
	<!--- Register a validator --->
	<cffunction name="registerValidator" access="public" returntype="void" hint="Register a validator object with this interceptor" output="false" >
		<cfargument name="validatorObject" required="true" type="any" hint="The validator object to register">
		<cfscript>
			/* Test if it has the correct method on it */
			if( structKeyExists(arguments.validatorObject,"userValidator") ){
				setValidator(arguments.validatorObject);
			}
			else{
				throw(message="Validator object does not have a 'userValidator' method ",type="interceptors.security.validatorException");
			}
		</cfscript>
	</cffunction>	
	
<!------------------------------------------- PRIVATE METHDOS ------------------------------------------->
	
	<!--- isEventInPattern --->
	<cffunction name="_isUserInValidState" access="private" returntype="boolean" output="false" hint="Verifies that the user is in any role">
		<!--- ************************************************************* --->
		<cfargument name="rule" required="true" type="struct" hint="The rule we are validating.">
		<!--- ************************************************************* --->
		<cfset var thisRole = "">
		
		<!--- Verify if using validator --->
		<cfif isValidatorUsed()>
			<!--- Validate via Validator --->
			<cfreturn getValidator().userValidator(arguments.rule)>
		<cfelse>
			<!--- Loop Over Roles --->
			<cfloop list="#arguments.rule.roles#" index="thisRole">
				<cfif isUserInRole(thisRole)>
					<cfreturn true>
				</cfif>
			</cfloop>	
			<cfreturn false>
		</cfif>	
	</cffunction>
	
	<!--- isEventInPattern --->
	<cffunction name="isEventInPattern" access="private" returntype="boolean" output="false" hint="Verifies that the current event is in a given pattern list">
		<!--- ************************************************************* --->
		<cfargument name="currentEvent" 	required="true" type="string" hint="The current event.">
		<cfargument name="patternList" 		required="true" type="string" hint="The list to test.">
		<!--- ************************************************************* --->
		<cfset var pattern = "">
		<!--- Loop Over Patterns --->
		<cfloop list="#arguments.patternList#" index="pattern">
			<!--- Using Regex --->
			<cfif getProperty('useRegex')>
				<cfif reFindNocase(pattern,arguments.currentEvent)>
					<cfreturn true>
				</cfif>
			<cfelseif FindNocase(pattern,arguments.currentEvent)>
					<cfreturn true>
			</cfif>	
		</cfloop>	
		<cfreturn false>	
	</cffunction>
		
	<!--- Load XML Rules --->
	<cffunction name="loadXMLRules" access="private" returntype="void" output="false" hint="Load rules from XML file">
		<cfscript>
			/* Validate the XML File */
			var rulesFile = "";
			var xmlRules = "";
			var x=1;
			var node = "";
			var appRoot = getController().getAppRootPath();
		
			/* Clean app root */
			if( right(appRoot,1) neq getSetting("OSFileSeparator",true) ){
				appRoot = appRoot & getSetting("OSFileSeparator",true);
			}
			
			//Test if the file exists
			if ( fileExists(appRoot & getProperty('rulesFile')) ){
				rulesFile = appRoot & getProperty('rulesFile');
			}
			/* Expanded Relative */
			else if( fileExists( ExpandPath(getProperty('rulesFile')) ) ){
				rulesFile = ExpandPath( getProperty('rulesFile') );
			}
			/* Absolute Path */
			else if( fileExists( getProperty('rulesFile') ) ){
				rulesFile = getProperty('rulesFile');
			}
			else{
				throw('Security Rules File could not be located: #getProperty('rulesFile')#. Please check again.','','interceptors.security.rulesFileNotFound');
			}
			/* Set the correct expanded path now */
			setProperty('rulesFile',rulesFile);
			/* Read in and parse */
			xmlRules = xmlSearch(XMLParse(rulesFile),"/rules/rule");
			/* Loop And create Rules */
			for(x=1; x lte Arraylen(xmlRules); x=x+1){
				node = structnew();
				node.whitelist = trim(xmlRules[x].whitelist.xmlText);
				node.securelist = trim(xmlRules[x].securelist.xmlText);
				node.roles = trim(xmlRules[x].roles.xmlText);
				node.permissions = trim(xmlRules[x].permissions.xmlText);
				node.redirect = trim(xmlRules[x].redirect.xmlText);
				ArrayAppend(getProperty('rules'),node);
			}
			/* finalize */
			setProperty('rulesLoaded',true);	
		</cfscript>
	</cffunction>
	
	<!--- Load DB Rules --->
	<cffunction name="loadDBRules" access="private" returntype="void" output="false" hint="Load rules from the database">
		<cfset var qRules = "">
		
		<!--- Let's get our rules from the DB --->
		<cfquery name="qRules" datasource="#getProperty('rulesDSN')#">
		<cfif propertyExists('rulesSQL') and len(getProperty('rulesSQL'))>
			#getProperty('rulesSQL')#
		<cfelse>
			SELECT *
			  FROM #getProperty('rulesTable')#
			<cfif propertyExists('rulesOrderBy') and len(getProperty('rulesOrderBy'))>
			ORDER BY #getProperty('rulesOrderBy')#
			</cfif>
		</cfif>
		</cfquery>
		
		<!--- validate query --->
		<cfset validateRulesQuery(qRules)>
		
		<!--- let's setup the array of struct Rules now --->
		<cfset setProperty('rules', queryToArray(qRules))>
		<cfset setProperty('rulesLoaded',true)>
	</cffunction>
	
	<!--- Load XML Rules --->
	<cffunction name="loadIOCRules" access="private" returntype="void" output="false" hint="Load rules from an IOC bean">
		<cfset var qRules = "">
		<cfset var bean = "">
		
		<!--- Get rules from IOC Container --->
		<cfset bean = getPlugin("ioc").getBean(getproperty('rulesBean'))>
		
		<cfif propertyExists('rulesBeanArgs') and len(getProperty('rulesBeanArgs'))>
			<cfset qRules = evaluate("bean.#getproperty('rulesBeanMethod')#( #getProperty('rulesBeanArgs')# )")>
		<cfelse>
			<!--- Now call method on it --->
			<cfinvoke component="#bean#" method="#getProperty('rulesBeanMethod')#" returnvariable="qRules" />
		</cfif>
		
		<!--- validate query --->
		<cfset validateRulesQuery(qRules)>
		
		<!--- let's setup the array of struct Rules now --->
		<cfset setProperty('rules', queryToArray(qRules))>
		<cfset setProperty('rulesLoaded',true)>
	</cffunction>
	
	<!--- Load XML Rules --->
	<cffunction name="loadOCMRules" access="private" returntype="void" output="false" hint="Load rules from the OCM">
		<cfset var qRules = "">
		
		<!--- Get Rules From OCM --->
		<cfif not getColdboxOCM().lookup(getProperty('rulesOCMkey'))>
			<cfthrow message="No key #getProperty('rulesOCMKey')# in the OCM." type="interceptors.security.invalidOCMKey">
		<cfelse>
			<cfset qRules = getColdboxOCM().get(getProperty('rulesOCMKey'))>
		</cfif>
		
		<!--- validate query --->
		<cfset validateRulesQuery(qRules)>
		
		<!--- let's setup the array of struct Rules now --->
		<cfset setProperty('rules', queryToArray(qRules))>
		<cfset setProperty('rulesLoaded',true)>
	</cffunction>
	
	<!--- ValidateRules Query --->
	<cffunction name="validateRulesQuery" access="private" returntype="void" output="false" hint="Validate a query as a rules query, else throw error.">
		<!--- ************************************************************* --->
		<cfargument name="qRules" type="query" required="true" hint="The query to check">
		<!--- ************************************************************* --->
		<cfset var validColumns = "whitelist,securelist,roles,permissions,redirect">
		<cfset var col = "">
		<!--- Validate Query --->
		<cfloop list="#validColumns#" index="col">
			<cfif not listfindnocase(arguments.qRules.columnlist,col)>
				<cfthrow message="The required column: #col# was not found in the rules query" type="interceptors.security.invalidRuleQuery">
			</cfif>
		</cfloop>
	</cffunction>
	
	<!--- queryToArray --->
	<cffunction name="queryToArray" access="private" returntype="array" output="false" hint="Convert a rules query to our array format">
		<!--- ************************************************************* --->
		<cfargument name="qRules" type="query" required="true" hint="The query to convert">
		<!--- ************************************************************* --->
		<cfscript>
			var x =1;
			var node = "";
			var rtnArray = ArrayNew(1);
			var columns = arguments.qRules.columnlist;
			
			/* Loop over Rules */
			for(x=1; x lte qRules.recordcount; x=x+1){
				/* Create Row Node */
				node = structnew();
				
				/* Create Node with all columns */
				for(y=1; y lte listLen(columns); y=y+1){
					node[listgetAt(columns,y)] = qRules[listgetAt(columns,y)][x];
				}
				
				/* Append it to the array */
				ArrayAppend(rtnArray,node);
			}
			/* return array */
			return rtnArray;
		</cfscript>
	</cffunction>
	
	<!--- rules sources check --->
	<cffunction name="RulesSourceChecks" access="private" returntype="void" output="false" hint="Validate the rules source property" >
		<cfscript>
			switch( getProperty('rulesSource') ){
				
				case "xml" :
				{
					/* Check if file property exists */
					if( not propertyExists('rulesFile') ){
						throw(message="Missing setting for XML source: rulesFile ",type="interceptors.security.settingUndefinedException");
					}
					break;
				}//end of xml check
				
				case "db" :
				{
					/* Check for DSN */
					if( not propertyExists('rulesDSN') ){
						throw(message="Missing setting for DB source: rulesDSN ",type="interceptors.security.settingUndefinedException");
					}
					/* Check for table */
					if( not propertyExists('rulesTable') ){
						throw(message="Missing setting for DB source: rulesTable ",type="interceptors.security.settingUndefinedException");
					}
					/* Optional DB settings are checked when loading rules. */
					break;
				}//end of db check
				
				case "ioc" :
				{
					/* Check for bean */
					if( not propertyExists('rulesBean') ){
						throw(message="Missing setting for ioc source: rulesBean ",type="interceptors.security.settingUndefinedException");
					}
					if( not propertyExists('rulesBeanMethod') ){
						throw(message="Missing setting for ioc source: rulesBeanMethod ",type="interceptors.security.settingUndefinedException");
					}
					
					break;
				}//end of ioc check
				
				case "ocm" :
				{
					/* Check for bean */
					if( not propertyExists('rulesOCMkey') ){
						throw(message="Missing setting for ioc source: rulesOCMkey ",type="interceptors.security.settingUndefinedException");
					}
					break;
				}//end of OCM check			
			
			}//end of switch statement			
		</cfscript>
	</cffunction>
	
	<!--- Get/Set Validator --->
	<cffunction name="getvalidator" access="private" output="false" returntype="any" hint="Get validator">
		<cfreturn instance.validator/>
	</cffunction>	
	<cffunction name="setvalidator" access="private" output="false" returntype="void" hint="Set validator">
		<cfargument name="validator" type="any" required="true"/>
		<cfset instance.validator = arguments.validator/>
	</cffunction>
	
	<!--- Check if using validator --->
	<cffunction name="isValidatorUsed" access="private" returntype="boolean" hint="Check to see if using the validator" output="false" >
		<cfscript>
			return structKeyExists(instance, "validator");
		</cfscript>
	</cffunction>
	
</cfcomponent>