// by Xeno, x_scripts/x_checklocalvec.sqf.
// Time by time move all deleted vehicles to the common dead object list of the mission.
// Also checks and process "d_end_time" variable on dead vehicles
if (!isServer) exitWith{};

#include "x_setup.sqf"
#include "x_macros.sqf"
private ["_check_vec_list", "_zz", "_dead", "_hastime"];

//#define __PRINT_STAT__

sleep 323.21;

_check_vec_list = [];

#ifdef __PRINT_STAT__
#define __PRINT_INTERVAL__ 600 // 10 minutes
_time_to_print = time + __PRINT_INTERVAL__;
#endif

while {true} do {
	if (X_MP) then {
		waitUntil {sleep (20 + random 1);(call XPlayersNumber) > 0};
	};
	//__DEBUG_NET("x_checklocalvec.sqf",(call XPlayersNumber))
	// add to the new units list
	if (count check_vec_list > 0) then {
	    _check_vec_list1 = check_vec_list; // rename list
		check_vec_list = []; // set empty
		sleep 0.1;
		_check_vec_list = _check_vec_list + _check_vec_list1;
		_check_vec_list1 = nil;
	};
	sleep 10.723;
	_cnt = count _check_vec_list;
	if ( _cnt > 0 ) then {
		for "_zz" from 0 to (_cnt - 1) do {
			_dead = _check_vec_list select _zz;
			
			if !(isNull _dead) then {
				_hastime = _dead getVariable "d_end_time";
				if (format["%1",_hastime] != "<null>") exitWith {
					if (time > _hastime) then {
						if (({alive _x} count (crew _dead)) == 0) then {
							deleteVehicle _dead;_check_vec_list set [_zz, "RM_ME"]
						};
					};
				};
                if (alive _dead) exitWith {};
#ifdef __BATTLEFIELD_BONUS__
				_recoverable = _dead getVariable "RECOVERABLE";
				if (isNil "_recoverable") then {_recoverable = false};
				if (!_recoverable) then {
#endif
					{ deleteVehicle _x; } forEach crew _dead;  // remove all units immediately from vehicle crew group
					[_dead] call XAddDead;
#ifdef __BATTLEFIELD_BONUS__
				};
#endif
				_check_vec_list set [_zz, "RM_ME"]; // remove vehicle from this dead list
				sleep 10;
			};
			sleep 3.422;
		};
	};
	_check_vec_list call  SYG_cleanArray;
	sleep 30.461;

#ifdef __PRINT_STAT__
// TODO: use method SYG_utilsText->SYG_objArrToTypeStr except lower code
    if (time >_time_to_print) then  {
        _print_cnt = (count _check_vec_list) max 5; // print vehicles count
        if (  _print_cnt > 0 ) then { // print only if there is some data to print
            _str = "";
            for "_i" from 0 to _print_cnt - 1 do {
                if (_str == "") then  {_str = format["%1", typeOf (_check_vec_list select _i)];}
                else {_str = format["%1,%2",_str, typeOf (_check_vec_list select _i)]};
            };
            _suffix = if ((count _check_vec_list) > _print_cnt) then {",..."} else {""};
            hint localize format["+++ INFO: vehicles in check list %1 -> [%2]", count _check_vec_list, _str];
        };
        _time_to_print = time + __PRINT_INTERVAL__;
    };
#endif

};
