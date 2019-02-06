// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[13938.3,16718.8,0], [13904.7,16694.1,0], [13836.9,16705.1,0]]; // index: 6,   Hangar at Roca del Dror
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client) then {
	current_mission_text = localize "STR_SM_6"; //""На юго-западе от Roca del Dror вражеские войска возвели авиационный ангар. Ваша задача уничтожить ангар до того как в него завезут авиатехнику.";
	current_mission_resolved_text = localize "STR_SM_06"; //"Задание выполнено! Вражеский ангар уничтожен.";
};

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (isServer) then {
	__PossAndOther
	_pos_other2 = x_sm_pos select 2;
	_vehicle = "Land_SS_hangar" createVehicle (_poss);
	[_vehicle] spawn XCheckSMHardTarget;
	_vehicle setDir 41.8;
	sleep 2.123;
	["specops", 1, "basic", 1, _pos_other,90,true] spawn XCreateInf;
	sleep 2.012;
	["shilka", 1, "bmp", 1, "tank", 1, _pos_other2,1,80,true] spawn XCreateArmor;
	__AddToExtraVec(_vehicle)
	sleep 10;
    [_poss, 200] call SYG_rearmAroundAsHeavySniper;
};

if (true) exitWith {};