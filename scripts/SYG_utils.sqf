//++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
// Script to detect if designated weapon is sniper one (return true) or not (return false)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "x_setup.sqf"
#include "x_macros.sqf"

//#define __DEBUG__

#define arg(x) (_this select(x))
#define argp(param,x) ((param)select(x))
#define argopt(num,val) (if(count _this<=(num))then{val}else{arg(num)})
#define RANDOM_ARR_ITEM(ARR) (ARR select(floor(random (count ARR))))

#define DEFAULT_MAX_DISTANCE_TO_TARGET 1500
#define DEFAULT_MIN_GROUP_SIZE 5
#define MIN_POSSIBLE_GROUP_SIZE 2

// ACE_Binocular, ACE_LaserDesignator, ACE_LaserDesignatorMag, ACE_Laserbatteries

if ( isNil "SYG_UTILS_COMPILED" ) then  // generate some static information
{
	SYG_UTILS_COMPILED = true;
	//hint localize "+++ SYG_utils initialization started";
	call compile preprocessFileLineNumbers "scripts\SYG_utilsWeapon.sqf";	// Weapons, re-arming etc
	call compile preprocessFileLineNumbers "scripts\SYG_utilsGeom.sqf";		// Geometry, mathematics
	call compile preprocessFileLineNumbers "scripts\SYG_utilsDateTime.sqf";	// Date-time
	call compile preprocessFileLineNumbers "scripts\SYG_utilsGeo.sqf";		// Geography
	call compile preprocessFileLineNumbers "scripts\SYG_utilsSM.sqf";		// Side Missions
	call compile preprocessFileLineNumbers "scripts\SYG_utilsEnv.sqf";		// Environment
	call compile preprocessFileLineNumbers "scripts\SYG_utilsVehicles.sqf";	// Vehicles
	call compile preprocessFileLineNumbers "scripts\SYG_utilsBuildings.sqf";// Buildings
	call compile preprocessFileLineNumbers "scripts\SYG_utilsText.sqf";		// Text functions
	call compile preprocessFileLineNumbers "scripts\SYG_utilsSound.sqf";	// Sound/music functions
#ifdef __PREVENT_OVERTURN__
	call compile preprocessFileLineNumbers "scripts\SYG_eventGetOut.sqf";		// anti-overturn method
#endif

	//hint localize "--- SYG_utils initialization finished";
};

/**
 * call: _listItemFound = [_shortList, _longList] call SYG_isListInList;
 *
 * returns: true if any item of first list found in second list. Comparison is case-sensitive.
 */
SYG_isListInList = {
    private ["_list","_ret"];
	_list = _this select 1;
	_ret = false;
	{
		if ( _x in _list ) exitWith {_ret = true;};
	} forEach (_this select 0);
	_ret
};

//
// Parameters in input array:
// _unit: unit to find group for
// _dist (optional): radius to find group, default value is 500 m. Set to 0 or negative to use default
// _pos (optional): search center, if set to [] or absent, _unit pos is used
// _min_pop (optional): minimum group population, default is 2, minimum possible value is 2
//
// Returns: group found or grpNull if not found
// Usage:
// _grp = [_unit, _dist] call SYG_findNearestSideGroup; // search around _unit, return grpNull if no group found
// _grp = [_unit, _dist, _zone_pos, _min_grp_size] call SYG_findNearestSideGroup; // search around _pos, return grpNull if no group found
//
SYG_findNearestSideGroup = {
	private ["_unit", "_dist", "_side", /* "_nearArr", */ "_grp", "_min_count", "_types" ];
	_unit = arg(0);
	_grp = grpNull;
	if ( !isNull _unit ) then
	{	
		_dist = 0;
//		if ( (count _this ) > 1 ) then { _dist = _this select 1};
		_dist = argopt(1, DEFAULT_MAX_DISTANCE_TO_TARGET);
		if (_dist <= 0) then { _dist = DEFAULT_MAX_DISTANCE_TO_TARGET;};
		
//		if ( (count _this ) > 2 ) then { _pos = _this select 2};
		_pos = argopt(2,(getPos _unit));
		if ((count _pos) <3) then {_pos = getPos _unit;};

		_min_count = argopt(3, DEFAULT_MIN_GROUP_SIZE);
		_min_count  = _min_count max MIN_POSSIBLE_GROUP_SIZE; // minimal possible size of group is 2

		//hint localize format["[%1,%2,%3,%4] call SYG_findNearestSideGroup;",_unit, _pos, _dist, _min_count ];
		
		_side = side _unit;
		_types = switch _side do
		{
			case east : {["SoldierEB"]};
			case west : {["SoldierWB"]};
			case civilian: {["Civilian"]};
			case resistance: {["SoldierGB"]};
			default {["CAManBase"]};
		};
		
/*
		_nearArr = nearestObjects [_pos, _types, _dist];
		hint localize format["SYG_findNearestSideGroup: nearestObjects [%1,%2,%3] = %4",_pos,_types,_dist,_nearArr];
*/

		{
			// find good, healthy, fast and agressive infantry group for our poor man
			if ( ((side _x) == _side) && (alive _x) && ( ! (isNull (group _x)) )
			&& (vehicle _x == _x) && (!isPlayer _x) && ( (group _x) != (group _unit) )
			&& ( ({(alive _x) && (canStand _x)} count (units group _x)) >= _min_count)) exitWith { _grp = group _x;};
		} forEach nearestObjects [_pos, _types, _dist]; //_nearArr;
	};
	_grp
};

/**
 *  returns true is unit has ACE crew protection else false
 * _hasACEProtection = _unit call SYG_checkACECrewProtection;
 */
SYG_unitHasACECrewProtection = {
 getNumber(configFile>>"CfgVehicles">> typeOf _this >>"ACE_CrewProtection") > 0
};

/**
 * Makes designated objects (buildings to be reasonable) undesructible by using event handlers
 * calls: _res = [_id1, _id2,..., _idN] call SYG_makeUndestructible;
 * params: array with objects id
 *
 * returns: number of objects set undestructable. If all id are valid, count of whole array items is returned
 */
SYG_makeUndestructible = {
	private ["_obj", "_cnt"];
	_cnt = 0;
	{
		_obj = [0,0,0] nearestObject _x;
		if ( !isNull _obj ) then 
		{
			_cnt = _cnt + 1;
			_obj addEventHandler ["hit", {(_this select 0) setDammage -900000000000}];
		};
	} forEach _this;
	_cnt
};

/**
 * Makes designated objects  with specified type (e.g. "Land_hotel") indestructible by setting event handlers. Works only for CfgVehicles branch of the class hierachy.
 * calls: _res = [_type<, _id1, _id2,..., _idN>] call SYG_makeTypeUndestructible;
 * params: _type - object type to processDiaryLink
 *        [...]  - array with objects id
 *
 * returns: number of objects set indestructible. If all id are valid, count of whole array items is returned
 */
SYG_makeTypeUndestructible = {
	private ["_obj", "_cnt"];
	_cnt = 0;
	_type = _this select 0;
	{
		_obj = [0,0,0] nearestObject _x;
		if ( !isNull _obj ) then 
		{
			if ( _obj isKindOf _type ) then 
			{
				_cnt = _cnt + 1;
				_obj addEventHandler ["hit", {(_this select 0) setDammage -900000000000}];
			};
		};
	} forEach (_this select 1);
	_cnt
};
/**
 * call: _reta = [_pos OR _unit,[_veh1,_veh2,...,_vehN]<,_dist>] call SYG_findVehWithFreeCargo;
 * where:
 *		_dist is distance to search for the convoy vehicle, optional, default is 350 m
 *      _reta is array of [_veh, emptyPosNum]
 *
 */
#define DEFAULT_GROUP_SEARCH_RADIUS 350
SYG_findVehWithFreeCargo = {
	private ["_pos","_vecs","_searchdist","_dist","_reta","_emptypos","_mindist","_str"];
	_pos     = arg(0);
	_vecs     = arg(1);
	_searchdist  = argopt(2,DEFAULT_GROUP_SEARCH_RADIUS);
	_reta     = [];
	_emptypos = 0;
	_mindist  = 9999999.0;
#ifdef __DEBUG__
	_str = format["%1 call SYG_findVehWithFreeCargo (%2,%3,%4)", call SYG_nowTimeToStr, _pos, _vecs, _dist];
#endif	
	if ( typeName _pos != "ARRAY" ) then {_pos = getPos _pos;}; // if _pos not position but object
	
	{ 
		if ( (!isNull _x) AND (canMove _x) AND (!isNull driver _x) AND ((_x distance _pos) <= _searchdist) ) then 
		{
			_emptypos = _x emptyPositions "Cargo";
			if ( _emptypos > 0 ) then 
			{ 
				 _dist = _pos distance _x;
				 if ( _dist < _mindist ) then {_mindist = _dist; _reta = [_x, _emptypos];};
			};
#ifdef __DEBUG__
			_str = _str + format["%1 cargo %2; ",typeOf _x, _emptypos];
#endif	
		}
#ifdef __DEBUG__
		else { _str = _str + "<null>; ";}
#endif	
		;
	} forEach _vecs;
#ifdef __DEBUG__
	hint localize format["%1 = %2",_str, _reta];
#endif	
	_reta
};

/**
 * finds big enough group at nearest mission war zones (main target town, air-base with sabotages, re-cuptured towns etc)
 * call:
 *     _grp     = [_unit, _dist, _min_grp_size] call SYG_findGroupAtTargets;
 * Where: 
 *     _unit    : any unit of the same side and group to re-join
 *    _dist     : distance in meters to search for such group around targets. Optional, default is 1500
 *    _min_grp_size : minimum distance to search for the target. Optional, default is 5
 * Returns:
 *		_grp    : found group of grpNull if no such group exists
 **/
SYG_findGroupAtTargets = {
	private ["_unit","_dist","_min_grp_size","_unit_pos","_pos","_goal_grp","_ret","_pos_arr","_zone_pos","_str"];
	// Let find new group in the follow order:
	//
	// 1. Target town
	// 2. Airbase with some enemy group on it
	// 3. Re-captured towns (possibly one of many)
	// 4. Side mission
	
	_unit     = arg(0);
	_dist     = argopt(1,DEFAULT_MAX_DISTANCE_TO_TARGET);
	_min_grp_size = argopt(2,DEFAULT_MIN_GROUP_SIZE);
	
	//hint localize format["[%1, %2, %3] call SYG_findGroupAtTargets;",_unit,_dist,_min_grp_size];
	
	_pos = getPos _unit;
	_goal_grp = grpNull;
	
	_pos_arr = [ _pos, true, ["MAIN","SIDEMISSION","OCCUPIED","AIRBASE"],_dist] call SYG_nearestZoneOfInterest; // [[_pos1,...],_nearest_dist_index]
	_ret = argp(_pos_arr,1); // minimal found dist index
	_pos_arr = argp(_pos_arr,0); // array of positions

#ifdef __SYG_ISLEDEFENCE_DEBUG__
/*
	_str = "";
	{
		if ( count _x == 0 ) then {_str = _str + " <>";} else {_str = _str + format[" %1", round (_x distance _unit)];};
	} forEach _pos_arr;
	
	hint localize format["SYG_utils.sqf.SYG_findGroupAtTargets: pos near ""%3"" [MSOA/ret] = [%1/%2]", _str, _ret, text (_pos call SYG_nearestLocation) ];
*/
#endif								

	if ( _ret >= 0 ) then // some war zone enough near found 
	{
		// try to find group
		_zone_pos = argp(_pos_arr,_ret);
		_goal_grp = [_unit, _dist, _zone_pos, _min_grp_size] call SYG_findNearestSideGroup;
		if ( isNull _goal_grp ) then
		{
			_pos_arr set[_ret, "RM_ME"];
			_pos_arr = _pos_arr - ["RM_ME"];
			// check all other zones too
			{
				if ( count _x > 0 ) then // zone exists
				{
					if ( (_pos distance _x) <= _dist ) then
					{
						_goal_grp = [_unit, DEFAULT_GROUP_SEARCH_RADIUS, _x, _min_grp_size] call SYG_findNearestSideGroup;
					};
				};
				if ( !isNull _goal_grp ) exitWith {};
			} forEach _pos_arr;
		};
	};
	_goal_grp
};
 
#define __SYG_ISLEDEFENCE_DEBUG__

/**
 * call: _feetmen = [[_unit1...,_unitN],[_veh1,_veh2,...,_vehN]] call SYG_findAndAssignAsCargo;
 * where:
 *		[_unit1...,_unitN] is array of units to assign as cargo to free vehicles, this item may be "GROUP", not "ARRAY"
 *		[_veh1,_veh2,...,_vehN] is array of vehicles to find for cargo free space
 *      _feetmen is array of men not fit into available cargo of designated vehicles
 */
SYG_findAndAssignAsCargo = {
	private ["_feetmen","_feetmen1","_vecs","_reta","_veh","_i","_count","_unit","_assigned","_j", "_pos","_grp_pos","_goal_grp","_grp","_part1","_part2","_grp_on_islet"];
	_feetmen = arg(0);
	if ( typeName _feetmen == "GROUP" ) then { _feetmen = units _feetmen; }
	else { // may be single unit designated
    	if ( typeName _feetman == "OBJECT") then { if ( _feetmen isKindOf "CAManBase" ) then { _feetmen = [ _feetmen ]; }};
	};
    if ( typeName _feetmen != "ARRAY" ) exitWith {[]}; // illegal argument
    if ( count _feetman == 0 ) exitWith {[]};
	_vecs = [] +  arg(1);
	scopeName "exit";
	if ( (count _vecs > 0) && (count _feetmen > 0) ) then
	{
		_feetmen1 = [] + _feetmen;
		_vecs = [] + _vecs;
		// filter vehicles
		for "_i" from 0 to count _vecs - 1 do
		{
			_x = _vecs select _i;
			if ( !(canMove _x) || (isNull driver _x) || ((_x emptyPositions "Cargo") <= 0) )  then {_vecs set [_i, "RM_ME"]};
		};
		_vecs = _vecs - ["RM_ME"];
		if ( count _vecs > 0 ) then
		{
			// filter feetmen
			for "_i" from 0 to count _feetmen1 - 1 do
			{
				_x = _feetmen1 select _i;
				if ( !alive _x ) then { _feetmen1 set [_i, "RM_ME"] }
				else
				{ 
					if ( (_x call SYG_ACEUnitUnconscious) || (!isNull assignedVehicle _x) ) then { _feetmen1 set [_i, "RM_ME"] };
				};
			};
			_feetmen1 = _feetmen1 - ["RM_ME"];
			if ( count _feetmen1 > 0 ) then
			{
				_feetmen1 allowGetIn true;
#ifdef __SYG_ISLEDEFENCE_DEBUG__
				hint localize format["%1 SYG_findAndAssignAsCargo: reassigning to cargo %2 men with patrol %3 vecs", call SYG_nowToStr, count _feetmen1, count _vecs];
#endif								
				while { (count _vecs > 0) || (count _feetmen1) > 0 } do
				{
					// find suitable vehicle with free cargo space,
					_reta = [_feetmen1 select 0, _vecs, DEFAULT_GROUP_SEARCH_RADIUS] call SYG_findVehWithFreeCargo;
					// returned is _reta as follow: [_veh, emptyPosNum], or [] if no suitable vec found;
					if (count _reta == 0) then {breakTo "exit"}; // no more vehicles with free cargo space, exit
					
					_count = (_reta select 1) min (count _feetmen1); // get available count
					_veh = _reta select 0;
					_vecs = _vecs - [_veh];
					_assigned = [];
					for "_i" from 0 to _count - 1 do // count always not equal to zero
					{
						_unit = _feetmen1 select _i;
						_unit assignAsCargo _veh;
						_assigned = _assigned + [_unit];
						_feetmen1 set [_i, "RM_ME"];
						sleep 0.104;
					};
					_assigned orderGetIn true;
					_feetmen1 = _feetmen1 - ["RM_ME"];
					_feetmen = _feetmen - _assigned;
					sleep 1.01;

#ifdef __SYG_ISLEDEFENCE_DEBUG__
					hint localize format["%1 SYG_findAndAssignAsCargo: %2 assignedToCargo %3 dist %4", call SYG_nowToStr, count _assigned, typeOf _veh, _veh distance (_assigned select 0)];
#endif

				}; // while { (count _vecs > 0) || (count _feetmen1) > 0 } do
			}; // if ( count _feetmen1 > 0 ) then
		}; // if ( count _vecs > 0 ) then 
	};
#ifdef __SYG_ISLEDEFENCE_DEBUG__
	hint localize format[ "%1 SYG_findAndAssignAsCargo: %2 free feetmen remained", call SYG_nowToStr, count _feetmen];
#endif
	_feetmen
};

/**
 * =====================================================
 * Detects if designated land vehicle is lying upside down. Originates from Xeno function for Domination 
 * call:
 *      _is_veh_upside_down = _veh call SYG_vehIsUpsideDown;
 * Returns:
 *      TRUE  if vehicle is alive and lies upside down. Else return FALSE
 */
SYG_vehIsUpsideDown = {
	private ["_l","_vUp","_angle"];
	if ( (alive _this) && (_this isKindOf "LandVehicle") ) then
	{
		_vUp = vectorUp _this;	// vector up for the goal
		if((_vUp select 2) < 0 )then {true}
		else // vehicle still can lay on one of its side
		{
			_l = sqrt((_vUp select 0)^2+(_vUp select 1)^2);
			if( _l != 0 )then
			{
				_angle=(_vUp select 2) atan2 _l;
				if( _angle < 30 ) then {true} else{false};
			} else {false}; // standing in good position
		};
	}
	else{false};
};

SYG_vehUpAngle = {
	if ( isNull _this ) exitWith { -1000 };
    _vUp = vectorUp _this;	// vector up for the goal
    _L2 = [_vUp,[ 0, 0, 0 ]] call SYG_distance2D;
    if ( _L2 == 0 ) exitWith { 0 };
    ( _vUp select 2 ) atan2 _L2
};

/**
  * Detectes if unit is unconscious (return true), consciousness (return false) or in unknown state (false)
* ...
 * call: _unc = _unit call SYG_ACEUnitUnconscious;
 * ...
 */
SYG_ACEUnitUnconscious = {
	if ( !alive _this ) exitWith {false};
	if (format["%1",_this getVariable "ACE_unconscious"] == "<null>") then { false } else { _this getVariable "ACE_unconscious" };
};
	
// count all alive units of group in consciousnesss
// call: _cnt = units _grp call XfGetAliveUnits;
// or call: _cnt = _grp call XfGetAliveUnits
SYG_getAllConsciousUnits = {
	if ( (typeName _this) == "GROUP" ) then { _this = units _this;};
	({ _x call SYG_ACEUnitUnconscious} count _this )
};

// Make officer to be the leader of this units group
// call: _officer = ["SquareLeaderW", _grp|_unit] call SYG_ensureOfficerInGroup;
//
SYG_ensureOfficerInGroup = {
    private ["_officer","_grp"];
    _grp     = grpNull;
    _officer = arg(0);
    if ( typeName _officer != "STRING") exitWith {hint localize format["--- SYG_ensureOfficerInGroup -> Expected argument [_unit_type, ...] is not string type: %1", _this];};
    if ( !(_officer isKindOf "Man")) exitWith { hint localize format["--- SYG_ensureOfficerInGroup -> Expected argument [_unit_type, ...] is not kind of ""Man"": %1", _this];};

    _grp     = arg(1);
    switch (typeName _grp) do
    {
        case "GROUP":  {};
        case "OBJECT": { if (_grp isKindOf "Man") then {_grp = group _grp; } else { _grp = grpNull;}; };
        default {_grp = grpNull;};
    };

    if (isNull _grp) exitWith {hint localize format["--- SYG_ensureOfficerInGroup -> Expected argument [..., _grp] is illegal: %1", _this];};
    _units = units _grp;
    // 1. check if leader is already officer
    if (leader _grp isKindOf _officer ) exitWith { leader _grp }; // found as leader
    {
        if ( _x isKindOf _officer ) exitWith
        {
            _officer = _x;
             (leader _grp) setRank "PRIVATE";
            _grp selectLeader _x;
            _x  setRank "LIEUTENANT";
        };
    }forEach _units;

    if ( typeName _officer == "OBJECT") exitWith { _officer }; // found in group and selected as leader

    // add absent officer to the group now
    _officer = _grp createUnit [_officer, getPos (leader _grp), [], 10, "FORM"];
    [_officer] join _grp;
    sleep 0.1;
    (leader _grp) setRank "PRIVATE";
     _grp selectLeader _officer;
    _officer setRank "LIEUTENANT";
    _officer
};

/**
  * Detects if designated group belongs to patrol or convoy group
  * call: _isPatrolGrp = _grp call SYG_isPatrolGroup;
 */
SYG_isPatrolGroup = {
    if ( typeName _this ==  "OBJECT") then
    {
        if ( _this isKindOf "Man") exitWith { _this = group _this };
        {
            if ( alive _x) exitWith { _this = group _x };
        } forEach crew _this;
    };

    if (typeOf _this != "GROUP") exitWith { false };

    // check to be any of active patrol group
    scopeName "main";
    _ret = false;
    {
        _grp = _x select 0; // group has offset 0 in patrol array
        if ( !isNull _grp) then {
            if ( _this == _grp) then {_ret = true; breakTo "main"};
        }
    } forEach SYG_isle_grps;
    _ret
};
//
// Handler for enemy vehicle "GetOut" event (under development)
//
SYG_hanldeGetOut = {

};

/**
 * Rounds number to the nearest boundary of designated value
 * call as: _roundedValue = [_value, BOUNDARY] call SYG_roundTo;
 * e.g. [12.49, 5] call SYG_SYG_roundTo =  10
 *      [12.51, 5] call SYG_SYG_roundTo =  15
 *      [15.7,  5] call SYG_SYG_roundTo =  15
 *      [17.51, 5] call SYG_SYG_roundTo =  20
 */
SYG_roundTo = {
    private ["_bound"];
    _bound = _this select 1;
    (round((_this select 0)/_bound)) * _bound
};

//
// Call as: _isWoman = "WOMAN_CLASS_NAME" call SYG_isWoman;
//     or : _isWoman = _man call SYG_isWoman;
//
SYG_isWoman = {
		private [ "_entry" ];
		if (typeName _this == "ARRAY") then {_this = _this select 0};
		if (typeName _this == "OBJECT") then {_this = typeOf _this};
		if (typeName _this != "STRING") exitWith {false};
		if (_this isKIndOf "MarianQuandt") exitWith {true}; // She is not woman in Arma-1
		_entry = configFile >> "CfgVehicles" >> _this;
		if ( isNumber (_entry >> "woman") )  exitWith
		{
            if ( getNumber(_entry >> "woman")  > 0) exitWith { true };
            false
		};
		if ( isText (_entry >> "woman") ) exitWith
		{
            if ( toLower(getText(_entry >> "woman")) == "true" ) exitWith {true};
            false;
		};
        false // unknown entry
};

if (true) exitWith {};
