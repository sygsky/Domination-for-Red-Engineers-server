/*
	author: Sygsky
	description:
		Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
		target (_this select 0): Object - the object which the action is assigned to
		caller (_this select 1): Object - the unit that activated the action
		ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
		arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
	returns: nothing
*/

#include "bonus_def.sqf"

_cone = (_this select 0);
hint localize format["+++ coneInfo.sqf: _this = %1", _cone];
_veh  = _cone getVariable "bonus_veh";
if (isNil "_veh") exitWith {
	// "Appropriate DOSAAF vehicle has not been found, this is a misunderstanding!"
	["msg_to_user","*",[[localize "STR_BONUS_INFO_1"]],0,0,false,"message_received"] call SYG_msgToUserParser;
	_cone say "losing_patience";
	sleep 1;
	deleteVehicle _cone;
};
_loc_name = _veh call SYG_nearestLocationName;
_dist = round (_veh distance DOSAAF_MAP_POS);
_slope = [0,0,1] distance ( vectorUp _cone );
sleep 0.1;
_str_dist = if (_dist == 0) then {localize "STR_BONUS_INFO_2"} else {format[localize "STR_BONUS_INFO_3", _dist]};
["msg_to_user","*",[[localize "STR_BONUS_INFO", typeOf _veh, _loc_name, _str_dist]],0,0,false,"good_news"] call SYG_msgToUserParser; // "DOSAAF vehicle '%1' close to '%2'", dist %3
if ( _slope < 0.2 )  exitWith{};

_cone setVectorUp [0,0,1];
_pos = getPos _veh;
DOSAAF_MAP_POS; // central point of the map
_xn = DOSAAF_MAP_POS select 0; _yn = DOSAAF_MAP_POS select 1;
_new_pos  = [ _xn + (((_pos select 0) - _xn) * DOSAAF_MAP_SCALE), _yn + (((_pos select 1) - _yn) * DOSAAF_MAP_SCALE), 0 ];
_cone setVehiclePosition  [ _new_pos, [], 0, "CAN_COLLIDE" ];

hint localize format["+++ coneInfo.sqf: veh %1 at %2, cone at %3", _veh, getPos _veh, getPos _cone];
