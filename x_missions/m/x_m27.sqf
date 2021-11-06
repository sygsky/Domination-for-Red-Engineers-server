// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[12535.7,12699.6,0]]; // index: 27,   Radio tower at farm near Bagango
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SYS_314"; //"На ферме к западу от Bagango, и к югу от Carmen, находится радиовышка. Враг использует ее для связи с силами коллаборационистов. Уничтожьте ее.";
	current_mission_resolved_text = localize "STR_SYS_313"; //"Задание выполнено! Радиовышка уничтожена.";
};

if (isServer) then {
	__Poss;
	_vehicle = "Land_telek1" createVehicle (_poss);
	_vehicle setVectorUp [0,0,1];
	[_vehicle] spawn XCheckSMHardTarget;
	sleep 2.22;
	["shilka", 1, "bmp", 1, "tank", 1, _poss,1,130,true] spawn XCreateArmor;
	sleep 2.333;
	["specops", 1, "basic", 1, _poss,120,true] spawn XCreateInf;
	__AddToExtraVec(_vehicle)
    sleep 10;
    [_poss,200] call SYG_rearmAroundAsHeavySniper;
	// TODO: use code from x_scripts\x_createsecondary.sqf line 335 to populate the tower
};

if (true) exitWith {};