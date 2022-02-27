/*
	scripts\bonus\bonusInspectAction.sqf, executed on client only
	author: Sygsky at 17-NOV-2021
	description:
        Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
        target (_this select 0): Object - the object which the action is assigned to
        caller (_this select 1): Object - the unit that activated the action
        ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
        arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax

	this method removes called action from vehicle
	returns: nothing
*/
hint localize format ["+++ bonusInspectAction.sqf: %1", _this];
_veh = _this select 0;
_name = name (_this select 1); // caller name (if a man)

_loc = _veh call SYG_nearestSettlement;
_loc_name =  text  _loc;
if ( !isPLayer (_this select 1) ) exitWith {
	// "One of your local soldiers %1 inspected vehicle %2, which he discovered."
	["msg_to_user","*",[["STR_BONUS_5"], _name, typeOf _veh],0,0,false,"received"] call XSendNetStartScriptClientAll;
	hint localize format["--- bonusInspectAction.sqf: Not player (%1) inspected bonus vehicle near %2. Exit.", typeOf (_this select 1), _loc_name];
};

if ( (getPos _veh) call SYG_pointIsOnBase ) exitWith {
	["bonus", "REG", _name, _veh ] call XSendNetStartScriptServer;
	hint localize format ["+++ bonusInspectAction.sqf: vehicle %1 is registered on the base, remove '%2' from command list and assign veh as bonus", typeOf _veh, localize "STR_CHECK_ITEM"];
	// Vehicle is on base, print message about and assign vehicle to be reastoreable
};

if ( _veh in client_bonus_markers_array) exitWith { // Do nothing except inform about vehicle already marked
	hint localize format["+++ Vehicle %1 is inspected by ""%2"" near ""%3"" already is marked known. Exit.", typeOf _veh, _name, _loc_name];
	localize "STR_BONUS_4" hintC [format[localize "STR_BONUS_4_1", typeOf _veh ],
						format[localize "STR_BONUS_4_2", typeOf _veh, localize "STR_CHECK_ITEM"]];
};

["bonus", "ADD", _name, _veh ] call XSendNetStartScriptServer;
hint localize format["+++ bonusInspectAction.sqf: Vehicle %1 inspected by '%2' near '%3'. Exit.", typeOf _veh, _name, _loc_name];
