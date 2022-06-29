// x_createguardpatrolgroups.sqf: create/spawn guard and patrol groups for main target (town)
// by Xeno
private ["_selectit", "_array", "_num", "_a_vng", "_num_ret", "_type_list_guard", "_type_list_guard_static",
    "_type_list_patrol", "_type_list_guard_static2", "_trgobj", "_radius", "_selectitmen", "_a_vng2",
    "_number_basic_guard", "_number_specops_guard", "_selectitvec", "_number_tank_guard", "_number_bmp_guard",
    "_number_brdm_guard", "_number_uaz_mg_guard", "_number_uaz_grenade_guard", "_number_basic_patrol",
    "_number_specops_patrol", "_number_tank_patrol", "_number_bmp_patrol", "_number_brdm_patrol",
    "_number_uaz_mg_patrol", "_number_uaz_grenade_patrol", "_number_basic_guardstatic", "_number_specops_guardstatic",
    "_number_tank_guardstatic", "_number_bmp_guardstatic", "_number_shilka_guardstatic", "_number_D30_guardstatic",
    "_number_DSHKM_guardstatic", "_number_AGS_guardstatic", "_trg_center", "_wp_array", "_xx", "_typeidx", "_number_",
    "_xxx", "_wp_ran", "_point", "_agrp", "_xx_ran", "_xpos", "_unit_array", "_units", "_grp_array", "_ammotruck",
    "_fueltruck","_grp","_addnum"];

if (!isServer ) exitWith{};

#define __DEBUG_PRINT__

//#define __TOWN_WEAK_DEFENCE__

#include "x_setup.sqf"
#include "x_macros.sqf"

_selectit = {
	private ["_array","_num","_a_vng","_num_ret"];
	_array = _this select 0;
	_num = _this select 1;
	_a_vng = _array select _num;
	_num_ret = (floor (random (_a_vng select 1))) + 1;
	_num_ret
};

_trgobj  = _this select 0; // main target town description
_trg_center = _trgobj; // center of target town
_isInDesert = _trg_center call SYG_isDesert; // is town in desert region
_tankName = if (_isInDesert) then {"tank_desert"} else {"tank"};  // define protective painting of the tank
//_tankName = "tank";  // define protective painting of the tank

#ifdef __DEBUG_PRINT__
hint localize format["+++ x_createguardpatrolgroups.sqf: point %1, _tankName ""%2""",_trg_center, _tankName];
#endif

_radius  = _this select 1;
_addnum   = if (_radius >= 300) then {1} else {0}; // how many to add to groups for big town

_type_list_guard = [["basic",0],["specops",0],[_tankName,[d_vehicle_numbers_guard, 0] call _selectit],["bmp",[d_vehicle_numbers_guard, 1] call _selectit],["brdm",[d_vehicle_numbers_guard, 2] call _selectit],["uaz_mg",[d_vehicle_numbers_guard, 3] call _selectit],["uaz_grenade",[d_vehicle_numbers_guard, 4] call _selectit]];
sleep 0.01;

_type_list_guard_static = [["basic",0],["specops",0],[_tankName,[d_vehicle_numbers_guard_static, 0] call _selectit],["bmp",[d_vehicle_numbers_guard_static, 1] call _selectit],["shilka",[d_vehicle_numbers_guard_static, 2] call _selectit]];
sleep 0.01;

_type_list_patrol = [["basic",0],["specops",0],[_tankName,[d_vehicle_numbers_patrol, 0] call _selectit],["bmp",[d_vehicle_numbers_patrol, 1] call _selectit],["brdm",[d_vehicle_numbers_patrol, 2] call _selectit],["uaz_mg",[d_vehicle_numbers_patrol, 3] call _selectit],["uaz_grenade",[d_vehicle_numbers_patrol, 4] call _selectit]];

_type_list_guard_static2 = [
#ifndef __TOWN_WEAK_DEFENCE__
["D30",(floor (random 5)) + 1],
#endif
["DSHKM",((floor (random 2)) + 1) + _addnum],["AGS",((floor (random 2)) + 1) + _addnum]];
sleep 0.01;

_selectit = nil;
/*
d_vehicle_numbers_patrol = [
	[[1,1], 1], // tanks
	[[1,1], 1], // apc (bmp)
	[[1,1], 1], // apc2 (brdm)
	[[1,1], 1], // jeep with mg (uaz mg)
	[[1,1], 1] 	// jeep with gl (uaz grenade)
];
[d_vehicle_numbers_patrol, 0] call _selectit;
*/
#ifdef __DEBUG_PRINT__
hint localize "+++ x_createguardpatrolgroups.sqf: type lists prepared";
#endif

_selectitmen = {
	private ["_array","_num","_a_vng2","_num_ret"];
	_array = _this select 0; // [[1,1], 1]
	_num = _this select 1; // 0
	_a_vng2 = _array select _num; // [1,1]
	_num_ret = round (random (_a_vng2 select 0)); // 1
	if (_num_ret < (_a_vng2 select 1)) then {_num_ret = (_a_vng2 select 1);};
	_num_ret
};

_number_basic_guard = _addnum + ([d_footunits_guard, 0] call _selectitmen);
_number_specops_guard = _addnum + ([d_footunits_guard, 1] call _selectitmen);

_selectitvec = {
	private ["_array","_num","_a_vng","_a_vng2","_num_ret"];
	_array = _this select 0;
	_num = _this select 1;
	_a_vng = _array select _num;
	_a_vng2 = _a_vng select 0;
	_num_ret = round (random (_a_vng2 select 0));
	if (_num_ret < (_a_vng2 select 1)) then {_num_ret = (_a_vng2 select 1);};
	_num_ret
};
_number_tank_guard = [d_vehicle_numbers_guard,0] call _selectitvec;
_number_tank_desert_guard = _number_tank_guard;
sleep 0.01;
_number_bmp_guard = [d_vehicle_numbers_guard,1] call _selectitvec;
sleep 0.01;
_number_brdm_guard = [d_vehicle_numbers_guard,2] call _selectitvec;
sleep 0.01;
_number_uaz_mg_guard = [d_vehicle_numbers_guard,3] call _selectitvec;
sleep 0.01;
_number_uaz_grenade_guard = _addnum + ([d_vehicle_numbers_guard,4] call _selectitvec);
sleep 0.01;

_number_basic_patrol = _addnum + ([d_footunits_patrol, 0] call _selectitmen);
sleep 0.01;
_number_specops_patrol = _addnum + ([d_footunits_patrol, 1] call _selectitmen);
sleep 0.01;
_number_tank_patrol = _addnum + ([d_vehicle_numbers_patrol,0] call _selectitvec);
_number_tank_desert_patrol = _number_tank_patrol;
sleep 0.01;
_number_bmp_patrol = [d_vehicle_numbers_patrol,1] call _selectitvec;
sleep 0.01;
_number_brdm_patrol = [d_vehicle_numbers_patrol,2] call _selectitvec;
sleep 0.01;
_number_uaz_mg_patrol = [d_vehicle_numbers_patrol,3] call _selectitvec;
sleep 0.01;
_number_uaz_grenade_patrol = _addnum + ([d_vehicle_numbers_patrol,4] call _selectitvec);
sleep 0.01;

_number_basic_guardstatic = [d_footunits_guard_static, 0] call _selectitmen;
sleep 0.01;
_number_specops_guardstatic = [d_footunits_guard_static, 1] call _selectitmen;
sleep 0.01;
_number_tank_guardstatic = [d_vehicle_numbers_guard_static,0] call _selectitvec;
_number_tank_desert_guardstatic = _number_tank_guardstatic;
sleep 0.01;
_number_bmp_guardstatic = [d_vehicle_numbers_guard_static,1] call _selectitvec;
sleep 0.01;
_number_shilka_guardstatic = _addnum + ([d_vehicle_numbers_guard_static,2] call _selectitvec);
sleep 0.01;
_number_D30_guardstatic = 1;
sleep 0.01;
_number_DSHKM_guardstatic = (floor (random 4)) + 1;
sleep 0.01;
_number_AGS_guardstatic = (floor (random 3)) + 1;
sleep 0.01;

_selectitmen = nil;
_selectitvec = nil;

_wp_array = [_trg_center, _radius] call x_getwparray;

sleep 0.112;

#ifndef __TOWN_WEAK_DEFENCE__ // compiled if not a weak defence defined

// Static weapons (canons, M2, AGS, TOW etc)
for "_xx" from 0 to (count _type_list_guard - 1) do {
	_typeidx = _type_list_guard select _xx;
	call compile format["if (_number_%1_guard > 0) then {for ""_xxx"" from 1 to _number_%1_guard do {_wp_ran = (count _wp_array) call XfRandomFloor;[_typeidx select 0, [_wp_array select _wp_ran], _trg_center, _typeidx select 1, ""guard"",d_enemy_side,0,-1.111] execVM ""x_scripts\x_makegroup.sqf"";_wp_array set [_wp_ran, ""X_RM_ME""];_wp_array = _wp_array - [""X_RM_ME""];sleep 1.123;};};",_typeidx select 0];
};

sleep 0.233;

// guard static vehicles (tanks, bmps, shilkas etc) in one group
_agrp = call SYG_createEnemyGroup;
for "_xx" from 0 to (count _type_list_guard_static - 1) do {
	_typeidx = _type_list_guard_static select _xx;
	call compile format["if (_number_%1_guardstatic > 0) then {for ""_xxx"" from 1 to _number_%1_guardstatic do {_wp_ran = (count _wp_array) call XfRandomFloor;[_typeidx select 0, [_wp_array select _wp_ran], _trg_center, _typeidx select 1, ""guardstatic"",d_enemy_side,_agrp,-1.111] execVM ""x_scripts\x_makegroup.sqf"";_wp_array set [_wp_ran, ""X_RM_ME""];_wp_array = _wp_array - [""X_RM_ME""];sleep 1.123;};};",_typeidx select 0];
};
#endif

#ifdef __DEBUG_PRINT__
hint localize "+++ x_createguardpatrolgroups.sqf: guard static vehicles prepared";
#endif

// create common group of static weapons: mg, at, aa, canons etc
//while {!can_create_group} do {sleep 0.1 + random (0.2)}; //__WaitForGroup
//_grp = [d_enemy_side] call x_creategroup;
_grp = call SYG_createEnemyGroup;
for "_xx" from 0 to (count _type_list_guard_static2 - 1) do {
	_typeidx = _type_list_guard_static2 select _xx;
	call compile format["
		if (_number_%1_guardstatic > 0) then {
			for ""_xxx"" from 1 to _number_%1_guardstatic do {
				_wp_ran = (count _wp_array) call XfRandomFloor;
				if ((_typeidx select 0) != ""D30"") then {
					[_typeidx select 0, [_wp_array select _wp_ran], _trg_center, _typeidx select 1, ""guardstatic2"",d_enemy_side,_grp,-1.111] execVM ""x_scripts\x_makegroup.sqf"";
					_wp_array set [_wp_ran, ""X_RM_ME""];
					_wp_array = _wp_array - [""X_RM_ME""];
				} else {
					_point = [_trg_center, _radius] call XfGetRanPointCircleBig;
					_ccc = 0;
					while {count _point == 0 && _ccc < 100} do {
						_point = [_trg_center, _radius] call XfGetRanPointCircleBig;
						_ccc = _ccc + 1;
						sleep 0.04;
					};
					[_typeidx select 0, [_point], _trg_center, _typeidx select 1, ""guardstatic2"",d_enemy_side,_grp,-1.111] execVM ""x_scripts\x_makegroup.sqf"";
				};
				sleep 1.123;
			};
		};
	",_typeidx select 0];
};

#ifdef __DEBUG_PRINT__
hint localize "+++ x_createguardpatrolgroups.sqf: groups created";
#endif

//#define __PRINT__
#ifdef __PRINT__
_array = [];
_driver_cnt = 0;
{
	if (vehicle _x != _x) then {
		if ( ! (vehicle _x in _array) ) then {
			_array = _array + [vehicle _x];
		};
		_driver_cnt = _driver_cnt + 1;
	};
} forEach units _grp;
_array_veh = _trg_center nearObjects ["StaticWeapon", _radius + 50];
/* for "_i" from 0 to count _array_veh - 1 do
{
	_array_veh set[ _i, typeOf (_array_veh select _i) ];
};
 */
hint localize format[ "+++ x_createguardpatrolgroups.sqf: StaticWeapon men %1, drivers %5, vecs analized %2, vecs found %3, job list %4", count units _grp, count _array, count _array_veh, _type_list_guard_static2, _driver_cnt ];
_array = [];
#endif

#ifndef __TOWN_WEAK_DEFENCE__ // compiled if not a weak defence defined
// patrol groups (infantry, BMPs, tanks etc)
for "_xx" from 0 to (count _type_list_patrol - 1) do {
	_typeidx = _type_list_patrol select _xx;
	call compile format["if (_number_%1_patrol > 0) then {for ""_xxx"" from 1 to _number_%1_patrol do {_wp_ran = (count _wp_array) call XfRandomFloor;[_typeidx select 0, [_wp_array select _wp_ran], _trg_center, _typeidx select 1, ""patrol"",d_enemy_side,0,-1.111,[_trg_center, _radius]] execVM ""x_scripts\x_makegroup.sqf"";_wp_array set [_wp_ran, ""X_RM_ME""];_wp_array = _wp_array - [""X_RM_ME""];sleep 1.123;};};",_typeidx select 0];
};

_type_list_guard = nil;
_type_list_guard_static = nil;
_type_list_patrol = nil;
_type_list_guard_static2 = nil;

sleep 2.124;

// Create group of trucks (repair, reammo, refuel)
//while {!can_create_group} do {sleep 0.1 + random (0.2)};//__WaitForGroup
//_agrp = [d_enemy_side] call x_creategroup; //__GetEGrp(_agrp)

_agrp = call SYG_createEnemyGroup;

_xx_ran = (count _wp_array) call XfRandomFloor;
_xpos = _wp_array select _xx_ran;
_wp_array set [_xx_ran, "X_RM_ME"];
_wp_array = _wp_array - ["X_RM_ME"];
_unit_array = ["uralrep", d_enemy_side] call x_getunitliste;
sleep 0.121;
[1, _xpos, (_unit_array select 2), (_unit_array select 1), _agrp, 0,-1.111,true] call x_makevgroup;
sleep 0.121;
_unit_array = ["uralfuel", d_enemy_side] call x_getunitliste;
sleep 0.121;
_fueltruck = [1, _xpos, (_unit_array select 2), (_unit_array select 1), _agrp, 0,-1.111,true] call x_makevgroup;
(_fueltruck select 0) setFuelCargo 1; // add full fuel cargo for this truck
sleep 0.121;
_unit_array = ["uralammo", d_enemy_side] call x_getunitliste;
sleep 0.121;
_ammotruck = [1, _xpos, (_unit_array select 2), (_unit_array select 1), _agrp, 0,-1.111,true] call x_makevgroup;

_unit_array = nil;
_xpos = nil;
#endif

sleep 2.124;

#ifdef __TOWN_WEAK_DEFENCE__
	no_more_observers = true; // skip observers for this define
#endif
// create observers in the town
if (!no_more_observers) then {
	// artillery observers
	nr_observers = (2 + (floor random 2)) max 2; // 2 or 3
	Observer1 = objNull;
	Observer2 = objNull;
	Observer3 = objNull;

	update_observers = -1;

	_unit_array = ["artiobserver", d_enemy_side] call x_getunitliste;
//	hint localize format["x_scripts\x_createguardpatrolgroups.sqf: observers cnt %1, type %2", nr_observers, _unit_array select 0];
//	_cnt = 0;
	for "_xx" from 1 to nr_observers do {
		//__WaitForGroup
		//__GetEGrp(_agrp)
	    _agrp = call SYG_createEnemyGroup;
		_xx_ran = (count _wp_array) call XfRandomFloor;
		_xpos = _wp_array select _xx_ran;
		_wp_array set [_xx_ran, "X_RM_ME"];
		_wp_array = _wp_array - ["X_RM_ME"];
		_units = [_xpos, (_unit_array select 0), _agrp,true] call x_makemgroup;
		_agrp setFormation "COLUMN";
		_agrp setSpeedMode "FULL"; // twas "LIMITED"
		_agrp setBehaviour "SAFE";
		_agrp setCombatMode "YELLOW";
		_grp_array = [_agrp, _xpos, 0,[_trg_center, _radius],[],-1,0,[],50,0];
		
		//+++ Sygsky: rearm spotter[s]
		{ [_x, 1.0, 0.99] call SYG_rearmSpotter } forEach units _agrp;
		//--- Sygsky
		// _cnt = _cnt + count units _agrp;
		_grp_array execVM "x_scripts\x_groupsm.sqf";
		call compile format ["
			Observer%1 = _units select 0;
			Observer%1 addEventHandler [""killed"", {Observer%1 = objNull;call SAddObserverKillScores;nr_observers = nr_observers - 1;if (nr_observers <= 0) then {update_observers = -1; [""update_observers"",update_observers] call XSendNetStartScriptClient;}}];
		",_xx];
		sleep 1.231;
	};
//	hint localize format["x_scripts\x_createguardpatrolgroups.sqf: observers to create %1, type %2, created %3", nr_observers, _unit_array select 0, _cnt];

	update_observers = nr_observers;
	["update_observers",update_observers] call XSendNetStartScriptClient;

	(_unit_array select 0) execVM "x_scripts\x_handleobservers.sqf";
	_unit_array = nil;
	sleep 2.214;
	#ifdef __DEBUG_PRINT__
	hint localize "+++ x_createguardpatrolgroups.sqf: observers prepared";
	#endif

} else {
//  inform about observer absence
//	hint localize "x_scripts\x_createguardpatrolgroups.sqf: no_more_observers = true";
	["msg_to_user", "*", [["STR_SYS_316_1"]], 0, 10, 0] call XSendNetStartScriptClient; // not print message as title text, only as chat
	no_more_observers = false; // skip observers only for one town
};

[_wp_array, _ammotruck select 0] execVM "x_scripts\x_createsecondary.sqf"; // a) medic BMP  or b) super-reammo or с) radio-tower etc

d_run_illum = true;
hint localize format["+++ x_createguardpatrolgroups.sqf: new x_illum.sqf executed for %1 at %2", _this select 2, call SYG_nowTimeToStr ];
[_trg_center, _radius, _this select 2] execVM "x_scripts\x_illum.sqf";

//#define __DEBUG_STAT_SERVICE__
#ifdef __DEBUG_STAT_SERVICE__
waitUntil { sleep 10; main_target_ready };
_array = [_trg_center, _radius + 50, true] call SYG_getScore4IntelTask; // this method is also called from GRUMissionSetup.sqf at line 64
#endif

if (true) exitWith {hint localize "+++ x_createguardpatrolgroups.sqf finished +++"};

