// by Xeno, x_scripts/x_removevehi.sqf
// Creates copy of deleted vehicle on the same place. And puts vehicle to the common dead list
// Used for town patrolling vehicles only. To increase reality of the game atmosphere
#include "x_setup.sqf"

private [
         "_aunit","_eunit","_itself","_direction","_dummyvehicle","_pos","_type","_velocity","_grp", "_reveal_cnt"
#ifdef __ACE__
         ,"_ace_th","_ace_eh","_ace_hh","_ace_trh"
#endif
];

if (!isServer) exitWith{};

#define SEARCH_DIST SEARCH_DIST

_aunit = _this select 0;
_eunit = _this select 1; // killer unit
_itself = _aunit == _eunit;

_aunit reveal _eunit; // just in case
_aunit removeAllEventHandlers "killed";
_aunit removeAllEventHandlers "hit";
_aunit removeAllEventHandlers "damage";
_aunit removeAllEventHandlers "getin";
_aunit removeAllEventHandlers "getout";
_type = typeOf _aunit;
_direction = direction _aunit;
_pos = position _aunit;
_velocity = velocity _aunit;
#ifdef __ACE__
    _ace_th = _aunit getVariable "ACE_TurretHit";
    _ace_eh = _aunit getVariable "ACE_EngineHit";
    _ace_hh = _aunit getVariable "ACE_HullHit";
    _ace_trh = _aunit getVariable "ACE_TracksHit";
#endif
{
	_x removeAllEventHandlers "killed";
	_x removeAllEventHandlers "hit";
	_x removeAllEventHandlers "damage";
	_x removeAllEventHandlers "getin";
	_x removeAllEventHandlers "getout";
	deleteVehicle _x
} forEach ([_aunit] + crew _aunit);
_dummyvehicle = _type createVehicle _pos;
_dummyvehicle setDir _direction;
_dummyvehicle setPos _pos;
_dummyvehicle setVelocity _velocity;
_dummyvehicle setFuel 0.0;
_dummyvehicle setDamage 1.1;
#ifdef __ACE__
if (_dummyvehicle isKindOf "Tank" || _dummyvehicle isKindOf "Car") then {
	_dummyvehicle setVariable ["ACE_TurretHit",_ace_th];
	_dummyvehicle setVariable ["ACE_EngineHit",_ace_eh];
	_dummyvehicle setVariable ["ACE_HullHit",_ace_hh];
	_dummyvehicle setVariable ["ACE_TracksHit",_ace_trh];
	[_dummyvehicle] spawn ACE_Destruction_FX;
};
#endif
[_dummyvehicle] call XAddDead; // *************** PUT TO THE LIST OF DEAD ********************

// inform group itself about killer
if ( !alive  _eunit ) exitWith{}; // killer is dead or absent
if( _itself ) exitWith{}; // killed by itself

_vehs =  [_pos , SEARCH_DIST, ["LandVehicle", "Air", "Ship"]] call Syg_findNearestVehicles;

if (count _vehs == 0) exitWith {};
_watch_cnt  = 0;
_reveal_cnt = 0;
{
    if ( (alive _x) && ((side _x) == d_side_enemy) )then // inform only enemy vehicles about
    {
        _x reveal _eunit;
        sleep 0.1;
        (commander _x) doWatch _eunit;
        if ( ( (commander _x) knowsAbout _eunit) < 1.5 )
            then { _watch_cnt = _watch_cnt + 1; }
            else { _reveal_cnt = _reveal_cnt + 1 };
    };
} forEach _vehs;

sleep 3.5;

_watch_cnt2 = 0;
_reveal_cnt2 = 0;
{
    if ( ( alive _x ) && ( ( side _x ) == d_side_enemy ) ) then // inform only alive enemy vehicles about
    {
        _x doWatch objNull;
        if ( ( ( commander _x ) knowsAbout _eunit ) < 1.5 )
        then {
            _watch_cnt2 = _watch_cnt2 + 1;
        }
        else { _reveal_cnt2 = _reveal_cnt2 + 1 };
    };
} forEach _vehs;
hint localize format["+++ x_removevehi.sqf (%1): killer %2, before/after watched %3/%4,  revealed %5/%6 by enemy vehicles",
    _type, typeOf _eunit, _watch_cnt, _watch_cnt2, _reveal_cnt, _reveal_cnt2 ];

_vehs = nil;

if (true) exitWith {};