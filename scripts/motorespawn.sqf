// by Sygsky
// script to restore vehicles from designated list
// independently of their type and position
// restore delay may be user-defined too.
// First position in the array are stored and looked as main position to return vehicles after position change
// Example:
// [moto1, ... ,motoN] execVM "motorespawn.sqf";
//
// Where motoN - reference to device with position to keep it here
//
#include "x_macros.sqf"

private ["_motoarr", "_mainCnt", "_moto", "_timeout", "_pos", "_pos1", "_type", "_nobj", "_driver_near"];

if (!isServer) exitWith{};

// comment next line to not create debug messages
#define __DEBUG__

// 5 mins timeout will be good
#define RESTORE_DELAY_NORMAL 420
#define RESTORE_DELAY_SHORT 30
#define CYCLE_DELAY 15
#define TIMEOUT_ZERO 0
#define MOTO_ON_PLACE_DIST 3.5
#define DRIVER_NEAR_DIST 10
#define FUEL_MIN_VOLUME 0.2
// offsets for vehicle status array items
#define MOTO_ITSELF 0
#define MOTO_ORIG_POS 1
#define MOTO_ORIG_DIR 2
#define MOTO_TIMEOUT 3

#define inc(val) (val=val+1)
#define TIMEOUT(addval) (time+(addval))

_motoarr = []; // create array of vehicles to return to original position after some delay
sleep 2;

// read all vehicles and store their inintial positon and angles
{
//	_motoarr = _motoarr + [[_x, getPos _x, direction _x, TIMEOUT_ZERO]];
	_pos = getPos _x;
	_pos set[2,0]; // zero Z coordinate
	_x setPos _pos;
	sleep 0.2;
	_pos1 = getPos _x;
	_pos1 set [2,0];
	sleep 0.2;
	_motoarr = _motoarr + [[_x, _pos1, getDir _x, TIMEOUT_ZERO]];
#ifdef __DEBUG__
    hint localize format["%1: initPos %2, setPos %3", _x, _pos, _pos1];
#endif

} forEach _this; // list all motocyrcles/automobiles

sleep CYCLE_DELAY;
#ifdef __DEBUG__
	hint localize format[
	    "motorespawn.sqf:  RESTORE_DELAY_NORMAL %1, RESTORE_DELAY_SHORT %2, CYCLE_DELAY %3, MOTO_ON_PLACE_DIST %4, DRIVER_NEAR_DIST %5, FUEL_MIN_VOLUME %6",
	                       RESTORE_DELAY_NORMAL,    RESTORE_DELAY_SHORT,    CYCLE_DELAY ,   MOTO_ON_PLACE_DIST ,   DRIVER_NEAR_DIST ,   FUEL_MIN_VOLUME
	                    ];
	{
	    hint localize format[
	    "motorespawn.sqf:  %1", _x];
	} forEach _motoarr;
#endif

//_mainCnt = 1;
while {true} do {

	if (X_MP && ((call XPlayersNumber) == 0) ) then
	{
		waitUntil {sleep (25.012 + random 1);(call XPlayersNumber) > 0};
	};

	sleep CYCLE_DELAY; // main cycle time-out

	//  forEach _motoarr;
	{
		_moto    = argp(_x, MOTO_ITSELF);
		_timeout = argp(_x, MOTO_TIMEOUT);
		_pos     = argp(_x, MOTO_ORIG_POS); // base pos (where it must be!)

		_pos1 = getPos _moto; // real pos
		if ( _timeout == TIMEOUT_ZERO ) then // check conditonsm for moto restoring
		{
			_pos1 set [2,0]; // zero Z coordinate
			if ( (!(canMove _moto)) || ((fuel _moto) < FUEL_MIN_VOLUME) || ( ( _pos1 distance _pos) > MOTO_ON_PLACE_DIST)  ) then
			{
				if ( ( {alive _x} count (crew _moto)) == 0) then // empty
				{
					if ( (canMove _moto) && ((fuel _moto) > FUEL_MIN_VOLUME) ) then  {_x set [MOTO_TIMEOUT, TIMEOUT(RESTORE_DELAY_NORMAL)]} // restore after normal delay
					else {_x set [MOTO_TIMEOUT, TIMEOUT(RESTORE_DELAY_SHORT)]}; // restore after shortened dealy
				};
#ifdef __DEBUG__
				hint localize format["motorespawn.sqf: %1 marked for respawn, canMove %2, shift %3, pos %4", _moto, canMove _moto, ( _pos1 distance _pos), _pos1];
#endif
			};
		}
		else // time-out was already set
		{
			if ( time > _timeout) then
			{
				_nobj = nearestObject [ _pos1, "CAManBase" ];
				_driver_near = !(isNull _nobj);
				if ( !_driver_near ) then // no any man near motocycle
				{
				    _pos2 = getPos _nobj;
        			_pos2 set [2,0]; // zero Z coordinate
                    _driver_near = (alive _nobj) && ((side _nobj) == east) && ((_pos2 distance _pos1) < DRIVER_NEAR_DIST);
                }
                else
                { hint localize format["%1 detected at dist %2", typeOf _nobj, (getPos _nobj) distance _pos1]; };

                if (! _driver_near ) then
                {
    				_driver_near = ( {alive _x} count (crew _moto) ) > 0; // is some man in moto crew?
                }
                else {  hint localize format["alive crew count %1", {alive _x} count (crew _moto)]; };

                if ( ! _driver_near) then // if empty and no man nearby (10 meters circle)
                {
                    if ( !alive _moto ) then // recreate vehicle
                    {
                        _type = typeOf _moto;
                        deleteVehicle _moto;
                        _moto = objNull;
                        sleep 1.375;
                        _moto = _type createVehicle [0,0,0];
                        _x set[MOTO_ITSELF, _moto];
#ifdef __DEBUG__
                        hint localize format["motorespawn.sqf: %1 (%2) recreated after breakdown", _moto, _type];
#endif
                    }
                    else	// use current vehicle item
                    {
#ifdef __DEBUG__
                        hint localize format["motorespawn.sqf: %1 moved back alive", _moto];
#endif
                        _moto setDammage 0.0;
                        _moto setFuel 1.0;
                    };
                    sleep 1.11;
                    _moto setPos (_pos);
                    sleep 0.25;
                    //_x set [MOTO_ORIG_POS, getPos _moto];
                    _moto setDir (argp(_x,MOTO_ORIG_DIR));
                    sleep 0.5 + random 0.5;
                    if ( isEngineOn _moto) then { _moto engineOn false; };
                    sleep 0.234;
#ifdef __DEBUG__
                    hint localize format[ "motorespawn.sqf: time %1, pos %5, %2 dir %3, engine on %4",round(time), _moto, getDir _moto, isEngineOn _moto, getPos _moto ];
#endif
				};
				_x set [MOTO_TIMEOUT, TIMEOUT_ZERO]; // drop timeout to allow start it again on next loop
			};
		};
		sleep CYCLE_DELAY; // main cycle time-out
	} forEach _motoarr;
	//_mainCnt = _mainCnt +1;
};
_motoarr = [];
_motoarr = nil;
hint localize "--- scripts/motorespawn.sqf is exiting due to any fatal error ----"