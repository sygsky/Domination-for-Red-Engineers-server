/*
	scripts\bonus\SYG_utilsBonus.sqf - utils for bonuses
	author: Sygsky
	description: none
	returns: nothing
*/
#include "x_setup.sqf"

// uncomment to allow upsidedown, no fuel, no ammo for all DOSAAF vehicles
//#define ALLOW_HARD_MODE

//
// Creates bonus vehicle in the designated annulus or on the nearest spawn point for "Plane" vehicles
// Called on server only
// call as follow: _new_veh = [[_x, _y<,_z>], _rad, _veh_type_name] call SYG_createBonusVeh;
// on any error returns objNull
//
// List all heli lifts: d_helilift1_types
//
SYG_createBonusVeh = {
	if (!X_Server) exitWith {};
	if (count _this < 3) exitWith { hint localize format["--- SYG_createBonusVeh: Expected params count 3, found %1", count _this]; objNull };
	private ["_center","_rad","_type","_pos","_dir","_veh","_x","_name","_loc", "_mt"];
	_center = _this select 0;
	_center = [_center select 0, _center select 1, 0];
	if (typeName _center != "ARRAY") exitWith { hint localize format["---SYG_createBonusVeh: Expected 1st param type is 'ARRAY', found %1", typeName (_this select 0)]; objNull };
//	hint localize format[ "+++ SYG_createBonusVeh: _this = %1", _this ];
	_rad    = _this select 1; // battle zone radious (e.g. town radious)
	_type   = _this select 2; // vehicle type to create

	hint localize format["+++ SYG_createBonusVeh: creating vehicle %1", _type];

	// check if pont is on one of Sahrani islands
	if ( _center call SYG_pointOnIslet) then {
		// we are on islet, move center to the main island
		_loc  = _center call SYG_nearestSettlement;
		_name = text _loc;
		_mt  = _name call SYG_MTByName;
		if (count _mt > 0) then {
			_center = _mt select 0;
			_center = [_center select 0, _center select 1, 0];
			_rad = _mt select 2;
		};
//		_center = _center call  SYG_nearestSettlement; // nearest settlement for the islet
		hint localize format["+++ SYG_createBonusVeh: MT is on islet, place changed to ""%1""", _name];
	};
	// We may be on Rahmadi
	if ( _center call SYG_pointOnRahmadi ) then {
//		hint localize format["+++ SYG_createBonusVeh: MT is on Rahmadi, (_type in d_helilift1_types) = %1, (_type isKindOf ""Air"") = %2",_type in d_helilift1_types, _type isKindOf "Air"];
//		hint localize format["+++ SYG_createBonusVeh: d_helilift1_types = %1",d_helilift1_types];
		if (! ((_type in d_helilift1_types) || (_type isKindOf "Air")) ) then {
			// it is not heli lifted or air vehicle, so move center from this point to the main aisland
			_mt = "Rahmadi" call SYG_nearestMainTarget; // find nearest target on main island
			if (count _mt > 0) then {
				_center = _mt select 0;
				_center = [_center select 0, _center select 1, 0];
				_rad    = _mt select 2;
				hint localize format["+++ SYG_createBonusVeh: MT changed from ""%1"" to ""%2""","Rahmadi", _mt];
			};
		};
	};
	_pos = [ _center, _rad * 1.5, _rad * 2.5 ] call XfGetRanPointAnnulusBig; // position for the land bonus vehicle
	_dir = random 360; // random direction
#ifdef __DEFAULT__
	if ( _type isKindOf "Plane" ) then {
//		_pos = _center call _find_air_pos; // find nearest position
		_time = time;
		_hnd = _pos execVM "scripts\bonus\bonus_air_pos.sqf"; //pos and dir are returned in _pos array
		waitUntil {sleep 0.1; scriptDone _hnd};
		hint localize format["+++ SYG_createBonusVeh: plane %1, delta time %2, new pos data %3", typeOf _veh, time - _time, _pos];
		_dir = _pos select 1;
		_pos = _pos select 0;
	};
#endif

//	_veh = _type createVehicle  [0,0,0];
//	_veh setPos _pos;
	_veh = _type createVehicle  _pos;
	_veh setDir _dir;
    if ( !( _veh isKindOf "Ship" ) ) then {
    	_fuel = _veh call SYG_fuelCapacity;
    	if (_fuel == 0) then {
    		hint localize format["--- SYG_utilsBonus.sqf: vehicle %1 has fuleCapacity = 0", _type];
    		_fuels = 0.01
    	} else { _fuel = 30 / (_veh call SYG_fuelCapacity) }; // 30 liters in the vehicle
	    _veh setFuel _fuel;
	    if (_veh isKindOf "Air" ) exitWith { _veh setVectorUp [0,0,1] };
	    if ( ( _veh isKindOf "LandVehicle" ) && ( ( random 10 ) > 2 ) ) exitWith {
	    	_veh setFuel 0;
#ifdef ALLOW_HARD_MODE
	    	_veh setVectorUp [0,0,-1]
#endif
	    };
#ifdef ALLOW_HARD_MODE
	    { _veh removeMagazines _x } forEach magazines _veh;	// remove magazines from Air vehicles only
#endif
    };
	sleep 2;
	_veh setDamage (0.4 + (random 0.1));
	_veh execVM "scripts\bonus\assignAsBonus.sqf"; // assign action to check register as bonus on base
	_veh
};

//
// Call as follows: [_veh, "INI || ""ADD" || "REG"<, _player_name for "ADD" and "REG" >] call SYG_updateBonusStatus;
//
SYG_updateBonusStatus = {
	private ["_veh","_cmd","_id","_ret"];
//	hint localize format["*** SYG_updateBonusStatus: _this = [%1,%2,%3]",type];
	if ( (typeName _this) != "ARRAY") exitWith { hint localize format["--- SYG_updateBonusStatus: expected input array, found %1",typeName _this] };
	if ( (count _this) < 2 ) exitWith { hint localize format["--- SYG_updateBonusStatus: expected input array[2], found size %1", count _this] };
	_veh = _this select 0;
	if (typeName _veh != "OBJECT") exitWith {hint localize format["--- SYG_updateBonusStatus: expected 1st param as OBJECT, found %1, found size %1", typeName _veh]};
	_cmd = _this select 1;
	if ( (typeName _cmd) != "STRING") exitWith {hint localize format["--- SYG_updateBonusStatus: expected 2st param as STRING, found %1, found size %1", typeName _cmd]};

	hint localize format["+++ bonus.%1: _this = %2", _cmd, _this];
	// "ADD" add command processing
	if ( _cmd == "ADD") exitWith {
		// assigns as found vehicle, change menu from "Inspect" to the "Register"
		_id = _veh getVariable "INSPECT_ACTION_ID";
		if (!isNil "_id") then {
			hint localize format[ "--- bonus.ADD on client: variable INSPECT_ACTION_ID detected in %1!!!", typeOf _veh ];
//			_veh removeAction _id;
			// replace title with "Register" text
//			_veh setVariable ["INSPECT_ACTION_ID", _veh addAction [ localize "STR_REG_ITEM", "scripts\bonus\bonusInspectAction.sqf",[]]];
		} else {
			hint localize format[ "--- bonus.ADD on client: variable INSPECT_ACTION_ID not detected in %1!!!", typeOf _veh ]
		};
		_veh setVariable ["RECOVERABLE",false]; // mark vehicle as detected not registered for already created vehicle in client copy
		_veh setVariable ["DOSAAF", nil]; // no more to be DOSAAF unknown vehicle
	};

	// "REG" register command processing
	if ( _cmd == "REG" ) exitWith {
		_id = _veh getVariable "INSPECT_ACTION_ID";
		if (!isNil "_id") then {
			_veh setVariable ["INSPECT_ACTION_ID", nil];
			_veh removeAction _id;
		} else {
			hint localize format[ "--- bonus.REG: variable INSPECT_ACTION_ID not found at %1!!!", typeOf _veh ]
		};
		// remove from markered vehs list register as recoverable vehicle
		_veh setVariable ["RECOVERABLE", true];
		_veh setVariable ["DOSAAF", nil];
	};

	if ( _cmd != "INI") exitWith { hint localize format["--- bonus.XXX: expected command ['INI','ADD','REG'], detected unknown ""%1""", _cmd]; };

	// "INI" initiate command processing
	private ["_id","_cnt"];
	_id = _veh getVariable "INSPECT_ACTION_ID";
	if (!isNil "_id") exitWith {
		hint localize format["+++ bonus.INI on client: inspect action #%1 for %2 already exists, new one not added", _id, typeOf _veh];
	};
	_veh setVariable ["INSPECT_ACTION_ID", _veh addAction [ localize "STR_CHECK_ITEM","scripts\bonus\bonusInspectAction.sqf",[]]];
	_veh setVariable ["DOSAAF", ""];
	hint localize format[ "+++ bonus.INI: setVariable ""INSPECT_ACTION_ID"" => %1!!!", typeOf _veh ]
};

//
// Returns the list of vehicles that match the designated condition. Vehicle is accessed through the external variable _x
// call as follows:
// _code = { private ["_var"]; _x getVariable "INSPECT_ACTION_ID"; if ( isNil "_var") exitWith { false}; isAlive _var };
// _list = _code call SYG_scanVehicles;
// E.g.:
//
SYG_scanVehicles = {
	private ["_arr","_x"];
	_arr = [];
	{
		if ( _x call _this ) then { _arr set [ count _arr, _x ] };
	} forEach vehicles;
	_arr
};

//
// Returns all alive non registered DOSAAF vehicles
// 	_id = _x getVariable "INSPECT_ACTION_ID"; // check if vehicle is bonus with "Inspect" command on it
SYG_scanDOSAAFVehicles = {
	private ["_x","_var", "_arr","_cnt"];
	_arr = [];
	_cnt = 0;
	{
		if (alive _x) then {
			_var = _x getVariable "RECOVERABLE";//  If inspected follow code is executed: "this setVariable [""RECOVERABLE"", false]"
			if ( !( isNil "_var" ) ) then {
				if (!_var) then {
					_arr set [count _arr, _x]
				};
			};
		};
		_cnt = _cnt + 1;
		if ((_cnt mod 20) == 0) then {sleep 0.01};
	} forEach vehicles;
	hint localize format["+++ SYG_scanDOSAAFVehicles whole vehicles counter = %1, DOSAAF found %2", _cnt, count _arr];
	_arr
};

//
// Returns all alive non registered DOSAAF vehicles
// Call as follow: _ret_arr = call SYG_scanDOSAAFVehiclesAll;
// where _ret_arr = [_dosaaf_arr,_marked_arr];
SYG_scanDOSAAFVehiclesAll = {
	private ["_x","_var", "_DOSAAF_arr","_marked_arr","_cnt"];
	_DOSAAF_arr = [];
	_marked_arr = [];
	_cnt = 0;
	{
		if ( alive _x ) then {
			_var = _x getVariable "DOSAAF";//  If inspected follow code is executed: "this setVariable [""RECOVERABLE"", false]"
			if ( !( isNil "_var" ) ) then {
				_DOSAAF_arr set [ count _DOSAAF_arr, _x ]
			};
			_var = _x getVariable "RECOVERABLE";//  If inspected follow code is executed: "this setVariable [""RECOVERABLE"", false]"
			if ( ( !isNil "_var" ) ) then {
				if ( !_var ) exitWith { _marked_arr set [ count _marked_arr, _x ] };
			};
		};
		_cnt = _cnt + 1;
		if ( ( _cnt mod 20 ) == 0 ) then { sleep 0.01 };
	} forEach vehicles;
	hint localize format[ "+++ SYG_scanDOSAAFVehiclesAll whole vehicles counter = %1, found DOSAAF0 %2, DOSAAF_MARKED %3", _cnt, count _DOSAAF_arr, count _marked_arr ];
	[_DOSAAF_arr,_marked_arr]
};

//
// Counts vehicles, returns array:
// [_common count, _veh_count, not_inspected_DOSAAF_count, _inspected_DOSAAF_count, alive_count, markered_count, bonus_count]
// call as follows: _ret_arr = call SYG_countVehicles;
//
SYG_countVehicles = {
	private ["_cnt","_cntv","_cntd","_cntnr","_cnta","_cntm","_var","_x"];
	_cnt = 0; _cntv = 0; _cntd = 0; _cntnr = 0; _cnta = 0; _cntm = 0; _cntr = 0;
	{
		if ( (_x isKindOf "LandVehicle") || (_x isKindOf "Air") || (_x isKindOf "Ship") ) then { // DOSAAF
			_cntv = _cntv + 1; // vehicle

			_var = _x getVariable "INSPECT_ACTION_ID";
			if ( !(isNil "_var") ) then { _cntnr = _cntnr + 1 }; // DOSAAF vehicle not registered, may be inspected

			_var = _x getVariable "RECOVERABLE";
			if ( !isNil"_var" ) then {
				if ( !_var ) then { _cntm = _cntm + 1 } else { _cntr = _cntr + 1 }; // not registered + recoverable vehicle
			};

			_var = _x getVariable "DOSAAF";
			if ( !isNil"_var" ) then { _cntd = _cntd + 1 }; // never inspected/registered DOSAAF vehicle

			if ( alive _x ) then { _cnta = _cnta + 1 }; // alive vehicle
		};
		_cnt = _cnt + 1; // all items count
	} forEach vehicles;
	[_cnt, _cntv, _cntd, _cntnr, _cnta, _cntm, _cntr]
};

//
// Finds index for vehicle in vehicles collection. On error return -1
//
SYG_getVehIndexFromVehicles = {
	private ["_id", "_ind", "_x"];
	_id  = 0;
	_ind = -1;
	{
		if (_x == _this) exitWith { _ind = _id };
		_id = _id + 1;
	} forEach vehicles;
	_ind
};
