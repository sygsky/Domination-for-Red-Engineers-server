/**
 *
 * SYG_utilsGeo.sqf : utils for geography functions
 *
 */
#include "x_setup.sqf"
#include "x_macros.sqf"
#include "GRU_setup.sqf"

#define inc(x) (x=x+1)
#define arg(x) (_this select(x))
#define argp(a,x) ((a)select(x))

#define argopt(num,val) (if((count _this)<=(num))then{val}else{arg(num)})
#define argoptskip(num,defval,skipval) (if((count _this)<=(num))then{defval}else{if(arg(num)==(skipval))then{defval}else{arg(num)}})

if ( isNil "SYG_UTILS_GEO_COMPILED" ) then 	{ // generate some static information
	SYG_UTILS_GEO_COMPILED = true;

#ifdef __DEFAULT__

	SYG_Sahrani_p0 = [13231.3,8890.26,0]; // City Corazol center
	SYG_Sahrani_p1 = [14878.6,7736.74,0]; // Vector dividing island to 2 parts (North and South) begininig, point p1
	SYG_Sahrani_p2 = [5264.39,16398.1,0]; // Vector dividing island to 2 parts (North and South) end, point p2
	SYG_Sahrani_desert_max_Y = 7890; // max Y coordinates for desert region of Sahrani
	SYG_Sahrani_desert_rects = // rectangles containing all desert lands
	[
	    [   [9529,  4390,0], 10000, 3500,   0 ], // South from Somato
	    [   [17551,18732,0],  1200, 1200,   0 ], // Antigua area
	    [   [7873,  9107,0],  2000,  500, 315 ] // Ambergris (on coast west from Chantico)
    ];
	//*** *** *** *** *** *** *** ***
	//*** Coordinates of circles with island of Sahrani in circumstances ***
	//*** ["Name",[cx,cy,cz],rad, "Text"] ***
	SYG_SahraniIsletCircles = [
		["isle1",[12322.5,10609.7,0],600,"острова в заливе Abra de Boca"],	// 0
		["isle2",[14005.7,8008.81,0],220,"Islas Gatunas"],	// 1
		["isle3",[17485.8,4014.21,0],1550,"Юго-восточные острова (Asharah)"],	// 2
		["isle4",[17368.9,18636.7,0],1300,"Северо-восточные острова (Антигуа)"],	// 3  Antigua
		["isle5",[7805.58,14350.3,0],400,"Trelobada"],	// 4
		["isle6",[5134.54,15489.3,0],1000,"Isla de Vassal 1"],	// 5
		["isle7",[1984.43,17968.6,0],1100,"Isla de Vassal 2"],	// 6
		["isle8",[10750.9,16758.9,0],200,"Isla des Compadres"],	// 7
		["isle9",[9497.47,3472.44,0],500,"San Tomas"],	// 8
//		["isle10",[2478.14,2597.8,0],1500,"Rahmadi"],	// 9 rAhmadi is separated islet parsed in other arrays
		["isle11",[11630.1,16942.4,0],50,"полуостров в заливе Porto de Perolas"],	// 10
		["isle12",[11794,11433.1,0],200,"островки на юго-западном побережье Северного Сахрани, залив Абра да Бока"],	// 11
		["isle13",[13723.7,8307.14,0],130,"Islas Gatunas"]	// 12
	];

	SYG_RahmadiIslet = ["isle10",[2478.14,2597.8,0],1500,"Rahmadi"];

    SYG_chasmArray = [
        [[14269,10545,0],70,[13919,10632,0], "Obregan"],
        [[11725,15467,0],70,[11371,14877,0], "Pesados"]
    ];

#endif

};	

//
// Checks if pos of vehicle is in one of chasm (no exit by BIS algorithm)
// if found that chasm wayout waypoit is returned
// if not in chasm, empty array is returned
//  call:
//  _newWP = (getPos _vehicle) call SYG_chasmExitWP;
//  if ( count _newWP == 3) then {_vehicle addWP _newWP};
//
SYG_chasmExitWP = {
    private ["_ret","_center","_radious","_x","_this"];
   _ret = [];
#ifdef __DEFAULT__
    _this = _this call SYG_getPos;
   	if (_this select 0 == 0 && _this select 1 == 0) exitWith { [] }; // Error to get position
    {
        _center = _x select 0;
        _radious = _x select 1;
        if ([_this, _center, _radious] call SYG_pointInCircle) exitWith {
            // yes, in circle
            _ret = _x select 2;
        };
    } forEach SYG_chasmArray;
#endif
    _ret
};

/**
 * Finds designated location type nearest to the designated point within designated radious
 * Call:
 *     _ret = [<getPos >player,["Name","NameCity","NameCityCapital","NameVillage","NameLocal"...], 1000] call SYG_nearestLocation;
 * returns:
 *      location : nearest location of designated settlement types
 * to get position of location, call _pos = position _loc;
 * to get text of location call _text = text  _loc;
 * if no such location found, returns locationNull
 */
SYG_nearestLocationD = {
    if ( (count _this) < 3 ) exitWith {locationNull};
	private ["_loc"];
	_loc = [arg(0),arg(1)] call SYG_nearestLocationA;
	if ( ( (position _loc) distance (_this select 0)) <= (_this select 2) )  exitWith { _loc };
	locationNull
};

/**
 * Finds nearest to the designated point location from designated location type list
 * Possible calls form:
 *     _ret = [player, _locTypeList] call SYG_nearestLocationA;
 *     _ret = [(getPos player), _locTypeList] call SYG_nearestLocationA;
 *     _ret = [_group, _locTypeList] call SYG_nearestLocationA;
 *     _ret = [_location, _locTypeList] call SYG_nearestLocationA;
 * returns:
 *      location : nearest location with designated in _locTypeList names or
 *      locationNull if bad parameters used or  empty list is designated
 *
 * to get position of location, call: _pos = position _loc;
 * to text of location call: _text = text  _loc;
 */
SYG_nearestLocationA = {
	private ["_pos","_dist","_nearloc", "_loc","_lst","_ploc","_x"];
	_pos = (_this select 0) call SYG_getPos;
	if (count _pos > 2) then {
		if (((_pos select 0) == 0) && ((_pos select 1) == 0)) then { _pos resize 0 };
	};
/*
	switch (typeName _pos) do {
		case "OBJECT": {_pos = position _pos;};
		case "LOCATION": {_pos = locationPosition _pos;};
		case "ARRAY": {};
		case "GROUP": { _pos = if ( isNull leader _pos) then {[0,0,0]} else {position leader _pos};};
		default {_pos = []};
	};
*/
	if (count _pos < 2) exitWith {locationNull};
	_lst = _this select 1;
	switch (typeName _lst) do {
		case "STRING": {_lst = [_lst];};
		case "ARRAY": {/* correct */};
		default {/* error */};
	};
	
	_dist = 9999999.9;
	_nearloc = locationNull; // default value
	{
		_loc = nearestLocation [_pos, _x];
		_ploc = locationPosition _loc;
		if ( (_pos distance _ploc) < _dist ) then {
			_dist = _pos distance _ploc;
			_nearloc = _loc;
		};
	} forEach _lst; // search for any listed locations
	_nearloc
};

/**
 * Text name of location found with call to SYG_nearestLocation
 */
SYG_nearestLocationName = {text (_this call SYG_nearestLocation)};

/**
 * Call:
 *     _ret = getPos player call SYG_nearestLocation;
 *     //     or
 *     _ret = player call SYG_nearestLocation;
 * returns:
 *      location : nearest map well known name
 * to get position of location, call _pos = position _loc;
 * to text of location call _text = text  _loc;
 */
SYG_nearestLocation = {
	[_this, ["NameCity","NameCityCapital","NameVillage","NameLocal","NameMarine","Hill"]] call SYG_nearestLocationA
};

/**
 * Call:
 *     _ret = getPos player call SYG_nearestSettlement;
 *     //     or 
 *     _ret = player call SYG_nearestSettlement;
 * returns:
 *      location : nearest settlement 
 * to get position of location, call _pos = position _loc;
 * to text of location call _text = text  _loc;
 */
SYG_nearestSettlement = {
	[_this, ["NameCity","NameCityCapital","NameVillage"]] call SYG_nearestLocationA
};

//
// Returns nearest settlement name
// Call: _settlement_name = player call SYG_nearestSettlementName;
SYG_nearestSettlementName = {text (_this call nearestSettlement)};
//
// Finds MT item array by target name (case sensitive). Call as follow:
// _mt_item = "Rahmadi" call SYG_MTByName; // [[2826,2891,0],   "Rahmadi"   ,180, 22, ["detected_Rahmadi"]] or [] if error name used e.g. "rahmado"
//
SYG_MTByName = {
	if (typeName _this != "STRING") exitWith {hint localize format["--- SYG_MTByName: illegal _this = %1", _this];[]};
	private ["_i","_id","_pos","_mt"];
	_id  = -1;
	_pos = [];
	for "_i" from 0 to ( ( count target_names ) - 1 ) do {
		_mt = target_names select _i;
		if ( ( _mt select 1 ) == _this ) exitWith { // name detected
			_id  = _i;	// index in list
			_pos = _mt select 0; // position
		};
	};
	if (_id < 0) exitWith {[]};
	target_names select _id
};
//
// Finds MT center nearest to the designated one. E.g. find near MT to Rahmadi:
// _near_MT_arr = "Rahmadi" call SYG_nearestMainTarget;
// 	...
// [[2826,2891,0],   "Rahmadi"   ,180, 22, ["detected_Rahmadi"]] // 20
// ...
// Returns: target_names item array (see above) if found or [] if not found.
//
SYG_nearestMainTarget = {
	private ["_i","_id","_pos","_mt","_min_dist","_min_id","_dist"];
	_min_dist = 999999.0; // initial distance
	_min_id = -1;
	if ( (typeName _this) == "ARRAY") exitWith {
		// input is point, not name, so find any main target nearest to the designated point
		_pos = +_this;
		_pos set [2,0];
		for "_i" from 0 to ( ( count target_names ) - 1 ) do {
			_dist = _pos distance ((target_names select _i) select 0);
			if (_dist < _min_dist) then {
				_min_dist = _dist;
				_min_id   = _i;
			};
		};
		target_names select _min_id // returns minimal distance item from main targets list
	};
	_mt = _this call SYG_MTByName;
	if (count _mt == 0) exitWith {[]};
	// find designated target
	_id  = _mt select 3;  // id of designated town
	_pos = +(_mt select 0);  // position
	_pos set [2,0];
	// find nearest to designated target
	for "_i" from 0 to ( ( count target_names ) - 1 ) do {
		_mt = target_names select _i;
		if ( (_mt select 3) != _id ) then { // skip MT, designated by name, from search procedure
			_dist = ( _mt select 0 ) distance _pos;
			if ( _dist < _min_dist ) then {
				_min_id   = _i;
				_min_dist = _dist;
			}
		};
	};
	if ( _min_id <= 0 ) exitWith {[]};
	target_names select _min_id
};

/**
 * Finds nearest forest of any type
 * Call:
 *     _ret = getPos player call SYG_nearestForest;
 *     //     or 
 *     _ret = player call SYG_nearestSettlement;
 * returns:
 *      location : nearest good enough forest
 * to get position of location, call _pos = position _loc;
 * to text of location call _text = text  _loc;
 */
SYG_nearestForest = {
	[_this, ["VegetationBroadleaf","VegetationFir","VegetationPalm"]] call SYG_nearestLocationA
};

/**
 * Zone can be as follows:
 * 1. Main target town
 * 2. Occupied town
 * 3. Airbase
 * 4. Secondary target point
 * 5. Geographic location on map (village, town, city, some natural zone names etc)
 *
 * call: _pos_arr= [_pos,_same_island_part,_wanted_zones_list<,_max_dist>] call SYG_nearestZoneOfInterest;
 *
 * Where:
 *  _pos: position or object to search proximity for
 *  _same_island_part: boolean, if TRUE only zones on the same Sahrani part will be used else zones on both parts will be seeked
 *	designated_zones: array of follow string for requested war zone types
 *                a) - main target town (if assigned) "MAIN"
 *                b) - occupied town (if any occupied) "OCCUPIED"
 *                с) - airbase (if there is some desant on it) "AIRBASE"
 *                d) - sidemission target (if not on Rahmadi) "SIDEMISSION"
 *                e) - location "LOCATION", including "NameCity","NameCityCapital","NameVillage","NameLocal"
 *                f) - settlement "SETTLEMENT", including "NameCity","NameCityCapital","NameVillage"
 * _max_dist    : maximum distance to the designated position, optional, default is 999999.9 meters (all the Arma universe)
 *
 * E.g.: _res_arr = [getPos player, false,["MAIN","OCCUPIED","AIRBASE","SIDEMISSION","LOCATION","SETTLEMENT"],1000] call SYG_nearestZoneOfInterest;
 *
 * Returns: array of 
 *  [ [_posMain,_posOccupied,_posAirbase,_posLocation, ...etc], _nearestIndex]
 *	with 1st array of same size as input one containing corresponding positions of zones found, where [] means of no value,
 *  and 2nd item (_nearestIndex) stand for index in original array with shortest distance to the closest zone type. 
 *  _nearestIndex -1 means NO any zone found. It is possible when you search only for ["MAIN"<,"SIDEMISSION"<,"OCCUPIED">>] at start
 *  or end of game or in very-very rare moments between main/secondary/occupied mission is finshed and still not started
 */
SYG_nearestZoneOfInterest = {
	private ["_dist","_dist1","_min_dist","_wanted_dist","_reta","_pos","_pos1","_pos2","_ret","_part","_part1","_same_part","_opt","_opts","_x"];
	
	_pos          = arg(0); // unit/object/vehicle pos
	_same_part    = arg(1); // find only on same part of island if true
	_opts         = arg(2); // what kind of zones to search
	_wanted_dist  = argopt(3,999999.9); // max distance to find for zone
	_ind = -1;
	_reta = [];
	
//	hint localize format[ "SYG_nearestZoneOfInterest: pos %1, same %2, opts %3, dist %4", _pos, _same_part, _opts, _wanted_dist];
	
	if ( count _opts > 0 ) then {
		if ( typeName _pos != "ARRAY" ) then { _pos = position _pos;};
		_part = _pos call SYG_whatPartOfIsland; // island part (upper/lower or Nothern/Southern) for designated point
		if ( _same_part ) then { // check need for the same part
			if ( _part == "CENTER" ) then {_same_part = false;}; // doesn't matter where is situated tested point according to the Corazol city
		};
		
		_min_dist = 9999999.9;
		for "_i" from 0 to (count _opts) - 1  do {
			_opt  = toUpper (_opts select _i);
			_dist = -1;
			_pos1 = [];
			switch _opt do {
				case "MAIN": {
					_ret = call SYG_getTargetTown; // returs some about [[9348.73,5893.4,0],"Cayo", 210]
					if ( count _ret > 0 ) then {
						_pos1  = _ret select 0;
						_part1 = _pos1 call SYG_whatPartOfIsland;
						if ( (!_same_part) || (_part1 == "CENTER") || (_part1 == _part)) then {
							_dist = _pos distance (_ret select 0);
						};
					};
				};
				case "AIRBASE": {
					if ( !isNil "FLAG_BASE" ) then {
						_pos1  = position FLAG_BASE;
						_part1 = _pos1 call SYG_whatPartOfIsland;
//						hint localize format[ "SYG_nearestZoneOfInterest: same part %1, _pos1 %2, _pos %3, dist %4", _same_part, _pos1, _pos, round(_pos1 distance _pos) ];
						if ( (!_same_part) || (_part1 == "CENTER") || (_part1 == _part) ) then {
							_dist =  _pos1 distance _pos;
						};
					};
				};
				case "LOCATION":  {
					_pos1  = _pos call SYG_nearestLocation; // location returned!!!
					_part1 = _pos1 call SYG_whatPartOfIsland;
					if ( (!_same_part) || (_part1 == "CENTER") || (_part1 == _part)) then {
						_dist =  _pos distance _pos1;
					};
				};
				case "SETTLEMENT":  {
					_pos1 = _pos call SYG_nearestSettlement; // settlement returned!!!
					_part1 = _pos1 call SYG_whatPartOfIsland;
					if ( (!_same_part) || (_part1 == "CENTER") || (_part1 == _part)) then {
						_dist = _pos distance _pos1;
					};
				};
				case "OCCUPIED": {
					if ( isServer ) then {
						_pos2 = [];
						{
							_ret = target_names select _x; //  e.g. [[9348.73,5893.4,0],"Cayo", 210],
							_pos1 = _ret select 0;
							_part1 = _pos1 call SYG_whatPartOfIsland;
							if ( (!_same_part) || (_part1 == "CENTER") || (_part1 == _part)) then {
								_dist1 = _pos1 distance _pos;
								if ( (_dist1 < _dist) || (_dist < 0)) then { _dist = _dist1; _pos2 = _pos1;};
							};
						} forEach d_recapture_indices;
						_pos1 = _pos2;
					};
				};
				case "SIDEMISSION": {
					if (!all_sm_res && !stop_sm && !side_mission_resolved && (current_mission_index >= 0)) then {
						if ( !(current_mission_index in nonstatic_sm_array) ) then {  // don't use non-static sidemissions (convoys, pilots etc)
							_pos1 = x_sm_pos select 0;
							if (!((_pos1 call SYG_pointOnIslet) || (_pos1 call SYG_pointOnRahmadi))) then { // filter out any islet missions
								_part1 = _pos1 call SYG_whatPartOfIsland;
								if ((!_same_part) || (_part1 == "CENTER") || (_part1 == _part)) then { // it is possible to reach from designated point
									// check if mission is on any of islets
									_dist = _pos distance _pos1;
								};
							};
						};
					};
				};
			};
			if ( _dist <= _wanted_dist ) then { // found zone is in wanted range
			    if ( (_dist < _min_dist)  && (_dist >= 0) ) then { _min_dist = _dist; _ind = _i }; // detect zone with minimum distance
			};
  			_reta set [_i, _pos1]; // always set position value, doesnt matter is it detected or not
		};
	};
	[_reta,_ind]
};
 
/**
 * call:
 *    _part = _getPos player call SYG_whatPartOfIsland; // "NORTH", "SOUTH", "CENTER" for Corazol area
 */
SYG_whatPartOfIsland = {
	private ["_pos","_res"];
	_pos = _this call SYG_getPos;
	if ( (_pos select 0) == 0 ) exitWith { "<ERROR DETECTED>" };
	_res = _pos distance SYG_Sahrani_p0;
	if ( _res < 500 ) exitWith {"CENTER"};
	_res = [SYG_Sahrani_p1,SYG_Sahrani_p2,_pos] call SYG_pointToVectorRel; // vector comes approximately from S-E to N-W through Corazol
	if (_res >= 0) then {"NORTH"} else {"SOUTH"}
};

/**
 * Decides if point is in desert region or no
 * call:
 *    _amIInDesert = _getPos player call SYG_isDesert; // TRUE or FALSE
 */
SYG_isDesert = {
	private ["_pos","_ret","_x"];
	_pos = _this call SYG_getPos;
	if (  (_pos select 0) == 0 ) exitWith {false};
	// this is a max Y coordinate of desert region on Sahrani (by my estimation)
	//argp(_pos,1) < SYG_Sahrani_desert_max_Y
	_ret = false;
    { if ([_pos,_x] call SYG_pointInRect) exitWith {_ret = true};  } forEach SYG_Sahrani_desert_rects;
    _ret
};

/**
 * Detects if point is on any of small islet, not on main Island Sahrani and not on Rahmadi isles group
 * call:
 *    _bool = (getPos player) call SYG_pointOnIslet; // true or false is returned
 */
SYG_pointOnIslet = {
	(_this call SYG_isleAtPoint) != ""
};

//
// Returns islet containing designated point
// _islet = _pnt call SYG_isleAtPoint; // Returns "" if point not in some islet circle, else name (e.g. "острова в заливе Abra de Boca")
//
SYG_isleAtPoint = {
	private ["_ret","_pos","_x"];
	_pos = _this call SYG_getPos;
	_ret = "";
	if ( _pos select 0 == 0 ) exitWith { _ret }; // point not found
	{
		if ([_this,_x select 1, _x select 2] call SYG_pointInCircle) exitWith {_ret = _x select 3;}; // name of islet of point
	} forEach SYG_SahraniIsletCircles;
	_ret
};

/**
 * Detects if point is on Rahmadi isles group, not on main Island Sahrani
 * call:
 *    _bool = (getPos player) call SYG_pointOnRahmadi; // true or false is returned
 */
SYG_pointOnRahmadi = {
	_this = _this call SYG_getPos;
	[ _this call SYG_getPos, SYG_RahmadiIslet select 1, SYG_RahmadiIslet select 2 ] call SYG_pointInCircle
};

/**
 * Detects if point is on Rahmadi isles group, not on main Island Sahrani
 * call:
 *    _bool = (getPos player) call SYG_pointOnRahmadi; // true or false is returned
 */
SYG_pointOnAntigua = {
	private ["_isle","_pos"];
	_isle = SYG_SahraniIsletCircles select 3;
	_pos = _this call SYG_getPos;
	hint localize format["+++ SYG_pointOnAntigua: isle %1, typeOf _this = %2, _pos %3", _isle, typeOf _this, str(_pos) ];
	[ _pos, _isle select 1, _isle select 2 ] call SYG_pointInCircle
};

/*
 * Detects if point is in base circumstances (near area is designated by predefined rectange)
 * Real base rectangle is as follows: [[9821.47,9971.04,0], 600, 200, 0];
 * call:
 * _bool = (_pos || _obj) call SYG_pointNearBase
 */
SYG_pointNearBase = {
    if (typeName _this == "OBJECT") then {_this = position _this};
	if (count _this < 2) exitWith {false};
    [_this, [[9913,10385,0],1300,800]] call SYG_pointInRect // only for Sahrani island
};

/**
 * call: 
 *   _reta =  call SYG_getTargetTown;
 * Where:
 *   _reta is _target_array (e.g. [[9348.73,5893.4,0],"Cayo", 210] ) or empty array ([]) if target not available
 * if call: _reta = "NO_DEBUG" call SYG_getTargetTown; // then no info about target town absence is printed to arma.rpt file
 */
SYG_getTargetTown = {
	private [ "_ret","_cur_cnt","_print" ];
	_ret = [];
	// target_clear == false if town still not liberated and still occupied
	_cur_cnt = if ( isServer ) then {current_counter} else {client_target_counter};
	if ( (_cur_cnt <= number_targets) && (!target_clear) && (current_target_index >=0)) then {
		_ret = target_names select current_target_index; //  e.g. [[9348.73,5893.4,0],"Cayo", 210],
	} else {
	    _print = false;
	    if ( format["%1",_this] == "<null>") then { _print = true};
	    if (!_print ) then {if (typeName _this != "STRING") then {_print = true}};
	    if (!_print ) then {if (_this != "NO_DEBUG") then {_print = true}};
	    if ( _print) then {
    		hint localize format["--- error in SYG_getTargetTown: time=%3,c_c=%1,c_c2=%5,t_c=%2,c_t_i=%4",_cur_cnt, target_clear, call SYG_nowTimeToStr,current_target_index,current_counter];
	    };
	};
	_ret
};

//
// call:
//   _tgtname = call SYG_getTargetTownName;
// returns: found town name or "<not defined>" if not
//
SYG_getTargetTownName = {
	private [ "_ret" ];
	_ret = "NO_DEBUG" call SYG_getTargetTown;
	if (count _ret == 0 ) then {"<not defined>"} else { _ret select 1};
};

//
// Returns additional town descriptive array, if available, else return empty [] array
//
// call: _additionalArray = call SYG_getTargetTown; // [[9349,5893,0],   "Cayo"      ,210, 2, ["detected_Cayo"]]
//
SYG_getTargetTownAddArray = {
    private ["_arr"];
    _arr = "NO_DEBUG" call SYG_getTargetTown; // gets town main info array
    if (count _arr <= 4) exitWith {[]};       // no additional array or no town are defined
    _arr select 4
};

/*
 * Returns sound name for town detection. If no sound defined empty string "" is returned
 *
 */
SYG_getTargetTownDetectedSound = {
    private ["_item"];
    _item = call SYG_getTargetTownAddArray; // gets town additional array
    if (typeName _item == "STRING") exitWith {_item};   // sound is designated, not array
    if (typeName _item == "ARRAY") exitWith {
        if ( count _item == 0) exitWith {""};   // no array - no sound
		_item = _item call XfRandomArrayVal; // get array random item
		if (typeName _item == "STRING") exitWith {_item}; // item is string, return as sound name
        "" // array with not strings as sound name
    };
    "" // sound not detected
};

/**
 * TODO: the method is not used anywhere, use it please!
 * Returns index for current side mission on the server. If no mission is available, -1 is returned;
 * call:
 *      _smindex = call SYG_getSideMissionIndex;
 */
SYG_getSideMissionIndex = {
	if (!all_sm_res && !stop_sm && !side_mission_resolved && (current_mission_index >= 0)) then {current_mission_index} else {-1};
};

//==================================
// read marker info struct as follows: [center_point,a,b,angle,type]
// where center_point is: [x,y,z]
//       a - axis on X
//       b - axis on Y
//       angle - rotation in right system (from X axis to clockwise)
//       type for marker is one of Arma's ones - "RECTANGLE", "ELLIPSE" or "ICON"
//
// call: _descr = ["marker_name",SHAPE] call SYG_readMarkerInfo; // SHAPE is of follow types: "RECTANGLE,"ELLIPSE"
// 
// if marker not exists or bad parameter designated, empty array returned: []
//
SYG_readMarkerInfo = {
	private ["_shape","_size","_name"];
	_shape = toUpper(_this select 1);
	if ( !(_shape in ["ELLIPSE","RECTANGLE"]) ) exitWith {[]};
	_name = arg(0);
	if ( markerType _name == "" ) exitWith {[]};
	_size = markerSize _name;
	[markerPos _name, argp(_size,0),argp(_size,1),markerDir _name,_shape]
};

/**
 * Detects if a designated point is in a designated marker of any form
 *
 * call:
 *      _bool = [pnt,[center_point,  width,height,angle,"RECTANGLE"]] call SYG_pointInMarker;
 *      _bool = [pnt,[center_point,  width,height,angle,"ELLIPSE"  ]] call SYG_pointInMarker;
 *      _bool = [pnt,[center_point,radious,     0,    0,"CIRCLE"   ]] call SYG_pointInMarker;
 *      _bool = [pnt,[center_point,radious                         ]] call SYG_pointInMarker; // for circles
 *      _bool = [pnt,[center_point,  width,height,angle            ]] call SYG_pointInMarker; // for rectangle
 *      _bool = [pnt,[center_point,  width,height                  ]] call SYG_pointInMarker; // for rectangle withno rotation
 *      _bool = [pnt,marker_name,shape] call SYG_pointInMarker; // shape is "CIRCLE" or "ELLIPSE" or "RECTANGLE"
 * note: angle is counted clockwise from 0 of Dekart x-axis. So it is -angle in real
 */
SYG_pointInMarker = {
	private ["_pnt","_mrk","_ret"];
	_mrk = arg(1);
	switch typeName _mrk do {
		case "ARRAY": { // marker description array (by Xeno, 4 params for rectangle, 2 - for circle)
			switch  count _mrk do {
				//hint localize format["Marker for circle ""%1"" converted to a form [center,w,h,angle]",_mrk];
				case 2: {_mrk = [argp(_mrk,0), argp(_mrk,1),0,0,"CIRCLE"];};
				case 3: {_mrk = [argp(_mrk,0), argp(_mrk,1),argp(_mrk,2),0,"RECTANGLE"];}; // rectangle withno rotation
				case 4: {_mrk = [argp(_mrk,0), argp(_mrk,1),argp(_mrk,2),argp(_mrk,3),"RECTANGLE"];};
			};
		};
		case "STRING": { // marker name, convert to Xeno array
			//hint localize format["Marker ""%1"" converted to a form [center,w,h,angle]",_mrk];
			_mrk = [_mrk,arg(2)] call SYG_readMarkerInfo;
			//hint localize format["+++ SYG_pointInMarker: %1",_mrk];
		};
	};
	_pnt = arg(0);
	_ret = false;
	switch argp(_mrk,4) do {
		case "CIRCLE": {
			_ret = [_pnt, argp(_mrk,0),argp(_mrk,1)] call SYG_pointInCircle;
		};
		case "ELLIPSE": {
			_ret = [_pnt, _mrk] call SYG_pointInEllipse;
		};
		case "RECTANGLE": {
			_ret = [_pnt, _mrk] call SYG_pointInRect;
		};
	};
	_ret
};

// west names
SYG_gendirlistW = ["N","N-NE","NE","E-NE","E","E-SE","SE","S-SE","S","S-SW","SW","W-SW","W","W-NW","NW","N-NW","N"];
// east names
SYG_gendirlistE = ["C","С-СВ","СВ","В-СВ","В","В-ЮВ","ЮВ","В-ЮВ","Ю","Ю-ЮВ","ЮЗ","З-ЮЗ","З","З-СЗ","СЗ","С-СЗ","С"];
// call: _dirname = _dir call SYG_getDirName;
SYG_getDirName = {
//	hint localize format["SYG_getDirName: this %1", _this];
	_this  = _this mod 360;
	if ( _this < 0 ) then {_this = _this + 360;};
	switch localize "STR_LANG" do {
		case "RUSSIAN": { SYG_gendirlistE select (round (_this/22.5))};
		case "ENGLISH";
		case "GERMAN";
		default { SYG_gendirlistW select (round (_this/22.5))};
	};
};

SYG_getDirNameEng = {
//	hint localize format["SYG_getDirNameEng: this %1", _this];
		_this  = _this mod 360;
	if ( _this < 0 ) then {_this = _this + 360;};
	SYG_gendirlistW select (round (_this/22.5))
};


// Ids of houses GRU can use as computer link center, 82124 is house near airfield and base building
SYG_intelHouseIds = [82124,220,354,356,360];
SYG_intelObjects =
[
	[[9709.46,9960.43,1.4], 155, "Computer", "GRU_scripts\computer.sqf", "STR_COMP_ENTER"],
	[[9712.41,9960,0.6], 90, "Wallmap", "GRU_scripts\mapAction.sqf","STR_CHECK_ITEM"]
	// GRUBox position[]={9707.685547,143.645111,9963.350586};	azimut=90.000000;
];

SYG_computerPos = {argp(argp(SYG_intelObjects, 0),0)};
SYG_mapPos = {argp(argp(SYG_intelObjects, 1),0)};

//
// call: _dist = _obj call SYG_distToGRUComp;
//       _dist = (getPos _obj) call SYG_distToGRUComp; 
// 
SYG_distToGRUComp = {
	_this distance argp(argp(SYG_intelObjects, 0),0);
};

SYG_getGRUCompPos = {
	argp( argp( SYG_intelObjects, 0 ), 0 )
};

SYG_getGRUComp = {
	private ["_comp_arr","_pos"];
	_compArr = argp(SYG_intelObjects, 0);
	_compType = call SYG_getGRUCompType;
	nearestObject [ argp(_compArr, 0), argp(_compArr, 2) ]
};

SYG_getGRUCompActionTextId = {
	argp( argp(SYG_intelObjects, 0), 4 )
};

SYG_getGRUCompType = {
	argp( argp(SYG_intelObjects, 0), 2 )
};

SYG_getGRUCompScript = {
	argp( argp(SYG_intelObjects, 0), 3 )
};

SYG_getGRUMapActionTextId = {
	argp( argp(SYG_intelObjects, 1), 4 )
};

SYG_getGRUMapScript = {
	argp( argp(SYG_intelObjects, 1), 3 )
};

SYG_getMainTaskTargetPos = { (call SYG_getTargetTown) select 0 };

#define __DEBUG_COMP__
//
// TODO: replace with more universal procedure
//
// Updates GRU house equipment. Call only from server if MP
// 1. Check for the computer house presence,
// 2. Check for computer presence if not present, create all equipment
// 3. Check if computer is in nearest house
// 4. if true, wait until next loop
// 5. if false, moves computer to the nearest hose
//
SYG_updateIntelBuilding = {
	private ["_house","_compArr","_comp","_pos","_pos1","_mapArr","_maps","_map"];
	// get nearest house
	// 1. check if equipment exists at all
	// check comp
	_compArr = argp(SYG_intelObjects, 0);
	_comp = nearestObject [ argp(_compArr, 0), argp(_compArr, 2) ];
	if ( isNull _comp ) then {  // create it
		_comp = argp(_compArr,2) createVehicle [0,0,0];
		_comp setPos argp( _compArr, 0 );
		_comp setDir argp( _compArr, 1);
#ifdef __DEBUG_COMP__		
		hint localize "+++ SYG_updateIntelBuilding: computer created";
#endif
		
		sleep 0.1;
#ifdef __LOCAL__
		playSound "ACE_VERSION_DING"; // inform about computer creation
		// add action
		_comp addAction [ localize argp(_compArr,4), argp(_compArr,3) ];
#else
		hint localize "+++ GRU_msg: GRU_MSG_COMP_CREATED sent to clients";
		["GRU_msg", GRU_MSG_COMP_CREATED] call XSendNetStartScriptClient;
#endif
	} else {
		// 1.1 check if equipment is damaged or stand not on place
		//if ( !alive _comp) then { _comp setDamage 0;};
		_pos  = getPos _comp;
		_pos1 = argp(_compArr, 0);
		_pos set [2, 0];
		_pos1 = [argp(_pos1,0), argp(_pos1,1),0];
		if ( ((_pos distance _pos1) > 0.1) || (((vectorUp _comp) distance [0,0,1]) > 0.1 ) ) then {
			_pos = argp(_compArr, 0);
			_comp setPos _pos;
			sleep 0.01;
			_comp setVectorUp [0,0,1];
			_comp setDir argp(_compArr, 1);
			sleep 0.01;
		};
	};
	
	// TODO: play with building
/* 	_house = nearestBuilding _comp;
	if ( _house distance _comp > 5 ) exitWith { hint localize "+++ SYG_updateIntelBuilding: no house found" };
 */	
	// check map
	sleep 0.01;
	_mapArr = argp(SYG_intelObjects,1);
	_map = objNull;
	_maps = nearestObjects [ argp(_mapArr, 0), ["Wallmap","RahmadiMap"],10 ];
	// 2. check if map has correct image (Sahrani or Rahmadi)
	_name = if ( (call SYG_getTargetTownName) == "Rahmadi" ) then {"RahmadiMap"} else {"Wallmap"};
	if ( count _maps > 0) then { // check type to be correct
		_map = argp(_maps, 0);
		if ( typeOf _map != _name ) then {
//			hint localize format["+++ SYG_updateIntelBuilding: target town ""%3"", typeOf ""%1"" != ""%2"";",typeOf _map, _name, (call SYG_getTargetTownName) ];
			deleteVehicle _map;
			sleep 0.01;
			_map = objNull;
			sleep 0.02;
		};
	};
	
	if ( isNull _map ) then { // create it
//		hint localize format["+++ SYG_updateIntelBuilding: create map ""%1""", _name];
		_map = _name createVehicle [0,0,0];
		sleep 0.1;
		_map setPos argp(_mapArr, 0);
		_map setDir argp(_mapArr, 1);
		sleep 0.1;
		//_mapArr set [0, getPos _map];
		["GRU_msg", GRU_MSG_INFO_TO_USER, GRU_MSG_INFO_KIND_MAP_CREATED] call XSendNetStartScriptClient;
	} else {
		// 1.1 check if equipment is damaged or stand not in place
		//if ( !alive _map) then { _map setDamage 0;};
		_pos  = getPos _map;
		_pos set [2, 0];
		_pos1 = argp(_mapArr, 0);
		_pos1  = [_pos1 select 0, _pos1 select 1, 0];
		if ( ((_pos distance _pos1) > 0.1) || ( ((vectorUp _map) distance [0,0,1]) > 0.1 ) ) then {
			_map setVectorUp [0,0,1];
			_map setPos argp(_mapArr, 0);
			_map setDir argp(_mapArr, 1);
			sleep 0.01;
		};
	};
};

// Moves map position in some map dialogs
//
// call as follow:
// [_display_id, _ctrl_id, _end_pos] call SYG_setMapPosToMainTarget;
//
// where 
//       _dialog_id = dialog for GRU tasks
//       _ctrl_id = id for map control in dialog
//       _end_pos = position to set map at end, start pos always is player position
//
SYG_setMapPosToMainTarget = {
	private ["_display","_ctrlmap","_start_pos"];
	if ( (count _this) < 3) exitWith {hint localize format["--- Expected number of params to call SYG_setMapPosToMainTarget is %1 (invalid, must be 3)", count _this];};
	_display = findDisplay arg(0);
	if (isNull _display) exitWith {hint localize format["--- Expected display id in [%1,%2,%3] call  SYG_setMapPosToMainTarget is invalid",arg(0),arg(1),arg(2)];};
	_ctrlmap = _display displayCtrl arg(1);
	ctrlMapAnimClear _ctrlmap;

	_start_pos = position player;
	_ctrlmap ctrlMapAnimAdd [0.0, 1.00, _start_pos];
	_ctrlmap ctrlMapAnimAdd [1.2, 1.00, arg(2)];
	_ctrlmap ctrlMapAnimAdd [0.5, 0.30, arg(2)];
	ctrlMapAnimCommit _ctrlmap;
};

// call as: _dist = [_obj1||_pos1, _obj2||_pos2] call SYG_distance2D;
SYG_distance2D = {
	if (typeName _this != "ARRAY") exitWith {
		hint localize format["--- SYG_distance2D: _this =  %1", _this];
		9999999.0 // assign maximum distance available
	};
	if (count _this != 2) then {
		hint localize format["--- SYG_distance2D: _this =  %1", _this];
	};

	private ["_pos1", "_pos2"];
	_pos1 = (_this select 0) call SYG_getPos;
//	if (isNil "_pos1") exitWith { -1000 };
//	if ( typeName _pos1 == "OBJECT") then { _pos1 = position _pos1;};
//	if (typeName _pos1 != "ARRAY") exitWith {
//		hint localize format["--- SYG_distance2D: _this =  %1", _this];
//		9999999.0 // assign maximum distance available
//	};
	_pos2 = (_this select 1) call SYG_getPos;
//	if (isNil "_pos2") exitWith { -2000 };
//	if ( typeName _pos2 == "OBJECT") then { _pos2 = position _pos2;};
//	if (typeName _pos2 != "ARRAY") exitWith {
//		hint localize format["--- SYG_distance2D: _this =  %1", _this];
//		9999999.0 // assign maximum distance available
//	};
//	hint localize format["+++ SYG_distance2D: _pos1=%1, _pos2=%2", _pos1, _pos2];
	[_pos1 select 0, _pos1 select 1] distance [_pos2 select 0, _pos2 select 1]
};

//
// Creates message with any object distance and direction according to the nearest location
// Input: _msg = player call SYG_MsgOnPos;
// Result message is localized as follow: "from %LOC_NAME %DIST m. to %DIR", please compound you messsage as follow:
// e.g. "You are " + "1400 м. to North from Bagango" 
// или "Вы на расстоянии " + "1400 м. к северу от Bagango"
//
SYG_MsgOnPos = {
	[_this, localize "STR_SYS_POS"] call SYG_MsgOnPosA // "from %1 %2 m. to %3"
};

//
// Creates localized message about object distance and direction from the nearest location,
// e.g. "%1 m. to %2 from %3" ("150 m. to W from Pita")
//
// call as: _msg = [_obj <,roundTo> ] call SYG_MsgOnPos0;
// or     : _msg = _obj call SYG_MsgOnPos0; // default roundTo == 100
//
SYG_MsgOnPos0 = {
	private ["_arr"];
	if (typeName _this == "ARRAY") then {
		_arr = [_this select 0, localize "STR_SYS_POS"];
		if (count _this > 1) then { _arr set[2, _this select 1] }
	} else {
		_arr  = [_this, localize "STR_SYS_POS"];
	};
	_arr call SYG_MsgOnPosA
};


//
// Creates message based on user format string with 3 params %1, %2, %3 in follow order:
// distance_to_location, direction_to_location, location_name. E.g. "%1 m. from %2 m. to %3"
//
// call as: _msg_localized = [_obj|_pos, _localized_format_msg<,roundTo>] call SYG_MsgOnPosA;
//
SYG_MsgOnPosA = {
	private ["_obj","_msg","_roundTo","_pos1","_pos2","_loc","_dir","_dist","_locname"];
	_obj = arg(0);
	_msg = arg(1);
	_roundTo = argopt(2,100);
	_loc = _obj call SYG_nearestLocation;
	_pos1 = position _loc;
	_pos1 set [2,0];
	if ( (typeName _obj) == "ARRAY") then { _pos2 = _obj } else { _pos2 = position _obj };
	_pos2 set [2,0];
	_dist = (round ((_pos1 distance _pos2)/_roundTo)) * _roundTo;
	_dir = ([locationPosition _loc, _obj] call XfDirToObj) call SYG_getDirName;
	_locname = text _loc;
	format[ _msg, _dist, _dir, _locname ]
};

//
// Creates message based on user format string with 2 params %1, %2 in follow order:
// distance from A to B, direction from A to B
// e.g. [player_1, player_2, "%1 m. to %2 from player_1 to player_2", 50]  call SYG_MsgOnPosA2B; // "150 m. to SW from playerOne to playerTwo"
//
// call as: _msg_localized = [_obj1, _obj2, _localized_format_msg<, roundTo>] call SYG_MsgOnPosA2B;
//
SYG_MsgOnPosA2B = {
	private ["_obj1","_obj2","_msg","_roundTo","_dir","_dist"];
	_obj1 = arg(0);
	_obj2 = arg(1);
  	_msg  = arg(2);
  	_roundTo = argopt(3,100);

	_dir  = ([_obj1, _obj2] call XfDirToObj) call SYG_getDirName;
	_dist = (round (([_obj1, _obj2] call SYG_distance2D)/_roundTo)) * _roundTo;
	format[ _msg, _dist, _dir ]
};

//
// Creates non-localized (usually english) message based on user format string with 3 params %1, %2, %3 in follow order:
// distance_to_location, direction_to_location, location_name
//
// call as: _msg_eng = [_obj, _localized_format_msg<,roundTo=50> ] call SYG_MsgOnPosE;
//
SYG_MsgOnPosE = {
	private ["_obj","_msg","_pos1","_pos2","_loc","_dir","_dist","_locname","_roundTo"];
	_obj = _this select 0;
	_msg = _this select 1;
//	if ( (typeName _obj) == "ARRAY") then {
//		hint localize format["+++ SYG_MsgOnPosE: _this = %1", _this];
//	};
	if (isNil "_obj") exitWith {format[_msg, "<null 0>??? ","???","???"]};
	_loc = _obj call SYG_nearestLocation;
	_pos1 = locationPosition _loc;
	if (isNil "_pos1") exitWith {format[_msg, "<null 1>??? ","???","???"]};
//	_pos1 set [2,0];
//	if ( (typeName _obj) == "ARRAY") then { _pos2 = _obj } else { _pos2 = position _obj };
	_pos2 = _obj call SYG_getPos;
	if (isNil "_pos2") exitWith {format[_msg, "<null 2>??? ","???","???"]};
//	_pos2 set [2,0];// SYG_getPos
	_dist = [_pos1, _pos2] call SYG_distance2D;
	_roundTo = if (count _this > 2) then { _this select 2 } else {50};
	_dist = (round (_dist/_roundTo)) * _roundTo;
	_dir = ([_pos1, _obj] call XfDirToObj) call SYG_getDirNameEng;
	_locname = text _loc;
	format[ _msg , _dist, _dir, _locname ]
};

//
// Creates non-localized (only english) message about object distance and direction from the nearest location,
// e.g. "%1 m. to %2 from %3" ("150 m. to W from Pita")
//
// call as: _msg_eng = [_obj <,roundTo> ] call SYG_MsgOnPosE0;
// or     : _msg_eng = _obj call SYG_MsgOnPosE0; // default roundTo == 100
// or     : _msg_eng = _pos2or3D call SYG_MsgOnPosE0; // default roundTo == 100
//
SYG_MsgOnPosE0 = {
	private ["_arr"];
	if (typeName _this == "ARRAY") then {
		if ( (typeName (_this select 0)) == "SCALAR") then {
			_arr = [_this, localize "STR_SYS_POSE"];
		} else {
			_arr = [_this select 0, localize "STR_SYS_POSE"];
			if (count _this > 1) then { _arr set[2, _this select 1] }
		};
	} else {
		_arr  = [_this, localize "STR_SYS_POSE"];
	};
	_arr call SYG_MsgOnPosE
};

/*
 * Approximated distance to the base by feet in meters approximatelly

  calls:
        _dist = player call SYG_distToBase;
        _dist = (getPos player) call SYG_distToBase;
 */
SYG_distByCar = {
    (_this call SYG_geoDist) * 1.4
};

/*
 * Distance from 1st point to 2nd by land path. The path always goes through center of island (if Sahrani)
 To make it distance by car multiply result by 1.4.

  Calls:
        _dist = [player, FLAG_BASE] call SYG_distByCar;
        _dist = [_pos1, _pos2] call SYG_distByCar;
  Note:
        both points must be on mainland, not in water or on any of islets
  Returns -1 if parameters are invalid, distance between point by car/feet on the land
 */
SYG_geoDist = {
    if (typeName _this != "ARRAY") exitWith {-1};
    if (count _this != 2) exitWith{-1};
    private ["_pos1","_pos2","_pn1","_pn2","_part1","_part2","_onCenter"];
    _pos1 = (_this select 0) call SYG_getPos;
    if ( (_pos1 select 0) == 0) exitWith {-1};
    _pos2 = (_this select 0) call SYG_getPos;
    if ( (_pos2 select 0) == 0) exitWith {-1};

    // "NORTH", "SOUTH", "CENTER"
#ifdef __DEFAULT__
    _part1 = _pos1 call SYG_whatPartOfIsland;
    _part2 = _pos2 call SYG_whatPartOfIsland;
    _onCenter = (_part1 == "CENTER" || _part2 == "CENTER"); // if one or both are on center part (Carazol if Sahrani)
    if ((_part1 == _part2) || _onCenter) exitWith {_pos1 distance _pos2};
    ((_pos1 distance SYG_Sahrani_p0) + (_pos2 distance SYG_Sahrani_p0));
#else
	_pos1 distance _pos2
#endif
};

//
// Get position for any kind of object.
// Call as: _pos = _obj call SYG_getPos;
//
SYG_getPos = {
    if ( typeName _this == "ARRAY"    ) exitWith { _this };
    if ( typeName _this == "OBJECT"   ) exitWith { getPos _this };
    if ( typeName _this == "GROUP"    ) exitWith { getPos (_this call SYG_getLeader) };
    if ( typeName _this == "LOCATION" ) exitWith { locationPosition _this };
    if ( typeName _this == "STRING"   ) exitWith { getMarkerPos _this };
    [ 0,0,0 ]
};

//
// Get correct ASL position, but it is` not workig correctly(((
//
SYG_getPosASL = {
    _this modelToWorld [0, 0, ((getPosASL _this) select 2)- ((getPos _this) select 2)]
};

//
// Detects real height above/under ground level
// call as follows: _agl = _obj call SYG_getPosAGL;
//
SYG_getPosAGL = {
	private ["_asl", "_log", "_agl"];
	if (typeName _this != "OBJECT") exitWith {[]};
	_asl = getPosASL _this;
	_log = "Logic" createVehicleLocal _asl;
	_agl = _asl - (getPosASL _log); // AGL
	deleteVehicle _log;
	_agl
};

//
// Measures ASL on the land in center of designated object
// call: _asl = _obj call SYG_getLandASL;
SYG_getLandASL = {
	private ["_logic","_asl"];
	_logic = "Logic" createVehicle [0,0,0];
	_asl = _this call SYG_getPos;
	_asl resize 2;
	_logic setPos _asl;
	_asl = getPosASL _logic;
	deleteVehicle _logic;
	_asl select 2
};

//
// Get random Way Point in designated annulus (between 2 designated radius)
// call as: _wp = [_center,_rad1,_rad2] call SYG_getWPointInAnnulus
// Returns: [x,y,z] point, or [] if can't create such point
//
SYG_getWPointInAnnulus = {
	private ["_rad","_ang","_pos","_cnt"];
	_pos = [];
	_cnt = 0;
	while {(count _pos == 0) && _cnt < 10} do {
		_rad = [_this select 1, _this select 2] call XfRndRadiousInAnnulus; // random radius indesignated  annulus
		_ang = random 360;
		_pos = [_rad * (cos _ang), _rad * (sin _ang)] call XfGetClearPoint; // random point on radios
		_cnt = _cnt + 1;
		sleep 0.01;
	};
	if (count _pos == 0) exitWith {_pnt};
	[(_pos select 0) + ((_this select 0) select 0),(_pos select 1) + ((_this select 0) select 1), 0]
};

/*
 * Finds nearest to the designated point/object boat station, marked by markers of follow names: "boats1", "boats2", ...
 * call: _obj call SYG_nearestBoatMarker; // nearest marker of boat station
 * call: [_x,_y<,_z>] call SYG_nearestBoatMarker; // nearest marker of boat station
 */
SYG_nearestBoatMarker = {
    if (typeName _this == "OBJECT") then { _this = position _this};
    if (typeName _this != "ARRAY") exitWith {""}; // bad parameter in call
    if (count _this < 2) exitWith {""}; // bad array with position coordinates (length must be 2..3)
    private ["_id","_near_dist","_near_marker_name","_marker","_mpos"];
    _id = 1;
    _near_dist = 999999;
    _near_marker_name = "";
    // find all boats marker
    while {true} do {
        _marker = format["boats%1", _id];
        if ( (getMarkerType _marker) == "") exitWith {};
        _mpos = getMarkerPos _marker;
        if ( (_mpos distance _this) < _near_dist) then {
            _near_dist =  _mpos distance _this;
            _near_marker_name = _marker;
        };
        _id = _id + 1;
    };
    _near_marker_name // return nearest marker name or "" if error occured
};

//
// Find if designateв point/object is on the base (in base rectangle)
// call:
// _on_base = player call SYG_pointIsOnBase;
// _on_base = _veh call SYG_pointIsOnBase;
// _on_base = (getPos _veh) call SYG_pointIsOnBase;
//
SYG_pointIsOnBase = {
	[_this call SYG_getPos,d_base_array] call SYG_pointInRect
};

//
// checks if designated point is in nearest town from the "target_names" borders
// call:
// _in_town = player call  SYG_pointInTownBorders;
// _in_town = _veh call  SYG_pointInTownBorders;
// _in_town = (getPos _veh) call  SYG_pointInTownBorders;
//
SYG_pointIsInTownBorders = {
    private ["_dist","_pos","_town","_new_dist","_x"];
    _dist = 9999999;
    _pos = _this call SYG_getPos;
    _town = [];
    // find nearest town
    {
    	//[                                          // Indexes, not identifiers
    	//	[[9349,5893,0],   "Cayo"      ,210, 2],  //  0
    	//	[[10693,4973,0],  "Iguana"    ,270, 3],  //  1
    	_new_dist = [_x select 0, _pos] call SYG_distance2D;
    	if (_new_dist < _dist) then {
    	    _dist= _new_dist;
    	    _town = _x;
    	};
    } forEach target_names;
    // return true if point is IN nearest town borders
    (_town select 2) >= _dist
};

//
// _asl = getPosAL _truck;             //       _asl = [9298.02, 10145.2, 139.992]
// _round_pos = () call SYG_roundPos;  // _round_pos = [9298,    10145,   140]
//
SYG_roundPos = {
    [ round (_this select 0), round (_this select 1), round (_this select 2) ]
};


//
// Detects if positions is on land or in sea near shore. Detects shore on distance 20 meters
// Call: _nearLand = _unit call SYG_posNearLand;
// Call: _nearLand = (_getPos _unit) call SYG_posNearLand;
//
SYG_isNearLand = {
	private ["_pos", "_dist", "_cnt", "_xpos0", "_ypos0", "_xpos"];
	_pos = _this call SYG_getPos;
	_cnt = 0;
	_xpos0 = _pos select 0;
	_ypos0 = _pos select 1;
	{
		_xpos = _xpos0 + _x;
		{
			if (!surfaceIsWater	[_xpos, _ypos0 + _x] ) then {_cnt =  _cnt + 1};
		} forEach [+20,0,-20]; // for Y
	} forEach [-20,0,+20]; // for X
	_cnt > 0
};


if (true) exitWith {};