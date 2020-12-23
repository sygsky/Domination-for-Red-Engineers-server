// by Sygsky, scripts\SYG_eventPlaneGetIn.sqf: prevents AI to enter as pilot or gunner to a plane
// Created at 23-DEC-2020, #421
private ["_vehicle","_position","_enterer"];

_vehicle = _this select 0;
if (!(_vehicle isKIndOf "Plane")) exitWith{hint localize format["--- SYG_eventPlaneGetIn: AI entered %1 (not plane)", typeOf _vehicle]};

_enterer = _this select 2;
if (isPlayer  _enterer) exitWith {}; // players are allowed to enter
if (side _enterer != d_side_player) exitWith{}; // enemies are allowed to enter :o)

_position = _this select 1;
if ( ! (_position in ["driver", "gunner", "commander"]) ) exitWith { }; // cargo is allowed

_enterer action["Eject",_vehicle]; // get him/her out

// send info to the player owned this AI that it is not allowed to board the plane
if (! isPlayer ( leader _enterer ) ) exitWith {
	hint localize format["--- SYG_eventPlaneGetIn: AI tries to getin as %1, no player owner detected and msg not sent", _position];
};
["msg_to_user", name leader _enterer,  [ ["STR_SYS_251"]], 0, 2, false, "losing_patience" ] call XSendNetStartScriptClient; // "No permission to fly!"
hint localize format["--- SYG_eventPlaneGetIn: AI entered %1 as %2, hiw player owned name ""%3"", msg sent", typeOf _vehicle, _position, name leader _enterer ];

sleep 1;
if (isEngineOn _vehicle) then {
	_vehicle engineOn false;
};

if (true) exitWith {};
