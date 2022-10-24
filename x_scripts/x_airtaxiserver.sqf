// by Xeno, x_scripts/x_airtaxiserver.sqf, air taxi script on server
private ["_player", "_sidep", "_crew_member", "_sidestr", "_grp", "_vehicle", "_unit"];
if (!isServer) exitWith {};
#include "x_setup.sqf"
#include "x_macros.sqf"

_player = _this;
_sidep = side _player;

hint localize format["+++ AirTaxi called by %1 at %2", name _player, [player, "%1 m. to %2 from %3"] call SYG_MsgOnPosE];
_crew_member = (
	switch (_sidep) do {
		case east: {d_pilot_E};
		case west: {d_pilot_W};
		case resistance: {d_pilot_G};
	}
);

_sidestr = (
	switch (_sidep) do {
		case east: {"EAST"};
		case west: {"WEST"};
		case resistance: {"RACS"};
	}
);


_grp = call SYG_createGroup;
/*
__WaitForGroup
_grp = [_sidestr] call x_creategroup;
*/
_vehicle = createVehicle [x_drop_aircraft, position X_Drop_Start_Pos, [], 300, "FLY"];
_unit = _grp createUnit [_crew_member, position _vehicle, [], 0, "FORM"];
[_unit] join _grp;_unit setSkill 1;_unit assignAsDriver _vehicle;_unit moveInDriver _vehicle;
__addDead(_unit)
__addRemoveVehi(_vehicle)

_cleanOnFinish = {
	["d_ataxi", _this, _player] call XSendNetStartScriptClient;
	sleep 120;
	{deleteVehicle _x} forEach [_vehicle] + crew _vehicle;
	sleep 1;
	if (!isNull _unit) then {deleteVehicle _unit;};
};

[_vehicle, [position _player], 300, true] execVM "scripts\mando_heliroute_arma.sqf";

sleep 10;

if (!alive _player) exitWith { 1 call _cleanOnFinish; }; // remove vehicle in any case as the callin player is dead

["d_ataxi", 0,_player] call XSendNetStartScriptClient;

while {_vehicle getVariable "mando_heliroute" == "busy"} do {sleep 2.012};

if (_vehicle getVariable "mando_heliroute" == "damaged") exitWith { 2 call _cleanOnFinish; };

if (_vehicle getVariable "mando_heliroute" == "waiting") then {
	while {alive _player && !(_player in crew _vehicle)} do {sleep 1.012};
	if (alive _player) then {
		["d_ataxi", 3,_player] call XSendNetStartScriptClient;
		
		sleep 15 + random 5;
		[_vehicle, [position AISPAWN], 100, true] execVM "scripts\mando_heliroute_arma.sqf";
		sleep 5;
		while {_vehicle getVariable "mando_heliroute" == "busy"} do {sleep 2.012};
		if (_vehicle getVariable "mando_heliroute" == "damaged") exitWith { 2 call _cleanOnFinish; };
		if (_vehicle getVariable "mando_heliroute" == "waiting") then {
			while {_player in crew _vehicle} do {sleep 3.012};
			sleep 10;
			["d_ataxi", 4,_player] call XSendNetStartScriptClient;

			[_vehicle, [position X_Drop_Start_Pos], 100, false] execVM "scripts\mando_heliroute_arma.sqf";
			while {_vehicle getVariable "mando_heliroute" == "busy"} do {sleep 2.012};
			sleep 120;
			{deleteVehicle _x} forEach [_vehicle] + crew _vehicle;
			if (!isNull _unit) then {deleteVehicle _unit;};
		};
	} else {
	    1 call _cleanOnFinish;
    };
};

if (true) exitWith {};