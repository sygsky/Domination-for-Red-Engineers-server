// scripts\SYG_utilsSPPM.sqf : utils for SPPM handling
// SPPM id is integer id from SPPM array
//private [ "_unit", "_dist", "_lastPos", "_curPos", "_boat", "_grp", "_wplist","_startPos", "_procWP", "_wpIndex", "_unittype", "_stopBoat" ];

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG__

#define arg(x) (_this select(x))
#define argp(arr,x) ((arr)select(x))
#define inc(x) ((x)=(x)+1)
#define argopt(num,val) if ((count _this)<=(num))then{val}else{arg(num)}
#define RAR(ARR) ((ARR)select(floor(random(count(ARR)))))
#define RANDOM_ARR_ITEM(ARR) ((ARR)select(floor(random(count(ARR)))))

#define SPPM_MIN_DISTANCE 80 // Minimum distance at which the nearest SPPM can be located
#define SPPM_VEH_MIN_DISTANCE 40 // Minimum distance between marker of SPPM and vehicle to count it in SPPM
#define SPPM_OBJ_TYPE "RoadCone" // SPPM object for search
#define SPPM_DOSAAF_MARKER_COLOR "ColorRed" // Color of any SPPM marker
#define SPPM_MARKER_NAME "SPPM_MARKER" // variable name of marker object with marker name

#ifdef __ACE__
#define SPPM_MARKER_TYPE "ACE_Icon_Truck" // ACE common truck marker for SPPM
#else
#define SPPM_MARKER_TYPE "SupplyVehicle" // Vanilla BIS supply truck marker for SPPM
#endif

if ( !isNil "SYG_SPPMArr" )exitWith { hint "SYG_utilsSM already initialized"};
hint localize "+++ INIT of SYG_utilsSPPM";
// Array to store SPPM objects
SYG_SPPMArr = []; // List of road cones used to designate all SPPM markers

// Tries to find any SPPM marker in radious 50 meters around desugnated object or position
//
// call as: _nearestSPPMDescrArr = _obj|_pos callSYG_findNearestSPPM;
//
// where:
//       _obj     is any object or  2D/3D position to find SPPM nearest to it
// Returns: if no SPPM in mission or nearer than 50 meters, empty string is returned,
//          if SPPM found in radius 50 meters, its marker name is returned

#ifdef __DEBUG__
SYG_Variables2Arr = {
	private ["_arr","_x"];
	_arr = [];
	{
		_arr set [count _arr, _x getVariable SPPM_MARKER_NAME];
	} forEach _this;
	_arr
};
#endif

SYG_findNearestSPPM = {
	if (count SYG_SPPMArr == 0) exitWith {""}; // no markers in mission, return empty name
	_this = _this call SYG_getPos;
	if (_this select 0 == 0 && _this select 1 == 0) exitWith { "" }; // "Error in the creation of the new SPPM: The parameters for the procedure were incorrect"

	private ["_arr","_marker_name","_x"];
	_arr = nearestObjects [_this, [SPPM_OBJ_TYPE], SPPM_MIN_DISTANCE];
#ifdef __DEBUG__
	if (count _arr > 0 ) then {
		hint localize format[ "+++ SYG_utilsSPPM.sqf#SYG_findNearestSPPM: _this %1, found %2 cone[s] %3",
			_this,
			count _arr,
			_arr call SYG_Variables2Arr
			];
	};
#endif
	_marker_name = "";
	{
		_marker_name = _x getVariable SPPM_MARKER_NAME;
		if (!isNil "_marker_name") exitWith {
#ifdef __DEBUG__
		    hint localize format[ "+++ SYG_utilsSPPM.sqf#SYG_findNearestSPPM: nearest SPPM (%1) at %2 m.", _marker_name, round(_x distance _this) ];
#endif
		}; // return marker name nearest to the designated object
	} forEach _arr;
	_marker_name
};

// Only western vehicles can be used for SPPM
//
// call: _vehArr = _pos | _object(RoadCone) call  SYG_getAllSPPMVehicles;
//
SYG_getAllSPPMVehicles = {
	private ["_pos", "_arr", "_i", "_veh"];
	_pos = _this call SYG_getPos;
	if (_pos select 0 == 0 && _pos select 1 == 0) exitWith {[]}; // bad parameters
	_arr = nearestObjects [_pos, ["LandVehicle", "Air","RHIB"], SPPM_VEH_MIN_DISTANCE];
	for "_i" from 0 to count _arr - 1 do {

//		_veh = _arr select _i;
//		if ( (!alive _veh) || (_veh isKindOf "ParachuteBase") || (_veh isKindOf "StaticWeapon") || (_veh in [HR1,HR2,HR3,HR4,MRR1,MRR2]) || (_veh isKindOf "ACE_ATV_HondaR") || (_veh isKindOf "Motorcycle") ) then { _arr set [_i, "RM_ME"] }; /// dead vehicle is not SPPM one
#ifdef __OWN_SIDE_EAST__
		if ( !((_arr select _i) call SYG_isWestVehicle) ) then { _arr set [_i, "RM_ME"] }; /// Only western vehicles can be SPPMed!
#else
		if ( !((_arr select _i) call SYG_isEastVehicle) ) then { _arr set [_i, "RM_ME"] }; /// Only eastern vehicles can be SPPMed!
#endif
	};
	_arr call SYG_clearArrayB;
	// now make all SPPM vehicles to be captured ones
	{ _x setVariable ["CAPTURED_ITEM",""] } forEach _arr;
	_arr
};

//
// Counts near SPPM (in linited range) vehicles
//
SYG_findNearSPPMCount = {
	_this = _this call SYG_getPos;
	if ( (_this select 0 == 0) && (_this select 1 == 0) ) exitWith {0};
	count  nearestObjects [_this, [SPPM_OBJ_TYPE], SPPM_MIN_DISTANCE];
};

//
// Tries to add new SPPM at player position, called on server only:
// call: _result_str = _pos | obj call SYG_addSPPMMarker;
// returns: result text string to localize
//
SYG_addSPPMMarker = {
	private ["_pos", "_marker","_arr","_pnt","_cone","_marker","_ret"];
	// get position of creation point (player or pos itself)
	_pos = _this call SYG_getPos;
	if (_pos select 0 == 0 && _pos select 1 == 0) exitWith { ["STR_SPPM_ADD_ERR", _this] }; // "Error in the creation of the new SPPM: The parameters for the procedure were incorrect"
	_marker = _pos call SYG_findNearestSPPM;
	if ( _marker != "" ) exitWith {
		// SPPM mark object (e.g. road cone) with marker was found at distance <= SPPM_MIN_DISTANCE (e.g.50) meters
		_marker_pos = getMarkerPos _marker;
		if ( ( _pos distance _marker_pos ) > SPPM_VEH_MIN_DISTANCE ) exitWith {
#ifdef __DEBUG__
			hint localize format["+++ SYG_addSPPMMarker: found near SPPM (%1) at dist %2", _marker, round(_pos distance _marker_pos)];
#endif
			["STR_SPPM_ADD_ERR_3", round (_pos distance _marker_pos)] // "The nearest SPPM is at %1 m. Move the vehicle closer to it."
		};

		// find ground SPPM road cone
		_arr = nearestObjects [ _marker_pos, [SPPM_OBJ_TYPE], SPPM_MIN_DISTANCE ];
		if (count _arr > 0) exitWith {
#ifdef __DEBUG__
			hint localize format["+++ SYG_addSPPMMarker: Detected SPPM cone"];
#endif
			(_arr select 0) call SYG_updateSPPM;
		};
		// no marking object is found near marker itself, so remove the marker at last
		deleteMarker _marker; // removal of marker
		"STR_SPPM_6_2"	// "SPPM marking object not found!"
	};

	// No near SPPM found, create new one
	_arr = _pos call SYG_getAllSPPMVehicles;
	if (count _arr == 0) exitWith{ "STR_SPPM_ADD_ERR_2" }; // no vehicles in vicinity

	_pnt = _arr call SYG_averPoint; // found average point
	_marker = _pnt call SYG_findNearestSPPM;
	if (_marker != "") exitWith {
		// new average point is too close  (<= 50 m) to a near SPPM
		"STR_SPPM_ADD_ERR_4" // "New average point is too close to the near SPPM.Move or combine them"
	};

//#ifdef __DEBUG__
//	hint localize format["+++ SYG_addSPPMMarker: _pnt %1", _pnt];
//#endif

	// try to create marker for SPPM
	_marker = "";
	for "_i" from 0 to (count SYG_SPPMArr + 100) do {
		_marker = createMarker [ format[ "SPPM_MARKER_%1", _i], _pnt ];
		if (_marker != "") exitWith {};
	};
	if (_marker == "") exitWith { "STR_SPPM_ADD_ERR_1" }; // can't create marker name
	hint localize format["+++ SPPM, created new marker ""%1"" for %2 vehicle[s]", _marker, count _arr];
	_marker setMarkerColor SPPM_DOSAAF_MARKER_COLOR;
	_marker setMarkerShape "ICON";
	// TODO: find marker
	_arr = _arr call SYG_generateSPPMText;
	_marker setMarkerType (_arr select 0);
	_marker setMarkerText (_arr select 1);
//	_marker setMarkerType SPPM_MARKER_TYPE;
//	_marker setMarkerText (_arr call SYG_generateSPPMText);

	// create mark object (e.g. road cone) for this SPPM
	_pnt set [2, -1]; // attempt to put underground to keep forever, but it is not possible by any means(((
	_cone = createVehicle [SPPM_OBJ_TYPE, _pnt, [], 0, "CAN_COLLIDE"]; // add road cone
	_cone setVariable [SPPM_MARKER_NAME, _marker ];
//#ifdef __DEBUG__
//	hint localize format["+++ SYG_addSPPMMarker: marker %1 assigned to road cone", _marker];
//#endif
	SYG_SPPMArr set [ count SYG_SPPMArr, _cone ];	// put new object to the list
	["STR_SPPM_ADD_SUCCESS", round( _pos distance _cone)]
};

// Update one designated SPPM
// _res = _cone call SYG_updateSPPM;
// returns: corresponding message tag in the stringtable.csv
SYG_updateSPPM = {
	// hint localize format["+++ SYG_updateSPPM: call with _this = %1", _this];
	if (typeOf _this != SPPM_OBJ_TYPE ) exitWith {
		hint localize format["--- SYG_updateSPPM: item isn't of predefined type (%1), delete it", SPPM_OBJ_TYPE];
	 	["STR_SPPM_6_3",typeOf _this] //Marking object (%1) on SPPM of unknown type!
	 };
	private ["_marker","_arr","_new_pos","_pos"];
	_marker = _this getVariable SPPM_MARKER_NAME;
	if ( isNil "_marker" ) exitWith { // this is not SPPM marker cone
		hint localize format["--- SYG_updateSPPM: marker non-assigned to the SPPM cone, delete it!"];
		[SYG_SPPMArr, _this] call SYG_removeObjectFromArray; // remove cone
		"STR_SPPM_6_1"  // The SPPM without marker removed
	};
	_pos = getMarkerPos _marker;
	_arr = _pos call SYG_getAllSPPMVehicles;
	hint localize format["+++ SYG_updateSPPM: %1 vehicles count %2", _marker, count _arr];
	if ( count _arr == 0 ) exitWith {
		hint localize format["+++ SYG_updateSPPM: empty SPPM removed"];
		// remove this SPPM as empty
//		SYG_SPPMArr = SYG_SPPMArr - [_this]; // remove cone
		deleteMarker _marker; // remove marker itself
		[SYG_SPPMArr, _this] call SYG_removeObjectFromArray; // remove from array
		deleteVehicle _this; // remove cone from system too
	 	"STR_SPPM_6"   // The empty SPPM removed
	 };
	 // Cone, marker, vehicles found, let check center point
	_new_pos = _arr call SYG_averPoint;
	_arr = _arr call SYG_generateSPPMText;
	_marker setMarkerType (_arr select 0);
	_marker setMarkerText (_arr select 1);

	if ( [_pos, _new_pos] call SYG_distance2D > 1 ) exitWith { // SPPM center moved
		if ( (_new_pos call SYG_findNearSPPMCount) > 1 ) exitWith {"STR_SPPM_4_1"}; // "This SPPM cannot be updated due to the proximity of another SPPM"
		// move mark object to marker pos
		hint localize format["*** SPPM ""%1"" position changed by %2 m.", _marker, [_pos, _new_pos] call SYG_distance2D];
		_new_pos set [2, -1];
		_this setVectorUp [0,0,1];
		_this setVehiclePosition [_new_pos, [], 0, "CAN_COLLIDE"];
		_marker setMarkerPos _new_pos;
		"STR_SPPM_4"     // The existing SPPM is updated
	};
	"STR_SPPM_5" // "The existing SPPM is used"
};

// Generate text title for SPPM marker
//
// call:
//	_arr = [_veh1, _veh2...];
//  _arr = _arr call SYG_generateSPPMText; // _arr = [_marker_type, _marker_text]
//
// returns follow string: "0:1:2:3:4" where 0 is number of trucks, 1 is for tanks/BMP, 2 is for cars/moto, 3 is for ships, 4 is for air
// result may be in partial form: "СППМ:1:1" - that means 1 ship and 1 air vehicle
SYG_generateSPPMText = {
	if (typeName _this != "ARRAY") then {_this = [_this]};
	private ["_cntArr","_mrkArr","_marker","_title","_i","_marker","_ace_support","_x"];
	_cntArr = [ 0, 0, 0, 0, 0 ]; // type counts
#ifdef __ACE__
	_mrkArr = ["ACE_Icon_Unknown","ACE_Icon_Unknown","ACE_Icon_Unknown","ACE_Icon_Unknown","ACE_Icon_Unknown"];  // markers array
#else
	_mrkArr = ["Vehicle","Vehicle","Vehicle","Vehicle","Vehicle"];  // markers array
#endif
	// clean array
	for "_i" from 0 to count _this -1 do {
		_x = _this select _i;
		if (typeName _x != "OBJECT") then { _this set [_i, "RM_ME"] };
	};
	_this call SYG_clearArrayB;
#ifdef __ACE__
	_ace_support = ""; // main marker from any combinations of SPPM vehicle (ACE :o)
#endif
	// fill all possible params
	{
		_marker = _x call SYG_getVehicleMarkerType; // method from SYG_uitlsVehicles.sqf
#ifdef __ACE__
		if (_marker == "ACE_Icon_TruckSupport") then { _ace_support = _marker };
#endif

//		hint localize format["+++  SYG_getVehicleMarkerType, type  %1, marker %2", typeOf _x,  _marker ];
		if (true) then {
			if (_x isKindOf "Truck") exitWith {
#ifdef __ACE__
				// if ammo truck detected, use its marker in  any case, use it as first SPPM position!!!
				if (_ace_support == "ACE_Icon_TruckSupport") exitWith { _cntArr set [0 , (_cntArr select 0) +1 ]; _mrkArr set [0, _ace_support] };
#endif
				_cntArr set [0 , (_cntArr select 0) +1 ]; _mrkArr set [0, _marker]
			};
			if (_x isKindOf "Tank")  exitWith { _cntArr set [1 , (_cntArr select 1) +1 ]; _mrkArr set [1, _marker] };
			if (_x isKindOf "Car")   exitWith { _cntArr set [2 , (_cntArr select 2) +1 ]; _mrkArr set [2, _marker] };
			if (_x isKindOf "Ship")  exitWith { _cntArr set [3 , (_cntArr select 3) +1 ]; _mrkArr set [3, _marker] };
			if (( _x isKindOf "Air" ) && ( !( _x isKindOf "ParachuteBase" ) ) ) then { _cntArr set [4 , (_cntArr select 4) +1 ]; _mrkArr set [4, _marker] };
		};
	} forEach _this;

	// Find most important marker
	{
		if ( ( _cntArr select _x) > 0) exitWith {_marker = _mrkArr select _x};
	} forEach [ 0,1,2,3,4];

	_title = "";
	{
		if (_x == 0) then { if (_title != "")
			then {_title = format["%1:", _title]} }
			else { if(_title == "") then {_title = format["СППМ:%1",_x]} else {_title = format["%1:%2",_title, _x]} };
	} forEach _cntArr;
	[_marker, _title]
};

// Updates all markers on map removing empty ones
SYG_updateAllSPPMMarkers = {
//	hint localize format["+++ SYG_updateAllSPPMMarkers +++"];
	private ["_marker","_count_updated","_count_removed","_count_empty","_pos","_arr","_new_pos","_i","_cone"];
	_count_updated = 0; // how many mark objects were corrected
	_count_removed = 0; // how many mark objects were removed
	_count_empty = 0; // how many mark objects were empty (not attached to markers)
	for "_i" from 0 to count SYG_SPPMArr - 1 do  {
		_cone =  SYG_SPPMArr select _i; // road cone linked with SPPM marker
		_marker = _cone getVariable SPPM_MARKER_NAME;
		if ( !isNil "_marker" ) then {
			_pos = getMarkerPos _marker;
			_arr = _pos call SYG_getAllSPPMVehicles;
			if ( count _arr == 0) exitWith {
				// remove empty (no vehicles) marker
				deleteMarker _marker;
				_cone setVariable [SPPM_MARKER_NAME, nil ];
				deleteVehicle _cone;
				_count_removed = _count_removed + 1;
				SYG_SPPMArr set [_i, "RM_ME"];
				hint localize format["*** SPPM: empty ""%1"" (%2) is removed", _marker, _pos];
			};
			// recalculate center position of SPPM
			_new_pos = _arr call SYG_averPoint;
//			hint localize format["+++ SPPM update: cnt %1, old pos %2, new pos %3", count _arr, _pos, _new_pos];
			if ( [_pos, _new_pos] call SYG_distance2D > 1) then {
					if ( _new_pos call SYG_findNearSPPMCount == 1) then {
					_marker setMarkerPos _new_pos;
					// move the mark object to a new pos
					_marker setMarkerPos _new_pos;
					_count_updated = _count_updated + 1;
					_new_pos set [2, -1];
					_cone setVectorUp [0,0,1];
					_cone setVehiclePosition  [_new_pos, [], 0, "CAN_COLLIDE"]; // update name just in case
					hint localize format["*** SPPM ""%1"" position changed by %2 m.", _marker, round( [_pos, _new_pos] call SYG_distance2D ) ];
				} else {
					hint localize format["*** SPPM ""%1"" position could be changes by %2 m. but is closer then 50 m. to other SPPM", _marker, [_pos, _new_pos] call SYG_distance2D];
				};
			};
			_arr = _arr call SYG_generateSPPMText;
			_marker setMarkerType (_arr select 0);
			_marker setMarkerText (_arr select 1);
		} else { _count_empty = _count_empty + 1 };
	};
	SYG_SPPMArr call SYG_clearArrayB;
	//player groupChat format["+++  count %1, updated %2, removed %3", count SYG_SPPMArr, _count_updated, _count_removed];
	hint localize format["+++ SYG_updateAllSPPMMarkers: count %1, updated %2, removed %3, empty %4", count SYG_SPPMArr, _count_updated, _count_removed, _count_empty];
	[_count_updated, _count_removed]
};
hint localize "+++ INIT of SYG_utilsSPPM completed";
