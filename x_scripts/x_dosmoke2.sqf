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

hint localize format["+++ x_dosmoke2.sqf: _this = %1", _this];

private ["_veh", "_shooter", "_damage", "_crew", "_issmoking", "_hideobject", "_name", "_dead", "_wpns", "_muzzle", "_x"];
if (!isServer) exitWith {};

#include "x_setup.sqf"

#define __PRINT__
//#define __FULL_PRINT__

_veh = _this select 0;

_issmoking = _veh getVariable "D_IS_SMOKING";
if (isNil "_issmoking") then { _issmoking = false };

if (_issmoking) exitWith {
    #ifdef __PRINT__
	hint localize format["+++ x_dosmoke2.sqf: attacked vec %1 is already smoking", typeOf _veh];
    #endif
};

_shooter = _this select 1;
if (isNull _shooter) exitWith {
#ifdef __PRINT__
	hint localize "+++ x_dosmoke2.sqf: shooter is null, exit";
#endif
};
_damage = _this select 2;

//
#ifdef __PRINT__
_name = _shooter call SYG_getKillerInfo;
hint localize format["+++ x_dosmoke2.sqf: _this = [%1,%2,%3], crew cnt %4", typeOf _veh, _name, _damage, count crew _veh];
#endif

//_name = if ( isPlayer _shooter) then {name _shooter} else {typeOf _shooter};
if ( _damage >= 1) exitWith { hint localize format["+++ x_dosmoke2.sqf: attacked vec %1 is killed by %2", typeOf _veh, _name]; }; // End Of Life
if ((!local _veh)) exitWith { hint localize format["+++ x_dosmoke2.sqf: attacked vec %1 is not local to the server (captured = %2)", _veh getVariable "CAPTURED_ITEM"]; }; // It is player commanded vehicle, don't handle it

if ( _veh == _shooter) exitWith{/* collision, not hit by enemy weapon */
    #ifdef __PRINT__
	hint localize format["+++ x_dosmoke2.sqf: vec %1 is collided with dmg %2 by ""%3"", not smoking", typeOf _veh, _damage, _name];
    #endif
};

// TODO: check attacker be in air vehicle. If so, not smoke against air enemy

// TODO: if attacker is a man, and veh is damaged, then load with HE and then shoot it to bastard.
// TODO: If attacker is alive after HE shoot, shoot it again and change ammo to sabot again

_dead = true;
_crew = crew _veh;
while { _dead } do {
    if (count _crew == 0) exitWith {
    #ifdef __FULL_PRINT__
        hint localize format["+++ x_dosmoke2.sqf: vec %1 crew is out", typeOf _veh];
    #endif
    };
    if ((_crew call XfGetAliveUnits) == 0) exitWith {
    #ifdef __FULL_PRINT__
        hint localize format["+++ x_dosmoke2.sqf: vec %1 crew is dead", typeOf _veh];
    #endif
    };
    _dead = false;
};

if (side _shooter == side _veh) exitWith {
    #ifdef __PRINT__
    hint localize format["+++ x_dosmoke2.sqf: attacked vec %1 is under friendly fire from ""%2""", typeOf _veh, _name];
    #endif
};

// TODO: smoke with ACE_GMV (support humwee) too. But how?

if (!("ACE_LVOSS_Magazine" in (magazines _veh))) exitWith {
    _veh setVariable ["D_IS_SMOKING",nil]; // remove just in case
    // TODO: try to find ammo and reload smoke grenades from it
#ifdef __PRINT__
	hint localize format["+++ x_dosmoke2.sqf: veh %1 has no more smoke shells against ""%2""!!!", typeOf _veh, _name];
#endif
};

_veh setVariable ["D_IS_SMOKING",true]; // we are smoking!!!

//
//smoke procedure
//
_wpns = weapons _veh;
_muzzle = _wpns select (count _wpns - 1); // get last weapon (it should be a smoke launcher!)
_veh selectWeapon _muzzle;
sleep 0.121;
_veh doWatch _shooter;
sleep 3.634;
_veh fire _muzzle;
#ifdef __PRINT__
	hint localize format["+++ x_dosmoke2.sqf: vec ""%1"" fires smoke curtain against ""%2"" (%3 m)", typeOf _veh, _name, round( _shooter distance _veh )];
#endif

// TODO: If attacker is a tank and damaged is a tank shoot to the attacker smoke first and sabot second

sleep 0.27;
_veh doWatch objNull; // stop watching
sleep 0.512;
if (alive (driver _veh ) && (canMove _veh) ) then {
	_hideobject = _veh findCover [position _veh, position _shooter, 180];
	if (!isNull _hideobject) then {
		{
			if (alive _x) then {
				_x disableAI "TARGET";
				_x disableAI "AUTOTARGET";
			};
		} forEach crew _veh;

		sleep 0.012;
		(driver _veh) doMove position _hideobject;
		sleep 8;

		{
			if (alive _x) then {
				_x enableAI "TARGET";
				_x enableAI "AUTOTARGET";
			};
		} forEach crew _veh;
	}  else {hint localize format["+++ x_dosmoke2.sqf: %1 cover not found", typeOf _veh]};
} else { hint localize format["+++ x_dosmoke2.sqf: %1 hasnt driver or cant move, skip hide procedure", typeOf _veh] };

_veh setVariable ["D_IS_SMOKING",false]; // drop smoking state
_veh selectWeapon (_wpns select 0); // return to the original weapon
if (true) exitWith {};
