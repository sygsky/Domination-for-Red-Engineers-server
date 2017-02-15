// by Xeno
private ["_dir_to_set","_m_name","_marker"];

#include "x_setup.sqf"

if ((player call XfGetHeight) > 5) exitWith {
	(localize "STR_MG_1") call XfGlobalChat; // "Пошутил, да..."
};

if (count d_mgnest_pos > 0) exitWith {
	(localize "STR_MG_2") call XfGlobalChat; // "Сверните старое пулемётное гнездо, что установить новое."
};

d_mgnest_pos = player modeltoworld [0,2,0];

// check if position is valid
if (surfaceIsWater [d_mgnest_pos select 0, d_mgnest_pos select 1]) exitWith {
	(localize "STR_MG_3") call XfGlobalChat; // "Пулеметы под водой пока не работают..."
	d_mgnest_pos = [];
};

#ifdef __RANKED__
if (score player < (d_ranked_a select 14)) exitWith {
	(format [localize "STR_MG_4", score player,(d_ranked_a select 14)]) call XfHQChat; // "Чтобы создать пулемет Вам необходимы очки: %2. У Вас их %1"
};
#endif

_helper1 = "HeliHEmpty" createVehicleLocal [d_mgnest_pos select 0, (d_mgnest_pos select 1) + 4, 0];
_helper2 = "HeliHEmpty" createVehicleLocal [d_mgnest_pos select 0, (d_mgnest_pos select 1) - 4, 0];
_helper3 = "HeliHEmpty" createVehicleLocal [(d_mgnest_pos select 0) + 4, d_mgnest_pos select 1, 0];
_helper4 = "HeliHEmpty" createVehicleLocal [(d_mgnest_pos select 0) - 4, d_mgnest_pos select 1, 0];

if ((abs (((getPosASL _helper1) select 2) - ((getPosASL _helper2) select 2)) > 2) || (abs (((getPosASL _helper3) select 2) - ((getPosASL _helper4) select 2)) > 2)) exitWith {
	(localize "STR_MG_5") call XfGlobalChat; // "Попробуйте в другом месте..."
	d_mgnest_pos = [];
	//for "_mt" from 1 to 4 do {call compile format ["deleteVehicle _helper%1;", _mt];};
};

for "_mt" from 1 to 4 do {call compile format ["deleteVehicle _helper%1;", _mt];};

#ifdef __RANKED__
player addScore (d_ranked_a select 21) * -1;
#endif

player playMove "AinvPknlMstpSlayWrflDnon_medic";
sleep 3;
waitUntil {animationState player != "AinvPknlMstpSlayWrflDnon_medic"};
if (!(alive player)) exitWith {
	d_mgnest_pos = [];
	(localize "STR_MG_6") call XfGlobalChat; // "Умер до того, как развернул пулеметное гнездо..."
};

_dir_to_set = getdir player;

mg_nest = d_mg_nest createvehicle d_mgnest_pos;
mg_nest setdir _dir_to_set;
mg_nest setPos [position mg_nest select 0, position mg_nest select 1, 0];

(localize "STR_MG_7") call XfGlobalChat; // "MG Nest ready."
_m_name = format [localize "STR_SYS_02", player]; // "Пулемёт %1"
[_m_name, position mg_nest,"ICON","ColorBlue",[0.5,0.5],format [localize "STR_SYS_02", name player],0,
#ifdef __ACE__
"ACE_Icon_Machinegun"
#else
"Dot"
#endif
] call XfCreateMarkerGlobal; // "Пулемёт %1"

_d_placed_obj_add = [format ["%1", player], position mg_nest,1];
["d_placed_obj_add",_d_placed_obj_add] call XSendNetStartScriptServer;

mg_nest addAction [localize "STR_MG_8", "x_scripts\x_removemgnest.sqf"]; // "Убрать"
mg_nest addEventHandler ["killed",{[_this select 0] spawn XMGnestKilled;}];

player moveInGunner mg_nest;

if (true) exitWith {};
