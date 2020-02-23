// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG__

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[16551.3,12925.3,0]]; // index: 49,   Officer near Benoma
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_49";// "В долине около Benoma, у врага расположен небольшой аванпост. Ваша задача захватить офицера и доставить его на базу. (Завершить миссию может только игрок в роли спасателя).";
	current_mission_resolved_text = localize "STR_SM_049"; //"Задание выполнено! Вражеский офицер доставлен на базу.";
};

if (isServer) then {
	#ifdef __ACE__
        _officer = (if (d_enemy_side == "EAST") then {"ACE_OfficerE"} else {"ACE_USMC0302"});
    #else
        _officer = (if (d_enemy_side == "EAST") then {"OfficerE"} else {"OfficerW"});
    #endif

	__Poss
	sleep 2.111;
	_fortress = "Fortress2" createVehicle _poss;
	//_fortress setDir 290.789;
	__AddToExtraVec(_fortress)
	__WaitForGroup
	__GetEGrp(_ogroup)
	_sm_vehicle = _ogroup createUnit [_officer, _poss, [], 0, "FORM"];
	[_sm_vehicle] join _ogroup;
	_sm_vehicle addEventHandler ["killed", {_this call XKilledSMTarget500}];
	removeAllWeapons _sm_vehicle;
	sleep 2.123;
	_bpos = _fortress buildingPos 1;
	_sm_vehicle setPos _bpos;
	sleep 2.123;

	if (d_enemy_side == "WEST") then
	{
		// as this group is near officer, rearm it with some special specops weapons
		["specops", 1, "basic", 1, _poss, 110,true] spawn 
		{
			private ["_grp_ret","_cnt"];
			_grp_ret = _this call XCreateInf;
			_cnt = (_grp_ret select 0) call SYG_rearmSpecopsGroup;
#ifdef __DEBUG__		
			hint localize format["%1 x_m49.sqf: %2 of %3 specops rearmed", call SYG_nowTimeToStr, _cnt, count units (_grp_ret select 0)];
#endif
		};
	}
	else
	{
		["specops", 1, "basic", 1, _poss, 110,true] spawn XCreateInf;
	};
	sleep 2.123;
	
	["shilka", 1, "bmp", 1, "tank", 1, _poss,1,130,true] spawn XCreateArmor;
	sleep 2.123;
	_leadero = leader _ogroup;
	_leadero setRank "COLONEL";
	_ogroup allowFleeing 0;
	_ogroup setbehaviour "AWARE";
	[_sm_vehicle] execVM "x_missions\common\x_sidearrest.sqf";
};

if (true) exitWith {};