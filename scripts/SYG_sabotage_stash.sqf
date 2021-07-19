/*
	scripts\SYG_sabotage_stash.sqf
	author: Sygsky
	description: set sabotage stash (some kind of amoobox with different type of mines) in target town as the secondary target
	input: [[9349,5893,0], 210]
	returns: created ammo-box
*/
if ( typeName _this != "ARRAY" ) exitWith { hint localize format["--- SYG_sabotage_stash.sqf: array expected as input, found %1", _this]; objNull };

#include "x_setup.sqf"

#include "SYG_hotel_rooms.sqf"

private ["_house","_cnt","_ind","_pos","_spec"];

#define __DEBUG__

_pos = [];
_box = "";
_spec = "NONE";

// find position in house or in town itself
if ( (random 10) <= 5 ) then { // find position in a house
	_list  = (_this select 0) nearObjects ["House", _this select 1];
	if ( count _list == 0 ) exitWith { hint localize format["--- SYG_sabotage_stash.sqf: no houses in radius %1, find pos in empty areas", _this select 1] };
	_cnt = 0;
	while { _cnt == 0 } do {
		_house = _list call XfRandomArrayVal; // get random house
		_cnt   = _house call SYG_housePosCount; // count positions in this house
		if ( _cnt  > 1) then { // use houses with more than 1 positions
			_ind = floor ( random _cnt );
			if ( (typeOf _house) == "Land_Hotel" ) then { // prevent blind positions of the hotel rooms
				while { _ind in _no_list } do { _ind = floor ( random _cnt ); };
			};
			_pos   = _house buildingPos ( _ind ); // get random position in the house to set the stash
			if ( ( _pos select 2) < 0 ) then { _cnt = 0 }; // avoid negative Z values in position
		};
	};
	#ifdef __DEBUG__
	_str = format["+++ SYG_sabotage_stash.sqf: create STASH in the house %1, pos ind %2 %3", typeOf _house, _ind, _pos];
	hint localize _str;
	player groupChat _str;
	#endif
	_spec = "CAN_COLLIDE";
	// small boxes for houses
	_box_west =
	#ifdef __ACE__
		"ACE_AmmoBox_West";
	#else
		"AmmoBoxWest";
	#endif
	_box_east =
	#ifdef __ACE__
		"ACE_AmmoBox_East";
	#else
		"AmmoBoxEast";
	#endif
	#ifdef __OWN_SIDE_EAST__
	_box  = _box_west;
	#endif
	#ifdef __OWN_SIDE_WEST__
	_box  = _box_east;
	#endif
};

if (count _pos == 0 ) then { // find position in the town area

	#ifdef __DEBUG__
	_str = format["+++ SYG_sabotage_stash.sqf: create STASH outdoor at %1 with radius %2", (_this select 0), (_this select 1)];
	hint localize _str;
	player groupChat _str;
	#endif
	_spec = "NONE";
	_pos = [(_this select 0), (_this select 1)] call XfGetRanPointCircle;
	// big boxes for the open areas
	#ifdef __OWN_SIDE_EAST__
	_box  = "WeaponBoxWest";
	#endif
	#ifdef __OWN_SIDE_WEST__
	_box  = "WeaponBoxEast";
	#endif
};

// set box position and rotate it
#ifdef __DEBUG__
_str = format["+++ SYG_sabotage_stash.sqf: create STASH in %1 on pos %2", _box, _pos];
hint localize _str;
player groupChat _str;
#endif

_box =  createVehicle [ _box, _pos, [], 0, _spec ];
_box setPos _pos;
_box setDir (random 360);

// clear content and fill new one

clearMagazineCargo _box;
clearWeaponCargo _box;

_box addMagazineCargo ["ACE_PipeBomb",10 + floor (random 10)];
#ifdef __OWN_SIDE_EAST__
_box addMagazineCargo ["ACE_Mine",10 + floor (random 10)];
#else
_box addMagazineCargo ["ACE_MineE",10 + floor (random 10)];
#endif

#ifdef __ACE__
_box addMagazineCargo ["ACE_Claymore_M",10 + floor (random 10)];
#endif

#ifdef __TT__
_box addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) in [west,resistance]) then {_sec_solved = "stash_down";};["sec_solved",_sec_solved] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
_box addEventHandler ["killed", {[3,_this select 1] call XAddPoints;}];
#else
_box addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) == d_side_player) then {_sec_solved = "stash_down";};["sec_solved",_sec_solved,name (_this select 1)] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
#endif
hint localize format["+++ STASH of %1 created", typeOf _box];
_box

