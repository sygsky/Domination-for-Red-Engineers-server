/*
	x_missions\common\sideradar\createTruck.sqf, called on server only
	author: Sygsky
	description: d_radar_trcuk must be not alive before call to this script
	returns: nothing
*/

if (!isServer) exitWith {"--- createTruck.sqf called not from server! Exit!"};

#include "sideradio_vars.sqf"

_pos = [];
_name = "";
if (typeName _this == "STRING") then {
	if ( (toUpper _this) == "BASE") then {
		_pos = [9452.5,9930.5,0];
		_name = "AirBase";
	};
};
_places = [
	[[8133,9084],   "Chantico", 205], // container parameters: [[X,Y],NAME, RADIUS]
	[[9170,8309],   "Somato",   200],
	[[10550,9375],  "Paraiso",  350],
	[[9758,8680],	"Yoro",		120],
	[[10151,8381],	"Pesto", 	60],
	[[11179,8839],	"Bonansa",	80],
	[[8080,9331],	"Balmopan",	70],
	[[8240,9562],	"Playa de Palomas",	50],
	[[9732,11026],	"Rashidan",	60],
	[[11502,9152],  "Corinto",  150]
];
// find good point for the truck
_MTName = call SYG_getTargetTownName; // name of the current town
while { count _pos == 0 } do {
	_ind = _places call XfRandomArrayVal; // find random settlement to use
	_info = _places select _ind;
	_center = _info select 0;
	_pname = _info select 1;
	if (_pname != _MTName) then { // not main target
		_pos = [_center, _info select 2, 5] call XfGetRanPointCircleBig; // find random point in the town to create the truck
		if (count _pos == 0) then {
			sleep 0.3;
		};
	};
};
if (count _pos == 0) exitWith {hint localize "--- createTruck: can't find good point!!!"};

#ifdef __ACE__
_ural = switch (d_own_side) do {
	case "EAST": {"UralCivil"};
	case "RACS";
	case "WEST": {"ACE_Truck5t_Open"};
};
#else
_ural = switch (d_own_side) do {
	case "EAST": {"UralCivil"};
	case "RACS";
	case "WEST": {"Truck5tOpen"};
};
#endif

d_radar_truck = createVehicle [_ural, _pos, [], 0, "NONE"];
if (_name != "AirBase") then {
	d_radar_truck setDir (random 360);
};
["say_sound", d_radar_truck,  call SYG_truckDoorCloseSound ] call XSendNetStartScriptClient;
publicVariable "d_radar_truck";
d_radar_truck setVehicleInit format ["this execVM ""x_missions\common\sideradar\radio_init.sqf"""];

// ++++++++++++++++++++++++ KILLED EVENT ++++++++++++++++++++
_veh addEventHandler ["killed", {
	hint localize format["+++ Radar truck killed by %1", if (isPlayer (_this select 1)) then{name (_this select 1)} else {typeof (_this select 1)}];
	private ["_veh","_asl","_pos","_msg","_cnt"];
	_veh = _this select 0;
	if (alive d_radar)  then  { // unload mast if truck is killed
		_asl = getPosASL d_radar;
		if ((_asl select 2) < 0) then {
			_pos = _veh modelToWorld [0, -DIST_MAST_TO_INSTALL, 0];
			d_radar setPos _pos;
			["say_sound", _veh, call SYG_rustyMastSound] call XSendNetStartScriptClientAll;
		};
	};

	_msg = [d_radar_truck, "%1 m. to %2 from %3", 50] call SYG_MsgOnPosE;
	hint localize format["+++ createTruck: truck created in ""%1"" (%2)", _name, _msg];

	// remove truck after 10 minutes of players absence around 300 meters of truck.
	_cnt = 0;
	while (!(isNull _veh)) do {
		sleep (60 + (random 60));
		_player =  [_pos, 100] call SYG_findNearestPlayer; // find any alive player in/out vehicles
		if ( !alive _player ) then {
			_cnt = _cnt + 1;
			if (_cnt > 5) exitWith { // 5 times with 90 seconds (on average) check if no players nearby
				_pos = getPos _veh;
				["say_sound", _pos, "steal"] call XSendNetStartScriptClient;
				deleteVehicle _veh;
			};
		} else {_cnt = 0;}; // wait next period for player absence
	};
}];
[ "msg_to_user", "",  [ ["STR_RADAR_TRUCK_INFO", _name]] ] call XSendNetStartScriptClient; // Look for the yellow truck in the '%1' area
