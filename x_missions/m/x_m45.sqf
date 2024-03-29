// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[14206.3,12523.6,0]]; // index: 45,   Destroy bank building in Bagango, attention, uses nearestObject ID
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_45"; //"Стало известно что представители местных наркокартелей хранят свои сбережения в национальном банке Сахрани расположенном в городе Bagango. Ваша задача - полное уничтожении банковского здания.";
	current_mission_resolved_text = localize "STR_SM_045"; //"Задание выполнено! Здание банка уничтожено.";
};

if (isServer) then {
	__Poss
	_building = _poss nearestObject 279996;
	if (!alive _building) exitWith {
    	-3 call XKilledSMTargetCodeNoDeadAdd;
	};
    #ifndef __TT__
    _building addEventHandler ["killed", {_this call XKilledSMTargetNormalNoDeadAdd}];
    #endif
    #ifdef __TT__
    _building addEventHandler ["killed", {_this call XKilledSMTargetTTNoDeadAdd}];
    #endif
	sleep 2.123;
	["specops", 1, "basic", 2, _poss,90,true] spawn XCreateInf;
	sleep 2.221;
	["shilka", 1, "bmp", 1, "tank", 1, _poss,1,160,true] spawn XCreateArmor;
	_snd = format["money%1", (floor (random 2)) + 1]; // 1..2
	["say_sound", "PLAY", _snd, 2, 24 ] call XSendNetStartScriptClient; // playSound on all connected players computers + show titles during 30 secs
};

if (true) exitWith {};