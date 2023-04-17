/*
	sea_patrol
	author: Sygsky
	description:
	support ships patrolling around all isles
	returns: nothing
*/


// _new patrol_group = [_type, _wp_arr] call _create_patrol
// _new_patrol: [_ship, _grp, _wp_arr]
_create_patrol = {


};

//
// [_ship, _grp] call _remove_patrol;
//
_remove_patrol = {

};

// [_ship, _group, _wp_arr] call _replace_patrol
_replace_patrol = {
	[_ship, _grp] call _remove_patrol;
	_arr = [_type, _wp_arr] call _create_patrol;
};

// fill all patrols from the scratch

_do_it = true;
while {_do_it} do {

	{
		_patrol = _x; // [_ship, _grp, _wp_arr]
		_ship = _x select 0;
		if (alive _ship) then {
			// ...
		} else {
			// ...
		};
	} forEach _patrol_arr;
};
