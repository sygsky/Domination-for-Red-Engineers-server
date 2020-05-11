// by Sygsky, scripts\check_ai_points.sqf - check your points before call for the AI

#include "x_setup.sqf"

_grp_player = group player;
_ai_counter = {!isPlayer _x && alive _x} count (units _grp_player);

_start_rank = d_ranked_a select 28; // initial AI caller rank name
_start_rank_id = _start_rank call XGetRankIndex; // initial AI caller rank id
_ai_low_cost = d_ranked_a select 3; // how many point needed to call 1st AI by caller of any enough rank

_str = "";

#ifdef __RANKED__

_rank =  player call XGetRankFromScoreExt; // rank string
_rank_id = player call XGetRankIndexFromScoreExt; // extended rank system, may returns value > 6 (colonel rank index)

#else

_rank =  player call XGetRankFromScore; // rank string
_rank_id = player call XGetRankIndexFromScore; // rank index

#endif

_rank_max_ai = _rank_id - _start_rank_id + 1; // e.g. 1 - Sergeant, 2 - Lieutenant... 11 - Generalissimus
if ( _rank_max_ai < 1 ) exitWith {
	(format [localize "STR_SYS_1174", player call XGetRankStringLocalized, _start_rank call XGetRankStringLocalized]) call XfHQChat; // "You current rank is %1. You need to be %2 to recruit soldier[s]!"
};

_new_ai_counter = _rank_max_ai -  _ai_counter; // how many AI you still can call with your rank

if (_new_ai_counter < 1) exitWith {
	(format [localize "STR_SYS_1173", _ai_counter]) call XfHQChat; // "You already have %1 AI soldiers under your control, it is not possible to recruit more with your current rank..."
/*
    hint localize format[
        "--- check_ai_points.sqf: _rank %1, _rank_id %2, _rank_max_ai %3, _new_ai_counter %4, _ai_counter %5, _start_rank_id %6",
        _rank, _rank_id, _rank_max_ai, _new_ai_counter, _ai_counter, _start_rank_id];
*/
};

_ai_big_cost = player call SYG_AIPriceByScore; // price for 2nd and more AI recruinting. 1st always is of low cost
_ai_cost = if (_ai_counter > 0) then {_ai_big_cost} else {_ai_low_cost};

_rank_score = _rank_id call XGetScoreFromRank;
if ( (score player - _ai_cost *2) < _rank_score ) then {
    _prev_rank_id = _rank_id - 1;
    _str = format[localize "STR_SYS_1174_2", (_prev_rank_id call XGetRankFromIndex) call XGetRankStringLocalized]; // ". After which you can be demoted to '%1', as pilots cost twice as expensive!"
} else {
    if ( (_ai_counter == 0) && (_new_ai_counter > 1) ) then {
        _str = format[localize "STR_SYS_1174_3", _ai_big_cost, _ai_big_cost * 2]; // ". Next AI will cost you -%1 (%2 if pilot)"
    };
};
/*
hint localize format["--- check_ai_points.sqf: _rank %1, _rank_id %2, _rank_max_ai %3, _new_ai_counter %4, _ai_big_cost %5, _ai_cost %6,_rank_score %7, _ai_counter %8, _start_rank_id %9",
                                               _rank, _rank_id, _rank_max_ai, _new_ai_counter, _ai_big_cost, _ai_cost,
                                               _rank_score, _ai_counter, _start_rank_id];
*/
(format [localize "STR_SYS_1174_1", _ai_counter, _new_ai_counter, _ai_cost,  _str]) call XfHQChat; // "Draftees: you have %1, in the military enlistment office %2. The draftee will cost -%3%4. A pilot is always twice as expensive!"

if (true) exitWith {};
