// by Sygsky; script\eventOnDamage.sqf; launch smokes for vehicles
/*

Triggered when the unit is damaged. In ArmA works with all vehicles not only men like in OFP.
(Does not fire if damage is set via setDammage.) (If simultaneous damage occured (e.g. via grenade) EH might be triggered several times.)

Global.

Passed array: [unit, selectionName, damage]

unit: Object - Object the event handler is assigned to
selectionName: String - Name of the selection where the unit was damaged
damage: Number - Resulting level of damage
*/

if (!isServer) exitWith {};

#include "x_setup.sqf"

#define __PRINT__
//#define __FULL_PRINT__

#ifdef __PRINT__
hint localize format["+++ eventOnDamage.sqf: _this = %1, crew %4", _this, count crew (_this select 0)];
#endif

private ["_vec", "_shooter", "_damage", "_crew", "_hasshell", "_issmoking", "_smoke_array", "_pp", "_shell", "_hideobject", "_name"];

_vec = _this select 0;

_issmoking = _vec getVariable "D_IS_SMOKING";
if (str(_issmoking) == "<null>") then {
    _issmoking = false;
};

if (_issmoking) exitWith
{
    #ifdef __PRINT__
	hint localize format["+++ eventOnDamage.sqf: attacked vec %1 is already smoking", typeOf _vec];
    #endif
};

_damage = _this select 2;

if ( _damage >= 1) exitWith { hint localize format["+++ eventOnDamage.sqf: attacked vec %1 is killed", typeOf _vec]; }; // End Of Life

// TODO: check attacker be in air vehicle. If so, not smoke against air enemy

// TODO: if attacker is a man, and veh is damaged, then load with HE and then shoot it to bastard.
// TODO: If attacker is alive after HE shoot, shoot it again and change ammo to sabot again

_dead = true;
_crew = crew _vec;
while { _dead } do
{
    if (count _crew == 0) exitWith
    {
    #ifdef __FULL_PRINT__
        hint localize format["+++ eventOnDamage.sqf: vec %1 crew is out", typeOf _vec];
    #endif
    };
    if ((_crew call XfGetAliveUnits) == 0) exitWith
    {
    #ifdef __FULL_PRINT__
        hint localize format["+++ eventOnDamage.sqf: vec %1 crew is dead", typeOf _vec];
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

// TODO: smoke with ACE_GMV (support humwee) too. But how?

if (!("ACE_LVOSS_Magazine" in (magazines _vec))) exitWith {
// TODO: try to find ammo and reload smoke grenades from it
#ifdef __PRINT__
	hint localize format["+++ eventOnDamage.sqf: veh %1 has no more smoke shells!!!", typeOf _vec];
#endif
};

_vec setVariable ["D_IS_SMOKING",true]; // we are smoking!!!

//
//smoke procedure
//
_wpns = weapons _vec;
_muzzle = _wpns select (count _wpns - 1); // get last weapon (it should be a smoke launcher!)
_vec selectWeapon _muzzle;
_shooter = _veh findNearestEnemy _veh;
if (alive _shooter) then {
#ifdef __PRINT__
	hint localize format["+++ eventOnDamage.sqf: vec ""%1"" fires smoke curtain to nearest enemy %2", typeOf _vec, typeOf _shooter];
#endif
    _vec doWatch _shooter; sleep 3.634;
} else {
#ifdef __PRINT__
	hint localize format["+++ eventOnDamage.sqf: vec ""%1"" fires smoke curtain to random direction", typeOf _vec];
#endif
    sleep 1
};
_vec fire _muzzle;
// TODO: If detected enemy is a tank and damaged vehicle is a tank too, lets shoot to the attacker smoke projectile first and sabot second
sleep 0.27;
if (alive _shooter) then { _vec doWatch objNull}; // stop watching
sleep 0.512;

_vec setVariable ["D_IS_SMOKING",false]; // drop smoking state

if (true) exitWith {};
