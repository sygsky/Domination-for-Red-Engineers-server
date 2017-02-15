// by Xeno
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

sleep 30 + (random 20);

if (_isruin) then {
	_ruin = nearestObject [_position, "Ruins"];
	if (!isNull _ruin) then {
		["d_del_ruin",position _ruin] call XSendNetStartScriptAll;
		deleteVehicle _ruin;
	};
};

deleteVehicle _aunit;

if (true) exitWith {};

