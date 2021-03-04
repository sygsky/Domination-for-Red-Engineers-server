// x_deleteunits.sqf by Xeno.
// Removes all alive enemy units only (men+vecs) in the range around town/airbase
private ["_index", "_dummy", "_current_target_pos", "_current_target_rad", "_old_units_trigger", "_i", "_list","_plist","_patrol"];

if (!isServer) exitWith{};
//#define __DEBUG__

_index = _this;
_old_units_trigger = "";

if ( _index >= 0) then {
    _dummy = target_names select _index;
    _current_target_pos = _dummy select 0;
//    hint localize format ["x_scripts/x_deleteunits.sqf: on town ""%1"" clear event called",_dummy select 1];
    _old_units_trigger = createTrigger["EmptyDetector",_current_target_pos];
    _current_target_rad = (_dummy select 2) + 50; // search radious is TOWN_RAD+50
    _old_units_trigger setTriggerArea [_current_target_rad, _current_target_rad, 0, false]; // round shape trigger
} else {  // take of airfield completed (new action, before any town!!!)
    hint localize "x_scripts/x_deleteunits.sqf: called on airbase taken event";
    _old_units_trigger = createTrigger["EmptyDetector",d_base_array select 0];
    _old_units_trigger setTriggerArea [(d_base_array select 1) + 50, (d_base_array select 2) + 50, d_base_array select 3, true]; // rect shape trigger
};
_old_units_trigger setTriggerActivation [d_enemy_side, "PRESENT", false]; // list only enemy side vehicles (with crew in it)
_old_units_trigger setTriggerStatements["this", "", ""];

sleep 240; // wait 4 minutes before cleaning

_plist = []; // patrol vehicle list
for "_i" from 0 to 6 do {
	_list = [];
	{
		if (((position _x) select 2) < 20) then {
			_patrol = _x getVariable "PATROL_ITEM"; // check to be in patrol list
			if ( !isNil "_patrol" ) exitWith {  // vehicle is patrol one, don't remove it now
				if (_x in _plist) exitWith {}; // already verified
				_plist set [count _plist, _x]; // mark as verified
				hint localize format["*** x_deleteunits.sqf: patrol veh %1 (#%2, alive crew %3) in town, not removed", typeOf _x, count _plist, {alive _x} count crew _x];
			};
			if ( !(_x in _list) ) then { _list set [count _list,_x]; };
		};
		sleep 0.11;
	} forEach (list _old_units_trigger);
	sleep 0.12;
	{
		if (!(_x isKindOf "Man")) then {
			{deleteVehicle _x} forEach [_x] + crew _x;
		} else {
			if (!(isPlayer _x)) then {deleteVehicle _x;};
		};
		sleep 0.05;
	} forEach _list;
	sleep 1.021;
};
if (count _plist > 0 ) then {
	hint localize format["*** x_deleteunits.sqf: %1 patrol vehicles detected in town not removed", count _plist];
};
sleep 0.321;

deleteVehicle _old_units_trigger;

if (true) exitWith {};


