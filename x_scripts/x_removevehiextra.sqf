// by Xeno, x_scripts\x_removevehiextra.sqf
// called on "killed" event
// Triggered when the unit is killed.
//
// Local.
//
// Passed array: [unit, killer]
//
// unit: Object - Object the event handler is assigned to
// killer: Object - Object that killed the unit
// Contains the unit itself in case of collisions.
//
// Removes secondary main target from the server after 45 seconds approximatelly
//
private ["_aunit","_position","_isruin"];
if (!isServer) exitWith{};

_aunit = _this select 0;
_aunit removeAllEventHandlers "hit";
_aunit removeAllEventHandlers "damage";
_aunit removeAllEventHandlers "getin";
_aunit removeAllEventHandlers "getout";
_aunit removeAllEventHandlers "killed";
_position = position _aunit;

_isruin = (if (_aunit isKindOf "House") then {true} else {false});

sleep (60 + (random 20)); // remove ruines after 70 seconds timeout

if (_isruin) then {
	_ruin = nearestObject [_position, "Ruins"];
	if (!isNull _ruin) then {
		["d_del_ruin",position _ruin] call XSendNetStartScriptAll;
		deleteVehicle _ruin;
	};
};

deleteVehicle _aunit;

if (true) exitWith {};

