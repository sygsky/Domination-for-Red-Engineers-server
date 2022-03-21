/*
	scripts/bonus/bonus_def.sqf
	author: Sygsky
	description: none
	returns: nothing
*/
#define DELAY_STD   60
#define DELAY_LONG   5
#define DELAY_NORMAL 1
#define DELAY_WHILE_NIL 3
#define DIST_TO_REDRAW  10
#define MARKER_COLOR "ColorGreen"
#define CONE_MAP_SERVER [9844,10098,0]

// code for initial DOSAAF vehicle initialization
#define INIT_CODE1 "this setVariable [""INSPECT_ACTION_ID"",this addAction [ localize ""STR_CHECK_ITEM"",""scripts\bonus\bonusInspectAction.sqf"",[]]];"

// code for detected DOSAAF vehicle initialization
#define INIT_CODE1 "this setVariable [""INSPECT_ACTION_ID"", this addAction [ localize ""STR_CHECK_ITEM"", ""scripts\bonus\bonusInspectAction.sqf"",[]]];this setVariable [""RECOVERABLE"",false];"