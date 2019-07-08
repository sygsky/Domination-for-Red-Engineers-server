// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[16582.7,4690.99,0], [16430.9,4617.28,0]]; // index: 11,   Lighthouse on Isla del Zorra
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

#ifdef __ACE__
#define __AA_DEFENCE_ON_ISLA_DEL_ZORRA__
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_11"; //"На острове Isla del Zorra враг установил на маяк радиолокатор. Задача - уничтожить здание маяка. Авиаторы будут вам благодарны.";
	current_mission_resolved_text = localize "STR_SM_011"; //"Задание выполнено! Маяк уничтожен.";
};

if (isServer) then {
	__PossAndOther
	_vehicle = "Land_majak2" createVehicle (_poss);
	[_vehicle] spawn XCheckSMHardTarget;
	sleep 2.022;
	["specops", 1, "basic", 2, _poss,100,true] spawn XCreateInf;
	sleep 2.123;
	["shilka", 3, "bmp", 1, "tank", 1, _poss,1,110,true] spawn XCreateArmor;
	__AddToExtraVec(_vehicle)

#ifdef __AA_DEFENCE_ON_ISLA_DEL_ZORRA__
    //+++ Sygsky: add more AA-defence
    	sleep 2.156;
    	__WaitForGroup
    	__GetEGrp(_newgroup)
    	_aa_types = [if (d_enemy_side == "EAST") then {"Stinger_Pod_East"} else {"Stinger_Pod"},"ACE_ZU23M"];
    	_utype = if (d_enemy_side == "EAST") then {d_crewman2_E} else {d_crewman2_W};
    	_pntarr = [ [18266.2,2966.5,0], [18212.8,2960.9,0], [18240.4,2902.3,0], [17894.4,3406.75,0] ];
    	//[_newgroup, _aa_types, _utype, _pntarr] call SYG_createStaticWeaponGroup;
    	[ _newgroup, ["ACE_ZU23M"], _utype, [ [17964.3,4022.6,0], [16839.09,5070.03,0] ] ] call SYG_createStaticWeaponGroup; // put ZSU-2 onto small desert islets

    	_newgroup allowFleeing 0;
    	// _newgroup setCombatMode "YELLOW";
    	{ _this setDir (floor random 360) } forEach units _newgroup;
    	_newgroup setSpeedMode "NORMAL";
    	_grp_array = [_newgroup, _pos, 0, [], [], -1, 0, [], 100, -1];
    	_grp_array execVM "x_scripts\x_groupsm.sqf";

    	hint localize format["%1 x_m30.sqf: AA defence on Isla del Zorra is created (%2 vehicles)", call SYG_missionTimeInfoStr, count units _newgroup ];
#endif
};

if (true) exitWith {};