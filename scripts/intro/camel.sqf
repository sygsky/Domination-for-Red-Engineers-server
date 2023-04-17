/*
	scripts\intro\camel.sqf : only on server
	author: Sygsky
	description:
		"Camel2" plane normalization: delete if killed, create if deleted, create if not alive, move existed to the Antigua camel point

	class Item29 {
		position[]={18089.394531,8.700000,18170.921875};
		azimut=80.000000;
		id=31;
		side="EMPTY";
		vehicle="Camel2";
		skill=0.600000;
		text="aborigen_camel";
	};

	returns: nothing
*/

#define PLANE_POS [18089.39,18170.92, 0]
_isNil = isNil "aborigen_camel";
_delete = if (!_isNil) then {!alive aborigen_camel} else { false };
if ( _delete ) then { // delete plane
	_del_pos = getPos aborigen_camel;
	["say_sound", _del_pos, "steal"] call XSendNetStartScriptClient;
	deleteVehicle aborigen_camel;
	aborigen_camel = objNull;
};

if (!alive aborigen_camel) then { // create
	aborigen_camel = createVehicle ["Camel2", [0,0,1000], [], 0, "NONE"];
};

aborigen_camel setDir 80;

if ( ((getPos aborigen_camel) distance PLANE_POS) > 0.5) then {
	aborigen_camel setVehiclePosition [ PLANE_POS, [], 0, "CAN_COLLIDE"];
	aborigen_camel setVelocity [0,0,0];
	publicVariable "aborigen_camel";
	sleep 0.3;
	["say_sound", aborigen_camel, "return"] call XSendNetStartScriptClient;
};

// set std damage and low fuel
aborigen_camel setFuel 0.3;
aborigen_camel setDamage 0.5;

