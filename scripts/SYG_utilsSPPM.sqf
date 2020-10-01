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
#define SPPM_VEH_MIN_DISTANCE 20 // Minimum distance between marker of SPPM and vehicle to count it in SPPM
#define SPPM_OBJ_TYPE "RoadCone" // SPPM object for search
#define SPPM_MARKER_COLOR "ColorGreen" // Color of any SPPM marker
#define SPPM_MARKER_NAME "SPPM_MARKER" // variable name of marker object with marker name
#ifdef __ACE__
#define SPPM_MARKER_TYPE "ACE_Icon_Truck" // ACE common truck marker for SPPM
#else
#define SPPM_MARKER_TYPE "SupplyVehicle" // Vanilla BIS supply truck marker for SPPM
#endif

if ( !isNil "SYG_SPPMArr" )exitWith { hint "SYG_utilsSM already initialized"};
hint localize "INIT of SYG_utilsSPPM";
// Array to store SPPM objects
SYG_SPPMArr = []; // List of road cones used to designate all SPPM markers

hint "INIT of SYG_utilsSPPM";

// Tries to find any SPPM marker in radious 50 meters around desugnated object or position
//
// call as: _nearestSPPMDescrArr = _obj|_pos callSYG_findNearestSPPM;
//
// where:
//       _obj     is any object or  2D/3D position to find SPPM nearest to it
// Returns: if no SPPM in mission or nearer than 50 meters, empty string is returned,
//          if SPPM found in radius 50 meters, its marker name is returned

SYG_findNearestSPPM = {
#ifdef __DEBUG__
    hint localize format["SYG_utilsSPPM.sqf#SYG_findNearestSPPM: called with %1", _this];
#endif
	if (count SYG_SPPMArr == 0) exitWith {""}; // no markers in mission, return empty name
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
	_marker_name = "";
	{
		_marker_name = _x getVariable SPPM_MARKER_NAME;
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
// call: _vehArr = _pos | _object(RaodCone) call  SYG_getAllSPPMVehicles;
//
SYG_getAllSPPMVehicles = {
	private ["_pos", "_arr", "_i"];
	_pos = _this call SYG_getPos;
	if (_pos select 0 == 0 && _pos select 1 == 0) exitWith {[]}; // bad parameters
	_arr = nearestObjects [_pos, ["LandVehicle", "Air","Ship"], SPPM_MIN_DISTANCE];
	for "_i" from 0 to count _arr - 1 do {
		_x = _arr select _i;
		if (!alive _x || _x isKindOf "ParachuteBase") then { _arr set [_i, "RM_ME"] }; /// dead vehicle is not SPPM one
	};
	_arr call SYG_clearArray
};

//
// Tries to add new SPPM:
// call: _sppm_nmarker = _pos|obj call SYG_addSPPMMarker;
// returns: result text string to localize
//
SYG_addSPPMMarker = {
	private ["_pos", "_marker_name","_arr","_pnt","_cone"];
	_pos = _this call SYG_getPos;
	if (_pos select 0 == 0 && _pos select 1 == 0) exitWith { "STR_SPPM_ADD_ERR" }; // "Error in the creation of the new SPPM: The parameters for the procedure were incorrect"
	_marker_name = _pos call SYG_findNearestSPPM;
	if ( _marker_name != "" ) exitWith {
		// SPPM found at distance SPPM_MIN_DISTANCE meters
		_marker_pos = getMarkerPos _marker_name;
		if ((_pos distance _marker_pos) > SPPM_VEH_MIN_DISTANCE ) exitWith {
			"STR_SPPM_ADD_ERR_3" // "The nearest SPPM is at %1 m. Move the vehicle closer to it."
		};
		"STR_SPPM_4" // "The valid SPPM  (distance %1 m.) is updated"
	};

	// No near SPPM found, create new one
	_arr = _pos call SYG_getAllSPPMVehicles;

	if (count _arr == 0) exitWith{ "STR_SPPM_ADD_ERR_2" }; // no vehicles in vicinity
	_pnt = _arr call SYG_averPoint; // found average point

	// try to create marker for SPPM
	_marker_name = "";
	for "_i" from 0 to (count SYG_SPPMArr + 100) do {
		_marker_name = createMarker [ _i call SYG_SPPMMarkerNameById, _pnt ];
		if (_marker_name != "") exitWith {};
	};
	if (_marker_name == "") exitWith { "STR_SPPM_ADD_ERR_1" }; // can't create marker name
	hint localize format["+++ SPPM, created new marker ""%1""", _marker_name];
	_marker_name setMarkerColor SPPM_MARKER_COLOR;
	_marker_name setMarkerShape "ICON";
	_marker_name setMarkerType SPPM_MARKER_TYPE;
	// create mark object (e.g. road cone) for this SPPM
	_cone = createVehicle [SPPM_OBJ_TYPE, _pos, [], 0, "NONE"]; // add road cone
	_cone setVariable [SPPM_MARKER_NAME, _marker_name ];
	"STR_SPPM_ADD_SUCCESS"
};
// Updates all markers removing empty ones
SYG_updateAllSPPMMarkers = {
	private ["_marker_name","_count_corrected","_count_removed","_pos","_arr","_new_pos"];
	_count_corrected = 0; // how many mark objects were corrected
	_count_removed = 0; // how many mark objects were corrected
	for "_i" from 0 to count SYG_SPPMArr - 1 do  {
		_x =  SYG_SPPMArr select _i;
		_marker_name = _x getVariable SPPM_MARKER_NAME;
		if ( !isNil "_marker_name" ) then {
			_pos = getMarkerPos _marker_name;
			_arr = _pos call SYG_getAllSPPMVehicles;
			if ( count _arr == 0) exitWith {
				// remove empty (no vehicles) marker
				deleteMarker _marker_pos;
				_x setVariable [SPPM_MARKER_NAME, nil ];
				deleteVehicle _x;
				_count_removed = _count_removed + 1;
				SYG_SPPMArr set [_i, "RM_ME"];
				hint localize format["*** empty SPPM ""%1"" (%2) is removed", _marker_name, _marker_pos];
			};
			// recalculate center position of SPPM
			_new_pos = _arr call SYG_averPoint;
			_marker_name setMarkerPos _new_pos;
			if ( [_pos, _new_pos] call SYG_distance2D > 0.5) then {
				// returns mark object to marker pos
				_count_corrected = _count_corrected + 1;
				_x setPos _new_pos;
				hint localize format["*** SPPM ""%1"" position changed by %1 m.", _marker_name, [_pos, _new_pos] call SYG_distance2D];
			};
		};
	};
	SYG_SPPMArr call SYG_clearArray;
	hint localize format["+++ SYG_updateAllSPPMMarkers: count %1, updated %2, removed %3", count SYG_SPPMArr, _count_corrected, _count_removed];
};
hint localize "INIT of SYG_utilsSPPM completed";
