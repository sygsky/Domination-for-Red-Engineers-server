// SYG_utilsSM.sqf : utils for Side Missions
private [ "_unit", "_dist", "_lastPos", "_curPos", "_boat", "_grp", "_wplist","_startPos", "_procWP", "_wpIndex", "_unittype", "_stopBoat" ];

#include "x_setup.sqf"
#include "x_macros.sqf"

//#define __DEBUG__

#define arg(x) (_this select(x))
#define argp(arr,x) ((arr)select(x))
#define inc(x) ((x)=(x)+1)
#define argopt(num,val) if ((count _this)<=(num))then{val}else{arg(num)}
#define RAR(ARR) ((ARR)select(floor(random(count(ARR)))))
#define RANDOM_ARR_ITEM(ARR) ((ARR)select(floor(random(count(ARR)))))

if ( !isNil "SYG_sm_initialized" )exitWith { hint "SYG_utilsSM already initialized"};
SYG_sm_initialized = true;
//hint "INIT of SYG_utilsSM";

// Creates group of static vehicles for Side Mission
//
// call as: _grp = [_grp, _vehtype, _utype, _posarr<, _create_delay>] call SYG_createStaticWeaponGroup;
// where:
//       _grp     is a group to assign newly created vehicle team
//       _vehtype is a vehicle type to create. e.g. "Stinger_Pod_East", "Stinger_Pod" or "ACE_ZU23M" or array of randomly selected vehicles, e.g. ["Stinger_pod","ACE_ZU23M"...]
//       _utype   is an unit type to asssign to a vehicle, e.g.:
//                 _utype = if (d_enemy_side == "EAST") then {d_crewman2_E} else {d_crewman2_W};
//      _posarr   is an array of positions to build created vehicles at, MUST be array of pos arrays [[x1,y1,z1],[x2,y2,z2] ...],
//                 z position is rather important to install vehicle for example on the top of some building 
//      _create_delay - delay in seconds to create vehicles, may be absent, default is 1
//

SYG_createStaticWeaponGroup = {
	private ["_grp","_vehtype","_vt","_utype","_posarr","_pos","_veh","_unit","_create_delay"];
	
	_grp     = arg(0);
	_vehtype = arg(1);
	_utype   = arg(2);
	_posarr  = arg(3); // positions array

#ifdef __DEBUG__
    hint localize format["SYG_utilsSM.sqf.SYG_createStaticWeaponGroup: called with %1", _this];
#endif

	if ( (typeName (_posarr select 0)) != "ARRAY" ) then // it is single pos with 2-3 coordinates, not array of pos
	{
		_posarr = [_posarr];
	};
	
	_create_delay = argopt(4,1); // delay between creations
	_create_delay  = _create_delay min 1;
	
	{ //forEach _posarr;
		_pos = _x;
		_vt = if ( typeName _vehtype == "ARRAY") then {_vehtype  call XfRandomArrayVal} else {_vehtype};
		_veh = createVehicle [_vt, _pos, [], 0, "CAN_COLLIDE"];
		sleep 0.01;
		_veh setPos _x;
		_veh setVectorUp [0,0,1];

		extra_mission_vehicle_remover_array = extra_mission_vehicle_remover_array + [_veh];
		
		_unit = _grp createUnit [_utype, _pos, [], 0, "FORM"];
		sleep 0.01;
		_unit setSkill 1.0;
		[_unit] joinSilent _grp;
		_unit assignAsGunner _veh;
		_unit moveInGunner _veh;

		extra_mission_remover_array = extra_mission_remover_array + [_unit];

		// lets wait time inversely proportional to the player number
		if ( (call XPlayersNumber) == 0 ) then 
		{
			sleep 1.0; // create next vehicle each second as no players to relax with progress
		}
		else
		{
			sleep  _create_delay; // sleep some time before next vehicle 
		};
	} forEach _posarr;

	_grp setCombatMode "RED";
	_grp setBehaviour "AWARE";

	_grp
};

//
// Find nearest enemy unit at designated distance from point
//
// call: [_side,_pos,_dist,["LandVehicle","Air","Ship"]] call SYG_findEnemyAt;
//        
//
SYG_findEnemyAt = {
	private ["_side","_pos","_dist","_types","_arr"];
	_side = arg(0);
	_pos  = arg(1);
	_dist = arg(2);
	_types= arg(3);
	_arr = nearestObjects [_pos, _types, _dist];
	{
		if ((side _x) == _side) exitWith { _x };
	} forEach _arr;
	objNull
};

//
// Finds all SM near to the designated point
// call as: _near_sm_arr = [_sm_array, _point, _dist] call SYG_findNearSM;
// where: _sm_array = sm id array, _point = [x,y,z] as search center, _dist = search radious around the _point
// returns: array of SM id, near to the point. If case of bad parameters, always [] is returned
//
SYG_findNearSMIdsArray = {
    if ( typeName _this != "ARRAY") exitWith {hint localize format["--- SYG_findNearSM: expected argument is array, found %1", typeName _this];[]};
    if ( count _this < 3) exitWith {hint localize format["--- SYG_findNearSM: expected number of arguments >= 3, found %1", count _this]; []};
    _sm_id_arr   = arg(0);
    _center      = arg(1);
    _search_dist = arg(2);
    _ret_id_arr  = [];
    {
        _sm_pos = call compile format ["""SM_POS_REQUEST"" call compile preprocessFileLineNumbers ""x_missions\m\%1%2.sqf"";",d_mission_filename, _x];
        _dist = _search_dist distance _sm_pos;
        if (_dist < _search_dist ) then { _ret_id_arr = _ret_id_arr + [_x]; };
    } forEach _sm_id_arr;
    _ret_id_arr
};

#ifdef __SIDE_MISSION_PER_MAIN_TARGET_COUNT__
//
// Detects if main target is able to be executed/started. Works on server and on client
//
// call:    [] call SYG_isMainTargetAllowed;
// returns: __mainAllowed = call SYG_isMainTargetAllowed
//
SYG_isMainTargetAllowed = 
{
    _target_counter = if (isServer) then {current_counter} else {client_target_counter}; // main target counter
    if ( _target_counter <= 0 ) exitWith {true}; // Lets start in any way at the mission beginning
    if (current_mission_counter == 0) exitWith {true};
    // Here important formula to calculate main target allowance is  executed
    if ( floor ( (current_mission_counter - 1) * __SIDE_MISSION_PER_MAIN_TARGET_COUNT__) >= (_target_counter -1) ) exitWith {true}; // 1 side mission for 2 main targets must be finished!!!
    // hint localize format["false SYG_isMainTargetAllowed: _target_counter %1, current_mission_counter %2", _target_counter, current_mission_counter];
    false
};
#endif

SYG_lastTownsQueue   = [[],3]; // [array of last towns indexes], length of circular queue
SYG_lastPlayersQueue = [[],3]; // [array of last players connected], length of circular queue

// call: _queue = [_queue, _item] call SYG_queueItem;
SYG_queueItem = {
    private ["_arr"];
//    hint localize format["+++ SYG_queueItem: %1", _this];
    _arr = (_this select 0) select 0;
    _arr = _arr - [_this select 1]; // remove duplicated entries
    _arr set[count _arr, _this select 1];
    if ( (count _arr) > ((_this select 0) select 1)) then // length overflow
    {
        _arr set [0, "RM_ME"];
        _arr = _arr - ["RM_ME"];
    };
    (_this select 0) set [0, _arr];
    +_arr
};

// call: _list = _queue call SYG_queueItem;
SYG_getQueueList = {
    +(_this select 0)
};
// call: _renewed_list = "Town_Name" call SYG_lastTownsAdd;
SYG_lastTownsAdd = {
    [SYG_lastTownsQueue, _this] call SYG_queueItem
};

// Returns array of last towns added to queue
SYG_lastTownsGet = {
    +(SYG_lastTownsQueue call SYG_getQueueList)
};

// call: _renewed_list = "Player_Name" call SYG_lastPlayersAdd;
SYG_lastPlayersAdd = {
    [SYG_lastPlayersQueue, _this] call SYG_queueItem
};
// Returns array of last towns added to queue
SYG_lastPlayersGet = {
    SYG_lastPlayersQueue call SYG_getQueueList
};
