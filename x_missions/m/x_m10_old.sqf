// by Xeno, x_m10.sqf
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1; _poss_2 = x_sm_pos select 2

x_sm_pos = [[11448.13,8604.000,0], [11354.3,8554.22,0],[11537.86,8665.58,0]]; // index: 10,   Artillery at top of mount San Esteban
x_sm_type = "normal"; // "convoy"

#ifdef __FUTURE__ // TODO: complete modification of code
//
// create canons on predefined positions. Array format: [_canon_pos[x,y,z], _canon_azi, _canon_vecUp[dx,dy,dz] ]
//
_grp = call SYG_createEnemyGroup;
{
	// create canon
	_veh = _xarti createVehicle (_x select 0);
	// put crew
	_unit = _grp createUnit [_crewman, _x select 0, [], 0, "NONE"];
	[_unit] join _grp;
	_unit setSkill 1;
	_unit assignAsGunner _vehicle;
	_unit moveInGunner _vehicle;
	extra_mission_remover_array set[ count extra_mission_remover_array, _unit ];
	extra_mission_vehicle_remover_array set[ count extra_mission_vehicle_remover_array, _veh ];
	_veh lock true;
} forEach [
	[ [11320.98,8652.43,0], 270, [-0.15,0,0.85] ],
	[ [11368.95,8530.02,0], 240, [-0.15,-0.15,0.85] ],
	[ [11421.08,8579.17,0], 295, [-0.15,0.15,0.8] ],
	[ [11459.09,8590.43,0],  90, [0.2,-0.15,0.8] ],
	[ [11452.17,8854.58,0], 295, [-0.05,0.05,0.95] ]
];
//
// Create spotters
//
{
// TODO: create spotters
} forEach [ // items format:[_spotter_pos[x,y,x],_spotter_azimuth]
	[ [11030.88,9853.52,0], 280 ],
	[ [11039.85,9934.06,0], 280 ],
	[ [11325.23,9082.02,0], 295 ],
	[ [11581.58,8750.09,0], 280 ],
	[ [11735.08,8521.75,0], 100 ],
	[ [11361.55,8442.84,0], 280 ],
	[ [11225.28,8247.95,0], 0 ]
];
#endif

_grp setBehaviour "SAVE"; _grp setCombatMode "WHITE";

// add spotters

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_10"; //"На вершине горы San Esteban расположилась вражеская артиллерия. Задача: уничтожить всю технику.";
	current_mission_resolved_text = localize "STR_SM_010"; //"Задание выполнено! Артиллерия уничтожена.";
};

if (isServer) then {
	_xarti = (if (d_enemy_side == "EAST") then {"D30"} else {"M119"});
	_crewman = (if (d_enemy_side == "EAST") then {d_crewman2_E} else {d_crewman2_W});
	_spotter  = (if (d_enemy_side == "EAST") then {d_crewman2_E} else {d_crewman2_W});

	__PossAndOther;

	_vehicle = objNull;
	_vehicle = _xarti createVehicle (_poss);
	#ifndef __TT__
	_vehicle addEventHandler ["killed", {_this call XKilledSMTargetNormal}]; // event to signal on mission finish
	#endif
	#ifdef __TT__
	_vehicle addEventHandler ["killed", {_this call XKilledSMTargetTT}];
	#endif

    // populate arti gun with a gunner
    _grp = call SYG_createEnemyGroup;
	_unit = _grp createUnit [_crewman, _poss, [], 0, "NONE"];[_unit] join _grp;_unit setSkill 1;_unit assignAsGunner _vehicle;_unit moveInGunner _vehicle;
	extra_mission_remover_array set[ count extra_mission_remover_array, _unit ];
	_vehicle lock true;
	_grp call XCombatPatrol;

	sleep 2.21;
	["specops", 1, "basic", 1, _poss,0] spawn XCreateInf;
	sleep 2.25;
	["specops", 0, "basic", 1, _poss_2,0] spawn XCreateInf; // one more guarding group
	sleep 2.045;
	["shilka", 2, "bmp", 1, "tank", 0, _pos_other,1,0] spawn XCreateArmor;
};

if (true) exitWith {};