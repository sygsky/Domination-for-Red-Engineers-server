// By Xeno, x_scripts\x_createdrop.sqf - weapon box drop
private ["_chopper","_doit","_drop_pos","_drop_type","_grp","_para","_the_chopper","_the_chute_type","_the_pilot","_unit","_vehicle","_wp","_starttime","_dist_to_drop","_exit_it","_wp2","_end_pos","_delete_chop","_may_exit"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_drop_type = _this select 0;
_drop_pos = _this select 1;
_drop_pos = [_drop_pos select 0, _drop_pos select 1, 120];

para_available = false;
["para_available",para_available] call XSendNetVarClient;

//_drop_pos = [_drop_pos select 0, _drop_pos select 1, 0];
_end_pos = [position X_Drop_End_Pos select 0, position X_Drop_End_Pos select 1, 120];

_delete_chop = {
	private ["_unit","_chopper"];
	_unit = _this select 0;
	_chopper = _this select 1;
	para_available = true;
	["para_available",para_available] call XSendNetVarClient;
	sleep (180 + random 100);
	deleteVehicle _chopper;deleteVehicle _unit;
};

__WaitForGroup
_grp = ["CIV"] call x_creategroup;
_the_chopper = x_drop_aircraft;
_the_pilot = "";
_the_chute_type = "";
switch (X_Drop_Side) do {
	case "WEST": {
		_the_chopper = x_drop_aircraft;
		_the_pilot = d_pilot_W;
		_the_chute_type = "ParachuteWest";
	};
	case "EAST": {
		_the_chopper = x_drop_aircraft;
		_the_pilot = d_pilot_E;
		_the_chute_type = "ParachuteEast";
	};
	case "RACS";
	case "CIV": {
		_the_chopper = x_drop_aircraft;
		_the_pilot = "Civilian";
		_the_chute_type = "ParachuteC";
	};
};

_chopper = createVehicle [_the_chopper, position X_Drop_Start_Pos, [], 0, "FLY"];
_unit = _grp createUnit [_the_pilot, position X_Drop_Start_Pos, [], 0, "NONE"];
[_unit] join _grp;_unit setSkill 1;_unit moveInDriver _chopper;
_unit setCaptive true;
__addDead(_unit)
__addRemoveVehi(_chopper)
_chopper lock true;
removeAllWeapons _chopper;

if (_chopper distance _drop_pos > _chopper distance d_island_center) then {
	_wp = _grp addWaypoint [d_island_center, 0];
	_wp setWaypointBehaviour "CARELESS";
	_wp setWaypointSpeed "NORMAL";
	_wp setwaypointtype "MOVE";
};
_wp = _grp addWaypoint [_drop_pos, 0];
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointSpeed "NORMAL";
_wp setwaypointtype "MOVE";

if (_drop_pos distance X_Drop_End_Pos > _drop_pos distance d_island_center) then {
	_wp = _grp addWaypoint [d_island_center, 0];
};
_wp2 = _grp addWaypoint [X_Drop_End_Pos, 0];
_wp2 setwaypointtype "MOVE";
_wp2 setWaypointBehaviour "CARELESS";
_wp2 setWaypointSpeed "NORMAL";

_chopper flyInHeight 120;
_dist_to_drop = 150;
_may_exit = false;
while {_chopper distance _drop_pos > 1000} do {
	sleep 0.512;
	if (!alive _unit || !alive _chopper || !canMove _chopper) exitWith {[_unit,_chopper] spawn _delete_chop;_may_exit = true};
};
if (_may_exit) exitWith {};
while {_chopper distance _drop_pos > _dist_to_drop} do {
	//sleep 0.512;
	sleep 1.012;
	if (!alive _unit || !alive _chopper || !canMove _chopper) exitWith {[_unit,_chopper] spawn _delete_chop;_may_exit = true};
	_unit doMove _drop_pos;
};
if (_may_exit) exitWith {};

[_the_chute_type,_chopper,_drop_type,_drop_pos] spawn {
	private ["_para","_the_chute_type","_chopper","_doit","_vehicle","_drop_type","_drop_posx"];
	_the_chute_type = _this select 0;
	_chopper = _this select 1;
	_drop_type = _this select 2;
	_drop_posx = _this select 3;
	_drop_posx = [_drop_posx select 0, _drop_posx select 1, 0];
	
	sleep 1.512;
	_vehicle = objNull;
	_is_ammo = false;
	_para = objNull;
	if (_drop_type in ["AmmoBoxWest","WeaponBoxWest","SpecialBoxWest","AmmoBoxEast","WeaponBoxEast","SpecialBoxEast","AmmoBoxGuer","WeaponBoxGuer","SpecialBoxGuer"]) then
	{
		_is_ammo = true;
		_para = createVehicle [_the_chute_type, [(position _chopper) select 0,(position _chopper) select 1,((position _chopper) select 2)-10], [], 0, "FLY"];
		_para setPos [(position _chopper) select 0,(position _chopper) select 1,((position _chopper) select 2) - 10];
	} else {
		_vehicle = createVehicle [_drop_type, [(position _chopper) select 0,(position _chopper) select 1,((position _chopper) select 2)-10], [], 0, "NONE"];
		_vehicle setPos [(position _chopper) select 0,(position _chopper) select 1,((position _chopper) select 2) - 10];
		_para = createVehicle [_the_chute_type, [0,0,0], [], 0, "FLY"];
		_para setPos (_vehicle modelToWorld [0,0,2]);
		[_vehicle] call XAddCheckDead;
	};
	
	[_vehicle,_drop_posx,d_drop_radius,_drop_type,_para, _is_ammo] execVM "scripts\mando_chute.sqf";
};

_drop_pos = nil;

_starttime = time;
_exit_it = false;

sleep 0.512;

while {_chopper distance _end_pos > 300} do {
	if (time - _starttime > 300) exitWith {
		para_available = true;["para_available",para_available] call XSendNetVarClient;
		deleteVehicle _chopper;deleteVehicle _unit;
		_exit_it = true;
	};
	if (!alive _unit || !alive _chopper || !canMove _chopper) exitWith {_exit_it = true;[_unit,_chopper] spawn _delete_chop;};
	sleep 1.012;
};

if (_exit_it) exitWith {};

deleteVehicle _chopper;deleteVehicle _unit;

para_available = true;
["para_available",para_available] call XSendNetVarClient;

if (true) exitWith {};
