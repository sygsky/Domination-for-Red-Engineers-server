// by Xeno
//
// x_repanalyze.sqf
//
// runs only on client side
//

#include "x_setup.sqf"

private ["_aid","_caller","_coef","_damage","_damage_val","_estimated_time","_fuel","_fuel_val","_rep_count","_this","_type_name","_fuelCapacity"];

_caller = _this select 1;
_aid = _this select 2;
//_caller removeAction _aid;
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

_damage_val = (_damage / _rep_count);

_fuelCapacity = objectID2 call SYG_fuelCapacity; // litres of fuel in vehicle fuel tanks

#ifdef __LIMITED_REFUELLING__
_fuel_val = (d_refuel_volume min (_fuelCapacity * (1 - _fuel))) / 20; //how many 

#else
_fuel_val = ((1 - _fuel) / _rep_count);
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
_estimated_time = _coef * 6;

_type_name = [typeOf (objectID2),0] call XfGetDisplayName;

//+++ Sygsky: to add some more functionality for refuelling, namely to add limited refuelling
_fuelCapacity = objectID2 call SYG_fuelCapacity;
//hint localize format["x_repanalyze.sqf: _fuelCapacity = %1", _fuelCapacity];
if ( _fuelCapacity > 0 ) then
{
	_fuel = format[localize "STR_SYS_15"/* "%1/%2 л." */,round(_fuelCapacity*_fuel),_fuelCapacity];
};
//--- Sygsky

//hint format ["Статус техники: %4\n--------------------------------\nТопливо: %1\nПовреждение: %2\nВремя ремонта: %3 сек.",_fuel, _damage,_estimated_time,_type_name];
hint format [localize "STR_SYS_14",_fuel, round(_damage*1000)/1000,_estimated_time,_type_name];

if (true) exitWith {};

