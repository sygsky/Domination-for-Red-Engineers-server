// SYG_utilsMT.sqf : utils for MainTarget (town)
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

#define __EXTENDED_TOWN_RADIOUS_MAN__  800
#define __EXTENDED_TOWN_RADIOUS_VEHICLE__  200

if ( !isNil "SYG_mt_initialized" )exitWith { hint "--- SYG_utilsMT already initialized"};
SYG_mt_initialized = true;
//hint "INIT of SYG_utilsMT";

#ifdef __SIDE_MISSION_PER_MAIN_TARGET_COUNT__
//
// Detects if main target is able to be executed/started. Works on server and on client
//
// call:    [] call SYG_isMainTargetAllowed;
// returns: __mainAllowed = call SYG_isMainTargetAllowed
//
SYG_isMainTargetAllowed =  {
	private ["_target_counter"];
    _target_counter = if (isServer) then {current_counter} else {client_target_counter}; // main target counter
    if ( _target_counter <= 0 ) exitWith {true}; // Lets start in any way at the mission beginning
    if (current_mission_counter == 0) exitWith {true}; // No SM started
    // Here important formula to calculate main target allowance is  executed
    if ( floor ( (current_mission_counter - 1) * __SIDE_MISSION_PER_MAIN_TARGET_COUNT__) >= (_target_counter -1) ) exitWith {true}; // 1 side mission for 2 main targets must be finished!!!
    // hint localize format["false SYG_isMainTargetAllowed: _target_counter %1, current_mission_counter %2", _target_counter, current_mission_counter];
    false
};
#endif

//
// Detects if designated point[s] of object[s] are in main target boundaries (red circle on map)
// call as: _inMT = <[>_pnt|_obj|_location<,...]> call SYG_areObjsInMainTarget;
//
// if parameter is array, method returns true only if all array items (positions, objects, locations, groups) are in MT circle, else false
//
SYG_areObjsInMainTarget = {
	if(current_target_index < 0) exitWith {false};
	private ["_dummy","_mt_pos","_mt_rad","_res","_x"];
	_dummy = target_names select current_target_index;
    _mt_pos = _dummy select 0;
    _mt_rad = _dummy select 2;
    if (typeName _this != "ARRAY") then {_this = [_this]};
    if (count _this == 0) exitWith {false};
    _res = true;
    {
    	if(typeName _x != "ARRAY") then {
			if (typeName _x == "OBJECT") exitWith { _x = getPos _x };
			if (typeName _x == "LOCATION") exitWith {_x = locationPosition _x; };
			if (typeName _x == "GROUP") then {
				_x = getPos (_x call SYG_getLeader);
				_x = if (isNull _x) then {[]} else { getPos _x; };
			};
    	};
    	if (typeName _x != "ARRAY") exitWith { _res = false }; // unknown item can't be checked, abnormal exit
   		if (count _x < 2) exitWith {_res = false; };
		if (!([_x,_mt_pos, _mt_rad] call SYG_pointInCircle)) exitWith {_res = false}; // not in circle
    } forEach _this;
    _res
};

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
// [[_players],[_scores], _start_time, _main_target_count];
// _players = ["player1",...,"playerN"]; // list of players participated in current town
// _scores  = [1,...,N]; // scores of corresponding players
//
SYG_townScores = [[], [], time,  current_mission_counter max 1];

// Reset internal arrays with currently online players at the start of the next town
SYG_townScoresInit = {
    private ["_names"];
    SYG_townScores  = [ [], [], time, current_mission_counter max 1];
    _names = call SYG_getOnlineNames;
    _names call SYG_townScoresAdd;
    hint localize format["+++ SYG_townScoresInit: SYG_townScores = %1, SM counter %2", SYG_townScores, current_counter];
	call SYG_townStatClear; // reset real score stat system too
};

//
// Returns all active players names
//
SYG_getOnlineNames = {
	private ["_names","_x"];
    _names = [];
    {
        _x = call _x;
        if (isPlayer _x) then { _names set [count _names, name _x];   };
    } forEach SYG_players_arr;
	_names
};
//
// Call: [_player_name1,...,_player_name_N] call SYG_townScoresAdd;
// add each new player connected while town siege process
//
SYG_townScoresAdd = {
    private ["_id","_arr","_x"];
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
                _arr set [count _arr, (d_player_array_misc select _id) select 3]; // Store player initial score, from d_player_array_misc player_item: [[d_player_air_autokick, time, _name, 0, "", arg(1)]]
            };
        };
    }forEach _this;
    //hint localize format["+++ SYG_townScoresAdd result %1", SYG_townScores];
};

// Prints to arma_server.RPT all player scores got during this town liberation process
// call as: _town_name call SYG_townScoresPrint
SYG_townScoresPrint = {
    private ["_arr","_arr1","_sum", "_i","_id","_item","_diff","_str","_time_diff"];
    //hint localize format["++++++ Town ""%1"" personal players score:",_this];
    _arr  = SYG_townScores select 0;
    _arr1 = SYG_townScores select 1;
    hint localize "[";
    _str = (call SYG_getServerDate) call SYG_dateToStr;
    hint localize format[ "++++++ Town ""%1"" #%2 (%3 SM done) players score report at %4 ++++++", _this, current_counter, current_mission_counter - (SYG_townScores select 3), _str];

    _sum = 0;
    _time_diff = time - (SYG_townScores select 2);
    if (count _arr > 0) then {
        for "_i" from 0 to (count _arr)-1 do {
            _id   = _arr select _i;
            _item = d_player_array_misc select _id;
            _diff =  (_item select 3) - (_arr1 select _i); // new score minus old one
            if (_diff != 0) then {
                _sum  = _sum + _diff;
                hint localize format[ "++++++ ""%1"": %2 (%3 per h.)", _item select 2, if ( _diff > 0 ) then { format["+%1", _diff] } else { _diff }, round(_diff  * 3600 / _time_diff)];
            }
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
    // print real kills stat info too
	_this call SYG_townStatReport;
};

//
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
// Player statistics for main target: [bon,mt] : (any bonus score, mait target scores)
//

SYG_bonusScore = 0; // score added during current town period by mission bonus system, not by Arma itself
SYG_deathCount = 0; // how many death were counted during the town period
SYG_startTownScore = score player; // Total scores at the town start / player connection

// Reset all town stats values to the initial state (on client only)
// Called only on client computer
SYG_townStatInit = {
	SYG_bonusScore = 0;
	SYG_deathCount = 0;
	SYG_startTownScore = score player;
};

//
// Adds some special bonus score (town liberation, observer killed etc)  to player and store them in main target statistical array.
// Bonus scores may be negative (for non-engineer repairing, para-jump from base etc)
// _bonusScore = _addScore call SYG_addBonusScore;
//
SYG_addBonusScore = {
	if (_this == 0) exitWith {SYG_bonusScore};
	SYG_bonusScore = SYG_bonusScore + _this; // count next bonus score
	player addScore _this;					// add bonus score to player embeded score
	SYG_bonusScore
};

//
// _death_cnt = call SYG_incDeathCount; // adds negative scores on death
//
SYG_incDeathCount = {
	SYG_deathCount = SYG_deathCount + 1; // one more player death detected
	player addScore d_sub_kill_points;	 // assume death to the player
	SYG_deathCount
};

//
// Detects player to be in town radious plus 200 (__EXTENDED_TOWN_RADIOUS_MAN__) or 1000 (__EXTENDED_TOWN_RADIOUS_VEHICLE__) meters
// call as: _playerIsInTown = call SYG_playerIsAtTown;
//
SYG_playerIsAtTown = {
	if( current_target_index < 0 ) exitWith { false };
	private [ "_dummy" ];
	_dummy = target_names select current_target_index;
	if (vehicle player == player) exitWith { // One distance for man, other for vehicle
        [player, _dummy select 0, (_dummy select 2) + __EXTENDED_TOWN_RADIOUS_MAN__ ] call SYG_pointInCircle // For man	out of vehicle
	};
	[player, _dummy select 0, (_dummy select 2) + __EXTENDED_TOWN_RADIOUS_VEHICLE__ ] call SYG_pointInCircle // For man in vehicle
};

//
// Array to store score per town for each player participating in town liberation
//
// Each item is: _kills, that is player kill count (how many times player killed enemy by any means)

SYG_townStat = []; // array for all players stat (on server only)

// reset whole stat arrays for the next town on server (on server only)
// call as: call SYG_townStatClear;
SYG_townStatClear = {
	SYG_townStat resize 0;
};

//
// Checks if designated player Id exists in the array. If id not existed its item is initialized to zero (0)
// id MUST be >= 0!!!
// call as: _val = _id call SYG_townStatCheck;
// returns: score value at designated item index, if item is created on this call zero(0) is returned
//
SYG_townStatCheck = {
	//hint localize format["--- SYG_townStatCheck: _this = %1", _this];
	if ( (count SYG_townStat) <= _this ) exitWith { _x = 0; SYG_townStat set[_this, _x]; _x  };
	_x = SYG_townStat select _this;
	if (isNil "_x") then {_x = 0; SYG_townStat set[_this, _x]};
	_x
};

//
// Adds kills value for the player. If value not exists it is created
// call as: [ _player_id, _player_town_kills ] call SYG_townStatItemUpdate;
//
SYG_townStatItemUpdate = {
	_x = (_this select 0) call SYG_townStatCheck; // Lets to guarantee the presence of an array element
	SYG_townStat set [_this select 0, _x + (_this select 1)]
};

//
// Print town stat on serevr log, assign town liberation bonus score to all players (active and not active)
// call as: "Paraiso" call SYG_townStatReport;
// Returns: none, print town statistics into arma.rpt
//
// Resulted print will be as follows:
//
// ++++++ Town "Paraiso" #1 real kills report, 22.05.2025 22:21:15 ++++++
// ++++++              name,  kills,   state
// ++++++            "yeti":    193, offline
// ++++++       "ihatelife":     28, offline
// ++++++      "Rokse [LT]":     43,  online
// ++++++ Town "Paraiso" real players kills summary: 264, avg. 88, dur. 43:25:46
//
SYG_townStatReport = {
    private ["_arr","_arr1","_sum", "_id","_kills","_kills_sum","_num","_onlineNames","_name"];
    //hint localize format["++++++ Town ""%1"" personal players score:",_this];
    hint localize "[";
    hint localize format[ "++++++ Town ""%1"" #%2 real kills report, %3 ++++++",
    	_this,
    	current_counter,
    	(call SYG_getServerDate) call SYG_dateToStr // Real server time, e.g. 2023 year, not Arma misson internal one, e.g. 1985 year
    ];
    _kills_sum = 0;
    _num = 0;
   	_onlineNames = call SYG_getOnlineNames; // all active player names (to print their stats)
	hint localize  "++++++              name,  kills,   state";
	for "_id" from 0 to (count SYG_townStat)-1 do {
		_kills = SYG_townStat select _id; //
		if (!isNil "_kills") then {
			if (_kills <= 0) exitWith{}; // no kills at all
			_name = d_player_array_names select _id;
			// print true kills (calculated from total-bonus+dead), dead сount, bonus score, total score accumulated
			hint localize format[ "++++++ %1: %2,%3",
					[17, format["""%1""",d_player_array_names select _id]] call SYG_textAlign,  // Player name
					[6, str(_kills)] call SYG_textAlign,										// In game kill count (as in Arma itself)
					if ( _name in _onlineNames ) then { "  online" } else { " offline" }		// Status in game (online/offline)
				];
			_kills_sum = _kills_sum + _kills;
			_num = _num + 1;
		};
	};
//    hint localize format["+++ [time, SYG_townScores select 2] %1", [time, SYG_townScores select 2]];
    hint localize format["++++++ Town ""%1"" real players kills summary: %2, avg. %3, dur. %4",
        _this,
        _kills_sum,
        if (_num == 0) then {"0"} else {(round( _kills_sum / _num * 10)) / 10 },
        [time, SYG_townScores select 2] call SYG_timeDiffToStr // Duration of existence of the Main Target
    ];
    hint localize "]";

};

//
// Calculates all players scores for town. Runs only on server
//
// call as:
// _bonus_score_arr = call SYG_townStatCalcScores;
//
// Returns: [_in_town_player_name_arr, _in_town_player_score_arr]
//
SYG_townStatCalcScores = {
    if (count SYG_townStat == 0) exitWith {
    	hint localize "--- SYG_townStatCalcScores: count SYG_townStat == 0 !!!";
    	[[],[]]
    };
    private [ "_id","_name_arr","_kill_arr","_kills","_max"];
	_name_arr = [];
	_kill_arr = [];
	// 1. find max score
	_max = -1;
	for "_id" from 0 to (count SYG_townStat)-1 do {
		_kills = SYG_townStat select _id;
		if (!isNil "_kills") then { 		// valid kills number, add to the result set
			if (_kills <= 0 ) exitWith{};	// no real kills
			// send to player client later
			_name_arr set [count _name_arr, d_player_array_names select _id]; // [name1,name2...]
			_kill_arr set [count _kill_arr, _kills];
			_max = _max max _kills; // Find max value
		};
	};
	if ( count _kill_arr > 0 ) then { // play with scores, set relative values
		for "_id" from 0 to count _kill_arr - 1 do {
			_kill_arr set [_id, (_kill_arr select _id ) / _max ]; // [score_coeff1, score_coeff2 ...]
		};
	} else {
    	hint localize "--- SYG_townStatCalcScores: count _kill_arr == 0 !!!";
	};
	[ _name_arr, _kill_arr ]
};

// Called only on client:
// call as: _info_arr = [_names_arr, _bonus_coeffs_arr] call SYG_mainTownBonusInfoStr;
// where _info_arr: [_best_players_info, _worst_player_info]
//
SYG_mainTownBonusInfoStr = {
	if(!X_Client) exitWith {["--- SYG_mainTownBonusInfoStr: expected to be called on the server", "--- SYG_mainTownBonusInfoStr: expected to be called on the server"]};
	private ["_names","_coeffs","_max_town_bonus","_min","_max","_i","_bonus","_best_str","_worst_str"];
	_names  = _this select  0;
	_coeffs = _this select 1;
	_max_town_bonus = (d_ranked_a select 9);
	_min = 100000;
	_max = 0;
	for "_i" from 0 to (count _names - 1) do {
		_bonus = round ((_coeffs select _i) * _max_town_bonus);
		if ( _bonus  < _min ) then { _min = _bonus};
		if ( _bonus  > _max ) then { _max = _bonus};
	};
	_best_str = "";
	_worst_str = "";
	for "_i" from 0 to (count (_arr select 0) - 1) do {
		_bonus = round ((_coeffs select _i) * _max_town_bonus);
		if (_bonus == _max) then {  _best_str = format["%1%2""%3"":%4", _best_str, if (_best_str == "") then {""} else {","},_names select _i, _bonus ] } else  {
			if (_bonus == _min) then { _worst_str = format["%1%2""%3"":%4", _worst_str, if (_worst_str == "") then {""} else {","},_names select _i, _bonus ] };
		};
	};
	if (_worst_str == "") exitWith {
		[format[localize "STR_SYS_MTBONUS_MAX", _best_str], localize "STR_SYS_MTBONUS_NOMIN"];
	};
	[format[localize "STR_SYS_MTBONUS_MAX", _best_str], format[localize "STR_SYS_MTBONUS_MIN", _worst_str]]
};


// EOF