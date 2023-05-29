/*
	scripts\intro\camel.sqf : only on server
	author: Sygsky
	description:
		"Camel2" plane normalization: delete if killed, create if deleted, create if not alive, move existed to the Antigua camel point.

	class Item29 {
		position[]={18089.394531,8.700000,18170.921875};
		azimut=80.000000;
		id=31;
		side="EMPTY";
		vehicle="Camel2";
		skill=0.600000;
		text="aborigen_plane";
	};

	returns: nothing
*/

#define PLANE_TYPE "Camel2"
#define PLANE_POS [18089.39,18170.92, 0]
#define PLANE_DIR 80

//
// Gets new dir and pos for the plane: _dir_pos =  PLANE_POS call _getDirAndPos; // _dir_pos = [80, [18089.39,18170.92, 0]]
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

hint localize "+++ camel.sqf: start";
_isNil = isNil "aborigen_plane";
_delete = if (!_isNil) then {!(alive aborigen_plane)} else { false };
_create = _isNil || _delete;
hint localize format["+++ camel.sqf: _delete is %1, isNull %2", _delete, isNull aborigen_plane];

if ( _delete ) then { // delete plane
	if (isNull aborigen_plane) exitWith {};
	_del_pos = getPos aborigen_plane;
	["say_sound", _del_pos, "steal"] call XSendNetStartScriptClient;
	deleteVehicle aborigen_plane;
	aborigen_plane = objNull;
	hint localize format["+++ camel.sqf: plane deleted at %1", _del_pos call SYG_MsgOnPosE0];
};

if ( _create  ) then { // create
	aborigen_plane = createVehicle [ PLANE_TYPE, [0,0,1000], [], 0, "NONE"];
	sleep 0.1;
	hint localize format["+++ camel.sqf: %1 plane created alive %2", PLANE_TYPE, alive aborigen_plane];
};

aborigen_plane setDir PLANE_DIR;

if ( ((getPos aborigen_plane) distance PLANE_POS) > 20) then {
	aborigen_plane setVelocity [0,0,0];
	_dir_pos = PLANE_POS call _getDirAndPos; // get new dir and pos for the plane
	aborigen_plane setDir (_dir_pos select 0);
	aborigen_plane setVehiclePosition [ _dir_pos select 1, [], 0, "CAN_COLLIDE"];
	publicVariable "aborigen_plane";
	sleep 0.3;
	["say_sound", aborigen_plane, "return"] call XSendNetStartScriptClient;
	hint localize "+++ camel.sqf: plane positioned on Antigua";
};

hint localize format["+++ camel.sqf: final plane status isNil %1, alive %2, type %3",isNil "aborigen_plane", alive aborigen_plane, typeOf aborigen_plane];

// set std damage and low fuel
aborigen_plane setFuel 0.3;
aborigen_plane setDamage 0.5;
publicVariable "aborigen_plane";

