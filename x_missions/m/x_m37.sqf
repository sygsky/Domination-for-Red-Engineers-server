// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[11300.6,16870.3,0]]; // index: 37,   Prison, Isla de Victoria, marker center
_sm_building_pos=[[11199.72,16965.2,0],[11151.6,16973.6,0]];
/*
	position[]=[11199.715820,16965.199219,0];
	azimut=270.000000;
	id=540;
	side="EMPTY";
	vehicle="Land_dum_mesto3_istan";
	skill=0.600000;
	text="prison2";
	init="this setVectorUp [0,0,1];";
*/
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text =  localize "STR_SM_37"; //"The enemy is building a prison on Isla de Victoria. Destroy the building so that they can not arrest innocent people.";
	current_mission_resolved_text = localize "STR_SM_037"; // "Задание выполнено! Здание уничтожено.";
};

if (isServer) then {
	__Poss;
	_id = _sm_building_pos call XfRandomFloorArray;
	x_sm_pos set[0,_sm_building_pos select _id ];
	publicVariable "x_sm_pos";
	_vehicle = "Land_dum_mesto3_istan" createVehicle (_sm_building_pos select _id); //  Old building was "Land_OrlHot"
//	hint localize format["+++ mission 37: veh = %1, id = %2, pos = %3", _vehicle, _id,  _sm_building_pos select _id];
	_pos = getPos _vehicle;
	_pos set [2, - 1.5];
	_vehicle setPos _pos;
	_vehicle setVectorUp [0,0,1];
	[_vehicle] spawn XCheckSMHardTarget;
	_vehicle setDir 270;
	sleep 2.132;
	["specops", 1, "basic", 1, _poss,100,true] spawn XCreateInf;
	sleep 2.234;
	["shilka", 2, "bmp", 1, "tank", 1, _poss,1,120,true] spawn XCreateArmor;
	__AddToExtraVec(_vehicle)
    sleep 10;
    [_poss,200] call SYG_rearmAroundAsHeavySniper;
    sleep 5;
    // TODO: add some static weapons, especially M2 on the terrace of the new  building and 2 AGS or ZSU-2 on the flatе roofs of neigboring building
};

if (true) exitWith {};