// by Xeno, x_gettargetbonus.sqf
private ["_dir","_pos","_posa","_vehicle","_town"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

//  smart select bonus according to the size of sieged town -> the largertown the bigger bonus
// 
// current_target_index -> index of completed town in target list

extra_bonus_number = -1;
#ifdef __DEFAULT__
_town = call SYG_getTargetTown; // town def array
if ( count _town > 0 ) then // town is defined
{
	if ( (_town select 2) >= big_town_radious ) then // select from best jets and helis (big bonus)
	{
		extra_bonus_number = [big_bonus_vec_index, count mt_bonus_vehicle_array] call XfGetRandomRangeInt;
	}
	else
	{
		extra_bonus_number = floor (random (big_bonus_vec_index)); // select any except Ka-50 and jets
	};
}
else
{
	hint localize "--- error in x_gettargetbonus.sqf: seized town not defined!!!";
};
#endif
if ( extra_bonus_number < 0 ) then
{
	extra_bonus_number = floor (random (count mt_bonus_vehicle_array));
};
sleep 1.012;

#ifndef __TT__
_posa = mt_bonus_positions select extra_bonus_number; _pos = _posa select 0;_dir = _posa select 1;
#endif
#ifdef __TT__
_pos = [];
_dir = 0;
// die gewinner seite, danach posi ausw�hlen
if (mt_winner == 1) then {
	_west = mt_bonus_positions select 0;
	_posa = _west select extra_bonus_number; _pos = _posa select 0;_dir = _posa select 1;
} else {
	if (mt_winner == 2) then {
		_racs = mt_bonus_positions select 1;
		_posa = _racs select extra_bonus_number; _pos = _posa select 0;_dir = _posa select 1;
	} else {
		if (mt_winner == 3) then {
			_west = mt_bonus_positions select 0;
			_posa = _west select extra_bonus_number; _pos = _posa select 0;_dir = _posa select 1;
			_vehicle2 = (mt_bonus_vehicle_array select extra_bonus_number) createVehicle (_pos);
			_vehicle2 setDir _dir;
			
			_vehicle2 execVM "x_scripts\x_wreckmarker.sqf";
			
			_racs = mt_bonus_positions select 1;
			_posa = _racs select extra_bonus_number; _pos = _posa select 0;_dir = _posa select 1;
		};
	};
};
#endif

target_clear=true; // town is liberated, no any occupied towns from now
["target_clear",target_clear, extra_bonus_number] call XSendNetStartScriptClient;

_vehicle = (mt_bonus_vehicle_array select extra_bonus_number) createVehicle (_pos);
_vehicle setDir _dir;

_vehicle execVM "x_scripts\x_wreckmarker.sqf";

if ( _vehicle isKindOf "Plane") then
{
    _pos =  [9359.855469, 10047.625000,0];
    _vehicle  = nearestObject [_pos, "MASH"];
    if ( !isNull ( _vehicle ) ) then
    {
        if (!alive _vehicle) then {deleteVehicle _vehicle; sleep 0.2; _vehicle = objNull;};
    };
    if ( isNull _vehicle) then
    {
        _mash = createVehicle ["MASH", _pos, [], 0, "NONE"];
        _mash setDir 189;
        ADD_HIT_EH(_mash)
        ADD_DAM_EH(_mash)
        hint localize format["x_scripts\x_gettargetbonus.sqf: MASH created near plane service with target bonus %1", typeOf _vehicle];
    };
};

_pos = nil;
_dir = nil;
_posa = nil;


if (true) exitWith {};
