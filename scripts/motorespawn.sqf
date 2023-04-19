// by Sygsky, works only on server
// scripts\motorespawn.sqf
//
// script to restore vehicles from designated list
// independently of their type and position
// restore delay may be user-defined too.
// First position in the array are stored and looked as main position to return vehicles after position change
// Example:
// [_veh_arr, _big_delay, _small_delay, "service_name_in_RPT", _lock_vehs_or_not] - description in lower lines
// ...
// [
//  [moto1, ... ,motoN], - vehicles array (0)
//  big_delay,           - return moved/killed vehicle  big delay (1)
//  small_delay,         - return moved/killed vehicle  small delay (2)
//  "service_name"       - name for RPT file messages (3)
//  lock_or_not           - lock new/returned vehicles (true) or not (false) (4)
// ] execVM "motorespawn.sqf";
// ...
//
// Where motoN - reference to device with position to keep it here
//
// Each auto-movement is accompanied by special sounds for get and put events for the moto being moved.
//

if (!isServer) exitWith{};

#include "x_macros.sqf"
private ["_motoarr", "_moto", "_timeout","_lock", "_pos", "_pos1", "_type", "_nobj", "_driver_near","_driverType"];

// comment next line to not create debug messages
#define __DEBUG__

// 5 mins timeout will be good
RESTORE_DELAY_NORMAL  = 420;
RESTORE_DELAY_SHORT   = 30;
#define CYCLE_DELAY 15
#define TIMEOUT_ZERO 0
#define MOTO_RETURN_DIST 3.5
#define DRIVER_NEAR_DIST 10
#define SOUND_MIN_DIST_TO_SAY 5 // Min shift in meters to play sound on moto teleport
#define FUEL_MIN_VOLUME 0.2
// offsets for vehicle status array items
#define MOTO_ITSELF 0
#define MOTO_ORIG_POS 1
#define MOTO_ORIG_DIR 2
#define MOTO_TIMEOUT 3
#define MOTO_ID      4

#define inc(val) (val=val+1)
#define TIMEOUT(addval) (time+(addval))

_service_name  = "motorespawn.sqf";
_lock = false;

_motoarr = []; // create array of vehicles to return to original position after some delay
sleep 2;

// +++++++++++++++++++++++++++++++++++++++ READ call PARAMS +++++++++++++++++++++++++++++++++++++++++
// check is special parameters are set (for Antigua as example
if ( (typeName (_this select 0)) == "ARRAY") then { // [[moto1, moto2...], DELAY_NORM, DELAY_SHORT, _service_name]
	RESTORE_DELAY_NORMAL = _this select 1;
	RESTORE_DELAY_SHORT  = _this select 2;
	_service_name         = _this select 3;
	_lock = if (count _this > 4) then {_this select 4} else {false}; // lock (true) or not lock (false) new or moved vehicle when put it to the original position
	_this = _this select 0;
};

hint localize format["+++ motorespawn.sqf: service started with name '%1';", _service_name];
// read all vehicles and store their initial position and angles
for "_i" from 0 to count _this -1 do { // list all motocyrcles/automobiles
	_x = _this select _i;
//	_motoarr = _motoarr + [[_x, getPos _x, direction _x, TIMEOUT_ZERO]];
	_posMain = getPos _x;
	_posMain set[2,0]; // zero Z coordinate
	_x setPos _posMain;
	sleep 0.2;
	_posReal = getPos _x;
	_posReal set [2,0];
	sleep 0.2;
	_motoarr set [count _motoarr , [_x, _posReal, getDir _x, TIMEOUT_ZERO, _i +1]];

	if ( !(_x hasWeapon "CarHorn")) then {
		_x addWeapon "CarHorn"; // add horn for motorcycle
		hint localize format["+++ moto%1 (%2): CarHorn added", _i + 1, typeOf _x];
	} else {hint localize format["+++ moto%1 (%2): already has CarHorn", _i + 1, typeOf _x]};
    hint localize  format["+++ moto%1 ini pos %2, real %3, diff %4", _i + 1, _posMain, _posReal, [_posReal,_posMain] call SYG_vectorSub3D ];
//	_x addWeapon "CarHorn";  // add horn for motorcycle: not work in MP
};

sleep CYCLE_DELAY;

#ifdef __DEBUG__

hint localize format[
	"+++ %7:  RESTORE_DELAY_NORMAL %1, RESTORE_DELAY_SHORT %2, CYCLE_DELAY %3, MOTO_RETURN_DIST %4, DRIVER_NEAR_DIST %5, FUEL_MIN_VOLUME %6",
					       RESTORE_DELAY_NORMAL,    RESTORE_DELAY_SHORT,    CYCLE_DELAY ,   MOTO_RETURN_DIST ,   DRIVER_NEAR_DIST ,   FUEL_MIN_VOLUME, _service_name
];

{
	hint localize format[
	"+++ %2:  %1", _x, _service_name];
} forEach _motoarr;

#endif

// Driver type to be checked near before teleport moto back to base position
_driverType = switch playerSide do {
    case east: {
        "SoldierEB"
    };
    case resistance: {
        "SoldierGB"
    };
    case west: {
        "SoldierWB"
    };
    default {"SoldierEB"};
};

while {true} do {

	if (X_MP && ((call XPlayersNumber) == 0) ) then {
		waitUntil {sleep (25.012 + random 1);(call XPlayersNumber) > 0};
	};

	sleep CYCLE_DELAY; // main cycle time-out

	//  forEach _motoarr;
	{
		_moto    = _x select MOTO_ITSELF; //
		_timeout = _x select MOTO_TIMEOUT;
		_posMain = _x select MOTO_ORIG_POS; // base pos (where it must be!)
		_id      = _x select MOTO_ID;

		_posReal = getPos _moto; // real pos
		_posReal set [2,0]; // zero Z coordinate
		_dist = round (_posReal distance _posMain); // get 2D distance
		_posReal0 = + _posReal; // save position to print it later

		if ( _timeout == TIMEOUT_ZERO ) then { // check conditions for moto position restoring
			if (!alive _moto) exitWith {_x set [MOTO_TIMEOUT, TIMEOUT(RESTORE_DELAY_SHORT)] };

			// ++++++++++++++++++ MAIN CHECK STATEMENT +++++++++++++++++++

			if ( (!(canMove _moto)) || ((fuel _moto) < FUEL_MIN_VOLUME) || ( _dist > MOTO_RETURN_DIST)  ) exitWith {
				if ( ( {alive _x} count (crew _moto)) == 0) then { // empty
					if ( (canMove _moto) && ( ( fuel _moto ) > FUEL_MIN_VOLUME ) ) then  { _x set [ MOTO_TIMEOUT, TIMEOUT( RESTORE_DELAY_NORMAL ) ] } // restore after normal delay
					else {_x set [MOTO_TIMEOUT, TIMEOUT(RESTORE_DELAY_SHORT)]}; // restore after shortened delay
				};
			};
			if ( isEngineOn _moto) then { _moto engineOn false; }; // #584. 2022-12-19 23:13:50
		} else { // time-out was already set
		
			if ( time < _timeout) exitWith {};
			if ( ( {alive _x} count (crew _moto)) > 0) exitWith { // not empty
				_x set [ MOTO_TIMEOUT, TIMEOUT( RESTORE_DELAY_NORMAL ) ];
			};

			_objNearArr = _posReal nearObjects [_driverType, DRIVER_NEAR_DIST]; //  //nearestObject [ _posReal, "CAManBase" ];

			_nobj = objNull;
			{
				if (alive _x && isPlayer _x) exitWith {_nobj = _x};
			} forEach _objNearArr;
			_driver_near = !isNull _nobj;

			if (! _driver_near ) then {
				_driver_near = ( {alive _x} count (crew _moto) ) > 0; // is some man in moto crew?
				if (_driver_near) then {
					hint localize format["+++ %2: alive crew on moto count %1", {alive _x} count (crew _moto), _service_name];
				};
			} else {  hint localize format["+++ %3: alive %1 detected at dist %2", typeOf _nobj, (getPos _nobj) distance _posReal, _service_name]; };

			if ( ! (_driver_near && (alive _moto))) then { // if empty and no man nearby (10 meters circle)
				_say = _dist >= SOUND_MIN_DIST_TO_SAY; // sound only if distance between moto and origin point is long enough
				if (_say ) then {
				["say_sound", _moto, "steal"] call XSendNetStartScriptClientAll;
					_posReal = getPosASL _moto;
					_posReal set [2,-15];
					_moto setPosASL _posReal; // move vehicle underground before return
				};

#ifdef __DEBUG__
				hint localize format["+++ %9: moto%1(%2) returned, %3canMove, dmg %4, fuel %5, dir %6, dist %7 (min %8)",
					_id,
					typeOf _moto,
					if (canMove _moto) then {""} else {"!"},
					damage _moto,
					fuel _moto,
					round ( direction _moto),
					_dist,
					MOTO_RETURN_DIST,
					_service_name];
#endif

				if ( !alive _moto ) then { // recreate vehicle
					_type = typeOf _moto;
					deleteVehicle _moto;
					_moto = objNull;
					sleep 1.375;
					_moto = _type createVehicle [0,0,0];
					_moto lock _lock;
					_x set[MOTO_ITSELF, _moto];
					if ( !(_moto hasWeapon "CarHorn")) then {
						_moto addWeapon "CarHorn"; // add horn for motorcycle
						hint localize format["+++ moto%1(%2) restored, CarHorn added", _id, _type];
					} else {hint localize format["+++ moto%1(%2) restored, has CarHorn", _id, _type]};

#ifdef __DEBUG__
					hint localize format["+++ %3: moto%1(%2) dead, recreated after breakdown", _id, _type,_service_name];
#endif
				} else {	// use current vehicle item
#ifdef __DEBUG__
                    //  +++ antigua_vehs: alive moto9(TT650C) local returned
					hint localize format[ "+++ %4: moto%1(%2) alive/%3 returned", _id, typeOf _moto, if (local _moto) then {" local"} else {" remote"}, _service_name ];
#endif
					_moto setDammage 0.0;
					_moto setFuel 1.0;
				};
				sleep 1.11;

				_moto setDir (_x select MOTO_ORIG_DIR);
				_moto setPos (_posMain);
				if ( isEngineOn _moto) then { _moto engineOn false; };
				if ( _say ) then { ["say_sound", _moto, "return"] call XSendNetStartScriptClientAll };

				sleep (0.5 + (random 0.5));
#ifdef __DEBUG__
				hint localize format[ "+++ %8: moto%1(%2) returned, dir %3, dist %4, before off %5, after off %6, engine %7", _id,
                    typeOf _moto,
                    direction _moto,
                    _dist,
                    [_posMain, _posReal0] call SYG_vectorSub, // offset before returning
                    [_posMain, getPos _moto] call SYG_vectorSub, // offset after returning to original
                    if (isEngineOn _moto) then {"on"} else {"off"},
                    _service_name
				];
#endif
			};
			_x set [MOTO_TIMEOUT, TIMEOUT_ZERO]; // drop timeout to allow start it again on next loop
		};
		sleep CYCLE_DELAY; // main cycle time-out
	} forEach _motoarr;
};
_motoarr = nil;
hint localize format["--- scripts/motorespawn.sqf(service %1) is exiting due to any fatal error ---", _service_name]