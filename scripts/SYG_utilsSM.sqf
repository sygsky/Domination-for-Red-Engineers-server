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
    SYG_lastTownsQueue call SYG_getQueueList
};

// call: _renewed_list = "Player_Name" call SYG_lastPlayersAdd;
SYG_lastPlayersAdd = {
    [SYG_lastPlayersQueue, _this] call SYG_queueItem
};
// Returns array of last towns added to queue
SYG_lastPlayersGet = {
    SYG_lastPlayersQueue call SYG_getQueueList
};

// ++++++++++++++++++++++++++ System to prnt scores of players during each town siege
//
// [[_players],[_scores], _start_time];
// _players = ["player1",...,"playerN"]; // list of players participated in current town
// _scores  = [1,...,N]; // scores of corresponding players
 //
SYG_townScores = [[],[], time];

// Create internal arrays with currently online players at the start of the next town
SYG_townScoresInit = {
    private ["_names","_pl"];
    SYG_townScores  = [ [], [], time];
    _names = [];
    {
        _pl = call _x;
        if (isPlayer _pl) then { _names set [count _names, name _pl];   };
    } forEach SYG_players_arr;
    _names call SYG_townScoresAdd;
    hint localize format["+++ SYG_townScoresInit: SYG_townScores = %1", SYG_townScores];
};

//
// Call: [_player_name1,...,_player_name_N] call SYG_townScoresAdd;
// add each new player connected while town siege process
//
SYG_townScoresAdd = {
    private ["_id","_arr"];
    if ( typeName _this != "ARRAY" ) then {
        if (typeName _this != "STRING") then {
            if (isPlayer _this) then { _this = name _this} else { _this = str _this};
        };
        _this = [_this];
    };
    //hint localize format["+++ SYG_townScoresAdd _this %1", _this];

    {
        _id = d_player_array_names find _x;
        // hint localize format["+++ SYG_townScoresAdd for %1 id == %2", _x, _id];
        if (_id >= 0) then { // player is registered on the server
            _arr = SYG_townScores select 0;
            if ( !(_id in _arr)) then {  // add new player to list of town liberation participates
                _arr set [count _arr, _id];
                _arr = SYG_townScores select 1;
                _arr set [count _arr, (d_player_array_misc select _id) select 3]; // set player score, from d_player_array_misc player_item: [[d_player_air_autokick, time, _name, 0, "", arg(1)]]
            };
        };
    }forEach _this;
    //hint localize format["+++ SYG_townScoresAdd result %1", SYG_townScores];
};

// Prints to arma_server.RPT all player scores got during this town liberation process
// call: _town_name call SYG_townScoresPrint
SYG_townScoresPrint = {
    private ["_arr","_arr1","_sum", "_i","_id","_item","_diff","_str","_time_diff"];
    //hint localize format["++++++ Town ""%1"" personal players score:",_this];
    _arr  = SYG_townScores select 0;
    _arr1 = SYG_townScores select 1;
    hint localize "[";
    hint localize format[ "++++++ Town ""%1"" (#%2) players score report ++++++", _this, current_counter ];

    _sum = 0;
    _time_diff = time - (SYG_townScores select 2);
    if (count _arr > 0) then {
        for "_i" from 0 to (count _arr)-1 do
        {
            _id   = _arr select _i;
            _item = d_player_array_misc select _id;
            _diff =  (_item select 3) - (_arr1 select _i); // new score minus old one
            _sum  = _sum + _diff;
            hint localize format[ "++++++ ""%1"": %2 (%3 per h.)", _item select 2, if ( _diff > 0 ) then { format["+%1", _diff] } else { _diff }, round(_diff  * 3600 / _time_diff)];
        };
    };
//    hint localize format["+++ [time, SYG_townScores select 2] %1", [time, SYG_townScores select 2]];
    _str =  [time, SYG_townScores select 2] call SYG_timeDiffToStr;
    hint localize format["++++++ Town ""%1"" players score summary: %2 (avg. %3, %4 per h.) during %5",
        _this,
        _sum,
        if(count _arr > 0) then {round (_sum / (count _arr))} else {0},
        round(_sum * 36000 / _time_diff)/10,
        _str
    ];
    hint localize "]";
};