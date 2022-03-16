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
// Find cone on base that contain designated vehicle. Remove if found.
// Called on client ONLY
// Call as: _veh call SYG_removeBonusCone;
//
SYG_removeBonusCone = {
	if (!X_Client) exitWith {};
	private ["_cones", "_veh"];
	_cones = CONE_MAP_SERVER nearObjects ["RoadCone", 200];
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
	_new_center = CONE_MAP_SERVER; //getPos cone_map_center;
	_cone_type  = "RoadCone";

	_xc = _center select 0;
	_yc = _center select 1;
	_xn = _new_center select 0;
	_yn = _new_center select 1;

	_pos      = getPos _this;
	_new_pos  = [_xn + (((_pos select 0) - _xc) * _scale), _yn + (((_pos select 1) - _yc) * _scale), 0.4];
	_obj = _cone_type createVehicleLocal _new_pos;
	_obj setVehiclePosition [_new_pos, [], 0, "CAN_COLLIDE"];
	_obj setVariable [ "bonus_veh", _x ];
	_obj addAction[ localize "STR_CHECK_ITEM", "scripts\bonus\coneInfo.sqf" ];
};
