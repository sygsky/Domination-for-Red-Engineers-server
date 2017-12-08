// by Xeno
//
// x_repengineer.sqf
//
// Runs only on client side
//

#include "x_setup.sqf"

private ["_aid","_caller","_coef","_damage","_damage_ok","_damage_val","_fuel","_fuel_ok","_fuel_val","_rep_count","_rep_array","_breaked_out","_rep_action","_type_name", "_trArr","_fuel_capacity_in_litres"];

_caller = _this select 1;
_aid = _this select 2;

_truck_near = false;
#ifdef __OLD__
if (player distance TR7 < 21 || player distance TR8 < 21) then {
	_truck_near = true;
};
#else
	_trArr =  nearestObjects [ position player, SYG_repTruckNamesArr, 21]; // find nearest truck in radius 20 meters
	_truck_near = false;
	{
		if ( alive _x ) exitWith { _truck_near = true; };
	} forEach _trArr;
#endif
if (!d_eng_can_repfuel && !_truck_near) exitWith {
	hint (localize "STR_SYS_18");//"Следует восстановить способность ремонта и заправки техники на базе...";
};

#ifdef __RANKED__

if (score player < (d_ranked_a select 0)) exitWith {
	(format [localize "STR_SYS_139", score player,(d_ranked_a select 0)]) call XfHQChat; // "Для ремонта и заправки техники необходимо очков: %2. Вы имеете только %1 ..."
};

 if (time >= d_last_base_repair) then {
	d_last_base_repair = -1;
};
if (player in (list d_engineer_trigger) && d_last_base_repair != -1) exitWith {
	_coef = ceil((d_last_base_repair - time)/60);
	// "Вы недавно отремонтировали что-то на базе. Теперь придётся либо ждать около %1 мин., либо воспользоваться ремонтным грузовиком..."
	(format[localize "STR_SYS_17",_coef]) call XfHQChat;
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

_fuel = fuel objectID2;
_damage = damage objectID2;

_damage_val    = (_damage / _rep_count); // how many undamage steps for reparing

_fuel_capacity_in_litres = objectID2 call SYG_fuelCapacity; // litres of fuel in vehicle fuel tanks
#ifdef __LIMITED_REFUELLING__
_refuel_add = 0;
if (_fuel_capacity_in_litres > 0) then
{
   _refuel_add = d_refuel_volume/_fuel_capacity_in_litres;  // max part of volume he could refuel, not in litres
};
_fuel_add      = _refuel_add min (1 - _fuel);     // how many he will up to the fuel tank limit
_refuel_limit  = ( _fuel + _fuel_add ) min 1.0;   // limit value he can refuel up to the capacity of the vehicle fuel tank

_fuel_val = 0;
if (_refuel_add > 0) then
{
	_fuel_val = d_refuel_volume * (_fuel_add / _refuel_add) / 20; // how many animations are need to complete refuelling
};

_fuel_count    = 0; // default is "already refuelled"
if ( abs(_fuel_val) > 0.0000001) then {_fuel_count = _fuel_add /_fuel_val;}; // how many refuel at one step
//hint localize format["x_repengineer.sqf: %1, _fuel %8, _fuel_capacity_in_litres %2, _refuel_add %3, _fuel_add %4, _refuel_limit %5, _fuel_val %6, _fuel_count %7, damage %9, _damage_val %10", typeOf objectID2,_fuel_capacity_in_litres,_refuel_add,_fuel_add,_refuel_limit,_fuel_val,_fuel_count,_fuel,_damage,_damage_val];

_rep_array = [objectID2,_refuel_limit];
#else
_refuel_limit  = 1.0;
_fuel_val      = ((_refuel_limit - _fuel) / _rep_count); // how many refuel steps for refuelling
_fuel_count    = _rep_count; // how may refuel at one step
_rep_array     = [objectID2];
//hint localize "x_repengineer.sqf: No __LIMITED_REFUELLING__ defined";
#endif

_coef = (
	if (_fuel_val == _damage_val) then {
		_damage_val
	} else {
		if (_fuel_val > _damage_val) then {
			_fuel_val
		} else {
			_damage_val
		}
	}
);
_coef = ceil _coef;

_lfuel = format[localize "STR_SYS_15"/* "%1/%2 л." */,round(_fuel_capacity_in_litres*_fuel),_fuel_capacity_in_litres];
hint format [localize "STR_SYS_16"/* "Статус техники:\n---------------------\nТопливо: %1\nПовреждение: %2" */,_lfuel, round(_damage*1000)/1000];

_type_name = [typeOf (objectID2),0] call XfGetDisplayName;
(format [localize "STR_SYS_19", _type_name]) call XfGlobalChat; // "Ремонт, заправка: %1... ожидайте..."
_damage_ok = false;
_fuel_ok = false;
d_cancelrep = false;
_breaked_out = false;
_breaked_out2 = false;
_rep_action = player addAction[localize "STR_SYS_77","x_scripts\x_cancelrep.sqf"]; // "Отменить обслуживание"

_addscore = 0; // how many repair steps were done
for "_wc" from 1 to _coef do {
	if (!alive player || d_cancelrep) exitWith {player removeAction _rep_action;};
	localize "STR_SYS_152" call XfGlobalChat; // "В процессе..."
	player playMove "AinvPknlMstpSlayWrflDnon_medic";
	sleep 3.0;
	waitUntil {animationState player != "AinvPknlMstpSlayWrflDnon_medic"}; // this animation cycle duration is approximatelly 6 seconds
	if (d_cancelrep) exitWith {
		_breaked_out = true;
	};
	if (vehicle player != player) exitWith {
		_breaked_out2 = true;
		hint localize "STR_SYS_142"/* "Обслуживание отменено..." */;
	};
	if (!_fuel_ok) then 
	{
		_fuel = _fuel + _fuel_count;
		if (_fuel >= _refuel_limit) then {_fuel = _refuel_limit; _fuel_ok = true;};
	};
	if (!_damage_ok) then 
	{
		_damage = _damage - _rep_count;
		if (_damage <= 0.01) then {_damage = 0;_damage_ok = true;};
		_addscore = _addscore + 1;
	};
	_lfuel = format[localize "STR_SYS_15"/* "%1/%2 л." */,round(_fuel_capacity_in_litres*_fuel),_fuel_capacity_in_litres];
	hint format [localize "STR_SYS_16"/* "Статус техники:\n---------------------\nТопливо: %1\nПовреждение: %2" */,_lfuel, round(_damage*1000)/1000];
};

if (_breaked_out) exitWith {
	(localize "STR_SYS_136") call XfGlobalChat; // "Сервис отменен..."
	player removeAction _rep_action;
};
if (_breaked_out2) exitWith {};
d_eng_can_repfuel = false;
player removeAction _rep_action;
if (!alive player) exitWith {player removeAction _rep_action};
#ifdef __RANKED__

// count score by steps, not vehicle size and class
/*
_parray = d_ranked_a select 1;
_addscore = (
	if (objectID2 isKindOf "Air") then {
		(_parray select 0)
	} else {
		if (objectID2 isKindOf "Tank") then {
			(_parray select 1)
		} else {
			if (objectID2 isKindOf "Car") then {
				(_parray select 2)
			} else {
				(_parray select 3)
			}
		}
	}
);
*/
if (_addscore > 0) then {
	player addScore _addscore;
	(format [localize "STR_SYS_137", _addscore]) call XfHQChat; //"Добавлено очков за обслуживание техники: %1 ..."
};
#endif
rep_array = _rep_array;
["rep_array",_rep_array] call XSendNetStartScriptAll;
_rep_array spawn x_repall;
(format [localize "STR_SYS_138", _type_name]) call XfGlobalChat; //"Обслуживание закончено: %1 ..."
if (true) exitWith {};

