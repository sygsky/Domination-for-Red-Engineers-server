//
// by Xeno. x_scripts/x_settingsdialog.sqf, runs only on client computer
//
private ["_ok", "_XD_display", "_ctrl", "_rarray", "_vdindex", "_i", "_index", "_glindex", "_mindex", "_str","_str1", "_strYes","_strNo","_ar", "_counter",
		  "_name1", "_name2", "_name3"];

#include "x_setup.sqf"
#include "x_macros.sqf"
#include "global_vars.sqf"

//#define __DEBUG__

#define GRU_DIALOG_ID 2011
 
_ok = createDialog "XD_SettingsDialog";

_XD_display = findDisplay 11251;

_ctrl = _XD_display displayCtrl 1000;
//_rarray = [900, 1000, 1200, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 10000];
_rarray = [1500, 2000, 2500, 3000, 3500, 4000, 5000, 6000, 7000, 8000, 9000, 10000];
_vdindex = -1;
for "_i" from 0 to (count _rarray - 1) do {
	call compile format ["_index = _ctrl lbAdd ""%1"";if (d_viewdistance == %1) then {_vdindex = _index};",_rarray select _i];
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

_ctrl = _XD_display displayCtrl 2007;

_strYes = localize "STR_SYS_400";   // "Yes\n"
_strYes1 = localize "STR_SYS_400_1";// "Yes"
_strNo = localize "STR_SYS_401";    // "No\n"
_strNo1 = localize "STR_SYS_401_1"; // "No"

_str = format[localize "STR_SYS_254", d_own_side, d_enemy_side, getText(configFile>>"CfgWorlds">>worldName>>"description")]; // "Ваша сторона: %1. Враги: %2. Остров: %3\n"

if (__ACEVer || __CSLAVer) then {
	if (__ACEVer) then {
		_str = _str + (localize "STR_SET_1")/* "Версия" */ + ": A.C.E.";
	} else {
		_str = _str + (localize "STR_SET_1")/* "Версия" */ + ": CSLA. ";
	};
};

_str = _str + ". " + (localize "STR_SET_2")/* "С АИ" */ + ": ";
#ifdef __AI__
_str = _str + _strYes1; //"Да"
#else
_str = _str + _strNo1; // "Нет"
#endif

_str = _str + ". " + (localize "STR_SET_3")/* "Ранговая" */ + ": ";
#ifdef __RANKED__
_str = _str + _strYes;
#else
_str = _str + _strNo;
#endif

//+++ 11-JUN-2018
_str = _str + (localize "STR_SET_5")/* Javelin" */ + ": ";
#ifdef __JAVELIN__
_str = _str + _strYes;
#else
_str = _str + _strNo;
#endif


_str = _str + (localize "STR_SET_6") + ": "; // "Simple side missions at the beginning"
#ifdef __EASY_SM_GO_FIRST__
_str = _str + _strYes;
#else
_str = _str + _strNo;
#endif

_str = _str + (localize "STR_SET_7") + ": "; // "Light vehicle[s] at the base in the beginning"
#ifdef __ADDITIONAL_BASE_VEHICLES__
_str = _str + _strYes;
#else
_str = _str + _strNo;
#endif

// Engineering Fund
_str = _str + (localize "STR_SYS_137_5") + ": "; // "The Engineering Fund"
#ifdef __REP_SERVICE_FROM_ENGINEERING_FUND__
_str = _str + format["%1",SYG_engineering_fund] + "\n";
#else
_str = _str + _strNo;
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
_str = _str + ": " + _strNo;
#endif

_str = _str + (localize "STR_SET_9") + ": "; // "Teleport works only when all services on the base are available"
#ifdef __TELEPORT_ONLY_WHEN_ALL_SERVICES_ARE_VALID__
_str = _str + _strYes;
#else
_str = _str + _strNo;
#endif

_str = _str + (localize "STR_SET_10") ; // "Jail"
#ifdef __JAIL_MAX_SCORE__
_str = _str + format[localize "STR_SET_10_1",__JAIL_MAX_SCORE__] + "\n";
#else
_str = _str + ": " + _strNo;
#endif

_str = _str + (localize "STR_SET_11") + ": "; // "Clone RPG missiles"
#ifndef __NO_RPG_CLONING__
_str = _str + _strYes;
#else
_str = _str + ": " + _strNo;
#endif

//---

_str = _str + (localize "STR_SET_4")/* "С возможность оживлять" */+": ";
#ifdef __REVIVE__
_str = _str + _strYes1 +". ";
#else
_str = _str + _strNo1 + ". ";
#endif

_str = _str + (localize "STR_SET_13");// "Mando missiles pack: "
#ifdef __MANDO__
_str = _str + _strYes1 +". ";
#else
_str = _str + _strNo1 + ". ";
#endif

// _str = _str + "Версия: " + d_version_string + "\n";

_str = _str + (localize "STR_SET_14");//"Built-in ruksack: ";
if (d_use_backpack) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

_str = _str + (localize "STR_SYS_343")/* "Отображение маркера с именем игрока: " */;
if (d_show_player_marker_names) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

_str = _str + (localize "STR_SYS_344")/* "Отображение направления движения у маркера игрока: " */;
if (d_p_marker_dirs) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

_str = _str + (localize "STR_SYS_345")/* "Отображение напр. движения маркеров техники: " */;
if (d_v_marker_dirs) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

_str = _str + (localize "STR_SYS_346")/* "Тип маркера игрока: " */ + d_p_marker + "\n";

_str = _str + "Меню статус включено: ";
if (d_use_teamstatusdialog) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

_str = _str + (localize "STR_SYS_347")/* "Выгрузка техники из мобильного респауна: " */;
for "_i" from 0 to (count d_create_bike - 1) do {
	_str = _str + ([d_create_bike select _i,0] call XfGetDisplayName);
	if (_i < (count d_create_bike - 1)) then {
		_str = _str + ", ";
	};
};
_str = _str + "\n";

_str = _str + "Время между выгрузками техники из мобильного респауна: " + str(d_remove_mhq_vec_time) + "\n";

if (count d_only_pilots_can_fly > 0) then {
	_str = _str + "Возможность летать: ";
	for "_i" from 0 to (count d_only_pilots_can_fly - 1) do {
		_str = _str + (d_only_pilots_can_fly select _i);
		if (_i < (count d_only_pilots_can_fly - 1)) then {
			_str = _str + ", ";
		};
	};
	_str = _str + "\n";
};

_str = _str + "Ящики снабжения: максимально " + str(max_number_ammoboxes) + ", активированы: " + str(ammo_boxes) + "\n";

_str = _str + "Время ожидания между загрузкой/выгрузкой ящиков: " + str(d_drop_ammobox_time) + "\n";

_str = _str + "Максимальное кол-во статических объектов в грузовике военного инженера: " + str(max_truck_cargo) + "\n";


_str = _str + "Транспорт, способный загружать ящики снабжения: ";
for "_i" from 0 to (count d_check_ammo_load_vecs - 1) do {
	if (_i > 0) then { _str1 = ", '%1'";}
	else {_str1 = "'%1'";};
	_str = _str + format[_str1, ([d_check_ammo_load_vecs select _i,0] call XfGetDisplayName)];
};
_str = _str + "\n";

_str = _str + "Время возрождения (в сек.): " + str(D_RESPAWN_DELAY) + "\n";

if (!isNil "d_with_respawn_dialog_after_death") then {
	_str = _str + "Диалог выбора места возрождения после смерти: ";
	if (d_with_respawn_dialog_after_death) then {
		_str = _str + _strYes;
	} else {
		_str = _str + _strNo;
	};
};

_str = _str + (localize "STR_SYS_348")/* "Система погодных явлений: " */;
if (d_weather) then {
	_str = _str + _strYes1 + ". ";
} else {
	_str = _str + _strNo1 + ". ";
};
_str = _str + format["%1: ",localize "STR_WET_22"]; // + "Туман: "
if (d_weather_fog) then {
	_str = _str + _strYes1 + ". ";
} else {
	_str = _str + _strNo1 + ". ";
};
_str = _str + format["%1: ",localize "STR_WET_23"]; // "Песчаная буря: "
if (d_weather_sandstorm) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

_str = _str + (localize "STR_SYS_349"); // "Пулемётчики могут развёртывать пулемётные гнезда: "
if (d_with_mgnest) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

#ifndef __REVIVE__
_str = _str + (localize "STR_SYS_1200"); // "Respawn with same weapons after death: "
if (x_weapon_respawn) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};
#endif

#ifdef __AI__
_str = _str + (localize "STR_SYS_1201") + str(max_ai) + "\n"; // "Maximum number of AI that can get recruited: "
#endif

_str = _str + localize"STR_SYS_350" + str(d_sub_tk_points) + "\n"; // "Points a player looses for teamkill: "

#ifdef __RANKED__
_str = _str + "Очков вычитается за смерть: " + str(abs(d_sub_kill_points)) + "\n"; // "Player points that get subtracted after death: "
_str = _str + "Очков необходимо инженеру для обслуживания техники: " + str(d_ranked_a select 0) + "\n"; // "Points an engineer needs to service a vehicle: "
_str = _str + "Инженер получает очков за ремонт:\n";                                                    // "Points an engineer gets for servicing: "
_str = _str + "Авиатехника: " + str((d_ranked_a select 1) select 0) + ", бронетехника: " + str((d_ranked_a select 1) select 1) + ", транспорт: " + str((d_ranked_a select 1) select 2) + "\n"; // (air vec), (tank), (car)
_str = _str + "Инженер получает очков за ремонт (прочее): " + str((d_ranked_a select 1) select 3) + "\n"; // (other)
_str = _str + "Очков списывается с инженера за ремонт сервисов на базе: " + str(d_ranked_a select 13) + "\n";   // "Points an engineer needs to rebuild the support buildings at base: "
_str = _str + "Очков списывается за вызов одного залпа артиллерии: " + str(d_ranked_a select 2) + "\n";         // "Points an artillery operator needs for a strike: "
if (__AIVer) then {
	_str = _str + "Очков за найм одного АИ: " + str(d_ranked_a select 3) + "\n";            // "Points needed to recuruit one AI soldier: "
	_str = _str + "Очков за вызов вертолётного такси: " + str(d_ranked_a select 15) + "\n"; // "Points needed to call in an air taxi: "
};
_str = _str + "Очков необходимо для десантирования: " + str(d_ranked_a select 4) + "\n";    // "Points needed for AAHALO parajump: "
_str = _str + "Очков необходимо для выгрузки техники из мобильного респауна: " + str(d_ranked_a select 6) + "\n"; // "Points needed to create a vehicle at a MHQ: "
_str = _str + "Очков вычитается за выгрузку техники из мобильного респауна: " + str(d_ranked_a select 5) + "\n";  // "Points that get subtracted for creating a vehicle at a MHQ: "
_str = _str + (localize "STR_SYS_351") + str(d_ranked_a select 7) + "\n"; // "Points a medic gets if someone heals at his Mash: "
_str = _str + (localize "STR_SYS_352") + str(d_ranked_a select 17) + "\n";          // "Points a medic gets if he heals another unit: "

_ar = d_ranked_a select 8;
_str = _str + (localize "STR_SYS_353")/* "Требуемое звание для управления лёгкой бронетехникой: " */ + ((_ar select 0) call XGetRankStringLocalized) + "\n";
_str = _str + (localize "STR_SYS_354")/* "Требуемое звание для управления бронетехникой: " */ + ((_ar select 1) call XGetRankStringLocalized) + "\n";
_str = _str + (localize "STR_SYS_355")/* "Требуемое звание для управления боевыми вертолётами: " */ + ((_ar select 2) call XGetRankStringLocalized) + "\n";
_str = _str + (localize "STR_SYS_356")/* "Требуемое звание для управления самолётами: " */ + ((_ar select 3) call XGetRankStringLocalized) + "\n";


_str = _str + format [localize "STR_SYS_357"/* "Очков за выполнение основной задачи, игрок в радиусе %1 м. от центра города: " */,d_ranked_a select 10] + str(d_ranked_a select 9) + "\n";
_str = _str + format [localize "STR_SYS_358"/* "Очков за выполнение дополнительной задачи, игрок в радиусе %1 м. от места операции: " */,d_ranked_a select 12] + str(d_ranked_a select 11) + "\n";

_str = _str + "Очков необходимо для развёртывания пулемётного гнезда: " + str(d_ranked_a select 14) + "\n"; // "Points needed to build a mg nest: "
_str = _str + "Очков необходимо для вызова снабжения: " + str(d_ranked_a select 16) + "\n";                 // "Points needed to call in an air drop: "
_str = _str + "Очков за транспортировку игроков: " + str(d_ranked_a select 18) + "\n";                      // "Points for transporting other players: "
_str = _str + (localize "STR_SYS_359") + str(d_transport_distance) + "\n"; // "Transport distance to get points: "
_str = _str + "Звание, разрешающее пилотирование вертолёта для переноски подбитой техники: " + (d_wreck_lift_rank call XGetRankStringLocalized) + "\n"; //"Rank needed to fly the wreck lift chopper: "
#endif

_str = _str + "Лимит вооружения: "; // "Weapons limited: "
if (d_limit_weapons) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

_str = _str + "Радиус сброса снабжения (0 = точная позиция): " + str(d_drop_radius) + " м.\n";           // "Air drop radius (0 = exact position): "

_str = _str + "Время 1-го цикла перезарядки/заправки/ремонта: " + str(x_reload_time_factor) + " сек.\n"; // "Reload/refuel/repair time factor: "

_str = _str + (localize "STR_SYS_361") ;            // "Engine gets shut off on service point: "
if (d_reload_engineoff) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

#ifdef __LIMITED_REFUELLING__
_str = _str + format[localize "STR_SYS_06", d_refuel_volume]; // "Engineer refuelling is limited to (litres): %1"
#else
_str = _str + localize "STR_SYS_05"; // "Engineer refuelling is unlimited: yes"
#endif 

_str = _str + (localize "STR_SYS_362")/* "Десантирование активно: " */;
if (!d_no_para_at_all) then {
	_str = _str + (localize "STR_SYS_363")/* "Да, доступно на базе: " */;
	if (d_para_at_base) then {
		_str = _str + _strYes;
	} else {
		_str = _str + _strNo;
	};
	if (d_para_at_base) then {
		_str = _str + format[localize "STR_SYS_364"/* "Периодичность десантирования от флага на базе: %1 сек." */,d_para_timer_base] +"\n";
	};
	_str = _str + format[localize "STR_SYS_365"/* "Начальная высота десантирования: %1 м." */,d_halo_height] + "\n";
	if (d_jumpflag_vec != "") then {
		_str = _str + format[localize "STR_SYS_366"/* "Создание транспорта у флага в городе вместо прыжка: %1 " */, d_jumpflag_vec] + "\n";
	};
} else {
	_str = _str + _strNo;
};

/* if (!d_no_para_at_all) then {
	_str = _str + "Десантирование доступно на базе: ";
	if (d_para_at_base) then {
		_str = _str + _strYes;
	} else {
		_str = _str + _strNo;
	};
	if (d_para_at_base) then {
		_str = _str + "Периодичность десантирования от флага на базе: " + str(d_para_timer_base) + "\n";
	};
	_str = _str + "Начальная высота десантирования: " + str(d_halo_height) + "\n";
	if (d_jumpflag_vec != "") then {
		_str = _str + "Создание транспорта у флага в городе вместо прыжка: " + d_jumpflag_vec + "\n";
	};
};
 */
_str = _str + localize "STR_SYS_370"; // "Use GDT Mod Tracked routine to prevent tanks falling on their back: "
if (d_use_mod_tracked) then {
	_str = _str + localize "STR_SYS_400";
} else {
	_str = _str + localize "STR_SYS_400_1";
};
_str =_str + "\n";

_str = _str + format[localize "STR_SYS_367" /* "Максимальная дистанция между оператором и точкой нанесения артудара: %1 м." */,d_arti_operator_max_dist] + "\n";
_str = _str + format[localize "STR_SYS_368" /* "Время перезарядки  между двумя артиллерийскими залпами: %1 сек." */,d_arti_reload_time] + "\n";
_str = _str + format [localize "STR_SYS_371", d_arti_available_time, d_arti_available_time + 200, d_arti_available_time + 400] + " сек.\n"; // "Artillery available again after 1, 2, 3 salvoes: %1, %2, %3 secs"
_str = _str + localize "STR_SYS_372"; // "Check for allied units in the vicinity of artillery target: "
if (d_arti_check_for_friendlies) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
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
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

_str = _str + (localize "STR_SET_16"); // "Enemy cars blocked: "
if (d_lock_ai_car) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

_str = _str + "Вражеская авиатехника блокирована: ";
if (d_lock_ai_air) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

if (d_show_chopper_hud) then {
	_str = _str + "Проекционный дисплей в вертолётах: "; //"Head-Up Display в вертолётах: "
	if (d_chophud_on) then {
		_str = _str + _strYes;
	} else {
		_str = _str + "нет\n";
	};
};

_str = _str + "Показывать приветствие в вертолётах: ";
if (d_show_chopper_welcome) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

_str = _str + "Показывать приветствие в технике: ";
if (d_show_vehicle_welcome) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

#ifndef __ACE__
_str = _str + "Found and using DM smoke grenade view block: ";
if (d_found_DMSmokeGrenadeVB) then {
	_str = _str + _strYes + "\n";
} else {
	_str = _str + _strNo + "\n";
};
#endif

#ifdef __ACE__
_str = _str + (localize "STR_SYS_369")/* "С картой АСЕ: " */;
if (d_with_ace_map) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

_str = _str + localize "STR_SYS_253"; // "Влияние ветра на вертолёты: "
if (d_with_wind_effect) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};
#endif

_str = _str + "Наземные ремонтные станции работают: ";
if (d_with_repstations) then {
	_str = _str + _strYes;
} else {
	_str = _str + _strNo;
};

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
 
#define RUMOR_WIDTH (_counter/4)
 
_ctrl = _XD_display displayCtrl GRU_DIALOG_ID; // Intel info (GRU)
if ( isNil "player_is_on_town_raid" ) then
{
	_str = localize "STR_SYS_55" + "\n";
	if ( !isNull (call SYG_getGRUComp) ) then
	{
		_str = _str + localize "STR_GRU_44" + "\n";
	};
	if (!isNil "d_on_base_groups") then
	{
	    _not_empty = false;
	    {
	        if ( ({alive _x} count (units _x)) > 0 ) exitWith {_not_empty = true;};
	    } forEach d_on_base_groups;

	    if ( _not_empty ) then
	    {
	        _str = _str + localize "STR_GRU_47" + "\n";
	    };
	};
	_str = _str + localize "STR_SYS_56" + "\n"; // "Just a rumor:"
}
else
{
	_str = format[localize "STR_SYS_606",argp(player_is_on_town_raid,0),argp(player_is_on_town_raid,1),argp(player_is_on_town_raid,2),[time, argp(player_is_on_town_raid,3)] call SYG_timeDiffToStr] +  "\n\n" + localize "STR_SYS_56_1" + "\n"""; // GRU mission etc ...;
};

// Check for last infiltation time
if (__HasGVar(INFILTRATION_TIME)) then
{
    _date = __GetGVar(INFILTRATION_TIME);
    _str = _str + format[localize "STR_SYS_617", _date call SYG_dateToStr] + "\n";
}
else
{
    _str = _str + format[localize "STR_GRU_52"] + "\n";
};
#ifdef __DEBUG__
hint localize format["__HasGVar(INFILTRATION_TIME)=%1:__GetGVar(INFILTRATION_TIME)=%2,",__HasGVar(INFILTRATION_TIME), __GetGVar(INFILTRATION_TIME) ];
#endif
// check for patrol number
if (__HasGVar(PATROL_COUNT)) then
{
    _counter = __GetGVar(PATROL_COUNT);
    if ( _counter > 0 ) then
    {
        _str = _str + format[localize "STR_GRU_50", _counter] + "\n";
    };
};
#ifdef __DEBUG__
    hint localize format["__HasGVar(PATROL_COUNT)=%1:__GetGVar(PATROL_COUNT)=%2,",__HasGVar(PATROL_COUNT), __GetGVar(PATROL_COUNT) ];
#endif
_daytime = daytime;
if ( _daytime <= SYG_startMorning || _daytime > SYG_startNight ) then {_str1 = localize "STR_RUM_NIGHT";}
else
{
	call compile format["_counter=%1;", localize "STR_RUM_NUM"];
	
	if ( isNil "SYG_rumor_index" ) then 
	{
		SYG_rumor_index = floor (random _counter); // start index for random rumor message
		SYG_rumor_hour  = floor(daytime);
#ifdef __DEBUG__		
		hint localize format["x_settingsdialog.sqf: initial settings SYG_rumor_index %1, SYG_rumor_hour %2",
	                         SYG_rumor_index,SYG_rumor_hour]; 
#endif							 
	};
	
	// get main index of message
	_index = floor(daytime) - SYG_rumor_hour; 
	_rnd   = (random 2.0) - 1.0; // from +1 to -1
	_index = (_index + (floor((_rnd*_rnd*_rnd)*RUMOR_WIDTH)) + SYG_rumor_index) % _counter ;
	if ( _index < 0 ) then
	{
		_index = _counter + _index;
	}
	else
	{
		if ( _index >= _counter ) then
		{
			_index = _index - _counter;
		};
	};
	_str1 = format["STR_RUM_%1",_index];
	_str1 =  (localize _str1) + "\n";
#ifdef __DEBUG__	
	hint localize format["x_settingsdialog.sqf: SYG_rumor_index %1, SYG_rumor_hour %2, _index %3, _rnd %4",
	                         SYG_rumor_index,SYG_rumor_hour,_index,_rnd];
#endif							 
};	
_name1 = (target_names call XfRandomArrayVal) select 1; // random main target name
_name2 = text (player call SYG_nearestLocation); // nearest location name
_name3 = text (player call SYG_nearestSettlement); // nearest settlement name
_str1 = format[_str1, _name1, _name2, _name3]; // just in case of %1 %2 etc
_str = _str + _str1;

_ctrl ctrlSetText _str;

waitUntil {!dialog || !alive player};

if (!alive player) then {
	closeDialog 11251;
};

if (true) exitWith {};