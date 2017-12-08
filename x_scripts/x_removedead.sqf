// by Xeno, x_scripts/x_removedead.sqf. Removes all dead object (men + vehicles) from the map one by one
private ["_element","_max_non_delete","_remove_dead_list","_tmp_array"];

#include "x_macros.sqf"

if (!isServer) exitWith{};

_remove_dead_list = [];
_tmp_array = [];
_max_non_delete = 30;

while {true} do {
	// add to the new units list
	if (X_MP) then {
		waitUntil {sleep (10.012 + random 1);(call XPlayersNumber) > 0};
	};
	__DEBUG_NET("x_removedead.sqf",(call XPlayersNumber))
	if (count dead_list > 0) then {
		_tmp_array = _tmp_array + dead_list;
		dead_list = [];
		if (count _tmp_array > _max_non_delete) then {
			_how_many = (count _tmp_array) - _max_non_delete;
			for "_oo" from 0 to (_how_many - 1) do {
				_element = _tmp_array select _oo;
				if (!(_element in _remove_dead_list)) then {
					_remove_dead_list = _remove_dead_list + [_element];
				};
				_tmp_array set [_oo, "X_RM_ME"];
				sleep 0.01;
			};
			_tmp_array = _tmp_array - ["X_RM_ME"];
			sleep 10.723;
			{
				if !(isNull _x) then {
						_x removealleventhandlers "killed";
						_x removealleventhandlers "hit";
						_x removealleventhandlers "damage"; //+++ Sygsky: just in case
						_x removealleventhandlers "getin"; //+++ Sygsky: just in case
						_x removealleventhandlers "getout"; //+++ Sygsky: just in case
						deletevehicle _x;
				};
				sleep 2.622;
			} foreach _remove_dead_list;
			
			_remove_dead_list = nil;
			sleep 2.878;
			_remove_dead_list = [];
		};
	};

	sleep 15.461;
};

if (true) exitWith {};
