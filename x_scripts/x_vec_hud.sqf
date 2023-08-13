// by Xeno: x_scripts\x_veh_hud.sqf
private ["_speed_str", "_fuel_str", "_dam_str", "_dir_str", /* "_gendirlist", */ "_welcome_message", "_veh", "_welcome_str", "_veh_msg1", "_struct_text", "_endtime", "_type_name", "_veh_string", "_vdir", "_gendir", "_dstr", "_count", "_control", "_type_weap", "_dirtmp"];
_type_str = localize "STR_SYS_324_0"; // Type
_speed_str = localize "STR_SYS_324_1"; // Speed
_fuel_str =  localize "STR_SYS_324_2"; // Fuel
_dam_str =   localize "STR_SYS_324_3"; // Damage
_dir_str =   localize "STR_SYS_324_4"; //"Dir: %1 (%2)"
//_gendirlist = ["N","N-NE","NE","E-NE","E","E-SE","SE","S-SE","S","S-SW","SW","W-SW","W","W-NW","NW","N-NW","N"];

#include "x_setup.sqf"

_welcome_message = {
	private ["_veh"];
	_veh = _this select 0;
	_welcome_str = format [localize "STR_SYS_324", name player]; // "Добро пожаловать на борт, %1"
	_veh_msg1 = "";
#ifndef __TT__
	if (_veh in [MRR1, MRR2]) then {
#endif
#ifdef __TT__
	if (_veh in [MRR1, MRR2, MRRR1, MRRR2]) then {
#endif
		_veh_msg1 = localize "STR_SYS_325"; //"Это мобильный респаун. Используется для перевозки ящиков снабжения, КШМ после смерти, телепортирования и выгрузки техники."
	} else {
#ifndef __TT__
		if (_veh in [TR7, TR8]) then {
#endif
#ifdef __TT__
		if (_veh in [TR4, TRR4]) then {
#endif
			_veh_msg1 = localize "STR_SYS_326"; //"This is an engineer salvage truck. You can load static weapons and unload them."
		};
	};
	_struct_text = composeText[
		parseText("<t color='#f0a7ff31' size='1'>" + _welcome_str + "</t>"), lineBreak,lineBreak,_veh_msg1
	];
	_endtime = time + 10;
	hint _struct_text;
	while {vehicle player != player && alive player && time < _endtime} do {
		sleep 0.321;
		hint _struct_text;
	};
	hint "";
};

while {true} do {
	waitUntil {sleep (0.5 + random 0.2);vehicle player != player};
	_veh = vehicle player;
	#ifndef __ACE__
	if (_veh isKindOf "LandVehicle" && !(_veh isKindOf "StaticWeapon")) then {
	#endif
	#ifdef __ACE__
	if ( (_veh isKindOf "Ship") || ( (_veh isKindOf "LandVehicle") && ( !((_veh isKindOf "StaticWeapon") || (_veh isKindOf "SLX_Dragger")) )) ) then {
	#endif
		if (d_show_vehicle_welcome) then {
#ifndef __TT__
			if (_veh in [MRR1,MRR2,TR7,TR8]) then {
#else
			if (_veh in [MRR1,MRR2,MRRR1,MRRR2,TR4,TRR4]) then {
#endif
				[_veh] spawn _welcome_message;
			};
		};
		#ifdef __ACE__
		if ( !( (_veh isKindOf "Tank") || (_veh isKindOf "StrykerBase") ) ) then {
		#endif
		while {vehicle player != player} do {
			if (player in _veh) then {
				_type_name = [typeOf _veh,0] call XfGetDisplayName;
				_veh_string = format [_type_str, _type_name];
				while { player in _veh } do {
					cutRsc["xvehicle_hud", "PLAIN"];
					_control = DVEC_HUD displayCtrl 64432;
					_control ctrlSetText _veh_string;
					_control = DVEC_HUD displayCtrl 64433;
					_control ctrlSetText format [_speed_str, round (speed _veh)];
					_control = DVEC_HUD displayCtrl 64434;
					_control ctrlSetText format [_fuel_str, round (fuel _veh * 100)];
					_control = DVEC_HUD displayCtrl 64435;
					_control ctrlSetText format [_dam_str, round (damage _veh * 100)];
					_vdir = round (direction _veh);
//					_gendir = _gendirlist select (round (_vdir/22.5));
					_gendir = _vdir call SYG_getDirName;
					_control = DVEC_HUD displayCtrl 64436;
					_control ctrlSetText format [_dir_str, _vdir, _gendir];
					sleep 0.631;
				};
				cutText["", "PLAIN"];
			};
			sleep 2.532;
		};
		#ifdef __ACE__
		};
		#endif
	} else {
		// Added this because problems with many static is they cant show compass. Finding directions is a nightmare, and they are already exposed enough.!!
		if (_veh isKindOf "StaticWeapon") then {
			while {vehicle player != player} do {
				if (player == gunner _veh) then {
					_type_name = [typeOf _veh,0] call XfGetDisplayName;
					_veh_string = format [_type_str, _type_name];
					_type_weap = (getArray(configFile>>"CfgVehicles" >> (typeOf _veh) >> "Turrets" >> "MainTurret" >> "weapons")) select 0; //always the case for statics which have only one gun
					while {vehicle player != player && alive player && player == gunner _veh} do {
						cutRsc["xvehicle_hud", "PLAIN"];
						_control = DVEC_HUD displayCtrl 64432;
						_control ctrlSetText _veh_string;
						_control = DVEC_HUD displayCtrl 64433;
						_control ctrlSetText format [_dam_str, round (damage _veh * 100)];
						_control = DVEC_HUD displayCtrl 64434;
						_dirtmp = round(((_veh weaponDirection _type_weap) select 0) atan2 ((_veh weaponDirection _type_weap) select 1));
						if (_dirtmp < 0) then {_dirtmp = _dirtmp + 360};
//						_gendir = _gendirlist select (round (_dirtmp/22.5));
						_gendir = _dirtmp call SYG_getDirName;
						_control ctrlSetText format [_dir_str, _dirtmp, _gendir];
						_control = DVEC_HUD displayCtrl 64435;
						_control ctrlSetText "";
						_control = DVEC_HUD displayCtrl 64436;
						_control ctrlSetText "";
						sleep 0.631;
					};
					cutText["", "PLAIN"];
				};
				sleep 0.832;
			};
		};
	};
	waitUntil {sleep (0.2 + random 0.2);vehicle player == player};
};

if (true) exitWith {};
