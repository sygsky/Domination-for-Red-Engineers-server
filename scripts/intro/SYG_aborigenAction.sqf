/*
	SYG_aborigenAction.sqf
	author: Sygsky
	description:
		Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
		target (_this select 0): Object - the object which the action is assigned to
		caller (_this select 1): Object - the unit that activated the action
		ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
		arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
									may be "BOAT", "CAR", "WEAPON", "MEN", "RUMORS"
	returns: nothing
*/

if (typeName _this != "ARRAY") exitWith {hint localize format["--- SYG_aborigenAction.sqf: unknown _this = %1", _this]};

_rects = [ // rectangles near shores for boats to be available for players
[ [17170.4,18146.9,0], 120, 50, 12.8  ],
[ [17169.0,17860.3,0], 240, 50, 107.7 ],
[ [17241.5,17750.3,0], 160, 50, -36.75 ],
[ [17672.8,17830.5,0], 240, 50, 107.7 ]
];

// call as: _at_shore =  _boat call _is_near_shore;
_is_near_shore = {
	private ["_pos","_res","_x"];
	_pos = _this call SYG_getPos;
	_res = false;
	{
		if ([_pos, _x] call SYG_pointInRect  ) exitWith {_res = true};
	} forEach _rects;
	_res
};

// no slope check, only on land check
// _pos = [  9386,  8921, 0 ], 600, 200, -5,...];
// _new_pos = _pos call XfGetRanPointSquareOld;
_XfGetRanPointInRectOnWater = {
	private ["_i", "_pos", "_a", "_b", "_angle", "_centerx", "_centery", "_leftx", "_lefty", "_width", "_height", "_ret_val", "_px1", "_py1", "_rotpnt" ];
	_pos = _this select 0;_a = _this select 1;_b = _this select 2;_angle = _this select 3;
	_centerx = _pos select 0;_centery = _pos select 1;_leftx = _centerx - _a;_lefty = _centery - _b;
	_width = 2 * _a;_height = 2 * _b;_ret_val = [];
	for "_i" from 1 to 50 do {
		_px1 = _leftx + random _width;
		_py1 = _lefty + random _height;
		// E.g.:  _rect = [[  9386,  8921, 0 ], 600, 200, -5, ...]; // Parachute drop rectangle
		// _rotpnt = [_center_pnt, _pnt2rot, _angle] call SYG_rotatePoint;
		_rotpnt = [_pos, [_px1,_py1], -_angle] call SYG_rotatePointAroundPoint; // rotate in inverse direction as directions are different in algebra (ccw) and in Arma (cw)
		if ( surfaceIsWater _rotpnt ) exitWith { _ret_val = _rotpnt };
		sleep 0.01;
	};
	_ret_val
};

// create point in the water near Antigus
_create_water_point_near_Antigua = {
	_sum = 0;
	{ _sum = _sum + (_x select 1) } count _rects; // count summary length of all rects, all widths are equal
	_rnd  = random _sum;
	_len = 0;
	_pos = [];
	{
		_len = _len + (_x select 1);
		if (_len >= _rnd) exitWith {_pos = _x call _XfGetRanPointInRectOnWater};
	} forEach _rects;
	if (count _pos == 0) then {
		_pos = (_rects call XfRandomArrayVal) call _XfGetRanPointInRectOnWater;
	};
	_pos
};
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+                       START HERE                          +
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_arg = _this select 3;
_str = localize "STR_ABORIGEN_UNKNOWN";

switch ( _arg ) do {

	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	case "BOAT": { // ask about boats
		// TODO: find distance to the boat type "Zodiac" ( small boats )
		_arr = nearestObjects [player, ["Zodiac"], 2500];
		_boat = objNull;
		{
			if (alive _boat) exitWith {
				_boat = _x;
				_x setDamage 0;
				_x setFuel (0.333333 max (fuel _x)) ;
			};
		} forEach _arr;

		if (isNull _boat) then { // found any empty one and move it here
			_arr = [];
			{
				if (_x isKindOf "Zodiac") then {
					_pl = [ getPos _x, 50 ] call SYG_findNearestPlayer;
					if ( !isNull _pl ) then { // no players within 50 meters of the boat
						_arr set[ count _arr, _x ];
					};
				};
			} forEach vehicles;
			_boat = _arr call XfRandomArrayVal;
		};
		_pnt = call _create_water_point_near_Antigua;
		_boat setPos _pnt;
		player groupChat format[localize "STR_ABORIGEN_BOAT", round(player distance _boat), ([player, _boat] call XfDirToObj) call SYG_getDirName]; // "The nearest boat is %1 m away direction %2"
		(_this select 0) lookAt _boat;
		(_this select 0) spawn {sleep 5; _this doWatch objNull};
	};

	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	case "CAR": { // ask about boats
		player groupChat format[localize "STR_ABORIGEN_CAR"]; // "Sorry. I don't know anything about cars. We live here."
	};

	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	case "WEAPON": { // ask about weapon box
		// TODO: find any "ReammoBox" type object and say about nearest

	};

	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	case "MEN": { // ask about boats

	};
	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	case "RUMORS": { // ask about boats
		[] execVM "scripts\rumours.sqf";
	};
	default {

	};
};

