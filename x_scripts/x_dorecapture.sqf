// by Xeno

private ["_target_center", "_radius", "_recap_index", "_helih", "_unitslist", "_ulist", "_posran", "_grp", "_vecs", "_grp_array", "_i", "_units", "_vec","_veclist", "_arr"];

if (!isServer) exitWith	{};

#include "x_setup.sqf"
#include "x_macros.sqf"

_target_center = _this select 0;
_radius = _this select 1;
_recap_index = _this select 2;
_helih = _this select 3;

_veclist = [];
_unitslist = [];

{
	_ulist = [_x,d_enemy_side] call x_getunitliste;
	_posran = [_target_center, _radius] call XfGetRanPointCircle;
	while {count _posran == 0} do {
		_posran = [_target_center, _radius] call XfGetRanPointCircle;
		sleep 0.4;
	};
	__WaitForGroup
	_grp = [d_enemy_side] call x_creategroup;
	_vecs = [(2 call XfRandomCeil),_posran,(_ulist select 2), (_ulist select 1),_grp,0,-1.111,true] call x_makevgroup;
	{_x lock true} forEach _vecs;
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
	_grp_array = [_grp, _posran, 0,[_target_center,_radius],[],-1,0,[], (_radius max 300) + (random 50),-1];
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
	__WaitForGroup
	_grp = [d_enemy_side] call x_creategroup;
	_units = [_posran,(_ulist select 0),_grp,true] call x_makemgroup;
	_unitslist = _unitslist + _units;
	sleep 0.01;
	_grp_array = [_grp, _posran, 0,[_target_center,_radius],[],-1,0,[],(_radius max 300) + (random 50),-1];
	_grp_array execVM "x_scripts\x_groupsm.sqf";
	sleep 0.512;
};

sleep 10;

while {({alive _x} count (_unitslist + _veclist)) > 5} do {sleep 10.312};

sleep 5;

_helih setDir -532.37;

d_recapture_indices = d_recapture_indices - [_recap_index];

//+++Sygsky: add more fun with flags
if (d_own_side == "EAST") then
{
	_arr = nearestObjects[_target_center,["FlagCarrierNorth"],_radius];
	{
		_x setFlagTexture "\ca\misc\data\rus_vlajka.pac"; // set USSR flag again
	} forEach _arr;
};
//---Sygsky

["recaptured",_recap_index,1] call XSendNetStartScriptClient;

sleep 300;

{
	if (!isNull _x) then {
		_vec = _x;
		{if (!isNull _x) then {deleteVehicle _x}} forEach ([_vec] + crew _vec);
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