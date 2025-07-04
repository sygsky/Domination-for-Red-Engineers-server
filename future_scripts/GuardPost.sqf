//	Simple Guard Post Script 1.0
//	by Tophe of Östgöta Ops
//
//	Usage with default values:
//	nul = [this] execVM "GuardPost.sqf"
//
//	Optional settings:
//	nul = [unit, range in degrees, behaviour, stance (up/down/middle/auto), look up/down, min delay] execVM "GuardPost.sqf"
//
//	Default values:
//	nul = [this, 240, "SAFE", "AUTO", false, 1] execVM "GuardPost.sqf"
//

if (!isServer) exitWith {};

_unit 		= _this select 0;
_range	 	= if (count _this > 1) then {_this select 1} else {240};
_beh		= if (count _this > 2) then {_this select 2} else {"SAFE"};
_stance		= if (count _this > 3) then {_this select 3} else {"AUTO"};
_height		= if (count _this > 4) then {_this select 4} else {false};
_delay 		= if (count _this > 5) then {_this select 5} else {1};	

_enemy 		= if (side _unit == east) then {west} else {east};
_startdir	= getDir _unit;
_zaxis 		= 0;

if (_range < 0) then {_range = 0};
if (_range > 360) then {_range = 360};

if 	(_beh == "CARELESS" || _beh == "SAFE" || _beh == "AWARE" || _beh == "COMBAT" || _beh == "STEALTH") 
	then 
	{_unit setBehaviour _beh} else {_unit setBehaviour "SAFE"};

_unit setUnitPos _stance;


// Start scanning 
while {alive _unit} do
{
	_left = _startdir - (_range/2);
	_right = _startdir + (_range/2);

	if (_left > _right) then {_left = _startdir - (_range/2); _right = _startdir + (_range/2)};	

	_left = round _left;
	_right = round _right;

	_dir = (random (_right - _left) + _left) call SYG_normalizeAngle;

	_pos  = position _unit;
	if (_height) then {_zaxis = random 20};
	if (!_height) then {_zaxis = _pos select 2};
	_pos = [(_pos select 0) + 50*sin _dir, (_pos select 1) + 50*cos _dir, _zaxis];

	_unit doWatch _pos;

	// Pause if unit is engaging
	_enemy = _unit findNearestEnemy position _unit;
	if ( ! isNull _enemy ) then 
	{
		waitUntil {{if (side _x == _enemy) then {_unit knowsAbout _x < 4}} count AllUnits > 0};
				
	};
	sleep (random 10) + _delay;
};