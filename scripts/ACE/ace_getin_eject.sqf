// ace_getin_eject.sqf
private ["_cfg", "_vehicle", "_humanInCrew", "_eject", "_ejectEnabled"];
/* This script is executed by a GetIn event handler for any class Air vehicle. */

// Argument(s) passed from GetIn Event Handler. 0 = the object the event handler is assigned to.

_vehicle = _this select 0;

// If the vehicle is NOT one of the air vehicles that have ejection capability OR is a parachute exit the script wthout continuing.

//if !((_vehicle isKindOf "KA50") || (_vehicle isKindOf "A10") || (_vehicle isKindOf "AV8B") || (_vehicle isKindOf "Su34")) exitWith {};
_exit = false;
_cfg = (configfile >> "CfgVehicles" >> typeOf _vehicle >> "ACE_SYS_EJECT_EJECT");

if ( !( isNumber _cfg )  ) exitWith {};
if ( getNumber _cfg == 0 ) exitWith{};

// If the vehicle already as a "Eject" option then exit the script without continuing.

_ejectEnabled = _vehicle getVariable "ejectEnabled";
if (_ejectEnabled) exitWith {};

// Add action menu option to "Eject".
_eject = _vehicle addAction [localize "STR_ACE_EJECT0","\ace_sys_eject\s\ace_eject.sqf",[],-1.5,false,false,"Eject"];

// Set a variable to the vehicle to record the action ID.

_vehicle setVariable ["eject",_eject];
_vehicle setVariable ["ejectEnabled",true];