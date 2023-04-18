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

hint localize "+++ camel.sqf: start";
_isNil = isNil "aborigen_plane";
_create = _isNil;
_delete = if (!_isNil) then {!(isNull aborigen_plane)} else { false };
hint localize format["+++ camel.sqf: _delete is %1, isNull %2", _delete, isNull aborigen_plane];

if ( _delete ) then { // delete plane
	_del_pos = getPos aborigen_plane;
	["say_sound", _del_pos, "steal"] call XSendNetStartScriptClient;
	deleteVehicle aborigen_plane;
	aborigen_plane = objNull;
	hint localize "+++ camel.sqf: plane deleted";
};

if ( _isNil || _delete ) then { // create
	aborigen_plane = createVehicle [ PLANE_TYPE, [0,0,1000], [], 0, "NONE"];
	sleep 0.1;
	hint localize format["+++ camel.sqf: %1 plane created alive %2", PLANE_TYPE, alive aborigen_plane];
};

aborigen_plane setDir PLANE_DIR;

if ( ((getPos aborigen_plane) distance PLANE_POS) > 0.5) then {
	aborigen_plane setVelocity [0,0,0];
	aborigen_plane setVehiclePosition [ PLANE_POS, [], 0, "CAN_COLLIDE"];
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

