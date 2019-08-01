// x_scripts/x_illum.sqf, by Xeno
private ["_tgt_center","_radius","_center_x","_center_y", "_flare","_flareCnt","_current_counter"];

if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __FULL_LIGHT__
#define __ILLUM_BY_ALIVE__ // to fire flares above alive man in predefined radious

#ifdef __FULL_LIGHT__
#define MIN_FLARE_HEIGHT 30
#endif

//#define __DEBUG__

#define FLASH_RANDOM_OFFSET 20

_tgt_center = _this select 0;
_radius     = _this select 1;
_center_x   = _tgt_center select 0;
_center_y = _tgt_center select 1;
_flareCnt = 0;
_current_counter = current_counter; // current main target index to illuminate

hint localize format["%1 execVM ""x_scripts/x_illum.sqf"", d_run_illum = %2",_this, d_run_illum];

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
hint localize format["+++ x_illum: start in %1+++", _this select 2];

while {d_run_illum && (_current_counter == current_counter) } do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	};
	//__DEBUG_NET("x_illum.sqf",(call XPlayersNumber))
	_flare = "";
	/*  SYG_shortNightEnd    =  4.60;
        SYG_morningEnd       =  7.00;
        SYG_eveningStart     = 18.30;
        SYG_shortNightStart  = 19.75;	*/
	if ((daytime > SYG_shortNightStart) || (daytime < SYG_shortNightEnd)) then
	{

#ifdef __ILLUM_BY_ALIVE__
    	_arrIsOld = true;
        if ( count _manArr < 10 ) then
        {
            _manArr = _tgt_center nearObjects [_manType, _radius]; // array of men found in the town boundaries
            _arrIsOld = false; // array is refreshed
            if ( count _manArr == 0 ) exitWith
            {
                hint localize format["--- x_illum: %1, loop for current town sleeps for 1 min as no %2 found in town radious %3 m.!",call SYG_nowTimeToStr, _manType, _radius];
                sleep 60; // wait for the new man entering the town red zone
                //d_run_illum = false;
            };
            hint localize format["+++ x_illum: %1, new town men list filled with %2/%3 %4", call SYG_nowTimeToStr, {alive _x} count _manArr, count _manArr, _manType];
        };
        //if (!d_run_illum) exitWith { false };
        if ( count _manArr == 0 ) exitWith { sleep 10; };

        for "_i" from 0 to (count _manArr) - 1 do
        {
            _x = _manArr select _i;
            if ( !alive _x ) then { _manArr set [_i, "RM_ME"];}
            else
            {
                if (_arrIsOld ) then // check a man to be in town radious as he can go out of boundaries
                {
                    if ( ( _x distance _tgt_center ) > _radius ) then { _manArr set [_i, "RM_ME"]; };
                }
            };
        };
        _manArr = _manArr - ["RM_ME"];
        if ( count _manArr == 0 ) exitWith
        {
            hint localize format["--- x_illum: %1 loop skipped as no alive %2 counted in town men list!", call SYG_nowTimeToStr, _manType];
            if (!_arrIsOld) then // no men in town at all as new list is empty
            {
                sleep (random 30);
            };
        };
        _man = _manArr call XfRandomArrayVal;

		_angle = floor (random 360);
		_randrad = FLASH_RANDOM_OFFSET call XfRndRadious; // correct randomly distributed radious
		_x1 = (getPos _man select 0) - (_randrad * sin _angle);
		_y1 = (getPos _man select 1) - (_randrad * cos _angle);

        if ( _man isKindOf "OfficerW" || _man isKindOf "SquadLeaderW" || _man isKindOf "TeamLeaderW" ) then
        {
             _flare = "F_40mm_Green"; // Officer's flares are green
        };
#else
		_angle = floor (random 360);
		_randrad = _radius call XfRndRadious; // correct randomly distributed radious
		_x1 = _center_x - (_randrad * sin _angle);
		_y1 = _center_y - (_randrad * cos _angle);
#endif
        if (_flare == "") then
        {
    		_flare = if (mt_radio_down ) then {"F_40mm_Red"} else { _flares select (( floor random 10 ) min 2); }; // while color is mostly flared
        };
		_flare =  _flare createVehicle [_x1, _y1, 250];
		_flareCnt = _flareCnt + 1;
#ifdef __DEBUG__
        hint localize format["+++ x_illum: %1 flare created at x %2, y %3 +++", call SYG_nowTimeToStr, _x1, _y1];
#endif
#ifdef __FULL_LIGHT__
        while {true} do
        {
            if ( isNull _flare) exitWith {};
            if ( (getPos _flare) select 2 < MIN_FLARE_HEIGHT) exitWith{};
            sleep 0.523;
        };
#else
    	sleep (25 + random 30);
#endif
	    if (!isNull _flare) then {deleteVehicle _flare};
	}
	else {sleep 300}; // check night come every 300 seconds to not skip it during main target change
};

#ifdef __ILLUM_BY_ALIVE__
_manArr = nil;
#endif

hint localize format["+++ x_illum: %1, exit %2, %3 flares created +++", call SYG_nowTimeToStr, _this select 2, _flareCnt];

if (true) exitWith {};
