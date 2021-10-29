// by Xeno, x_scripts\x_dorecapture.sqf, server call only

private ["_target_center", "_radius", "_recap_index", "_helih", "_unitslist", "_ulist", "_posran", "_grp", "_vecs",
		 "_grp_array", "_i", "_units", "_vec","_veclist", "_arr","_xside"];

if (!isServer) exitWith	{};

#include "x_setup.sqf"
#include "x_macros.sqf"

_target_center = _this select 0;
_radius = _this select 1;
_recap_index = _this select 2;
_helih = _this select 3;

_veclist = [];
_unitslist = [];

_veccnt = 0; // vehicle cnt
_infcnt = 0; // infantry cnt

{
	_ulist = [_x,d_enemy_side] call x_getunitliste;
	_posran = [];
	while {count _posran == 0} do {
		_posran = [_target_center, _radius] call XfGetRanPointCircle;
		sleep 0.4;
	};
	//__WaitForGroup
	//_grp = [d_enemy_side] call x_creategroup;
	_grp = call SYG_createEnemyGroup;
	_vecs = [(2 call XfRandomCeil),_posran,(_ulist select 2), (_ulist select 1),_grp,0,-1.111,true] call x_makevgroup;
	_veccnt = _veccnt + (count _vecs);
#ifdef __LOCK_ON_RECAPTURE__
	{_x lock true} forEach _vecs;
#endif
	sleep 1.012;
	_veclist = _vecs;
	{
		{
			_unitslist = _unitslist + [_x];
			sleep 0.01;
		} forEach (crew _x);
		sleep 0.01;
	} forEach _vecs;
	sleep 0.01;
	_grp_array = [_grp, _posran, 0,[_target_center, _radius], [], -1, 0, [], _radius - random 50, -1];
	_grp_array execVM "x_scripts\x_groupsm.sqf";
	sleep 0.512;
} forEach ["tank","bmp"];

sleep 1.23;

for "_i" from 0 to 1 do {
	_ulist = ["basic",d_enemy_side] call x_getunitliste;
	_posran = [_target_center, _radius] call XfGetRanPointCircle;
	 while {count _posran == 0} do {
		_posran = [_target_center, _radius] call XfGetRanPointCircle;
		sleep 0.4;
	};
	//__WaitForGroup
	//_grp = [d_enemy_side] call x_creategroup;
	_grp = call SYG_createEnemyGroup;
	_units = [_posran,(_ulist select 0),_grp,true] call x_makemgroup;
	_infcnt = _infcnt + 1;
	_unitslist = _unitslist + _units;
	sleep 0.01;
	_grp_array = [_grp, _posran, 0,[_target_center, _radius], [], -1, 0, [], _radius - random 50, -1];
	_grp_array execVM "x_scripts\x_groupsm.sqf";
	sleep 0.512;
};

_loc = _target_center call SYG_nearestSettlement;
_locname = text _loc;
hint localize format["+++ Town %1 recaptured (rad. %2 м.), %3 vehicles and %4 infantry groups (%5 men)", _locname, _radius, _veccnt, _infcnt, count _unitslist];
sleep 10;

while { ( {(alive _x) && (side _x) == d_side_enemy } count ( _target_center nearObjects ["Land", _radius] ) ) > 5 } do {sleep 10.312};

hint localize format["+++ Recaptured town %1 is free, remained %2 vehs and %3 men",
    _locname,
    {alive _x && side _x == d_side_enemy} count ( (_target_center nearObjects ["Tank", _radius]) + (_target_center nearObjects ["Car", _radius])),
    {alive _x&& side _x == d_side_enemy} count (_target_center nearObjects ["CAManBase", _radius])
];

sleep 5;

_helih setDir -532.37;

d_recapture_indices = d_recapture_indices - [_recap_index];  SYG_remove

//+++Sygsky: add more fun with flags
if (d_own_side == "EAST") then
{
    _sound= false;
	_arr = nearestObjects[_target_center,["FlagCarrierNorth"],_radius];
	{
		_x setFlagTexture "\ca\misc\data\rus_vlajka.pac"; // set USSR flag again
		if (!_sound) then {
        	 ["say_sound", _x, "USSR"] call XSendNetStartScriptClientAll;
		    _sound = true;
		};
	} forEach _arr;
};
//---Sygsky

["recaptured",_recap_index,1] call XSendNetStartScriptClient;

sleep 300;

{
	if (!isNull _x) then {
		_vec = _x;
		_xside =  format["%1", side _x];
		if ( alive _x && (!(_x call SYG_vehIsUpsideDown)) &&
			(
			 (_xside == d_own_side ) ||
			 ( (_xside != d_enemy_side) && ( [getPos _x, d_base_array] call SYG_pointInRect ) && ((getDammage _x) < 0.000001) )
			)
		   )  then { // vehicle was captured by player
			// re-assign vehicle to be ordinal ones
#ifdef __SYG_ISLEDEFENCE_PRINT_SHORT__
			hint localize format["+++ x_isledefense: vec %1 is captured by Russians! Now side is %2, pos on base %3, damage %4", typeOf _x, side _x, [getPos _x, d_base_array] call SYG_pointInRect, damage _x];
#endif
			// put vehicle under system control
			[_x] call XAddCheckDead;
		} else {
			{if (!isNull _x) then {deleteVehicle _x}} forEach ([_vec] + crew _vec);
		};
	};
} forEach _veclist;

{
	if (!isNull _x) then {
		if (!isNull _x) then {deleteVehicle _x};
	};
} forEach _unitslist;
_unitslist = nil;
_veclist = nil;

if (true) exitWith {};