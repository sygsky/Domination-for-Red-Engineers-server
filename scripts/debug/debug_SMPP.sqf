/*
	debug_SMPP.sqf
	author: Sygsky
	description: none
	returns: nothing
*/

if (typeName (_this select 0) == "STRING") exitWith {
	// on server it is command: _this execVM "scripts\debug\debug_SMPP.sqf"
	hint localize format["+++ server debug_SMPP.sqf: _this %1, SYG_getVehSPPMMarker = %2", _this, typeName SYG_getVehSPPMMarker];
	_veh = _this select 2;
	_str = _veh call SYG_getVehSPPMMarker;
	hint localize format["+++ server debug_SMPP.sqf: %1 call SYG_getVehSPPMMarker => ""%2""", typeOf _veh, _str];
};
// client, so this is action called by menu on vehicle
//    Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
//    target (_this select 0): Object - the object which the action is assigned to
//    caller (_this select 1): Object - the unit that activated the action
//    ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
//    arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax

player groupChat format["+++ client debug_SMPP.sqf: _this %1", _this];
hint localize format["+++ client debug_SMPP.sqf: _this %1", _this];
["remote_execute", "_this execVM ""scripts\debug\debug_SMPP.sqf"";", _this select 0, name player] call XSendNetStartScriptServer;
