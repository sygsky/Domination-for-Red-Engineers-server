// by Xeno, x_addsoldier.sqf to add AI to the player
private ["_type_soldier","_units","_ai_counter","_ai_side_char","_ai_side_unit"];
#include "x_setup.sqf"

_type_soldier = _this select 3;

d_grp_caller = group player;
if (player != leader d_group_caller) exitWith {
	localize "STR_SYS_1172" call XfHQChat; // "You are currently not a group leader, no AI available. Create a new group"
};
_units = units d_grp_caller;

#ifdef __RANKED__
_rank = rank player;
_rankIndex = player call XGetRankIndexFromScoreExt; // extended rank system, may returns value > 6 (colonel return 6)
if (_rankIndex < ("LIEUTENANT" call XGetRankIndex)) exitWith {
	(format [localize "STR_SYS_1174", _rank call XGetRankStringLocalized, "LIEUTENANT" call XGetRankStringLocalized]) call XfHQChat; // "You current rank is %1. You need to be %2 to recruit soldier[s]!"
};

if (score player < ((d_points_needed select 0) + (d_ranked_a select 3))) exitWith {
	(format [localize "STR_SYS_1175", score player, d_ranked_a select 3, "PRIVATE" call XGetRankStringLocalized]) call XfHQChat; // "You can't recruit an AI soldier, costs %2 points, your current score (%1) will drop below %2!"
};
_max_rank_ai = _rankIndex - 2; // 1 - Lieutenant... 10 - Generalissimus
#endif

_ai_counter = 0;
{
	if (!isPlayer _x && alive _x) then {_ai_counter = _ai_counter + 1;};
} forEach _units;
if (_ai_counter > _max_rank_ai) exitWith {
	(format [localize "STR_SYS_1173", _max_rank_ai]) call XfHQChat; // "You allready have %1 AI soldiers under your control, it is not possible to recruit more with your current rank..."
};

#ifdef __RANKED__
// each AI soldier costs score points
player addScore (d_ranked_a select 3) * -1;
#endif

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
		format [_type_soldier, _ai_side_char]
	}
);
#endif

_unit = d_grp_caller createUnit [_ai_side_unit, position AISPAWN, [], 0, "FORM"];
[_unit] join d_grp_caller;
_unit setSkill 1;
_unit setRank "CORPORAL"; // Why???
_unit addEventHandler ["killed", {xhandle = [_this select 0] execVM "x_scripts\x_deleteai.sqf";}];

if (true) exitWith {};
