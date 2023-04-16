//
// by Xeno. x_scripts/x_settingsdialog.sqf, runs only on client computer
//
private ["_ok", "_XD_display", "_ctrl", "_rarray", "_vdindex", "_i", "_index", "_glindex", "_mindex", "_str","_str1", "_strYesCR","_strNoCR","_ar", "_counter",
		  "_name1", "_name2", "_name3"];

#include "x_setup.sqf"
#include "x_macros.sqf"
#include "global_vars.sqf"

//#define __DEBUG__

#define GRU_DIALOG_ID 2011
 
_ok = createDialog "XD_SettingsDialog";

_XD_display = findDisplay 11251;

_ctrl = _XD_display displayCtrl 1000;

// View distance show
_vdindex = -1;
for "_i" from 0 to (count SYG_viewDistanceArray - 1) do {
	call compile format ["_index = _ctrl lbAdd ""%1"";if (d_viewdistance == %1) then {_vdindex = _index};",SYG_viewDistanceArray select _i];
};
_ctrl lbSetCurSel _vdindex;

_ctrl = _XD_display displayCtrl 1001;
// Трава "Без травы"  "Средняя" "Полная"
_rarray = ["STR_GRASS_1", "STR_GRASS_2", "STR_GRASS_3"];
_glindex = -1;
for "_i" from 0 to (count _rarray - 1) do {
	call compile format ["_index = _ctrl lbAdd ""%1"";if (d_graslayer_index == _index) then {_glindex = _index};",localize (_rarray select _i)];
};
_ctrl lbSetCurSel _glindex;


_ctrl = _XD_display displayCtrl 1002;
if (!(__ReviveVer) && !d_dont_show_player_markers_at_all) then {
	//_rarray = ["Без маркеров", "С именем", "Только маркеры", "С ролью", "С отображением здоровья"];
	_rarray = [localize "STR_SYS_170", localize "STR_SYS_171", localize "STR_SYS_172", localize "STR_SYS_173", localize "STR_SYS_174"];
	for "_i" from 0 to (count _rarray - 1) do {
		call compile format ["_index = _ctrl lbAdd ""%1"";",_rarray select _i];
	};
	_ctrl lbSetCurSel d_show_player_marker;
} else {
	_ctrl ctrlShow false;
	_ctrl = _XD_display displayCtrl 1500;
	_ctrl ctrlShow false;
	_ctrl = _XD_display displayCtrl 1501;
	_ctrl ctrlShow false;
};

// Reborn music sound/not sound
_ctrl = _XD_display displayCtrl 1003;
// Reborn music "Listen"  "Don't listen"
_rarray = ["STR_REBORN_1", "STR_REBORN_0"];
_carray = [[0,1,0,1], [1,0,0,1]];
_mindex = -1;
for "_i" from 0 to (count _rarray - 1) do {
	call compile format ["_index = _ctrl lbAdd ""%1"";_ctrl lbSetColor [%2,%3];if (d_rebornmusic_index == _index) then {_mindex = _index};",localize (_rarray select _i), _i, _carray select _i];
};
_ctrl lbSetCurSel _mindex;


_ctrl = _XD_display displayCtrl 2001;
_ctrl ctrlSetText str(d_points_needed select 0);
_ctrl = _XD_display displayCtrl 2002;
_ctrl ctrlSetText str(d_points_needed select 1);
_ctrl = _XD_display displayCtrl 2003;
_ctrl ctrlSetText str(d_points_needed select 2);
_ctrl = _XD_display displayCtrl 2004;
_ctrl ctrlSetText str(d_points_needed select 3);
_ctrl = _XD_display displayCtrl 2005;
_ctrl ctrlSetText str(d_points_needed select 4);
_ctrl = _XD_display displayCtrl 2006;
_ctrl ctrlSetText str(d_points_needed select 5);

//++++++++++++++++++++++++++++++++++++ MAIN LIST BOX WITH SETTINGS +++++++++++++++++++++

_ctrl = _XD_display displayCtrl 2007;

_strYesCR = localize "STR_SYS_400";   // "Yes\n"
_strYes = localize "STR_SYS_400_1";// "Yes"
_strNoCR = localize "STR_SYS_401";    // "No\n"
_strNo = localize "STR_SYS_401_1"; // "No"

_str = format[localize "STR_SYS_254_0", missionName];
_str = _str + format[localize "STR_SYS_254", d_own_side, d_enemy_side, getText(configFile>>"CfgWorlds">>worldName>>"description")]; // "Ваша сторона: %1. Враги: %2. Остров: %3\n"

if (__ACEVer || __CSLAVer) then {
	if (__ACEVer) then {
		_str = _str + (localize "STR_SET_1")/* "Version" */ + ": A.C.E.";
	} else {
		_str = _str + (localize "STR_SET_1")/* "Version" */ + ": CSLA. ";
	};
};

_str = _str + ". " + (localize "STR_SET_2")/* "С АИ" */ + ": ";
#ifdef __AI__
_str = _str + _strYes; //"Yes"
#else
_str = _str + _strNo; // "No"
#endif

_str = _str + ". " + (localize "STR_SET_3")/* "Ранговая" */ + ": ";
#ifdef __RANKED__
_str = _str + _strYesCR;
#else
_str = _str + _strNoCR;
#endif

//+++ 11-JUN-2018: new non-Xeno defines starts from here

_str = _str + (localize "STR_SET_5")/* Javelin" */ + ": ";
#ifdef __JAVELIN__
_str = _str + _strYesCR;
#else
_str = _str + _strNoCR;
#endif


_str = _str + (localize "STR_SET_6") + ": "; // "Simple side missions at the beginning"
#ifdef __EASY_SM_GO_FIRST__
_str = _str + _strYesCR;
#else
_str = _str + _strNoCR;
#endif

_str = _str + (localize "STR_SET_7") + ": "; // "Light vehicle[s] at the base in the beginning"
#ifdef __ADDITIONAL_BASE_VEHICLES__
_str = _str + _strYesCR;
#else
_str = _str + _strNoCR;
#endif

// Engineering Fund
_str = _str + (localize "STR_SYS_137_5") + ": "; // "The Engineering Fund"
#ifdef __REP_SERVICE_FROM_ENGINEERING_FUND__
_str = _str + format["%1\n",SYG_engineering_fund];
#else
_str = _str + _strNoCR;
#endif

_str = _str +
#ifdef __ADD_SCORE_FOR_FACTORY_SUPPORT__
format[localize "STR_SET_12",__ADD_SCORE_FOR_FACTORY_SUPPORT__ ]  // "Score added for service support "
#else
format[localize "STR_SET_12_1",d_ranked_a select 20] // "Score subrtracted for service support"
#endif
 + "\n";

_str = _str + (localize "STR_SET_8") ; // "Mandatory side missions"
#ifdef __SIDE_MISSION_PER_MAIN_TARGET_COUNT__
_str = _str +  format[localize "STR_SET_8_1", __SIDE_MISSION_PER_MAIN_TARGET_COUNT__] + "\n";
#else
_str = _str + ": " + _strNoCR;
#endif

_str = _str + (localize "STR_SET_9") + ": "; // "Teleport works only when all services on the base are available"
#ifdef __TELEPORT_ONLY_WHEN_ALL_SERVICES_ARE_VALID__
_str = _str + _strYesCR;
#else
_str = _str + _strNoCR;
#endif

#ifdef __NO_TELEPORT_ON_DAMAGE__
    _str = _str + (format[localize "STR_SET_9_2", __NO_TELEPORT_ON_DAMAGE__ * 100,"%" ]) + "\n"; // "Teleport works until the MHQ damage %1%2"
#else
    _str = _str + (localize "STR_SET_9_1") + "\n"; // "Teleport shuts off when MHQ is damaged at %1 percents"
#endif

_str = _str + (localize "STR_SET_10") ; // "Jail"
#ifdef __JAIL_MAX_SCORE__
_str = _str + format[localize "STR_SET_10_1",__JAIL_MAX_SCORE__] + "\n";
#else
_str = _str + ": " + _strNoCR;
#endif

_str = _str + (localize "STR_SET_11"); // "Clone RPG missiles: "
#ifndef __NO_RPG_CLONING__
_str = _str + _strYesCR;
#else
_str = _str + ": " + _strNoCR;
#endif

#ifdef __NON_ENGINEER_REPAIR_PENALTY__
_str = _str + format[localize "STR_SET_30_0", __NON_ENGINEER_REPAIR_PENALTY__]  + "\n"; // "Anyone can repair everything, with a %1 penalty per step. Engineers are not penalized"
#else
_str = _str + (localize "STR_SET_30") + "\n"; // "Can repair only engineers"
#endif

#ifdef __PREVENT_OVERTURN__
_str = _str + format[localize "STR_SET_31",_strYesCR]; //
#else
_str = _str + format[localize "STR_SET_31",_strNoCR]; //
#endif

#ifdef __DISABLE_GRU_BE_PILOTS__
_str = _str + format[localize "STR_SET_32",_strYesCR]; //
#else
_str = _str + format[localize "STR_SET_32",_strNoCR]; //
#endif

#ifdef __ALLOW_SHOTGUNS__
_str = _str + (localize "STR_SET_33"); //
#endif

#ifdef __NO_TELEPORT_ON_DAMAGE__
_str = _str + format[localize "STR_SET_34", __NO_TELEPORT_ON_DAMAGE__ *100, "%"]; // "The teleport stops working when taking damage %1%2"
#endif

#ifdef __LOCK_ON_RECAPTURE__
_str = _str + (localize "STR_SET_35"); // "Enemy armored vehicles engaged in counterattacks are blocked from entering\n"
#endif

#ifdef __SPPM__
_str = _str + (localize "STR_SET_SPPM"); // "SPPM service is on\n"
#else
_str = _str + (localize "STR_SET_SPPM_OFF"); // "SPPM service is off\n"
#endif

#ifdef __NO_AI_IN_PLANE__
_str = _str + (localize "STR_SET_36"); // prevents AI to enter plane as driver/pilot, gunner or commaner. Cargo role is allowed
#endif

#ifdef __LH_HOWLER__
_str = _str + (localize "STR_SET_37"); // Sahrani lighthouse howler sounds on
#else
_str = _str + (localize "STR_SET_37_0"); // Sahrani lighthouse howler sounds off
#endif

// teleport is infuenced by ferro-magnetic masses and damagein designated distance
#ifdef __TELEPORT_DEVIATION__
_str = _str + (localize format["STR_SET_38", __TELEPORT_DEVIATION__]);
#endif

#ifdef __VEH_1985__
_str = _str + (localize "STR_SET_39"); // "Only vehicles BEFORE 1985 inclusivelly allowed\n"
#else
_str = _str + (localize "STR_SET_39_0"); // "The mission uses all available equipment\n"
#endif

#ifndef __DISABLE_PARAJUMP_WITHOUT_PARACHUTE__
_str = _str + (localize "STR_SET_40");
#endif

#ifdef __DOSAAF_BONUS__
_str = _str + (localize "STR_SET_41");
#endif

#ifdef __CONNECT_ON_PARA__
_str = _str + (localize format["STR_SET_42", 1 call XGetRankStringLocalized]);
#endif

//--- new non-Xeno defines stops here

_str = _str + (localize "STR_SET_4")/* "С возможность оживлять" */+": ";
#ifdef __REVIVE__
_str = _str + _strYes +". ";
#else
_str = _str + _strNo + ". ";
#endif

_str = _str + (localize "STR_SET_13");// "Mando missiles pack: "
#ifdef __MANDO__
_str = _str + _strYes +". ";
#else
_str = _str + _strNo + ". ";
#endif

// _str = _str + "Версия: " + d_version_string + "\n";

_str = _str + (localize "STR_SET_14");//"Built-in rucksack: ";
if (d_use_backpack) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

_str = _str + (localize "STR_SYS_343")/* "Отображение маркера с именем игрока: " */;
if (d_show_player_marker_names) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

_str = _str + (localize "STR_SYS_344")/* "Отображение направления движения у маркера игрока: " */;
if (d_p_marker_dirs) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

_str = _str + (localize "STR_SYS_345")/* "Отображение напр. движения маркеров техники: " */;
if (d_v_marker_dirs) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

_str = _str + (localize "STR_SYS_346")/* "Тип маркера игрока: " */ + d_p_marker + "\n";

_str = _str + (localize  "STR_SET_22"); // "Teamstatus Dialog enabled: "
if (d_use_teamstatusdialog) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

_str = _str + (localize "STR_SYS_347")/* "Выгрузка техники из мобильного респауна: " */;
for "_i" from 0 to (count d_create_bike - 1) do {
	_str = _str + ([d_create_bike select _i,0] call XfGetDisplayName);
	if (_i < (count d_create_bike - 1)) then {
		_str = _str + ", ";
	};
};
_str = _str + "\n";

_str = _str + (localize "STR_SET_23") + str(d_remove_mhq_vec_time) + "\n"; //"Time a player has to wait until he can create a new vehicle at a MHQ: "

if (count d_only_pilots_can_fly > 0) then {
	_str = _str + (localize "STR_SET_24");
	for "_i" from 0 to (count d_only_pilots_can_fly - 1) do {
		_str = _str + (d_only_pilots_can_fly select _i);
		if (_i < (count d_only_pilots_can_fly - 1)) then {
			_str = _str + ", ";
		};
	};
	_str = _str + "\n";
};

_str = _str +  (localize "STR_SET_25") + str(max_number_ammoboxes) + (localize "STR_SET_25_1") + str(ammo_boxes) + "\n"; // "Maximum number of ammoboxes: "

_str = _str + (localize "STR_SET_25_2") + str(d_drop_ammobox_time) + "\n"; // "Time to wait until an ammobox can be dropped/loaded again: "
_str = _str + (localize "STR_SET_26") + str(max_truck_cargo) + "\n"; // "Maximum number of statics per engineer truck: "


_str = _str + (localize "STR_SET_27"); //"Vehicles able to load ammoboxes: "
for "_i" from 0 to (count d_check_ammo_load_vecs - 1) do {
	if (_i > 0) then { _str1 = ", '%1'";}
	else {_str1 = "'%1'";};
	_str = _str + format[_str1, ([d_check_ammo_load_vecs select _i,0] call XfGetDisplayName)];
};
_str = _str + "\n";

_str = _str + (localize "STR_SET_28") + str(D_RESPAWN_DELAY) + "\n"; // "Player respawn delay (in seconds): "

if (!isNil "d_with_respawn_dialog_after_death") then {
	_str = _str + ( localize "STR_SET_29" );
	if (d_with_respawn_dialog_after_death) then {
		_str = _str + _strYesCR;
	} else {
		_str = _str + _strNoCR;
	};
};

// TODO: add settings from x_setup.sqf here


_str = _str + (localize "STR_SYS_348")/* "Система погодных явлений: " */;
if (d_weather) then {
	_str = _str + _strYes + ". ";
} else {
	_str = _str + _strNo + ". ";
};
_str = _str + format["%1: ",localize "STR_WET_22"]; // + "Туман: "
if (d_weather_fog) then {
	_str = _str + _strYes + ". ";
} else {
	_str = _str + _strNo + ". ";
};
_str = _str + format["%1: ",localize "STR_WET_23"]; // "Песчаная буря: "
if (d_weather_sandstorm) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

_str = _str + (localize "STR_SYS_349"); // "Пулемётчики могут развёртывать пулемётные гнезда: "
if (d_with_mgnest) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

#ifndef __REVIVE__
_str = _str + (localize "STR_SYS_1200"); // "Respawn with same weapons after death: "
if (x_weapon_respawn) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};
#endif

#ifdef __AI__
_str = _str + (localize "STR_SYS_1201") + str(max_ai) + "\n"; // "Maximum number of AI that can get recruited: "
#endif

_str = _str + localize"STR_SYS_350" + str(d_sub_tk_points) + "\n"; // "Points a player looses for teamkill: "

#ifdef __RANKED__
_str = _str + (localize "STR_SYS_1202") + str(abs(d_sub_kill_points)) + "\n"; // "Player points that get subtracted after death: "
_str = _str + (localize "STR_SYS_1203") + str(d_ranked_a select 0) + "\n"; // "Points an engineer needs to service a vehicle: "
_str = _str + (localize "STR_SYS_1204");                                                    // "Points an engineer gets for servicing: "
_str = _str + (localize "STR_SYS_1204_1") + str((d_ranked_a select 1) select 0)
			+ (localize "STR_SYS_1204_2") + str((d_ranked_a select 1) select 1)
			+ (localize "STR_SYS_1204_3") + str((d_ranked_a select 1) select 2)
			+ (localize "STR_SYS_1204_4") + str((d_ranked_a select 1) select 3)
			+ "\n"; // (air vec), (tank), (car), (other)
_str = _str + (localize "STR_SYS_1204_5") + str(d_ranked_a select 13) + "\n";   // "Points an engineer needs to rebuild the support buildings at base: "
_str = _str + (localize "STR_SYS_1205") + str(d_ranked_a select 2) + "\n";         // "Points an artillery operator needs for a strike: "
if (__AIVer) then {
	_str = _str + (localize "STR_SYS_1206") + str(d_ranked_a select 3) + "\n";            // "Points needed to recuruit one AI soldier: "
	_str = _str + (localize "STR_SYS_1207") + str(d_ranked_a select 15) + "\n"; // "Points needed to call in an air taxi: "
};
_str = _str + (localize "STR_SYS_1208") + str(d_ranked_a select 4) + "\n";    // "Points needed for AAHALO parajump: "
_str = _str + (localize "STR_SYS_1209") + str(d_ranked_a select 6) + "\n"; // "Points needed to create a vehicle at a MHQ: "
_str = _str + (localize "STR_SYS_1210") + str(d_ranked_a select 5) + "\n";  // "Points that get subtracted for creating a vehicle at a MHQ: "
_str = _str + (localize "STR_SYS_351") + str(d_ranked_a select 7) + "\n"; // "Points a medic gets if someone heals at his Mash: "
_str = _str + (localize "STR_SYS_352") + str(d_ranked_a select 17) + "\n";          // "Points a medic gets if he heals another unit: "

_ar = d_ranked_a select 8;
_str = _str + (localize "STR_SYS_353")/* "Требуемое звание для управления лёгкой бронетехникой: " */ + ((_ar select 0) call XGetRankStringLocalized) + "\n";
_str = _str + (localize "STR_SYS_354")/* "Требуемое звание для управления бронетехникой: " */ + ((_ar select 1) call XGetRankStringLocalized) + "\n";
_str = _str + (localize "STR_SYS_355")/* "Требуемое звание для управления боевыми вертолётами: " */ + ((_ar select 2) call XGetRankStringLocalized) + "\n";
_str = _str + (localize "STR_SYS_356")/* "Требуемое звание для управления самолётами: " */ + ((_ar select 3) call XGetRankStringLocalized) + "\n";


_str = _str + format [localize "STR_SYS_357"/* "Очков за выполнение основной задачи, игрок в радиусе %1 м. от центра города: " */,d_ranked_a select 10] + str(d_ranked_a select 9) + "\n";
_str = _str + format [localize "STR_SYS_358"/* "Очков за выполнение дополнительной задачи, игрок в радиусе %1 м. от места операции: " */,d_ranked_a select 12] + str(d_ranked_a select 11) + "\n";

_str = _str + (localize "STR_SYS_1211") + str(d_ranked_a select 14) + "\n"; // "Points needed to build a mg nest: "
_str = _str + (localize "STR_SYS_1212") + str(d_ranked_a select 16) + "\n";                 // "Points needed to call in an air drop: "
_str = _str + (localize "STR_SYS_1213") + str(d_ranked_a select 18) + "\n";                      // "Points for transporting other players: "
_str = _str + (localize "STR_SYS_359") + str(d_transport_distance) + "\n"; // "Transport distance to get points: "
_str = _str + (localize "STR_SYS_1214") + (d_wreck_lift_rank call XGetRankStringLocalized) + "\n"; //"Rank needed to fly the wreck lift chopper: "
#endif

_str = _str + (localize "STR_SYS_1215"); // "Weapons limited: "
if (d_limit_weapons) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

_str = _str + (localize "STR_SYS_1216") + str(d_drop_radius) + " м.\n";           // "Air drop radius (0 = exact position): "

_str = _str + (localize "STR_SYS_1217") + str(x_reload_time_factor) + " сек.\n"; // "Reload/refuel/repair time factor: "

_str = _str + (localize "STR_SYS_361") ;            // "Engine gets shut off on service point: "
if (d_reload_engineoff) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

#ifdef __LIMITED_REFUELING__
_str = _str + format[localize "STR_SYS_06", d_refuel_volume]; // "Engineer refueling is limited to (litres): %1"
#else
_str = _str + localize "STR_SYS_05"; // "Engineer refueling is unlimited: yes"
#endif 

_str = _str + (localize "STR_SYS_362")/* "Десантирование активно: " */;
if (!d_no_para_at_all) then {
	_str = _str + (localize "STR_SYS_363")/* "Да, доступно на базе: " */;
	if (d_para_at_base) then {
		_str = _str + _strYesCR;
	} else {
		_str = _str + _strNoCR;
	};
	if (d_para_at_base) then {
		_str = _str + format[localize "STR_SYS_364"/* "Периодичность десантирования от флага на базе: %1 сек." */,d_para_timer_base] +"\n";
	};
	_str = _str + format[localize "STR_SYS_365"/* "Начальная высота десантирования: %1 м." */,d_halo_height] + "\n";
	if (d_jumpflag_vec != "") then {
		_str = _str + format[localize "STR_SYS_366"/* "Создание транспорта у флага в городе вместо прыжка: %1 " */, d_jumpflag_vec] + "\n";
	};
} else {
	_str = _str + _strNoCR;
};

_str = _str + localize "STR_SYS_370"; // "Use GDT Mod Tracked routine to prevent tanks falling on their back: "
if (d_use_mod_tracked) then { _str = _str + _strYesCR }
					   else { _str = _str + _strNoCR };

_str = _str + format[localize "STR_SYS_367" /* "Максимальная дистанция между оператором и точкой нанесения артудара: %1 м." */,d_arti_operator_max_dist] + "\n";
_str = _str + format[localize "STR_SYS_368" /* "Время перезарядки  между двумя артиллерийскими залпами: %1 сек." */,d_arti_reload_time] + "\n";
_str = _str + format [localize "STR_SYS_371", d_arti_available_time, d_arti_available_time + 200, d_arti_available_time + 400] + "\n"; // "Artillery available again after 1, 2, 3 salvoes: %1, %2, %3 secs"
_str = _str + localize "STR_SYS_372"; // "Check for allied units in the vicinity of artillery target: "
if (d_arti_check_for_friendlies) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};
_str = _str + localize "STR_SYS_373" + str(d_drop_max_dist) + localize "STR_SYS_373_1";

_str = _str + localize "STR_SYS_374" + str(d_player_air_autokick) + " сек.\n"; // "Player autokick time (kicked out of tanks, planes, choppers for the first seconds): "

#ifdef __REVIVE__
//_str = _str + "Player starts with the following number of lives (Revive): " + str(d_NORRN_max_respawns) + "\n";
//_str = _str + "Respawn button after: " + str(d_NORRN_respawn_button_timer) + "\n";
//_str = _str + "Revive time limit: " + str(d_NORRN_revive_time_limit) + "\n";
//_str = _str + "Number of heals: " + str(d_NORRN_no_of_heals) + "\n";
//_str = _str + "With Queens Gambit animations: " + str(d_with_qg_anims) + "\n";
#endif

_str = _str + (localize "STR_SET_15"); // "Enemy vehicles are locked: "
if (d_lock_ai_armor) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

_str = _str + (localize "STR_SET_16"); // "Enemy cars blocked: "
if (d_lock_ai_car) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

_str = _str + (localize "STR_SET_17");
if (d_lock_ai_air) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

if (d_show_chopper_hud) then {
	_str = _str + (localize "STR_SET_18"); //"Head-Up Display в вертолётах: "
	if (d_chophud_on) then {
		_str = _str + _strYesCR;
	} else {
		_str = _str + "нет\n";
	};
};

_str = _str + (localize "STR_SET_19");
if (d_show_chopper_welcome) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

_str = _str + (localize "STR_SET_20");
if (d_show_vehicle_welcome) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

#ifndef __ACE__
_str = _str + "Found and using DM smoke grenade view block: ";
if (d_found_DMSmokeGrenadeVB) then {
	_str = _str + _strYesCR + "\n";
} else {
	_str = _str + _strNoCR + "\n";
};
#endif

#ifdef __ACE__
_str = _str + (localize "STR_SYS_369")/* "С картой АСЕ: " */;
if (d_with_ace_map) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

_str = _str + localize "STR_SYS_253"; // "Wind impact to heli: "
if (d_with_wind_effect) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};
#endif

_str = _str + localize "STR_SET_21"; // "Island repair stations can repair vehicles: "
if (d_with_repstations) then {
	_str = _str + _strYesCR;
} else {
	_str = _str + _strNoCR;
};

// TODO: add difficalty settings from "server.ArmAProfile"




// don't forget to add \n, but not when adding the last string part

_ctrl ctrlSetText _str;

_ctrl = _XD_display displayCtrl 2008;

_str = "";
_counter = 0;
for "_i" from 0 to (count d_is_medic - 1) do {
	call compile format ["
		if (!isNull %1 && isPlayer %1) then {
			if (_counter > 0) then {
				_str = _str + "", "";
			};
			_str = _str + (name %1);
			_counter = _counter + 1;
		};
	", d_is_medic select _i];
};

if (_str == "") then {
	_str = localize "STR_SYS_110"; //"Игроки в роли медика отсутствуют..."
};

_ctrl ctrlSetText _str;

_ctrl = _XD_display displayCtrl 2009;

_str = "";
_counter = 0;
for "_i" from 0 to (count d_can_use_artillery - 1) do {
	call compile format ["
		if (!isNull %1 && isPlayer %1) then {
			if (_counter > 0) then {
				_str = _str + "", "";
			};
			_str = _str + (name %1);
			_counter = _counter + 1;
		};
	", d_can_use_artillery select _i];
};

if (_str == "") then {
	_str = localize "STR_SYS_111"; // "Игроки в роли артиллериста-спасателя отсутствуют..."
};

_ctrl ctrlSetText _str;

_ctrl = _XD_display displayCtrl 2010;

_str = "";
_counter = 0;
for "_i" from 0 to (count d_is_engineer - 1) do {
	call compile format ["
		if (!isNull %1 && isPlayer %1) then {
			if (_counter > 0) then {
				_str = _str + "", "";
			};
			_str = _str + (name %1);
			_counter = _counter + 1;
		};
	", d_is_engineer select _i];
};

if (_str == "") then {
	_str = localize "STR_SYS_112"; // "Игроки в роли военного инженера отсутствуют..."
};

_ctrl ctrlSetText _str;

/**
 * ===================== RUMOR DIALOG ==========================
 *
 *
 */
 
_ctrl = _XD_display displayCtrl GRU_DIALOG_ID; // Intel info (GRU)
if ( isNil "player_is_on_town_raid" ) then {
	_str = localize "STR_SYS_55" + "\n";
	if ( !isNull (call SYG_getGRUComp) ) then {
		_str = _str + localize "STR_GRU_44" + "\n";
	};
	if (!isNil "d_on_base_groups") then {
	    _cnt = 0;
	    {
	        _cnt = _cnt + ({alive _x} count (units _x));
	    } forEach d_on_base_groups;

		if (_cnt == 0) exitWith {
	        _str = _str + localize "STR_GRU_47" + "\n";
		};
		switch (sideradio_status)  do {
			case 0: {
				_str = _str + localize "STR_RADAR_INFO" + "\n";
				if (alive d_radar_truck) then {
					if (locked d_radar_truck) then { _str = _str + localize "STR_RADAR_INIT2" + "\n"; };
				};
				if (alive d_radar) then {
					if ( (vectorUp d_radar_truck) distance [0,0,1] > 0.1) then { _str = _str + localize "STR_RADAR_INIT" + "\n"; };
				};
			};
			case 1: { _str = _str + localize "STR_RADAR_TRUCK_MAST_INSTALLED" + "\n" };
			case 2: { _str = _str + localize "STR_RADAR_SUCCESSFUL" + "\n" };
		};
	    if ( _cnt < 3 ) exitWith {
	        _str = _str + localize "STR_GRU_47_0" + "\n";
	    };
	    if ( _cnt < 6 ) exitWith {
	        _str = _str + localize "STR_GRU_47_1" + "\n";
	    };
        _str = _str + localize "STR_GRU_47_2" + "\n";
	};
	_str = _str + localize "STR_SYS_56" + "\n"; // "Just a rumor:"
} else {
	_str1 = [time, argp(player_is_on_town_raid,3)] call SYG_timeDiffToStr;
	_str = format[localize "STR_SYS_606", argp(player_is_on_town_raid,0), argp(player_is_on_town_raid,1), argp(player_is_on_town_raid,2), _str1]
		+ "\n\n"
		+ localize "STR_SYS_56_1"
		+ "\n"""; // GRU mission etc ...;
};

// Check for last infiltation time
if (__HasGVar(INFILTRATION_TIME)) then {
    _date = __GetGVar(INFILTRATION_TIME);
    _str = _str + format[localize "STR_GRU_55", _date call SYG_dateToStr] + "\n";
} else {
    _str = _str + format[localize "STR_GRU_52"] + "\n";
};
#ifdef __DEBUG__
hint localize format["__HasGVar(INFILTRATION_TIME)=%1:__GetGVar(INFILTRATION_TIME)=%2,",__HasGVar(INFILTRATION_TIME), __GetGVar(INFILTRATION_TIME) ];
#endif
// check for patrol number
if (__HasGVar(PATROL_COUNT)) then {
    _counter = __GetGVar(PATROL_COUNT);
    if ( _counter > 0 ) then {
        _str = _str + format[localize "STR_GRU_50", _counter] + "\n";
    } else {
        _str = _str + (localize "STR_GRU_51") + "\n";
    };
};
#ifdef __DEBUG__
    hint localize format["__HasGVar(PATROL_COUNT)=%1:__GetGVar(PATROL_COUNT)=%2,",__HasGVar(PATROL_COUNT), __GetGVar(PATROL_COUNT) ];
#endif
_str1 = call SYG_getRumourText;
_str = _str + _str1;

_ctrl ctrlSetText _str;

waitUntil {!dialog || !alive player};

if (!alive player) then {
	closeDialog 11251;
};

if (true) exitWith {};