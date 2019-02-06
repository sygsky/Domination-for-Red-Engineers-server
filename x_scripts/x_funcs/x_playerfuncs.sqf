//
// runs only on client side
//
// x_playerfuncs.sqf by Xeno, initalized at // TODO: add file name 
//
#include "x_setup.sqf"
#include "x_macros.sqf"

//#define __DEBUG__

#define __SUPER_RANKING__

if ( isNil "SYG_repTruckNamesArr" ) then 
{
#ifdef __ACE__			
	SYG_repTruckNamesArr = [ "ACE_Truck5t_Repair" , "ACE_Ural_Repair", "ACE_HMMWV_GMV2" ];
#else				
	SYG_repTruckNamesArr = [ "UralRepair", "Truck5tRepair" ];
#endif		
};

_str_p = format ["%1", player];

#ifndef __NON_ENGINEER_REPAIR_PENALTY__
if (_str_p in d_is_engineer /*|| __AIVer*/) then {
#endif

#ifdef __ACE__
	x_sfunc = {
		private ["_objs"];
		if ((vehicle player) == player && (player call ACE_Sys_Ruck_HasRucksack))then
		{
		    _objs = nearestObjects [player,["LandVehicle","Air","Ship"],5];
		    if (count _objs > 0) then
		    {
		        objectID2 = _objs select 0;
		        if (alive objectID2) then
		        {
		            if(damage objectID2 > 0.0000001 || fuel objectID2<0.3333)then
		            {
		                true
		            }
		            else
		            {
		                false
		            };
		        }
		        else
		        {
		            false
		        };
		    }
		    else
		    {
		        false
		    };
		}
		else
		{
		    false
		};

	};
#else
	x_sfunc = {
		private ["_objs"];
		if ((vehicle player) == player)then{_objs = nearestObjects [player,["LandVehicle","Air"],5];if (count _objs > 0) then {objectID2 = _objs select 0;if (alive objectID2) then {if(damage objectID2 > 0.0000001 || fuel objectID2<1)then{true}else{false};}else{false};};}else{false};
	};
#endif


#ifdef __NON_ENGINEER_REPAIR_PENALTY__
if (_str_p in d_is_engineer /*|| __AIVer*/) then {
#endif
    // Only for engineers
	x_ffunc = {
		private ["_l","_vUp","_angle", "_pos", "_tr", "_trArr", "_dist"];
		if ((vehicle player) == player) then 
		{
			objectID1=(position player nearestObject "LandVehicle");
			if ( !(alive objectID1) || (player distance objectID1) > 8) then {false}
			else
			{
				// check presence of ANY repair truck in vicinity of 20 meters
				_trArr =  nearestObjects [ position player, SYG_repTruckNamesArr, 20]; // find nearest truck in radius 20 meters
				_tr = objNull;
				{
					if ( alive _x ) exitWith { _tr = _x;};
				} forEach _trArr;

				if ( !(isNull _tr)) then 
				{
					objectID1 call SYG_vehIsUpsideDown; // source is in "scripts\SYG_Utils.sqf"
				}
				else{false};
			}
		} 
		else {false};
	};
#ifdef __NON_ENGINEER_REPAIR_PENALTY__
    };
#endif

#ifndef __NON_ENGINEER_REPAIR_PENALTY__
};
#endif

#ifndef __MANDO__
if (!(__ACEVer)) then {
	XIncomingMissile = {
		private ["_vehicle", "_ammo", "_who", "_missile", "_flare", "_flares", "_ran"];
		_vehicle = _this select 0;
		_ammo = _this select 1;
		_who = _this select 2;

		_missile = nearestObject [_who,_ammo];

		if (isNull _missile) exitWith {};

		[_vehicle, "Сброшены осветительные..."] call XfVehicleChat;

		for "_i" from 0 to 10 do {
			_flare = "FlareWhite_M203" createVehicle (position _vehicle);
			_flare setVelocity (velocity _vehicle);
			_flares = _flares + [_flare];
		};

		_ran = random 100;
		if (_ran >= 40) then {
			waitUntil {((_missile distance _vehicle) <= 150)};
			deleteVehicle _missile;
		} else {
			waitUntil {((_missile distance _vehicle) <= 100)};
			[_vehicle, "!!! Опасность !!! По вам выпущена ракета..."] call XfVehicleChat;
		};

		sleep 30.231;
		{
			deleteVehicle _x;
		} forEach _flares;
		_flares = nil;
	};
};
#endif

Xoartimsg = {
	private ["_target_pos"];
	_target_pos = _this;
	if (player distance _target_pos < 50) then {
	    playSound(["fear","bestie","gamlet","fear3","heartbeat","the_trap","koschei"] call XfRandomArrayVal);
		("STR_DANGER_NUM" call SYG_getLocalizedRandomText) call XfHQChat; // "You suddenly became terribly..."
	};
};

#ifndef __ACE__
XFindObstacle = {
	private ["_objs", "_strlist", "_list", "_retval"];
	_objs = nearestObjects [player,[],2];
	_strlist = []; {_strlist = _strlist + [str(_x)];}forEach _objs;
	_list = "";
	_retval = false;
	{_list = _list + format ["obj: %1\n", _x];} forEach _objs;
	{
		d_obstacle = [_strlist,_x] call KRON_getArgRev;
		if (d_obstacle != "") exitWith {_retval = true;};
		sleep 0.01;
	} forEach d_wires;
	_retval
};
#endif

if (_str_p in d_is_medic) then {
	XMashKilled = {
		private ["_mash","_m_name"];
		_mash = _this select 0;
		_m_name = format [localize "STR_MED_5", name player]; //  "Санчасть %1"
		deleteMarker _m_name;
		d_medtent = [];
		(localize "STR_SYS_00") call XfGlobalChat; // "Ваша мед.палатка была уничтожена."
		if (!(isNull _mash)) then {
			deleteVehicle _mash;
		};
	};
};

if (_str_p in d_can_use_mgnests) then {
	XMGnestKilled = {
		private ["_mgnest","_m_name"];
		_mgnest = _this select 0;
		_m_name = format [localize "STR_SYS_02", name player]; // "Пулемёт %1"
		deleteMarker _m_name;
		d_mgnest_pos = [];
		(localize "STR_SYS_03") call XfGlobalChat; // "Ваше пулеметное гнездо было уничтожено."
		if (!(isNull _mgnest)) then {
			deleteVehicle _mgnest;
		};
	};
};

//
// Update client info for recaptured town[s]
//
XRecapturedUpdate = {
	private ["_index","_target_array", "_target_name", "_targetName","_state"];
	_index = _this select 0;
	_state = _this select 1;
	_target_array = target_names select _index;
	_target_name = _target_array select 1;
	_target_rad = (_target_array select 2) max 300; // visible radious of town
	switch (_state) do {
		case 0: { // shade with red slash hatching brush
			_target_name setMarkerColorLocal "ColorRed";
			_target_name setMarkerBrushLocal "FDiagonal";
			_target_name setMarkerSizeLocal [_target_rad +100, _target_rad + 100];
			call compile format ["""%1"" objStatus ""%2"";", _target_array select 3, "FAILED"];
			hint composeText[
				parseText("<t color='#f0ff0000' size='2'>" + localize "STR_SYS_104"/* "Внимание:" */ + "</t>"), lineBreak,
				parseText("<t size='1'>" + format [localize "STR_SYS_105"/* "В %1 обнаружено вражеское присутствие! Зачистить!" */, _target_name] + "</t>")
			];
			format [localize "STR_SYS_105", _target_name] call XfHQChat; // "В %1 обнаружено вражеское присутствие! Зачистить!"
		};
		case 1: {  // fill with green solid brush
			#ifndef __TT__
			_target_name setMarkerColorLocal "ColorGreen";
			#endif
			#ifdef __TT__
			_winner = -1;
			{
				if ((_x select 0) == _index) exitWith {
					_winner = _x select 1;
				};
			} forEach resolved_targets;
			_color = (
				switch (_winner) do {
					case 1: {"ColorBlue"};
					case 2: {"ColorYellow"};
					case 3: {"ColorGreen"};
					default {"ColorGreen"};
				}
			);
			_target_name setMarkerColorLocal _color;
			#endif
			_target_name setMarkerBrushLocal "Solid";
			_target_name setMarkerSizeLocal [_target_rad, _target_rad];
			call compile format ["""%1"" objStatus ""%2"";", _target_array select 3, "DONE"];
			hint composeText[
				parseText("<t color='#f00000ff' size='2'>" + (localize "STR_SYS_106")/* "Отлично!" */ + "</t>"), lineBreak,
				parseText("<t size='1'>" + format [localize "STR_SYS_107"/* "Вы зачистили %1. */, _target_name] + "</t>")
			];
			format [localize "STR_SYS_108", _target_name] call XfHQChat; // "Хорошая работа! Вы зачистили %1."

			//+++ Sygsky, to add scores to player[s] on recapture
#ifndef __TT__
			if (__RankedVer) then 
			{
				_current_target_pos = _target_array select 0;
				if ((player distance _current_target_pos) < (d_ranked_a select 10)) then
				{
					(format [localize "STR_SYS_109",(d_ranked_a select 9)]) call XfHQChat; // "За зачистку города вы получаете очки ( +%1 ) !"
					player addScore (d_ranked_a select 9);
				};
			};
#endif
			//--- Sygsky

		};
	};
};

#ifdef __SUPER_RANKING__
player_already_in_super_rank = false;
#endif

XPlayerRank = {
	private ["_score", "_ret", "_i","_notDone","_prev_rank","_scores","_rank_names","_new_rank","_rank_score","_new_rank"];
	_score = score player;
	
	/*
		d_pseudo_ranks = 	  [1200,1500,2000,2500,3000,5000];
		d_pseudo_rank_names = ["Генерал-майор","Генерал-лейтенант","Генерал-полковник","Генерал армии","Маршал","Генералиссимус"];
	*/

	//+++ Sygsky: add level promotion/demotion for higher available rank of Colonel
#ifdef __SUPER_RANKING__	
	// if you are colonel and have >= 1200 scores
	if ( _score >= (d_pseudo_ranks select 0) ) exitWith
	{
        if ( d_player_old_rank == "PRIVATE" ) then // It is the first time this function is called
        {
           d_player_old_rank = "COLONEL";
           player setRank d_player_old_rank;
        };
		scopeName "exit";
		_notDone     = true;
		_prev_rank   = d_player_old_rank; // rank with score lower than in array pointed to
		_scores      = d_pseudo_ranks;
		_rank_names  = d_pseudo_rank_names;
		_new_rank    = "";
		for "_i" from 0 to (count _rank_names) - 1 do
		{
			_rank_score = _scores select _i;
			_new_rank = _rank_names select _i;
			if ( _score  < _rank_score) then // this is the case
			{
				// get previous rank
				_notDone = false;
				if ( d_player_pseudo_rank == _prev_rank ) then { breakTo "exit"; }; // No changes in rank
				if ( d_player_pseudo_rank == _new_rank ) then // demoted from the higher rank
				{
					(format [localize "STR_SYS_43",_new_rank, _prev_rank]) call XfHQChat; // "Вы разжалованы со звания %1 до %2! Увы, прощай высокое звание на Родине..."
					d_player_pseudo_rank = _prev_rank; // e.g. from G-L to G-M, or from G-M to COL
					breakTo "exit";
				};
				// if here, then promoted due to fact that your rank now is not old one and not new too
				(format [ localize "STR_SYS_44", d_player_pseudo_rank, _prev_rank ]) call XfHQChat; // "Вы повышены в звании с %1 до %2, которое будет присвоено на Родине!"
				d_player_pseudo_rank = _prev_rank; // e.g. from COL to G-M or from COL to G-M etc
                // TODO: sent message to everybody about new super rank player
                // TODO: addAction to get moto/etc from bus stops (but is it impossible?)
                // TODO: check if no players in the same group with the same or higher rank
                _grp = group player;
                _units = (units _grp) - [player]; // group units minus player itself
                if( count _units > 0) then
                {
                    hint localize format["+++ Ranking: grp %1, cnt %2", _grp, count units _grp];
                    _rankIndex = _score call XGetRankIndexFromScore;
                    _highest_ranked_player = objNull;
                    {
                        if ( (isPlayer _x) &&  (( (score _x) call XGetRankIndexFromScore ) > _rankIndex) ) exitWith {_highest_ranked_player = _x;};
                    } forEach _units;
                    if ( isNull _highest_ranked_player  ) then
                    {
                        // TODO: set player leader
                        hint localize format["This player with score %1 (%2) has max rank in the group (count %3)", _score, _new_rank, count (units _grp)];
                    }
                    else
                    {
                        hint localize format["Player %1 has higher rank (%2) than you (%3)",
                        name _highest_ranked_player,
                        _highest_ranked_player call XGetRankFromScoreExt,
                        _score call XGetRankFromScoreExt];
                    };
                };

				breakTo "exit";
			};
			_prev_rank = _new_rank;
		};
		
		if ( _notDone && (d_player_pseudo_rank != _prev_rank) ) then // Player is generalissimus!!!
		{
		    player_already_in_super_rank = true;
			(format [ localize "STR_SYS_45", d_player_pseudo_rank, _new_rank ]) call XfHQChat; // "You have reached an incredible level! From the title %1 to the %2! It doesn't happen! Go home immediately! After all, the Motherland is in danger!!!"
			d_player_pseudo_rank = _new_rank;
			_notDone = false;
		};
/*
 		if ( !_notDone ) then 
		{
			hint localize format["x_playerfuncs.sqf: XPlayerRank params: %1, %2, %3", _score, d_player_old_rank,d_player_pseudo_rank];
		};
 */	
	}; // if ( _score >= (d_pseudo_ranks select 0) ) exitWith
#endif	
	//---
	// standard ranks system of Arma
	if (_score < (d_points_needed select 0) && d_player_old_rank != "PRIVATE") exitWith {
		if (d_player_old_score >= (d_points_needed select 0)) then {
			(format [localize "STR_SYS_66" /* "Вы разжалованы со звания %1 до звания %2" */,d_player_old_rank call XGetRankStringLocalized, localize "STR_TSD9_26"]) call XfHQChat; // Рядового
		};
		d_player_old_rank = "PRIVATE";
		d_rank_pic = d_player_old_rank call XGetRankPic;
		player setRank d_player_old_rank;
		d_player_old_score = _score;
	};
	if (_score < (d_points_needed select 1) && _score >= (d_points_needed select 0) && d_player_old_rank != "CORPORAL") exitWith {
		if (d_player_old_score < (d_points_needed select 1)) then {
			format[ localize "STR_SYS_67"/*  "Поздравляем с присвоением внеочередного звания %1" */,localize "STR_TSD9_27"] call XfHQChat; // Ефрейтора
			playSound "fanfare";
		} else {
			(format [localize "STR_SYS_66"/* "Вы разжалованы со звания %1 до %2" */,d_player_old_rank call XGetRankStringLocalized, localize "STR_TSD9_27"]) call XfHQChat; //Ефрейтора
		};
		d_player_old_rank = "CORPORAL";
		d_rank_pic = d_player_old_rank call XGetRankPic;
		player setRank d_player_old_rank;
		d_player_old_score = _score;
	};
	if (_score < (d_points_needed select 2) && _score >= (d_points_needed select 1) && d_player_old_rank != "SERGEANT") exitWith {
		if (d_player_old_score < (d_points_needed select 2)) then {
			format[localize "STR_SYS_67"/* "Поздравляем с присвоением внеочередного звания %1" */, localize "STR_TSD9_28"] call XfHQChat; // Сержанта
			playSound "fanfare";
		} else {
			(format [localize "STR_SYS_66"/* "Вы разжалованы со звания %1 до звания %2" */, d_player_old_rank call XGetRankStringLocalized, localize "STR_TSD9_28"]) call XfHQChat; // Сержанта
		};
		d_player_old_rank = "SERGEANT";
		d_rank_pic = d_player_old_rank call XGetRankPic;
		player setRank d_player_old_rank;
		d_player_old_score = _score;
	};
	if (_score < (d_points_needed select 3) && _score >= (d_points_needed select 2) && d_player_old_rank != "LIEUTENANT") exitWith {
		if (d_player_old_score < (d_points_needed select 3)) then {
			format[localize "STR_SYS_67"/* "Поздравляем с присвоением внеочередного звания %1" */, localize "STR_TSD9_29"] call XfHQChat; //Лейтенанта
			playSound "fanfare";
		} else {
			(format [localize "STR_SYS_66"/* "Вы разжалованы со звания %1 до звания %2" */, d_player_old_rank call XGetRankStringLocalized,localize "STR_TSD9_29"]) call XfHQChat;
		};
		d_player_old_rank = "LIEUTENANT";
		d_rank_pic = d_player_old_rank call XGetRankPic;
		player setRank d_player_old_rank;
		d_player_old_score = _score;
	};
	if (_score < (d_points_needed select 4) && _score >= (d_points_needed select 3) && d_player_old_rank != "CAPTAIN") exitWith {
		if (d_player_old_score < (d_points_needed select 4)) then {
			format[localize "STR_SYS_67"/* "Поздравляем с присвоением внеочередного звания Капитана" */,localize "STR_TSD9_30"] call XfHQChat;
			playSound "fanfare";
		} else {
			(format [localize "STR_SYS_66"/* "Вы разжалованы со звания %1 до Капитана" */,d_player_old_rank call XGetRankStringLocalized,localize "STR_TSD9_30"]) call XfHQChat;
		};
		d_player_old_rank = "CAPTAIN";
		d_rank_pic = d_player_old_rank call XGetRankPic;
		player setRank d_player_old_rank;
		d_player_old_score = _score;
	};
	if (_score < (d_points_needed select 5) && _score >= (d_points_needed select 4) && d_player_old_rank != "MAJOR") exitWith {
		if (d_player_old_score < (d_points_needed select 4)) then {
			format[localize "STR_SYS_67"/* "Поздравляем с присвоением внеочередного звания Майора" */,localize "STR_TSD9_31"] call XfHQChat;
			playSound "fanfare";
		} else {
			(format [localize "STR_SYS_66"/* "Вы разжалованы со звания %1 до Майора" */,d_player_old_rank call XGetRankStringLocalized,localize "STR_TSD9_31"]) call XfHQChat;
		};
		d_player_old_rank = "MAJOR";
		d_rank_pic = d_player_old_rank call XGetRankPic;
		player setRank d_player_old_rank;
		d_player_old_score = _score;
	};
	if (_score >= (d_points_needed select 5) && d_player_old_rank != "COLONEL") exitWith {
		d_player_old_rank = "COLONEL";
		d_rank_pic = d_player_old_rank call XGetRankPic;
		player setRank d_player_old_rank;
		format["%1. %2",format[localize "STR_SYS_67",localize "STR_TSD9_32"], localize "STR_SYS_68"] call XfHQChat;
		d_player_pseudo_rank = d_player_old_rank;
		playSound "fanfare";
		d_player_old_score = _score;
	};
};

XGetRankIndex = {
	["PRIVATE","CORPORAL","SERGEANT","LIEUTENANT","CAPTAIN","MAJOR","COLONEL"] find (toUpper (_this));
};

//============================================
//+++ Sygsky
// call: _rank_localized = _rank_str call XGetRankStringLocalized;
//
XGetRankStringLocalized = {
    if ( typeName _this == "OBJECT") then
    {
        if (isPlayer _this) then { _this = _this call XGetRankFromScoreExt;};
    };
	switch (toUpper(_this)) do {
		case "PRIVATE":    {localize "STR_TSD9_26"}; // 0
		case "CORPORAL":   {localize "STR_TSD9_27"}; // 1
		case "SERGEANT":   {localize "STR_TSD9_28"}; // 2
		case "LIEUTENANT": {localize "STR_TSD9_29"}; // 3
		case "CAPTAIN":    {localize "STR_TSD9_30"}; // 4
		case "MAJOR":      {localize "STR_TSD9_31"}; // 5
		case "COLONEL":    {localize "STR_TSD9_32"}; // 6

		case "Brigadier-General": {localize "STR_SYS_1000"};  // 7
        case "Lieutenant-General": {localize "STR_SYS_1001"}; // 8
        case "Colonel-General": {localize "STR_SYS_1002,"};   // 9
        case "General-of-the-Army": {localize "STR_SYS_1003"};// 10
        case "Marshal": {localize "STR_SYS_1004"};            // 11
        case "Generalissimo": {localize "STR_SYS_1005"};      // 12
	};
};

// returns namee for the ordinal Arma rank
XGetRankFromScore = {
    if ( typeName _this == "OBJECT") then
    {
        if (isPlayer _this) then { _this = score _this;};
    };
	if (_this < (d_points_needed select 0)) exitWith {"Private"};
	if (_this < (d_points_needed select 1)) exitWith {"Corporal"};
	if (_this < (d_points_needed select 2)) exitWith {"Sergeant"};
	if (_this < (d_points_needed select 3)) exitWith {"Lieutenant"};
	if (_this < (d_points_needed select 4)) exitWith {"Captain"};
	if (_this < (d_points_needed select 5)) then {"Major"} else {"Colonel"};
};

#ifdef __SUPER_RANKING__

XIsRankFromScoreExtended =  {
    if ( typeName _this == "OBJECT") then
    {
        if (isPlayer _this) then { _this = score _this;};
    };
    _this >= argp(d_pseudo_ranks,0)
};

//
// returns rank overall name, from "Private" to "Generalissimus"
//
// call as follow: _rank = (score player) call XGetRankFromScoreExt
//
XGetRankFromScoreExt = {
    private ["_rank"];
    if ( typeName _this == "OBJECT") then
    {
        if (isPlayer _this) then { _this = score _this;};
    };
    if (!(_this call XIsRankFromScoreExtended)) exitWith
    {
        _this call XGetRankFromScore; // returns from "Private"(0) to "Colonel" (6)
    };
    _index = -1; // Colonel
    {
        if ( _this < _x ) exitWith { "Colonel" };
        _index = _index + 1;
    } forEach d_pseudo_ranks;
    (d_pseudo_rank_names select _index) // returns string from "Brigadier-General"(7) to "Generalissimo"(12)
};

XGetRankIndexFromScoreExt = {
    private ["_index"];
    if ( typeName _this == "OBJECT") then
    {
        if (isPlayer _this) then { _this = score _this;};
    };
    if (!(_this call XIsRankFromScoreExtended)) exitWith
    {
        _this call XGetRankIndexFromScore // returns from 0 ("Private") to 6 ("Colonel")
    };
    _index = 6; // Colonel
    {
        if ( _this < _x ) exitWith {};
        _index = _index + 1;
    } forEach d_pseudo_ranks;
    _index // returns from 7("Brigadier-General") to 12("Generalissimo")
};

#endif

XGetRankIndexFromScore = {
    private ["_index"];
    if ( typeName _this == "OBJECT") then
    {
        if (isPlayer _this) then { _this = score _this;};
    };
    _index = 0;
    {
        if (  _this  < _x) exitWith {};
        _index = _index +  1;
    } forEach d_points_needed;
    _index
};

XGetRankPic = {
	switch (toUpper(_this)) do {
		case "PRIVATE": {"\warfare\Images\rank_private.paa"};
		case "CORPORAL": {"\warfare\Images\rank_corporal.paa"};
		case "SERGEANT": {"\warfare\Images\rank_sergeant.paa"};
		case "LIEUTENANT": {"\warfare\Images\rank_lieutenant.paa"};
		case "CAPTAIN": {"\warfare\Images\rank_captain.paa"};
		case "MAJOR": {"\warfare\Images\rank_major.paa"};
		default {"\warfare\Images\rank_colonel.paa"};
	}
};

#ifdef __ACE__
XCheckForMap = {
	private ["_retval", "_ruckmags"];
	_retval = false;
	if (player hasWeapon "ACE_Map") then {
		_retval = true;
	} else {
		if (player call ACE_Sys_Ruck_HasRucksack) then {
			_ruckmags = [];
			if (format["%1",player getVariable "ACE_Ruckmagazines"] != "<null>") then {
				_ruckmags = player getVariable "ACE_Ruckmagazines";
			};
			if (count _ruckmags > 0) then {
				{
					if ((_x select 0) == "ACE_Map_PDM") exitWith {_retval = true;};
				} forEach _ruckmags;
			};
		}
	};
	_retval
};
#endif