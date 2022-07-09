/*
	x_missions\common\sideradar\createRelayMast.sqf
	author: Sygsky
	description: none
	returns: nothing
*/

#include "sideradio_vars.sqf"

_pos = [];
_name = "";
if (typeName _this == "STRING") then {
	if ( (toUpper _this) == "BASE") then {
		_pos = [9472.9,9930,0];
		_name = "BASE";
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
while { count _pos == 0 } do {
	_ind = _places call XfRandomArrayVal; // find settlement to use
	_info = _places select _ind;
	_center = _info select 0;
	_name = _info select 1;
	_pos = [_center, _info select 2, 25] call XfGetRanPointCircleBig; // find the point in the town to create the truck
	sleep 1;
};
if (count _pos == 0) exitWith {hint localize "--- createRelayMast: can't find good point!!!"};

//+++++++++++++++++++++
// 1. create antenna on the base or in any sttlement
d_radar =  createVehicle [RADAR_TYPE, _pos, [], 0, "CAN_COLLIDE"];
publicVariable "d_radar";
d_radar setVehicleInit "this execVM ""x_missions\common\sideradar\radio_init.sqf""";

_pos = getPos d_radar;
d_radar setPos [_pos select 0, _pos select 1, -5.7 ];
// calculate random angle vector
_angle = random 360;
d_radar setVectorUp [cos _angle,sin _angle,0];
d_radar addEventHandler ["killed", { _this execVM "x_missions\common\sideradar\radio_delete.sqf" } ]; // remove killed radar after some delay
["say_sound",d_radar, call SYG_rustyMastSound] call XSendNetStartScriptClient;
// processInitCommands; // called in radio_service.sqf

_msg = [d_radar,"%1 m. to %2 from %3",50] call SYG_MsgOnPosE;
hint localize format["+++ createRelayMast: radar created at ""%1"" (%2)", _name, _msg]