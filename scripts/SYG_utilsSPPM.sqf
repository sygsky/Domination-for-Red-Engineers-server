// SYG_utilsSPPM.sqf : utils for SPPM handling
// SPPM id id integer id from SPPM array
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

#define SPPM_MIN_DISTANCE 50 // Minimum distance at which the nearest SPPM can be located
#define SPPM_VEH_MIN_DISTANCE 10 // Minimum distance at which vehicles in SMPPM must be located
#define SPPM_OBJ_TYPE "RoadCone" // SPPM object for search

if ( !isNil "SYG_SPPMArr" )exitWith { hint "SYG_utilsSM already initialized"};

// Array to store SPPM objects
SYG_SPPMArr = [0,[]]; // Zero (0) offset number is count of markers generated; one (1) offset array is for unused id of SPPM

hint "INIT of SYG_utilsSPPM";

// Tries to find any SPPM marker in radious 50 meters around desugnated object or position
//
// call as: _nearestSPPMDescrArr = _obj callSYG_findNearestSPPM;
//
// where:
//       _obj     is any object or  2D/3D position to find SPPM nearest to it
// Returns: if no SPPM in mission or nearer than 50 meters, empty string is returned,
//          if SPPM found in radius 50 meters, its marker name is returned

SYG_findNearestSPPM = {
#ifdef __DEBUG__
    hint localize format["SYG_utilsSPPM.sqf#SYG_findNearestSPPM: called with %1", _this];
#endif
	if ((SYG_SPPMArr select 0) == 0) exitWith {""}; // no markers in masions, return empty name
	switch (typeName _this) do {
		case "ARRAY":  { // Position
		};
		case "OBJECT": { // any object, including player
			_this = getPos _this;
		};
	};
	if (typeName _this != "ARRAY") exitWith {""};
	private ["_arr"];
	_arr = nearestObjects [_this, [SPPM_OBJ_TYPE], SPPM_MIN_DISTANCE];
	_amrker_name = "";
	{
		_marker_name = _x getVariable "SPPM_MARKER";
		if (!isNil _marker_name) exitWith {}; // return marker name nearest to the marker object
	} forEach _arr;
	_marker_name
};

//
// call: _marker_name = _id call SYG_SPPMMarkerNameById;
//
SYG_SPPMMarkerNameById = {
	format[ "SPPM_MARKER_%1", _id];
};
//
// call: _vehArr = _sppm_id | _sppm_marker_name | _object(RaodCone) call  SYG_getAllSPPMVehicles;
//
SYG_getAllSPPMVehicles = {
	_marker_name = _this;
	if ( typeName _this == "SCALAR" ) then { _marker_name = format["SPPM_MARKER_%1", _this] };
	if ( typeName _this == "OBJECT" ) then {
		if ( typeOf _this == SPPM_OBJ_TYPE) then { _marker_name = _this getVariable  "MARKER_NAME"}; 
	};
	if ( typeName _this != "STRING" ) exitWith {[]}; // bad marker name, empty return
	if (getMarkerType _marker_name == "") exitWith {[]}; // no such marker found
	_pos = getMarkerPos _marker_name;
	_arr = nearestObjects [_pos, [SPPM_OBJ_TYPE], SPPM_MIN_DISTANCE];
	for "_i" from 0 to count _arr - 1 do {
		_x = _arr select _i;
		if ((_x distance _pos ) > SPPM_VEH_MIN_DISTANCE ) then { // no SPPM point near
			_arr1 = nearestObjects [_x, ["LandVehicle", "Air","Ship"], SPPM_VEH_MIN_DISTANCE];
			if (count _arr1 == 0) then {_arr set [ _i, "RM_ME"]} // no any vehicle near
			else {
				// check if any of near vehicles is in SPPM circle
				{
					if ( )
				} forEach _arr1;
			};
		};
	};
	
}