// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[7767.34,7500.25,0],[7453.12,7506.08,0]]; // index: 24,   Fuel station in camp near Arcadia
// One more option  
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SYS_516"; //"The enemy uses a fuelstation located in a camp north of Arcadia to refuel its vehicles. Simple task, destroy it to cut down fuel supplies.";
	current_mission_resolved_text = localize "STR_SYS_517"; //"Good job. The fuelstation is down.";
};

if (isServer) then {
    _reselect_pos = (random 1) < 0.5;
	if ( _reselect_pos ) then {
#ifdef __RANKED__
        d_sm_p_pos = nil;
#endif
	    x_sm_pos set [0, x_sm_pos select 1];
//	    publicVariable "x_sm_pos"; // dont use this line as x_sm_pos is modified with server-client network exchange
	};
	__Poss
#ifdef __RANKED__
    if ( _reselect_pos ) then {
    	["d_sm_p_pos", _poss] call XSendNetVarClient;
    };
#endif
	_vehicle = "Land_fuelstation_army" createVehicle (_poss);
	[_vehicle] spawn XCheckSMHardTarget;
	//createGuardedPoint[d_side_enemy, position _vehicle, -1, _vehicle];
	sleep 2.22;
	["shilka", 1, "bmp", 2, "tank", 1, _poss, 1, 120,true] spawn XCreateArmor;
	sleep 2.123;
	["specops", 1, "basic", 1, _poss,110,true] spawn XCreateInf;
	__AddToExtraVec(_vehicle)
    sleep 10;
    [_poss,200] call SYG_rearmAroundAsHeavySniper;

};

if (true) exitWith {};