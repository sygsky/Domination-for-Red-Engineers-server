// x_scripts/x_illum.sqf, by Xeno
private ["_trg_center","_radius","_center_x","_center_y", "_flare"];

if (!isServer) exitWith {};

#include "x_macros.sqf"

#define __FULL_LIGHT__

#ifdef __FULL_LIGHT__
#define MIN_FLARE_HEIGHT 30
#endif

_trg_center = _this select 0;
_radius = _this select 1;
_center_x = _trg_center select 0;_center_y = _trg_center select 1;

while {!mt_spotted} do {sleep 7.75};

_flares = [ "F_40mm_Yellow", "F_40mm_Red", "F_40mm_Green", "F_40mm_White" ];
while {d_run_illum} do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	};
	__DEBUG_NET("x_illum.sqf",(call XPlayersNumber))
	_flare = objNull;
	if (daytime > 19.75 || daytime < 4.25) then {
		_angle = floor (random 360);
		_x1 = _center_x - ((random _radius) * sin _angle);
		_y1 = _center_y - ((random _radius) * cos _angle);
		_flare = if (mt_radio_down ) then {"F_40mm_Red"}
		else
		{
            _flares select (( floor random 10 ) min 3);
		};
		_flare =  _flare createVehicle [_x1, _y1, 250];
#ifdef __FULL_LIGHT__
        while {true} do
        {
            if ( isNull _flare) exitWith {};
            if ( (getPos _flare) select 2 < MIN_FLARE_HEIGHT) exitWith{};
            sleep 1.123;
        };
#else
    	sleep 25 + random 30;
#endif
	    if (!isNull _flare) then {deleteVehicle _flare};
	}
	else {sleep 120}; // check night come every 2 minutes
};

if (true) exitWith {};
