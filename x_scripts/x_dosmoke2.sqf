// by Xeno; x_dosmoke2.sqf; launch smokes for vehicles
private ["_vec", "_shooter", "_damage", "_crew", "_hasshell", "_issmoking", "_smoke_array", "_pp", "_shell", "_hideobject", "_name"];
if (!isServer) exitWith {};

#include "x_setup.sqf"

#define __PRINT__
//#define __FULL_PRINT__

_vec = _this select 0;
_shooter = _this select 1;
_damage = _this select 2;

if ( _damage >= 1) exitWith {}; // End Of Life
_name = if ( isPlayer _shooter) then {name _shooter} else {typeOf _shooter};

if ( _vec == _shooter) exitWith{/* collision, not hit by enemy weapon */
    #ifdef __PRINT__
	hint localize format["x_dosmoke2.sqf: vec %1 is collided with dmg %2 by ""%3""", typeOf _vec, _damage, _name];
    #endif
};

_dead = true;
_crew = crew _vec;
while { _dead } do
{
    if (count _crew == 0) exitWith
    {
    #ifdef __FULL_PRINT__
        hint localize format["x_dosmoke2.sqf: vec %1 crew is out", typeOf _vec];
    #endif
    };
    if ((_crew call XfGetAliveUnits) == 0) exitWith
    {
    #ifdef __FULL_PRINT__
        hint localize format["x_dosmoke2.sqf: vec %1 crew is dead", typeOf _vec];
    #endif
    };
    _dead = false;
};

if ( _dead ) exitWith // find other units of the group
{
    #ifdef __FUTURE__
    {
      // TODO: find next vehicle in the group if any exists
    } forEach _crew;
    #endif
};

if (side _shooter == side _vec) exitWith
{
    #ifdef __PRINT__
    hint localize format["x_dosmoke2.sqf: vec %1 shooted by friendly ""%2""", typeOf _vec, _name];
    #endif
};

// TODO: smoke with ACE_GMV (support humwee) too

if (!("ACE_LVOSS_Magazine" in (magazines _vec))) exitWith {
#ifdef __PRINT__
	hint localize format["x_dosmoke2.sqf: vec %1 smoke shells are already shot out!!!", typeOf _vec];
#endif
};

_issmoking = _vec getVariable "D_IS_SMOKING";
if (str(_issmoking) == "<null>") then {
    _issmoking = false;
};

if (_issmoking) exitWith 
{
    #ifdef __PRINT__
	hint localize format["x_dosmoke2.sqf: vec %1 is already smoking", typeOf _vec];
    #endif
};

_vec setVariable ["D_IS_SMOKING",true]; // we are smoking!!!

_wpns = weapons _vec;
_muzzle = _wpns select (count _wpns - 1); // get last weapon (it should be a smoke launcher!)
_vec selectWeapon _muzzle;
sleep 0.121;
_vec doWatch _shooter;
sleep 3.634;
_vec fire _muzzle;
#ifdef __PRINT__
	hint localize format["x_dosmoke2.sqf: vec %1 fires smoke curtain against ""%2""", typeOf _vec, _name];
#endif

sleep 0.27;
_vec doWatch objNull; // stop watching
sleep 0.512;
_crew = crew _vec;
{
	if (alive _x) then {
		_x disableAI "TARGET";
		_x disableAI "AUTOTARGET";
	};
} forEach _crew;

sleep 1.012;

if (canMove _vec) then {
	_hideobject = _vec findCover [position _vec, position _shooter, 180];
	if (!isNull _hideobject) then {
		if (!isNull (driver _vec)) then {
			(driver _vec) doMove position _hideobject;
		};
	};
};

sleep 8;
_crew = crew _vec;
{
	if (alive _x) then {
		_x enableAI "TARGET";
		_x enableAI "AUTOTARGET";
	};
} forEach _crew;

_vec setVariable ["D_IS_SMOKING",false];

if (true) exitWith {};
