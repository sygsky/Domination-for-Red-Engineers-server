// by Xeno, x_scripts\x_civs.sqf - to create civilians service

if (!isServer) exitWith {};

sleep 2.012 + (random 10);

x_check_for_ground = {
	private ["_list","_ret"];_list = _this;_ret = false;{if (position _x select 2 < 2) exitWith {_ret = true};} forEach _list;_ret
};

for "_i" from 0 to (count target_names - 1) do {
	call compile format ["x_civs_array_%1 = [];", _i];
	_target = target_names select _i;
	_trigger = createTrigger["EmptyDetector",_target select 0];
	_trigger setTriggerArea [800, 800, 0, false];
	_trigger setTriggerActivation [d_own_side_trigger, "PRESENT", true];
	call compile format ["_trigger setTriggerStatements['thislist call x_check_for_ground', 'xhandle = [%1, thislist] execVM ''x_scripts\x_createcivs.sqf'';', 'xhandle = [%1] execVM ''x_scripts\x_removecivs.sqf'';'];", _i];
	sleep 0.501;
};

if (true) exitWith {};
