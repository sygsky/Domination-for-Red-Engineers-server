// x_missions/common/x_sideprisoners.sqf : by Xeno
private ["_posi_a", "_pos", "_newgroup", "_unit_array", "_leader", "_hostages_reached_dest", "_all_dead", "_rescued", "_units", "_winner", "_nobjs", "_retter", "_do_loop", "_i", "_one"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_posi_a = _this select 0;
_pos = _posi_a select 0;
_patrol_dist = if ( count _this > 1) then {_this select 1} else {-1};

_posi_a = nil;

#ifdef __RANKED__
d_sm_p_pos = nil;
#endif

sleep 2;

__WaitForGroup
#ifndef __TT__
_newgroup = [d_own_side] call x_creategroup;
#endif
#ifdef __TT__
_newgroup = ["WEST"] call x_creategroup;
#endif
_unit_array = ["civilian", "CIV"] call x_getunitliste;
[_pos, (_unit_array select 0), _newgroup] call x_makemgroup;
_leader = leader _newgroup;
_leader setSkill 1;
_unit_array = nil;
sleep 2.0112;
_newgroup allowFleeing 0;
{
	removeAllWeapons _x;
	_x setCaptive true;
	_x disableAI "MOVE";
} forEach units _newgroup;

sleep 2.333;
["specops", 2, "basic", 2, _pos, if (_patrol_dist > 0) then {_patrol_dist} else {200},true] spawn XCreateInf;
sleep 2.333;
["shilka", 2, "bmp", 1, "tank", 1, _pos,1,if (_patrol_dist > 0) then {_patrol_dist} else {170},true] spawn XCreateArmor;

sleep 32.123;

_hostages_reached_dest = false;
_all_dead = false;
_rescued = false;
_units =+ units _newgroup;

#ifdef __TT__
_winner = 0;
#endif

#ifndef __AI__
while {!_hostages_reached_dest && !_all_dead} do {
    if (X_MP) then {
        if ((call XPlayersNumber) == 0) then
        {
            waitUntil { sleep (10.0123 + random 1);(call XPlayersNumber) > 0 };
        };
    };
	if (({alive _x} count _units) == 0) then {
		_all_dead = true;
	} else {
		if (!_rescued) then {
			_leader = leader _newgroup;
			_nobjs = nearestObjects [_leader, ["Man"], 15];
			if (count _nobjs > 0) then {
				{
					if ((isPlayer _x) AND ((format ["%1", _x] in ["RESCUE","RESCUE2"]) OR (leader group _x == _x))) exitWith {
						_rescued = true;
						_retter = _x;
						{
							if (!(isNull _x) && alive _x) then {
								_x setCaptive false;
								_x enableAI "MOVE";
							};
						} forEach _units;
						_units join (leader _retter);
					};
					sleep 0.01;
				} forEach _nobjs;
			};
		} else {
			_i = 0;
			while {(!_hostages_reached_dest) && (_i < count _units)} do {
				_one = _units select _i;
				if (!(isNull _one) && (alive _one)) then {
					if (!(__TTVer)) then {
						if (_one distance FLAG_BASE < 20) then {
							_hostages_reached_dest = true;
						};
					} else {
						if (_one distance WFLAG_BASE < 20) then {
							_hostages_reached_dest = true;

							_winner = 2;
						} else {
							if (_one distance RFLAG_BASE < 20) then {
								_hostages_reached_dest = true;
								_winner = 1;
							};
						};
					};
				};
				_i = _i +1;
			};
		};
	};
	if (__RankedVer) then {
		if (_hostages_reached_dest) then {
			if (!(__TTVer)) then {
				["d_sm_p_pos", position FLAG_BASE] call XSendNetVarClient;
			} else {
				switch (_winner) do {
					case 1: {["d_sm_p_pos", position RFLAG_BASE] call XSendNetVarClient;};
					case 2: {["d_sm_p_pos", position WFLAG_BASE] call XSendNetVarClient;};
				};
			};
		};
	};
	sleep 5.123;
};
#else
_retter = objNull;

while {!_hostages_reached_dest && !_all_dead} do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	};
	if (({alive _x} count _units) == 0) exitWith { _all_dead = true; };

    _leader = leader _newgroup;
    if (!_rescued) then {
        _nobjs = nearestObjects [_leader, ["Man"], 20];
        if (count _nobjs > 0) then {
            {
                if (isPlayer _x) exitWith {
                    _rescued = true;
                    _retter = _x;
                };
                sleep 0.01;
            } forEach _nobjs;
            if (_rescued && !isNull _retter) then {
                {
                    if ( alive _x ) then {
                        _x setCaptive false;
                        _x enableAI "MOVE";
                    };
                } forEach _units;
                _units join (leader _retter);
            };
        };
    } else {
        {
            if ( (alive _x) && (_x distance FLAG_BASE < 20) ) exitWith {
                _hostages_reached_dest = true;
            };
            sleep 0.01;
        } forEach _units;
    };
	if (__RankedVer) then {
		if (_hostages_reached_dest) then {
			["d_sm_p_pos", position FLAG_BASE] call XSendNetVarClient;
		};
	};
	sleep 5.123;
};
#endif

if (_all_dead) then {
	side_mission_winner = -400;
	sleep 2.123;
	{
		if (!isNull _x) then {
			if (vehicle _x != _x) then {
				_x action ["eject", vehicle _x];
				unassignVehicle _x;
				_x setPos [0,0,0];
			};
			deleteVehicle _x;
		};
	} forEach _units;
	sleep 0.5321;
	if (!isNull _newgroup) then {deleteGroup _newgroup};
} else {
	if (_hostages_reached_dest) then {
		if (({alive _x} count _units) >= 1) then {
#ifndef __TT__
			side_mission_winner = 2;
#endif
#ifdef __TT__
			side_mission_winner = _winner;
#endif
		} else {
			side_mission_winner = -400;
		};
		sleep 2.123;
		{
			if (!isNull _x) then {
				if (vehicle _x != _x) then {
					_x action ["eject", vehicle _x];
					unassignVehicle _x;
					_x setPos [0,0,0];
				};
				deleteVehicle _x;
			};
		} forEach _units;
		sleep 2.5321;
		if (!isNull _newgroup) then {deleteGroup _newgroup};
	};
};

_units = nil;

side_mission_resolved = true;

if (true) exitWith {};
