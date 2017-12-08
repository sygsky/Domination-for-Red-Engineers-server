private [ "_unit", "_dist", "_lastPos", "_curPos", "_boat", "_grp", "_wplist","_startPos", "_procWP", "_wpIndex", "_unittype", "_stopBoat" ];
//#define __DEBUG_INTEL_MAP_MARKERS__

#include "x_setup.sqf"
#include "x_macros.sqf"

#define arg(x) (_this select(x))
#define argp(param,x) ((param)select(x))

#define argopt(num,val) (if(count _this<=(num))then{val}else{arg(num)})
#define argoptp(a,num,val) (if((count a)<=(num))then{val}else{argp(a,num)})
#define argoptskip(num,defval,skipval) (if((count _this)<=(num))then{defval}else{if(arg(num)==(skipval))then{defval}else{arg(num)}})

#define RANDOM_ARR_ITEM(ARR) (ARR select(floor(random (count ARR))))

#define DEFAULT_INTEL_MAP_MARKERS_PREFIX "IMM_"

#define ADD_1CARGO_TO_TRUCKS_AND_HMMW

if ( !isNil "SYG_utilsVehicles_INIT" )exitWith { hint "SYG_utilsVehicles already initialized"};
SYG_utilsVehicles_INIT = false;
hint localize "INIT of SYG_utilsVehicles";

//
// call: _veh_type call SYG_getVehicleType;
// or: _veh_object call SYG_getVehicleType;
// returns: [0..5,11] as for[tank(0),car/moto(1),static(2),heli(3),airplain(4),
//          ship(5),Rifle(6),MG(7),SideArm(8),Launcher(9),Explosive(10),
//          soldier(11)]
//         or -1 if not vehicle or weapon was designated at input
SYG_getVehicleType = {
	private ["_entry","_typeCfg","_typeNr"];
	_entry = _this;
	if (typeName _this == "OBJECT") then { _entry = typeName _this;};
	_typeCfg = configFile >> _entry >> "Library" >> "type";
	_entry = configFile >> _entry;
	_typeNr = -1;
	if ((configName _typeCfg) == "type") then 
	{
		_typeNr = getNumber _typeCfg;
		
		if ((_typeNr < 0) || (_typeNr > 11)) then  // illegal number, may be overrriden
		{
			//Assign correct type id.
			if ((configName(_entry >> "vehicleClass")) != "") then 
			{
				private ["_sim"];
				_sim = getText(_entry >> "simulation");
				
				_typeNr = switch (_sim) do 
				{
					case "tank": 
					{
						if (getNumber(_entry >> "maxSpeed") > 0) then 
						{
							0
						} 
						else 
						{
							//Static.
							2
						};
					};
					
					case "car": 
					{
						1
					};
					case "motorcycle":
					{ 
						1
					};
					
					case "helicopter": 
					{ 
						3
					};
					
					case "airplane": 
					{ 
						4
					};
					
					case "ship": 
					{ 
						5
					};
					
					case "soldier": 
					{
						11
					};
					default { -1 };
				};
			} // if ((configName(_entry >> "vehicleClass")) != "") then 
			else // may be weapon
			{
				private ["_type"];
				_type = getNumber (_entry >> "type");
				
				_typeNr = switch (_type) do 
				{
					//Rifles.
					case 1: 
					{
						6
					};
					
					//Sidearms.
					case 2: 
					{
						8
					};
					
					//Launchers.
					case 4: 
					{
						9
					};
					
					//Machineguns.
					case 5: 
					{
						//Check autofire to see this is a machinegun.
						if (getNumber(_entry >> "autoFire") == 1) then 
						{				
							7
						} 
						else 
						{
							//Probably a heavy sniper rifle.
							6
						};
					};
					
					default 
					{
						//Explosives?
						if ((_type % 256) == 0) then 
						{
							10	
						};
					};
				}; //switch (_type) do 
			};
		}; // if ((_typeNr < 0) || (_typeNr > 11)) then
	};
	_typeNr
};

//
// Finds near enemy "Man" or "LandVehicle"
//
// call _nenemy = [_unit<,_dist>] call SYG_detectedEnemy;
SYG_detectedEnemy = {
	private ["_enemy","_near_targets","_side","_eside","_target","_cost"];
	_unit = arg(0);
	_near_targets = _unit nearTargets argopt(1,300);
	_eside = if ((side _unit) == east) then  { west } else {east};
	_cost = -1000000;
	_enemy = objNull;
	{
	    _side = argp(_x,2);
	    if ( _side == _eside) then
	    {
	        _target = argp(_x,4);
	        if ( _target isKindOf "LandVehicle" && ((_unit knowsAbout _target) > 0.5)) then
	        {
	            if ( !(_target isKindOf "Man")) then // check vehicle to has crew
	            {
	                if ( ((crew _target) call XfGetAliveUnits) == 0 ) then
	                {
        	            _target = objNull;
	                };
	            };
	            if ( !(isNull _target)) then
	            {
    	            if ( _cost < argp(_x,3)) then {_cost = argp(_x,3); _enemy = argp(_x,4);};
    	        };
    	    };
	    };
	} forEach _near_targets;
	_enemy
};

//
// Call as:  _near_enemy = _unit call SYG_nearestEnemy;
//           _near_enemy = _grp call SYG_nearestEnemy;
// Returns: nearest enemy object or null if no enemy (with knowAbout > 0.5) found
// 
SYG_nearestEnemy = {
	private ["_enemy","_distance","_near_targets","_pos_nearest"];
	if (typeName _this == "GROUP") then
	{
   	    _this = leader _this;
	};
	if (isNull _this) exitWith{objNull};
	_enemy = _this findNearestEnemy _this;
	if (!(isNull _enemy) && (_this knowsAbout _enemy >= 0.5) && ((vehicle _enemy) isKindOf "CAManBase")) then {
		_distance = _this distance _enemy;
		_near_targets = _this nearTargets (_distance + 50);
		if (count _near_targets > 0) then {
			_pos_nearest = [];
			{
				if ((_x select 4) == _enemy) exitWith {
					_pos_nearest = _x select 0;
				};
				sleep 0.001;
			} forEach _near_targets;
			_near_targets = nil;
			if (count _pos_nearest == 0) then {
				_enemy = objNull;
			};
		};
	}
	else { _enemy = objNull; };
	_enemy
};					

//
// Parameters in input array:
// _unit: unit to find groups for. Groups can be crew in any vehicles (Man, Land, Air, Ship)
// _dist (optional): radious to find groups, default value is 500 m. Set to 0 or negative to use default
// _pos (optional): search center, if set to [], _unit pos is used
//
// Returns: array of groups found or [] if not found
//
// Usage:
// _grps = [_unit, _dist] call SYG_nearestGroups; // search around _unit at 500 m., return empty array [] if no group found
// _grps = [_unit, _dist, _pos] call SYG_nearestGroups; // search around _pos, return empty array [] if no group found
//
SYG_nearestGroups = {
	private ["_unit", "_dist", "_side", "_nearArr", "_grps", "_types" ];
	_unit = _this select 0;
	if ( isNull _unit || !alive _unit ) exitWith {[]};
	_grps = [];
	if ( !isNull _unit ) then
	{	
		_dist = 0;
		if ( (count _this ) > 1 ) then { _dist = _this select 1;};
		if (_dist <= 0) then { _dist = 500;};
		
		_pos = _unit;
		if ( (count _this ) > 2 ) then { _pos = _this select 2;};
		if ( typeName _pos == "ARRAY" ) then // use position array, check to be empty 
		{ 
			if ((count _pos) == 0) then {_pos = getPos _unit;};
		};
		
		_side = side _unit;
		_types = switch _side do
		{
			case east : {["SoldierEB","LandVehicle","Air","Ship"]};
			case west : {["SoldierWB","LandVehicle","Air","Ship"]};
			case civilian: {["Civilian","LandVehicle","Air","Ship"]};
			case resistance: {["SoldierGB","LandVehicle","Air","Ship"]};
			case default {["CAManBase","LandVehicle","Air","Ship"]};
		};
		_nearArr = nearestObjects [_pos, _types, _dist];
		{
			// find good, healhy, fast and agressive group for our man :o)
			if ( _x isKindOf "CAManBase") then
			{
				if (alive _x && ((side _x) == _side)) then
				{
					if (!(group _x in _grps)) then 
					{
						_grps = _grps + [group _x];
						sleep 0.01;
					};
				};
			}
			else // not a man, check for crew
			{
				if ( alive _x) then
				{
					if (( {alive _x} count crew _x) > 0 && (side _x == _side) ) then
					{
						_unit = objNull;
						{	
							if ( { alive _x } ) exitWith {_unit = _x;};
						} forEach (crew _x);
						
						if ( !isNull _unit) then 
						{
							if (!(group _unit in _grps)) then 
							{
								_grps = _grps + [group _unit];
								sleep 0.01;
							};
						};
					};
				};
			};
		} forEach _nearArr;
	};
	_grps
};

//
// call: _cnt = [[_zavora1, ... _zavoraN], _act] call SYG_openAllBarriers;
//
// returns number of objects processed
// Where _act may be 1 (to open) or 0 (to close)
//
SYG_execBarrierAction = {
	private ["_act", "_pos", "_ret", "_arr"];
	_act = arg(1);
	_ret = 0;
	if ( switch _act do {case 1; case 0: { true}; default {false};} ) then
	{
		_arr = arg(0);
		{
			_x animate ["BarGate",_act];
		} forEach _arr;
		_ret = count _arr; 
	};
	_ret
};

SYG_getSide = {
    if ( typeName _this == "OBJECT") exitWith { side _this };
    if ( typeName _this == "GROUP") exitWith { side _this };
    if ( typeName _this == "SIDE") exitWith { _this };
    if ( (typeName _side) == "STRING") exitWith
    {
        switch (toUpper(_this)) do
        {
            case "EAST": {east};
            case "WEST": {west};
            case "GUER": {resistance};
            case "CIV":  {civilian};
            case "LOGIC": {sideLogic};
            case "ENEMY": {sideEnemy};
            case "FRIENDLY": {sideFriendly};
        }
    };
    format["--- SYG_getSide: expected input ""%1"" is illegal with typeName is %2", _this, typeName _this]
};

//
// call: _unit call SYG_handleDammage; // to attach event handler on unit
//    OR
// [_unit, _selectionName, _damage] call SYG_handleDammage; // internal call on process event itself
//
SYG_handlePlayerDammage = {
	//hint localize format["*** SYG_handlePlayerDammage: called with %1", _this]; 
	if ( (typeName _this) == "OBJECT" ) exitWith
	{
		if ( isPlayer _this ) then
		{
			_this addEventHandler["dammaged", {_this call SYG_handlePlayerDammage}];
			hint localize format["*** SYG_handlePlayerDammage: handler set for %1", _this];
		}
		else
		{
			hint localize format["*** SYG_handlePlayerDammage: Expected initializing unit is not a player (%1)", _this];
		};
	};
	private ["_unit","_msg_id"];
	if ( (typeName _this) != "ARRAY" ) exitWith {};
	if ( (count _this) < 2 ) exitWith {};
	_unit = arg(0);
	if ( !(_unit call SYG_ACEUnitUnconscious) ) then 
	{
		_msg_id = switch (arg(1)) do
		{
			case "legs": {"STR_HIT_LEGS"};
			case "hands": {"STR_HIT_HANDS"};
			case "head": {"STR_HIT_HEAD"};
			case "head_hit": {"STR_HIT_HEAD_HIT_NUM" call SYG_getRandomText};
			case "body" : {"STR_HIT_BODY"};
			default {"STR_HIT_UNKNOWN"};
		};
        if ( (count _this) > 2 ) then
        {
    		hint localize format["*** SYG_handlePlayerDammage: player damaged %1",arg(2)];
        };
	}
	else
	{
		_msg_id =  "STR_HIT_UNCONSCIOUS";
		hint localize "*** SYG_handlePlayerDammage: player is unconscious";
	};
	titleText[ localize _msg_id, "PLAIN DOWN" ];
	titleFadeOut 3;
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
// for WEST enemy only
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

// call:
//      _town = [[10550,9375,0],"Paraiso", 405];
//      _params = [_town select 0,_town select 1, _town select 1, 0]; // for rectangle
//      _params = [_town select 0,_town select 1]; // for circle
//       _grp =  _params call SYG_makePatrolGroup;
SYG_makePatrolGroup = {
    if (typeName _this != "ARRAY") exitWith {hint localize format["--- SYG_makePatrolGroup: expected parameter in not ARRAY (%1)", _this] ;grpNull };
    private ["_agrp","_elist","_rand","_leader"];
	__WaitForGroup
	__GetEGrp(_agrp)
	_elist = [d_enemy_side] call x_getmixedliste;
	{
	    _rand = floor random 3;
		if ( _rand > 0) then
		{
			([_rand, [], _x select 1, _x select 0, _agrp, 30, -1.111] call x_makevgroup);
			sleep 0.73;
		};
	} forEach _elist;
	if ( (count units _agrp) == 0) then // No units at all, create random single one!
	{
	    _elist = _elist select (floor random (count _elist));
		([1,_start_point,_elist select 1,_elist select 0,_agrp,30,_dir] call x_makevgroup);
	};
	_elist = nil;
	sleep 0.31;
	_leader = leader _agrp;
	_leader setRank "LIEUTENANT";
	_leader setSkill (d_skill_array select 0) + (random (d_skill_array select 1));
	_agrp setFormation "COLUMN";
	_agrp setBehaviour "SAFE";
	_agrp setCombatMode "YELLOW";
	_agrp setSpeedMode "NORMAL";
    _agrp
    /*
	_grp_array = [_agrp, _start_point, 0,_params,[],-1,0,[],400 + (random 100),1, [0,false,true]]; // param 10: [no rejoin,no debug print,prevent wp on islet generation]
	_grp_array execVM "x_scripts\x_groupsm.sqf";
    */
};

//
// vehicle type identifiers:
// static
//
// aa - anti-aircraft
// at - anti-tank
// mg - machine guns
// cn - canons
// gl - grenade launcher
// st - secondary targetsAggregate
//
// use it as list of short strings: ["aa","at","mg","cn","gl"<,"st">]

WEAPONS_TYPE_ARR = [
	["Stinger_Pod","Stinger_Pod_East","ACE_ZU23M"/*,"ACE_ZU23"*/], // AntiAircraft
	["TOW_TriPod","TOW_TriPod_East","ACE_TOW","ACE_KonkursM"], // AntiTank
	["M2StaticMG","M2HD_mini_TriPod","DSHKM","DSHkM_Mini_TriPod","WarfareBEastMGNest_PK"], // MachineGun
	["M119","D30"], // CaNon
	["MK19_TriPod","AGS"] // GrenadeLauncher
];

//
// collects side static weapons array in circle with designated center and radious
// returns 6 entry array with different weapon type and secondary target
//
// call:
//
// _res_arr = [_side, _pos, _radius ] call SYG_sideDisposition;
// _res_arr will contains array of 5 arrays of known types (see above) and 1 object, 
// each sub-array contains list of object with corresponding type e.g.:
// [[aa1,..., aaN],[at1,...,atN],..., st1]. 
// If no vehicles of predefined type detected, empty sub array is returned. 
// If secondary target is already killed, objNull is returned as 6th entry of resulted array
//
SYG_sideStaticWeapons = {

#define EMPTY_RETURN_ARRAY [[],[],[],[],[],objNull]

	private ["_mgs","_aas","_ats","_gls","_cns"/* ,"_wpa", */"_ret","_unk","_side","_pos","_dist","_arr","_vec","_type","_found","_i"];

/* 	_mgs = ["M2StaticMG","M2HD_mini_TriPod","DSHKM","DSHkM_Mini_TriPod","WarfareBEastMGNest_PK"];
	_aas = ["Stinger_Pod","Stinger_Pod_East","ACE_ZU23M","ACE_ZU23"];
	_ats = ["TOW_TriPod","TOW_TriPod_East","ACE_TOW","ACE_KonkursM"];
	_gls = ["MK19_TriPod","AGS"];
	_cns = ["M119","D30"];
	_wpa = [_aas,_ats,_mgs,_cns,_gls];
 */	_ret = EMPTY_RETURN_ARRAY;
	_unk = []; // unknown type objects array
	_side = arg(0);
	_side = _side call SYG_getSide;
	if ( (typeName _side) == "STRING") exitWith 
	{
		hint localize format["--- call to SYG_sideStaticWeapons failed -> %1",_side];
		EMPTY_RETURN_ARRAY
	};

	_pos = argopt(1,[]);
	if ( (typeName _pos) == "OBJECT") then { _pos = position _pos; };
	if ( count _pos != 3 ) exitWith 
	{ 
		hint localize format["--- SYG_sideStaticWeapons: expected pos illegal or absent ""%1""", _pos];EMPTY_RETURN_ARRAY
	};

	_dist = argopt(2,-1);
	if ( _dist < 0 ) exitWith 
	{
		hint localize "--- SYG_sideStaticWeapons: expected search radious absent";
		EMPTY_RETURN_ARRAY
	};
	
	_arr = _pos nearObjects [ "StaticWeapon", _dist];
	{ // forEach _arr;
		if ( (side _x) == _side ) then
		{
			_vec = _x;
			_type = typeOf _x;
			_found = false;
			for "_i" from 0 to (count WEAPONS_TYPE_ARR) - 1 do
			{
				if ( _type in (WEAPONS_TYPE_ARR select _i) ) exitWith 
				{ 
					_rar = _ret select _i; _rar set [count _rar, _vec]; _found = true;
				};
			};
			if ( !_found ) then {_unk set [count _unk, _vec];};
		};
		sleep 0.01;
	} forEach _arr; // _aas,_ats,_mgs,_cns,_gls
	if ((count _unk) > 0) then
	{
		for "_i" from 0 to ((count _unk) - 1) do
		{
			_unk set [ _i, typeOf  (_unk select _i) ];
		};
	};
	 // TODO: add info about secondary target to the array
#ifdef __DEBUG_INTEL_MAP_MARKERS__	 
	hint localize format["SYG_sideStaticWeapons: AA %1, AT %2, MG %3, CN %4, GL %5, ST not realized, UN %6", count (_ret select 0),count (_ret select 1),count (_ret select 2), count (_ret select 3), count (_ret select 4), _unk];
#endif	
	_arr = [];
	_ret
};

/*
 Collect side info in circle with designated center and radious
 
 call as: _info_arr = [_side, _pnt, _radious] call SYG_sideStat;
 
 returns: [_men, _statics, _tanks, _bmps, _cars, _aa, _canons]
*/
SYG_sideStat = {
	private [ "_side","_pos","_arr","_men","_statics","_tanks","_bmps","_cars","_aa","_canons","_c1arr","_c2arr" ];
	_side = arg(0);
	if (typeName _side == "OBJECT") then 
	{
		_side = side _side;
	};
	if ( typeName _side != "SIDE" ) exitWith {hint localize format["--- SYG_sideStat: expected side illegal ""%1""", _side];[0,0,0,0,0,0]};
	_pos = argopt(1,[]);
	if ( count _pos != 3 ) exitWith {hint localize format["--- SYG_sideStat: expected pos illegal or absent ""%1""", _pos];[0,0,0,0,0,0]};
	_dist = argopt(2,-1);
	if ( _dist < 0 ) exitWith {/* hint localize "--- SYG_sideStat: expected search radious absent"; */[0,0,0,0,0,0]};
	
	_arr = nearestObjects [ _pos, ["Land"], _dist];
	_men = 0;
	_statics = 0;
	_tanks   = 0;
	_bmps    = 0;
	_cars    = 0;
	_aa      = 0;
	_canons  = 0;
	_c1arr   = [];
	_c2arr   = [];
	{
		if (_side == side _x) then
		{
			if ( _x isKindOf "CAManBase") then {_men = _men +1;}
			else {
				if ( _x isKindOf "StaticWeapon") then 
				{
					if ( _x isKindOf "Stinger_Pod" ) then 
					{
						_aa = _aa +1;
					} 
					else 
					{
						if ( _x isKindOf "D30" OR _x isKindOf "M119" ) then 
						{
							_canons = _canons + 1;
						}
						else { _statics = _statics +1;};
					};
				} 
				else {
					if ( _x isKindOf "Tank") then 
					{
						if ( _x isKindOf "T72" OR _x isKindOf "M1Abrams") then {_tanks = _tanks+1;}
						else { _bmps = _bmps +1; };
					} else {
						if ( _x isKindOf "Car") then 
						{
							if ( _x isKindOf "StrykerBase"  OR _x isKindOf "BRDM2") then 
							{ 
								if ( ! ((typeOf _x) in ["BMP2_MHQ","BMP2_MHQ_unfolded","M113_MHQ","M113_MHQ_unfolded"]) ) then {_bmps = _bmps +1;};
							} else {_cars = _cars+1;};
						};
					};
				};
			};
		};
	}forEach _arr;
	_arr = [];
	[_men, _statics, _tanks, _bmps, _cars, _aa, _canons];
//	hint localize format["SYG_sideStat: size %1, men %2, static %3, tank %4, apc %5, car %6, aa %7",_side,_men,_statics,_tanks,_bmps,_cars,_aa];
};

#define SCORE_PER_KILOMETER 5
//
//	call as: _score = [_pos, _dist<,true|false>] call SYG_getScore4IntelTask;
//
SYG_getScore4IntelTask = {
	hint localize format["SYG_getScore4IntelTask: %1", _this];
	private ["_town_center","_dist","_hint","_stat","_stat1","_info","_info1","_arr", "_resultScore"];
	_town_center = argopt(0,[]);
	if ( count _town_center != 3) exitWith {hint localize format["--- SYG_getScore4IntelTask: expected center position is illegal or absent"]; -1};
	
	_dist = argopt(1,300);
	_hint = argopt(2,false);

	_info  = [west, _town_center, _dist] call SYG_sideStat;
	_stat = _info call SYG_stat2Score;
	if ( _hint ) then
	{
		hint localize format["West stat on TOWN: side %1, cnt %8, score %9, men %2, static %3, tank %4, apc %5, car %6, aa %7, canon %10", west, argp(_info,0),argp(_info,1),argp(_info,2),argp(_info,3),argp(_info,4),argp(_info,5), argp(_stat,0), argp(_stat,1), argp(_info,6)];
	};

	_info1  = [east, _town_center, _dist] call SYG_sideStat;
	_stat1 = _info1 call SYG_stat2Score;
	if ( _hint) then
	{
		hint localize format["East stat on town: side %1, cnt %8, score %9, men %2, static %3, tank %4, apc %5, car %6, aa %7, canon %10", east,argp(_info1,0),argp(_info1,1),argp(_info1,2),argp(_info1,3),argp(_info1,4),argp(_info1,5), argp(_stat1,0), argp(_stat1,1), argp(_info1,6)];
//#ifdef __DEBUG_INTEL_MAP_MARKERS__
//		_arr = [ west, _town_center, _dist ] call SYG_sideStaticWeapons;
//		[ _arr ] call SYG_resetIntelMapMarkers;
//#endif		
	};

//	_arr = nearestObjects [_town_center, ["BMP2_MHQ"], _dist + 100];
	_arr = _town_center nearObjects ["BMP2_MHQ",_dist+100];
	
	// count as follow: result score is divided by MHQ count and subtracted by friends score multiplied by 2
	_resultScore = (argp(_stat,1)/((count _arr)+1)-argp(_stat1,1)*2) max 0;
	_resultScore = if ( _resultScore > 0) then { round(_resultScore/10)*10} else {0};
	
	// also take into account distance from base to targetsAggregate
	_dist = _town_center call SYG_distToGRUComp; // dist to GRU computer
	_dist = floor(_dist / 1000);
	_resultScore = _resultScore + _dist * SCORE_PER_KILOMETER;
	
	if ( _hint) then
	{
		hint localize format["******** Result score for town is %1 (dist %5) / %2  - %3 == %4",argp(_stat,1), ((count _arr) +1),argp(_stat1,1) * 2, _resultScore, _dist];
	};
	_resultScore
};

//
// calculates score from statistics (by SYG_sideStat) 
// Input array is: [_men, _statics, _tanks, _bmps, _cars, _aa, _canons]
//
SYG_stat2Score = {
	private ["_val","_cnt","_score","_weight"];
	_cnt   = 0;
	_score = 0;
	for "_i" from 0 to count _this -1 do
	{
		_val = arg(_i);
		_cnt = _cnt + _val;
		_weight = switch _i do
		{
			case 0: {1}; // men
			case 4;      // car
			case 5;      // aa
			case 1: {2}; // static
			case 6;      // canon
			case 2: {4}; // tank
			case 3: {3}; // apc
		};
		_score = _score + _val * _weight;
	};
	[_cnt,_score]
};

// marker types corresponding to entries in stat weapon array
SYG_markerTypes        = ["ACE_Icon_AirDefenceGun","ACE_Icon_AntiTank","ACE_Icon_Machinegun","ACE_Icon_Howitzer","ACE_Icon_GrenadeLauncher","Marker"];
SYG_markerScales       = [0.6,0.5,0.5,1,0.5,0.3];
SYG_markerPrefixNames  = [DEFAULT_INTEL_MAP_MARKERS_PREFIX]; // names of prefixes used
SYG_markerPrefixCounts = [0]; // count of markers with designated prefixes

//
// Input: array with static objects, namely:  [aas,ats,mgs,cns,gls,st]
// call:
//       [_stat_obj_arr<, _prefix, _cnt>] call SYG_resetIntelMapMarkers;
//
// where: _prefix is string prefixed all new and old markers, e.g. default one is "IMM_", that stands for Intel Map Markers
//        _cnt is number of previous markers created with designated prefix. 
// if _prefix not designated, default prefix "IMM_" used and SYG_intelMapMarkersNum as _cnt
//
// Action:
//		   1. Remove all previous known markers
//         2. draw new markers for intel objects
// Returns:
//         number of markers created
//
SYG_resetIntelMapMarkers = {
	private ["_arr","_tarr","_prefix","_ind","_cnt","_i","_scale","_pos","_marker","_mrk_type"];
	
	if ( count _this < 1) exitWith {false};
	_arr = arg(0);
	_prefix = argopt(1, DEFAULT_INTEL_MAP_MARKERS_PREFIX);
	_ind = SYG_markerPrefixNames find _prefix;
	_cnt = 0;
	if ( _ind < 0 ) then
	{
		_ind = count SYG_markerPrefixNames;
		SYG_markerPrefixNames  set [ _ind, _prefix ];
		SYG_markerPrefixCounts set [ _ind, 0 ];
	}
	else
	{
		_cnt = SYG_markerPrefixCounts select _ind;
		_prefix call SYG_removeMarkers; // always clear all previous intel markers
		_cnt = 0;
	};
//	for "_i" from 0 to 4 do // ["aa","at","mg","cn","gl","st"]
	for "_i" from 0 to (count SYG_markerTypes - 2) do // last marker still not used
	{
		_mrk_type = SYG_markerTypes select _i; // marker type
		_scale    = SYG_markerScales select _i; // marker scale
		_tarr     = _arr select _i;
	
		{ // for each found weapon type list 
			_cnt = _cnt + 1; // start marker name will be (_prefix + "1")
			_pos = position _x;
			_marker = format["%1%2",_prefix,_cnt]; // marker unique name
			[ _marker, _pos, "ICON", "ColorBlack", [_scale,_scale],"",0,_mrk_type] call XfCreateMarkerLocal;
		}forEach _tarr;
	};
	SYG_markerPrefixCounts set[_ind, _cnt]; // store prefix markers count into existance list
#ifdef __DEBUG_INTEL_MAP_MARKERS__	 
	hint localize format["SYG_resetIntelMapMarkers: AA %1, AT %2, MG %3, CN %4, GL %5, ST 0, whole cnt %6", count (_arr select 0),count (_arr select 1),count (_arr select 2),count (_arr select 3),count (_arr select 4), _cnt];
#endif		
	_cnt
};

// call: _exists = _prefix call SYG_hideIntelMarkers;
SYG_hideIntelMarkers = {
#ifdef __DEBUG_INTEL_MAP_MARKERS__	 
	hint localize format["SYG_hideIntelMarkers: hidden %1", _this];
#endif		
	[_this, "ACE_ColorTransparent"] call SYG_colorIntelMarkers
};

SYG_hideDefaultIntelMarkers = {
	DEFAULT_INTEL_MAP_MARKERS_PREFIX call SYG_hideIntelMarkers
};

// call: _exists = _prefix call SYG_showIntelMarkers;
SYG_showIntelMarkers = {
#ifdef __DEBUG_INTEL_MAP_MARKERS__	 
	hint localize format["SYG_showIntelMarkers: show   %1", _this];
#endif		
	[_this, "ColorBlack"] call SYG_colorIntelMarkers
};

SYG_showDefaultIntelMarkers = {
	DEFAULT_INTEL_MAP_MARKERS_PREFIX call SYG_showIntelMarkers
};

// call: _exists = [_prefix_known,_color]  call call SYG_colorIntelMarkers;
SYG_colorIntelMarkers = {
	private ["_prefix","_ind","_color","_cnt","_i"];
	_prefix = arg(0);
	_ind = SYG_markerPrefixNames find _prefix;
	if ( _ind < 0 ) exitWith {false};
	_color  = arg(1);
	_cnt = SYG_markerPrefixCounts select _ind;
	for "_i" from 1 to _cnt do
	{
		format["%1%2",_prefix, _i] setMarkerColorLocal _color;
	};
	true
};

// removes all previous markers with known prefix (must be present in list of previously drawn prefixes)
//
// call: _exists = _prefix call SYG_removeMarkers;
//
SYG_removeMarkers = {
	private ["_cnt","_i","_ind","_marker"];
	_ind = SYG_markerPrefixNames find _this;
	if (_ind < 0) exitWith {false};
	_cnt = SYG_markerPrefixCounts select _ind;
#ifdef __DEBUG_INTEL_MAP_MARKERS__	 
	hint localize format["SYG_removeMarkers: removed %1 marker[s] of %2", _cnt,_this];
#endif		
	
	if ( _cnt > 0 ) then
	{
		for "_i" from 1 to _cnt do
		{
			_marker = format["%1%2",_this,_i];
			deleteMarkerLocal _marker;
		};
		SYG_markerPrefixCounts set [_ind, 0];
	};
	true
};

SYG_removeIntelStatWpnMarkers = 
{
	DEFAULT_INTEL_MAP_MARKERS_PREFIX call SYG_removeMarkers;
};

// return true if prefix is known and is stored in internal list else false
SYG_prefixExists = {
	(SYG_markerPrefixNames find _this) >= 0
};

// returns -1 if no such prefix else return number of markers with such prefix (0 .. N)
SYG_prefixCount = {
if (call SYG_prefixExists) then {SYG_markerPrefixCounts select (SYG_markerPrefixNames find _this)} else {-1}
};

// call: call SYG_buildIntelLegend;
SYG_buildIntelLegend = {
	if (SYG_intelLengedAlreadyBuilt) exitWith {};
	// TODO: build legend markers
};
// call: call SYG_buildIntelLegend;
SYG_removeIntelLegend = {
	if (!SYG_intelLengedAlreadyBuilt) exitWith {};
	// TODO: remove legend markers
};

//
// set handler for "hit" event if vehicle has a smoke magazines in inventory
//
// Call: _isAssingedToSmoke = _vec call SYG_assignVecToSmokeOnHit;
//
SYG_assignVecToSmokeOnHit =
{
    if (!d_smoke) exitWith {false}; // not allowed in setup
    if ( (typeName _this) != "OBJECT") exitWith {false};
    if (!(_this isKindOf "LandVehicle")) exitWith{false}; // only for land vehicles
    // check if vehicle support smoke magazines in common list of magazines
    private ["_magazines"];
    _magazines = getArray (configFile >> "CfgVehicles" >> _type >> "Turrets" >> "MainTurret" >> "magazines");
        //_magazines = getArray(_config >> "magazines");
    if ( "ACE_LVOSS_Magazine" in _magazines ) exitWith { _this addEventHandler ["hit", {_this spawn x_dosmoke2}]; true }; // add smoking protection
    false
};


//------------------------------------------------------------- Rearm vehicles methods

#ifdef __REARM_SU34__
SYG_su34_RearmTables =
[
 ["ACE_Su34B","ACE_Su34"], // plane names
 [	// plane params
	 [ // 1st plane params
		["ACE_TunguskaMgun30", "ACE_R73Launcher","ACE_Kh29LLauncher", "ACE_FAB500M62BombLauncher", "ACE_FFARPOD2" ],
		["ACE_3UOF8_1904", "ACE_6Rnd_R73", "ACE_6Rnd_Kh29L", "ACE_6Rnd_Kh29L", "ACE_12Rnd_FAB500M62", "ACE_70mm_FL_FFAR_38", "ACE_70mm_FL_FFAR_38"]
	 ],
	 [ // 2nd plane params
		["ACE_TunguskaMgun30", "ACE_R73Launcher","ACE_S8Launcher","ACE_FFARPOD2", "ACE_FAB500M62BombLauncher" ],
		["ACE_3UOF8_1904", "ACE_6Rnd_R73", "ACE_120Rnd_S8T", "ACE_70mm_FL_FFAR_38","ACE_70mm_FL_FFAR_38", "ACE_12Rnd_FAB500M62"/*, "ACE_12Rnd_FAB500M62"*/]
	 ]
 ]
];

SYG_heliRearmTable =
[
    // heli names, Mi24 can't be rearmed, doesnt try to do it
 ["ACE_Mi24D","ACE_Mi24V","ACE_Ka50","ACE_Ka50_N","ACE_Mi17_MG", "ACE_Mi17"],
 	// heli params
 [
 	 [ // 1st heli params
 	 	["M197", "ACE_9M17PLauncher"/*, "ACE_57mm_FFAR", "ACE_FFARPOD2"*/],
     	["750Rnd_M197_AH1", "ACE_4Rnd_9M17P"/*,"ACE_128Rnd_57mm", "ACE_70mm_FL_FFAR_38"*/]
 	 ],
 	 [ // 2nd heli params
 	 	["ACE_M230", "ACE_9M114Launcher"/*, "ACE_57mm_FFAR", "ACE_FFARPOD2"*/],
	    ["ACE_M789_1200", "ACE_8Rnd_9K114"/*, "ACE_128Rnd_57mm", "ACE_70mm_FL_FFAR_38"*/]
 	 ],
 	 [ // 3rd heli params
 	 	["ACE_GSh302", "ACE_FFARPOD2", "VikhrLauncher"],
	    ["ACE_750Rnd_30mm_GSh302", "ACE_70mm_FL_FFAR_38", "12Rnd_Vikhr_KA50"]
 	 ],
 	 [ // 4th heli params
 	 	["ACE_GSh302", "ACE_FFARPOD2", "VikhrLauncher"],
	    ["ACE_750Rnd_30mm_GSh302", "ACE_70mm_FL_FFAR_38", "12Rnd_Vikhr_KA50"]
 	 ],
     [ // 5th heli params
        ["ACE_YakB"],
        ["ACE_1470Rnd_127x108_YakB"]
     ],
     [ // 6th heli params
        ["ACE_57mm_FFAR", "ACE_FFARPOD2"],
        ["ACE_128Rnd_57mm", "ACE_70mm_FL_FFAR_38", "ACE_70mm_FL_FFAR_38"]
     ]
 ]
];

SYG_carRearmTable =
[
 ["ACE_UAZ_MG"], // car  names
 [	// heli params
 	 [ // 1st heli params
 	 	["ACE_YakB"],
     	["ACE_1470Rnd_127x108_YakB","ACE_1470Rnd_127x108_YakB"]
 	 ]
 ]
];

SYG_vehiclesRearmTables =
[
 argp(SYG_su34_RearmTables,0) + argp(SYG_heliRearmTable,0) + argp(SYG_carRearmTable,0),
 argp(SYG_su34_RearmTables,1) + argp(SYG_heliRearmTable,1) + argp(SYG_carRearmTable,1)
];

// call: _vtbl = _su34_type call SYG_getVehicleTable;
// returns array: [[vec_wpn1,...,vec_wpn#],[vec_mgz1,...,vec_mgz#]]
//   or [] if vehicle not found in rearm table
SYG_getSu34Table =
{
    if ( typeName _this == "OBJECT") then {_this = typeOf _this};
    if (typeName _this != "STRING") exitWith {[]};
    private ["_list", "_pos"];
    _list = argp(SYG_su34_RearmTables,0);
    //player groupChat format["SYG_getVehicleTable: %1", _this];
    _pos =  _list find _this;
    if ( _pos < 0) exitWith {[]}; // no such vehicle
    _list = argp(argp(SYG_su34_RearmTables,1),_pos);
    [argp(_list,0), argp(_list,1)]
};

// call: _vtbl = _su34 call SYG_getVehicleTable;
// returns array: [[vec_wpn1,...,vec_wpn#],[vec_mgz1,...,vec_mgz#]]
//   or [] if vehicle not found in rearm table
SYG_getHeliTable =
{
    if ( typeName _this == "OBJECT") then {_this = typeOf _this};
    if (typeName _this != "STRING") exitWith {[]};
    private ["_list", "_pos"];
    _list = argp(SYG_heliRearmTable,0);
    //player groupChat format["SYG_getVehicleTable: %1", _this];
    _pos =  _list find _this;
    if ( _pos < 0) exitWith {[]}; // no such vehicle
    _list = argp(argp(SYG_heliRearmTable,1),_pos);
    [argp(_list,0), argp(_list,1)]
};

// gets any table for designated vehicle/type
// call: _vtbl = [_vec,table] call SYG_getVehicleTable;
// returns array: [[vec_wpn1,...,vec_wpn#],[vec_mgz1,...,vec_mgz#]]
//   or [] if vehicle not found in rearm table
SYG_getAnyTable =
{
    private ["_list", "_table", "_pos","_vec"];
    _vec = arg(0);
    if ( typeName _vec == "OBJECT") then {_vec = typeOf _vec};
    if (typeName _vec != "STRING") exitWith {[]};
    _table = arg(1);
    _list = argp(_table,0);
    //player groupChat format["SYG_getTable: %1", _vec];
    _pos =  _list find _vec;
    if ( _pos < 0) exitWith {[]}; // no such vehicle
    _list = argp(argp(_table,1),_pos);
    [argp(_list,0), argp(_list,1)]
};


// call: _vtbl = _su34 call SYG_getVehicleTable;
// returns array: [[vec_wpn1,...,vec_wpn#],[vec_mgz1,...,vec_mgz#]]
//   or [] if vehicle not found in rearm table
SYG_getVehicleTable =
{
    if ( typeName _this == "OBJECT") then {_this = typeOf _this};
    if (typeName _this != "STRING") exitWith {[]};
    private ["_list", "_pos"];
    _list = argp(SYG_vehiclesRearmTables,0);
    //player groupChat format["SYG_getVehicleTable: %1", _this];
    _pos =  _list find _this;
    if ( _pos < 0) exitWith {[]}; // no such vehicle
    _list = argp(argp(SYG_vehiclesRearmTables,1),_pos);
    [argp(_list,0), argp(_list,1)]
};

//
// call:
//      _vecTbl = _vec call SYG_getVehicleTable;
//      _res = ([_vec] + _vecTbl) call SYG_rearmVehicle;
//
SYG_rearmVehicle =
{
    if ( typeName _this != "ARRAY") exitWith {false};
    if ( count _this < 3) exitWith {false};
    private ["_vec"];
    //player groupChat format["SYG_rearmVehicle: %1", _this];
    _vec = arg(0);
    {_vec removeMagazines _x} forEach magazines _vec;
    {_vec removeWeapon _x} forEach weapons _vec;
	{
		_vec addMagazine _x;
	} forEach arg(2); // magazines
	{
		_vec addWeapon _x;
	} forEach arg(1);  // weapons
	true
};

// call:      _res = _this call SYG_rearmVehicleA;
SYG_rearmVehicleA = {
    private ["_list"];
    _list = _this call SYG_getVehicleTable;
    if ( count _list == 0) exitWith {false};
    //player groupChat format["SYG_rearmVehicleA: %1", [_this] + _list];
    ([_this] + _list) call SYG_rearmVehicle
};

// call:      _res = _this call SYG_rearmAnySu34;
SYG_rearmAnySu34 =
{
    private ["_list"];
    _list = _this call SYG_getSu34Table;
    if ( count _list == 0) exitWith {false};
    //player groupChat format["SYG_rearmAnySu34: %1", [_this] + _list];
    ([_this] + _list) call SYG_rearmVehicle
};


// call:      _res = _this call SYG_rearmAnyHeli;
SYG_rearmAnyHeli =
{
    private ["_list"];
    _list = _this call SYG_getHeliTable;
    if ( count _list == 0) exitWith {false};
    //player groupChat format["SYG_rearmAllMi24: %1", [_this] + _list];
    ([_this] + _list) call SYG_rearmVehicle
};
#endif

// generates report about damaged parts of vehicle
// Call as: _dmg_report_str = _unit call SYG_ACEDamageReportStr;
//
// Returned: _dmg_report_str = "Turret, Hull, Engine, Tracks"
//
SYG_ACEDamageReportStr = {
    if ( (typeName _this) != "OBJECT" ) exitWith {""};
    if ( !(_this isKindOf "Tank")) exitWith {""};
    private ["_varTurret","_varEngine","_varHull","_varTracks","_ret"];
    _ret = "";
    _varTurret = _veh getVariable "ACE_TurretHit";
    if ( !isNil _varTurret) then
    {
        if (_varTurret == "1") then {_ret = "башня"};
    };
    _varEngine = _veh getVariable "ACE_EngineHit";
    if ( !isNil _varEngine) then
    {
        if (_varEngine == "1") then {_ret = _ret + " двигатель"};
    };
    _varHull = _veh getVariable "ACE_HullHit";
    if ( !isNil _varHull) then
    {
        if (_varHull == "1") then {_ret = _ret + " корпус"};
    };
    _varTracks = _veh getVariable "ACE_TracksHit";
    if ( !isNil _varTracks) then
    {
        if (_varTracks == "1") then {_ret = _ret + " гусениц[а|ы]"};
    };
    //hint localize format["ACE_TurretHit=%1, ACE_EngineHit=%2, ACE_HullHit=%3, ACE_TracksHit=%4",_varTurret,_varEngine,_varHull,_varTracks ];
    _ret

};

/*
 * Creates one group on enemy side, return created group:
 * _enemy_grp = call SYG_createEnemyGroup;
 */
SYG_createEnemyGroup =
{
    while {!can_create_group} do {sleep 0.1 + random (0.2)};//__WaitForGroup
    [d_enemy_side] call x_creategroup //__GetEGrp(_agrp)
};
//------------------------------------------------------------- END OF INIT
//------------------------------------------------------------- END OF INIT
//------------------------------------------------------------- END OF INIT
SYG_utilsVehicles_INIT = true;
hint localize "INIT of SYG_utilsVehicles completed";
if ( true ) exitWith {};


