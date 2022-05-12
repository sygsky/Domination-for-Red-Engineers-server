// x_deleteunits.sqf by Xeno.
// Removes all alive enemy units only (men+vecs) in the range around town/airbase
// Procedure is as follows:
// 1. if all anemy dead, wait 240 seconds and start town clean proc
// 2. if during 300 seconds town is free of players, start town clean proc

if (!isServer) exitWith{};
//hint localize format["+++ x_deleteunits.sqf: _this  = %1", _this]; // debug printing
private ["_index", "_dummy", "_current_target_pos", "_current_target_rad", "_old_units_trigger", "_i", "_list","_plist",
         "_patrol","_town_name","_cnt","_cnt1","_x"];

//#define __DEBUG__

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// load list of all the units in the town at the start of the scropt
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_index = _this;
_old_units_trigger = "";
_town_name = "(???)";
if ( _index >= 0) then {
    _dummy = target_names select _index;
    _town_name = _dummy select 1;
//    hint localize format["+++ x_scripts/x_deleteunits.sqf: called in town""%1""", _dummy select 1];
    _current_target_pos = _dummy select 0;
    _old_units_trigger = createTrigger["EmptyDetector",_current_target_pos];
    _current_target_rad = (_dummy select 2) + 50; // search radious is TOWN_RAD+50
    _old_units_trigger setTriggerArea [_current_target_rad, _current_target_rad, 0, false]; // round shape trigger
} else {  // take of airfield completed (new action, before any town!!!)
    hint localize "+++ x_scripts/x_deleteunits.sqf: called on airbase taken event";
    _old_units_trigger = createTrigger["EmptyDetector",d_base_array select 0];
    _old_units_trigger setTriggerArea [(d_base_array select 1) + 100, (d_base_array select 2) + 100, d_base_array select 3, true]; // rect shape trigger
};
_old_units_trigger setTriggerActivation [d_enemy_side, "PRESENT", false]; // list only alive enemy side vehicles (with crew in it) and men
_old_units_trigger setTriggerStatements["this", "", ""];

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// wait until no players/enemy units in the town  during last 300 seconds
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_dummy = target_names select _index;
_town_name = _dummy select 1;
_current_target_pos = _dummy select 0;
_current_target_rad = (_dummy select 2) + 50; // search radious is TOWN_RAD+50
_time = time; // start of script time
if ( _index >= 0) then { // wait for absence of players/alive enemies in the town
    while {true} do {
        _cnt = 0; _cnt1 = 0;
        // check all enemy troops to be dead
#ifdef __OWN_SIDE_EAST__
        _list = _current_target_pos nearObjects ["SoldierWB", _current_target_rad + 50];
#else
        _list = _current_target_pos nearObjects ["SoldierEB", _current_target_rad + 50];
#endif
        _cnt1 = {canStand _x} count _list; // number of alive enemy units

        // check owners to be out during 300 seconds
        if (_cnt1 > 0 ) then  { // not all enemy are laying on the land, check for players absence in the town
            {
#ifdef __OWN_SIDE_EAST__
                _list = _current_target_pos nearObjects ["SoldierEB", _current_target_rad + 50];
#endif
#ifdef __OWN_SIDE_WEST__
                _list = _current_target_pos nearObjects ["SoldierWB", _current_target_rad + 50];
#endif
#ifdef __OWN_SIDE_RACS__
                _list = _current_target_pos nearObjects ["SoldierGB", _current_target_rad + 50];
#endif
                _cnt = _cnt +  ({(isPlayer _x) || (canStand _x)} count _list);
                sleep 60;
            } forEach [1,2,3,4,5];
        };

        if ( ( (_cnt1 * _cnt) ) == 0) exitWith {
            // all enemy dead or no players in town during 300 seconds period
            hint localize "+++ x_deleteunits.sqf: alive/canStand enemy and/or owner counters are ZERO, clean the town now!!!";
        };
    };
    hint localize format["+++ x_deleteunits.sqf: start units remove proc. in %1 after sleep during %2 secs.", _town_name, round (time- _time)];
};

sleep ( (240 - (time-_time)) max 0 ); // sleep 0 or delta between 240 and smaller delay due to all enemy dead

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// remove all found enemy units from the town
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

_plist = []; // town vehicle list
_veh_cnt = 0;
_man_cnt = 0;
_alive_man_cnt = 0;
for "_i" from 0 to 6 do {
	_list = [];
	{
		if (((position _x) select 2) < 20) then { // vehicle may be in air
		    // Check to be the captured vehicle
			if ( !isNil (_x getVariable "CAPTURED_ITEM") ) exitWith {  // vehicle is patrol one, don't remove it now
				if (_x in _plist) exitWith {}; // already verified
				_plist set [count _plist, _x]; // mark as verified
				hint localize format["+++ x_deleteunits.sqf: captured veh %1 (#%2, alive crew %3) in %4, not removed", typeOf _x, count _plist, {alive _x} count crew _x, _town_name];
			};
			// check to be in patrol list
			if ( !isNil (_x getVariable "PATROL_ITEM") ) exitWith {  // vehicle is patrol one, don't remove it now
				if (_x in _plist) exitWith {}; // already verified
				_plist set [count _plist, _x]; // mark as verified
				hint localize format["+++ x_deleteunits.sqf: patrol veh %1 (#%2, alive crew %3) in %4, not removed", typeOf _x, count _plist, {alive _x} count crew _x, _town_name];
			};
			if ( !(_x in _list) ) then { _list set [count _list,_x]; };
		};
		sleep 0.11;
	} forEach (list _old_units_trigger);
	sleep 0.12;
	{
		if (!(_x isKindOf "Man")) then { // vehicle, empty or filled in
			// patrol vehicles can't be in this list
			_man_cnt = _man_cnt + (count (crew _x));
			_veh_cnt = _veh_cnt + 1;
			{
				if (alive _x) then { _alive_man_cnt = _alive_man_cnt + 1; };
			 	deleteVehicle _x;
			} forEach (crew _x);
			deleteVehicle _x;
		} else {
			if ( isPlayer _x) exitWith {};
			if ( (vehicle _x) in _plist ) exitWith {}; // checks if man not in patrol vehicle
			if (alive _x) then { _alive_man_cnt = _alive_man_cnt + 1; };
			deleteVehicle _x; _man_cnt = _man_cnt + 1;
		};
		sleep 0.05;
	} forEach _list;
	sleep 1.021;
};
if (count _plist > 0 ) then {
	hint localize format["+++ x_deleteunits.sqf: %1 patrol/captured vehicles detected in %2 not removed", count _plist, _town_name];
};

hint localize format["+++ x_deleteunits.sqf: deleted men %1 (alive %2), vehicles %3 in %4", _man_cnt, _alive_man_cnt, _veh_cnt, _town_name ];

sleep 0.321;

deleteVehicle _old_units_trigger;

if (true) exitWith {};


