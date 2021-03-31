/* scripts\barracks_add_actions.sqf
	author: Sygsky

	description:
	    try to add actions to AI_HUT
        arguments:  ["add_barracks_actions", AI_HUT, "AlarmBell"] execVM "scripts\barracks_add_actions.sqf" execVM "scripts\barracks_add_actions.sqf"

	returns: nothing
*/

if (isServer && ! X_SPE) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#ifdef __AI__

// check for the AI_HUT to be alive
if (isNil "AI_HUT") exitWith {hint localize "--- barracks_add_actions.sqf: AI_HUT is nil"}; // no hut
hint localize format["+++ %1 barracks_add_actions.sqf starting...", _this];
if (typeName _this == "ARRAY") then {
    if ( count _this > 2) then {
        _sound= _this select 2;
        if (typeName _sound == "STRING") then { if (_sound != "") then { AI_HUT say _sound; }; };
    }
};

_string_player = format ["%1",player];

if ( _string_player in d_can_use_artillery ) then {

    AI_HUT addEventHandler [   "hit", {AI_HUT setDamage 0}];
    AI_HUT addEventHandler ["dammaged", {AI_HUT setDamage 0}];

	if (!(__ACEVer)) then {
		AI_HUT addAction[localize "STR_AI_1","x_scripts\x_addsoldier.sqf","Soldier%1B"]; //"Recruit Soldier"
		AI_HUT addAction[localize "STR_AI_2","x_scripts\x_addsoldier.sqf","Soldier%1AT"]; // "Recruit AT Soldier"
		AI_HUT addAction[localize "STR_AI_3","x_scripts\x_addsoldier.sqf","Soldier%1Medic"]; // "Recruit Medic",
		AI_HUT addAction[localize "STR_AI_4","x_scripts\x_addsoldier.sqf","Soldier%1MG"]; // "Recruit MG Gunner"
		AI_HUT addAction[localize "STR_AI_5","x_scripts\x_addsoldier.sqf","Soldier%1Sniper"]; // "Recruit Sniper"
		AI_HUT addAction[localize "STR_AI_6","x_scripts\x_addsoldier.sqf","Soldier%1AA"];  // "Recruit AA Soldier"
		AI_HUT addAction[localize "STR_AI_7","x_scripts\x_addsoldier.sqf","Specop"]; // "Recruit Specop"
	} else {

//#define __LOCALE_RECRUITS__
#ifdef __LOCALE_RECRUITS__ // Add locale specific recruits not soviet ones
		AI_HUT addAction[localize "STR_AI_1","x_scripts\x_addsoldier.sqf",["ACE_SoldierAR_INS","ACE_SoldierG_B_INS_A",/*"ACE_SoldierG_B_INS_R",*/"ACE_SoldierG_SR_INS_R","ACE_SoldierG_MediumMort"]];
		AI_HUT addAction[localize "STR_AI_2","x_scripts\x_addsoldier.sqf",["ACE_SoldierG_AT_INS_A","ACE_SoldierG_RPG_INS_R","ACE_SoldierG_RPG_INS_A","ACE_SoldierAT_INS","ACE_SoldierRPG_INS"]];
		AI_HUT addAction[localize "STR_AI_3","x_scripts\x_addsoldier.sqf","ACE_Soldier%1Medic"];
		AI_HUT addAction[localize "STR_AI_4","x_scripts\x_addsoldier.sqf","ACE_SoldierG_MG_INS_A"];
		AI_HUT addAction[localize "STR_AI_5","x_scripts\x_addsoldier.sqf",["ACE_SoldierSniper_INS","ACE_SoldierG_Sniper_INS_A","ACE_SoldierG_Sniper_INS_R"]];
		AI_HUT addAction[localize "STR_AI_6","x_scripts\x_addsoldier.sqf",["ACE_SoldierAA_INS","ACE_SoldierG_AA_INS_A"]];
		AI_HUT addAction[localize "STR_AI_7","x_scripts\x_addsoldier.sqf",["ACE_SoldierG_Demo_INS_A","ACE_SoldierG_Miner_INS_R"]];
#endif
#ifndef __LOCALE_RECRUITS__ // Add locale specific recruits not soviet ones
		AI_HUT addAction[localize "STR_AI_1","x_scripts\x_addsoldier.sqf","ACE_Soldier%1B"];
		AI_HUT addAction[localize "STR_AI_2","x_scripts\x_addsoldier.sqf","ACE_Soldier%1AT"];
		AI_HUT addAction[localize "STR_AI_3","x_scripts\x_addsoldier.sqf","ACE_Soldier%1Medic"];
		AI_HUT addAction[localize "STR_AI_4","x_scripts\x_addsoldier.sqf","ACE_Soldier%1MG"];
		AI_HUT addAction[localize "STR_AI_5","x_scripts\x_addsoldier.sqf","ACE_Soldier%1Sniper"];
		AI_HUT addAction[localize "STR_AI_6","x_scripts\x_addsoldier.sqf","ACE_Soldier%1AA"];
		AI_HUT addAction[localize "STR_AI_7","x_scripts\x_addsoldier.sqf","Specop"];
#endif
		if (d_enemy_side == "EAST") then {
			AI_HUT addAction[localize "STR_AI_7_1","x_scripts\x_addsoldier.sqf", "BISCamelPilot" /*"ACE_Soldier%1Pilot"*/]; // Pilot
		} else {
			// Set random pilot type
			AI_HUT addAction[ localize "STR_AI_7_1","x_scripts\x_addsoldier.sqf", ["BISCamelPilot2","ACE_SoldierEPilot_IRAQ_RG"] ]; // Pilot
		};
	};
	AI_HUT addAction[localize "STR_AI_8","x_scripts\x_dismissai.sqf"]; // "Dismiss AI"

	_marker_name = "Recruit_x";
	if ( ( getMarkerType _marker_name) == "") then {// no such marker
    	[_marker_name, position AI_HUT,"ICON","ColorYellow",[0.5,0.5],localize "STR_SYS_1171",0,"DOT"] call XfCreateMarkerLocal; // "Recruit Barracks"
	    hint localize "+++ barracks_add_actions.sqf: Barracks marker drawn";
	};
} else {
    AI_HUT addAction[localize "STR_CHECK_ITEM","scripts\info_barracks.sqf"]; // "Inspect"
};
AI_HUT addAction[localize "STR_AI_8_1","scripts\check_ai_points.sqf"]; // "Check your points"

#endif