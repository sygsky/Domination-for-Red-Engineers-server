/**
 *
 * SYG_utilsEnv.sqf : Environment utils by Sygsky from JHC
 *
 */
 
#include "x_macros.sqf"

#define DEFAULT_RESURRECT_DIST 10
#define DEFAULT_RADIOUS_STEP 5
#define DEFAULT_RADIOUS_MAX 100

#define inc(x) (x=x+1)
#define arg(x) (_this select (x))
#define argp(param,x) ((param)select(x))
#define argopt(num,val) (if ( count _this <= (num) ) then {val} else { arg(num) })
#define argoptskip(num,defval,skipval) (if ( count _this <= (num) ) then { defval } else { if (arg(num) == (skipval)) then {defval} else {arg(num)} })

///////////////////////////////////////////////////////////////////
// Call as: _script = [_obj, _interval, _face, "texture1.paa", "texture2.paa"] call SYG_blinkingTexture; 
// or
// E.g.: _script = [_billboard, 1, 0, "texture1.paa", "texture2.paa"] call SYG_blinkingTexture;
// Created by: [GLT]Myke
// Where:
//        _obj - object to enable blinking
//        _interval - interval in seconds to blink
//        _face - index of plane to blink retexture
//        _tex1 - initial texture
//        _tex1 - final texture
// Returns: script handle
// Note: procedure is spawned. To stop it, please use follow code:
// terminate _script;  // to stop blinking
// _billboard setObjectTextture [0, "texture1.paa"]; 
// to ensure correct texture on billboard without blinking
//////////////////////////////////////////////////////////////////
SYG_blinkingTexture = {
	_this spawn {
		private [ "_billboard","_interval","_face","_tex1","_tex2" ];
		_billboard = _this select 0;
		_interval = _this select 1;
		_face = _this select 2;
		_tex1 = _this select 3;
		_tex2 = _this select 4;

		while {alive _billboard} do {
		_billboard setObjectTexture [_face, _tex1];
		sleep _interval;
		_billboard setObjectTexture [_face, _tex2];
		sleep _interval;
		};
	}
};

// _nul = [_obj, _face, _texture] call SYG_setTexture;
SYG_setTexture = {
	player groupChat format["[%1,%2,%3] call SYG_setTexture;", arg(0),arg(1),arg(2)];
	arg(0) setObjectTexture [arg(1),arg(2)];
};

//
// call on client only to build deritrinitation visual effect (sparcles) above player:
// _tobj = [_obj, _height, _dur] call SYG_showTeleport;
//   or call:
// to prevent internal deletion (_dur), set delete interval to 0, e.g.
// _tobj = [_obj, 4, 0] call SYG_showTeleport;
// sleep _before_del;
// deleteVehicle _tobj;
//
SYG_showTeleport = {
/*	private ["_PS1", "_pos","_dur","_obj"];
 	_obj = arg(0);
	if ( isNull _obj ) exitWith {hint localize "--- SYG_showTeleport: expected object isNull";};
	_pos = getPos _obj;
	_pos set [2, argp(_pos,2)+arg(1)];
	_dur = argopt(2,5);
	_PS1 = "#particlesource" createVehicleLocal _pos;
	hint localize format["SYG_showTeleport: obj %1, pos %2, dur %3, particle obj %4", typeOf _obj, _pos, _dur, _PS1];
	_PS1 setParticleCircle [0, [0, 0, 0]];
	_PS1 setParticleRandom [0, [0, 0, 0], [0,0,0], 0, 1, [0, 0, 0, 0], 0, 0];
	_PS1 setParticleParams [["\Ca\Data\ParticleEffects\SPARKSEFFECT\SparksEffect.p3d", 8, 3, 1], "", "spaceobject", 1, 0.2, [0, 0, 1], [0,0,0], 1, 10/10, 1, 0.2, [2, 2], [[1, 1, 1 ,1], [1, 1, 1, 1], [1, 1, 1, 1]], [0, 1], 1, 0, "", "", objNull];
//	_PS1 setDropInterval 0.01;
//	if ( _dur > 0 ) then { _PS1 spawn {deleteVehicle _this};};
//	_PS1
*/


// args == [_obj, _height_above_obj,_time_to_expire]

	private ["_PS1", "_pos","_dur","_obj","_hgt","_pwr"];
	_obj   = arg(0);
	_pos = if ( (typeName _obj) == "ARRAY" ) then {_obj} else {position _obj};
	_hgt   = argopt(1,6) max 6; // heigth from 6 meters
	_dur   = 20; //argopt(2,) max 5; // duration from 5 seconds
	_pwr   = argopt(3,3) max 3; // power of effect, from 3 (usually height of sparks tail)
	_PS1 = "#particlesource" createVehicleLocal [_pos select 0, _pos select 1, _hgt];
	_PS1 setParticleCircle [0, [0, 0, 0]];
	_PS1 setParticleRandom [0, [0, 0, 0], [0,0,0], 0, 1, [0, 0, 0, 0], 0, 0];
	_PS1 setParticleParams [["\Ca\Data\ParticleEffects\SPARKSEFFECT\SparksEffect.p3d", 8, 3, 1], "", "spaceobject", 1, _pwr, [0, 0, _hgt], [0,0,0], 1, 10/10, 1, 0.2, [10, 5, 15, 1], [[1, 1, 1 ,1], [1, 1, 1, 1], [1, 1, 1, 1]], [0, 1], 1, 0, "", "", ""];
	_PS1 setDropInterval 0.01;
	
	[_PS1,_dur] spawn {
		// play corresponding sound
		arg(0) say ["highvoltage",200];
		sleep arg(1);
		deleteVehicle arg(0);
		// stop sound if still on
	};
};

//
// Adds inspect action on airbase fires. Wotks once only on client computer
//
SYG_firesService = {
    private ["_cnt","_fires"];
    hint localize format["scripts/SYG_utilsEnv.sqf => SYG_firesService, isServer %1, isNil ""SYG_firesAreServed"" %2", isServer, isNil "SYG_firesAreServed"];
    if ( ! X_Client ) exitWith{0};
    if (!isNil "SYG_firesAreServed") exitWith {SYG_firesAreServed};
    SYG_firesAreServed = 0;
    private ["_cnt","_fire"];
    // play with fires on base
    _cnt = 0;
    {
        _fires = nearestObjects [_x, ["Fire","FireLit"],10];
        if ( count _fires > 0) then
        {
            (_fires select 0) addAction [localize "STR_CHECK_ITEM", "scripts\fireLitAction.sqf"];
            _cnt = _cnt + 1;
        };
    } forEach d_base_patrol_fires_array;
    hint localize format["scripts/SYG_utilsEnv.sqf: Inspect actionEventHandler added to %1 created fires ", _cnt];
};

//
// Restores all killed embedded Arma island objects at designated radious around point or object
//
// call: _restored_cnt = [{_pos||_obj},_dist] call SYG_restoreIslandItems;
//
SYG_restoreIslandItems = {
    hint localize format["+++ SYG_restoreIslandItems %1",_this];
    private ["_cnt", "_pos", "_dist", "_list", "_sleep_period"];
    if ( typeName _this != "ARRAY") exitWith {0};
    if ( count _this < 2 ) exitWith {0};
    _pos = arg( 0 );
    if (typeName _pos == "OBJECT") then {_pos = getPos _pos;};
    if (typeName _pos != "ARRAY") exitWith {[]};
    _dist = arg( 1 );
    if ( _dist < 0 ) exitWith {[]};
    _cnt = 0;
    _list = ([_pos, _dist] call SYG_findRestorableObjects);
    if ( count _list == 0) exitWith {0};
    _sleep_period = 0.05; // 2 / (count _list);
    {
        _x setDamage 0;
        if ( local _x) then
        {
            _x setVectorUp [0,0,1];
        };
        _cnt  = _cnt + 1;
        sleep _sleep_period;
    } forEach _list;
    _cnt
};

//
// Finds all killed embedded Arma island objects at designated radious around point or object
//
// call: _restored_obj__arr = [{_pos||_obj},_dist] call SYG_findRestorableObjects;
//
// default resurrect distance is 10 meters
//
SYG_findRestorableObjects = {
    private [ "_pos", "_dist","_list","_i"];
    if ( typeName _this != "ARRAY") exitWith {[]};
    if ( count _this < 2) exitWith {[]};
    _pos = arg(0);
    if (typeName _pos == "OBJECT") then {_pos = getPos _pos;};
    if (typeName _pos != "ARRAY") exitWith {[]};
    _dist = arg(1);
    hint localize format["+++ SYG_findRestorableObjects %1",[_pos, _dist]];
    _list = nearestObjects [ _pos, [], _dist ];
    hint localize format["+++ SYG_findRestorableObjects found %1 any items",count _list];
    for "_i" from 0 to ((count _list) - 1) do
    {
        _x = argp(_list, _i);
        if ( (typeOf _x != "") || (getDammage _x < 1) )then
        {
            _list set [_i, "RM_ME"];
        };
    };
    _list = _list - ["RM_ME"];
    hint localize format["+++ SYG_findRestorableObjects found %1 killed items",count _list];
    _list
};

//
// Counts killed island items at designated radious around designated position or object
//
// call: [{_pos||_obj},_num] call SYG_countKilledIslandItems;
//
// default resurrect distance is 10 meters
//
SYG_countKilledIslandItems = {
    private [ "_pos", "_dist"];
    if ( count _this == 0) exitWith {0};
    if ( count _this < 2) exitWith {0};
    private ["_pos"];
    _pos = arg(0);
    if (typeName _pos != "ARRAY") then {_pos = getPos (arg(0));};
    {(getDammage _x) == 1} count (nearestObjects [_pos,[],argopt(1,DEFAULT_RESURRECT_DIST)])
};

//
// call: _arr = [_unit|_object, max_num, _radious_step] call SYG_makeRestoreArray;
// result: [[num1, radous1]<,...[numN1, radousN]>] where num# is number of restorable objects found in radious#
//
SYG_makeRestoreArray = {
    //player groupChat format["*** %1 call SYG_makeRestoreArray ***", _this];
    if ( count _this == 0) exitWith {[]};
    if ( count _this < 2) exitWith {[]};
    private ["_pos","_num","_step","_dist","_dist_limit","_dist_cnt","_filled_in_dist","_prev_cnt","_cnt","_res","_list","_max_cnt"];

    _pos = arg(0);

    _num = arg(1);
    if ( _num <= 0)  exitWith {[]};

    _step = argopt(2, DEFAULT_RADIOUS_STEP);

    _dist_limit = argopt(3, DEFAULT_RADIOUS_MAX);

    // count number of object in each <5-10> meters circle radious
    _ring_rad = _step;

    _prev_cnt = 1;
    _filled_in_ring = 0;
    _cnt = 0;
    _res = [];
    _list = [_pos, _dist_limit] call SYG_findRestorableObjects;
    _max_cnt = _num min (count _list);
    if ( _max_cnt == 0) exitWith { _res };
    //player groupChat format["[pos %1, max cnt %2, step %3] call SYG_makeRestoreArray: max_cnt %4, %5 restoreable items", _pos, _num, _step, _max_cnt, count _list];
    //hint localize format["[pos %1, max cnt %2, step %3] call SYG_makeRestoreArray => found cnt %4", _pos, _num, _step, _max_cnt];
    for "_num" from 0 to _max_cnt - 1 do
    {
        _dist = _pos distance (argp(_list,_num));
        //hint localize format["%1: %2 %3 %4", _num + 1, _dist, _ring_rad, _filled_in_ring ];
        if ( _dist > _ring_rad ) then // curent dist limit detected
        {
            if ( _filled_in_ring > 0 ) then
            {
                _res = _res + [[_num, _ring_rad]];
                _filled_in_ring = 0; // start next ring
            };
            // find next ring to fit current object
            while {(_ring_rad < _dist_limit) && ( _dist > _ring_rad)} do
            {
                _ring_rad = _ring_rad + _step;
            };
        };
        if ( _dist <= _ring_rad ) then // curent dist limit detected
        {
            _filled_in_ring = _filled_in_ring + 1; // one more for this dist
        };
    };
    _num = if ( count _res > 0) then {_res select ((count _res) - 1) select 0} else {0}; // last filled count
    if ( _max_cnt > _num ) then
    {
        _res = _res + [[_max_cnt, _dist + 0.01 ]]; // fill with last object distance
    }
    else
    {
        if (count _res > 0 ) then
        {
            (_res select [ (count _res) - 1 ]) set [ 1, _dist + 0.01 ];
        };
    };
     //player groupChat format["SYG_makeRestoreArray: returns %1", _res];
    _res
};

///
// Sets grass level, example: 0 call  SYG_setGrassLevel; // sets full grass level
//
SYG_setGrassLevel = {
    private ["_real_list","_vlist"];
    _real_list = [50, 25, 12.5];
    _vlist = ["STR_SYS_011","STR_SYS_012","STR_SYS_013"]; // "No Grass", "Medium Grass", "Full Grass"
    _this = (_this max 0) min ((count _real_list) - 1);
    if (d_graslayer_index != _this) then {
        d_graslayer_index = _this;
        setTerrainGrid (_real_list select d_graslayer_index);

        (format [localize "STR_SYS_01"/* "Grass layer set to: %1" */ , localize (_vlist select d_graslayer_index)]) call XfGlobalChat;
    };
};

SYG_viewDistanceArray = [1500, 2000, 2500, 3000, 3500, 4000, 5000, 6000, 7000, 8000, 9000, 10000];

// Call only on client. Or it may be useful on server also?
//
// Sets view distance. Call as:
// _dist = 0 call SYG_setViewDistance;
// _dist = [0] call SYG_setViewDistance;
// _dist = 1200 call SYG_setViewDistance;
// _dist = [10000] call SYG_setViewDistance;
//
SYG_setViewDistance = {
    //hint localize format["+++++ %1 call SYG_setViewDistance; isServer = %2+++++", _this, isServer ];
    //if ( isServer ) exitWith {-1};
    private ["_selectedIndex"];
    _selectedIndex = _this;
    if ( typeName _this == "ARRAY") then {_selectedIndex = arg(0);};
    if (_selectedIndex >= argp(SYG_viewDistanceArray, 0)) then {_selectedIndex = SYG_viewDistanceArray find _selectedIndex;};
    _selectedIndex == (_selectedIndex max 0) min ((count SYG_viewDistanceArray) -1);
    //hint localize format["+++++ _selectedIndex = %1", _selectedIndex ];
    if (d_viewdistance != (SYG_viewDistanceArray select _selectedIndex)) then {
        d_viewdistance = SYG_viewDistanceArray select _selectedIndex;
        setViewDistance d_viewdistance;
        (format [localize "STR_SYS_1140", d_viewdistance]) call XfGlobalChat; // "Viewdistance set to: %1"
    };
    d_viewdistance
};

//
// gets view distance by index. Call as:
// _dist = call SYG_getViewDistance;
// _dist = call SYG_getViewDistance;
SYG_getViewDistance = {
    if ( ! X_Client ) exitWith {-1};
    d_viewdistance
};