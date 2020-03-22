/* scripts\barracks_add_actions.sqf
	author: Sygsky

	description:
	    try to add actions to AI_HUT
        arguments: ["sound_name"] execVM "scripts\barracks_add_actions.sqf"

	returns: nothing
*/

if (isServer && ! X_SPE) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#ifdef __AI__

// check for the AI_HUT to be alive
if (isNil "AI_HUT") exitWith {hint localize "--- barracks_add_actions.sqf: no AI_HUT detected"}; // no hut
hint localize format["+++ %1 barracks_add_actions.sqf starting...", _this];
if (typeName _this == "ARRAY") then
{
    if ( count _this > 0) then
    {
        _sound= _this select 0;
        if (typeName _arg == "STRING") then
        {
            AI_HUT say _sound;
        };
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
		AI_HUT addAction[localize "STR_AI_8","x_scripts\x_dismissai.sqf"]; // "Dismiss AI"
	} else {
		AI_HUT addAction[localize "STR_AI_1","x_scripts\x_addsoldier.sqf","ACE_Soldier%1B"];
		AI_HUT addAction[localize "STR_AI_2","x_scripts\x_addsoldier.sqf","ACE_Soldier%1AT"];
		AI_HUT addAction[localize "STR_AI_3","x_scripts\x_addsoldier.sqf","ACE_Soldier%1Medic"];
		AI_HUT addAction[localize "STR_AI_4","x_scripts\x_addsoldier.sqf","ACE_Soldier%1MG"];
		AI_HUT addAction[localize "STR_AI_5","x_scripts\x_addsoldier.sqf","ACE_Soldier%1Sniper"];
		AI_HUT addAction[localize "STR_AI_6","x_scripts\x_addsoldier.sqf","ACE_Soldier%1AA"];
		AI_HUT addAction[localize "STR_AI_7","x_scripts\x_addsoldier.sqf","Specop"];
		AI_HUT addAction[localize "STR_AI_7_1","x_scripts\x_addsoldier.sqf","ACE_Soldier%1Pilot"]; // Pilot

		AI_HUT addAction[localize "STR_AI_8","x_scripts\x_dismissai.sqf"];
	};
	_marker_name = "Recruit_x";
	if ( ( getMarkerType _marker_name) == "") then // no such marker
	{
    	[_marker_name, position AI_HUT,"ICON","ColorYellow",[0.5,0.5],localize "STR_SYS_1171",0,"DOT"] call XfCreateMarkerLocal; // "Recruit Barracks"
	    hint localize "+++ barracks_add_actions.sqf: Barracks marker drawn";
	};
}
else
{
    AI_HUT addAction[localize "STR_CHECK_ITEM","scripts\info_barracks.sqf"]; // "Inspect"
};

#endif