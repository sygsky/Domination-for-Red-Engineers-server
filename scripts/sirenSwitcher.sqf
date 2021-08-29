/*
	scripts\sirenSwitcher.sqf
	author: Sygsky

	Parameters array passed to the script upon activation in _this  variable is: [target, caller, ID, arguments]
      target (_this select 0): Object  - the object which the action is assigned to
      caller (_this select 1): Object  - the unit that activated the action
      ID (_this select 2): Number  - ID of the activated action (same as ID returned by addAction)
      arguments (_this select 3): Anything  - arguments given to the script if you are using the extended syntax

	description: none


	returns: if siren now is on then true, else false
*/
//++++++++++++++++++++++
// call as follows: _majak call SYG_lighthouseSirenSwitch;
// Switched siren on / off opposire to the cyrrent state: if was on, set off, if was off set on
//----------------------

if (!X_CLIENT) exitWith { hint localize "--- scripts\sirenSwitcher.sqf: called not on client computer" };
_majak = _this select 0;
if (!alive _majak) exitWith {hint localize format[ "--- SYG_lighthouseSirenSwitch: call with dead object %1", typeOf _majak ]; false };
if ( !(_majak isKindOf "Land_majak") ) exitWith { hint localize format[ "--- SYG_lighthouseSirenSwitch: call with dead object %1", typeOf _majak ]; false };
_siren = _majak getVariable "siren";
if ( isNil "_siren" ) then { _siren = false };
if ( _siren ) exitWith {
	_majak setVariable ["siren", false];
	["msg_to_user", "", ["STR_LIGHTHOUSE_OFF"], 0, 0, false, "off"] call SYG_msgToUserParser;
	false
};

_majak setVariable ["siren", true];
["msg_to_user", "", ["STR_LIGHTHOUSE_ON"], 0, 0, false, "on"] call SYG_msgToUserParser;
true

