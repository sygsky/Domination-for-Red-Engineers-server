// by Xeno, x_scripts/x_delaiserv.sqf. Removes all AI groups without player from server lists
private ["_grp", "_units"];
if (!isServer) exitWith {};

#include "x_macros.sqf"

sleep 60;
while {true} do {
	if (X_MP) then {
		waitUntil {sleep (5.012 + random 1);(call XPlayersNumber) > 0};
	};
	//__DEBUG_NET("AI playercheck",(call XPlayersNumber))
	{
        _ap = compile _x; // player
        if (!(isPlayer _ap)) then {
            _grp = group _ap;
            _units = units _grp;
            if (count _units > 0) then {
                {
                    if (_x != _ap) then {
                        if (vehicle _x != _x) then {
                            _x action ["eject", vehicle _x];
                            unassignVehicle _x;
                            _x setPos [0,0,0];
                        };
                        sleep 0.05;
                        deleteVehicle _x;
                    };
                } forEach _units;
            };
            sleep 0.05;
        };
	} forEach d_player_entities; // for each available player
	sleep 5.321;
};