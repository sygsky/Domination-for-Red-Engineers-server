/*
	scripts/bonus/bonus_def.sqf
	author: Sygsky
	description: none
	returns: nothing
*/
#define DOSAAF_DELAY_STD   5
#define DOSAAF_DELAY_LONG  30
#define DOSAAF_DELAY_NORMAL 1
#define DOSAAF_DIST_TO_REDRAW  10
#define DOSAAF_MARKER_COLOR "ColorGreen"
#define DOSAAF_MAP_POS [9519,10082,0]
#define DOSAAF_MAP_SCALE 0.0025


// code for initial DOSAAF vehicle initialization
#define DOSAAF_INIT_CODE1 "this setVariable [""INSPECT_ACTION_ID"",this addAction [ localize ""STR_CHECK_ITEM"",""scripts\bonus\bonusInspectAction.sqf"",[]]]; this setVariable [""DOSAAF"", """"]"

// code for detected DOSAAF vehicle initialization
#define DOSAAF_INIT_CODE2 "this setVariable [""RECOVERABLE"",false];"

// code for registering DOSAAF vehicle after "Inspect" action
#define DOSAAF_INIT_CODE3 "this setVariable [""INSPECT_ACTION_ID"",this addAction [ localize ""STR_REG_ITEM"",""scripts\bonus\bonusInspectAction.sqf"",[]]];"
