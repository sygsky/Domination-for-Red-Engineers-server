/*
	scripts\intro\SYG_startOnAntigua.sqf: process arrival on Antigua while you not visited the base
	author: Sygsky
	description: none
	returns: nothing
*/

#include "x_setup.sqf"
#define __DEBUG__

_rects = [ // rectangles for boats to be available
[ [17170.4,18146.9,0], 120, 50, 12.8  ],
[ [17169.0,17860.3,0], 240, 50, 107.7 ],
[ [17241.5,17750.3,0], 160, 50, -36.75 ],
[ [17672.8,17830.5,0], 240, 50, 107.7 ]
];

// call as: _at_shore =  _boat call _is_near_shore;
_is_near_shore = {
	private ["_pos","_res","_x"];
	_pos = _this call SYG_getPos;
	_res = false;
	{
		if ([_pos, _x] call SYG_pointInRect  ) exitWith {_res = true};
	} forEach _rects;
	_res
};

// create point in the water near Antigus
_create_water_point_near_Antigua = {

};

_createAmmoBox = {
	if (!alive spawn_tent) exitWith  {
		hint localize "--- SYG_startOnAntigua: ammobox on Antigua not created as tent is dead";
	};
	_spawn_point = spawn_tent call SYG_housePosCount;
	_spawn_point = spawn_tent buildingPos ( floor (random _spawn_point) );

	#ifndef __TT__
    _boxname = (
    	switch (d_own_side) do {
    		case "RACS": {"AmmoBoxGuer"};
    		case "WEST": {"AmmoBoxWest"};
    		case "EAST": {if (__ACEVer) then {"ACE_WeaponBox_East"} else {"AmmoBoxEast"}};
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
    #endif

	_box = _boxname createVehicleLocal _spawn_point;
	_box setDir (random 360);
	_box setPos _spawn_point;
	_box call SYG_clearAmmoBox;

	{ // fill created items into the box at each client ( so Arma-1 need, only items added manually on clients during gameplay are propagated through network to all clients )
    	_cnt = 10 + floor (random 10);
    	_box addMagazineCargo [_x, _cnt];
    } forEach ["ACE_AK74","ACE_AKS74U","ACE_Bizon","ACE_AKM"];

    {
    	_box addMagazineCargo [_x, 100];
    } forEach ["ACE_30Rnd_545x39_BT_AK","ACE_30Rnd_545x39_SD_AK",
    		   "ACE_30Rnd_762x39_B_RPK","ACE_30Rnd_762x39_BT_AK","ACE_30Rnd_762x39_SD_AK","ACE_40Rnd_762x39_BT_AK","ACE_75Rnd_762x39_BT_AK"
    	       ,"ACE_64Rnd_9x18_B_Bizon"];
	hint localize "+++ scripts/intro/SYG_startOnAntigua.sqf: simple ammo box created"
};

call _createAmmoBox;
// 1. DC3 flight to the Antigua or simple drop from a plane