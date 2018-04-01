// by Xeno, x_scripts/x_checklocalvec.sqf. Time by time move all deleted vehicles to the common dead object list of the mission
private ["_check_vec_list", "_remove_from_list", "_zz", "_dead", "_hastime"];
if (!isServer) exitWith{};

#include "x_macros.sqf"

sleep 323.21;

_check_vec_list = [];
_remove_from_list = [];

while {true} do {
	if (X_MP) then {
		waitUntil {sleep (20 + random 1);(call XPlayersNumber) > 0};
	};
	//__DEBUG_NET("x_checklocalvec.sqf",(call XPlayersNumber))
	// add to the new units list
	if (count check_vec_list > 0) then {
	    _check_vec_list1 = check_vec_list;
		check_vec_list = [];
		sleep 0.1;
		_check_vec_list = _check_vec_list + _check_vec_list1;
		_check_vec_list1 = nil;
	};
	sleep 10.723;
	if ( count _check_vec_list > 0 ) then
	{
		for "_zz" from 0 to ((count _check_vec_list) - 1) do {
			_dead = _check_vec_list select _zz;
			
			if !(isNull _dead) then {
				_hastime = _dead getVariable "d_end_time";
				if (format["%1",_hastime] != "<null>") then {
					if (time > _hastime) then {
						if (({alive _x} count (crew _dead)) == 0) then {
							deleteVehicle _dead;_check_vec_list set [_zz, "X_RM_ME"]
						};
					};
				} else {
					if (!alive _dead) then
					{
					    {
					       deleteVehicle _x; // remove unit immediately from dead vehicle
					    } forEach crew _dead;
					    [_dead] call XAddDead;_check_vec_list set [_zz, "X_RM_ME"];
					};
				};
			};
			sleep 3.422;
		};
	};
	_check_vec_list = _check_vec_list - ["X_RM_ME"];
	sleep 19.461;
};
