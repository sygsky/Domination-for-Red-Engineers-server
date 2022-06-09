/*
    x_missions/common/sideradar/radio_init.sqf
    created 2022.06.01
	author: Sygsky, on #410 request by Rokse

	description: handles object/vehicles for radar-on-hills SM type on the vehicle (radar or one of two trucks) init
	1. Add the radio SM trucks actions "Inspect", "Install", "Load"/"Unload".
	2. Add "killed" event handling to the first truck only, second one not need this as its death leads to the failure of the mission itself.
	3. For radar setVariable ["RADAR",true].

    params: [ _veh, _id ]

	changed:

	returns: nothing
*/
_veh = _this;
if (typeOf _veh  == "Land_radar") exitWith { // Radar itself
	if (alive _veh) then {
		_veh setVariable ["RADAR",true]; // set for each vehicle
		_veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf",0]; // Inspect
	};
};

if (_veh isKindOf "Truck" ) exitWith { // first truck, second is in reserve
	if (!alive d_radar) exitWith{};
	if (!alive _veh) exitWith {};
	_ids = [_veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf",1]]; // Inspect
	_veh setVariable ["RADAR",true]; // set for each vehicle
	if ( locked _veh ) exitWith {}; // vehcile locaked and cant be used any more

	_asl = getPosAsl d_radar;
	if ((_asl select 2) < 0 ) then {
		// radar is loaded to this truck
		_ids set [1,_veh addAction[localize "STR_UNLOAD","x_missions\common\sideradar\radio_menu.sqf","UNLOAD"]]; // unload
	} else  {
		// radar is not loaded in this truck
		_ids set [1,_veh addAction[localize "STR_LOAD","x_missions\common\sideradar\radio_menu.sqf","LOAD"]]; // load
		_ids set [2,_veh addAction[localize "STR_INSTALL","x_missions\common\sideradar\radio_menu.sqf","INSTALL"]]; // install
	};

	// ++++++++++++++++++++++++ KILLED EVENT ++++++++++++++++++++
	_veh addEventHandler ["killed",{
		if (!alive d_radar) exitWith {};
		_asl = getPosASL _veh;
		d_radar setPos _asl;
		_vehs = sideradio_info select 2;
		_veh1 = _vehs select 1;
		if (alive _veh1) then {
			_veh1 lock false;
			// "There's only one truck left. Take care of it, it's our last chance to complete the mission!"
			_veh1 addAction[localize "STR_LOAD","x_missions\common\sideradar\radio_menu.sqf","LOAD"]; // load
			_veh1 addAction[localize "STR_INSTALL","x_missions\common\sideradar\radio_menu.sqf","INSTALL"]; // install
			["msg_to_user", "",  [ ["STR_RADAR_TRUCK_UNLOCK"]], 0, 2, false, "message_received" ] call XSendNetStartScriptClientAll;
		} else {
			["msg_to_user", "",  [ ["STR_RADAR_TRUCK_FAILED"]], 0, 2, false, "losing_patience" ] call XSendNetStartScriptClientAll;
			d_radar setDamage 1.1;
		};
	}]; // unlock 2nd vehicle if alive

};
player groupChat format["--- radio_init.sqf: expected vehicle must by Truck of Land_radar. Found %3, exit ", typeOf _veh];