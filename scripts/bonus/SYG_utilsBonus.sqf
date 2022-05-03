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
// Call as follows: [_veh, "INI || ""ADD" || "REG", _player_name] call SYG_updateBonusStatus;
//
SYG_updateBonusStatus = {
	private ["_veh","_cmd","_id","_ret"];
	if ( (typeName _this) != "ARRAY") exitWith { hint localize format["--- SYG_updateBonusStatus: expected input array, found %1",typeName _this] };
	if ( (count _this) < 2 ) exitWith { hint localize format["--- SYG_updateBonusStatus: expected input array[2], found size %1", count _this] };
	_veh = _this select 0;
	if (typeName _veh != "OBJECT") exitWith {hint localize format["--- SYG_updateBonusStatus: expected 1st param as OBJECT, found %1, found size %1", typeName _veh]};
	_cmd = _this select 1;
	if ( (typeName _cmd) != "STRING") exitWith {hint localize format["--- SYG_updateBonusStatus: expected 2st param as STRING, found %1, found size %1", typeName _cmd]};
	if ( _cmd == "ADD") exitWith {
		// assigns as found vehicle, change menu from "Inspect" to the "Register"
		if (isNil "client_bonus_markers_array") then { client_bonus_markers_array = [];};
		if (! (_veh in client_bonus_markers_array)) then {
			_id = _veh getVariable "INSPECT_ACTION_ID";
			if (!isNil "_id") then {
				_veh removeAction _id;
				// replace title with "Register" text
				_veh setVariable ["INSPECT_ACTION_ID", _veh addAction [ localize "STR_REG_ITEM", "scripts\bonus\bonusInspectAction.sqf",[]]];
			} else {
				hint localize format[ "--- bonus.ADD on client: variable INSPECT_ACTION_ID not found at %1!!!", typeOf _veh ]
			};
			_veh setVariable ["RECOVERABLE",false]; // mark vehicle as detected not registered for already created vehicle in client copy
			_veh setVariable ["DOSAAF", nil]; // no more to be DOSAAF unknown vehicle
			_ret = call SYG_countVehicles; // _id = vehicles find _veh;
			if ((name player) == (_this select 2)) then {
				(d_ranked_a select 30) call SYG_addBonusScore; // this player found this bonus vehicle, add +2 to him
				playSound "good_news";
				(localize "STR_BONUS_1") hintC [
					format[localize "STR_BONUS_1_1", _this select 2, typeOf _veh, (d_ranked_a select 30) ], // "'%1' found '%2' (+%3 score)"
					format[localize "STR_BONUS_1_2", typeOf _veh], // "A temporary marker has been created, visible until '%1' registers with the recovery service."
//							format["""RECOVERABLE"" = %1", _veh getVariable "RECOVERABLE"],
					format[localize "STR_BONUS_1_3", typeOf _veh, localize "STR_REG_ITEM"] // "Registration: deliver %1 to the base and invoke the '%2' command"
				];
			} else { //  send info to all players except author
				["msg_to_user","",[
					["STR_BONUS_1"], // "ДОСААФ (Voluntary Society for Assistance to the Army, Aviation and Navy) News:"
					["STR_BONUS_1_1", _this select 2, typeOf _veh, (d_ranked_a select 30) ], // "'%1' found '%2' (+%3 score)"],
					["STR_BONUS_1_2", typeOf _veh], // "A temporary marker has been created, visible until '%1' registers with the recovery service."
					["STR_BONUS_1_3", typeOf _veh, "STR_REG_ITEM"] // "Registration: deliver %1 to the base and invoke the '%2' command"
				],5,0, false, "good_news"] call SYG_msgToUserParser;
			};
			hint localize format["+++ bonus.ADD on client: adds %1 to the markers list, cnt/vehs/DOSAAF_0/DOSAAF_NOTREG/alive/markers/bonus = %2 ", typeOf _veh,_ret];
			// ["msg_to_user",["-", name player],[["'%1' обнаружил %2", _this select 2, typeOf _veh]],0,0, false, "good_news"] call XHandleNetStartScriptClient;
		} else { hint localize format["--- bonus.ADD veh %1 already in marker list, exit", _veh]; };
	};

	// REGister command processing
	if ( _cmd == "REG" ) exitWith {
		_id = _veh getVariable "INSPECT_ACTION_ID";
		if (!isNil "_id") then {
			_veh setVariable ["INSPECT_ACTION_ID", nil];
			_veh removeAction _id;
			_ret = call SYG_countVehicles;
			hint localize format["+++ bonus.REG on client: inspect action removed from %1, cnt/vehs/DOSAAF_0/DOSAAF_NOTREG/alive/markers/bonus = %2", typeOf _veh, _ret];
		} else {
			hint localize format[ "--- bonus.REG: variable INSPECT_ACTION_ID not found at %1!!!", typeOf _veh ]
		};
		// remove from markered vehs list register as recoverable vehicle
		_veh setVariable ["RECOVERABLE", true];
		_veh setVariable ["DOSAAF", nil];
		// ["msg_to_user",_player_name,[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay<,_sound>>>]
		playSound "good_news";
		localize "STR_BONUS_3_1" hintC [
			format [localize "STR_BONUS_3_2", typeOf _veh,  _this select 2, (d_ranked_a select 31) ], // "Check-in '%1' is done, recovery service is allowed (responsible '%2', +%3 points)"
			localize "STR_BONUS_3_3"
			];
		if ((name player) == (_this select 2)) then { (d_ranked_a select 31) call SYG_addBonusScore;}; // this player registered this bonus vehicle, add +2 to him
	};

	if ( _cmd != "INI") exitWith { hint localize format["--- SYG_updateBonusStatus: expected command ['INI','ADD','REG'], detected unknown ""%1""", _cmd]; };

	// INItiate command processing
	private ["_id","_cnt"];
	_id = _veh getVariable "INSPECT_ACTION_ID";
	if (!isNil "_id") exitWith {
		hint localize format["+++ bonus.INI on client: inspect action #%1 for %2 already exists, new one not added", _id, typeOf _veh];
	};
	_veh setVariable ["INSPECT_ACTION_ID", "this addAction [ localize ""STR_CHECK_ITEM"",""scripts\bonus\bonusInspectAction.sqf"",[]]]; this setVariable [""DOSAAF"", """"]"];
	hint localize format[ "--- bonus.INI: setVariable ""INSPECT_ACTION_ID"" == %1!!!", typeOf _veh ]

};

//
// Find cone on base that contain designated vehicle. Remove if found.
// Called on client ONLY
// Call as: _veh call SYG_removeBonusCone;
//
SYG_removeBonusCone = {
	if (!X_Client) exitWith {};
	private ["_cones", "_veh"];
	_cones = DOSAAF_MAP_POS nearObjects ["RoadCone", 200];
	{
		_veh = _x getVariable "bonus_veh";
		if (! (isNil "_veh")) then {
			if (_veh == _this) exitWith {
				_veh say "steal";
				sleep 0.5;
				deleteVehicle _x;
			};
		};
	}forEach _cones;
};

//
// Called on client ONLY
// Call as follows: _veh call SYG_addBonusCone;
//
SYG_addBonusCone = {
	if (!XClient) exitWith {};
	private ["_mt","_center","_scale","_new_center","_cone_type","_xc","_yc","_xn","_yn","_pos","_new_pos","_obj"];
	_mt = "Corazol" call SYG_MTByName;
	_center     = _mt select 0;
	_scale      = 0.005; // scale 1: 100 => 100 m in 1 m
	_new_center = DOSAAF_MAP_POS; //getPos cone_map_center;
	_cone_type  = "RoadCone";

	_xc = _center select 0;
	_yc = _center select 1;
	_xn = _new_center select 0;
	_yn = _new_center select 1;

	_pos      = getPos _this;
	_new_pos  = [_xn + (((_pos select 0) - _xc) * _scale), _yn + (((_pos select 1) - _yc) * _scale), 0.4];
	_obj = _cone_type createVehicleLocal _new_pos;
	_obj setVehiclePosition [_new_pos, [], 0, "CAN_COLLIDE"];
	_obj setVariable [ "bonus_veh", _this ];
	_obj addAction[ localize "STR_CHECK_ITEM", "scripts\bonus\coneInfo.sqf" ];
};


//
// Call as follows: _veh call SYG_addBonusCone;
//
SYG_addBonusCone = {
	hint localize format[ "+++ SYG_addBonusCone: %1", _this ];
	private ["_mt","_center","_scale","_new_center","_cone_type","_xc","_yc","_xn","_yn","_pos","_new_pos","_obj"];
	_mt = "Corazol" call SYG_MTByName;
	_center     = _mt select 0;
	_scale      = DOSAAF_MAP_SCALE; // scale 1: 100 => 100 m in 1 m
	_new_center = DOSAAF_MAP_POS; //getPos cone_map_center;
	_cone_type  = "RoadCone";

	_xc = _center select 0;
	_yc = _center select 1;
	_xn = _new_center select 0;
	_yn = _new_center select 1;

	_pos      = getPos _this;
	_new_pos  = [_xn + (((_pos select 0) - _xc) * _scale), _yn + (((_pos select 1) - _yc) * _scale), 0.4];
	hint localize format["+++ Cone added: dx %1, dy %2", (((_pos select 0) - _xc) * _scale), (((_pos select 1) - _yc) * _scale) ];
	_obj = _cone_type createVehicleLocal _new_pos;
	_obj setVehiclePosition [_new_pos, [], 0, "CAN_COLLIDE"];
	_obj setVariable [ "bonus_veh", _this ];
	_obj addAction[ localize "STR_CHECK_ITEM", "scripts\bonus\coneInfo.sqf" ];
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
// 	_id = _x getVariable "INSPECT_ACTION_ID"; // check if vehicle is bonus with "Inspect" command on it
SYG_scanDOSAAF0Vehicles = {
	private ["_x","_var", "_arr","_cnt"];
	_arr = [];
	_cnt = 0;
	{
		if (alive _x) then {
			_var = _x getVariable "DOSAAF";//  If inspected follow code is executed: "this setVariable [""RECOVERABLE"", false]"
			if ( !( isNil "_var" ) ) then {
				_arr set [count _arr, _x]
			};
		};
		_cnt = _cnt + 1;
		if ((_cnt mod 20) == 0) then {sleep 0.01};
	} forEach vehicles;
	hint localize format["+++ SYG_scanDOSAAF0Vehicles whole vehicles counter = %1, DOSAAF0 found %2", _cnt, count _arr];
	_arr
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
