// by Xeno, x_scripts/x_removedead.sqf. Removes all dead object (men + vehicles) from the map one by one
private ["_element","_max_non_delete","_remove_dead_list","_tmp_array","_tmp_array1"];

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
	//__DEBUG_NET("x_removedead.sqf",(call XPlayersNumber))
	if (count dead_list > 0) then {
	    // echange array with empty one
	    _tmp_array1 = dead_list;    // fast remove deads from one array to other
		dead_list = []; // empty dead list
		sleep 0.1; // now dead_list is guarantied to be switched to empty one
		[_tmp_array, _tmp_array1] call SYG_addArrayInPlace;
		_tmp_array1 = nil;
		if (count _tmp_array > _max_non_delete) then {
			_how_many = (count _tmp_array) - _max_non_delete;
			for "_oo" from 0 to (_how_many - 1) do {
				_element = _tmp_array select _oo;
				if (!(_element in _remove_dead_list)) then {
					_remove_dead_list set [count _remove_dead_list, _element];
				};
				_tmp_array set [_oo, "RM_ME"];
				sleep 0.01;
			};
			_tmp_array call SYG_clearArray;
			sleep 10.723;
			{
				if !(isNull _x) then {
						_x removeAllEventHandlers "killed";
						_x removeAllEventHandlers "hit";
						_x removeAllEventHandlers "dammaged";   //+++ Sygsky: just in case
						_x removeAllEventHandlers "getin";      //+++ Sygsky: just in case
						_x removeAllEventHandlers "getout";     //+++ Sygsky: just in case
						deleteVehicle _x;
				};
				sleep 2.622;
			} foreach _remove_dead_list;
			sleep 2.878;
			_remove_dead_list resize 0;
		};
	};

	sleep 15.461;
};

if (true) exitWith {};
