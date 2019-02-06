// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[11300.6,16870.3,0]]; // index: 37,   Prison, Isla de Victoria
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text =  localize "STR_SM_37"; //"На острове обнаружены множественные незаконные постройки. Самая крупная из них - особняк на Isla de Victoria. Уничтожьте постройку.";
	current_mission_resolved_text = localize "STR_SM_037"; // "Задание выполнено! Здание уничтожено.";
};

if (isServer) then {
	__Poss
	_vehicle = "Land_OrlHot" createVehicle (_poss);
	[_vehicle] spawn XCheckSMHardTarget;
	_vehicle setDir 270;
	sleep 2.132;
	["specops", 1, "basic", 1, _poss,100,true] spawn XCreateInf;
	sleep 2.234;
	["shilka", 1, "bmp", 1, "tank", 1, _poss,1,120,true] spawn XCreateArmor;
	__AddToExtraVec(_vehicle)
    sleep 10;
    [_poss,200] call SYG_rearmAroundAsHeavySniper;
};

if (true) exitWith {};