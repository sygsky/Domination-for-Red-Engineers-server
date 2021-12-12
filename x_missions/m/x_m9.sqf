// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG__

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;
//,         heli pos 1            heli pos 2           infantry pos     vehicle pos
x_sm_pos = [[19225.5,13889.3,0],  [19198.6,13912.9,0], [19192,13879,0], [19236,13993,0]]; // index: 9,   Helicopter Prototype at Pita Airfield
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_9"; //"В аэропорту Pita проходят летные испытания нового вертолета. Задача - уничтожить его!";
	current_mission_resolved_text = localize "STR_SM_09"; //"Задание выполнено! Вертолёт уничтожен.";
};

if (isServer) then {
#ifdef __ACE__
	_xchopper = (if (d_enemy_side == "EAST") then {
		"ACE_KA52"
	} else {
		"ACE_AH64_AGM"
	});
#else
	_xchopper = (if (d_enemy_side == "EAST") then {
		"KA50"
	} else {
		"AH1W"
	});
#endif
	_randomv = floor random 2;

//	__PossAndOther
	_poss = x_sm_pos select (floor (random 2) ); // 0..1 pos for heli creation
	_pos_other = x_sm_pos select 2; //  infantry groups creation
	_pos_other2  = x_sm_pos select 4; // armor group creation

	_vehicle = objNull;
	_vehicle = _xchopper createVehicle (_poss);
	#ifndef __TT__
	_vehicle addEventHandler ["killed", {_this call XKilledSMTargetNormal}];
	#endif
	#ifdef __TT__
	_vehicle addEventHandler ["killed", {_this call XKilledSMTargetTT}];
	#endif
	_vehicle setDir 40;
	_vehicle lock true;
	sleep 2.123;
//	["specops", 1, "basic", 1, _poss,90,true] spawn XCreateInf;
    // as this group is near heli, rearm it with some special specops weapons and allow minimal patrol area
    ["specopsbig", 1, "basic", 3, _pos_other, 200, true] spawn {
        private ["_grp_ret","_cnt", "_cnt1"];
        _grp_ret = _this call XCreateInf;
        // 4 infantry groups (1 big specops and  3 basic) are generated for this SM
        _cnt = [units (_grp_ret select 0), 0.4, 0.1] call SYG_rearmSpecopsGroupA; // [_units_arr, _rearm_prob, _adv_rearm_prob ] call SYG_rearmSpecopsGroupA;
        _cnt1 = (units (_grp_ret select 1)) call SYG_rearmBasicGroup; // _res = [_unit1,... , _unitN] call SYG_rearmBasicGroup;
        _cnt1 = _cnt1 + ((units (_grp_ret select 2)) call SYG_rearmBasicGroup); // _res = [_unit1,... , _unitN] call SYG_rearmBasicGroup;
        _cnt1 = _cnt1 + ((units (_grp_ret select 3)) call SYG_rearmBasicGroup); // _res = [_unit1,... , _unitN] call SYG_rearmBasicGroup;
#ifdef __DEBUG__
        hint localize format["%1 x_m9.sqf: %2 of %3 specops, %4 of %5 basic rearmed",
        					 call SYG_nowTimeToStr,
        					 _cnt,
        					 count units (_grp_ret select 0),
        					 _cnt1,
        					 (count units (_grp_ret select 1)) + (count units (_grp_ret select 2)) + (count units (_grp_ret select 3))];
#endif
    };

	sleep 2.111;
	["shilka", 1, "bmp", 2, "tank", 0, _pos_other2, 1, 100, true] spawn XCreateArmor;
};

if (true) exitWith {};