/*
	scripts\SYG_sabotage_stash.sqf
	author: Sygsky
	description: set saboteur stash (some kind of amoobox with different type of mines) in target town as the secondary target
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
_ind = -1;

// find position in house or in town itself
if ( (random 10) <= 5 ) then { // find position in a house
	_list  = (_this select 0) nearObjects ["House", _this select 1];
	if ( count _list == 0 ) exitWith { hint localize format["--- SYG_sabotage_stash.sqf: no houses in radius %1 found, find pos in empty areas", _this select 1] };
	_cnt = 0;
	while { _cnt == 0 } do {
		_house = _list call XfRandomArrayVal; // get random house
		_cnt   = _house call SYG_housePosCount; // count positions in this house
		if ( _cnt  > 1) then { // use houses with more than 1 positions
			_ind = floor ( random _cnt );
			if ( (typeOf _house) == "Land_Hotel" ) then { // prevent blind positions in the hotel rooms
				while { _ind in _no_list } do { _ind = floor ( random _cnt ); };
			};
			_pos   = _house buildingPos ( _ind ); // get random position in the house to set the stash
			if ( ( _pos select 2) < 0 ) then { _cnt = 0 }; // avoid negative Z values in position
		};
	};
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

if ( count _pos == 0 ) then { // find position in the town area
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
_str = if (isNull _house) then {format["outdoor with radius %1",  (_this select 1)]} else {format["in %1 (at pos %2)",typeOf _house, _ind]};
_str = format["+++ SYG_sabotage_stash.sqf: create %1 STASH at %2 %3", _box, _pos, _str];
hint localize _str;
//player groupChat _str;
#endif

_box =  createVehicle [ _box, _pos, [], 0, _spec ];
_box setPos _pos;
_box setDir (random 360);

// clear content and fill new one

_box call SYG_clearAmmoBox;

_arr = [];
_str = "";
#ifdef __ACE__
	#ifdef __OWN_SIDE_EAST__
_mine = "ACE_MineE";
	#endif
	#ifdef __OWN_SIDE_WEST__
_mine = "ACE_Mine";
	#endif
_bomb = "ACE_PipeBomb";

_arr set [2, "ACE_Claymore_M"];
#else
_mine = "Mine";
_bomb = "PipeBomb";
#endif
_arr set [0, _mine];
_arr set [1, _bomb];

{ // fill created items into the box at each client ( so Arma-1 need, only items added manually on clients during gameplay are propagated through network to all clients )
	_cnt = 10 + floor (random 10);
	_box addMagazineCargo [_x, _cnt];
	_str = format["%1this addMagazineCargo [""%2"",%3];", _str, _x, _cnt];
} forEach _arr;

_box lock true;

_box call SYG_clearAmmoBox;
_box setVehicleInit ("this call SYG_clearAmmoBox;" + _str + "this lock true;");
processInitCommands;

#ifdef __TT__
_box addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) in [west,resistance]) then {_sec_solved = "stash_down";};["sec_solved",_sec_solved] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
_box addEventHandler ["killed", {[3,_this select 1] call XAddPoints;}];
#else
_box addEventHandler ["killed", {_sec_solved = "sec_over";side_main_done = true;if (side (_this select 1) == d_side_player) then {_sec_solved = "stash_down";};["sec_solved",_sec_solved,name (_this select 1)] call SYG_solvedMsg;_this spawn x_removevehiextra;}];
#endif
hint localize format["+++ STASH of %1 created %2", typeOf _box, [_box,"at %1 m to %2 from %3", 50] call SYG_MsgOnPosE];
_box

