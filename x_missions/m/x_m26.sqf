// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

// 
// 7743.49,14452.7,0 - cone 1 hangar
// 7959.680176,0.000000,14514.200195 - cone 2 - _pos_other - smaller hil top
// 7774.970215,0.000000,14422.099609 - cone 3
// 7667.000000,0.000000,14409.599609 - cone 4 forest
// 7614.573730,74.208435,14317.125000 - Vulcan on the top
// {7511.905273,36.213688,14232.868164}
x_sm_pos = [[7743.5,14452.7,0],[7959.78,14514.2,0], [7775,14422.1,0],[7667,14409.6,0],[7614.6,14317,0],[7511.91,14232.87,0]]; // index: 26,   Hangar on Trelobada
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SYS_518";// "Враг заканчивает строительство ангара в Trelobada. Предположительно, там планируется развертывание производства нелегального оружия для повстанческой армии. Ваша задача уничтожение ангара."
	current_mission_resolved_text = localize "STR_SYS_519"; //"Задание выполнено! Ангар уничтожен."
};

if (isServer) then {
	__PossAndOther
	// _pos_other - on the smaller hill top
	_pos_other2 = x_sm_pos select 2; // cone 3 (before hangar entry)
	_pos_other3 = x_sm_pos select 3; // cone 4 (in the forest)
	_pos_other4 = x_sm_pos select 4; // AA pos (on highest hill top)
	_pos_other5 = x_sm_pos select 5; // AA pos (on western slope sharp-point)
	_vehicle = "Land_SS_hangar" createvehicle (_poss);
	[_vehicle] spawn XCheckSMHardTarget;
	_vehicle setDir 354;
	sleep 2.123;
	["specops", 1, "basic", 1, _pos_other3,80] spawn XCreateInf;
	sleep 2.012;
	["shilka", 1, "bmp", 0, "tank", 0, _pos_other, 1,0] spawn XCreateArmor; //++ Sygsky: shilka on 2-nd point (north-east of island)
	sleep 2.012;
	["shilka", 0, "bmp", 0, "tank", 1, _pos_other2, 1,0] spawn XCreateArmor; //++ Sygsky: point near hangar, not same pos as 1st shilka 
	sleep 2.123;
	["specops", 0, "basic", 1, _pos_other2,60] spawn XCreateInf; // specops on 3-rd point
	sleep 2.012;
	["shilka", 1, "bmp", 0, "tank", 0, _pos_other4, 1,0] spawn XCreateArmor; //++ Sygsky: shilka on 4-th point (top of the island)
	["shilka", 1, "bmp", 0, "tank", 0, _pos_other5, 1,0] spawn XCreateArmor; //++ Sygsky: shilka on 5-th point (SW side of island)
	sleep 1.337;
};

if (true) exitWith {};
