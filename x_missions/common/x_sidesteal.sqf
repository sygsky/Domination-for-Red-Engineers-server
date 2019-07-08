// by Xeno
private ["_reached_base","_vehicle"];
if (!isServer) exitWith {};

#include "x_setup.sqf"

_vehicle = _this select 0;

sleep 10.213;

_reached_base = false;
#ifdef __TT__
_winner = 0;
#endif

while {alive _vehicle && !_reached_base} do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	};
#ifndef __TT__
	if (_vehicle distance FLAG_BASE < 100) then {
		_reached_base = true;
	};
#endif
#ifdef __TT__
	if (_vehicle distance WFLAG_BASE < 100) then {
		_reached_base = true;
		_winner = 2;
	} else {
		if (_vehicle distance RFLAG_BASE < 100) then {
			_reached_base = true;
			_winner = 1;
		};
	};
#endif
	sleep 5.2134;
};

if (alive _vehicle && _reached_base) then {

#ifdef __RANKED__
// send info about winners score prize added on the base flag vicinity
    if (!(__TTVer)) then {
        ["d_sm_p_pos", position FLAG_BASE] call XSendNetVarClient;
    } else {
        if (_winner == 1) then {
            ["d_sm_p_pos", position RFLAG_BASE] call XSendNetVarClient;
        } else {
            ["d_sm_p_pos", position WFLAG_BASE] call XSendNetVarClient;
        }
    };
#endif

#ifndef __TT__
	side_mission_winner = 2;
#endif
#ifdef __TT__
	side_mission_winner = _winner;
#endif
} else {
	side_mission_winner = -600;
};

side_mission_resolved = true;

if (true) exitWith {};
