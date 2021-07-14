/*
	scripts\SYG_sabotage_stash.sqf
	author: Sygsky
	description: set sabotage stash (some kind of amoobox with different type of mines) in target town as the secondary target
	input: target_towns entry, e.g. [[9349,5893,0],   "Cayo"      ,210, 2]
	returns: nothing
*/
if ( typeName _this != "ARRAY" ) exitWith { hint localize format["--- SYG_sabotage_stash.sqf: array expected as input, found %1", _this] };

#include "x_setup.sqf"

_pos = [0,0,0];

// find position in house or in town itself
if ( random 10 <= 5 ) then { // find position in a house
	_list  = (_this select 0) nearObjects ["House", _this select 2];
	_house = _list call XfRandomArrayVal; // get random house
	_cnt   = _house call SYG_housePosCount; // count positions in this house
	_pos   = _house buildingPos ( floor ( random _cnt ) ); // get random position in the house to set the stash
	// small boxes for houses
#ifdef __OWN_SIDE_EAST__
	#ifdef __ACE__
	_box  = "ACE_AmmoBox_West";
	#endif
	#ifndef __ACE__
	_box  = "AmmoBoxWest";
	#endif
#endif
#ifdef __OWN_SIDE_WEST__
	#ifdef __ACE__
	_box  = "ACE_AmmoBox_East";
	#endif
	#ifndef __ACE__
	_box  = "AmmoBoxEast";
	#endif
#endif
} else { // find position in the town area
	_pos = [(_this select 0), (_this select 2)] call XfGetRanPointCircle;
	// big boxes for the open areas
	#ifdef __OWN_SIDE_EAST__
	_box  = "WeaponBoxWest";
	#endif
	#ifdef __OWN_SIDE_WEST__
	_box  = "WeaponBoxEast";
	#endif
};

// set box position and rotate it
_box =  createVehicle [ _box, _pos, [], 0, "NONE"];
_box setDir (random 360);

// clear content and fill new one

removeAllWeapons _box;

_box addMagazineCargo ["ACE_PipeBomb",10];
#ifdef __OWN_SIDE_EAST__
_box addMagazineCargo ["ACE_Mine",10];
#else
_box addMagazineCargo ["ACE_MineE",10];
#endif
#ifdef __ACE__
_box addMagazineCargo ["ACE_Claymore",10];
#endif

#ifndef __TT__
_box addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) == d_side_player) then {_sec_solved = "stash_down";};["sec_solved",_sec_solved,name (_this select 1)] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
#endif
#ifdef __TT__
_box addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) in [west,resistance]) then {_sec_solved = "stash_down";};["sec_solved",_sec_solved] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
_box addEventHandler ["killed", {[3,_this select 1] call XAddPoints;}];
#endif

