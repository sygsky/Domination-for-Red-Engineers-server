// by Xeno
private ["_points_array"];

if (!isServer) exitWith {};

#include "x_macros.sqf"

while {true} do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	};
	__DEBUG_NET("TT points send.sqf",(call XPlayersNumber))
	if (public_points) then {
		_points_array = [points_west,points_racs,kill_points_west,kill_points_racs];
		["points_array",_points_array] call XSendNetStartScriptClient;
	};
	sleep 1.516;
};