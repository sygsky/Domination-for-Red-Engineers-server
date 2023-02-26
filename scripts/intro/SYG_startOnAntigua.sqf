/*
	SYG_startOnAntigua.sqf: process arrival on Antigua while you not visited the base
	author: Sygsky
	description: none
	returns: nothing
*/

#define __DEBUG__

_rects = [ // rectangles for boats to be available
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
// create point in the water near Antigus
_create_point_near_Antigua = {

};

// 1. DC3 flight to the Antigua or simple drop from a plane