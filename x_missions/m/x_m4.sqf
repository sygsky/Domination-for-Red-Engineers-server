// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[12104.7,17750,0], [12114.3,17739.1,0], [12110.8,17656.7,0]]; // index: 4,   Water tower (chemical weapons) Cabo Santa Lucia
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = format[localize "STR_SYS_520","Cabo Santa Lucia"]; //"По данным разведки, на вражеской базе в Cabo Santa Lucia производится химическое оружие. Найдите башню химического реактора и уничтожьте её.";
	current_mission_resolved_text = localize "STR_SYS_521"; //"Задание выполнено! Химреактор уничтожен.";
};

if (isServer) then {
	__PossAndOther
	_pos_other2 = x_sm_pos select 2;
	_vehicle = "Land_watertower1" createvehicle (_poss);
	[_vehicle] spawn XCheckSMHardTarget;
	sleep 2.123;
	["specops", 1, "basic", 2, _pos_other,80,true] spawn XCreateInf;
	sleep 2.123;
	["shilka", 1, "bmp", 1, "tank", 1, _pos_other2,1,100,true] spawn XCreateArmor;
	__AddToExtraVec(_vehicle)
};

if (true) exitWith {};