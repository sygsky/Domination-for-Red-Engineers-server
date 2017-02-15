// x_scripts\x_sabotage.sqf, by Xeno
//
// not used on Red-Engineers server mission, instead scripts\sabotage.sqf is launched
//
// Sabotage functionality: try to blast factories
// 
private ["_attack_pos","_grp","_leader","_mags","_no","_obj","_obj_pos","_one_shell","_shell_unit","_continue","_retreat_pos","_bombScript", "_pipeBombCount"];
if (!isServer) exitWith {};

#include "x_setup.sqf" //+++ remove it later
#include "x_macros.sqf"

_grp = _this select 0;
_attack_pos = _this select 1;

_grp setBehaviour "AWARE";
_grp setCombatMode "YELLOW";

if (isNull _grp) exitWith {};
_continue = true;

#define __SYG_PIPEBOMB__

while { (({alive _x} count units _grp) > 0) && _continue } do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1); (call XPlayersNumber) > 0};
	};
	__DEBUG_NET("x_sabotage.sqf",(call XPlayersNumber))
	_leader = leader _grp;
	_no = nearestObjects [_leader,["WarfareBEastAircraftFactory","WarfareBWestAircraftFactory"],500];
	if ( count _no > 0 ) then 
	{
		_obj = _no select (floor random (count _no)); // get random building to sabotage
		if ( (alive _obj) && _continue ) then {
			_units = units _grp;
			_one_shell = "";
			_shell_unit = objNull;
			{
				scopeName "xxxx3";
				_mags = magazines _x;
#ifdef 	__SYG_PIPEBOMB__				
				_pipeBombCount = {_x == "ACE_PipeBomb"} count _mags;
				//_pipeBombCount = "PipeBomb" countType (magazines _x);
				if ( _pipeBombCount > 0 ) then
				{
					_shell_unit = _x;
					_one_shell = "ACE_PipeBomb";
					breakOut "xxxx3";
				};

//					_pipeBombCount = {_x == "PIPEBOMB"} count magazines _unit;
#else
				_shell_unit = _x;
				{
					if (_x == "PipeBomb") then {
						_one_shell = _x;
						breakOut "xxxx3";
					};
				} forEach _mags;
#endif					
				sleep 0.011;
			} forEach _units;
			if ( isNull _shell_unit ) exitWith { _continue = false };
//				_units = _units - [_shell_unit];
			if (_one_shell != "") then // bomb found
			{
				_obj_pos = position _obj;
#ifdef __SYG_PIPEBOMB__		
				sleep  1.0;
				//localize "STR_XCP_12" call XfGlobalChat; // "Sabotage: starting procedure"

				//+++++++++++++++++++++++++++++++++++++++++++++++
				//+++ Sygsky: start pipebomb dropping procedure +
				//+++++++++++++++++++++++++++++++++++++++++++++++
				_retreat_pos = position _shell_unit;
				if ( (_leader != _shell_unit) && ( ! ( isNull _leader ) ) ) then
				{
					_shell_unit action ["salute", _leader]; // salute to commander for order
					sleep 1; // salute 1 second
				};
				// remove unit from group first
				[_shell_unit] join grpNull;

				// unit to bomb, position to bomb, return position (now current)
				//localize "STR_XCP_01" call XfGlobalChat;
				//_bombScript = [_shell_unit, [ _obj_pos ], _retreat_pos, true, "ACE_PipeBomb" ] spawn FuncUnitDropPipeBomb; 
				
				// no debug,no name,no bomb centering
				_bombScript = [_shell_unit, [ _obj_pos ], _retreat_pos, false, "ACE_PipeBomb", "", false ] spawn FuncUnitDropPipeBomb;
				// debug
				

				waitUntil ( scriptDone _bombScript );
				if ( (alive _shell_unit) && (!(isNull _grp)) ) then
				{
					[_shell_unit] join _grp;
				};
#else
				_shell_unit selectWeapon "PipeBombMuzzle";
				if (_leader == _shell_unit) then {
					_shell_unit doMove _obj_pos;
					_shell_unit doTarget _obj;
					_shell_unit doFire _obj;
				} else {
					_shell_unit commandMove _obj_pos;
					_shell_unit commandTarget _obj;
					_shell_unit commandFire _obj;
				};
#endif
			}
			else
			{
				_continue = false; // exit as no more bombs found
			};
			if (!alive _obj) exitWith {};
		};
	};
	_no = nil;
	if ( (isNull _grp) || (!_continue) ) exitWith {};
#ifdef 	__SYG_PIPEBOMB__
	sleep 240 + (random 80); // try to bomb each 4-5 minutes
#else
	sleep 600 + (random 120); // try to bomb each 10-12 minutes
#endif	
};

if (true) exitWith {};
