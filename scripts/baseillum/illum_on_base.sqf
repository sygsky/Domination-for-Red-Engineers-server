/*
        NOT USED!!!

    scripts\baseillum\illum_on_base.sqf

	author: Sygsky, 14-MAY-2020
	description: produce illumination over base at night
	_this = [_player]
	returns: nothing
*/

if (!isServer) exitWith{}; // only for server

#include "x_setup.sqf"
#include "x_macros.sqf"

#define FLARE_TYPE "ACE_Flare_40mm_White"
#define FLARE_NUM 7
#define FLARE_ALT_START 450                 // altitude to create flare
#define FLARE_ALT_END 20                    // altitude of flare to start next one
#define FLARE_NIGHT_COST_PER_RANK 10        // how many per rank index (private == 1) costs base illumination during whole night


if (typeName _this != "ARRAY") then {_this = [_this]};
if (count _this ==0) exitWith {hint localize format["--- illum_on_base.sqf: illegal start parameters _this = %1", _this]};
if ( !( typeOf ( _this select 0 ) == "STRING" ) ) exitWith { hint localize format[ "--- illum_on_base.sqf: expected parameter is player name string, detected ""%1""", typeof (_this select 0) ] };
_this = _this select 0;
if (!isNil "SYG_illum_customer") exitWith  {
    // send info to player about already started illumination.
    ["msg_to_user", _this,  [ ["STR_ILLUM_5", SYG_illum_customer]], 0, 2, false, "losing_patience" ] call XSendNetStartScriptClient; // "The night illumination already started by '%1'"
};
SYG_illum_customer = _this; // store name of illum starter
// 0 for night, 1 for day, 2 for morning and 3 for evening
if (call SYG_getDayTimeId != 0 ) then {
    // wait for the next night
    sleep SYG_startNight - daytime;
    // TODO: inform user about
};
// TODO: send info about start of illumination over base

// TODO: fire illumination flare one by one up to the end of night

private ["_pos", "_flares", "_flare"];

#ifndef __TT__
_pos = getPos FLAG_BASE;
#else
_pos = getPos (if (d_own_side == "WEST") then { WFLAG_BASE } else { RFLAG_BASE  });
#endif
_pos set [2, FLARE_ALT_START];

_flares = [];
for "_i" from 1 to FLARE_NUM do {
    _flares set [count _flares,  objNull];
    sleep 0.025;
};

// loop for flares whole night
_flare = objNull;
while { (time > SYG_startNight) || (time < SYG_startMorning) } do
{
    // create new flares
    for "_i" from 0 to count _flares - 1 do {
         _flare = _flares select _i;
        if (!isNull _flare) then {deleteVehicle _flare; sleep 0.025};
        _flare = FLARE_TYPE createVehicle _pos;
        _flares set [_i,  _flare ];
    };
    while ( (!isNull _flare) || (getPos _flare) select 2 > FLARE_ALT_END) do {sleep 0.5};
};

{ if (!isNull _x) then {deleteVehicle _x}; } forEach _flares;
_flares = [];

// allow next illumination to be run
SYG_illum_customer = nil;
