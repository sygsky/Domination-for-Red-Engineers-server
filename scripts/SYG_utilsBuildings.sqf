/**
 *
 * SYG_utilsBuildingGeo.sqf : utils for building functions
 *
 */
 
#include "x_macros.sqf"

#define __DEBUG_PRINT___

#define inc(x) (x=x+1)
#define arg(x) (_this select(x))
#define argp(a,x) ((a)select(x))

#define argopt(num,val) (if((count _this)<=(num))then{val}else{arg(num)})
#define argoptp(a,num,val) (if((count a)<=(num))then{val}else{argp(a,num)})
#define argoptskip(num,defval,skipval) (if((count _this)<=(num))then{defval}else{if(arg(num)==(skipval))then{defval}else{arg(num)}})

SYG_illegalHouseList = ["Land_hut_old02","Land_podesta_1_mid_cornl","Land_podesta_1_mid_cornp","Land_podesta_1_cornl","Land_podesta_1_mid","Land_dum_istan2","Land_dum_istan2_02","Land_dum_istan2b","Land_dum_istan3","Land_dum_istan4","Land_dum_istan4_inverse","Land_dum_zboreny_total","Land_zastavka_sever","Land_sara_domek_hospoda","Land_leseni2x","Land_leseni4x","Land_water_tank","Land_Nasypka","Land_strazni_vez"];
//
// call: _teleport_info = [[_center,_town_name, _town_radious...]<, _teleport_dist(150)<,_min_pos_cnt(4)>>] call SYG_teleportToTown;
//
// returns: 1 - good, 0 - bad input parameters, -1 - no house found in town to teleport to
//
SYG_teleportToTown = {	
	private ["_town_params","_ret","_dist_arr","_town_center","_tname","_param"];
	_ret = 1; // success return code
	if ( typeName _this != "ARRAY") exitWith {0};
	_town_params = arg(0);
	if ( typeName _town_params != "ARRAY") exitWith {0};
	private ["_dist","_town_center","_tname", "_nb","_cnt","_param","_pos_id","_dist_arr","_cnt","_dist","_nb"];
	_dist_arr = argopt(1,[150]);
	if ( typeName _dist_arr == "SCALAR") then
	{
		if ( _dist_arr < 150) then { _dist_arr = [_dist_arr,150]; }
		else { _dist_arr = [_dist_arr]; };
	};
	_town_center = argp( _town_params, 0 );
	_tname = argp( _town_params, 1 );
	_param = switch _tname do
	{
		case "Somato": { [179675,429139]};
		case "Ortego": {[535829,527178,535824,527163,527185,528302,135355,534199]};
		case "Cayo": {[8465,9379,596469]};
		case "Bagango": {[450621,453210,187718]};
		case "Everon": {[31515,4292,139159,483661]};
		case "Pacamac": {[133215,9298,134046,144583]};
		case "Mataredo": {[485365]};
		case "Carmen": {[445639,193094]};
		case "Rahmadi": {[483108,486014]};
		case "Corazol": {[3196,3528,429748,429434]};
		case "Dolores": {[1117,562403]};
		case "Geraldo": {[10881,554947]};
		case "Corinto": {[62,66,171519,171520]};
		case "Estrella": {[406184,406180,616895]};
		case "Gulan": {[410198,410199]};

		default {SYG_illegalHouseList};
	};
	
	if ( count _param == 0) then { _param = SYG_illegalHouseList; }; // if list of preselected buildings is empty (they are destroyed etc)
	_cnt = argopt(2,4); // min number of positions for house to be good one
	if ( _cnt < 1 ) then { _cnt = 2; };
	_dist = _dist_arr select 0;
	_nb = objNull;
	{	
		_dist = _x;
		_nb = [_town_center, _cnt, _dist, _param] call SYG_nearestGoodHouse;
		if ( !isNull _nb) exitWith {};
	}forEach _dist_arr;
	
	if ( !isNull _nb ) then {
		_pos_id = [_nb, "RANDOM_CENTER", 20] call SYG_teleportToHouse;
#ifdef __DEBUG_PRINT___
		hint localize format[ "--- SYG_teleportToTown: teleport tt %1, _nb pos %2, _pos_id %3", _town_params, getPos _nb, _pos_id ];
#endif
		sleep 0.01;
	} else {
#ifdef __DEBUG_PRINT___
		hint localize format[ "--- SYG_teleportToTown: house at town %1 with min pos count %2 at dist from center %3 not found", _tname, _cnt, _dist ];
#endif
		_ret = -1;
	};
	_ret
};


// returns number of building positions (LOD), 0 (zero) if no such one
// call: _posCnt = _house call SYG_housePosCount;
SYG_housePosCount = {
	private ["_pos","_ret"];
	_pos = [1, 1, 1];
	_ret = 0;
	for "_i" from 0 to 1000 do {
		_pos = _this buildingPos _i;
		if (format["%1", _pos] == "[0,0,0]" ) exitWith {_ret = _i;};
	};
	_ret
};

//
// Finds building nearest to designated position with number of positions >= minPosCnt value
//
// call: _ngb = [_pos<,_minPosCnt(5)<,_minSearchDist(100)<,_spec_list([])>>>] call SYG_nearestGoodHouse;
//
//  or to seek in house list
//
// call: _ngb = [_house_list<,_minPosCnt<,_minSearchDist<,_spec_list([])>>>] call SYG_nearestGoodHouse;
//
// Where:
//		_pos is a center position of search 
//      _house_list is resulting array of buildings after call to nearestObjects [...,["House"],...]. No search will be produced, only filtering of this list
//		_minPosCnt - minimal house positions count to take house into accounts, default 3
//		_minSearchDist - maximum distance from search point, default 100
//		_spec_list - list of strings with prohibited house types filtered out (never used as result), default []
//		_spec_list - list of _id of Arma map objects, used as params to call to _pos nearestObject _id, to be used except of call to nearestObjects, default []
// returns: filtered in nearest house or objNull if no such one
SYG_nearestGoodHouse = {
	private ["_pos","_arr","_minPosCnt","_minSearchDist","_obj","_spec_list","_good_type","_type","_i","_cnt","_cnt1",
	"_max", "_id"];
	_pos           = arg(0);
	_minPosCnt     = argopt(1,3); // default minimum positions
	_minSearchDist = argopt(2,100); // default distance from search center
	_spec_list     = argopt(3,[]);

	_arr = [];
	if ( typeName _pos == "ARRAY" ) then {
		if ( count _pos > 0 ) then {
			_obj = _pos select 0;
			if ( typeName _obj == "OBJECT" ) then {
				if ( _obj isKindOf "House" ) then {
					_arr = _pos; // list of houses is detected not position
				};
			};
		};
	};
	if ( count _pos == 0) exitWith {objNull}; // illegal search center/house list designated

	_obj = objNull;
	// check if spec list contains houses id
	if ( count _spec_list > 0 ) then {
		if ( ( typeName(_spec_list select 0)) == "SCALAR") then {// house id array detected, not prohibited types array
			_id = _spec_list call XfRandomArrayVal;
			_cnt1 = 0;
			_max = count _spec_list;
			while { (isNull _obj) && ((count _spec_list) > 0) && (_cnt1 < _max)} do {
				//hint localize format["--- SYG_nearestGoodHouse: house ID selected %1", _id];
				_obj = _pos nearestObject _id; 
				if ( !isNull _obj ) then {
					_cnt = _obj call SYG_housePosCount;
					if ( (_cnt == 0) || (_obj isKindOf "Ruins") ) then{
						_obj = objNull;
						hint localize format["--- SYG_nearestGoodHouse: house ID == %1 (%2) has %3 positions", _id, typeOf _obj, _cnt];
						_spec_list = _spec_list - [ _id ];
					};
				};
				_cnt1 = _cnt1 + 1;
			};
		};
	};
	
	if ( !isNull _obj ) exitWith { _obj };

	if ( count _arr == 0 ) then {
		_arr = nearestObjects [_pos, ["House"], _minSearchDist];
		sleep 0.01;
	};
	
	if ( count _arr == 0 ) exitWith {objNull};
	// filter houses using prohibited house types array from _spec_list
	_good_type = "";
	_i = 0;
	{
		_type = typeOf _x;
		if  ( _good_type == "" ) then {
			if ( ( !( _type in _spec_list) ) && ( ( _x call SYG_housePosCount ) >= _minPosCnt ) ) then {
				_good_type = _type;
			} else {
				_arr set [_i, "RM_ME"];
			};
		} else {// good house type already detected
			if ( _type != _good_type ) then { _arr set [_i, "RM_ME"]; }; // remove all except first found good type
		};
		_i = _i + 1;
	} forEach _arr;
	_arr = _arr - ["RM_ME"];
#ifdef __DEBUG_PRINT___
	hint localize format["SYG_nearestGoodHouse: good house type ""%1"" count %2 in radious %3", _good_type, count _arr, _dist];
#endif			
	if ( count _arr > 0) then { _arr call XfRandomArrayVal; }
	else {objNull};
};

//
// call: [_house, _pos<,_unit>] call SYG_teleportToHouse;
// or
//       [_house,"MIDDLE"<,_unit>] call SYG_teleportToHouse;
// or
//       [_house,"RANDOM_MIDDLE"<,_unit>] call SYG_teleportToHouse;
// or
//       [_house,"RANDOM"<,_unit>] call SYG_teleportToHouse;
// or
//       [_house,"RANDOM_CENTER"<,_percent<,_unit>>] call SYG_teleportToHouse;
// where _percent is from 0 to 50 to define house position distance from center of positions list in percents (0..50)
// returns the position index in the house
SYG_teleportToHouse = {
	private ["_house","_hpos", "_pos", "_cnt","_part","_unit"];
	
	_house = argopt(0,objNull);
	if ( isNull _house ) exitWith { hint localize "--- SYG_teleportToHouse: expected house (1st param) is illegal"; -1};
	
	_hpos = argopt(1,"RANDOM_CENTER");
	_unit = objNull;
	if ((typeName _hpos) == "STRING") then { // defined by mnemonic name
		_cnt = _house call SYG_housePosCount;
		_done = false;
#include "SYG_hotel_rooms.sqf"
		while {!_done} do {
			switch toUpper(_hpos) do {
				case "RANDOM_CENTER": {
					_part = argopt(2,20); // use position at 20% around center of position array
					if ( _part <= 0) then {_part = 20;};
					_part = _part min 50;
					_hpos = ((floor((_cnt*(0.5-_part/100))+(random(_cnt*(_part/50))))) max 0) min (_cnt -1);
					_unit = argopt(3,objNull);
					//player groupChat format["RANDOM_CENTER: house with posnum %1, center part %2%4, selected pos %3", _cnt, _part, _hpos, "%"];
				};
				case "RANDOM_MIDDLE": {
					_hpos = floor(_cnt/2 + (random (_cnt % 2)));
					_unit = argopt(2,objNull);
				};
				case "RANDOM": {
					_hpos = floor (random _cnt);
					_unit = argopt(2,objNull);
				};
				case "MIDDLE";
				default  {
					_hpos = floor(_cnt/2);
					_unit = argopt(2,objNull);
				};
			};
			// test to be in hotel building with blind rooms
			if ( (typeName _house)  != "Land_Hotel") exitWith {};
			_done = ! (_hpos in _no_list); // find position not in room without door (listed in _no_list array from SYG_hotel_rooms.sqf file
		};
	} else { _unit = argopt(2,objNull);}; // defined by position index
	_pos = _house buildingPos _hpos;
	if ( isNull _unit ) then { // teleport player, not unit
		if (isNull player) exitWith {hint localize "--- SYG_teleportToHouse: unit/player isNull";-1};
	    player setPos _pos;
	} else {
	    _unit setPos _pos;
	};
	_hpos
};

/**
 * move object to relative pos in house space
 *
 * call: _unit_pos = [_house, _obj, _rel_arr] call SYG_setObjectInHousePos;
 * where _rel_arr = [[_dx,_dy,_dz], _angle]; // _angle is object angle in house model space
 * Returns: new position of the uint
 */
SYG_setObjectInHousePos = {
	private ["_house","_obj","_rel_arr","_angle","_pos"];
    _house   = arg(0);
    _obj     = arg(1);
    _rel_arr = arg(2);
    _angle   = ( ( _rel_arr select 1) + (getDir _house) +360) mod 360;
    _obj setDir _angle;
    _pos = _house modelToWorld (_rel_arr select 0);
    _obj setPos (_pos);
    _pos
};

// Check if point/object is in nearest house rectangle
// call: _isInHouseRect = _unit call SYG_isInHouseRect;
//
SYG_isInHouseRect =
{
	if (typeName _this != "OBJECT") exitWith {false};
    private ["_near","_bb","_po"];
    _near  = nearestObject [_this, "House"];
    if (isNull _near) exitWith {false};
    _bb = boundingBox _near;
    _po = _near worldToModel (getPos _near);
    if (((_bb select 0) select 0) > (_po select 0)) exitWith { false};
    if (((_bb select 1) select 0) < (_po select 0)) exitWith { false};
    if (((_bb select 0) select 1) > (_po select 1)) exitWith { false};
    if (((_bb select 1) select 1) < (_po select 1)) exitWith { false};
    true
};

//
// Checks if designated object(house) is building with room[s] in it
// call: _hasRooms = _house call SYG_isBuilding;
// returns:true if there is at least one rooom (with buildingPos) in the house, else false. If _house is not "OBJECT", returns false
//
SYG_isBuilding = {
	if (typeName _this != "OBJECT") exitWith { false };
	if (! (_this isKindOf "House")) exitWith { false };
	( ( ( _this buildingPos 0 ) distance [0,0,0] ) > 0.1) // so (_this buildingPos 0) is [0,0,0] itself
};

//
// call on "killed" event to restore it momentarily
// Parameters: [_building, killer]
//
SYG_invulnerableBuilding = {
	private ["_building","_killer","_pos","_new","_azi","_str","_code"];
	_building = _this select 0;
	if (count _this > 2) then { _pos = _this select 2 } else { _pos = getPos _building; _pos set[ 2, 0 ] };
	if (count _this > 3 ) then { _azi = _this select 3 } else { _azi = getDir _building };
	_killer   = _this select 1;
	_new = createVehicle [typeOf _building, _pos, [], 0, "CAN_COLLIDE"];
	_new setDir _azi;
	_code = compile format["[_this select 0,_this select 1%1%2] call SYG_invulnerableBuilding",
		if (count _this > 2) then { format[",%1", _this select 2] } else { "" },
		if (count _this > 3 ) then { format[",%1",_this select 3] } else { "" }
		];
	_new addEventHandler["killed", _code];
	_str = format["*** SYG_invulnerableBuilding _this: %1", _this];
	_building removeAllEventHandlers "killed";
	if ( !isNull _building ) then { deleteVehicle _building; _str = _str + ", ruines deleted" };

	hint    localize _str;  //	player groupchat _str;

	// check if player is killer and let's punish him for that
	if (isNull _killer) exitWith{};
	_killer = gunner _killer;
	if (!isPlayer _killer) exitWith {};
	[ "change_score", name _killer, -10, [ "msg_to_user", "",  [ ["STR_KILLED_WALL", name _killer, 10]], 0, 2, false, "losing_patience" ] ] call XSendNetStartScriptClientAll;
	// TODO: combine lower line wuth the upper one, it is possible!!!
	[ "msg_to_user", name _killer,  [ ["STR_JAIL_4"]], 0, 65, false, "losing_patience" ] call XSendNetStartScriptClientAll;
};

if (true) exitWith {};