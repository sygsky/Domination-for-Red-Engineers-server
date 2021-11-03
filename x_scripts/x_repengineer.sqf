// by Xeno
//
// x_scripts\x_repengineer.sqf
//
// Runs only on client side
//
// Modified by Sygsky in 2018. Limited by rank refuelling + score by step count not vehicle type
//

#include "x_setup.sqf"

// #define __DEBUG__

private ["_aid","_caller","_total_steps","_damage","_damage_ok","_dmg_steps","_fuel","_fuel_ok","_fuel_steps",
        "_rep_count","_rep_array","_break_str","_rep_action","_type_name", "_trArr","_fuel_capacity_in_litres","_addscore"];


#ifdef __NON_ENGINEER_REPAIR_PENALTY__
_is_engineer = format ["%1", player] in d_is_engineer;
// hint localize format["_is_engineer = %1", _is_engineer];
#endif

_caller = _this select 1;
_aid = _this select 2;

_truck_near = objNull;
_trArr =  nearestObjects [ position player, SYG_repTruckNamesArr, 21]; // find nearest repair vehicle in radius 20 meters
{
    if ( alive _x ) exitWith { _truck_near = _x; };
} forEach _trArr;

if (!d_eng_can_repfuel && (isNull _truck_near) ) exitWith {
	hint (localize "STR_SYS_18"); //"Следует восстановить способность ремонта и заправки техники на базе...";
};

// print info about nearby truck
if (!d_eng_can_repfuel) then {
	(format [localize "STR_SYS_18_2", typeOf _truck_near, round	(player distance _truck_near)]) call XfHQChat; // "Near %1 (%2 m.), repairs possible!"
};

#ifdef __RANKED__

if (score player < (d_ranked_a select 0)) exitWith {
	(format [localize "STR_SYS_139", score player,(d_ranked_a select 0)]) call XfHQChat; // "Для ремонта и заправки техники необходимо очков: %2. Вы имеете только %1 ..."
};

 if (time >= d_last_base_repair) then {
	d_last_base_repair = -1;
};
if (player in (list d_engineer_trigger) && d_last_base_repair != -1) exitWith {
	_total_steps = ceil((d_last_base_repair - time)/60);
	// "Wait some time to restore repairing ability..."
	(format[localize "STR_SYS_17",_total_steps]) call XfHQChat;
};
if (player in (list d_engineer_trigger)) then {d_last_base_repair = time + 300;};
#endif

_caller removeAction _aid;
if (!(local _caller)) exitWith {};
_rep_count = 1;

if (objectID2 isKindOf "Air") then {
	_rep_count = 0.1;
} else {
	if (objectID2 isKindOf "Tank") then {
		_rep_count = 0.2;
	} else {
		_rep_count = 0.3;
	};
};

_fuel = fuel objectID2; // fuel the vehicle has (0..1)
_damage = damage objectID2;

_dmg_steps    = (_damage / _rep_count); // how many undamage steps for reparing

_fuel_capacity_in_litres = objectID2 call SYG_fuelCapacity; // litres of fuel in vehicle fuel tanks
#ifdef __LIMITED_REFUELING__
_refuel_add = 0;

	#ifdef __SUPER_RANKING__
_rankIndex = player call XGetRankIndexFromScoreExt; // extended rank system, may returns value > 6 (colonel rank index)
	#else
_rankIndex = player call XGetRankIndexFromScore; // rank index
	#endif

_refuel_volume = d_refuel_volume + d_refuel_per_rank * _rankIndex; // how many liters can refuel the player

if (_fuel_capacity_in_litres > 0) then {
   _refuel_add = _refuel_volume/_fuel_capacity_in_litres;  // max part of volume he could refuel, (note that value in Arma config not in litres!)
};
_fuel_add      = _refuel_add min (1 - _fuel);     // how many he will up to the fuel tank limit
_refuel_limit  = ( _fuel + _fuel_add ) min 1.0;   // limit value he can refuel up to the capacity of the vehicle fuel tank

_fuel_steps = 0;
if (_refuel_add > 0) then {
	_fuel_steps = _refuel_volume * (_fuel_add / _refuel_add) / 20; // how many animations are need to complete refueling
};

_fuel_vol_on_step    = 0; // default is "already refuelled"
if ( abs(_fuel_steps) > 0.0000001) then {_fuel_vol_on_step = _fuel_add /_fuel_steps;}; // how many refuel at one step
//hint localize format["x_repengineer.sqf: %1, _fuel %8, _fuel_capacity_in_litres %2, _refuel_add %3, _fuel_add %4, _refuel_limit %5, _fuel_steps %6, _fuel_vol_on_step %7, damage %9, _dmg_steps %10", typeOf objectID2,_fuel_capacity_in_litres,_refuel_add,_fuel_add,_refuel_limit,_fuel_steps,_fuel_vol_on_step,_fuel,_damage,_dmg_steps];

_rep_array = [objectID2,_refuel_limit];
#else
_refuel_limit  = 1.0;
_fuel_steps      = ((_refuel_limit - _fuel) / _rep_count); // how many refuel steps for refueling
_fuel_vol_on_step    = _rep_count; // how may refuel at one step
_rep_array     = [objectID2];
//hint localize "x_repengineer.sqf: No __LIMITED_REFUELING__ defined";
#endif

#ifdef __LIMITED_REFUELING__
_total_steps = ceil (_dmg_steps) + ceil (_fuel_steps);
#else
_total_steps = ceil (_dmg_steps);
#endif

_lfuel = format[localize "STR_SYS_15"/* "%1/%2 л." */,round(_fuel_capacity_in_litres*_fuel),_fuel_capacity_in_litres];
hint format [localize "STR_SYS_16"/* "Статус техники:\n---------------------\nТопливо: %1\nПовреждение: %2" */,_lfuel, round(_damage*1000)/1000];

_type_name = [typeOf (objectID2),0] call XfGetDisplayName;
(format [localize "STR_SYS_19", round(_damage *100), "%", round(_refuel_volume), _type_name]) call XfGlobalChat; // "Repair %1%2, refuel %3 L.: %4... wait..."
_damage_ok = false;
_fuel_ok = false;
d_cancelled = false;
_break_str = "";
_pos = getPos player;
_rep_action = player addAction[localize "STR_SYS_77","x_scripts\x_cancelrep.sqf"]; // "Отменить обслуживание"

// #413: off engine before repairing. TODO: Not works on client computer, try to do on server in the bright  future
if ( !(alive (driver objectID2) ) ) then {
	// switch engine off only if driver not alive or is absent
	if (isEngineOn objectID2) then {
		objectID2 engineOn false;
	};
};

_addscore = 0; // how many repair/refuel steps were done

for "_i" from 1 to _total_steps do {
	// print info about action type
	if (!_damage_ok) then {
#ifdef __NON_ENGINEER_REPAIR_PENALTY__
		if (!_is_engineer) then {  (format[localize "STR_SYS_152", (_addscore + 1) * __NON_ENGINEER_REPAIR_PENALTY__ ]) call XfGlobalChat }// Repair -5 ...
		else {
#endif
	        (format[localize "STR_SYS_152", _addscore + 1]) call XfGlobalChat; // "Still working (score %1)..."
#ifdef __NON_ENGINEER_REPAIR_PENALTY__
		};
#endif
#ifdef __LIMITED_REFUELING__
	} else  {
        if (!_fuel_ok) then { (localize "STR_SYS_257") call XfGlobalChat; }; // Refueling ...
#endif
	};

	player playMove "AinvPknlMstpSlayWrflDnon_medic";
	sleep 3.0;
	waitUntil {animationState player != "AinvPknlMstpSlayWrflDnon_medic"}; // this animation cycle duration is approximatelly 6 seconds

	if (!alive player) exitWith { _break_str = "STR_SYS_142_3"; }; // "You are dead, service is cancelled..."

	if (d_cancelled) exitWith { _break_str = "STR_SYS_136"; }; // The service is cancelled...

	if (vehicle player != player) exitWith { _break_str = "STR_SYS_142"; }; // "Service from the vehicle is impossible..."

	if ( ! (alive objectID2) ) exitWith { _break_str = "STR_SYS_142_1"; };// "The vehicle burned out... you're too late!"

	if ( (_pos distance player) > 10 ) exitWith {_break_str = "STR_SYS_142_2";}; // "You are far from the vehicle..."

	if (!_damage_ok) then {
		_damage = _damage - _rep_count;
		if ( _damage <= 0 ) then {_damage = 0;_damage_ok = true;};
		_addscore = _addscore + 1;
	} else  {
        if (!_fuel_ok) then {
            _fuel = _fuel + _fuel_vol_on_step;
            if (_fuel >= _refuel_limit) then {_fuel = _refuel_limit; _fuel_ok = true;};
        };
	};
	_lfuel = format[localize "STR_SYS_15"/* "%1/%2 л." */,round(_fuel_capacity_in_litres*_fuel),_fuel_capacity_in_litres];
	hint format [localize "STR_SYS_16"/* "Статус техники:\n---------------------\nТопливо: %1\nПовреждение: %2" */,_lfuel, round(_damage*1000)/1000];
	if ( _damage_ok && _fuel_ok ) exitWith{};  // completed
};

player removeAction _rep_action;

// Service may be cancelled by any circumstances
if (_break_str != "") exitWith {
	if ( alive player ) then { playSound "losing_patience" }; // death usually have special sounds
	(localize _break_str) call XfGlobalChat;
};

d_eng_can_repfuel = false; // Well, refuel ability is exhausted

#ifdef __RANKED__

	#ifdef __DEBUG__
hint localize format["*** x_repengineer.sqf: _addscore = %1 in %2 total steps (rep %3, fuel %4), ", _addscore, _total_steps, ceil(_dmg_steps), ceil(_fuel_steps) ];
	#endif

if (_addscore > 0) then {
    _str = "STR_SYS_137"; //"Добавлено очков за обслуживание техники: %1 ..."
	#ifdef __DEBUG__
	hint localize format["*** x_repengineer.sqf: (_addscore > 0) _str = ""%1""", _str ];
	#endif
	#ifdef __NON_ENGINEER_REPAIR_PENALTY__
    if (!_is_engineer) then {
        _addscore = _addscore * __NON_ENGINEER_REPAIR_PENALTY__; // must be negative value!
        SYG_engineering_fund = SYG_engineering_fund - _addscore; // add to enginering fund, not subtract!!!
        publicVariable "SYG_engineering_fund"; // send spent scores to the fund
    	#ifdef __REP_SERVICE_FROM_ENGINEERING_FUND__
        _str = "STR_SYS_137_2"; // "Maintenance score (%1) is reallocated to the Engineering Fund (%2)"
    	#endif
    	#ifndef __REP_SERVICE_FROM_ENGINEERING_FUND__
        _str = "STR_SYS_137_1"; //"Subtracted points for maintenance: %1 ..."
    	#endif
		#ifdef __DEBUG__
		hint localize format["*** x_repengineer.sqf: (!_is_engineer _str) = ""%1""", _str ];
		#endif
    };
	#endif
	if (alive objectID2) then {
		//player addScore _addscore;
		_addscore call SYG_addBonusScore;
		(format [localize _str, _addscore, SYG_engineering_fund]) call XfHQChat;
	} else {
		(localize "STR_SYS_138_1") call XfGlobalChat; // "You didn't make it, the vehicle burned..."
	};
};
#endif

rep_array = _rep_array;
["rep_array",_rep_array] call XSendNetStartScriptAll;
_rep_array call x_repall;

(format [localize "STR_SYS_138", _type_name]) call XfGlobalChat; // "Обслуживание закончено: %1 ..."

if (true) exitWith {};

