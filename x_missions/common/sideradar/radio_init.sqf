/*
    x_missions/common/sideradar/radio_init.sqf
    created 2022.06.01
	author: Sygsky, on #410 request by Rokse

	description: handles object/vehicles for radar-on-hills SM type
	1. Add the radio SM trucks actions "Inspect", "Install", "Load"/"Unload".
	2. Add "killed" event handling to the first truck only, second one not need this as its death leads to the failure of the mission itself.
	3. For radar setVariable ["RADAR",true].

    params: [ _veh, _id ]

	changed:

	returns: nothing
*/
_veh = _this select 0;
_id  = _this select 1;
if (_id == 0) exitWith { // Radar itself
	_veh setVariable ["RADAR",true]; // set for each vehicle
	_veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf",0]; // Inspect

};
if (_id == 1) exitWith { // first truck
	_veh setVariable ["RADAR",true]; // set for each vehicle
	_veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf",1]; // Inspect
	_veh addAction[localize "STR_UNLOAD",{}]; // Unload
	_veh addAction[localize "STR_LOAD",{}]; // Load
	_veh addEventHandler ["killed",{}]; // unlock 2nd vehicle if alive
};
if (_id == 2) exitWith { // second truck
	_veh setVariable ["RADAR",true]; // set for each vehicle
	_veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf",2]; // Inspect
	_veh addAction[localize "STR_UNLOAD",{}]; // Unload
	_veh addAction[localize "STR_LOAD",{}]; // Load

};
player groupChat format["--- radio_init.sqf: expected _id must by 0, 1 or 2. Found %3, exit ", _id];