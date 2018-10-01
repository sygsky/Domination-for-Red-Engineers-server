// by Xeno, x_gettargetbonus.sqf, creates bonus vehicle for main targed completion
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

private ["_dir","_pos","_posa","_vehicle","_town"];

//  smart select bonus according to the size of sieged town -> the larger town the bigger bonus
// 
// current_target_index -> index of completed town in target list

extra_bonus_number = -1;
#ifdef __DEFAULT__

_town = call SYG_getTargetTown; // town def array
if ( count _town > 0 ) then // town is defined
{

    hint localize format["+++ find bonus vehicle for town %1 (big_town_radious = %2)", _town, big_town_radious];
    // new feature to select main target bonus indexes
	if ( (_town select 2) >= big_town_radious ) then // select from best vehicles (big bonus)
	{
	    extra_bonus_number = mt_big_bonus_params call SYG_findTargetBonusIndex;
	}
	else
	{
	    extra_bonus_number = mt_small_bonus_params call SYG_findTargetBonusIndex;
	};

//---------------------------------------------------------------

}
else
{
	hint localize "--- error in x_gettargetbonus.sqf: a newly captured city not defined!!!";
};

#endif

if ( extra_bonus_number < 0 ) then
{
	hint localize "--- extra_bonus_number find error: get vehicle from small array only";
	extra_bonus_number = mt_bonus_vehicle_array call XfRandomFloorArray; // случайное число в диапазоне длины массива
};
sleep 1.012;

#ifndef __TT__
_posa = mt_bonus_positions select (extra_bonus_number mod (count mt_bonus_positions)); _pos = _posa select 0;_dir = _posa select 1;
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

target_clear = true; // town is liberated, no any occupied towns from now
["target_clear",target_clear, extra_bonus_number] call XSendNetStartScriptClient;

_vehicle = (mt_bonus_vehicle_array select extra_bonus_number) createVehicle (_pos);

hint localize format["+++ x_scripts\x_gettargetbonus.sqf: target bonus vehicle created ""%1""", typeOf _vehicle];

_vehicle setDir _dir;

#ifdef __REARM_SU34__
_vehicle call SYG_rearmVehicleA; // rearm if bonus vehicle is marked to rearm
#endif


#ifdef __NO_ETERNAL_BONUS__

[_vehicle ]call SYG_addEventsAndDispose; // add events to this vehicle, no points, no smoke

#else

// set marker procedure for the newly created vehicle
_vehicle execVM "x_scripts\x_wreckmarker.sqf";

#endif

//
// RESTORE DESTROYED BUILDINGS
//
#ifdef __DEFAULT__
{
    _mash = nearestObject [argp( _x, 0), "MASH"];
    _rebuild_mash = false;
    // try to repair object if it is damaged
    if ( !isNull ( _mash ) ) then
    {
        if (!alive _mash) then { _mash removeAllEventHandlers "hit";  _mash removeAllEventHandlers "damage"; deleteVehicle _mash;sleep 0.2; _mash = objNull; _rebuild_mash = true;};
    };
    // (re)build mash if not available
    if ( (_vehicle isKindOf "Plane") || _rebuild_mash ) then
    {
        if ( isNull _mash) then
        {
            _mash = createVehicle ["MASH", argp(_x,0), [], 0, "NONE"];
            sleep 1;
            _mash setDir argp(_x,1);
            ADD_HIT_EH(_mash)
            ADD_DAM_EH(_mash)
            hint localize format["x_scripts\x_gettargetbonus.sqf: MASH created near plane service at %2 with target bonus %1", typeOf _vehicle, argp(_x,0) call SYG_nearestLocationName];
        };
    };

} forEach [ [ [ 9359.855469, 10047.625000, 0 ], 190 ], [ [18035,18908,0 ], 260 ] ]; // two mash sites
#endif

_pos = nil;
_dir = nil;
_posa = nil;


if (true) exitWith {};
