// by Xeno, x_scripts\x_playerammobox.sqf - player personal ammo box handling
#include "x_setup.sqf"
#include "x_macros.sqf"

private ["_box","_box_array"];

_box_array = [];

#ifndef __TT__
_boxname = (
	switch (d_own_side) do {
		case "RACS": {"AmmoBoxGuer"};
		case "WEST": {"AmmoBoxWest"};
//		case "EAST": {if (__ACEVer) then {"ACE_WeaponBox_East"} else {"AmmoBoxEast"}};
		case "EAST": {"AmmoBoxEast"};
	}
);
_box_array = d_player_ammobox_pos;
#endif

#ifdef __TT__
_boxname = (
	if (playerSide == west) then {
		"AmmoBoxWest"
	} else {
		"AmmoBoxGuer"
	}
);
if (playerSide == west) then {
	_box_array = d_player_ammobox_pos select 0;
} else {
	_box_array = d_player_ammobox_pos select 1;
};
#endif

#ifndef __BLUEFOR_AMMOBOX__
hint localize format["+++ x_playerammobox.sqf: _box_array = %1", _box_array];
_box = _boxname createVehicleLocal (_box_array select 0);
_box setDir (_box_array select 1);
_box setPos (_box_array select 0);
#endif

#ifdef __RANKED__
_box_script = (
		if (__CSLAVer) then {
			"x_scripts\x_weaponcargor_csla.sqf"
	} else {
		if (__ACEVer) then {
			"x_scripts\x_weaponcargor_ace.sqf"
		} else {
			if (__P85Ver) then {
				"x_scripts\x_weaponcargor_p85.sqf"
			} else {
				"x_scripts\x_weaponcargor.sqf"
			}
		}
	}
);
#else
_box_script = (
	if (__CSLAVer) then {
		"x_scripts\x_weaponcargo_csla.sqf"
	} else {
		if (__ACEVer) then {
			"x_scripts\x_weaponcargo_ace.sqf"
		} else {
			if (__P85Ver) then {
				"x_scripts\x_weaponcargo_p85.sqf"
			} else {
				"x_scripts\x_weaponcargo.sqf"
			}
		}
	}
);
#endif

#ifdef __BLUEFOR_AMMOBOX__

//+++++++++++++++++++++++
//   Fill EAST box first
//+++++++++++++++++++++++
_ammo_box = d_player_ammobox_pos select 0; // EAST
_ammo_box set [2, _boxname]; // set box type name
_ammo_box set [3, _box_script]; // set box script

_box = _boxname createVehicleLocal (_ammo_box select 0);
_box setDir (_ammo_box select 1);
_box setPos (_ammo_box select 0);
_ammo_box set [4, _box];        // Box instance
[_box] execVM _box_script;      // Run for EAST box

//++++++++++++++++++++++
//    Fill WEST box
//++++++++++++++++++++++
_ammo_box = d_player_ammobox_pos select 1; // WEST box array
_boxname = _ammo_box select 2; // get box type name
_ammo_box set [3, _box_script]; // Set box script for ranked

_box = _boxname createVehicleLocal (_ammo_box select 0);
_box setDir (_ammo_box select 1);
_box setPos (_ammo_box select 0);
_box setVectorDirAndUp[[0,0,1],[0,1,0]];
_ammo_box set [4, _box];        // Box instance

#endif

[_box] execVM _box_script; // Run for last box (may be single if not defined __BLUEFOR_AMMOBOX__)

#ifndef __BLUEFOR_AMMOBOX__
d_player_ammobox_pos = nil;
#endif

//+++++++++++++++++++++++++++++++++++++++++++++
// main thread to refresh personal ammobox[es]
//+++++++++++++++++++++++++++++++++++++++++++++
[_box,_boxname,_box_array, _box_script ] spawn {
	private ["_box", "_boxname", "_box_array","_box_script","_x"];

#ifndef __BLUEFOR_AMMOBOX__
	_box = _this select 0;
	_boxname = _this select 1;
	_box_array = _this select 2;
	_box_script = _this select 3;
#endif

    // Once in 25-30 minutes modify personal box content according to the rank of player
	while {true} do {
		sleep (1500 + random 300);

#ifndef __BLUEFOR_AMMOBOX__
		if (!isNull _box) then {deleteVehicle _box;};
		_box = _boxname createVehicleLocal (_box_array select 0);
		_box setDir (_box_array select 1);
		_box setPos (_box_array select 0);
		[_box] execVM _box_script;
#else
        {
            _box_array = _x;
            _box = _box_array select 4;
            if (!isNull _box) then {deleteVehicle _box;};
            _boxname = _box_array select 2;
            _box = _boxname createVehicleLocal (_box_array select 0);
            _box setDir (_box_array select 1);
            _box setPos (_box_array select 0);
            [_box] execVM (_box_array select 3);
            _box_array set [4, _box]; // Refresh box instance
        } forEach d_player_ammobox_pos;
#endif

	};
};

if (true) exitWith {};
