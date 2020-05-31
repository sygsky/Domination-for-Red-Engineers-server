/*
    scripts\illumination_full.sqf
	author: Sygsky, 14-MAY-2020
	description: produce illumination over designated center
	_this = [_player_name, _illum_center_obj]
	returns: nothing
*/
//hint localize format["+++ Illumination (%1): _this == %2, isServer = %3", call SYG_nowTimeToStr, _this, isServer];

if (!isServer) exitWith{}; // only for server

//#define FLARE_NUM 7
#define FLARE_ALT_START 450                  // altitude to create flare
#define FLARE_DIST 550                       // dist from center to luanch flare
//#define FLARE_ALT_END 20                   // altitude of flare to start next one
//#define FLARE_NIGHT_COST_PER_RANK 10       // how many per rank index (private == 1) costs base illumination during whole night
//#define FLARE_MAX_COUNT 5                  // maximum number of flares
//#define FLARE_INTERVAL 10
#define FLARE_POINT_TYPES ["WarfareBEastAircraftFactory","WarfareBWestAircraftFactory","FlagCarrier","Land_Vysilac_FM","Land_telek1"]
#define FLARE_OBJ_CHECK_INTERVAL 120        // interval in seconds to check launch flare objects (e.g. towers on base)

#include "x_setup.sqf"

#ifdef __ACE__
    #define FLARE_TYPE "ACE_Flare_Arty_White"
    #define FLARE_LIVE_TIME 60
#else
    #define FLARE_TYPE "ACE_Flare_40mm_White"
    #define FLARE_LIVE_TIME 30
#endif

if (!isNil "SYG_illum_runner") exitWith  {
    // send info to player that the illumination is already running
    ["msg_to_user", _this select 0,  [ ["STR_ILLUM", SYG_illum_runner]], 0, 2, false, "losing_patience" ] call XSendNetStartScriptClient;
};

if (typeName _this != "ARRAY") exitWith { hint localize format["--- Illumination: expected input array [_player_name, _illum_center_obj] not found -> _this = %1", _this]};
if (count _this < 2) exitWith {hint localize format["--- Illumination: illegal start parameters (must be [_player_name, _illum_center_obj]) _this = %1", _this]};
if ( !( typeName ( _this select 0 ) == "STRING" ) ) exitWith { hint localize format[ "--- Illumination: Expected started player name string as 1st parameter, detected ""%1""", typeof (_this select 0) ] };

private ["_i", "_pos", "_flares", "_id_pos","_no","_center","_obj_cnt","_center", "_cnt", "_check_time"];

_pname = _this select 0;
_center = _this select 1;
if ( ( typeName  _center != "ARRAY" ) ) then {  _center = _center call SYG_getPos };

SYG_illum_runner = _pname; // store name of illum starter
hint localize format["+++ Illumination (%1): started by ""%2""", call SYG_nowTimeToStr, _pname];
// 0 for night, 1 for day, 2 for morning and 3 for evening
if (call SYG_getDayTimeId != 0 ) then {
    // wait for the next night
    //hint localize format["+++ Illumination over base will sleep %1 hour(s) up to the night", round (SYG_startNight - daytime)];
    sleep (SYG_startNight - daytime);
};

// send info about start of illumination over base for this player
[ "illum_over_base",  _pname ] call XSendNetStartScriptClient;


if (count _no == 0) exitWith {
    SYG_illum_runner = nil;
    hint localize "--- Illumination: exit because no flare point counted (0)"
};
_flares = [];
// loop for flares whole night
_id_pos = 0; // next flare object in list id
//hint localize format["+++ Illumination: start flare launch loop, daytime = %1, ( daytime > SYG_startNight ) || ( time < SYG_startMorning ) = %2", daytime, ( daytime > SYG_startNight ) || ( daytime < SYG_startMorning )];
_cnt = 0;
_check_time = time  - 1;
while { ( daytime > SYG_startNight ) || ( daytime < SYG_startMorning ) } do {
    if ( time >= _check_time) then {
        // fire illumination flare one by one up to the end of night above these buildings
        _no = nearestObjects [_center, FLARE_POINT_TYPES , FLARE_DIST]; // Objects to fire flares above them
        _check_time = time + FLARE_OBJ_CHECK_INTERVAL;
    };
    // create flares step by step
    _obj_cnt = {alive _x} count _no;
//    if (_obj_cnt !=  count _no) then {hint localize format["+++ Illumination: alive centers %1, whole centers %2", _obj_cnt, count _no]};
    if ( ( count _flares ) <  _obj_cnt) then {
        // add one more flare
        {
            _center = _no select _id_pos;
            _id_pos = ( _id_pos + 1 ) mod _obj_cnt;
            if ( alive _center ) exitWith {
                _pos = getPos _center;
                _pos set [ 0, (_pos select 0) + random 10 ];
                _pos set [ 1, (_pos select 1) + random 10 ];
                _pos set [ 2, FLARE_ALT_START ];
                _flares set [count _flares, FLARE_TYPE createVehicle _pos];
                _cnt = _cnt + 1;
            };
        } forEach _no;
    };
    // clean flares list
    if (count _flares > 0) then {
        for "_i" from 0 to (count _flares) -1 do {
            if (isNull (_flares select _i)) then {_flares set [ _i, "RM_ME"]};
        };
        _flares = _flares - ["RM_ME"];
    };
    sleep   floor (FLARE_LIVE_TIME / (_obj_cnt max 1));// sleep for next
};

// allow the next illumination to start on the next night
SYG_illum_runner = nil;
["msg_to_user", "",  [ ["STR_ILLUM_4", _cnt]], 0, 2, false, "message_received" ] call XSendNetStartScriptClient;

// wait until all the flares goes out
while { ({!isNull _x} count _flares) > 0 } do {sleep 5; };
_flares = [];

hint localize "+++ Illumination over base stopped (at morning)";
