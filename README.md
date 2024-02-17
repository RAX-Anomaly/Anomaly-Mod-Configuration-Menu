# Anomaly-Mod-Configuration-Menu
Inspired by MCM mod for the Bethesda games this provides similar functionality for Anomaly. This is a copy of the Instructions located at the end of the sctipt.

## Table of Contents

1. How to read these options in your script (RavenAscendant)
2. How to add new options (Tronex orginal turotial from ui_options)
3. How to make your script talk to MCM
4. Using dph-hcl's script for save game specific MCM options
5. Additional information on key_bind
6. Additional Key Bind utilities
7. Examples

##  How to read these options in your script

Feilds in `[brackets]`  are described in "How to add new options"

First a bit about setting up your options. Nine times out of ten you don't need any functors. MCM will read the curent value of the setting from `axr_options` with out a `[curr]` functor and will write values to `axr_options` if no `[functor]` is provided. For simple global settings this 
will be more than adequate.

The easiest way to read your setting is call `ui_mcm.get(path)` where path is the id fields of  the nested tables down to the option in the table you returned in `on_mcm_load()`. Most likely this will take the form of "modname/settingname"  but you can break your settings into multiple panels if you want resulting in a loinger path. See the options section of `axr_configs` for how anomaly options menu translates into paths, same system is used here. `ui_mcm.get(path)` is cached and fails back to the value you set in [def=] 

Just like ui_options when MCM applies a settings change it sends an on_option_change callback.

1. You can use this to do a one time read of your options into variables in your script.
2. You can either get the values with `ui_mcm.get(path)` or read them directly from `axr_configs` like so:
    - `axr_main.config:r_value("mcm", path, type,default)`
    - see `_g` for how `r_value` functions.

Examples of when you might want to use functors

1. Saving mod settings to the save game file instead of globaly to axr_configs
2. You are building your settings dynaicaly can't rely on the path being consistant.
3. You otherwise like to over complicate things.

##  How to add new options

The only thing changed from this as compared to the version in `ui_options` is changing all ocurances of `ui_mm_` to `ui_mcm_` 

### Option name

- script will read option name (id) and show it automatically, naming should be like this: | `"ui_mcm_[tree_1]_[tree_2]_[tree_...]_[option]"`
- `[tree_n]` and `[option]` are detemined from option path inside the table
- __Example__: `options["video"]["general"]["renderer"]` name will come from | `"ui_mcm_video_general_renderer"` string

### Option description

- option description can show up in the hint window if its defined by its name followed by | `"_desc"`
- __Example__: option with a name of | `"ui_mcm_video_general_renderer"` will show its hint if | `"ui_mcm_video_general_renderer_desc"` exists

### Parameters of option tree

| Parameter      | Definition                      | Description / purpose  |
|----------------|---------------------------------|----------|
| `[id]`           | `(string)`                        | To give a tree its own identity |
| `[sh]`           | `(boolean)`                       | Determines that the sub-tree tables are actual list of options to set and show |
| `[text]`         | `(string)`                        | To override the display text for the tree in the tree select |
| `[precondition]` | `(table {function, parameters})`  | Don't show tree options if its precondition returns false |
| `[output]`       | `(string)`                        | Text to show when precondition fails |
| `[gr]`           | `(table { ... })`                 | Table of a sub-tree or options list |
| `[apply_to_all]` | `(boolean)`                       | When you have options trees with similar options and group, you can use this to add "Apply to All" button to each option. Clicking it will apply option changes to this option in all other trees from the same group. You must give these a tree a group id. |
| `[id_gr]`        | `(string)`                        | Allows you to give options tree a group id, to connect them when you want to use "Apply to all" button for options |

## Parameters of options

### Critical parameters

These parameters ___must___ be declared for elements:

| Parameter      | Definition                      | Description / Purpose  |
|----------------|---------------------------------|------------------------|
| `[id]`         | `(string)`                      | Option's identity/name. |
|                |                                 | __Example:__ `( tree_1_id/tree_2_id/.../option_id )` |
|                |                                 | Option get stored in axr_main or called in other sripts by its path (IDs of sub trees and option) |
|                |                                 | The top id in the table you return to MCM (tree_1_id in the above example) should be as unique as posible to prevent it from conflicting with another mod. |
| `[type]`            | `(string)`                       | Specifies option's type. See possible values below |

#### Possibe values for `[type]`

| Value |  Description / Purpose         |
|-------|--------------------------------|
| Option elements:         |
| `"check"`            | Option, check box, either ON or OFF |
| `"list"`             | Option, list of strings, useful for options with too many selections |
| `"input"`            | Option, input box, you can type a value of your choice |
| `"radio_h"`       | Option, radio box, select one out of many choices. Can fit up to 8 selections (Horizental layout) |
| `"radio_v"`       | Option, radio box, select one out of many choices. Can fit up any number of selections (Vertical layout) |
| `"track"`           | Option, track bar, easy way to control numric options with min/max values (can be used only if [val] = 2) |
| `"key_bind"`        | Option, button that registers a keypress after being clicked. (See suplimental instructions below) |
| Support elements:         |
| `"line"`             | Support element, a simple line to separate things around |
| `"image"`               | Support element, 563x50 px image box, full-area coverage |
| `"slide"`           | Support element, image box on left, text on right |
| `"title"`           | Support element, title (left/right/center alignment) |
| `"desc"`           | Support element, description (left alignment) |

### Dependable parameters

These parameters ___must be___ declared when ___other specific parameters are declared already___. They work along with them

| Parameter      | Definition                      | Decsription/Purpose  |
|----------------|---------------------------------|----------------------|
| `[val]`        | `(number)`                      | Used by: option elements: ALL  |
|                |                                 | Option's value type: `0. string \| 1. boolean \| 2. float`  |
|                |                                 | It tells the script what kind of value the option is storing / dealing with |
| `[cmd]`        | `(string)`                     | Used by: option elements: ALL (needed if you want to control a console command) |
|                |                                 | Tie an option to a console command, so when the option value get changed, it gets applied directly to the command |
|                |                                 | The option will show command's current value  |
|                |                                 | __NOTE:__ cmd options don't get cached in `axr_options`, instead they get stored in `appdata/user.ltx` |
|                |                                 | `[def]` parameter is not needed here since we engine applies default values to commands if they don't exist in `user.ltx` automatically |
| `[def]`        | `(boolean)` / `(number)` / `(string)` / `( table {function, parameters} )`|  Used by: option elements: ALL (not needed if `[cmd]` is used) |
|                |                                 | Default value of an option |
|                |                                 | when no cached values are found in `axr_options`, the default value will be used |
| `[min]`        | `(number)`                      |  Used by: option elements: `"input"` / "`track"`: (only if `[val] = 2`) |
|                |                                 | Minimum viable value for an option, to make sure a value stays in range |
| `[max]`        | `(number)` |  Used by: option elements:  `"input"` / `"track"`: (only if `[val] = 2`) |
|                |                                 | Maximum viable value for an option, to make sure a value stays in range |
| `[step]`       | `(number)` |  Used by: option elements: `"track"`: (only if `[val] = 2`)  |
|                |                                 | How much a value can be increased/decreased in one step  |
| `[content]`    | `( table {double pairs} )` / `( table {function, parameters} )` |  Used by: option elements: `"list"` / `"radio_h"` / `"radio_v"`:  |
|                |                                 | Delcares option's selection list  |
|                |                                 | Pairs: `{ value of the selection, string to show on UI }`  |
|                |                                 | __Example:__ `content= { {0,"off"} , {1,"half"} , {2,"full"}}`  |
|                |                                 | So the list or radio option will show 3 selections (translated strings): (ui_mcm_lst_off) and (ui_mcm_lst_half) and (ui_mcm_lst_full)  |
|                |                                 | When you select one and it gets applied, the assosiated value will get applied  |
|                |                                 | So picking the first one will pass ( 0 )  |
|                |                                 | Because all lists and radio button elements share the same prefix, "ui_mcm_lst_" it is important that you not use common words like  |
|                |                                 | the ones in the example above. Make your element names unique.  |
| `[link]`         | `(string)`         | Used by: support elements: "image" / "slide"  |
|                |                                 | Link to texture you want to show  |
| `[text]`         | `(string)`         | Used by: support elements: "slide" / "title" / "desc"  |
|                |                                 | String to show near the image, it will be translated  |
    
### Optional parameters

These parameters are completely optionals, and can be used for custom stuff

| Parameter      | Definition                      | Decsription/Purpose  |
|----------------|---------------------------------|----------------------|
| `[force_horz]` | `(boolean)`                     | Used by: option elements: `"radio_h"` |
|                |                                 | Force the radio buttons into horizental layout, despite their number |
| `[no_str]`     | `(boolean)`                     | Used by: option elements: `"list"` / `"radio_h"` / `"radio_v"` / `"track"` |
|                |                                 | Usually, the 2nd key of pairs in content table are strings to show on the UI, by translating `"opt_str_lst_(string)"` |
|                |                                 | when we set `[no_str]` to `true`, it will show the string fromm table as it is without translations or `"opt_str_lst_"` |
|                |                                 | For TrackBars: `[no_str]` won't show value next to the slider |
| `[prec]`       | `(number)`                      | Used by: option elements: "track" |
|                |                                 | allowed number of zeros in a number |
| `[precondition]`| `( table {function, parameters} )` |  Used by: option elements: ALL |
|                |                                 | Show the option on UI if the precondition function returns `true` |
| `[functor]`    | `( table {function, parameters} )` |  Used by: option elements: ALL |
|                |                                 | Execute a function when option's changes get applied |
|                |                                 | The value of the option is added to the end of the parameters list. |
| `[postcondition]`| `( table {function, parameters} )` |  Used by: option elements: ALL, with defined `[functor]` |
|                |                                 | Option won't execute its functor when changes are applied, unless if the postcondition function returns `true` |
| `[curr]`       | `( table {function, parameters} )`|  Used by: option elements: ALL |
|                |                                 | get current value of an option by executing the declared function, instead of reading it from `axr_options.ltx`  |
| `[hint]`  (as of MCM 1.6.0 this will actualy show _desc strings) |  `(string)`         | Used by: option elements: ALL |
|                |                                 | Override default name / desc rule to replace the translation of an option with a custom one, should be set without `"ui_mcm_"` and `"_desc"` |
|                |                                 | __Example:__ `{ hint = "alife_warfare_capture"}` will force the script to use `"ui_mcm_alife_warfare_capture"` and `"ui_mcm_alife_warfare_capture_desc"` for name and desc of the option |
| `[clr]`        | `( table {a,r,b,g} )`           |  Used by: support elements: "title" / "desc" |
|                |                                 | determines the color of the text |
| `[stretch]`    | `(boolean)`                     | Used by: support elements: "slide" |
|                |                                 | force the texture to stretch or not |
| `[pos]`        | `( table {x,y} )`               |  Used by: support elements: "slide" |
|                |                                 | custom pos for the texture |
| `[size]`       | `( table {w,z} )`               |  Used by: support elements: "slide" |
|                |                                 | custom size for the texture |
| `[align]`      | `(string)` "l" "r" "c"          |  Used by: support elements: "title"  |
|                |                                 | determines the alignment of the title |
| `[spacing]`    | `(number)`                      |  Used by: support elements: "slide" |
|                |                                 | hight offset to add extra space |

##  How to make your script talk to MCM

MCM looks for scripts with names ending in mcm: `*mcm.script`. (You can use an `_` to sperate it from the rest of the name of your script but it isn't necessary)

1. In those scripts MCM will execute the function `on_mcm_load()`
2. In order for options to be added to MCM, `on_mcm_load()` __must__ return a valid options tree.

    (as described in the tutorial here, used in the `ui_options` script and shown in the examples below)

3. An additional return value of a string naming a collection is optional

    1. The string will be used to create a category to which the options menus of mods returning the same collection name will be added to.
    2. This is to allow for modular mods to have the settings for each module be grooped under a common heading.
    3. Note that the __collection name__ becomes __the root name__ in your settings path and translation strings.
    4. As a root name care should be taken to ensure it will not conflict with another 
    mod.

## Using dph-hcl's script for save game specific MCM options

dph-hcl's orginal script from https://www.moddb.com/mods/stalker-anomaly/addons/151-mcm-13-mcm-savefile-storage is included unaltered and can be used as described and documented in thier mod and script

Aditionaly for convinence the function has been aliased here as `ui_mcm.store_in_save(path)`. This function can be called safely as MCM will simply print an error if dph-hcl's script is missing

### To make an option be stored in a save game instead of globaly

Call `ui_mcm.store_in_save(path)` path can be a full option path like is used by ui_mcm.get(path) or a partial path

If a __partial__ path is used all options that contain that path __will be stored in the savegame__. Partial paths __must__ start with a valid root and cannot end with a `/`

1. In the second example below the second checkbox in the second options menu would be stored buy
    `ui_mcm.store_in_save("example_example/example_two/2check2")`
2. In the same example storing all options (both checks) in the first option menu would be:
    `ui_mcm.store_in_save("example_example/example_one")`
3. Lastly storing all of the options for your mod would look like: 
    `ui_mcm.store_in_save("example_example")`

4. `ui_mcm.store_in_save(path)` can be called at any time. The easyiest is probably in `on_mcm_load()`
    - __However__ it could be done as late as `on_game_start()` if one wanted to have an MCM option for global
    - one could save specific options storing - i.e. `calling ui_mcm.get(path)` in `on_mcm_load()`. But its a bad idea - don't do that. 

## Additional information on key_bind

Key binds are gathered into __two meta lists__ for the users convienance. This means it is __very important__ that your translation strings clearly identify what the key does. __Ideally__ it should be clear what addon the keybind is from.

Some key_bind-related rules:
1. The value stored by the key bind is the DIK_keys value of the key. Same number that will be given to the key related callbacks.
2. val must be set to 2 and is still manditory.
3. curr and functor  are not curently supported. Post an issue on github describing the usecase you had for them. If it's cool enough they might get fixed.
4. Old (pre 1.6.0) versions of MCM will not display key_bind and calling `ui_mcm.get` for it will return `nil`. __Take that into acount if you want reverse compatablity.__

## Additional Key Bind utilities

### Detecting CTRL/SHIFT/ALT being pressed/held

MCM tracks the held status of the control and shift keys as well as a flag that is `true` when neither is pressed
1. `ui_mcm.MOD_NONE`,  `ui_mcm.MOD_SHIFT` and `ui_mcm.MOD_CTRL`, `ui_mcm.MOD_ALT`
2. `ui_mcm.get_mod_key(val)` will return the above flags based on val: `0:MOD_NONE`, `1:MOD_SHIFT`, `2:MOD_CTRL` and `3:MOD_ALT`
If these somehow get latched they reset when Escape is pressed. __Please report cases of latching__.

### Detecting double-taps, holds, single-key presses

MCM provides functions for
- detecting key double taps and keys that are held down
- single key presses that do not go on to be double or long presses.

### `ui_mcm.double_tap(id, key, [multi_tap])`

Should be called from on_key_press callback after you have filtered for your key

| Parameter   | Description |
|-|-|
| `id`        | should be a unique identifier for your event, scriptname and a number work well: `"ui_mcm01"` |
| `key`       | is of course they key passed into the on_key_press callback. |
| `multi_tap` | if `true` timer is updated instead of cleared allowing for the detection of triple/quad/ect taps |

Returns for a given `id` and `key`

- `true` if less than __X__ ms has elapsed since the last time it was called (with that `id` and `key`) and `false` otherwise
    (where X is a user configurable value between 100ms and 1000 ms)
- if `multi_tap` is `false` - timer is reset when `true` is returned. Prevents the function from returning `true` twice in a row
- if `multi_tap` is `true` - the function will return `true` any time the gap between a call and the one before is within the window.

### `ui_mcm.key_hold(id, key, [repeat])`

Should be called from `on_key_hold` callback after you have filtered for your key

| Parameter   | Description |
|-|-|
| `id`        | should be a unique identifer for your event, scriptname and a number work well: `"ui_mcm01"` |
| `key`       | is the key passed into the `on_key_hold` callback. |
| `repeat` | Optional. time in seconds. If the key continues to be held down will return `true` again after this many seconds on a cycle. |

When called from the `on_key_hold` callback it will return `true` after the key has been held down for Y ms (determined by applying a user defined multiplier to X above) and then again every repeat seconds if repeat is provided. sequence resets when key is released.

### `ui_mcm.simple_press(id, key, functor)`

Should be called from on_key_press callback after you have filtered for your key

| Parameter   | Description |
|-|-|
| `id`        | should be a unique identifer for your event, scriptname and a number work well: `"ui_mcm01"` |
| `key`       | is the key passed into the `on_key_hold` callback. |
| `function: table {function, parameters}` | to be executed when it is determined that the press is not long or double (or multi press in general) |

Unlike the other two this one __does not return anything__:
1. Instead you give it a function to execute.
2. Using this function you gain exclusivity, your event won't fire when the key is __double(multi) taped__ or __held (long press)__
3. It comes at the cost of a small bit of __input delay__.
4. This delay is dependent on the double tap window the used defines in the MCM Key Bind settings.

## Options with translation strings

The following option entries have translation strings provided by MCM and are setup to be ignored by pre 1.6.0 versions of MCM

Note the keybind conflict identification in MCM does NOT look for these and reports conflict on the keybind value alone.

```lua        
--- With shift and control, radio buton style
        {id = "modifier", type = ui_mcm.kb_mod_radio, val = 2, def = 0, hint = "mcm_kb_modifier" , content= { {0,"mcm_kb_mod_none"} , {1,"mcm_kb_mod_shift"} , {2,"mcm_kb_mod_ctrl"},{3,"mcm_kb_mod_alt"}}},
--- With shift and control, list style
        {id = "modifier", type = ui_mcm.kb_mod_list, val = 2, def = 0, hint = "mcm_kb_modifier" , content= { {0,"mcm_kb_mod_none"} , {1,"mcm_kb_mod_shift"} , {2,"mcm_kb_mod_ctrl"},{3,"mcm_kb_mod_alt"}}},
    
        
--- Single double or long press,  , radio buton style
        {id = "mode", type = ui_mcm.kb_mod_radio, val = 2, def = 0, hint = "mcm_kb_mode" , content= { {0,"mcm_kb_mode_press"} , {1,"mcm_kb_mode_dtap"} , {2,"mcm_kb_mode_hold"}}},
--- Single double or long press,  , radio buton style
        {id = "mode", type = ui_mcm.kb_mod_list, val = 2, def = 0, hint = "mcm_kb_mode" , content= { {0,"mcm_kb_mode_press"} , {1,"mcm_kb_mode_dtap"} , {2,"mcm_kb_mode_hold"}}},
```

An example script making use of all of these can be found at: https://github.com/RAX-Anomaly/MiniMapToggle/blob/main/gamedata/scripts/mini_map_toggle_mcm.script

##  Examples

```lua
	function on_mcm_load()
		op = { id= "example_example"      	 	,sh=true ,gr={
            
				{ id= "slide_example_example"				 ,type= "slide"	  ,link= "AMCM_Banner.dds"	 ,text= "ui_mcm_title_example_example"		,size= {512,50}		,spacing= 20 },
				{id = "check1", type = "check", val = 1, def = false},
				{id = "check2", type = "check", val = 1, def = false},
				}
			}
			
		return op
	end
```

### Tree with 3 menus 

A a tree with a root containing three menus with a title slide and check boxes. 

```lua
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
```

### Simple menu - title, slide, check boxes

Two scripts with a simple menu with a title slide and check boxes, that will be added to a collection named "collection_example"

```lua
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
```