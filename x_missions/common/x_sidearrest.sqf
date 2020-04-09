// by Xeno, x_missions\common\x_sidearrest.sqf
private ["_is_dead","_leader","_nobjs","_officer","_offz_at_base","_rescued","_winner","_rescue","_grant","_sound","_player_cnt"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_officer = _this select 0;
_grant = _officer getVariable "GRANT";
_grant = !isNil "_grant";


_offz_at_base = false;
_is_dead = false;
_rescued = false;
_winner = 0;

#ifdef __RANKED__
d_sm_p_pos = nil;
#endif

while {!_offz_at_base && !_is_dead} do {
	if (X_MP) then {
	    if ((call XPlayersNumber) == 0 ) then
	    {
    		waitUntil {sleep (10.012 + random 1);(call XPlayersNumber) > 0};
	    }
	};
	
#ifndef __AI__
	
	if (!alive _officer) then {
		_is_dead = true;
	} else {
		if (!_rescued) then 
		{

			////////////////////////////////////////////++ Dupa by Engineer's request
			_nobjs = nearestObjects [_officer, ["CAManBase"], 20];
            {
                if ((isPlayer _x) && ((format ["%1", _x] in ["RESCUE","RESCUE2"]) || ((leader _x) == _x) ) ) exitWith {
                    _rescued = true;
                    _officer setCaptive true;
                    sleep 0.1;
                    [_officer] join grpNull; // stronger (possibly) remove action, as ordinal work good not all times
                    sleep 0.1;
                    [_officer] join (group _x);
                    ["make_ai_captive",_officer] call XSendNetStartScriptClient;
                    hint localize format["+++ x_sidearrest.sqf: nearest to officer EAST man is %1(%2), is leader = %3", _x, name _x, (leader _x) == _x];
                };
                sleep 0.01;
            } forEach _nobjs;
			////////////////////////////////////////////

		} 
		else 
		{
			if (!(__TTVer)) then 
			{
				if (_officer distance FLAG_BASE < 20) then {
					_offz_at_base = true;
				}
				else
				{
					// check if officer again is alone
					if ( (leader _officer) == _officer ) then
					{
						if ( (count units (group _officer)) > 1 ) then
						{
							[_officer] join grpNull; // move officer out of group
							sleep 0.01;
						};
						_officer setCaptive false;
						_officer addRating (2500 - (rating _officer)); // set high rating to prevent officer being killed by friendly AI
						_rescued = false;
						sleep 0.01;
					};
				};
			} 
			else 
			{
				if (_officer distance WFLAG_BASE < 20) then {
					_offz_at_base = true;
					_winner = 2;
				} else {
					if (_officer distance RFLAG_BASE < 20) then {
						_offz_at_base = true;
						_winner = 1;
					};
				};
			};
		};
	};
#else
	if (!alive _officer) exitWith { _is_dead = true; };

    if (!_rescued) then {
        _nobjs = nearestObjects [_officer, ["Man"], 20];
        if (count _nobjs == 0) exitWith{};
        _sound = "";
        _player_cnt = 0;
        {
            if ( isPlayer _x  ) then {
                _player_cnt = _player_cnt + 1;
                if (_x == leader _x) then {
                    _rescued = true;
                    [_officer] join (leader _x);
                    _officer setCaptive true;
                    ["make_ai_captive",_officer] call XSendNetStartScriptClientAll;
                    hint localize format["+++ x_sidearrest.sqf: nearest to officer player is %1(%2), is %3 leader", _x, name _x, (leader _x) == _x];
                };
            };
            sleep 0.01;
            if (_rescued) exitWith {};
        } forEach _nobjs;

        if (_player_cnt) then { // some player near
            if (_grant) then {
                if (_rescued) then {
                    switch (localize "STR_LANGUAGE" ) do
                    {
                        case "GERMAN": { _sound = "ger_grant_intro"};
                        case "ENGLISH";
                        default {
                            _sound = "eng_grant_intro";
                        };
                    };
                } else { // no leader near, officer not surrendered
                    // set sound
                    switch (localize "STR_LANGUAGE" ) do
                    {
                        case "GERMAN": { _sound = "ger_grant_surrend"};
                        case "ENGLISH";
                        default {
                            _sound = "eng_grant_surrend";
                        };
                    };
                };
            } else { // not Grant && any player near
                _sound = call SYG_exclamationSound;
            };
            // TODO: force officer to look at the nearest player
            if  (_sound != "") then { ["say_sound",_officer, _sound] call XSendNetStartScriptClientAll;}; // play sound
        };
    } else {
        if (_officer distance FLAG_BASE < 20) then {
            _offz_at_base = true;
        } else {
            // check if officer again is alone
            if ( (leader _officer) == _officer ) then
            {
                if ( (count units (group _officer)) > 1 ) then
                {
                    [_officer] join grpNull; // move officer out of group
                    sleep 0.01;
                };
                _officer setCaptive false;
                if ( (rating _officer) < 0) then { _officer addRating (2500 - (rating _officer)) }; // set high rating to prevent officer being killed by friendly AI
                _rescued = false;
                sleep 0.01;
            };
        };
    };
#endif
	sleep 5.621;
};

if (_is_dead) then {
	side_mission_winner = -500;
} else {
	if (_offz_at_base) then {
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
		sleep 2.123;
		if (vehicle _officer != _officer) then {
			_officer action ["eject", vehicle _officer];
			unassignVehicle _officer;
			_officer setPos [0,0,0];
		};
		sleep 0.5;
		_officer removeAllEventHandlers "killed";
		deleteVehicle _officer;
	};
};

side_mission_resolved = true;

if (true) exitWith {};
