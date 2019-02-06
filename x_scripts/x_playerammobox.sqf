// by Xeno, x_scripts\x_playerammobox.sqf - player personal ammo box handling
private ["_box","_box_array"];

#include "x_setup.sqf"
#include "x_macros.sqf"

_box_array = [];

#ifndef __TT__
_boxname = (
	switch (d_own_side) do {
		case "RACS": {"AmmoBoxGuer"};
		case "WEST": {"AmmoBoxWest"};
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

_box = _boxname createVehicleLocal (_box_array select 0);
_box setDir (_box_array select 1);
_box setPos (_box_array select 0);

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
[_box] execVM _box_script;

d_player_ammobox_pos = nil;

[_box,_boxname,_box_array] spawn {
	private ["_box", "_boxname", "_box_array"];
	_box = _this select 0;
	_boxname = _this select 1;
	_box_array = _this select 2;
	while {true} do {
		sleep 1500 + random 500;
		if (!isNull _box) then {deleteVehicle _box;};
		_box = _boxname createVehicleLocal (_box_array select 0);
		_box setDir (_box_array select 1);
		_box setPos (_box_array select 0);
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
		[_box] execVM _box_script;
	};
};

if (true) exitWith {};
