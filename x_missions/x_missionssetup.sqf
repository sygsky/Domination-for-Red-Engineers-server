// by Xeno, x_missions\x_missionssetup.sqf

// lower include already used in parent init.sqf
//#include "x_setup.sqf"
//#include "x_macros.sqf"

// I'm using x_mXXX.sqf for the mission filename where XXX has to be added to sm_array
d_mission_filename = "x_m";

// sm_array contains the indices of the sidemissions (it gets shuffled later)
// to remove a specific side mission just remove the index from sm_array

#ifdef __DEFAULT__
sm_array = [57,56,44,53,54,55,40,20,30,21,22,25,42,26,52,51,50,49,48,47,46,45,43,3,41,39,38,37,36,35,34,33,32,31,29,28,27,24,23,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,2,1,0];
// Lower veriable it not used any more, it is replaced by better structure (see init.sqf)
// ranked_sm_array = [ 5, [2,3,53] ]; //+++ Sygsky: [_lowest_allowed_index, [plane, tank, plain]] - steal missions to run with already ranked players
nonstatic_sm_array = [20,21,22,51,52,54,56,57]; // indexes for not static mission objectives, where no troops can be found (сonvoy, pilots, radiomast, sea devil etc)
#endif

#ifdef __EASY_SM_GO_FIRST__
// list of easy missions (near base) suitable to run them at the mission start while player is of low rank
easy_sm_array = [5,10,12,18,21,24,34,46,47,51]; // 19,52,54 also are suitable
hint localize format["+++ easy_sm_array = %1", easy_sm_array];
#else
easy_sm_array = []; // no easy side missions near base
#endif

#ifdef __TT__
sm_array = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55];
#endif
#ifdef __SCHMALFELDEN__
sm_array = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17];
#endif
#ifdef __UHAO__
sm_array = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17];
#endif

number_side_missions = count sm_array;
current_mission_index = -1;

// just for debugging
// it will create markers at each sidemission position
#ifdef __SMMISSIONS_MARKER__
{
	call compile format ["
		[1,1] call compile preprocessFileLineNumbers ""x_missions\m\%2%1.sqf"";
	", _x,d_mission_filename];

	_start_pos = x_sm_pos select 0;
	_name = format ["Sidemission: %1", _x];
	_marker= createMarkerLocal [_name, _start_pos];
	_marker setMarkerTypeLocal "DOT";
	_name setMarkerColorLocal "ColorBlack";
	_name setMarkerSizeLocal [0.2,0.2];
	_name setMarkerTextLocal _name;
} forEach sm_array;
#endif

if (isServer) then {

	//======================================= if set to false 
	//======================================= sidemissions won't get shuffled so you are able to set up a specific order of sidemissions
	d_random_sm_array = true; // for real game set it true, of course
//    d_random_sm_array = false; // for debugging purposes only set it false

#ifndef __TT__
	// Passed array: [unit, killer]
	XKilledSMTargetNormal = {
		_this call XKilledSMTargetNormalNoDeadAdd;
		(_this select 0) call XAddDead0;
	};

	// Passed array: [unit, killer]
	XKilledSMTargetNormalNoDeadAdd = {
		side_mission_winner=2;
		side_mission_resolved = true;
		hint localize format["+++ SideMission id %1 (#%2) (object: %3) completed by %4 (%5)", current_mission_index, current_mission_counter, typeOf (_this select 0), name (_this select 1), typeOf (vehicle (_this select 0))];
	};
#endif
#ifdef __TT__
	// Passed array: [unit, killer]
	XKilledSMTargetTT = {
		_this call XKilledSMTargetTTNoDeadAdd;
		(_this select 0) call XAddDead0;
	};

	// Passed array: [unit, killer]
	XKilledSMTargetTTNoDeadAdd = {
		side_mission_winner = (switch (side (_this select 1)) do {case resistance:{1}; case west:{2}; default{-1};});
		side_mission_resolved = true;
	};
#endif

	// Passed array: [unit, killer]
	XKilledSMTarget500 = {
		-500 call XKilledSMTargetCodeNoDeadAdd;
		(_this select 0) call XAddDead0;
		hint localize format["+++ SideMission id %1 (#%2) (object: %3, aborted by %4 (%5)", current_mission_index, current_mission_counter, typeOf (_this select 0), name (_this select 1), typeOf (vehicle (_this select 0))];
	};

	// _this: negative code to complete this sm -1,-1 etc
	XKilledSMTargetCodeNoDeadAdd = {
		side_mission_winner = _this;
		side_mission_resolved = true;
		hint localize format["+++ SideMission #%1 aborted with code %2 (-3: no building, -500: officer killed)", current_mission_counter, _this ];
	};

	// Data are real for Sahrani only:
	// 1st line: convoy start position and direction
	// 2nd line: convoy waypoint array 1
	// 3rd line: convoy waypoint array2 (1 or 2 gets randomly selected)
	d_sm_convoy = [
		[ // Ixel - Tandag
			[17452.8,13577.6,0],0,
			[[16963.1,14105.9,0], [15399.6,13744,0], [15135.7,14049.8,0], [13983.5,13168.2,0], [13824.8,13116,0] , [12563.6,13406.7,0], [12395.6,14494,0], [11851.9,14376.5,0]],
			//[[16962.4,14106.6,0],[15371.1,12698.4,0],[14602.8,11861.4,0],[14103.6,12405.2,0],[13082.1,11276.8,0],[10100,14120.9,0],[11851.9,14376.5,0]]
			[[16962.4,14106.6,0],[15371.1,12698.4,0],[14602.8,11861.4,0],[14103.6,12405.2,0],[13082.1,11276.8,0],[9990.1,14181.35,0],[10100,14120.9,0],[11851.9,14376.5,0]]
		],
        [ // Corazol - Estrella
            [12723,8729.78,0],20.4149,
            [[12737.5,8787.06,0], [10947.4,10623.1,0], [9614.35,11036.2,0], [8671.46,10084.4,0], [7618.55,9048.34,0], [7766.26,8822.9,0], [6946.93,8226.66,0]],
//          [[12737.5,8787.4,0],  [10947.2,10623.3,0], [10517.3,9640.52,0],[10147.1,9317.35,0],[8952.3,8345.36,0],[8038.49,8893.38,0],[6946.93,8226.66,0]],
            [[12521,8496.28,0],[12731.1,8053.28,0],[12448,7586.38,0],[11914.4,6354.13,0],[11608.4,6208.08,0],[11571.6,6125.94,0],[11181.9,6139.99,0],[9214.04,6258.08,0],
             [8898.95,6468.03,0],[9143.61,6569.26,0],[8802.89,6909.65,0],[8716.59,6923.71,0],[8654.03,6976.59,0],[8505.68,7345.69,0],[8479.92,7708.00,0],[8460.26,7934.54,0],
             [8715.52,8170.13,0],[8721.81,8297.77,0],[7888.45,8403.49,0],[8038.66,8889.25,0],[7363.16,8695.12,0],[6946.93,8226.66,0]]
/*
            [[12737.5,8787.06,0],[12521,8496.28,0],[12731.1,8053.28,0],[12448,7586.38,0],[11914.4,6354.13,0],[11608.4,6208.08,0],[11571.6,6125.94,0],[11181.9,6139.99,0],[9214.04,6258.08,0],
             [8898.95,6468.03,0],[9143.61,6569.26,0],[8710.74,6979.2,0],[8947.02,7065.79,0],[8833.02,7134.48,0],[8974.96,7231.35,0],[8847.41,7253.35,0],[8847.41,7253.35,0],
             [8785.15,7670.74,0],[8656.25,8094.64,0],[8741.77,7920.59,0],[8721.73,8311.65,0],[7888.45,8403.49,0],[8038.66,8889.25,0],[7363.16,8695.12,0],[6946.93,8226.66,0]]
*/
        ],
		[ // Hunapu -  Modesta
			[8048.9,15783.5,0],101.542,
			[[10100.4,14120.8,0],[10951.5,12658.1,0],[13082,11276,0],[13979.9,9841.15,0],[13816.5,9469.06,0],[14293.2,9450.24,0]],
			[[10100.4,14120.8,0],[12394.8,14494.2,0],[12562.7,13406.4,0],[14124.8,12507.3,0],[13082,11276,0],[13979.9,9841.15,0],[13816.5,9469.06,0],[14293.2,9450.24,0]]
		]
	];

	// these vehicles get spawned in a convoy sidemission
	#ifndef __ACE__
	d_sm_convoy_vehicles = (
		switch (d_enemy_side) do {
			case "EAST": {["T72","T72", "ZSU", "UralRepair", "UralRefuel", "UralReammo", "T72"]};
			case "WEST": {
				if (__CSLAVer) then {
					["CSLA_USHMMWV_M2","CSLA_USM1A1", "CSLA_USM1A1", "CSLA_USTruck5tRepair", "CSLA_USTruck5tRefuel", "CSLA_USTruck5tReammo", "CSLA_USM1A1"]
				} else {
					["Stryker_ICV_M2","M1Abrams", "Stryker_ICV_MK19", "Truck5tRepair", "Truck5tRefuel", "Truck5tReammo", "M1Abrams"]
				}
			};
		}
	);
	#endif
	#ifdef __ACE__
	 d_sm_convoy_vehicles = (
		switch (d_enemy_side) do {
			case "EAST": {["ACE_T90","ACE_ZSU", "ACE_ZSU", "UralRepair", "UralRefuel", "UralReammo", "ACE_T90"]};
//			case "WEST": {["ACE_Stryker_MGS","ACE_M2A2","ACE_PIVADS","ACE_M6A1","ACE_Stryker_MGS","ACE_Truck5t_Repair","ACE_Truck5t_Refuel","ACE_Truck5t_Reammo","ACE_PIVADS","ACE_M1A2_SEP_TUSK"]};
			case "WEST": 
			{
			[["ACE_Truck5t_MG","ACE_Truck5t_MG","ACE_Truck5t","ACE_Truck5t_Open","ACE_Truck5t_Reammo","ACE_Truck5t_Repair"],"ACE_M1A2_SEP_TUSK","ACE_M2A2","ACE_M6A1","ACE_M6A1","TRUCK","TRUCK","ACE_M1A2_SEP_TUSK"]
			};
		}
	);
	#endif
};