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

_cone = (_this select 0);
hint localize format["+++ coneInfo.sqf: _this = %1", _cone];
_veh  = _cone getVariable "bonus_veh";
if (isNil "_veh") exitWith {
	// "Appropriate DOSAAF vehicle has not been found, this is a misunderstanding!"
	["msg_to_user","*",[[localize "STR_BONUS_INFO_1"]],0,0,"received"] call SYG_msgToUserParser;
	_cone say "losing_patience";
	sleep 1;
	deleteVehicle _cone;
};
_loc_name = _veh call SYG_nearestLocationName;
// "DOSAAF vehicle '%1' close to '%2'"
["msg_to_user","*",[[localize "STR_BONUS_INFO", typeOf _veh, _loc_name]],0,0,"good_news"] call SYG_msgToUserParser;
hint localize format["+++ coneInfo.sqf: veh %1 at %2, cone at %3", _veh, getPos _veh, getPos _cone];
