/*
	x_missions\common\sideradar\createTruck.sqf, called on server only
	author: Sygsky
	description: d_radar_truck must be not alive before call to this script
	returns: nothing
*/

if (!isServer) exitWith {hint localize "--- createTruck.sqf called not from server! Exit!"};
hint localize format["+++ createTruck.sqf started, _this = ""%1""", _this];
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
_cnt = 0;
while { count _pos == 0 } do {
	_info = _places call XfRandomArrayVal; // find random settlement to use
	_center = _info select 0;
	_MTName = call SYG_getTargetTownName; // name of the current town
	_name = _info select 1;
	if (_name != _MTName) then { // not main target
		_pos = [_center, _info select 2, 5] call XfGetRanPointCircleBig; // find random point in the town to create the truck
		if (count _pos == 0) then {
			if (_cnt  >= 100) exitWith {
				_pos = [9452.5,9930.5,0];
				_name = "AirBase";
				hint localize "--- createTruck: can't find good point among designated towns, use ""AirBase"" as default!";
			};
			_cnt = _cnt + 1;
			sleep 0.3;
		};
	};
};

_ural = "UralCivil2"; // Blue truck "Camionaje Juares Puerto del Dolores"

d_radar_truck = createVehicle [_ural, _pos, [], 0, "NONE"];
if (_name != "AirBase") then {
	d_radar_truck setDir (random 360);
};
d_radar_truck lock true;
["say_sound", d_radar_truck,  call SYG_truckDoorCloseSound ] call XSendNetStartScriptClient;
publicVariable "d_radar_truck";
d_radar_truck setVehicleInit format ["this execVM ""x_missions\common\sideradar\radio_init.sqf"""];

_msg = [d_radar_truck, 50] call SYG_MsgOnPosE0;
hint localize format["+++ createTruck: truck created in ""%1"" (%2)", _name, _msg];
[ "msg_to_user", "",  [ ["STR_RADAR_TRUCK_INFO", _name]] ] call XSendNetStartScriptClient; // "Look for the blue truck in the '%1' area"


// ++++++++++++++++++++++++ KILLED EVENT ++++++++++++++++++++
d_radar_truck addEventHandler ["killed", { _this execVM "x_missions\common\sideradar\truck_killed.sqf" }]; // _this = [_killed, _killer];