// by Xeno, x_gettargetbonus.sqf, creates bonus vehicle for main targed completion.
if (!isServer) exitWith {}; // Runned on server only

#include "x_setup.sqf"
#include "x_macros.sqf"

private ["_dir","_pos","_posa","_vehicle","_town","_counterattack_occurred","_last_town_index"];

//  smart select bonus according to the size of sieged town -> the larger town the bigger bonus
// 
// current_target_index -> index of completed town in target list

extra_bonus_number      = -1;

_counterattack_occurred = _this select 0; // Counter attack was started and finished (true) or  not (false)
_last_town_index        = _this select 1; // last town index to create bonus if new BattleField Bonus system is on

#ifdef __DEFAULT__

_town = target_names select _last_town_index; // call SYG_getTargetTown; // town def array
if ( count _town > 0 ) then {// town is defined

    hint localize format["+++ find bonus vehicle for town %1 (big_town_radious %2)", _town, big_town_radious];
    // new feature to select main target bonus indexes
	if ( (_town select 2) >= big_town_radious ) then { // select from best vehicles (big bonus)
	    extra_bonus_number = mt_big_bonus_params call SYG_findTargetBonusIndex;
        hint localize format["+++ x_gettargetbonus.sqf: current veh list after get next is %1", mt_big_bonus_params select 1];
	} else {
	    extra_bonus_number = mt_small_bonus_params call SYG_findTargetBonusIndex;
	};

//---------------------------------------------------------------

} else {
	hint localize "--- error in x_gettargetbonus.sqf: no target town defined!!!";
};

#endif

if ( extra_bonus_number < 0 ) then {
	hint localize "--- extra_bonus_number find error: get vehicle from small array only";
	extra_bonus_number = mt_bonus_vehicle_array call XfRandomFloorArray; // случайное число в диапазоне длины массива
};
sleep 1.012;

#ifndef __TT__
_posa = mt_bonus_positions select (extra_bonus_number mod (count mt_bonus_positions)); _pos = _posa select 0;_dir = _posa select 1;
#endif

#ifdef __TT__
_pos = [];
_dir = 0;
// die gewinner seite, danach posi ausw�hlen
if (mt_winner == 1) then {
	_west = mt_bonus_positions select 0;
	_posa = _west select extra_bonus_number; _pos = _posa select 0;_dir = _posa select 1;
} else {
	if (mt_winner == 2) then {
		_racs = mt_bonus_positions select 1;
		_posa = _racs select extra_bonus_number; _pos = _posa select 0;_dir = _posa select 1;
	} else {
		if (mt_winner == 3) then {
			_west = mt_bonus_positions select 0;
			_posa = _west select extra_bonus_number; _pos = _posa select 0;_dir = _posa select 1;
			_vehicle2 = (mt_bonus_vehicle_array select extra_bonus_number) createVehicle (_pos);
			_vehicle2 setVariable ["RECOVERABLE", true];
			_vehicle2 setDir _dir;
			_vehicle2 execVM "x_scripts\x_wreckmarker.sqf";
			_racs = mt_bonus_positions select 1;
			_posa = _racs select extra_bonus_number; _pos = _posa select 0;_dir = _posa select 1;
		};
	};
};
#endif

// must be ["target_clear",target_clear, extra_bonus_number, _counterattack_occurred, _town_stat_arr] call XSendNetStartScriptClient
_bonus_score_arr = call SYG_townStatCalcScores;
target_clear = true; // town is liberated, no new occupied towns is created while target_clear is true

SYG_players_online = []; // collector for online player names
["target_clear",target_clear, extra_bonus_number, _counterattack_occurred, _bonus_score_arr] call XSendNetStartScriptClient;

// hint localize format["+++ DEBUG: town bonus info sent to all players (%1)", _bonus_score_arr];
// assing bonus scores to offline players
_bonus_score_arr spawn {
	sleep 10; // wait until all online clients send confirmation messages
	private ["_offline_arr","_arr","_add_arr","_ind","_item","_add","_x"];

	_arr = (_this select 0); // all town player names array
	_add_arr = (_this select 1); // all town player town bonus score array

	_offline_arr = (+ (_this select 0)) - SYG_players_online; // remain only offline players in list
	if ( count SYG_players_online == 0 ) then {
		hint localize "+++ No fighters involved in the liberation of the city have been found.";
	} else {
		{	// print online player bonus score
			_ind = _arr find _x;
			if ( _ind >= 0 ) then  {
				_add = _add_arr select _ind; // assigned bonus coefficient (as decimal part of town bonus score, from 0.0 to 1.0)
				if ( !isNil "SYG_townMaxScore" ) then {
				 	_add = (round(_add * SYG_townMaxScore)) max 1; // add minimum +1 score on a town liberation
					hint localize format["+++ Online player ""%1"" town bonus score +%2", _x, _add];
				} else {
					hint localize format["+++ Online player ""%1"" town bonus coeff +%2", _x, _add];
				};
			};
		} forEach SYG_players_online;
	};

//	hint localize format["+++ DEBUG: town bonus offline players (%1) processing", _offline_arr];
	if ( count _offline_arr == 0) then {
		hint localize "+++ No offline players involved in the battle for the city were found.";
	} else {
		{
			_ind = _arr find _x;	// this player is offline, add score to him indirectly
			if (_ind >= 0 ) then  {
				_add = _add_arr select _ind; // assigned bonus coefficient (as decimal part of score value 40, from 0.0 to 1.0)
				_ind = d_player_array_names find _x; // find player in the system misc array
				if (_ind >= 0) then {
					_item = d_player_array_misc select _ind; // player stats descriptor
					if (!isNil "SYG_townMaxScore") then {
						_add = (round(_add * SYG_townMaxScore)) max 1; // add minimum +1 score on a town liberation
						_item set [3, (_item select 3) + _add]; // add town bonus score to the player
					};
					hint localize format["+++ Offline player ""%1"" town bonus value +%2", _x, _add];
				};
			};
		} forEach _offline_arr;
	};
	SYG_players_online = nil;
};

#ifdef __DOSAAF_BONUS__
_vehicle = [_town select 0, _town select 2, mt_bonus_vehicle_array select extra_bonus_number] call SYG_createBonusVeh;
hint localize format["+++ x_scripts\x_gettargetbonus.sqf: main target DOSAAF vehicle ""%1"" created ", typeOf _vehicle];
#else
_vehicle = (mt_bonus_vehicle_array select extra_bonus_number) createVehicle (_pos);
_vehicle setDir _dir;
_vehicle call SYG_assignVehAsBonusOne;
hint localize format["+++ x_scripts\x_gettargetbonus.sqf: bonus vehicle created ""%1"" at %2, pos %3", typeOf _vehicle, _vehicle call SYG_MsgOnPos, getPos _vehicle];
#endif


//
// RESTORE DESTROYED BUILDINGS
//
#ifdef __DEFAULT__
{
    _mash = nearestObject [argp( _x, 0), "MASH"];
    _rebuild_mash = false;
    // try to repair object if it is damaged
    if ( !isNull ( _mash ) ) then {
        if (!alive _mash) then { _mash removeAllEventHandlers "hit";  _mash removeAllEventHandlers "dammaged"; deleteVehicle _mash;sleep 0.2; _mash = objNull; _rebuild_mash = true;};
    };
    // (re)build mash if not available
    if ( (_vehicle isKindOf "Plane") || _rebuild_mash ) then {
        if ( isNull _mash) then {
            _mash = createVehicle ["MASH", argp(_x,0), [], 0, "NONE"];
            sleep 1;
            _mash setDir argp(_x,1);
            ADD_HIT_EH(_mash)
            ADD_DAM_EH(_mash)
            hint localize format["+++ x_scripts\x_gettargetbonus.sqf: MASH [re]created near plane service at %2, main target bonus plane %1", typeOf _vehicle, argp(_x,0) call SYG_nearestLocationName];
        };
    };

} forEach [ [ [ 9359.855469, 10047.625000, 0 ], 190 ], [ [18035,18908,0 ], 260 ] ]; // two mash sites
#endif

_pos = nil;
_dir = nil;
_posa = nil;

[_vehicle] spawn {
	sleep 60; // wait a minute to report position after this delay
	hint localize format["+++ x_scripts\x_gettargetbonus.sqf: main target bonus after 1 munute is at pos %1", getPos (_this select 0)];
}

if (true) exitWith {};
