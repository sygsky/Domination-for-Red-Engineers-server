// x_mash.sqf, by Xeno
// TODO: localize this file, stringtable items from STR_SYS_07
private ["_dir_to_set","_m_name","_marker"];

#include "x_setup.sqf"

if ((player call XfGetHeight) > 5) exitWith {
	(localize "STR_MG_1") call XfGlobalChat; // "Вы должно быть шутите..."
};

if (count d_medtent > 0) exitWith {
	(localize "STR_MED_1") call XfGlobalChat; // "У вас уже есть одна мед.палатка, сверните её прежде чем устанавливать новую."
};

d_medtent = player modeltoworld [0,5,0];

// check if position is valid
if (surfaceIsWater [d_medtent select 0, d_medtent select 1]) exitWith {
	localize "STR_MED_2" call XfGlobalChat; // "Установка в воду невозможна..."
	d_medtent = [];
};

_helper1 = "HeliHEmpty" createVehicleLocal [d_medtent select 0, (d_medtent select 1) + 4, 0];
_helper2 = "HeliHEmpty" createVehicleLocal [d_medtent select 0, (d_medtent select 1) - 4, 0];
_helper3 = "HeliHEmpty" createVehicleLocal [(d_medtent select 0) + 4, d_medtent select 1, 0];
_helper4 = "HeliHEmpty" createVehicleLocal [(d_medtent select 0) - 4, d_medtent select 1, 0];

if ((abs (((getPosASL _helper1) select 2) - ((getPosASL _helper2) select 2)) > 2) || (abs (((getPosASL _helper3) select 2) - ((getPosASL _helper4) select 2)) > 2)) exitWith {
	(localize "STR_MG_5") call XfGlobalChat; // "Попробуйте в другом месте..."
	d_medtent = [];
	//for "_mt" from 1 to 4 do {call compile format ["deleteVehicle _helper%1;", _mt];};
};

for "_mt" from 1 to 4 do {call compile format ["deleteVehicle _helper%1;", _mt];};

player playMove "AinvPknlMstpSlayWrflDnon_medic";
sleep 3;
waitUntil {animationState player != "AinvPknlMstpSlayWrflDnon_medic"};
if (!(alive player)) exitWith {
	d_medtent = [];
	localize "STR_MED_3" call XfGlobalChat; // "Скончался до того, как установил мед.палатку..."
};

_dir_to_set = getdir player - 180;

medic_tent = "Mash" createVehicle d_medtent;
medic_tent setdir _dir_to_set;
medic_tent setPos [position medic_tent select 0, position medic_tent select 1, 0];

(localize "STR_MED_4") call XfGlobalChat; // "Мед.палатка готова."
_m_name = format [localize "STR_MED_5", player]; // "Санчасть %1"
[_m_name, position medic_tent,"ICON","ColorBlue",[0.5,0.5],format [localize "STR_MED_5"/* "Санчасть %1" */, name player],0,
#ifdef __ACE__
"ACE_Icon_FieldHospital"
#else
"Dot"
#endif
] call XfCreateMarkerGlobal;

_d_placed_obj_add = [format ["%1", player], position medic_tent,0];
["d_placed_obj_add",_d_placed_obj_add] call XSendNetStartScriptServer;

medic_tent addAction [localize "STR_MED_6"/* "Убрать санчасть" */, "x_scripts\x_removemash.sqf"];
medic_tent addEventHandler ["killed",{[_this select 0] spawn XMashKilled;}];

#ifdef __RANKED__
medic_tent spawn {
	private ["_tent", "_pos_healers", "_healerslist", "_points", "_nobs", "_i", "_h", "_anim_list"];
	_tent = _this;
	_pos_healers = (
		switch (d_own_side) do {
			case "WEST": {"SoldierWB"};
			case "EAST": {"SoldierEB"};
			case "RACS": {"SoldierGB"};
		}
	);
	_healerslist = [];
	_anim_list   = ["ainvpknlmstpslaywrfldnon_healed","amovppnemstpsraswrfldnon_healed"];
	while { alive _tent } do {
		_points = 0;
		_nobs = nearestObjects [_tent, [_pos_healers], 7];
		{
			if (!(_x in _healerslist) && (_x != player)) then {
				if (animationState _x in _anim_list) then {
					_points = _points + (d_ranked_a select 7);
					_healerslist = _healerslist + [_x];
				};
			};
		} forEach _nobs;
		if (_points > 0) then {
			//player addScore _points;
			_points call SYG_addBonusScore;
			(format [localize "STR_MED_7"/* "You get %1 points because other units used your mash for healing!" */, _points]) call XfHQChat;
		};
		sleep 0.01;
		if (count _healerslist > 0) then {
			for "_i" from 0 to (count _healerslist - 1) do {
				_h = _healerslist select _i;
				if (!(animationState _h in _anim_list)) then {
					_healerslist set [_i, "X_RM_ME"];
				};
			};
			_healerslist = _healerslist - ["X_RM_ME"];
		};
		sleep 0.521;
	};
};
#endif

if (true) exitWith {};
