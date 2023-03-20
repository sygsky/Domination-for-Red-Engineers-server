/*
	x_missions\common\sideradar\createRelayMast.sqf
	author: Sygsky
	description: none
	returns: nothing
*/

if (!isServer) exitWith {hint localize "--- createRelayMast.sqf called not from server! Exit!"};
hint localize format["+++ createRelayMast.sqf started, _this = %1 +++", _this];


#include "sideradio_vars.sqf"

_pos = [];
_name = "";
_base = false;
if (typeName _this == "STRING") then {
	if ( (toUpper _this) == "BASE") then { _base = true };
};
if (_base ) then {
	_pos = [9472.9,9930,0];
	_name = "AirBase";
} else {
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
		_info = _places call XfRandomArrayVal; // find settlement to use
		_center = _info select 0;
		_MTName = call SYG_getTargetTownName; // name of the current town
		_name = _info select 1;
    	if (_name != _MTName) then { // not main target
			_pos = [_center, _info select 2, 25] call XfGetRanPointCircleBig; // find the point in the town to create the radar
			if (count _pos == 0) then {
				if (_cnt >= 100) exitWith {
					hint localize "--- createRelayMast: can't find good point, use AirBase default point!!!";
					_pos = [9472.9,9930,0];
					_name = "AirBase";
					_base = true;
				};
				sleep 0.3;
				_cnt = _cnt +1;
			};
		};
	};
};

//+++++++++++++++++++++
// 1. create antenna on the base or in any near to base settlement
d_radar =  createVehicle [RADAR_TYPE, _pos, [], 0, "CAN_COLLIDE"];
publicVariable "d_radar";
d_radar setVehicleInit "this execVM ""x_missions\common\sideradar\radio_init.sqf""";

_pos = getPos d_radar;
d_radar setPos [_pos select 0, _pos select 1, -5.7 ];
// calculate random angle vector
if (_base) then {
	d_radar setVectorUp [1,0,0]
} else {
	_angle = random 360;
	d_radar setVectorUp [cos _angle,sin _angle,0]
};
d_radar addEventHandler ["killed", { _this execVM "x_missions\common\sideradar\radio_killed.sqf" } ]; // remove killed radar after some delay
["say_sound", d_radar, call SYG_rustyMastSound] call XSendNetStartScriptClient;
[ "msg_to_user", "",  [ ["STR_RADAR_MAST_INFO", _name]] ] call XSendNetStartScriptClient; // "Look for the blue truck in the '%1' area"

_msg = d_radar call SYG_MsgOnPosE0;
hint localize format["+++ createRelayMast: radar created at ""%1"" (%2)", _name, _msg]