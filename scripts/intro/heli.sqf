/*
	scripts\intro\heli.sqf : heli only creation, run on server
	author: Sygsky
	description:
		"[ACE_]MH6" heli normalization:
			delete if killed,
			create if deleted,
			move existed to the Antigua predefined points if out of Antigua.

	returns: nothing
*/

#include "x_setup.sqf"
#include "air_setup.sqf"

//
// Gets predefined dir and pos for the heli: _pos_dir =
//
_setPosAndDir = {
	private ["_pos_dir"];
	_pos_dir = HELI_POINT_ARR call XfRandomArrayVal; // get new pos and dir
	aborigen_heli setDir (_pos_dir select 1);
	aborigen_heli setVehiclePosition [ _pos_dir select 0, [], 0, "CAN_COLLIDE"];
	aborigen_heli
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

if ( _create  ) exitWith { // create and set pos on islands
	aborigen_heli = createVehicle [ HELI_TYPE call XfRandomArrayVal, [0,0,1000], [], 0, "NONE"];
	sleep 0.1;
	aborigen_heli setVelocity [0,0,0];
	hint localize format["+++ heli.sqf: %1 heli created (alive %2) at ASL pos %3", typeOf aborigen_heli, alive aborigen_heli, getPosASL aborigen_heli];
	call _setPosAndDir; // get new dir and pos for the heli
	publicVariable "aborigen_heli";
};
// set zero damage and not full fuel
aborigen_heli setDamage 0;
aborigen_heli setFuel 0.7;
sleep 0.1;
hint localize format["+++ heli.sqf: final heli status isNil %1, alive %2, type %3, fuel %4, dmg %5, is %6local",
	isNil "aborigen_heli", alive aborigen_heli, typeOf aborigen_heli, fuel aborigen_heli, damage aborigen_heli,
	if (local aborigen_heli) then {""} else {"not "}];

