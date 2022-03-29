/*
	scripts/bonus/bonus_def.sqf
	author: Sygsky
	description: none
	returns: nothing
*/
#define DOSAAF_DELAY_STD   5
#define DOSAAF_DELAY_LONG  60
#define DOSAAF_DELAY_NORMAL 1
#define DOSAAF_DIST_TO_REDRAW  10
#define DOSAAF_MARKER_COLOR "ColorGreen"
#define DOSAAF_CONE_MAP_SERVER [9844,10098,0]

// code for initial DOSAAF vehicle initialization
#define DOSAAF_INIT_CODE1 "this setVariable [""INSPECT_ACTION_ID"",this addAction [ localize ""STR_CHECK_ITEM"",""scripts\bonus\bonusInspectAction.sqf"",[]]];"

// code for detected DOSAAF vehicle initialization
#define DOSAAF_INIT_CODE2 "this setVariable [""RECOVERABLE"",false];"