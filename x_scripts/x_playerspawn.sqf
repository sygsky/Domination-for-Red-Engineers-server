// by Xeno, x_scripts\x_playerspawn.sqf
private ["_magazines","_p","_weapons","_muzzles","_primw"];
if (!X_Client) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_weapons = [];
_magazines = [];

if (isNil "x_weapon_array") then {x_weapon_array = [];};
if (isNil "wp_weapon_array") then {wp_weapon_array = [];};

while {true} do {
	waitUntil {!alive player};
	_p = player;
	#ifdef __ACE__
	_ruckmags = [];
	if (_p call ACE_Sys_Ruck_HasRucksack) then {
		if (format["%1",_p getVariable "ACE_Ruckmagazines"] != "<null>") then {
			_ruckmags = _p getVariable "ACE_Ruckmagazines";
		};
	};
	_weaponback = "";
	if (format["%1",_p getVariable "ACE_weapononback"] != "<null>") then {
		_weaponback = _p getVariable "ACE_weapononback";
	};
	#endif
	#ifndef __REVIVE__
	if (x_weapon_respawn) then {
		if (count x_weapon_array > 0) then {
			_weapons = x_weapon_array select 0;
			_magazines = x_weapon_array select 1;
			x_weapon_array = [];
		} else {
			if (count wp_weapon_array > 0) then {
				_weapons = wp_weapon_array select 0;
				_magazines = wp_weapon_array select 1;
				wp_weapon_array = [];
			} else {
				_weapons = weapons _p;
				_magazines = magazines _p;
			};
		};
	};
	#endif
	#ifndef __AI__
	if (!(__ACEVer)) then {
		if (player_can_call_arti) then {
			if (ari1 != -8877) then {
				_p removeAction ari1;
				ari1 = -8877;
			};
		};
		if (player_can_call_drop) then {
			if (dropaction != -8878) then {
				_p removeAction dropaction;
				dropaction = -8878;
			};
		};
	};
	#endif
	#ifdef __AI__
	if (!(__ACEVer)) then {
		if (ari1 != -8877) then {
			_p removeAction ari1;
			ari1 = -8877;
		};
		if (dropaction != -8878) then {
			_p removeAction dropaction;
			dropaction = -8878;
		};
	};
	#endif

	if (vec_id != -1000) then {
		_p removeAction vec_id;
		vec_id = -1000;
	};
	if (vec2_id != -1000) then {
		_p removeAction vec2_id;
		vec2_id = -1000;
	};

	if (ass != -8879) then {
		_p removeAction ass;
		ass = -8879;
	};
	if (d_use_backpack) then {
		if (pbp_id != -9999) then {
			_p removeAction pbp_id;
			pbp_id = -9999;
		};
	};

	if (player_is_medic) then {
		if (medicaction != -3333) then {
			_p removeAction medicaction;
			medicaction = -3333;
		};
	};

	if (d_with_mgnest) then {
		if (player_can_build_mgnest) then {
			if (mgnestaction != -11111) then {
				_p removeAction mgnestaction;
				mgnestaction = -11111;
			};
		};
	};
	if (count d_action_menus_type > 0) then {
		{
			_types = _x select 0;
			if (count _types > 0) then {
				if (_type in _types) then {
					_action = _x select 3;
					_p removeAction _action;
				};
			} else {
				_action = _x select 3;
				_p removeAction _action;
			};
		} forEach d_action_menus_type;
	};
	if (count d_action_menus_unit > 0) then {
		{
			_types = _x select 0;
			_ar = _x;
			if (count _types > 0) then {
				{
					call compile format ["
						if (_p ==  %1) exitWith {
							_action = _ar select 3;
							_p removeAction _action;
						};
					", _x];
				} forEach _types
			} else {
				_action = _x select 3;
				_p removeAction _action;
			};
		} forEach d_action_menus_unit;
	};
	if (d_weather) then {
		0 setFog fFogLess;
		0 setOvercast fRainLess;
		0 setRain 0.0;
		if (d_weather_sandstorm) then {x_do_sandstorm = false;};
	};
	waitUntil {alive player};
	_p = player;
	#ifndef __REVIVE__
	if (x_weapon_respawn) then {
		removeAllWeapons _p;
		{_p addMagazine _x;} forEach _magazines;
		{_p addWeapon _x;} forEach _weapons;
		if (count d_backpack_helper > 0) then {
			{_p addMagazine _x;} forEach (d_backpack_helper select 0);
			{_p addWeapon _x;} forEach (d_backpack_helper select 1);
			d_backpack_helper = [];
		};
		_primw = primaryWeapon _p;
		if (_primw != "") then {
			_p selectWeapon _primw;
			_muzzles = getArray(configFile>>"cfgWeapons" >> _primw >> "muzzles");
			_p selectWeapon (_muzzles select 0);
		};
	};
	#endif
	#ifdef __ACE__
	if (count _ruckmags > 0) then {
		_p setVariable ["ACE_Ruckmagazines",_ruckmags];
	};
	if (_weaponback != "") then {
		_p setVariable ["ACE_weapononback",_weaponback];
	};
	ACE_FV = 0;ACE_MvmtFV = 0;ACE_FireFV = 0;ACE_WoundFV = 0;
	ACE_Blackout = 0;ACE_Breathing = 0;ACE_Heartbeat = [0,20];
	#endif

	#ifndef __AI__
	if (!(__ACEVer)) then {
		if (player_can_call_arti) then {
			_strp = format ["%1",_p];
			if (_strp == "RESCUE") then {
				ari1 = _p addAction [localize "STR_SYS_98"/* "Артиллерия" */, "x_scripts\x_artillery.sqf",[],-1,false];
			};
			if (_strp == "RESCUE2") then {
				ari1 = _p addAction [localize "STR_SYS_98"/* "Артиллерия" */, "x_scripts\x_artillery2.sqf",[],-1,false];
			};
		};
		if (player_can_call_drop) then {
			dropaction = _p addAction [localize "STR_SYS_99"/*"Вызов снабжения"*/, "x_scripts\x_calldrop.sqf",[],-1,false];
		};
	};
	#endif
	#ifdef __AI__
	if (!(__ACEVer)) then {
		if (player_can_call_arti) then {
			ari1 = _p addAction [localize "STR_SYS_98"/* "Артиллерия" */, "x_scripts\x_artillery.sqf",[],-1,false];
		};
		if (player_can_call_drop) then {
			dropaction = _p addAction [localize "STR_SYS_99"/*"Вызов снабжения"*/, "x_scripts\x_calldrop.sqf",[],-1,false];
		};
	};
	if (rating _p < 20000) then {_p addRating 20000};
	#endif
	ass = _p addAction [localize "STR_SYS_97"/* "СТАТУС" */, "x_scripts\x_showstatus.sqf",[],-1,false];
	if (d_use_backpack) then {
		if (count player_backpack == 0) then {
			if (primaryWeapon _p != "" && primaryWeapon _p != " ") then {
				_s = format ["%1 to Backpack", [primaryWeapon _p,1] call XfGetDisplayName];
				if (pbp_id == -9999) then {
					pbp_id = _p addAction [_s, "x_scripts\x_backpack.sqf",[],-1,false];
				};
			};
		} else {
			_s = format ["Weapon %1", [player_backpack select 0,1] call XfGetDisplayName];
			if (pbp_id == -9999) then {
				pbp_id = _p addAction [_s, "x_scripts\x_backpack.sqf",[],-1,false];
			};
		};
	};
	if (player_is_medic) then {
		if (medicaction == -3333) then {
			medicaction = _p addAction [localize "STR_MED_01"/* "Мед.палатка" */, "x_scripts\x_mash.sqf",[],-1,false];
		};
	};
	if (d_with_mgnest) then {
		if (player_can_build_mgnest) then {
			if (mgnestaction == -11111) then {
				mgnestaction = _p addAction [localize "STR_SYS_2"/*"Пулемётное гнездо"*/, "x_scripts\x_mgnest.sqf",[],-1,false];
			};
		};
	};

	if (count d_action_menus_type > 0) then {
		{
			_types = _x select 0;
			if (count _types > 0) then {
				if (_type in _types) then {
					_action = _p addAction [_x select 1,_x select 2,[],-1,false];
					_x set [3, _action];
				};
			} else {
				_action = _p addAction [_x select 1,_x select 2,[],-1,false];
				_x set [3, _action];
			};
		} forEach d_action_menus_type;
	};
	if (count d_action_menus_unit > 0) then {
		{
			_types = _x select 0;
			_ar = _x;
			if (count _types > 0) then {
				{
					call compile format ["
						if (_p ==  %1) exitWith {
							_action = _p addAction [_ar select 1,_ar select 2,[],-1,false];
							_ar set [3, _action];
						};
					", _x];
				} forEach _types
			} else {
				_action = _p addAction [_x select 1,_x select 2,[],-1,false];
				_x set [3, _action];
			};
		} forEach d_action_menus_unit;
	};
	if (d_weather) then {
		0 setFog 0;
		0 setOvercast 0;
		0 setRain 0.0;
		if (d_weather_sandstorm) then {x_do_sandstorm = false;};
	};
	bike_created = false;
	if (_p hasWeapon "NVGoggles") then {
		if ( daytime > SYG_shortNightStart/*19.75*/ || daytime < SYG_shortNightEnd /*4.25*/ ) then {
			_p action ["NVGoggles",_p];
		};
	};
};

if (true) exitWith {};
