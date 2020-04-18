// by Xeno
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __AA_DEFENCE_ON_TIBERIA__

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[9379.85,5221,0]]; // index: 40,   Prison camp, Tiberia
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {

	current_mission_text = format[localize "STR_SYS_118", "Tiberia"];//	"В Tiberia расположен лагерь, где незаконно удерживается и подвергается различным пыткам гражданское население. Ваша задача - освободить гражданских и доставить их на базу. Для выполнения задания хотя бы один заложник должен добраться до базы живым. (Завершить миссию может только игрок в роли спасателя).";
	current_mission_resolved_text = localize "STR_SYS_119"; //"Задание выполнено! Пленные освобождены.";
};

if (isServer) then {

#ifdef __AA_DEFENCE_ON_TIBERIA__
//+++ Sygsky: add more AA-defence
	_newgroup = call SYG_createEnemyGroup;
//    hint localize format["_newgroup == %1", _newgroup];
	sleep 1.56;
	_utype = if (d_enemy_side == "EAST") then {d_crewman2_E} else {d_crewman2_W}; // d_crewman2_E
//    hint localize format["_utype == %1", _utype];

	_btm_wpn = if (d_enemy_side == "EAST") then {["DSHkM_Mini_TriPod","ACE_ZU23M"]} else {["M2HD_mini_TriPod","ACE_ZU23M"]};
	_ground_arr = [_newgroup,_btm_wpn,_utype,[[9166.53,5231.16,0],[9438.93,5044.9,0],[9760.06,4809.8,0]]];
	_ground_arr call SYG_createStaticWeaponGroup;

	_top_wpn = if (d_enemy_side == "EAST") then {["Stinger_Pod_East","ACE_ZU23M"]} else {["Stinger_Pod","ACE_ZU23M"]};
	_roof_arr = [_newgroup,_top_wpn,_utype,[[9283.08,5208.89,15.4],[9381.33,5152.75,14.8],[9403.3,5182.61,6]]];
	_roof_arr call SYG_createStaticWeaponGroup;
	[ _newgroup, "M119",       _utype, [[ 8711.15,5489.39, 0]]] call SYG_createStaticWeaponGroup;
	[ _newgroup, "MK19_TriPod",_utype, [[ 9359.7, 5009.98, 0]]] call SYG_createStaticWeaponGroup;

	_newgroup allowFleeing 0;
	_newgroup setCombatMode "YELLOW";
	_newgroup setFormDir (floor random 360);
	_newgroup setSpeedMode "NORMAL";
	_grp_array = [_newgroup, _pos, 0, [], [], -1, 0, [], 100, -1];
	_grp_array execVM "x_scripts\x_groupsm.sqf";

	hint localize format["%1 x_m40.sqf: AA defence on Tiberia is created (%2 static vehicles)", call SYG_missionTimeInfoStr, count units _newgroup ];
#endif

	[x_sm_pos, 400] execVM "x_missions\common\x_sideprisoners.sqf";

    sleep 10;
    [(x_sm_pos select 0),200] call SYG_rearmAroundAsHeavySniper;
};

if (true) exitWith {};