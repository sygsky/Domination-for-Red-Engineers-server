// by Xeno, x_addsoldier.sqf to add AI to the player
private ["_type_soldier","_units","_ai_counter","_ai_side_char","_ai_side_unit","_msg_arr"];
#include "x_setup.sqf"

_type_soldier = _this select 3;

d_grp_caller = group player;
if (player != leader d_grp_caller) exitWith {
	localize "STR_SYS_1172" call XfHQChat; // "You are currently not a group leader, no AI available. Create a new group"
};
_units = units d_grp_caller;
_ai_counter = {(!isPlayer _x) && (alive _x)} count _units;

_start_rank = d_ranked_a select 28; // initial AI caller rank name
_start_rank_id = _start_rank call XGetRankIndex; // initial AI caller rank id
_ai_low_cost = d_ranked_a select 3; // how many point needed to call 1st AI by caller of any enough rank

#ifdef __RANKED__
_rank = rank player;
_rankIndex = player call XGetRankIndexFromScoreExt; // extended rank system, may returns value > 6 (colonel rank index)
_rank_max_ai = _rankIndex - _start_rank_id + 1; // e.g. 1 - Sergeant, 2 - Lieutenant... 11 - Generalissimus

if ( _rank_max_ai < 1) exitWith {
	(format [localize "STR_SYS_1174", player call XGetRankStringLocalized, _start_rank call XGetRankStringLocalized]) call XfHQChat; // "You current rank is %1. You need to be %2 to recruit soldier[s]!"
};

_ai_big_cost = player call SYG_AIPriceByScore; // price for 2nd and more AI recruinting. 1st always is of low cost
_ai_cost = if (_ai_counter > 0) then {_ai_big_cost} else {_ai_low_cost};

if ( score player < _ai_cost ) exitWith {
	(format [localize "STR_SYS_1175", score player, _ai_cost, "PRIVATE" call XGetRankStringLocalized]) call XfHQChat; // "You can't recruit an AI soldier, costs %2 points, your current score (%1) will drop below %3!"
};

_new_ai_counter = _rank_max_ai -_ai_counter; // how many AI you still can call with your rank

if (_new_ai_counter < 1) exitWith {
	(format [localize "STR_SYS_1173", _ai_counter]) call XfHQChat; // "You already have %1 AI soldiers under your control, it is not possible to recruit more with your current rank..."
};

#else

_rankIndex = player call XGetRankIndexFromScore; // extended rank system, may returns value > 6 (colonel rank index)
_rank_max_ai = _rankIndex - _start_rank_id + 1; // e.g. 1 - Sergeant, 2 - Lieutenant... 11 - Generalissimus
if ( _ai_counter >= _rank_max_ai) exitWith {
	(format [localize "STR_SYS_1173", _ai_counter]) call XfHQChat; // "You already have %1 AI soldiers under your control, it is not possible to recruit more with your current rank..."
};
_ai_cost = _ai_low_cost;

#endif

// each AI soldier costs score points
if (_ai_cost > 0) then
{
    playSound "steal";
    player addScore -_ai_cost;
    (format[localize "STR_AI_11", _ai_cost]) call XfHQChat; // "You paid %1 for one AI, points will be returned when he is fired"
};

_ai_side_char = (
	switch (d_own_side) do {
		case "RACS": {"G"};
		case "WEST": {"W"};
		case "EAST": {"E"};
	}
);

#ifndef __ACE__
_ai_side_unit = (
	if (_type_soldier == "Specop") then {
		switch (d_own_side) do {
			case "RACS": {"SoldierGCommando"};
			case "WEST": {"SoldierWSaboteur"};
			case "EAST": {"SoldierESaboteur"};
		}
	} else {
		format [_type_soldier, _ai_side_char]
	}
);
#else
_ai_side_unit = (
	if (_type_soldier == "Specop") then {
		switch (d_own_side) do {
			case "RACS": {"ACE_SoldierB_INS"};
			case "WEST": {"ACE_SoldierWDemo_A"};
			case "EAST": {"ACE_SoldierEDemo_SNR"};
		}
	} else {
    	if (_type_soldier == "ACE_Soldier%1Medic" && d_own_side == "EAST") then
    	{
            "ACE_SoldierEMedicWoman_VDV" // woman for russian that he was noble
    	}
    	else
    	{
    		format [_type_soldier, _ai_side_char]
    	}
	}
);
#endif

_unit = d_grp_caller createUnit [_ai_side_unit, position AISPAWN, [], 0, "FORM"];
[_unit] join d_grp_caller;
_unit setSkill 0.1;
_unit call SYG_armPilotFull; // Rearm in case of pilot
_unit setVariable ["AI_COST", _ai_cost]; // store cost to refund after demobilization

// set AA unit aiming skill to expert to help base AA defence
if ( (secondaryWeapon _unit) in [ "ACE_FIM92A", "ACE_Strela" ])
    then { _unit setSkill 0.9; };
_unit setRank "CORPORAL"; // Why???
_unit addEventHandler ["killed", {xhandle = [_this select 0] execVM "x_scripts\x_deleteai.sqf";}];

#ifdef __ACE__
if (d_own_side == "EAST") then
{

    _identity =  format["Rus%1", ceil (random 5)];
    if (_ai_side_unit call SYG_isWoman) then
    {
        _identity = "Irina";
        _unit spawn { sleep 1.5; _this say (call SYG_getFemaleExclamation);}
    };
    _msg_arr = [];
    _unit setIdentity _identity; // there are only 5 russina voice in the ACE
    hint localize format["+++ AI setIdentity ""%1""", _identity];
    if ( ! ((_identity == "Irina") || (localize "STR_LANG" == "RUSSIAN")) ) then {
        _msg_arr set [count _msg_arr, [["STR_SYS_1175_1", name _unit] ]];
    };
    _msg_arr set [count _msg_arr, [["STR_SYS_1175_2"] ]];
    ["msg_to_user", "", _msg_arr ] call SYG_msgToUserParser; // "Your recruit (%1) speaks only Russian. Can use idioms in an enemy language"
    playSound "losing_patience";
};
#endif

if (true) exitWith {};
