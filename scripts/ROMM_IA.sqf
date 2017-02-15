/*	
	ROMM_IA.sqf;
	Version: 112 [14, 06, 2008];
	Author(s): Rommel [rommelvonrichtofen_at_bigpond.com];
	Execution: nul = [group this] call compile preProcessFile "ROMM_IA.sqf";
*/

#include "x_setup.sqf"

if !(isServer) exitWith {};

private ["_g", "_i", "_k","_s", "_b", "_l", "_d", "_t", "_o", "_od", "_c","_setGrpBehaviour","_splitByMG","_fC","_fD"];

// set group behaviour
_setGrpBehaviour = {
	_g = _this select 0; // group
	_s = _this select 1; // speen
	_b = _this select 2; // combat mode
	_f = _this select 3; // possible error: no such parameter in any call

	_l = leader _g;

	{if (alive _x) then {_x doFollow _l; _x setUnitPos "AUTO";}} forEach units _g;

	_g setCombatMode _b;
	_g setSpeedMode _s;
	_g setFormation _f;

	_k = false;
};

//
// split group to machinegunners and not machinegunners and call _fD
// _g = select 0; // group
// _d = select 1; // enemy shooter direction
_splitByMG = {
	private ["_g", "_d", "_o", "_u"];

	_g = _this select 0;
	_d = _this select 1;

	_g setCombatMode "YELLOW";
	_g setSpeedMode "FULL";
	_g setFormation "LINE";

	_o = []; // list of machinegunners

	// select machinegunners only
	{_u = _x; {if (_u hasWeapon _x) then {_o = _o + [_u]};} forEach ["M249","M240","PK"];} forEach units _g; 

	{if (alive _x) then {[_x, _k, _d] spawn _fC}} forEach units _g;

	_k = true;

	{if (alive _x) then {[_x, _d] spawn _fD}} forEach _o; // first order action  each machinegunners

	sleep 8.0;

	{if (alive _x) then {[_x, _d] spawn _fD}} forEach units _g - _o; // second order action each non machinegunner
};

_fC = {
	private ["_u", "_k", "_d", "_y"];

	_u = _this select 0;
	_k = _this select 1;
	if (_k) exitWith {};

	_u setUnitPos "DOWN";

//	if (count _this > 1) then {
	if (count _this > 2) then { //+++ Sygsky: possible bag cleared
		_d = _this select 2;
		_u commandWatch [(getPos _u select 0)+ sin(_d) * 43,(getPos _u select 1)+ cos(_d) * 43, (getPos _u select 2) + 1];
	};

	_k = _u findCover [getPos _u, getPos _u, 43];
	_y = (_u distance _k) / 2;

	_u commandMove getPos _k;

	sleep _y;

	commandStop _u;

	sleep _y;

	_u commandMove getPos _k;

//	if (floor(random 10) > 9) then  {
	if (floor(random 10) >= 9) then  { //+++ Sygsky: possible bug clear (floor (random 10) never exceeeds 9, may be only equal to it
		_u setUnitPos "AUTO";
	};
};

//
// this subroutine is not for snipers
//
_fD = {
	private ["_u", "_d", "_i", "_t", "_f","_v"];

	_u = _this select 0;

#ifdef __ACE__	
	if (primaryWeapon _u in ["M24", "M107", "SVD","KSVK", "ACE_M14"]) exitWith {}; // exit if sniper
#else
	if (primaryWeapon _u in ["M24", "M107", "SVD","KSVK"]) exitWith {};
#endif	

	_d = _this select 1;

	_t = "Logic" createVehicleLocal [0,0,0];
	_f = _u findNearestEnemy getPos _u;

	if !(vehicle _f in crew _f) exitWith {};

	_i = 0;

	while {(alive _u) AND (_i < 14)} do {
   		_u commandWatch position _f;
		sleep (random 7.0);
		_v = (((getPos _u select 0) - (getPos _f select 0)) atan2 ((getPos _u select 1) - (getPos _f select 1))) +360 % 360;
		if (abs _v < 25) then {_t action ["useWeapon",_u,_u,1];};
		_i = _i + 1;
	};
	deleteVehicle _t;
};

_g = _this select 0;
_i = {alive _x} count units _g;
_k = false;


_s = speedMode _g;
_b = combatMode _g;
_f = formation _g;

_c = -1;

while {_i > 0} do {
	if (isNull _g) exitWith {};
	if (_i > {alive _x} count units _g) then {
		{if (alive _x) then {[_x, _k] spawn _fC}} forEach units _g;
		_c = _t + 143;

		_i = {alive _x} count units _g;
	};
	if (_i == 0) exitWith {};

	_l = leader _g;
	_d = getDir _l;
	_t = time;

	if (!(isNull _l)) then {
		_o = nearestObject [_l, "BulletBase"];

		if (!(isNull _o)) exitWith {
			_od = getDir _o - 180; // where bullet is from
			if ((_od < _d + 109 AND _od > _d - 109) OR (_od > _d + 109 AND _od < _d - 109)) then { // possible logic error: value under IF is always true!!!
				[_g, _od] call _splitByMG;
				_c = _t + 143;
			};
		};

		_o = nearestObject [_l, "GrenadeHand"];
		if (!(isNull _o)) exitWith {
			{if (alive _x) then {[_x, _k] spawn _fC}} forEach units _g;
			_k = true;
			_c = _t + 43;
		};
		_o = nearestObject [_l, "G_40mm_HE"];

		if (!(isNull _o)) exitWith {
			{if (alive _x) then {[_x, _k] spawn _fC}} forEach units _g;
			_k = true;
			_c = _t + 23;
		};
		_o = nearestObject [_l, "RocketCore"];

		if (!(isNull _o)) exitWith {
			{if (alive _x) then {[_x, _k] spawn _fC}} forEach units _g;
			_k = true;
			_c = _t + 33;
		};
		_o = nearestObject [_l, "ShellCore"];

		if (!(isNull _o)) exitWith {
			{if (alive _x) then {[_x, _k] spawn _fC}} forEach units _g;
			_k = true;
			_c = _t + 23;
		};
		_o = nearestObject [_l, "MissileCore"];

		if (!(isNull _o)) exitWith {
			{if (alive _x) then {[_x, _k] spawn _fC}} forEach units _g;
			_k = true;
			_c = _t + 43;
		};
	};

	if (_c != -1 AND _t > _c) then {
		[_g, _s, _b] call _setGrpBehaviour;

		_c = -1;
	};

	sleep 1.0;
};

