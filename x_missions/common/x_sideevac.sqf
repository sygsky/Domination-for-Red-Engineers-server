// by Xeno, x_sideevac.sqf
private ["_pos_array", "_poss", "_endtime", "_side_crew", "_pilottype", "_wrecktype", "_wreck", "_owngroup",
         "_pilot1", "_owngroup2", "_pilot2", "_hideobject", "_is_dead", "_pilots_at_base", "_rescued", "_winner",
         "_time_over", "_enemy_created", "_nobjs", "_estart_pos", "_unit_array", "_ran", "_i", "_newgroup", "_units", "_leader",
         "_pilots_arr"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define WARN_INTERVAL (15 + (random 5))

_pos_array = _this select 0;
_poss = _pos_array select 0;
_endtime = _this select 1;

_side_crew = if (d_enemy_side == "EAST") then {"WEST"} else {"EAST"};
_pilottype = if (d_enemy_side == "EAST") then {d_pilot_W} else {d_pilot_E};
_wrecktype = if (d_enemy_side == "EAST") then {"BlackhawkWreck"} else {"Mi17"}; // no wreck on the east side, grrr

_wreck = _wrecktype createVehicle _poss;
_wreck lock true;
if (_wrecktype == "Mi17") then {_wreck setDamage 1.1}; // grrrr
_wreck setDir (random 360);
_wreck setPos _poss;

_wreck call SYG_addToExtraVec;
_wrecktype = nil;

sleep 2;

/*
__WaitForGroup
_owngroup = [_side_crew] call x_creategroup;
*/
_owngroup = call SYG_createOwnGroup;
_pilot1 = _owngroup createUnit [_pilottype, _poss, [], 30, "FORM"];
[_pilot1] join _owngroup;
_pilot1 setIdentity format["Rus%1", (floor (random 5)) + 1]; // there are only 5 russina voice in the ACE
sleep 0.5;
/**
__WaitForGroup
_owngroup2 = [_side_crew] call x_creategroup;
*/
_owngroup2 = call SYG_createOwnGroup;
_pilot2 = _owngroup2 createUnit [_pilottype, position _pilot1, [], 3, "FORM"];
[_pilot2] join _owngroup2;
_pilot2 setIdentity format["Rus%1", (floor (random 5)) + 1]; // there are only 5 russina voice in the ACE
sleep 0.1;

_pilots_arr = [_pilot1,_pilot2];

{
    _hideobject = _x findCover [position _x, position _x, 100];
    if (!isNull _hideobject) then {
        _x doMove (position _hideobject);
    };
} forEach _pilots_arr;

// enough time for the pilots to hide
sleep 45;

{
_x disableAI "MOVE";
_x setDamage 0.5;
_x setUnitPos "DOWN";
_x join _owngroup;
} forEach _pilots_arr;
//[_pilot2] join _owngroup;

sleep 0.5;
deleteGroup _owngroup2;
_owngroup2 = nil;

_is_dead = false;
_pilots_at_base = false;
_rescued = false;
_winner = 0;
_time_over = 3;
_enemy_created = false;

_soldier = (
	switch (d_own_side) do {
		case "EAST": {"SoldierEB"};
		case "WEST": {"SoldierWB"};
		case "RACS": {"SoldierGB"};
	}
);

_last_warn_said = 0;
while {(!_pilots_at_base) && (!_is_dead)} do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	};

	if (!alive _pilot1 && !alive _pilot2) exitWith {
		_is_dead = true;
	};

    if (!_rescued) then
    {
        ////////////////////////////////////////////++ Dupa by Engineer's request
        _rescue = objNull;
        _dist = 999999;
        {
            if ( alive _x) then
            {
                _nobjs = nearestObjects [_x, [_soldier], 20];
                _pilot = _x;
                {
                    if ((isPlayer _x) && ((format ["%1", _x] in ["RESCUE","RESCUE2"]) || (leader group _x == _x))) exitWith {
                        if ((_x distance _pilot) < _dist) then
                        {
                            _rescue = _x;
                            _dist = _x distance _pilot;
                        };
                    };
                    sleep 0.01;
                } forEach _nobjs;
            };
        } forEach _pilots_arr;
        ////////////////////////////////////////////

        if (_dist < 20) then
        {
            _rescued = true;
            {
              if (alive _x) then
              {
                _x setUnitPos "AUTO";
                _x enableAI "MOVE";
                [_x] join objNull;
                sleep 0.1;
                [_x] join (leader _rescue);
              };
            } forEach _pilots_arr;
            ["msg_to_user",name _rescue,[["STR_SYS_504_3"]], 2, 2] call XSendNetStartScriptClient; // "Good job! The rescue of helicopter crew was successful"
        };
              ////////////////////////////////////////////
    }
    else
    { // _rescued!!!

//++++++++++++++++++++++++ !__TTVer
        if (!(__TTVer)) then
        {
            {
                if (alive _x ) then
                {
                    if ( _x == leader (group _x) ) exitWith // check if pilot already is leader of the group, so rescuer must be dead
                    {
                        _rescued = false;
                        // again create separate group for our poor pilots
                        /**
                        __WaitForGroup
                        _owngroup = [_side_crew] call x_creategroup;
                        */
                        _owngroup = call SYG_createOwnGroup;
                        sleep 0.12345;
                        _pilots_arr join _owngroup;
                        { _x disableAI "MOVE"; _x setUnitPos "DOWN" }forEach _pilots_arr;
                        hint localize format["--- x_sideevac.sqf: as one of pilots (%1) is found to be group leader, so pilots are moved to its own group at %2",
                                             _x,  [_x, "%1 m. to %2 from %3"] call SYG_MsgOnPosE];
                        // TODO: send info to all about lost control of pilots
                    };
                    if ( vehicle _x != _x ) then    // pilot in some vehicle
                    {
                        if ([getPos _x,d_base_array] call SYG_pointInRect ) then // pilot  not so far from flag
                        {
                            if (time - _last_warn_said > WARN_INTERVAL) then
                            {
                                ["msg_to_user",vehicle _x,[["STR_SYS_504_1", name _x]]] call XSendNetStartScriptClient; // "% 1: - Get us out of the vehicle, commander!"
                                _last_warn_said = time;
                            };
                        };
                    }
                    else // pilot not  in vehicle (on ground)
                    {
                        if (_x distance FLAG_BASE < 20) then { _pilots_at_base = true; } // pilot near flag
                        else // not near flag
                        {
                             if ( ([getPos _x,d_base_array] call SYG_pointInRect) && (time - _last_warn_said > WARN_INTERVAL)) then
                             {
                                [ "msg_to_user", name _rescue,[["STR_SYS_504_2", name _x]] ] call XSendNetStartScriptClient; // "%1: - Need be closer to the flag, commander!"
                                 _last_warn_said = time;
                             };
                        };
                    };
                };
                if (_pilots_at_base || (!_rescued) ) exitWith{};
            } forEach _pilots_arr;
//++++++++++++++++++++++ __TTVer
        }
        else
        {
            {
                if (alive _x && (vehicle _x == _x)) then {
                    if (_x distance WFLAG_BASE < 20) then {
                        _pilots_at_base = true;
                        _winner = 2;
                    }else if (_x distance RFLAG_BASE < 20) then {
                        _pilots_at_base = true;
                        _winner = 1;
                    };
                };
                if (_pilots_at_base) exitWith{};
            } forEach _pilots_arr;
        };

    };

	sleep 5.621;
	if (_time_over > 0) then {
		if (_time_over == 3) then {
			if (_endtime - time <= 600) then {
				_time_over = 2;
				["d_hq_sm_msg", 0] call XSendNetStartScriptClient;
			};
		} else {
			if (_time_over == 2) then {
				if (_endtime - time <= 300) then {
					_time_over = 1;
					["d_hq_sm_msg", 1] call XSendNetStartScriptClient;
				};
			} else {
				if (_time_over == 1) then {
					if (_endtime - time <= 120) then {
						_time_over = 0;
						["d_hq_sm_msg",2] call XSendNetStartScriptClient;
					};
				};
			};
		};
	} else {
		if (!_enemy_created) then {
			_enemy_created = true;
			_estart_pos = [_poss,250] call XfGetRanPointCircleOuter;
			_unit_array = ["basic", d_enemy_side] call x_getunitliste;
			_ran = [3,5] call XfGetRandomRangeInt;
			for "_i" from 1 to _ran do {
			    /**
				__WaitForGroup
				_newgroup = [d_enemy_side] call x_creategroup;
				*/
                _newgroup = call SYG_createEnemyGroup;

				_units = [_estart_pos, (_unit_array select 0), _newgroup] call x_makemgroup;
				sleep 1.045;
				_leader = leader _newgroup;
				_leader setRank "LIEUTENANT";
				_newgroup allowFleeing 0;
				[_newgroup, _poss] call XAttackWP;
				extra_mission_remover_array = extra_mission_remover_array + _units;
				sleep 1.012;
			};
			_unit_array = nil;
		};
	};
};

if (_is_dead) then {
	side_mission_winner = -700;
} else {
	if (_pilots_at_base) then {
#ifdef __RANKED__
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
		if (_winner != 0) then {
			side_mission_winner = _winner;
		} else {
			side_mission_winner = 2;
		};
	};
};

sleep 2.123;

{
    if (alive _x) then {
        if (vehicle _x != _x) then {
            unassignVehicle _x;
            _x action ["eject", vehicle _x];
            sleep 0.5;
            _x setPos [0,0,0];
        };
    };
    sleep 0.1;
    deleteVehicle _x;
} forEach _pilots_arr;

side_mission_resolved = true;

if (true) exitWith {};
