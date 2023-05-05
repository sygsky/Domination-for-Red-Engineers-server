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

private ["_veh", "_shooter", "_damage", "_crew", "_hasshell", "_issmoking", "_x", "_dead", "_wpns", "_muzzle", "_name", "_gunner", "_exit"];

_veh = _this select 0;
_exit = false;
if (!isNil "last_killed_veh") then {
    _exit = _veh == last_killed_veh;
};
if (_exit) exitWith {}; // skip any processing for the dead vehicle

#ifdef __PRINT__
hint localize format["+++ eventOnDamage.sqf: _this = %1, crew %2, veh %3", _this, {alive _x} count crew _veh, typeOf _veh];
#endif
if ( (_this select 2) >= 1) then {
    last_killed_veh = _veh;
	_veh removeAllEventHandlers "dammaged";
	hint localize format["+++ eventOnDamage.sqf: damage detected %1 >= 1, stop ""Damage"" event processing", (_this select 2)];
};

if (side _veh == d_side_player) exitWith {format["+++ eventOnDamage.sqf: vehicle side is %1, exit", d_side_player]};

_damage = _this select 2;
if ( !(alive _veh)) exitWith { hint localize format["+++ eventOnDamage.sqf: attacked vec %1 is killed", typeOf _veh]; }; // End Of Life

_issmoking = _veh getVariable "D_IS_SMOKING";
if (isNil "_issmoking") then { _issmoking = false; };

if (_issmoking) exitWith {
    #ifdef __PRINT__
	hint localize format["+++ eventOnDamage.sqf: attacked vec %1 is already smoking", typeOf _veh];
    #endif
};

// TODO: check attacker be an air vehicle. If so, not smoke against air enemy

// TODO: if attacker is a man, and veh is damaged, then load with HE and then shoot it to the bastard.
// TODO: If attacker is alive after HE shoot, shoot it again and change ammo to sabot again

_dead = true;
_crew = crew _veh;
while { _dead } do {
    if (count _crew == 0) exitWith {
    #ifdef __PRINT__
        hint localize format["+++ eventOnDamage.sqf: vec %1 crew is out", typeOf _veh];
    #endif
    };
    if ((_crew call XfGetAliveUnits) == 0) exitWith {
    #ifdef __PRINT__
        hint localize format["+++ eventOnDamage.sqf: vec %1 crew is dead", typeOf _veh];
    #endif
    };
    _dead = false;
};

if ( _dead ) exitWith { }; // Exit on empty stae

// TODO: smoke with ACE_GMV (support humwee) too. But how?

if (!("ACE_LVOSS_Magazine" in (magazines _veh))) exitWith {
// TODO: try to find ammo and reload smoke grenades from it
	_veh setVariable ["D_IS_SMOKING",nil]; // remove just in case
	#ifdef __PRINT__
	hint localize format["+++ eventOnDamage.sqf: veh %1 has no more smoke shells!!!", typeOf _veh];
	#endif
};

_veh setVariable ["D_IS_SMOKING",true]; // we are smoking!!!

//
//smoke procedure
//
_wpns = weapons _veh;
_muzzle = _wpns select (count _wpns - 1); // get last weapon (it should be a smoke launcher!)
_veh selectWeapon _muzzle;
_shooter = _veh findNearestEnemy _veh;
if (alive _shooter) then {
	_gunner = gunner _shooter;
	_name = if (isPlayer _gunner) then {name _gunner} else { typeOf _shooter };
#ifdef __PRINT__
	hint localize format["+++ eventOnDamage.sqf: veh ""%1"" fires smoke curtain to the nearest enemy %2 (%3 m)", typeOf _veh, _name, round(_gunner distance _veh)];
#endif
    _veh glanceAt _shooter; sleep 3.634;
} else {
#ifdef __PRINT__
	hint localize format["+++ eventOnDamage.sqf: veh ""%1"" fires smoke curtain to a random direction as no shooter is found", typeOf _veh];
#endif
    sleep 1
};

_veh fire _muzzle;
// TODO: If detected enemy is a tank and damaged vehicle is a tank too, lets shoot to the attacker smoke projectile first and sabot second
sleep 0.27;

// stop watching
if (alive _shooter) then {
	_veh doWatch objNull;
	_muzzle = _wpns select 0;
	_veh selectWeapon _muzzle;
};
sleep 0.512;

_veh setVariable ["D_IS_SMOKING",nil]; // drop smoking state

if (true) exitWith {};
