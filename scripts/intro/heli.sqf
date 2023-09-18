/*
	scripts\intro\heli.sqf : aborigen only creation, run on server
	author: Sygsky
	description:
		"[ACE_]MH6" heli normalization: delete if killed, create if deleted, create if not alive, move existed to the Antigua random point.
	returns: nothing
*/

#include "x_setup.sqf"
#include "air_setup.sqf"

//
// Gets new dir and pos for the heli: _dir_pos =
//
_getDirAndPos = {
	private ["_rnd","_house","_rel"];
	if (typeName _this == "OBJECT") then {_this  = getPos _this};
	_rnd    = floor (random 4); // 0..3
	if (_rnd == 0) exitWith { [80, _this] }; // Use init poin as result
	_house = nearestObject [ _this, "House"];
	_rel   = _house worldToModel _this; // find 1st point
	if (_rnd < 3) exitWith { // 1..2
		[80, _house modelToWorld [_rel select 0, (_rel select 1) + 4 * _rnd, 0]] // pos along long side of house, +4 or +8 meters on Y init pos
	};
	// pos on the front side
	[350, [18078.5,18182.6,0]]
};

hint localize "+++ heli.sqf: start";
_isNil = isNil "aborigen_heli";
_delete = if (!_isNil) then {!(alive aborigen_heli)} else { false };
_create = _isNil || _delete;
hint localize format["+++ heli.sqf: _delete is %1, isNull %2", _delete, isNull aborigen_heli];

if ( _delete ) then { // delete heli
	if (isNull aborigen_heli) exitWith {};
	_del_pos = getPos aborigen_heli;
	["say_sound", _del_pos, "steal"] call XSendNetStartScriptClient;
	deleteVehicle aborigen_heli;
	aborigen_heli = objNull;
	hint localize format["+++ heli.sqf: deleted at %1", _del_pos call SYG_MsgOnPosE0];
};

_places = HELI_POINT_ARR;

if ( _create  ) then { // create and set pos on islands
	aborigen_heli = createVehicle [ HELI_TYPE call XfRandomArrayVal, [0,0,1000], [], 0, "NONE"];
	sleep 0.1;
	aborigen_heli setVelocity [0,0,0];
	hint localize format["+++ heli.sqf: %1 heli created (alive %2) at ASL pos %3", typeOf aborigen_heli, alive aborigen_heli, getPosASL aborigen_heli];
	_pos = _places call XfRandomArrayVal;
	_dir = _pos select 1;
	_pos = _pos select 0;
	aborigen_heli setDir _dir;
	aborigen_heli setVehiclePosition [ _pos, [], 0, "CAN_COLLIDE"];
} else {
	if ( !(aborigen_heli call SYG_pointOnAntigua) ) then { // Move heli to any of designated points on Antigua
		_dir_pos = aborigen_heli call _getDirAndPos; // get new dir and pos for the heli
		aborigen_heli setDir (_dir_pos select 0);
		aborigen_heli setVehiclePosition [ _dir_pos select 1, [], 0, "CAN_COLLIDE"];
		publicVariable "aborigen_heli";
		sleep 0.3;
		["say_sound", aborigen_heli, "return"] call XSendNetStartScriptClient;
		_str = [ aborigen_heli , 10 ] call SYG_MsgOnPosE0;
		hint localize format["+++ heli.sqf: heli positioned on Antigua at %1", _str];
	};

	hint localize format["+++ heli.sqf: final heli status isNil %1, alive %2, type %3",isNil "aborigen_heli", alive aborigen_heli, typeOf aborigen_heli];

	// set std damage and low fuel
	aborigen_heli setFuel 0.1;
	aborigen_heli setDamage 0;

};

publicVariable "aborigen_heli";

