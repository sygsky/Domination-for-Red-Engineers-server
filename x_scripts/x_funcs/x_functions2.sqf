// by Xeno

x_funcs2_compiled = false;

// direction from one object/position to another
// parameters: object1 or position1, object2 or position2 
// example: _dir = [pos1, obj2] call XfDirToObj; // dir from pos1 to pos2
//         _dir = [tank1, ATPod] call XfDirToObj; // dir from tank to pod
XfDirToObj = {
	private ["_o1","_o2""_deg"];
	_o1 = _this select 0;_o2 = _this select 1;
	if ( typeName _o1 != "ARRAY" ) then { _o1 = position _o1;};
	if ( typeName _o2 != "ARRAY" ) then { _o2 = position _o2;};
	_deg = ((_o2 select 0) - (_o1 select 0)) atan2 ((_o2 select 1) - (_o1 select 1));
	if (_deg < 0) then {_deg = _deg + 360;};
	_deg
};
 
// get a random number, floored, from count array
// parameters: array
// example: _randomarrayint = _myarray call XfRandomFloorArray;
XfRandomFloorArray = {
	floor (random (count _this))
};

// get a random item from an array
// parameters: array
// example: _randomval = _myarray call XfRandomArrayVal;
XfRandomArrayVal = {
	_this select (_this call XfRandomFloorArray);
};

// get a random numer, ceiled
// parameters: number
// example: _randomint = 30 call XfRandomCeil;
XfRandomCeil = {
	ceil (random _this)
};

// returns the number of human players currently playing a mission in MP
XPlayersNumber = {
	(playersNumber east + playersNumber west + playersNumber resistance + playersNumber civilian)
};

// gets a random number in a specific range
// parameters: number from, number to
// example: _random_number = [30,150] call XfGetRandomRange;
XfGetRandomRange = {
	private ["_num1","_num2","_ra"];
	_num1 = _this select 0;_num2 = _this select 1;
	_ra = _num2 - _num1;
	_ra = random _ra;
	(_num1 + _ra)
};

// gets a random integer number in a specific range
// parameters: integer from, integer to
// example: _random_integer = [30,150] call XfGetRandomRangeInt;
XfGetRandomRangeInt = {
	private ["_num1","_num2","_ra"];
	_num1 = _this select 0;_num2 = _this select 1;
	if (_num1 > _num2) then {_num1 = _this select 1;_num2 = _this select 0;};
	_ra = _num2 - _num1;
	_ra = _ra call XfRandomFloor;
	(_num1 + _ra)
};

// compares two arrays, if equal returns true, if not false
// parameters: array1, array2
// example: _isequal = [array1, array2] call XfArrayCompare;
XfArrayCompare = {
	if (str (_this select 0) == str (_this select 1)) then {true} else {false}
};

// get height of object
// parameters: object (no brackets)
// _height = tank1 call XfGetHeight;
XfGetHeight = {
	position _this select 2
};

// set only height of an object
// parameters: object, height
// example: [unit1, 30] call XfSetHeight;
XfSetHeight = {
	(_this select 0) setPos [position (_this select 0) select 0, position (_this select 0) select 1, (_this select 1)];
};

// get x position of an object
// parameters: object (no brackets)
// _posx = tank1 call XfGetPosX;
XfGetPosX = {
	position _this select 0
};

// set only x position of an object
// parameters: object, x
// example: [unit1, 30] call XfSetPosX;
XfSetPosX = {
	(_this select 0) setPos [(_this select 1), position (_this select 0) select 1, position (_this select 0) select 2];
};

// get y position of an object
// parameters: object (no brackets)
// _posy = tank1 call XfGetPosY;
XfGetPosY = {
	position _this select 1
};

// set only y position of an object
// parameters: object, y
// example: [unit1, 30] call XfSetPosY;
XfSetPosY = {
	(_this select 0) setPos [position (_this select 0) select 0, (_this select 1), position (_this select 0) select 2];
};

// get displayname of an object
// parameters: type of object (string), what (0 = CfgVehicles, 1 = CfgWeapons, 2 = CfgMagazines)
// example: _dispname = ["UAZ", 0] call XfGetDisplayName;
XfGetDisplayName = {
	private ["_obj_name", "_obj_kind", "_cfg"];
	_obj_name = _this select 0;_obj_kind = _this select 1;
	_cfg = (switch (_obj_kind) do {case 0: {"CfgVehicles"};case 1: {"CfgWeapons"};case 2: {"CfgMagazines"};});
	getText(configFile >> _cfg >> _obj_name >> "displayName")
};

//+++ Added by Sygsky at 24-OCT-2014
// Gets randomized radious. Useful for correct spatially distributed random points density in the circle. See source: http://mathworld.wolfram.com/DiskPointPicking.html
// Parameters: radious of circle to insert random point (no brackets)
// Example: _randrad = 500 call XfRndRadious; // correctly distributed among disk square random value in range of 0..500
XfRndRadious = {
		(sqrt((random _this)/_this))*_this
};

// get a random point inside a circle
// parameters:
// center position, radius of the circle
// example: _random_point = [position trigger1, 200] call XfGetRanPointCircle;
XfGetRanPointCircle = {
	private ["_center", "_radius", "_center_x", "_center_y", "_ret_val", "_co", "_angle", "_x1", "_y1", "_helper", "_dist"];
	_center = _this select 0;_radius = _this select 1;
	_center_x = _center select 0;_center_y = _center select 1;
	_ret_val = [];_co = 0;
	while {count _ret_val == 0 && _co < 50} do {
		_angle = random 360;
        _dist = (sqrt(( random _radius)/ _radius)) * _radius;
		_x1 = _center_x - ( _dist * cos _angle);
		_y1 = _center_y - ( _dist * sin _angle);
		if (!(surfaceIsWater [_x1, _y1])) then {
			_helper = "RoadCone" createVehicleLocal [_x1,_y1,0];
			if (!(surfaceIsWater [position _helper select 0, position _helper select 1])) then {
				_slope = [position _helper, 5] call XfGetSlope;
				if (_slope < 0.5) then {
					_ret_val = [position _helper select 0, position _helper select 1,0];
				};
			};
			deleteVehicle _helper;
		};
		if (count _ret_val == 0) then {
			_co = _co + 1;
			sleep .01;
		};
	};
	_ret_val
};

// no slope check, only water check for patrolling
XfGetRanPointCircleOld = {
	private ["_center", "_radius", "_center_x", "_center_y", "_ret_val", "_co", "_angle", "_x1", "_y1", "_helper", "_dist"];
	_center = _this select 0;_radius = _this select 1;
	_center_x = _center select 0;_center_y = _center select 1;
	_ret_val = [];
	for "_co" from 0 to 50 do {
		_angle = random 360;
        _dist = (sqrt((random _radius)/ _radius)) * _radius;
		_x1 = _center_x - ( _dist * cos _angle);
		_y1 = _center_y - ( _dist * sin _angle);
		if (!(surfaceIsWater [_x1, _y1])) exitWith {
			_ret_val = [_x1, _y1, 0];
		};
        _co = _co + 1;
        sleep .01;
	};
	_ret_val
};

// get a random point inside a circle for bigger objects (not less than 20 meters from nearest static object)
// parameters:
// center position, radius of the circle
// example: _random_point = [position trigger1, 200] call XfGetRanPointCircleBig;
XfGetRanPointCircleBig = {
	private ["_center", "_radius", "_center_x", "_center_y", "_ret_val", "_co", "_angle", "_x1", "_y1", "_nobs", "_helper", "_dist"];
	_center = _this select 0;_radius = _this select 1;
	_center_x = _center select 0;_center_y = _center select 1;
	_ret_val = [];_co = 0;
	while {count _ret_val == 0 && _co < 50} do {
		_angle = random 360;
        _dist = (sqrt((random _radius)/ _radius )) * _radius;
		_x1 = _center_x - ( _dist * cos _angle);
		_y1 = _center_y - ( _dist * sin _angle);
		if (!(surfaceIsWater [_x1, _y1])) then {
			_nobs = [_x1,_y1,0] nearObjects ["Static",20];
			if (count _nobs == 0) then {
				_helper = "RoadCone" createVehicleLocal [_x1,_y1,0];
				if (!(surfaceIsWater [position _helper select 0, position _helper select 1])) then {
					_slope = [position _helper, 5] call XfGetSlope;
					if (_slope < 0.5) then {
						_ret_val = [position _helper select 0,position _helper select 1,0];
					};
				};
				deleteVehicle _helper;
			};
		};
		if (count _ret_val == 0) then {
			_co = _co + 1;
			sleep .01;
		};
	};
	_ret_val
};

// get a random point at the borders of a circle
// parameters:
// center position, radius of the circle
// example: _random_point = [position trigger1, 200] call XfGetRanPointCircleOuter;
XfGetRanPointCircleOuter = {
	private ["_center", "_radius", "_center_x", "_center_y", "_ret_val", "_co", "_angle", "_x1", "_y1", "_helper", "_dist"];
	_center = _this select 0;_radius = _this select 1;
	_center_x = _center select 0;_center_y = _center select 1;
	_ret_val = [];_co = 0;
	while {count _ret_val == 0 && _co < 50} do {
		_angle = random 360;
        _dist = _radius call XfRndRadious; // (sqrt((random _radius)/ _radius )) * _radius;
		_x1 = _center_x - ( _dist * cos _angle);
		_y1 = _center_y - ( _dist * sin _angle);
		if (!(surfaceIsWater [_x1, _y1])) then {
			_helper = "RoadCone" createVehicleLocal [_x1,_y1,0];
			if (!(surfaceIsWater [position _helper select 0, position _helper select 1])) then {
				_slope = [position _helper, 5] call XfGetSlope;
				if (_slope < 0.5) then {
					_ret_val = [position _helper select 0, position _helper select 1,0];
				};
			};
			deleteVehicle _helper;
		};
		if (count _ret_val == 0) then {
			_co = _co + 1;
			sleep .01;
		};
	};
	_ret_val
};

// get a random point inside a square not on slope and not in water
// parameters:
// center position, a and b (like in triggers), angle
// example: _random_point  = [position trigger2, 200, 300, 30] call XfGetRanPointSquare;
XfGetRanPointSquare = {
	private ["_pos", "_a", "_b", "_angle", "_centerx", "_centery", "_leftx", "_lefty", "_width", "_height", "_ret_val", "_co", "_px1", "_py1", "_radius", "_atan", "_x1", "_y1", "_helper"];
	_pos = _this select 0;_a = _this select 1;_b = _this select 2;_angle = _this select 3;
	_centerx = _pos select 0;_centery = _pos select 1;_leftx = _centerx - _a;_lefty = _centery - _b;
	_width = 2 * _a;_height = 2 * _b;_ret_val = [];_co = 0;
	while {count _ret_val == 0 && _co < 50} do {
		_px1 = _leftx + random _width;
		_py1 = _lefty + random _height;
		_radius = _pos distance [_px1,_py1];
		_atan = (_centerx - _px1) atan2 (_centery - _py1);
		_x1 = _centerx - (_radius * cos (_atan + _angle));
		_y1 = _centery - (_radius * sin (_atan + _angle));
		if (!(surfaceIsWater [_x1, _y1])) then {
			_helper = "RoadCone" createVehicleLocal [_x1,_y1,0];
			if (!(surfaceIsWater [position _helper select 0, position _helper select 1])) then {
				_slope = [position _helper, 5] call XfGetSlope;
				if (_slope < 0.5) then {
					_ret_val = [position _helper select 0, position _helper select 1,0];
				};
			};
			deleteVehicle _helper;
		};
		if (count _ret_val == 0) then {
			_co = _co + 1;
			sleep .01;
		};
	};
	_ret_val
};

// no slope check, only water check for patrolling
XfGetRanPointSquareOld = {
	private ["_pos", "_a", "_b", "_angle", "_centerx", "_centery", "_leftx", "_lefty", "_width", "_height", "_ret_val", "_co", "_px1", "_py1", "_radius", "_atan", "_x1", "_y1"];
	_pos = _this select 0;_a = _this select 1;_b = _this select 2;_angle = _this select 3;
	_centerx = _pos select 0;_centery = _pos select 1;_leftx = _centerx - _a;_lefty = _centery - _b;
	_width = 2 * _a;_height = 2 * _b;_ret_val = [];_co = 0;
	while {count _ret_val == 0 && _co < 50} do {
		_px1 = _leftx + random _width;
		_py1 = _lefty + random _height;
		_radius = _pos distance [_px1,_py1];
		_atan = (_centerx - _px1) atan2 (_centery - _py1);
		_x1 = _centerx - (_radius * cos (_atan + _angle));
		_y1 = _centery - (_radius * sin (_atan + _angle));
		if (!(surfaceIsWater [_x1, _y1])) then {
			_ret_val = [_x1, _y1, 0];
		};
		if (count _ret_val == 0) then {
			_co = _co + 1;
			sleep .01;
		};
	};
	_ret_val
};

// get a random point at the borders of a square
// parameters:
// center position, a and b (like in triggers), angle
// example: _random_point  = [position trigger2, 200, 300, 30] call XfGetRanPointSquareOuter;
XfGetRanPointSquareOuter = {
	private ["_pos", "_a", "_b", "_angle", "_centerx", "_centery", "_leftx", "_lefty", "_width", "_height", "_ret_val", "_co", "_px1", "_py1", "_radius", "_atan", "_x1", "_y1", "_helper"];
	_pos = _this select 0;_a = _this select 1;_b = _this select 2;_angle = _this select 3;
	_centerx = _pos select 0;_centery = _pos select 1;_leftx = _centerx - _a;_lefty = _centery - _b;
	_width = 2 * _a;_height = 2 * _b;_ret_val = [];_co = 0;
	while {count _ret_val == 0 && _co < 50} do {
		_rside = floor (random 4);
		_px1 = (
			switch (_rside) do {
				case 0: {_leftx + random _width};
				case 1: {_leftx + _width};
				case 2: {_leftx + random _width};
				case 3: {_leftx};
			}
		);
		_py1 = (
			switch (_rside) do {
				case 0: {_lefty + _height};
				case 1: {_lefty + random _height};
				case 2: {_lefty};
				case 3: {_lefty + random _height};
			}
		);
		_radius = _pos distance [_px1,_py1];
		_atan = (_centerx - _px1) atan2 (_centery - _py1);
		_x1 = _centerx - (_radius * cos (_atan + _angle));
		_y1 = _centery - (_radius * sin (_atan + _angle));
		if (!(surfaceIsWater [_x1, _y1])) then {
			_helper = "RoadCone" createVehicleLocal [_x1,_y1,0];
			if (!(surfaceIsWater [position _helper select 0, position _helper select 1])) then {
				_slope = [position _helper, 5] call XfGetSlope;
				if (_slope < 0.5) then {
					_ret_val = [position _helper select 0, position _helper select 1,0];
				};
			};
			deleteVehicle _helper;
		};
		if (count _ret_val == 0) then {
			_co = _co + 1;
			sleep .01;
		};
	};
	_ret_val
};

// hopefully not needed in A2, function returns two flanking positions for AI
// parameters: target unit(s) pos , flanking unit(s) pos, distance between both
// example: _flankarray = [position player, position _enemy1, (player distance _enemy1)]
XfGetFlankPos = {
	private ["_pp", "_pe", "_dis", "_px", "_py", "_ex", "_ey", "_angle", "_a", "_b", "_flank_ret", "_i", "_xp", "_yp", "_ret", "_rand"];
	_pp = _this select 0;_pe = _this select 1;_dis = _pp distance _pe;_px = _pp select 0;_py = _pp select 1;_ex = _pe select 0;_ey = _pe select 1;
	_angle = 0; _a = (_px - _ex);_b = (_py - _ey);
	if (_a != 0 || _b != 0) then {_angle = _a atan2 _b;};
	if (_angle < 0) then {_angle = _angle + 360;};
	_rand = random 100;_flank_ret = [];_i = if (_rand > 49) then {-85} else {85};
	_xp = _px - ((_dis * 0.5) * sin (_angle + _i));_yp = _py - ((_dis * 0.5) * cos (_angle + _i));_ret = [_xp,_yp,0];_flank_ret = _flank_ret + [_ret];
	sleep 0.001;_i = if (_rand > 49) then {-35} else {35};
	_xp = _px - ((_dis) * sin (_angle + _i));_yp = _py - ((_dis) * cos (_angle + _i));_ret = [_xp,_yp,0];
	_flank_ret = _flank_ret + [_ret];
	_flank_ret
};

// from warfare
// Returns an average slope value of terrain within passed radius.
// a little bit modified. no need to create a "global" logic, local is enough, etc
// parameters: position, radius
// example: _slope = [the_position, the_radius] call XfGetSlope;
XfGetSlope = {
	private ["_position", "_radius", "_slopeObject", "_centerHeight", "_height", "_direction", "_count"];
	_position = _this select 0;_radius = _this select 1;
	_slopeObject = "Logic" createVehicleLocal [0,0,0];
	_slopeObject setPos _position;
	_centerHeight = getPosASL _slopeObject select 2;
	_height = 0;_direction = 0;
	for "_count" from 0 to 7 do {
		_slopeObject setPos [(_position select 0)+((sin _direction)*_radius),(_position select 1)+((cos _direction)*_radius),0];
		_direction = _direction + 45;
		_height = _height + abs (_centerHeight - (getPosASL _slopeObject select 2));
	};
	deleteVehicle _slopeObject;
	_height / 8
};

// create a global marker
// parameters: marker name, marker pos, marker shape, marker color, marker size;(optional) marker text, marker dir, marker type, marker brush
// example: ["my marker",  position player, "ICON", "ColorBlue", [0.5,0.5]<,"AmmoBox",0,"Marker">] call XfCreateMarkerLocal;
XfCreateMarkerGlobal = {
	private ["_m_name","_m_pos","_m_shape","_m_col","_m_size","_m_text","_m_dir","_m_type","_m_brush"];
	_m_name = _this select 0;
	_m_pos = _this select 1;
	_m_shape = _this select 2;
	_m_col = _this select 3;
	_m_size = _this select 4;
	_m_text = (if (count _this > 5) then {_this select 5} else {""});
	_m_dir = (if (count _this > 6) then {_this select 6} else {-888888888888});
	_m_type = (if (count _this > 7) then {_this select 7} else {""});
	_m_brush = (if (count _this > 8) then {_this select 8} else {""});
	
	_marker = createMarker [_m_name, _m_pos];
	if (_m_shape != "") then {_marker setMarkerShape _m_shape};
	if (_m_col != "") then {_marker setMarkerColor _m_col};
	if (count _m_size > 0) then {_marker setMarkerSize _m_size};
	if (_m_text != "") then {_marker setMarkerText _m_text};
	if (_m_dir != -888888888888) then {_marker setMarkerDir _m_dir};
	if (_m_type != "") then {_marker setMarkerType _m_type};
	if (_m_brush != "") then {_marker setMarkerBrush _m_brush};
};

// create a local marker
// parameters: marker name, marker pos, marker shape, marker color, marker size;(optional) marker text, marker dir, marker type, marker brush
// example: ["my marker",  position player, "ICON", "ColorBlue", [0.5,0.5]<,"AmmoBox",0,"Marker">] call XfCreateMarkerLocal;
XfCreateMarkerLocal = {
	private ["_m_name","_m_pos","_m_shape","_m_col","_m_size","_m_text","_m_dir","_m_type","_m_brush"];
	_m_name = _this select 0;
	_m_pos = _this select 1;
	_m_shape = _this select 2;
	_m_col = _this select 3;
	_m_size = _this select 4;
	_m_text = (if (count _this > 5) then {_this select 5} else {""});
	_m_dir = (if (count _this > 6) then {_this select 6} else {-888888888888});
	_m_type = (if (count _this > 7) then {_this select 7} else {""});
	_m_brush = (if (count _this > 8) then {_this select 8} else {""});
	
	_marker = createMarkerLocal [_m_name, _m_pos];
	if (_m_shape != "") then {_marker setMarkerShapeLocal _m_shape};
	if (_m_col != "") then {_marker setMarkerColorLocal _m_col};
	if (count _m_size > 0) then {_marker setMarkerSizeLocal _m_size};
	if (_m_text != "") then {_marker setMarkerTextLocal _m_text};
	if (_m_dir != -888888888888) then {_marker setMarkerDirLocal _m_dir};
	if (_m_type != "") then {_marker setMarkerTypeLocal _m_type};
	if (_m_brush != "") then {_marker setMarkerBrushLocal _m_brush};
};

// send a text message over the network
// parameters: msg text, receiver ("unit","grp","all","vec"), receiver (unit, grp, vehicle), type ("global", "vehicle", "side", "group", "hint")
XfSendMessage = {
	["xmsg",_this] call XNTSendNetStartScriptClient;
};

// count all alive units in units or group {alive _x}
// call: _cnt = units _grp call XfGetAliveUnits;
// or call: _cnt = _grp call XfGetAliveUnits
XfGetAliveUnits = {
	if ( (typeName _this) == "GROUP" ) then { _this = units _this;};
	({alive _x} count _this)
};

/***********************************************
 * Finds real leader or first found alive team member
 * call: _leader = _grp call XfGetLeader;
 * or _leader    = _unit call XfGetLeader
 */
XfGetLeader = {
	private ["_leader"];
	if (isNull _this) exitWith { objNull };
	if (typeName _this == "OBJECT") then
	{
		_this = group _this;
	};
	if (isNull _this) exitWith { objNull };
	_leader = leader _this;
	if ( !isNull _leader ) exitWith {_leader};
	{
		if ( alive _x ) exitWith {_leader = _x };
	} forEach units _this;
	_leader
};

// count all units in units or group that can stand {canStand _x}
// call: _cnt = units _grp call XfGetAliveUnits;
// or call: _cnt = _grp call XfGetAliveUnits
XfGetStandUnits = {
	if ( (typeName _this) == "GROUP" ) then { _this = units _this;};
	({canStand _x} count _this)
};

// count all alive and fully health units in units or group
// call: _cnt = units _grp call XfGetAliveUnits;
// or call: _cnt = _grp call XfGetAliveUnits
XfGetHealthyUnits = {
	if ( (typeName _this) == "GROUP" ) then { _this = units _this;};
	({alive _x && (damage _x == 0)} count _this)
};

// count all group alive units  not in vehicles
// call: _cnt = units _grp call XfGetAliveUnits;
// or call: _cnt = _grp call XfGetAliveUnits
XfGetUnitsOnFeet = {
	if ( (typeName _this) == "GROUP" ) then { _this = units _this;};
	({(alive _x) AND (vehicle _x == _x)} count _this)
};

// call: _cnt = _grp call XfGetAliveUnits; // count all alive units in group
XfGetAliveUnitsGrp =  XfGetAliveUnits;

x_funcs2_compiled = true;

if (true) exitWith {};