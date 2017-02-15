// by Xeno
private ["_grp", "_units"];
if (!isServer) exitWith {};

#include "x_macros.sqf"

sleep 60;
while {true} do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	};
	__DEBUG_NET("AI playercheck",(call XPlayersNumber))
	{
		call compile format ["
			if (!(isPlayer %1)) then {
				_grp = group %1;
				_units = units _grp;
				if (count _units > 0) then {
					{
						if (_x != %1) then {
							if (vehicle _x != _x) then {
								_x action [""eject"", vehicle _x];
								unassignVehicle _x;
								_x setPos [0,0,0];
							};
							sleep 0.01;
							deleteVehicle _x;
						};
					} forEach _units;
				};
				sleep 0.01;
			};
		", _x];
	} forEach d_player_entities;
	sleep 5.321;
};