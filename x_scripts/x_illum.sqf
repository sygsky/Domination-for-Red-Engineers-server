// x_scripts/x_illum.sqf, by Xeno
private ["_trg_center","_radius","_center_x","_center_y", "_flare"];

if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __FULL_LIGHT__
#define __ILLUM_BY_ALIVE__ // to fire flares above alive man in predefined radious

#ifdef __FULL_LIGHT__
#define MIN_FLARE_HEIGHT 30
#endif

//#define __DEBUG__

_trg_center = _this select 0;
_radius     = _this select 1;
_center_x   = _trg_center select 0;_center_y = _trg_center select 1;

#ifdef __DEBUG__
hint localize format["%1 execVM ""x_scripts/x_illum.sqf"", d_run_illum = %2",_this, d_run_illum];
#endif

while {!mt_spotted} do {sleep 7.75};

_flares = [ "F_40mm_Yellow", "F_40mm_Red", "F_40mm_White" ]; // "F_40mm_Green" - for officers only
#ifdef __ILLUM_BY_ALIVE__
_manType = switch playerSide do {
    case east:
    {
        "SoldierWB"
    };
    default{};
    case resistance;
    case west:
    {
        "SoldierEB"
    };
};
#ifdef __DEBUG__
hint localize format["+++ x_illum: manType %1", _manType];
#endif

_manArr = [];

#endif

while {d_run_illum} do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	};
#ifdef __DEBUG__
    hint localize "+++ x_illum: start procedure +++";
#endif
	//__DEBUG_NET("x_illum.sqf",(call XPlayersNumber))
	_flare = objNull;
	/*
	    SYG_shortNightEnd    =  4.60;
        SYG_morningEnd       =  7.00;
        SYG_eveningStart     = 18.30;
        SYG_shortNightStart  = 19.75;

	*/
	_arrIsOld = true;
	if ((daytime > SYG_shortNightStart) || (daytime < SYG_shortNightEnd)) then
	{

#ifdef __ILLUM_BY_ALIVE__
        if ( count _manArr < 10 ) then
        {
            _manArr = _trg_center nearObjects [_manType, _radius];
            _arrIsOld = false;
            if ( count _manArr == 0 ) exitWith
            {
                hint localize format["--- Illumination loop for current town exited as no one %1 found in town radious %2 m.!", _manType, _radius];
                d_run_illum = false;
            };
        };
    #ifdef __DEBUG__
        hint localize format["+++ x_illum: found %1 of %2 +++", count _manArr, _manType];
    #endif
        for "_i" from 0 to (count _manArr) - 1 do
        {
            _x = _manArr select _i;
            if ( !alive _x ) then { _manArr set [i, "RM_ME"];}
            else
            {
                if (_arrIsOld ) then
                {
                    if ( (_x distance _trg_center) > _radius) then { _manArr set [i, "RM_ME"]; };
                }
            };
        };
        _manArr = _manArr - ["RM_ME"];
        if ( count _manArr == 0 ) exitWith
        {
            hint localize format["--- Illumination loop for current town exited as all %1 are dead in town radious %2 m.!", _manType, _radius];
            d_run_illum = false;
        };
        _man = _manArr call XfRandomArrayVal;
        _x1 = (getPos _man select 0) + (-5 + (random 10));
        _y1 = (getPos _man select 1) + (-5 + (random 10));
        if ( _man isKindOf "OfficerW" || _man isKindOf "SquadLeaderW" || _man isKindOf "TeamLeaderW" ) then
        {
             _flare = "F_40mm_Green"; // Officer's flares are always green
        };
#else
		_angle = floor (random 360);
		_randrad = _radius call XfRndRadious; // correct randomly distributed radious
		_x1 = _center_x - (_randrad * sin _angle);
		_y1 = _center_y - (_randrad * cos _angle);
#endif
        if (isNull _flare) then
        {
    		_flare = if (mt_radio_down ) then {"F_40mm_Red"} else { _flares select (( floor random 10 ) min 2); }; // while color is mostly flared
        };
		_flare =  _flare createVehicle [_x1, _y1, 250];
#ifdef __DEBUG__
        hint localize format["+++ x_illum: flare created at x %1, y %2 +++", _x1, _y1];
#endif
#ifdef __FULL_LIGHT__
        while {true} do
        {
            if ( isNull _flare) exitWith {};
            if ( (getPos _flare) select 2 < MIN_FLARE_HEIGHT) exitWith{};
            sleep 1.123;
        };
#else
    	sleep (25 + random 30);
#endif
	    if (!isNull _flare) then {deleteVehicle _flare};
	}
	else {sleep 120}; // check night come every 2 minutes
};

#ifdef __ILLUM_BY_ALIVE__
_manArr = nil;
#endif

#ifdef __DEBUG__
hint localize "+++ x_illum: exit +++";
#endif

if (true) exitWith {};
