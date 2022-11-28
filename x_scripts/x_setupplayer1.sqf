/*
	x_scripts\x_setupplayer1.sqf, created by Sygsky on 30th of Jul 2021.
	Helper for the x_setupplayer1.sqf

	author: Sygsky
	description: assign weapon/ammo for the new player
	returns: nothing
*/

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG__

private ["_endtime","_p","_rifle","_weapp","_magp","_old_rank","_index","_rpg","_mg","_sniper","_medic","_diversant",
		 "_pistol","_equip","_rearmed"];
// ask the server for the client score etc
sleep random 0.5;
_endtime = time + 60;
// initial information on player connected
_str = if (SYG_found_ACE) then {"ACE_found"} else {"ACE_not_found"};
_str = _str + (if (SYG_found_EditorUpdate_v102) then { ", EditorUpdate_v102_found"} else {", EditorUpdate_v102_not_found"});
["d_p_a", name player, missionStart, localize "STR_LANG", _str ] call XSendNetStartScriptServer;
waitUntil { sleep 0.1; ( (!(isNil "d_player_stuff")) || (time > _endtime)) };

hint localize format["+++ x_setupplayer1.sqf: d_player_stuff %1 +++", if (isNil "d_player_stuff") then { "isNil" } else { d_player_stuff }];

if ( (isNil "d_player_stuff") || (time > _endtime) ) exitWith {
	player_autokick_time = d_player_air_autokick;
};

if ( (d_player_stuff select 2) != name player ) exitWith { };

player_autokick_time = d_player_stuff select 0;
player addScore (d_player_stuff select 3); // set saved scores
// execute player rearm procedure
_p = player;
#ifdef __RANKED__
_equip = "";
if ( count d_player_stuff > 5) then { // equipment returned
	_equip = d_player_stuff select 5; // string with all equipment
	hint localize format["+++ x_setupplayer1.sqf: equipment read as %1", _equip];
} else {
	hint localize "+++ x_setupplayer1.sqf: equipment not detected in the d_player_stuff variable"
};
// generate common weapon set
if (_equip != "") then {
	//hint localize format["d_player_stuff with equipment: %1", _equip];
	[player, _equip] call SYG_rearmUnit;
	// now check if player have primary and secondary weapons
	if ((primaryWeapon player == "") && (secondaryWeapon player == "")) then {
		hint localize format["+++ x_setupplayer1.sqf: as no primary and secondary weapons detected, unit is rearmed by std weapons!"];
		_equip = ""
	};
};
if ( _equip == "" ) then {
	// give players a basic rifle/MG at start
	_weapp = "";
	_magp = [];
	_magp = [];
	switch (d_own_side) do {
		case "WEST": {
			if (__ACEVer) then {
				_weapp = ["P", "ACE_M16A4","ACE_30Rnd_556x45_B_Stanag",12];
				_magp = ["ACE_30Rnd_556x45_B_Stanag",6];
			} else {
				_weapp = ["P", "M16A4","30Rnd_556x45_Stanag",12];
				_magp = ["30Rnd_556x45_Stanag",6];
			};
		};
		case "EAST": {
			if (__ACEVer) then {
				_old_rank = "";
				_rpg = [];
				while {true } do {
					_old_rank = (score player) call XGetRankFromScore;
					_index = _old_rank call XGetRankIndex;
					_rpg   = if (_index == 0 ) then { ["P","ACE_RPG7","ACE_RPG7_PG7VL",1] } else { ["P","ACE_RPG7_PGO7","ACE_RPG7_PG7VL",1]};

					_rifle = switch _index do {
						case 0;
						case 1;
						case 2: {
							[
								["P", "ACE_AK74", "ACE_45Rnd_545x39_BT_AK", 10],
								["P", "ACE_AKM", "ACE_75Rnd_762x39_BT_AK", 5],
								["P", "ACE_RPK47", "ACE_75Rnd_762x39_BT_AK", 5]
							] call XfRandomArrayVal;
						};
						case 3: {["P", "ACE_AKM_Cobra", "ACE_75Rnd_762x39_BT_AK", 5]}; // Lieutenant
						default {
							[["P", "ACE_Val_Cobra", "ACE_20Rnd_9x39_B_VAL", 10],["P", "ACE_Bizon_SD_Cobra", "ACE_64Rnd_9x18_B_Bizon", 10]] call XfRandomArrayVal;
						};
					};

					_mg = switch _index do {
						case 0: {["P", "ACE_RPK47", "ACE_75Rnd_762x39_BT_AK", 5]};
						case 1: {["P", "ACE_RPK74", "ACE_45Rnd_545x39_BT_AK", 10]};
						case 2: {
							[["P", "ACE_PK", "ACE_100Rnd_762x54_BT_PK", 3],["P", "ACE_RPK74M_1P29", "ACE_45Rnd_545x39_BT_AK", 10]] call XfRandomArrayVal;
						};
						case 3: {["P", "ACE_Pecheneg", "ACE_100Rnd_762x54_BT_PK", 3]}; // Lieutenant
						default {["P", "ACE_Pecheneg_1P29", "ACE_100Rnd_762x54_BT_PK", 3]};
					};

					_sniper = switch _index do {
						case 0: {["P", "ACE_AKM", "ACE_75Rnd_762x39_BT_AK", 5]};
						case 1: {["P", "ACE_AKS74PSO", "ACE_45Rnd_545x39_BT_AK", 10]};
						case 2: {["P", "ACE_SVD", "ACE_10Rnd_762x54_SB_SVD", 10]};
						default {["P", "ACE_KSVK", "ACE_5Rnd_127x108_BT_KSVK", 10]};
					};

					_medic = switch _index do {
						case 0;
						case 1: {["P", "ACE_AKS74U", "ACE_45Rnd_545x39_BT_AK", 10]};
						case 2;
						case 3: {["P", "ACE_AKS74U_Cobra", "ACE_45Rnd_545x39_BT_AK", 10]};
						default {["P", "ACE_AKS74USD_Cobra", "ACE_45Rnd_545x39_BT_AK", 10]};
//							default {["P", "ACE_Bizon_SD_Cobra", "ACE_64Rnd_9x18_B_Bizon", 10]};
					};

					_diversant = switch _index do {
						case 0;
						case 1: {["P", "ACE_Bizon", "ACE_64Rnd_9x18_B_Bizon", 10]};
						case 2;
						case 3: {
							switch floor (random 4) do {
								case 0: {["P", "ACE_Val", "ACE_20Rnd_9x39_B_VAL", 10]};
								case 1: {["P", "ACE_Bizon_SD", "ACE_64Rnd_9x18_B_Bizon", 10] };
								case 2: {["P", "ACE_AKMS_PBS1", "ACE_30Rnd_762x39_SD_AK", 10] };
								case 3: {["P", "ACE_AKS74USD", "ACE_45Rnd_545x39_BT_AK", 10] };
							};
						};
						default {
							switch floor (random 4) do {
								case 0: {["P", "ACE_Val_Cobra", "ACE_20Rnd_9x39_B_VAL", 10]};
								case 1: {["P", "ACE_Bizon_SD_Cobra", "ACE_64Rnd_9x18_B_Bizon", 10] };
								case 2: {["P", "ACE_AKS74USD_Cobra", "ACE_45Rnd_545x39_BT_AK", 10] };
								case 3: {["P", "ACE_AKMS_PBS1_Cobra", "ACE_30Rnd_762x39_SD_AK", 10] };
							};
						};
					};

					_pistol= switch _index do {
						case 0: {["S", "ACE_Makarov", "ACE_8Rnd_9x18_B_Makarov", 4]};
						case 1;
						case 2: {["S", "ACE_TT", "ACE_8Rnd_762x25_B_Tokarev", 4]};
						case 3: {["S", "ACE_MakarovSD", "ACE_8Rnd_9x18_SD_Makarov", 4]};
						case 4;
						default {["S", "ACE_Scorpion", "ACE_20Rnd_765x17_vz61", 4]};
					};
					if (_string_player in d_can_use_artillery) exitWith {
						_weapp =  [["P","ACE_RPG22","ACE_RPG22",2], _diversant, _pistol, ["ACE_Bandage",2],["ACE_Morphine",2]];
						_diversant set [3,8];
						_magp = [[format["%1_PDM",_diversant select 2],2],["ACE_PipeBomb_PDM",1],["ACE_SmokeGrenade_Red_PDM",3]];

					};
					if ( _p isKindOf "SoldierEMG") exitWith {
						_weapp =  [["P","ACE_RPG22","ACE_RPG22",1],_mg, _pistol, ["ACE_Bandage",2],["ACE_Morphine",2]];
						_magp = [/* ["ACE_40Rnd_762x39_BT_AK_PDM",6], */["ACE_Bandage_PDM",3],["ACE_Morphine_PDM",5],["ACE_Epinephrine_PDM",1],["ACE_PipeBomb_PDM",1],["ACE_SmokeGrenade_Red_PDM",3]];
					};

					if ( _p isKindOf "SoldierEAT" ) exitWith {
						_rpg set [2, "ACE_RPG7_PG7VR"];
						_rifle set [3, 9]; // 9 magazines
						_weapp =  [_rpg, _rifle ,_pistol, ["ACE_Bandage",2],["ACE_Morphine",2]];
						_magp = [/* ["ACE_45Rnd_545x39_BT_AK_PDM",4], */["ACE_Bandage_PDM",3],["ACE_Morphine_PDM",5],["ACE_Epinephrine_PDM",1],["ACE_PipeBomb_PDM",1],["ACE_SmokeGrenade_Red_PDM",3],["ACE_RPG7_PG7VR_PDM",1]];
					};

					if ( _p isKindOf "SoldierEAA" ) exitWith {
						_rifle set [3,6]; // 6 magazines
						_weapp =  [["P","ACE_Strela","ACE_Strela",1],_rifle,_pistol,["ACE_Bandage",2],["ACE_Morphine",2]];
						_magp = [/* ["ACE_45Rnd_545x39_BT_AK_PDM",4], */["ACE_Bandage_PDM",3],["ACE_Morphine_PDM",5],["ACE_Epinephrine_PDM",1],["ACE_PipeBomb_PDM",1],["ACE_SmokeGrenade_Red_PDM",3],["ACE_Strela_PDM",1]];
					};

					if ( _p isKindOf "SoldierESniper") exitWith {
						_weapp =  [_rpg, _sniper, _pistol, ["ACE_Bandage",2],["ACE_Morphine",2]];
						_magp = [/* ["ACE_40Rnd_762x39_BT_AK_PDM",6], */["ACE_RPG7_PG7VL_PDM",1],["ACE_Bandage_PDM",3],["ACE_Morphine_PDM",5],["ACE_Epinephrine_PDM",1],["ACE_PipeBomb_PDM",1],["ACE_SmokeGrenade_Red_PDM",3]];
					};

					if ( _p isKindOf "SoldierEMedic") exitWith {
						_weapp =  [_rpg, _medic, _pistol, ["ACE_Bandage",1],["ACE_Morphine",1],["ACE_Epinephrine",1]];
						_pistol set [3,5]; // 5 mags except standard 4
						_magp = [/* ["ACE_40Rnd_762x39_BT_AK_PDM",6], */["ACE_RPG7_PG7VL_PDM",1],["ACE_PipeBomb_PDM",1],["ACE_SmokeGrenade_Red_PDM",3]];
					};

					if ( _p isKindOf "SoldierECrew") exitWith {
						_weapp =  [_rpg, _rifle, _pistol, ["ACE_Bandage",2],["ACE_Morphine",2]];
						_magp = [["ACE_RPG7_PG7VL_PDM",1],["ACE_Bandage_PDM",3],["ACE_Morphine_PDM",5],["ACE_Epinephrine_PDM",1],["ACE_PipeBomb_PDM",1],["ACE_SmokeGrenade_Red_PDM",3]];
					};

					if ( _p isKindOf "SoldierEMiner") exitWith {
						_weapp =  [_rpg, _rifle, _pistol, ["ACE_Bandage",2],["ACE_Morphine",2]];
						_magp = [["ACE_RPG7_PG7VL_PDM",1],["ACE_Bandage_PDM",3],["ACE_Morphine_PDM",5],["ACE_Epinephrine_PDM",1],["ACE_PipeBomb_PDM",1],["ACE_SmokeGrenade_Red_PDM",3]];
					};

					if ( true ) exitWith {
						_weapp =  [_rpg,_rifle,_pistol,["ACE_Bandage",2],["ACE_Morphine",2]];
						_magp = [/* ["ACE_45Rnd_545x39_BT_AK_PDM",4], */["ACE_Bandage_PDM",3],["ACE_Morphine_PDM",5],["ACE_Epinephrine_PDM",1],["ACE_PipeBomb_PDM",1],["ACE_SmokeGrenade_Red_PDM",3],["ACE_RPG7_PG7VL_PDM",1]];
					};
				};
				// try to rearm predefined players (Yeti, EngineerACE etc)
				_rearmed = true;
				hint localize format["+++ x_setupplayer1.sqf: _rpg %1, _rifle %2, _pistol %3", _rpg, _rifle, _pistol];
				switch (toUpper (name player)) do {
					case "YETI": { // Yeti
						d_rebornmusic_index = 1; // no play std death sound
						//SYG_suicideScreamSound = ["suicide_yeti","suicide_yeti_1","suicide_yeti_2","suicide_yeti_3"] call XfRandomArrayVal; // personal suicide sound for yeti
						3000 call SYG_setViewDistance;
						if (_index == 0 && !(player isKindOf "SoldierEMedic")) exitWith { _p execVM "scripts\rearm_Yeti.sqf"; };
						_rearmed = false; // if here, player not rearmed
					};
					case "ENGINEERACE": {  // EngineerACE
						3500 call SYG_setViewDistance; // Viewdistance
						if (_index == 0 && !(player isKindOf "SoldierEMedic")) exitWith { [_p,_index] execVM "scripts\rearm_EngineerACE.sqf"; };
						_rearmed = false; // if here, player not rearmed
					};
					case "ROKSE [LT]": { // Rokse [LT]
						// Viewdistance
						10000 call SYG_setViewDistance;
						if (_index == 0 && !(player isKindOf "SoldierEMedic")) exitWith { [_p,_index] execVM "scripts\rearm_Rokse.sqf"; };
						_rearmed = false; // if here, player not rearmed
					};
					// TODO: add more personal setting here (as for "Yeti" done)
					default { _rearmed = false; }; // all other players are rearmed by standart
				};
				if (!_rearmed ) then {
					[_p, _weapp] call SYG_armUnit;
					//+++ Sygsky: add largest ACE rucksack and fill it with mags
					_p setVariable ["ACE_weapononback","ACE_Rucksack_Alice"];
					_p setVariable ["ACE_Ruckmagazines", _magp];
					// send info to the server about new equipment, note that weapons will be read from player in OPD callback
					_equip = player call SYG_getPlayerRucksackAsStr;
					["d_ad_wp", name player, _equip] call XSendNetStartScriptServer; // sent to the server 1st time player armamaent
					hint localize format["+++ x_setupplayer1.sqf: player %1, rank %2, score %3, weapon %4, rucksack %5, language %6",
							name player, _old_rank, score player, _weapp, _magp,  localize "STR_LANG"];
					//--- Sygsky
				};
			} else {  // if (__ACEVer) then
				if (__CSLAVer) then {
					_weapp = "CSLA_Sa58P";
					_magp = "CSLA_Sa58_30rnd_7_62vz43";
				} else {
					_weapp = "AK74";
					_magp = "30Rnd_545x39_AK";
				};
			};
		};
		case "RACS": {
			_weapp = "M16A4";
			_magp = "30Rnd_556x45_Stanag";
		};
	};

	if (!(__ACEVer)) then {
		removeAllWeapons _p;
		{ _p addMagazine _magp } forEach [0,1,2,3,4,5];

		_p addWeapon _weapp;
		_p selectWeapon (primaryWeapon _p);
		_muzzles = getArray(configFile>>"cfgWeapons" >> (primaryWeapon _p) >> "muzzles");
		if ( count _muzzles > 1) then {
			_p selectWeapon (_muzzles select 0);
		};
	};
};
#endif
//		hint localize format["+++ rearm: before player hasWeapon %1 = %2, hasWeapon %3 = %4","NVGoggles", player hasWeapon "NVGoggles","Binocular", player hasWeapon "Binocular"];
if ( (daytime < SYG_startMorning) || (daytime > (SYG_startNight - 3)) || (toUpper (name player) == "YETI")  ) then {
	player call SYG_addNVGoggles;
};
player call SYG_addBinocular;
//		hint localize format["+++ rearm: after player hasWeapon %1 = %2, hasWeapon %3 = %4","NVGoggles", player hasWeapon "NVGoggles","Binocular", player hasWeapon "Binocular"];
//    	d_player_stuff = nil;
//__DEBUG_NET("x_setupplayer1.sqf",d_player_stuff)

#ifdef __EQUIP_OPD_ONLY__
SYG_playerRucksackContent = player call SYG_getPlayerRucksackAsStr; // initial player rucksack content in text form
#endif

#ifdef __AI__
ai_counter = 0;
#endif
