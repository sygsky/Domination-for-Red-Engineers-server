// by Xeno, x_scripts/x_handleobservers.sqf
private ["_enemy_ari_available","_nextaritime","_type","_man_type"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_enemy_ari_available = true;
_nextaritime = 0;

#ifndef __TT__
_man_type = (
	switch (d_enemy_side) do {
		case "WEST": {"SoldierWB"};
		case "EAST": {"SoldierEB"};
		case "RACS": {"SoldierGB"};
	}
);
_tt = false;
#endif
#ifdef __TT__
_man_type = ["SoldierWB","SoldierGB"];
_tt = true;
#endif

if (isNil "x_shootari") then {
	x_shootari = compile preprocessFileLineNumbers "x_scripts\x_shootari.sqf";
};

sleep 10.123;

while {nr_observers > 0} do {
	if (X_MP) then {
	if ((call XPlayersNumber) == 0) then { waitUntil {sleep (5.012 + random 1);(call XPlayersNumber) > 0}; };
	};
	__DEBUG_NET("x_handleobservers.sqf",(call XPlayersNumber))
	for "_i" from 1 to 3 do {
		call compile format ["
			if (!(isNull Observer%1) AND (alive Observer%1)) then {
				if (_enemy_ari_available) then {
					_enemy = Observer%1 findNearestEnemy Observer%1;
					if (!(isNull _enemy) && Observer%1 knowsAbout _enemy >= 1.5 && (vehicle _enemy) isKindOf ""Land"") then {
						_distance = Observer%1 distance _enemy;
						_near_targets = Observer%1 nearTargets (_distance + 10);
						if (count _near_targets > 0) then {
							_pos_nearest = [];
							{
								if ((_x select 4) == _enemy) exitWith {
									_pos_nearest = _x select 0;
								};
								sleep 0.001;
							} forEach _near_targets;
							_near_targets = nil;
							if (count _pos_nearest > 0) then {
								if (!_tt) then
								{
									_near_targets = _pos_nearest nearObjects [_man_type, 35];
								}
								else
								{
									_near_targets = nearestObjects [_pos_nearest, _man_type, 35];
								};	
								_type = if (( {canStand _x} count _near_targets) == 0) then { 1 } else { 2 };
								_nextaritime = time + d_arti_available_time + random 120;
								[_pos_nearest,_type] spawn x_shootari;
								_enemy_ari_available = false;
								_near_targets = nil;
							};
						};
					};
				};
				sleep 3.321;
			};
		",_i];
	};
	sleep 5.123;
	if (!_enemy_ari_available) then 
	{
		if ( time >= _nextaritime ) then { _enemy_ari_available = true; };
	};
};

if (true) exitWith {};
