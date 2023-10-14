// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1

//
x_sm_pos = [[7767.34,7500.25,0],[7453.12,7506.08,0]]; // index: 24,   Any of two fuel stations in desert to North of Arcadia
// One more option  
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_24"; //"The enemy uses a fuelstation located in a camp north of Arcadia to refuel its vehicles. Simple task, destroy it to cut down fuel supplies.";
	current_mission_resolved_text = localize "STR_SM_024"; //"Good job. The fuelstation is down.";
};

if (isServer) then {
    _pos_ind =x_sm_pos call XfRandomFloorArray; // 0 is original point, 1 is other point
	d_sm_p_pos = x_sm_pos select _pos_ind;
	publicVariable "d_sm_p_pos";
	if ( _pos_ind > 0 ) then { x_sm_pos set [0, d_sm_p_pos] };
	_vehicle = "Land_fuelstation_army" createVehicle d_sm_p_pos;
	[_vehicle] spawn XCheckSMHardTarget;
	//createGuardedPoint[d_side_enemy, position _vehicle, -1, _vehicle];
	sleep 2.22;
	["shilka", 1, "bmp", 2, "tank", 1, d_sm_p_pos, 1, 120,true] spawn XCreateArmor;
	sleep 2.123;
	["specops", 1, "basic", 2, d_sm_p_pos, 150,true] spawn XCreateInf;
	//	__AddToExtraVec(_vehicle)
	// TODO replace all __AddToExtraVec(_vehicle) with _vehicle call SYG_addToExtraVec;
	_vehicle call SYG_addToExtraVec;
    sleep 10;
    [_poss,200] call SYG_rearmAroundAsHeavySniper;

};

if (true) exitWith {};