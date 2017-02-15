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
#define NOT_POPULATE_LOADER_TO_TANK
#define NOT_POPULATE_MANY_GUNNERS_IN_HMMW_SUPPORT
#define ADD_1CARGO_TO_TRUCKS_AND_HMMW
// ACE_Binocular, ACE_LaserDesignator, ACE_LaserDesignatorMag, ACE_Laserbatteries

if ( isNil "SYG_UTILS_COMPILED" ) then  // generate some static information
{
	SYG_UTILS_COMPILED = true;
	call compile preprocessFileLineNumbers "scripts\SYG_utilsWeapon.sqf";	// Weapons, re-arming etc
	call compile preprocessFileLineNumbers "scripts\SYG_utilsGeom.sqf";		// Geometry, mathematics
	call compile preprocessFileLineNumbers "scripts\SYG_utilsDateTime.sqf";	// Date-time
	call compile preprocessFileLineNumbers "scripts\SYG_utilsGeo.sqf";		// Geography
	call compile preprocessFileLineNumbers "scripts\SYG_utilsSM.sqf";		// Side Missions
	call compile preprocessFileLineNumbers "scripts\SYG_utilsEnv.sqf";		// Environment
	call compile preprocessFileLineNumbers "scripts\SYG_utilsVehicles.sqf";	// Vehicles
	call compile preprocessFileLineNumbers "scripts\SYG_utilsBuildings.sqf";// Buildings
	call compile preprocessFileLineNumbers "scripts\SYG_utilsText.sqf";		// Text functions
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
		if ((count _pos) <3) then {_pos = getPos _unit};

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
			// find good, healhy, fast and agressive group for our man :o)
			if ( ((side _x) == _side) && (alive _x) && ( ! (isNull (group _x)) )
			&& (vehicle _x == _x) && (!isPlayer _x) && ( (group _x) != (group _unit) )
			&& ( ({(alive _x) && (canStand _x)} count (units group _x)) >= _min_count)) exitWith { _grp = group _x};
		} forEach nearestObjects [_pos, _types, _dist]; //_nearArr;
	};
	_grp
};

//
// Changes positon for sound created with call to createSoundSource function
//
// Example: 
// _sndArr = [_sound];
// [ _caller, _sndArr] call SYG_moveSoundSource; // 1st sound ar index 0 from _sndArr is changed place to the _caller position
//
SYG_moveSoundSource = {
	private ["_caller", "_id", "_args", "_snd", "_pos"];

	_caller = _this select 0;
	_args = _this select 1; // [ [snd1, snd2 ...], pos ]
	_arr = _args select 0; // array with sounds
	_pos = 0; // pos in array
	if ( count _this > 2 ) then
	{
		_pos = _this select 2; // special pos in array, not zero one
	};
	_snd = _arr select _pos; // sound to move to
	if ( !isNull snd ) then
	{
		deleteVehicle _snd;
		sleep 0.1;
		_snd = createSoundSource ["Music", getPosASL _caller, [], 0];
		_arr set [ _pos, _snd];
		_caller globalChat format["Movesnd: snd pos: %2, new pos is %1", getPosASL _caller, getPosASL _snd];
	};
};

SYG_ffunc = {
	private ["_l","_vUp","_angle", "_pos", "_tr", "_tr1", "_res","_dist"];
	if ((vehicle player) == player) then 
	{
		objectID1=(position player nearestObject "LandVehicle");
		if (!alive objectID1 || player distance objectID1 > 8) then {false}
		else
		{
			_vUp=vectorUp objectID1;
			_res = true;
			_tr = player nearestObject d_rep_truck;
#ifdef __ACE__			
			_tr1 = player nearestObject "ACE_Truck5t_Repair";
#else				
			_tr1 = player nearestObject "Truck5tRepair";
#endif			
			if ( (isNull _tr) && (isNull _tr1) ) then { _res = false;} // no any repair tracks near
			else
			{
				if ( isNull _tr ) then // _tr1 != null
				{ 
					_dist = player distance (position _tr1);
				}
				else // _tr != null
				{
					_dist = player distance (position _tr);
					if ( !(isNull _tr1) ) then // then both are found near me. Rare case but why not!)
					{
						// find nearest of two
						if ( (player distance (position _tr1)) < _dist ) then { _dist = player distance (position _tr1);};
					};
				};
				_res = true;
			};

			if ( _res ) then 
			{
				if((_vUp select 2) < 0 && (_dist < 20))then {true}
				else // vehicle still can lay on one of its side
				{
					_l=sqrt((_vUp select 0)^2+(_vUp select 1)^2);
					if( _l != 0 )then
					{
						_angle=(_vUp select 2) atan2 _l;
						if( (_angle < 30) && (_dist < 20)) then {true} else{false};
					} else {false}; // standing in good posiition
				};
			}
			else{false};
		}
	} 
	else {false}
};

// call: _turretNumber = _unit call SYG_turretNumber;
SYG_turretNumber = {
	count (configFile >> "CfgVehicles" >> typeof _this >> "turrets")	
};

//
// call: _turretList = _vehicle call SYG_turretsList; 
// get list of vehicle positions
// { moveInTurret [_vehicle, _x]} forEach _turretList; 
// populate all turrets of vehicle
//
SYG_turretsList = {
	private [ "_cfg", "_out", "_mtc", "_mti", "_mt", "_st", "_stc", "_sti" ];
	_out =  [];
	_cfg = configFile >> "CfgVehicles" >> typeof _this >> "turrets";
	_mtc = (count _cfg); // number of main turrets
	if ( _mtc > 0 ) then
	{
		for "_mti" from 0 to _mtc-1 do {
			_out = _out + [[_mti]]; // + main turret
			_mt = (_cfg select _mti);
			_st = _mt >> "turrets";
			_stc = count _st; // sub-turrets in current main one count
			if ( _stc > 0 ) then
			{
				for "_sti" from 0 to _stc-1 do {
					_out = _out + [[_mti, _sti]]; // + sub-turret
				};
			};
		};
	};
	//player globalChat format["Turret list: %1", _out];
	_out // returns list of ready positions in vehicle turrets
};

/**
 * call: _res_list = [_single_turr_descr, _veh_turr_arr] call SYG_removeFromTurretList;
 */
SYG_removeFromTurretList = 
{
	private ["_i", "_j", "_arr", "_role_arr", "_tlist", "_rarr_cnt", "_diff"];
	_role_arr = arg(0);
	if ( typeName _role_arr != "ARRAY" )  exitWith {player globalChat "SYG_removeFromTurretList: 1st param not ARRAY";};
	_rarr_cnt = count _role_arr;
	if (_rarr_cnt == 0 ) exitWith {player globalChat "SYG_removeFromTurretList: 1st array is of zero length!";};
	_tlist = arg(1);
	if ( count _tlist > 0 ) then
	{
		for "_i" from 0 to ((count _tlist)-1) do 
		{ // find unit position in vehicle turret list and remove it from list
			_diff = 0;
			_arr = _tlist select _i; // current turret description array
			if ( count _arr == _rarr_cnt ) then
			{
				for "_j" from 0 to (_rarr_cnt - 1) do
				{
					if (( _arr select _j) != (_role_arr select _j) ) exitWith { _diff = 1};
				};
				if ( _diff == 0 ) exitWith { _tlist set [_i, "RM_ITEM_NOW"]};
			};
		};
	};
	_tlist = _tlist -  ["RM_ITEM_NOW"];
	sleep 0.01;
	_tlist
};

/**
 * Version 2.0 Populates without creation any excessive units
 * Populates any totally empty vehicle (air, land or marine one) will full battle vehicle crew including all turret seats.
 * Note: cargo crew is not populated in this function
 *
 * call as: _grp = [_veh, _grp, _utype<, _skill<, _randomSkillPart>>] call SYG_populateVehicle;
 *  where:
 *			_vehicle - vehicle to populate (Striker, Abrams etc)
 *			_grp - group for vehicle, all needed crew is added to this group
 *			_utype - "SoldierWCrew" etc to fill any positions in vehicle
 * 			_skill - <optional> skill for group, default is 0.5
 *         _randomSkillPart - <optional> additional random part default 0.5
 * return: group of team member for vehicle created or grpNull on error
 *
 * Function tryes to first populate commander, then driver and only after  all other available turret gunners
 * No man added to the vehicle cargo
 */
SYG_populateVehicle ={
	private [ "_veh", "_utype", "_grpskill", "_grprndskill", "_grprndskill", "_pos", "_tlist", "_role_arr", "_unit",
	"_grp", "_add_unit", "_diff", "_ind", "_emptypos","_isAirVeh"];

	_veh   = arg(0);
	_grp   = arg(1);
	_utype = arg(2);
	
	if ( count _this > 3 ) then {_grpskill = _this select 3}
	else {_grpskill = 0.5};
	
	if ( count _this > 4 ) then {_grprndskill = (_this select 4) min (1.0 - _grpskill)}
	else {_grprndskill = 0;};
	
	_pos = getPos _veh;
	
	_tlist = _veh call SYG_turretsList;
#ifdef NOT_POPULATE_LOADER_TO_TANK
	if ( _veh isKindOf "Tank" ) then 
	{
		_tlist = [[0,1], _tlist] call SYG_removeFromTurretList;
	};
#endif

#ifdef NOT_POPULATE_MANY_GUNNERS_IN_HMMW_SUPPORT
	if ( _veh isKindOf "ACE_HMMWV_GMV" ) then 
	{
		_tlist = [[1], _tlist] call SYG_removeFromTurretList;
		_tlist = [[2], _tlist] call SYG_removeFromTurretList;
	};
#endif

	_isAirVeh = _veh isKindOf "Air";
//	player globalChat format["Turrs %1", _tlist ];
	// first try to put commander (according to role of name)
	if (_veh emptyPositions "Commander" > 0) then 
	{
		_unit=_grp createUnit [_utype, _pos, [], 0, "FORM"];
		_unit setSkill _grpskill + random (_grprndskill );
		[_unit] joinSilent _grp;
		if ( _isAirVeh ) then {_unit call SYG_armPilot};
		_unit assignAsCommander _veh;
		_unit moveInCommander _veh;
		sleep 0.01;
		_role_arr = assignedVehicleRole _unit;
		if (count _role_arr > 0 ) then
		{
			if ( _role_arr select 0 == "Turret" ) then 
			{
				_tlist = [_role_arr select 1, _tlist] call SYG_removeFromTurretList;
			};
		};
	};
		
	// second try to put driver (no turrets be occupied)
	if ( isNull driver _veh ) then  // add driver if he is not already assigned as commander
	{
		_unit=_grp createUnit [_utype, _pos, [], 0, "FORM"];
		_unit setSkill _grpskill + random (_grprndskill );
		[_unit] joinSilent _grp;
		if ( _isAirVeh ) then {_unit call SYG_armPilot};
		_unit assignAsDriver _veh;
		_unit moveInDriver _veh;
		sleep 0.01;
		_role_arr = assignedVehicleRole _unit;
		if (count _role_arr > 0 ) then
		{
			if ( _role_arr select 0 == "Turret" ) then 
			{
				_tlist = [_role_arr select 1, _tlist] call SYG_removeFromTurretList;
			};
		};
	};

	// now populate remaining turrets
	{	// create one more unit and try to fit it to current turret
		_unit=_grp createUnit [_utype, _pos, [], 0, "FORM"];
		_unit setSkill _grpskill + random (_grprndskill );
		[_unit] joinSilent _grp;
		if ( _isAirVeh ) then {_unit call SYG_armPilot};
		_unit moveInTurret [_veh, _x];
		sleep 0.02;
	} forEach _tlist;

	// never populate small mguns of HMMWV_GVT
	// well, lets look if we should fill some cargo places in trucks and canons, may be in M113, MG strikes, AT humwee
	
#ifdef ADD_1CARGO_TO_TRUCKS_AND_HMMW
	if ( (_veh isKindOf "Truck") OR (_veh isKindOf "HMMWV50" /*"ACE_HMMWV_TOW"*/) /*OR (_veh isKindOf "ACE_Stryker_TOW") */) then
	{
        // add "ACE_SoldierWMAT_A" as a passenger
        _emptypos = _veh emptyPositions "Cargo";
        if ( _emptypos > 0 ) then
        {
            _unit=_grp createUnit ["ACE_SoldierWMAT_A", _pos, [], 0, "FORM"];
            _unit setSkill _grpskill + random (_grprndskill );
            [_unit] joinSilent _grp;
            _unit moveInCargo _veh;
            sleep 0.02;
        };
	};
#endif
	_grp
};

//
// call as: 
//  _musicName = _music_index call SYG_musicTrackName; // index from 0 to ((call SYG_musicTrackCount) - 1)
//  playMusic ( floor( random (call SYG_musicTrackCount) ) call SYG_musicTrackName);
//
SYG_musicTrackName = {
	if ( _this < 0 or _this >= (call SYG_musicCount) ) exitWith { "" }; // no such track
	configName((configFile >> "CfgMusic") select _this)
};

/*
 * call as: 1 call SYG_playMusicTrack;
 * Returns started track name, or "" if bad index designated
 */
SYG_playMusicTrack = {
	private ["_name"];
	if ( _this < 0 or _this >= (call SYG_musicCount) ) exitWith { "" }; // no such track
	_name = _this call SYG_musicTrackName;
	playMusic ( _name);
	_name
};

/*
 * call as: call SYG_randomMusicTrack;
 * Returns random track name
 * playMusic ( call SYG_randomMusicTrack);
 */
SYG_randomMusicTrack = {
	(floor (random (call SYG_musicTrackCount))) call SYG_musicTrackName
};

SYG_defeatTracks = ["ATrack9","ATrack10","ATrack14","ATrack15","ATrack16","ATrack17","ATrack18","ATrack19","ATrack20","ATrack21","ATrack22"];

SYG_playRandomDefeatTrack = {
	playMusic (SYG_defeatTracks call XfRandomArrayVal);
};

SYG_OFPTracks = [
			["ATrack24",[[8.269,5.388],[49.521,7.320],[158.644,6.417],[234.663,-1]]],
			["ATrack25",[[0,11.978],[13.573,10.142],[158.644,6.417],[105.974,9.508],[138.443,-1]]]
			    ];

SYG_playRandomOFPTrack = {
    private ["_arr", "_trk"];
	_arr = SYG_OFPTracks call XfRandomArrayVal;
	_trk = argp(_arr,1) call XfRandomArrayVal;
#ifdef __DEBUG__	
	hint localize format["SYG_playRandomOFPTrack: %1",[argp(_arr,0),argp(_trk,0),argp(_trk,1)]];
#endif	
	if ( argp(_trk,1) > 0) then
	{
		[argp(_arr,0),argp(_trk,0),argp(_trk,1)] spawn {playMusic [arg(0),arg(1)];sleep arg(2);playMusic "";};
	}
	else
	{
		playMusic [argp(_arr,0),argp(_trk,0)];
	};
};


//
// call as: _musCnt = call SYG_musicTrackCount;
//
SYG_musicTrackCount = {
	count (configFile >> "CfgMusic" )
};

//
// _isCivic = _vehicle call SYG_isCivicMGCar;
//
SYG_isCivicMGCar = {
	[_this,  ["DATSUN_PK1", "HILUX_PK1","LandroverMG"] ] call SYG_isKindOfList
};

// is Mg car civic or militry one
// _isCivic = _vehicle call SYG_isCivicMGCar;
//
SYG_isMGCar = {
	_this call isCivicMGCar or _this isKindOf "UAZMG" or _this isKindOf "HMMWV50"
};

//
// _fuelCapacity = _vehicle call SYG_fuelCapacity;
// or
// _fuelCapacity = (typeOf _vehicle) call SYG_fuelCapacity;
//
SYG_fuelCapacity = {
	if ((typeName _this)=="OBJECT")then{_this=(typeOf _this)};
	getNumber(configFile >> "CfgVehicles" >> _this >> "fuelCapacity")
};

SYG_readSlots = {

private ["_readSlots"];
_readSlots = { getNumber ( configFile >> "CfgVehicles" >> _this >> "weaponSlots" ) };
_slotPrimary     = { (_this call _readSlots) % 2 };
_slotHandGun     = { floor((_this call _readSlots) / WeaponSlotHandGun ) % 2 };
_slotSecondary   = { floor((_this call _readSlots) / WeaponSlotSecondary ) % 4 };
_slotHandGunMag  = { floor((_this call _readSlots) / WeaponSlotHandGunMag ) % 16 };
_slotMag         = { floor((_this call _readSlots) / WeaponSlotMag ) % 16 };
_slotGoggle      = { floor((_this call _readSlots) / WeaponSlotGoggle ) % 8 };
_hardMounted     = { floor((_this call _readSlots) / WeaponHardMounted ) % 2 };
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
 * calls: _res = [_type, [_id1, _id2,..., _idN]] call SYG_makeTypeUndestructible;
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
				 if ( _dist < _mindist ) then {_mindist = _dist; _reta = [_x, _emptypos]};
			};
#ifdef __DEBUG__
			_str = _str + format["%1 cargo %2; ",typeOf _x, _emptypos];
#endif	
		}
#ifdef __DEBUG__
		else { _str = _str + "<null>; "}
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
	_str = "";
	{
		if ( count _x == 0 ) then {_str = _str + " <>"} else {_str = _str + format[" %1", round (_x distance _unit)]};
	} forEach _pos_arr;
	
	//hint localize format["SYG_utils.sqf.SYG_findGroupAtTargets: pos near ""%3"" [MSOA/ret] = [%1/%2]", _str, _ret, text (_pos call SYG_nearestLocation) ];
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
	if ( typeName _feetmen == "GROUP" ) then {_feetmen = units _feetmen;};

	_vecs = arg(1);
	scopeName "exit";
	if ( (count _vecs > 0) AND (count _feetmen > 0) ) then
	{
		_feetmen1 = [] + _feetmen;
		_vecs = [] + _vecs;
		// filter vehicles
		for "_i" from 0 to count _vecs - 1 do
		{
			_x = _vecs select _i;
			if ( !canMove _x OR isNull driver _x ) then {_vecs set [_i, "RM_ME"]};
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
					if ( (_x call SYG_ACEUnitUnconscious) OR (!isNull assignedVehicle _x) ) then { _feetmen1 set [_i, "RM_ME"] }; 
				};
			};
			_feetmen1 = _feetmen1 - ["RM_ME"];
			if ( count _feetmen1 > 0 ) then
			{
				_feetmen1 allowGetIn true;
#ifdef __SYG_ISLEDEFENCE_DEBUG__
				hint localize format["%1 SYG_findAndAssignAsCargo: reassigning to cargo %2 men with patrol vecs %3",call SYG_nowToStr,_feetmen1, _vecs];
#endif								
				while { (count _vecs > 0) AND (count _feetmen1) > 0 } do
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
					hint localize format["%4 SYG_findAndAssignAsCargo: %1 assignedToCargo %2 (%3) dist %5",_assigned, typeOf _veh, _veh, call SYG_nowToStr, _veh distance (_assigned select 0)];
#endif

				}; // while { (count _vecs > 0) AND (count _feetmen1) > 0 } do
			}; // if ( count _feetmen1 > 0 ) then
		}; // if ( count _vecs > 0 ) then 
	};
#ifdef __SYG_ISLEDEFENCE_DEBUG__
	hint localize format[ "%1 SYG_findAndAssignAsCargo: free feetmen remained %2", call SYG_nowToStr, _feetmen];
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
	if ( (!(isNull _this)) AND (alive _this) AND (_this isKindOf "LandVehicle")) then 
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
			} else {false}; // standing in good posiition
		};
	}
	else{false};
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
// call: _officer = ["SquareLeaderW", _grp|_unit] call Syg_ensureOfficerInGroup;
//
Syg_ensureOfficerInGroup = {
    private ["_officer","_grp"];
    _grp     = grpNull;
    _officer = arg(0);
    if ( typeName _officer != "STRING") exitWith {hint localize format["--- Syg_ensureOfficerInGroup -> Expected argument [_unit_type, ...] is not string type: %1", _this];};
    if ( !(_officer isKindOf "Man")) exitWith { hint localize format["--- Syg_ensureOfficerInGroup -> Expected argument [_unit_type, ...] is not kind of ""Man"": %1", _this];};

    _grp     = arg(1);
    switch (typeName _grp) do
    {
        case "GROUP":  {};
        case "OBJECT": { if (_grp isKindOf "Man") then {_grp = group _grp; } else { _grp = grpNull;}; };
        default {_grp = grpNull;};
    };

    if (isNull _grp) exitWith {hint localize format["--- Syg_ensureOfficerInGroup -> Expected argument [..., _grp] is illegal: %1", _this];};
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
    _officer = _grp createUnit [_officer, getPos (leader _grp), [], 10, "NONE"];
    [_officer] join _grp;
    sleep 0.3;
    (leader _grp) setRank "PRIVATE";
     _grp selectLeader _officer;
    _officer setRank "LIEUTENANT";
    _officer
};


if (true) exitWith {};
