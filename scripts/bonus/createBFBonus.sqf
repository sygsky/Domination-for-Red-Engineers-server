/*
	scripts\bonus\createBFBonus.sqf : DEBUG script to call from base flag when debugging "BattleField Bonus"
	Executed on server!
	Creates bonus vehicles (tank, car, heli, plane) on Rahmadi
	author: Sygsky
	description: none
	returns: nothing
*/

//_new_veh = [[_x, _y<,_z>], _rad, _veh_type_name] call SYG_createBonusVeh;
_mt = "Somato" call SYG_MTByName;
if (count _mt  == 0 ) exitWith {hint localize format ["--- BFB: town %1 not found, exit", "Somato"]};
_pos = getPos FLAG_BASE;
_pos set [1, (_pos select 1) + 150];

{
//	hint localize format[ "+++ BFB: vehicle %1 creating at %2", _x,_mt ];
//	_veh = [+(_mt select 0), _mt select 2, _x] call SYG_createBonusVeh;
	_veh = [_pos, 50, _x] call SYG_createBonusVeh;
	if (isNull _veh) then {hint localize format["--- BFB: %1 not created!", _x ]};
	hint localize format["+++ BFB: %1 created at %2!", _x, [_veh, "%1 m to %2 from %3", 10] call SYG_MsgOnPosE ];
//	player groupChat format["+++ BFB: %1 created at %2!", _x, [_veh, "%1 m to %2 from %3", 10] call SYG_MsgOnPosE ];
	sleep 0.5;
} forEach ["ACE_UAZ_MG","ACE_UAZ_AGS30","ACE_UAZ","ACE_Su27S2"];
