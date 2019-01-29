// ace_getin_jumpout.sqf
private ["_cfg", "_vehicle", "_humanInCrew", "_jumpOut", "_jumpEnabled"];
/* This script is executed by a GetIn event handler for any class Air, LandVehicle, or Ship vehicle. */

// Argument(s) passed from GetIn Event Handler. 0 = the object the event handler is assigned to.

_vehicle = _this select 0;

// If  vehicle is an class Air vehicle with ejection capability OR is a parachute or static weapon then exit the script wthout continuing.
 //if ((_vehicle isKindOf "KA50") || (_vehicle isKindOf "A10") || (_vehicle isKindOf "AV8B") || (_vehicle isKindOf "Su34")) exitWith {};
//if ((_vehicle isKindOf "Parachute") || (_vehicle isKindOf "StaticWeapon")) exitWith {};
_cfg = (configfile >> "CfgVehicles" >> typeOf _vehicle >> "ACE_SYS_EJECT_JUMP");

if ( !( isNumber _cfg )  ) exitWith {};
if ( getNumber _cfg == 0 ) exitWith{};

// If the vehicle already as a "Jump Out" option then exit the script without continuing.

_jumpEnabled = _vehicle getVariable "jumpEnabled";
if (_jumpEnabled) exitWith {};

// If there are no human players in the vehicle exit the script without continuing.

_humanInCrew = false;
{ if (isPlayer _x) then { _humanInCrew = true; }; } forEach crew _vehicle;
if (!_humanInCrew) exitWith {};

// Add action menu option to "Jump Out".

_jumpOut = _vehicle addAction [localize "STR_ACE_EJECT1","\ace_sys_eject\s\ace_jumpout.sqf",[],-1.5,false,false,"Eject"];

// Set a variable to the vehicle to record the action ID and indicate it has an existing option.

_vehicle setVariable ["jumpOut",_jumpOut];
_vehicle setVariable ["jumpEnabled",true];

 