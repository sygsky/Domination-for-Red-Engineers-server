// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG__

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[9627.99,16345.6,0],[9929.8,16759.2,0]]; // index: 42,   Officer in forest Selva de Caza
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SYS_512"; //"Один из офицеров отправился по грибы в лес Selva de Caza. Ваша задача отобрать грибы, арестовать офицера и доставить его на базу. (Завершить миссию может только игрок в роли спасателя)";
	current_mission_resolved_text = localize "STR_SYS_513"; //"Задание выполнено! Офицера в ГРУ, грибы на кухню.";
};

if (isServer) then {
	_officer = (if (d_enemy_side == "EAST") then {"OfficerE"} else {"ACE_USMC0302"});
	__PossAndOther
	__WaitForGroup
	__GetEGrp(_ogroup)
	_sm_vehicle = _ogroup createUnit [_officer, _poss, [], 0, "FORM"];
	[_sm_vehicle] join _ogroup;
	_sm_vehicle addEventHandler ["killed", {_this call XKilledSMTarget500}];
	removeAllWeapons _sm_vehicle;
	sleep 2.123;

	if (d_enemy_side == "WEST") then
	{
		// as this group is near officer, rearm it with some special specops weapons and allow minimal patrol area
		["specopsbig", 1, "basic", 0, _poss, 51, true] spawn
		{
			private ["_grp_ret","_cnt"];
			_grp_ret = _this call XCreateInf;
			_cnt = (_grp_ret select 0) call SYG_rearmSpecopsGroup;
#ifdef __DEBUG__		
			hint localize format["%1 x_m42.sqf: %2 of %3 specops rearmed", call SYG_nowTimeToStr, _cnt, count units (_grp_ret select 0)];
#endif
		};
		["specopsbig", 0, "basic", 2, _poss, 200, true] call XCreateInf; // groups to control forest
		["specopsbig", 0, "basic", 1, _pos_other, 150, true] call XCreateInf; // additional patrol group to control sea shore
	}
	else
	{
		["specopsbig", 1, "basic", 2, _poss, 200,true] spawn XCreateInf;
	};
	sleep 2.123;
	

	__WaitForGroup
	__GetEGrp(_grp)
	_AAr_Pod_arr =
	[
	    [9412.82,15794.6,0.00357056],[9929.38,15904.5,0.00190735],[8919.56,15988.4,0.000579834],
	    [9115.81,16176.5,0.00161743],[8970.38,16780.1,0.00421143],[10944.8,17014.1,0.000844955],
	    [8759.912,17140.27,0], [9789.017,16960.7,0]
	];

	[_grp, ["Stinger_Pod","ACE_ZU23M"], "ACE_SoldierWB", _AAr_Pod_arr,0.2] call  SYG_createStaticWeaponGroup;

	["shilka", 1, "bmp", 2, "tank", 0, _poss,1,200,true] spawn XCreateArmor;
	sleep 2.123;
	_leadero = leader _ogroup;
	_leadero setRank "COLONEL";
	//_ogroup allowFleeing 0;
	_ogroup setBehaviour "AWARE";
	[_sm_vehicle] execVM "x_missions\common\x_sidearrest.sqf";
};

if (true) exitWith {};