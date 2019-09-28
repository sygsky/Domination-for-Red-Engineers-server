// by Xeno, x_scripts/x_removevehi.sqf
// Creates copy of deleted vehicle on the same place. And puts vehicle to the common dead list
// Used for town patrolling vehicles only. To increase reality of the game atmosphere
#include "x_setup.sqf"

private [
         "_aunit","_direction","_dummyvehicle","_position","_type","_velocity","_grp", "_reveal_cnt"
#ifdef __ACE__
         ,"_ace_th","_ace_eh","_ace_hh","_ace_trh"
#endif
];

if (!isServer) exitWith{};

_aunit = _this select 0;
_aunit removeAllEventHandlers "killed";
_aunit removeAllEventHandlers "hit";
_aunit removeAllEventHandlers "damage";
_aunit removeAllEventHandlers "getin";
_aunit removeAllEventHandlers "getout";
_type = typeOf _aunit;
_direction = direction _aunit;
_position = position _aunit;
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
_dummyvehicle = _type createVehicle _position;
_dummyvehicle setDir _direction;
_dummyvehicle setPos _position;
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

// TODO: inform group itself about killer
_eunit = _this select 1; // killer unit
if ( !alive  _eunit ) exitWith{};
if ( _aunit == _eunit) exitWith {};
_aunit reveal _eunit;
_vehs =  [_position , 4000, ["LandVehicle", "Air", "Ship"]] call Syg_findNearestVehicles;

if (count _vehs == 0) exitWith {};
_watch_arr  = [];
_reveal_cnt = 0;
{
    if ((side _x) == d_side_enemy) then // inform only enemy vehicles about
    {
        _x reveal _eunit;
        sleep 0.3;
        if (((commander _x) knowsAbout _eunit) < 1.5 ) then
        {
            (commander _x) doWatch _eunit;
            _watch_arr = _watch_arr + [commander _x];
        }
        else { _reveal_cnt = _reveal_cnt + 1 };
    };
} forEach _vehs;
hint localize format["+++ x_removevehi.sqf: airkiller %1, watched %2 and revealed %3 enemy vehicles", count _watch_arr, typeOf _eunit, _reveal_cnt];
sleep 4.5;
{
    _x doWatch objNull;
} forEach _watch_arr;
_watch_arr = nil;
_vehs = nil;

if (true) exitWith {};