// x_missions/common/x_sideprisoners.sqf : by Xeno
private ["_posi_a", "_pos", "_newgroup", "_unit_array", "_leader", "_hostages_reached_dest", "_all_dead", "_rescued",
         "_units", "_winner", "_nobjs", "_retter", "_do_loop", "_i", "_one","_say_time","_sound"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

// #define __DEBUG_SM__  // if defined, no enemy will be created
#ifdef __DEBUG_SM__
hint localize "*** __DEBUG_SM__ is defined in x_missions\common\x_sideprisoners.sqf !!!";
#endif

_posi_a = _this select 0;
_pos = _posi_a select 0;
_patrol_dist = if ( count _this > 1) then {_this select 1} else {-1};

_posi_a = nil;

#ifdef __RANKED__
d_sm_p_pos = nil;
#endif

#define SAY_INTERVAL 7 // in seconds

_say_grp_sound = {
    if (_say_time > time) exitWith {};
    {
        _sound = call SYG_prisonersSound;
        if (alive _x && canStand _x) exitWith {
            ["say_sound", _x, _sound] call XSendNetStartScriptClientAll;
            _say_time = time + 2 + (random (SAY_INTERVAL * 2));
        };
    } forEach _units;
};

sleep 2;

while {!can_create_group} do {sleep (0.1 + random (0.2))};
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

#ifndef __DEBUG_SM__
sleep 2.333;
["specops", 2, "basic", 2, _pos, if (_patrol_dist > 0) then {_patrol_dist} else {200},true] spawn XCreateInf;
sleep 2.333;
["shilka", 2, "bmp", 1, "tank", 1, _pos,1,if (_patrol_dist > 0) then {_patrol_dist} else {170},true] spawn XCreateArmor;
#endif

sleep 32.123;

_hostages_reached_dest = false;
_all_dead = false;
_rescued = false;
_units =+ units _newgroup;

#ifdef __DEBUG_SM__
hint localize format["+++ x_sideprisoners.sqf: civilians created %1", count _units];
#endif

#ifdef __TT__
_winner = 0;
#endif

#ifndef __TT__
#ifdef __RANKED__
// Add "killed" event to each citizen to remove -5 on his killing
{
	if (alive _x) then {
		_x addEventHandler ["killed",
			{
				private ["_score","_killer"];
				_killer = _this select 1;
				if (! (isNull _killer)) then { // killer known
					if (isPlayer _killer) exitWith {
						_score = -(d_ranked_a select 24); // -5 for killing of sidemission civilian
						// "Soldier %1 killed a civilian from the current sidemission. The soldier is penalized for %2 points."
						[ "change_score", name _killer, _score, ["msg_to_user", [ ["STR_SM_HOSTAGES_1", name _killer, _score ] ], 0, 1, false, "losing_patience"] ] call XSendNetStartScriptClient;
						hint localize format["--- x_sideprisoners.sqf: hostage is killed by %1 (%2 player)", name _killer, if (alive _killer) then {"alive"} else {"dead"}];
					};
					hint localize format["--- x_sideprisoners.sqf: hostage is killed by %1 (%2, AI, %3)" ,
						name _killer,
						side _killer,
						if (alive _killer) then {"alive"} else {"dead"}];
				};
			}
		];
	};
} forEach _units;
#endif
#endif

_say_time = time + SAY_INTERVAL;

#ifndef __AI__
// NO AI enabled
while {!_hostages_reached_dest && !_all_dead} do {
    if (X_MP) then {
        if ((call XPlayersNumber) == 0) then {
            waitUntil { sleep (30.0123 + random 1);(call XPlayersNumber) > 0 };
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
					if ((isPlayer _x) && ((format ["%1", _x] in d_can_use_artillery) OR (leader group _x == _x))) exitWith {
						_rescued = true;
						_retter = _x;
						{
							if ( alive _x ) then {
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
// AI is enabled
_retter = objNull;

while {! (_hostages_reached_dest || _all_dead) } do {

	if (X_MP) then {
		_time = time;
		if ((call XPlayersNumber) == 0) then {
			_time = time;
			waitUntil {sleep (30 + random 1);(call XPlayersNumber) > 0};
			hint localize format["*** x_sideprisoners.sqf: players have been gone for %1", (time -_time) call SYG_timeDiffToStr];
		};
	};
	if (({alive _x} count _units) == 0) exitWith {
	    _all_dead = true;
        #ifdef __DEBUG_SM__
        hint localize format["+++ x_sideprisoners.sqf: all civilians dead, whole grp count %1", count _units];
        #endif
	};

    _leader = leader _newgroup;
    if (!_rescued) then {
        _nobjs = nearestObjects [_leader, ["Man"], 20];
        if (count _nobjs > 0) then {
            {
                if ( (isPlayer _x) && (_x == leader _x) && (alive _x) ) exitWith {
                    _rescued = true;
                    _retter = _x;
                    #ifdef __DEBUG_SM__
                     hint localize format["+++ x_sideprisoners.sqf: civilians resсued by %1", name _retter];
                    #endif
                    // Print locality of the hostages before assigning to the player group
                     hint localize format[ "+++ x_sideprisoners.sqf: civilian leader is%1 local to server just before resque", if (local _x) then {""} else {" not"} ];
                };
                sleep 0.01;
            } forEach _nobjs;
            if (_rescued && alive _retter) then {
                {
                    if ( alive _x ) then {
                        _x setCaptive false;
                        _x enableAI "MOVE";
                    };
                } forEach _units;
                _units join (leader _retter);
                call _say_grp_sound;
            };
        };
    } else { // they are rescued
        {
            if ( (alive _x) && (_x distance FLAG_BASE < 20) ) exitWith {
				// Units are not local to the server at this moment!
/*				{
					if (alive _x) exitWith {
						// Print locality of the hostages before assigning to the player group
						hint localize format[ "+++ x_sideprisoners.sqf: 1st of civilian units is%1 local to server just before sidemission finishing", if (local _x) then {""} else {" not"} ];
					};
				} forEach _units; */

                _hostages_reached_dest = true;
                if (__RankedVer) then {
                        ["d_sm_p_pos", position FLAG_BASE] call XSendNetVarClient;
                        //["x_weather_array",x_weather_array] call XSendNetVarClient;
                        // TODO: add to winners all players who were at this SM (use method from convoy algorithm)
                        #ifdef __DEBUG_SM__
                        hint localize format["+++ x_sideprisoners.sqf: [""d_sm_p_pos"", position FLAG_BASE] call XSendNetVarClient"];
                        #endif
                };

                #ifdef __DEBUG_SM__
                hint localize format["+++ x_sideprisoners.sqf: civilians reached FLAG_BASE"];
                #endif
            };
            sleep 0.01;
        } forEach _units;
        call _say_grp_sound;
    };
	sleep 5.123;
};
#endif

if (_all_dead) then {
	side_mission_winner = -400;
#ifdef __DEBUG_SM__
    hint localize format["+++ x_sideprisoners.sqf: side_mission_winner = -400; remove all civilians from mission"];
#endif

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
#ifdef __DEBUG_SM__
        hint localize format["+++ x_sideprisoners.sqf: side_mission_winner = %1; remove all civilians from mission",side_mission_winner ];
#endif

	} else {
#ifdef __DEBUG_SM__
        hint localize "--- x_sideprisoners.sqf: prisoners not dead and not resqued. All removed in any case!!!";
#endif
	};
	// remove prisoners in any case
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
};

_units = nil;

side_mission_resolved = true;
#ifdef __DEBUG_SM__
	hint localize format["+++ x_sideprisoners.sqf: SM resolved"];
#endif

if (true) exitWith {};
