// by Xeno; x_dosmoke2.sqf; launch smokes for vehicles
/*

Triggered when the unit is hit/damaged.

Is not always triggered when unit is killed by a hit.
Most of the time only the killed event handler is triggered when a unit dies from a hit.
The hit EH will not necessarily fire if only minor damage occurred (e.g. firing a bullet at a tank), even though the damage increased.

Local.

Passed array: [unit, causedBy, damage]

    unit: Object - Object the event handler is assigned to
causedBy: Object - Object that caused the damage. Contains the unit itself in case of collisions.
  damage: Number - Level of damage caused by the hit
*/

private ["_vec", "_shooter", "_damage", "_crew", "_hasshell", "_issmoking", "_smoke_array", "_pp", "_shell", "_hideobject", "_name"];
if (!isServer) exitWith {};

#include "x_setup.sqf"

#define __PRINT__
//#define __FULL_PRINT__

#ifdef __PRINT__
hint localize format["x_dosmoke2.sqf: _this = [%1,%2,%3], crew cnt %4", typeOf (_this select 0), _this select 1, _this select 2, count crew (_this select 0)];
#endif

_vec = _this select 0;

_issmoking = _vec getVariable "D_IS_SMOKING";
if (str(_issmoking) == "<null>") then {
    _issmoking = false;
};

if (_issmoking) exitWith
{
    #ifdef __PRINT__
	hint localize format["x_dosmoke2.sqf: attacked vec %1 is already in smoking", typeOf _vec];
    #endif
};

_shooter = _this select 1;
if (isNull _shooter) exitWith
{
#ifdef __PRINT__
	hint localize "x_dosmoke2.sqf: shooter is null, exit";
#endif
};
_damage = _this select 2;

_name = if ( isPlayer _shooter) then {name _shooter} else {typeOf _shooter};
if ( _damage >= 1) exitWith { hint localize format["x_dosmoke2.sqf: attacked vec %1 is killed by %2", typeOf _vec, _name]; }; // End Of Life
if (!local _vec) exitWith {  hint localize format["x_dosmoke2.sqf: attacked vec %1 is commanded by player %2", typeOf _vec, _name]; }; // It is player commanded vehicle, don't handle it

if ( _vec == _shooter) exitWith{/* collision, not hit by enemy weapon */
    #ifdef __PRINT__
	hint localize format["x_dosmoke2.sqf: vec %1 is collided with dmg %2 by ""%3"", not smoking", typeOf _vec, _damage, _name];
    #endif
};

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
    hint localize format["x_dosmoke2.sqf: attacked vec %1 is under friendly fire from ""%2""", typeOf _vec, _name];
    #endif
};

// TODO: smoke with ACE_GMV (support humwee) too. But how?

if (!("ACE_LVOSS_Magazine" in (magazines _vec))) exitWith {
// TODO: try to find ammo and reload smoke grenades from it
#ifdef __PRINT__
	hint localize format["x_dosmoke2.sqf: veh %1 has no more smoke shells!!!", typeOf _vec];
#endif
};

_vec setVariable ["D_IS_SMOKING",true]; // we are smoking!!!

//
//smoke procedure
//
_wpns = weapons _vec;
_muzzle = _wpns select (count _wpns - 1); // get last weapon (it should be a smoke launcher!)
_vec selectWeapon _muzzle;
sleep 0.121;
_vec doWatch _shooter;
sleep 3.634;
_vec fire _muzzle;
#ifdef __PRINT__
	hint localize format["x_dosmoke2.sqf: vec ""%1"" fires smoke curtain against ""%2"" (%3 m)", typeOf _vec, _name, round( _shooter distance _vec )];
#endif

// TODO: If attacker is a tank and damaged is a tank shoot to the attacker smoke first and sabot second

sleep 0.27;
_vec doWatch objNull; // stop watching
sleep 0.512;

if (canMove _vec) then {
	_hideobject = _vec findCover [position _vec, position _shooter, 180];
	if (!isNull _hideobject) then {
		if (!isNull (driver _vec)) then {

            {
                if (alive _x) then {
                    _x disableAI "TARGET";
                    _x disableAI "AUTOTARGET";
                };
            } forEach crew _vec;

            sleep 0.012;

			(driver _vec) doMove position _hideobject;

            sleep 8;
            {
                if (alive _x) then {
                    _x enableAI "TARGET";
                    _x enableAI "AUTOTARGET";
                };
            } forEach crew _vec;

		};
	};
};

_vec setVariable ["D_IS_SMOKING",false]; // drop smoking state

if (true) exitWith {};
