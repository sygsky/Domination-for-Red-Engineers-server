/*
	scripts\bonus\SYG_utilsBonus.sqf - utils for bonuses
	author: Sygsky
	description: none
	returns: nothing
*/
#include "x_setup.sqf"

//
// Creates bonus vehicle in the designated annulus or on the nearest spawn point for "Plane" vehicles
//
// call as follow: _new_veh = [[_x, _y<,_z>], _rad, _veh_type_name] call _create_bonus_veh;
// on any error returns objNull
//
// List all heli lifts: d_helilift1_types
//
SYG_createBonusVeh = {
	if (count _this < 3) exitWith { hint localize format["---SYG_createBonusVeh: Expected params count 3, found %1", count _this]; objNull };
	private ["_center","_rad","_type","_pos","_is_plane","_dir","_veh","_x","_name","_loc"];
	_center = _this select 0;
	if (typeName _center != "ARRAY") exitWith { hint localize format["---SYG_createBonusVeh: Expected 1st param type is 'ARRAY', found %1", typeName (_this select 0)]; objNull };
	_rad    = _this select 1; // battle zone radious (e.g. town radious)
	_type   = _this select 2; // vehicle type to create

	// check if pont is on one of Sahrani islands
	if ( _center call SYG_pointOnIslet) then {
		// we are on islet, move center to the main island
		_loc  = _center call SYG_nearestSettlement;
		_name = text _loc;
		_mt  = _name call SYG_MTByName;
		if (count _mt > 0) then {
			_center = _mt select 0;
			_rad = _mt select 2;
		};
//		_center = _center call  SYG_nearestSettlement; // nearest settlement for the islet
		hint localize format["+++ SYG_createBonusVeh: MT is on islet, changed to ""%1""", _name];
	};
	// We may be on Rahmadi
	if ( _center call SYG_pointOnRahmadi ) then {
		if (! ((_type in (d_choppers select 3)) || (_type isKindOf "Air"))) then {
			// it is not heli lifted or air vehicle, so move center from this point to the main aisland
			_mt = "Rahmadi" call SYG_nearestMainTarget; // find nearest target on main island
			if (count _mt > 0) then {
				_center = _mt select 0;
				_rad    = _mt select 2;
				hint localize format["+++ SYG_createBonusVeh: MT changed from ""%1"" to ""%2""","Rahmadi", _mt select 1];
			};
		};
	};
	_pos = [ _center, _rad * 1.5, _rad * 2.5 ] call XfGetRanPointAnnulusBig; // position for the land bonus vehicle
	_dir = random 360; // random direction
#ifdef __DEFAULT
	_is_plane  = _type isKindOf "Plane";
	if (_is_plane) then {
//		_pos = _center call _find_air_pos; // find nearest position
		_hnd = _pos execVM "scripts\bonus\bonus_air_pos.sqf";
		waitUntil {sleep 0.1; scriptDone _hnd};
		_pos = _pos select 0;
		_dir = _pos select 1;
	};
#endif

	_veh = _type createVehicle  [0,0,0];
	_veh setDir _dir;
    _veh setPos _pos;
    if ( !( _veh isKindOf "Ship" ) ) then {
	    _fuel = 30 / (_veh call SYG_fuelCapacity); // 30 liters in the vehicle
	    _veh setFuel _fuel;
	    if (_veh isKindOf "Air" ) exitWith { _veh setVectorUp [0,0,1] };
	    if ( ( _veh isKindOf "LandVehicle" ) && ( ( random 10 ) > 2 ) ) exitWith { _veh setFuel 0; _veh setVectorUp [0,0,-1] };
    };
    { _veh removeMagazines _x } forEach magazines _veh;
	sleep 2;
	_veh setDamage 0.5;
	_veh execVM "scripts\bonuses\assignAsBonus.sqf"; // assign action to check register as bonus on base
	_veh
};
