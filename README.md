# Anomaly-Mod-Configuration-Menu
Inspired by MCM mod for the Bethesda games this provides similar functionality for Anomaly

This is a copy of the Instructions located at the end of the sctipt.

------------------------------------------------------------
-- Tutorial:Table of Contents:
------------------------------------------------------------
--[[
	Use the [-] in the margin in notpad++ to colapse sections for easier
	navigation
	
	1. How to read these options in your script (RavenAscendant)
	2. How to add new options (Tronex orginal turotial from ui_options)
	3. How to make your script talk to MCM
	4. Examples

]]--

------------------------------------------------------------
-- Tutorial: How to read these options in your script:
------------------------------------------------------------
--[[
	Feilds in [backets]  are described in "How to add new options"
	
	First a bit about setting up your options. Nine times out of ten you don't need any functors.
		MCM will read the curent value of the setting from axr_options with out a [curr] functor and
		will write values to axr_options if no [functor] is provided. For simple global settings this 
		will be more than adequate.
	
	The easiest way to read your setting is call ui_mcm.get(path) where path is the id fields of 
		the nested tables down to the option in the table you returned in on_mcm_load() . Mostlikely 
		this will take the form of "modname/settingname"  but you can break your settings into multiple
		panels if you want resulting in a loinger path. see the options section of axr_configs for how 
		anomaly options menu translates into paths, same system is used here.
		ui_mcm.get(path) is cached and fails back to the value you set in [def=] 
	
	Just like ui_options when MCM applies a settings change it sends an on_option_change callback
		you can use this to do a one time read of your options into variables in your script.
		you can either get the values with ui_mcm.get(path) or read them directly from axr_configs
		like so:
			axr_main.config:r_value("mcm", path, type,default) --see _g for how r_value functions.
	
	
	Examples of when you might want to use functors: 
		Saving mod settings to the save game file instead of globaly to axr_configs
		You are building your settings dynaicaly can't rely on the path being consistant.
		You otherwise like to over complicate things.

]]--


------------------------------------------------------------
-- Tutorial: How to add new options:
------------------------------------------------------------
--[[

	The only thing changed from this as compared to the version in ui_options is changing all ocurances of ui_mm_ to ui_mcm_ 
	------------------------------------------------------------------------------------------------
	Option name:
		script will read option name (id) and show it automatically, naming should be like this: "ui_mcm_[tree_1]_[tree_2]_[tree_...]_[option]"
		[tree_n] and [option] are detemined from option path inside the table
			Example: options["video"]["general"]["renderer"] name will come from "ui_mcm_video_general_renderer" string
			
	------------------------------------------------------------------------------------------------
	Option description:
		option description can show up in the hint window if its defined by its name followed by "_desc"
			Example: option with a name of "ui_mcm_video_general_renderer" will show its hint if "ui_mcm_video_general_renderer_desc" exists
		
	
	------------------------------------------------------------------------------------------------
	Parameters of option Tree:
	------------------------------------------------------------------------------------------------
	
	- [id]
	- Define: (string)
		To give a tree its own identity
	
	- [sh]
	- Define: (boolean)
		used to detemine that the sub-tree tables are actual list of options to set and show
		
	- [text]
	- Define: (string)
		To over ride the display text for the tree in the tree select
		
	- [precondition]
	- Define: ( table {function, parameters} )
		don't show tree options if its precondition return false
		
	- [output]
	- Define: (string)
		Text to show when precondition fails
		
	- [gr]
	- Define: ( table { ... } )
		Table of a sub-tree or options list
		
	- [apply_to_all]
	- Define: (boolean)
		when you have options trees with similar options and group, you can use this to add "Apply to All" button to each option
		clicking it will apply option changes to this option in all other trees from same group
		you must give these a tree a group id
		
	- [id_gr]
	- Define: (string)
		allows you to give options tree a group id, to connect them when you want to use "Apply to all" button for options
	
	------------------------------------------------------------------------------------------------
	Parameters of options:
	------------------------------------------------------------------------------------------------
	
	----------------------
	Critical parameters:
	--------------------
	These parameters must be declared for elements
	
	[id]
	- Define: (string)
		Option identity/name.
		Option get stored in axr_main or called in other sripts by its path (IDs of sub trees and option):
			Example: ( tree_1_id/tree_2_id/.../option_id ) 
		The top id in the table you return to MCM (tree_1_id in the above example) should be as unique as 
			posible to prevent it from conflicting with another mod.
	
	[type]
	- Define: (string)
	- Possible values:
		- Option elements:
				"check"        	: Option, check box, either ON or OFF
				"list"         	: Option, list of strings, useful for options with too many selections
				"input"        	: Option, input box, you can type a value of your choice
				"radio_h"   	: Option, radio box, select one out of many choices. Can fit up to 8 selections (Horizental layout)
				"radio_v"   	: Option, radio box, select one out of many choices. Can fit up any number of selections (Vertical layout)
				"track"       	: Option, track bar, easy way to control numric options with min/max values (can be used only if [val] = 2)
		- Support elements:
				"line"         	: Support element, a simple line to separate things around
				"image"    	   	: Support element, 563x50 px image box, full-area coverage
				"slide"   		: Support element, image box on left, text on right
				"title"   		: Support element, title (left/right/center alignment)
				"desc"   		: Support element, description (left alignment)
		
	
	----------------------
	Dependable parameters:
	----------------------
	These parameters must be declared when other specific parameters are declared already. They work along with them
		
	[val]
	- Define: (number)
	- Used by: option elements: ALL
		Option's value type: 0. string | 1. boolean | 2. float
		It tells the script what kind of value the option is storing / dealing with

	[cmd]:
	- Define: (string)
	- Used by: option elements: ALL (needed if you want to control a console command)
		Tie an option to a console command, so when the option value get changed, it get applied directly to the command
		The option will show command's current value 
		NOTE:
			cmd options don't get cached in axr_options, instead they get stored in appdata/user.ltx
			[def] parameter is not needed here since we engine applies default values to commands if they don't exist in user.ltx automatically
		
	[def]
	- Define: (boolean) / (number) / (string) / ( table {function, parameters} )
	- Used by: option elements: ALL (not needed if [cmd] is used)
		Default value of an option
		when no cached values are found in axr_options, the default value will be used
	
	[min]
	- Define: (number)
	- Used by: option elements: "input" / "track": (only if [val] = 2)
		Minimum viable value for an option, to make sure a value stays in range
		
	[max]
	- Define: (number)
	- Used by: option elements:  "input" / "track": (only if [val] = 2)
		Maximum viable value for an option, to make sure a value stays in range
		
	[step]
	- Define: (number)
	- Used by: option elements: "track": (only if [val] = 2)
		How much a value can be increased/decreased in one step
		
	[content]
	- Define: ( table {double pairs} ) / ( table {function, parameters} )
	- Used by: option elements: "list" / "radio_h" / "radio_v":
		Delcares option's selection list
		Pairs: { value of the selection, string to show on UI }
			Example: content= { {0,"off"} , {1,"half"} , {2,"full"}}
			So the list or radio option will show 3 selections (translated strings): (ui_mcm_lst_off) and (ui_mcm_lst_half) and (ui_mcm_lst_full)
			When you select one and it get applied, the assosiated value will get applied
			So picking the first one will pass ( 0 )
		Because all lists and radio button elements share the same prefix, "ui_mcm_lst_" it is important that you not use common words like
			the ones in the example above. Make your element names unique.
		
	[link]
	- Define: (string)
	- Used by: support elements: "image" / "slide"
		Link to texture you want to show
		
	[text]
	- Define: (string)
	- Used by: support elements: "slide" / "title" / "desc"
		String to show near the image, it will be translated
		
	----------------------
	Optional parameters:
	----------------------
	These parameters are completely optionals, and can be used for custom stuff
	
	[force_horz]
	- Define: (boolean)
	- Used by: option elements: "radio_h"
		Force the radio buttons into horizental layout, despite their number
		
	[no_str]
	- Define: (boolean)
	- Used by: option elements: "list" / "radio_h" / "radio_v" / "track"
		Usually, the 2nd key of pairs in content table are strings to show on the UI, by translating "opt_str_lst_(string)"
		when we set [no_str] to true, it will show the string fromm table as it is without translations or "opt_str_lst_"
		For TrackBars: no_str won't show value next to the slider
		
	[prec]
	- Define: (number)
	- Used by: option elements: "track"
		allowed number of zeros in a number
		
	[precondition]
	- Define: ( table {function, parameters} )
	- Used by: option elements: ALL
		Show the option on UI if the precondition function returns true
	
	[functor]
	- Define: ( table {function, parameters} )
	- Used by: option elements: ALL
		Execute a function when option's changes get applied
		The value of the option is added to the end of the parameters list.
		
	[postcondition]
	- Define: ( table {function, parameters} )
	- Used by: option elements: ALL, with defined [functor]
		Option won't execute its functor when changes are applied, unless if the postcondition function returns true

	[curr]
	- Define: ( table {function, parameters} )
	- Used by: option elements: ALL
		get current value of an option by executing the declared function, instead of reading it from axr_options.ltx
		
	[hint]
	- Define: (string)
	- Used by: option elements: ALL
		Override default name / desc rule to replace the translation of an option with a custom one, should be set without "ui_mcm_" and "_desc"
			Example: { hint = "alife_warfare_capture"} will force the script to use "ui_mcm_alife_warfare_capture" and "ui_mcm_alife_warfare_capture_desc" for name and desc of the option
	
	[clr]
	- Define: ( table {a,r,b,g} )
	- Used by: support elements: "title" / "desc"
		determines the color of the text
		
	[stretch]
	- Define: (boolean)
	- Used by: support elements: "slide"
		force the texture to stretch or not
		
	[pos]
	- Define: ( table {x,y} )
	- Used by: support elements: "slide"
		custom pos for the texture
		
	[size]
	- Define: ( table {w,z} )
	- Used by: support elements: "slide"
		custom size for the texture
		
	[align]
	- Define: (string) "l" "r" "c"
	- Used by: support elements: "title"
		determines the alignment of the title
		
	[spacing]
	- Define: (number)
	- Used by: support elements: "slide"
		hight offset to add extra space
--]]

------------------------------------------------------------
-- Tutorial: How to make your script talk to MCM:
------------------------------------------------------------

--[[
	MCM looks for scripts with names ending in mcm: *mcm.script you can use an _ to sperate it from the 
		rest of the name of your script but it isn't necessary.
	In those scripts MCM will execute the function on_mcm_load()
	In order for options to be added to MCM, on_mcm_load() must return a valid options tree
		as described in the tutorial here, used in the ui_options script and shown in the examples below
	An aditioanl retun value of a string naming a collection is optional. The string will be used to create a catagory to which the	
		the options menues of mods returning the same collection name will be added to. This is to allow for 
		modular mods to have the settings for each module be grooped under a common heading. Note the collection name becomes the root
		name in your settings path and translation strings. As a root name care should be taken to ensure it will not conflict with another 
		mod.

	
]]--

---------------------------------------------------------------------------------------
-- Tutorial: Using : dph-hcl's script for save game specific MCM options
---------------------------------------------------------------------------------------

--[[
	dph-hcl's orginal script from https://www.moddb.com/mods/stalker-anomaly/addons/151-mcm-13-mcm-savefile-storage 
		is included un altered and can be used as described and documented in thier mod and script
	
	Aditionaly for convinence the function has been aliased here as ui_mcm.store_in_save(path)
		this function can be called safely as MCM will simply print an error if dph-hcl's script is missing

	To make an option be stored in a save game instead of globaly call ui_mcm.store_in_save(path)
	 	path can be a full option path like is used by ui_mcm.get(path) or a partial path
	If a partial path is used all options that caontain that path will be stored in the savegame
		partial paths must start with a valid root and cannot end with a /

	In the second example below the second checkbox in the second options menu would be stored buy
		ui_mcm.store_in_save("example_example/example_two/2check2")
	In the same example storing all options (both checks) in the first option menu would be:
		ui_mcm.store_in_save("example_example/example_one")
	Lastly storing all of the options for your mod would look like: 
		ui_mcm.store_in_save("example_example")
	
	ui_mcm.store_in_save(path) can be called at any time. The easyiest is probably in on_mcm_load()
		however it could be done as late as on_game_start() if one wanted to have an MCM option for global vs save specific options storing
			(calling ui_mcm.get(path) in on_mcm_load() is a bad idea don't do that )
]]--


------------------------------------------------------------
-- Tutorial: Examples:
------------------------------------------------------------

-- these examples can all be copied to a blank script example_mcm.script and ran.

-- A simple menu with a title slide and check boxes.
--[[

	function on_mcm_load()
		op = { id= "example_example"      	 	,sh=true ,gr={
				{ id= "slide_example_example"				 ,type= "slide"	  ,link= "AMCM_Banner.dds"	 ,text= "ui_mcm_title_example_example"		,size= {512,50}		,spacing= 20 },
				{id = "check1", type = "check", val = 1, def = false},
				{id = "check2", type = "check", val = 1, def = false},
				}
			}
			
		return op
	end
]]--

-- A a tree with a root containing three menues with a title slide and check boxes. 
--[[

	function on_mcm_load()
		op =  { id= "example_example"      	 	, ,gr={
			
						{ id= "example_one"      	 	,sh=true ,gr={
							{ id= "slide_example_example"				 ,type= "slide"	  ,link= "AMCM_Banner.dds"	 ,text= "ui_mcm_title_example_example"		,size= {512,50}		,spacing= 20 },
							{id = "1check1", type = "check", val = 1, def = false},
							{id = "1check2", type = "check", val = 1, def = false},
							}
						},
						{ id= "example_two"      	 	,sh=true ,gr={
							{ id= "slide_example_example"				 ,type= "slide"	  ,link= "AMCM_Banner.dds"	 ,text= "ui_mcm_title_example_example"		,size= {512,50}		,spacing= 20 },
							{id = "2check1", type = "check", val = 1, def = false},
							{id = "2check2", type = "check", val = 1, def = false},
							}
						},
						{ id= "example_three"      	 	,sh=true ,gr={
							{ id= "slide_example_example"				 ,type= "slide"	  ,link= "AMCM_Banner.dds"	 ,text= "ui_mcm_title_example_example"		,size= {512,50}		,spacing= 20 },
							{id = "3check1", type = "check", val = 1, def = false},
							{id = "3check2", type = "check", val = 1, def = false},
							}
						},
					}
				}
					
			
		return op
	end
]]--

-- Two scripts with a simple menu with a title slide and check boxes, that will be added to a collection named "collection_example"
--[[
	-- example1_mcm.script
	function on_mcm_load()
		op = { id= "first_example"      	 	,sh=true ,gr={
				{ id= "slide_first_example"				 ,type= "slide"	  ,link= "AMCM_Banner.dds"	 ,text= "ui_mcm_title_first_example"		,size= {512,50}		,spacing= 20 },
				{id = "check1", type = "check", val = 1, def = false},
				{id = "check2", type = "check", val = 1, def = false},
				}
			}
			
		return op, "collection_example"
	end
	
	-- example2_mcm.script.
	function on_mcm_load()
		op = { id= "second_example"      	 	,sh=true ,gr={
				{ id= "slide_second_example"				 ,type= "slide"	  ,link= "AMCM_Banner.dds"	 ,text= "ui_mcm_title_second_example"		,size= {512,50}		,spacing= 20 },
				{id = "check1", type = "check", val = 1, def = false},
				{id = "check2", type = "check", val = 1, def = false},
				}
			}
			
		return op, "collection_example"
	end
]]--
