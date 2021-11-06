// init include server

SYG_AV8B_TYPES = [ "ACE_A10_AGM_FFAR","ACE_A10_MK82HD","ACE_AV8B_AG_AGM65","ACE_AV8B_AGM65" ];

if (isServer) then {
if (!X_InstalledECS) then {
	// next variables turns on/off some internal AI features
	// maybe you are using a mod like ECS which already has an enhanced AI system
	// turn on/off Rommels suppression script (true = on), now off as default
	d_suppression = false; //--- Sygsky
	// turn on/off smoke, means enemy will throw smoke grenades if true
	d_smoke =
//	#ifndef __ACE__
		true;
//	#else
//		false; // off for ACE
//	#endif
} else {
	d_suppression = false;
	d_smoke = false;
};

// to add bonus vehicles just add a new position and direction to sm_bonus_positions and a new vehicle to sm_bonus_vehicle_array
// the number of the elements in the sm_bonus_positions and sm_bonus_vehicle_array must be equal (you don't have to change a script)
sm_bonus_positions =
#ifdef __SCHMALFELDEN__
	[
		[[2437.76,54.3149,0], 62], 	// Stryker_ICV_M2/BMP2 Position and direction
		[[2446.47,37.6227,0], 62], 	// Stryker_ICV_MK19/BRDM2 Position and direction
		[[2456.99,20.9305,0], 62], 	// HMMWV50/UAZMG Position and direction
		[[2469.33,2.78717,0], 62], 	// HMMWVMK/UAZ_AGS30 Position and direction
		[[2389.86,75.7245,0], 62], 	// HMMWVTOW/BRDM2_ATGM Position and direction
		[[2398.2,59.7586,0], 62], 	// Stryker_TOW/BMP2 Position and direction
		[[2410.9,37.6233,0], 62] 	// M113/BRDM2 Position and direction
	];
#endif
#ifdef __UHAO__
	[
		[[2068.435,4691.627,0], 90], 	// Stryker_ICV_M2/BMP2 Position and direction
		[[2083.798,4691.597,0], 90], 	// Stryker_ICV_MK19/BRDM2 Position and direction
		[[2067.95,4663.812,0], 90], 	// HMMWV50/UAZMG Position and direction
		[[2084.015,4662.509,0], 90], 	// HMMWVMK/UAZ_AGS30 Position and direction
		[[2094.869,4677.05,0], 90], 	// HMMWVTOW/BRDM2_ATGM Position and direction
		[[2067.95,4678.139,0], 90], 	// Stryker_TOW/BMP2 Position and direction
		[[2083.147,4677.270,0], 90] 	// M113/BRDM2 Position and direction
	];
#endif
#ifdef __DEFAULT__
	[                           // any number of positions
		[[9560,9890,0], 270], 	// position and direction
		[[9550,9890,0], 270], 	// position and direction
		[[9560,9875,0], 270], 	// position and direction
		[[9550,9875,0], 270], 	// position and direction
		[[9560,9860,0], 270], 	// position and direction
		[[9550,9860,0], 270], 	// position and direction
		[[9560,9850,0], 270], 	// position and direction
		[[9550,9850,0], 270], 	// position and direction
		[[9513,9895,0], 90], 	// position and direction
		[[9513,9885,0], 90], 	// position and direction
		[[9513,9875,0], 90], 	// position and direction
		[[9513,9865,0], 90], 	// position and direction
		[[9513,9855,0], 90], 	// position and direction
		[[9513,9845,0], 90] 	// position and direction
	];
#endif
#ifdef __TT__
	[
		[ // West
		[[2501.02,2891.16,0], 90], // A10/Su34B Position and direction
		[[2501.02,2864.68,0], 90], // AH1/KA50 Position and direction
		[[2501.02,2838.2 ,0], 90], // AH6/Mi17 Position and direction
		[[2501.02,2811.72,0], 90], // AV8B/Su34 Position and direction
		[[2501.02,2785.24,0], 90], // AV8B2/Su34 Position and direction
		[[2501.02,2758.76,0], 90], // UH60/Mi17 Position and direction
		[[2501.02,2732.28,0], 90] // Vulcan/ZSU Position and direction
		],
		[ // Racs
		[[18195.6,18263.9,0], 260], // A10/Su34B Position and direction
		[[18204.4,18217.6,0], 260], // AH1/KA50 Position and direction
		[[18217.2,18162.9,0], 260], // AH6/Mi17 Position and direction
		[[18235.5,18113.1,0], 260], // AV8B/Su34 Position and direction
		[[18249.8,18061.8,0], 260], // AV8B2/Su34 Position and direction
		[[18261.6,18000.7,0], 260], // UH60/Mi17 Position and direction
		[[18183.2,18325,0], 260] 	// Vulcan/ZSU Position and direction
		]
	];
#endif

#ifdef __DEBUG__
// only for debugging, creates markers at all sidemission bonus vehicle positions
_i = 0;
{
	_sm = _x;
	_start_pos =_sm select 0;
	_name = format ["sbv: %1", _i];
	_i = _i + 1;
	_marker= createMarkerLocal [_name, _start_pos];
	_marker setMarkerTypeLocal "DOT";
	_name setMarkerColorLocal "ColorBlack";
	_name setMarkerSizeLocal [0.5,0.5];
	_name setMarkerTextLocal _name;
} forEach sm_bonus_positions;
#endif

// main target missions
// to add bonus vehicles just add a new position and direction to mt_bonus_positions and a new vehicle to mt_bonus_vehicle_array
// the number of the elements in the mt_bonus_positions and mt_bonus_vehicle_array must be equal (you don't have to change a script)
mt_bonus_positions =
#ifdef __SCHMALFELDEN__
	[
		[[2682.3,32.4362,0], 332], // AH1/KA50 Position and direction
		[[2718.3,54.5297,0], 332], // AH6/Mi17 Position and direction
		[[2765.35,80.3055,0], 332], // UH60/Mi17 Position and direction
		[[2419.03,91.5836,0], 62], // M1/T72 Position and direction
		[[2427.6,72.4588,0], 62] // Vulcan/ZSU Position and direction
	];
#endif
#ifdef __UHAO__
	[
		[[2130.094,4805.468,0], 180], // A10/Su34B Position and direction
		[[2071.607,4768.613,0], 145], // AH1/KA50 Position and direction
		[[2083.656,4805.639,0], 180], // AH6/Mi17 Position and direction
		[[2108.160,4805.811,0], 180], // AV8B/Su34 Position and direction
		[[2108.160,4805.811,0], 180], // AV8B2/Su34 Position and direction
		[[2071.607,4733.613], 145], // UH60/Mi17 Position and direction
		[[2071.607,4683.613], 145], // M1/T72 Position and direction
		[[2071.607,4623.613], 145] // Vulcan/ZSU Position and direction
	];
#endif
#ifdef __DEFAULT__
	[
		[[9704.06,10055.74,0], 180], // 1
		[[9714.99,10081.87,0], 180], // 2
		[[9736.16,10106.05,0], 180], // 3
		[[9749.34,10056.46,0], 180], // 4
		[[9759.25,10079.64,0], 180], // 5

		[[9794.47,10056.66,0], 180], // 6
		[[9775.94,10105.75,0], 180], // 7
		[[9873.36,10057.40,0], 180], // 8
		[[9801.69,10080.22,0], 180], // 9
		[[9847.80,10106.14,0], 180], // 10

		[[9810.01,10104.71,0], 180], // 11
		[[9841.42,10080.93,0], 180], // 12
		[[9834.28,10056.33,0], 180], // 13
		[[9925.90,10109.15,0], 180], // 14
		[[9910.69,10057.78,0], 180], // 15

		[[9878.95,10083.26,0], 180], // 16
		[[9884.66,10107.43,0], 180], // 17
		[[9945.42,10059.40,0], 180], // 18
		[[9917.82,10086.48,0], 180], // 19
		[[9678.34,10083.70,0], 180], // 20

		[[9669.39,10057.61,0], 180], // 21
		[[9691.76,10108.67,0], 180], // 22
		[[9945.47,10077.50,0], 180], // 23
		[[9957.18,10107.79,0], 180], // 24
		[[9975.18,10062.77,0], 180] // 25

	];
#endif
#ifdef __TT__
	[
		[ // West
			[[2501.02,2656.94,0], 90], // Stryker_ICV_M2/BMP2 Position and direction
			[[2501.02,2633.9,0], 90], // Stryker_ICV_MK19/BRDM2 Position and direction
			[[2501.02,2615.33,0], 90], // HMMWV50/UAZMG Position and direction
			[[2501.02,2597.1,0], 90], // HMMWVMK/UAZ_AGS30 Position and direction
			[[2501.02,2581.97,0], 90], // HMMWVTOW/BRDM2_ATGM Position and direction
			[[2501.02,2559.27,0], 90], // Stryker_TOW/BMP2 Position and direction
			[[2501.02,2732.28,0], 90] // M113/BRDM2 Position and direction
		],
		[ // Racs
			[[18133.1,18541.2,0], 260], // Stryker_ICV_M2/BMP2 Position and direction
			[[18140.1,18512.3,0], 260], // Stryker_ICV_MK19/BRDM2 Position and direction
			[[18147.9,18481.2,0], 260], // HMMWV50/UAZMG Position and direction
			[[18161.3,18431.7,0], 260], // HMMWVMK/UAZ_AGS30 Position and direction
			[[18169.8,18393.6,0], 260], // HMMWVTOW/BRDM2_ATGM Position and direction
			[[18175.5,18366,0], 260], // Stryker_TOW/BMP2 Position and direction
			[[18183.2,18325,0], 260] // M113/BRDM2 Position and direction
		]
	];
#endif

#ifdef __DEBUG__
// only for debugging, creates markers at all main target missions bonus vehicle positions
_i = 0;
{
	_sm = _x;
	_start_pos =_sm select 0;
	_name = format ["mbv: %1", _i];
	_i = _i + 1;
	_marker= createMarkerLocal [_name, _start_pos];
	_marker setMarkerTypeLocal "DOT";
	_name setMarkerColorLocal "ColorBlack";
	_name setMarkerSizeLocal [0.5,0.5];
	_name setMarkerTextLocal _name;
} forEach mt_bonus_positions;
#endif

// _E = East
// _W = West
// _G = Racs/Guer
// this is what gets spawned
d_sleader_E = (
	if (__ACEVer) then {
		"ACE_SquadLeaderE"
	} else {
		if (__CSLAVer) then {
			"CSLA_rSgt"
		} else {
			"SquadLeaderE"
		}
	}
);
d_sleader_W = (
	if (__ACEVer) then {

// ЛИДЕР КОМАНДЫ
//##############################################################################
"ACE_SquadLeaderW_A"

	} else {
		if (__CSLAVer) then {
			"CSLA_USsgt"
		} else {
			"SquadLeaderW"
		}
	}
);
d_sleader_G = "SquadLeaderG";

d_crewman_E = (
	if (__ACEVer) then {
		"ACE_SoldierECrew"
	} else {
		"SoldierECrew"
	}
);
d_crewman2_E = (
	if (__ACEVer) then {
		"ACE_SoldierEB"
	} else {
		"SoldierEB"
	}
);
d_crewman_W = (
	if (__ACEVer) then {

// Tankmaster
//##############################################################################
"ACE_SoldierWCrew_WDL"
	} else {
		if (__CSLAVer) then {
			"CSLA_UScrw"
		} else {
			"SoldierWCrew"
		}
	}
);
d_crewman2_W = (
	if (__ACEVer) then {

// Driver
//##############################################################################
"ACE_SoldierWB_A"

	} else {
		if (__CSLAVer) then {
			"CSLA_USrfl"
		} else {
			"SoldierWB"
		}
	}
);
d_crewman_G = "SoldierGCrew";
d_crewman2_G = "SoldierGB";

d_pilot_E = (
	if (__ACEVer) then {
// TODO: ACE_SoldierEPilot_IRAQ_RG - can be used too
		"ACE_SoldierEPilot"
	} else {
		"SoldierEPilot"
	}
);
d_pilot_W = (
	if (__ACEVer) then {

// Pilot
//##############################################################################
"ACE_SoldierWPilot_WDL"

	} else {
		if (__CSLAVer) then {
			"CSLA_USplt"
		} else {
			"SoldierWPilot"
		}
	}
);
d_pilot_G = "SoldierGPilot";

d_allmen_E = (
	if (__ACEVer) then {
		[
			// different squads, squads get selected randomly but not the units anymore
			["ACE_SquadLeaderE","ACE_SoldierE_SR","ACE_SoldierEB","ACE_SoldierEG","ACE_SoldierERPG","ACE_SoldierERPGAB","ACE_SoldierEAR"],
			["ACE_SquadLeaderE","ACE_SoldierE_SR","ACE_SoldierERPGAB","ACE_SoldierEB","ACE_SoldierERPG","ACE_SoldierEMGAB","ACE_SoldierEMG"],
			["ACE_SquadLeaderE","ACE_SoldierE_SR","ACE_SoldierEG","ACE_SoldierERPGAB","ACE_SoldierERPG","ACE_SoldierEAR","ACE_SoldierEB","ACE_SoldierE_MarksmanSVD"],
			["ACE_SquadLeaderE","ACE_SoldierERPG","ACE_SoldierEMGAB","ACE_SoldierEMGAB","ACE_SoldierEMGAB","ACE_SoldierEMG","ACE_SoldierEMG","ACE_SoldierEMG"],
			["ACE_SquadLeaderE_VDV","ACE_AssistantSquadLeaderE_VDV","ACE_SoldierE_SR_VDV","ACE_SoldierE_FO_VDV","ACE_SoldierEMedic_VDV","ACE_SoldierEG_VDV","ACE_SoldierEAR_VDV"],
			["ACE_SquadLeaderE_VDV","ACE_AssistantSquadLeaderE_VDV","ACE_SoldierEG_VDV","ACE_SoldierERPG_VDV","ACE_SoldierEMGAB_VDV","ACE_SoldierEMG_VDV","ACE_SoldierE_MarksmanSVD_VDV"],
			["ACE_SquadLeaderE_VDV","ACE_SoldierERPG_VDV","ACE_SoldierEMGAB_VDV","ACE_SoldierEMGAB_VDV","ACE_SoldierEMG_VDV","ACE_SoldierEMG_VDV"]
		]
	} else {
		[
			["SquadleaderE","TeamLeaderE","SoldierEG","SoldierEMG","SoldierEAT","TeamLeaderE","SoldierEG","SoldierEMG","SoldierESniper","SoldierEMedic"],
			["SquadleaderE","SoldierEMG","SoldierEB","SoldierEMG","SoldierEB","SoldierEAT","SoldierEB","SoldierEMedic"]
		]
	}
);

d_allmen_W = (
	[
		if (__ACEVer) then {
// Infantry in main target town
//##############################################################################
// any group must have: squad leader, radio-operator, medic, AT оператор, MG operator, sniper, other may be from a random list

    ["ACE_SoldierWMG_A","ACE_SoldierWAR_A","ACE_SoldierWSniper_A","ACE_SoldierWMAT_A","ACE_SoldierWAA","ACE_SoldierWAT2_A",
        "ACE_SoldierWMedic_A","ACE_SoldierWG","ACE_SoldierW_HMG","ACE_SoldierW_HMGAG","ACE_SoldierWMiner","ACE_SoldierW_HMGAB"
        ,"ACE_SoldierWG_A"  // grenade launcher to test grenade fix addon
#ifdef __JAVELIN__
, "ACE_SoldierWHAT_A"
#endif
    ]


		} else {
			if (__CSLAVer) then {
				["CSLA_USsgt","CSLA_USgnd","CSLA_USgnd","CSLA_USat","CSLA_USat","CSLA_USrfl","CSLA_USrfl","CSLA_USsaw","CSLA_USsaw","CSLA_USsniper","CSLA_USmedi"] +
				["CSLA_USsgt","CSLA_USgnd","CSLA_USgnd","CSLA_USgnd","CSLA_USat","CSLA_USat","CSLA_USat","CSLA_USrfl","CSLA_USrfl","CSLA_USrfl","CSLA_USmg","CSLA_USmg","CSLA_USmg","CSLA_USmedi"]
			} else {
				["SquadleaderW","TeamLeaderW","SoldierWG","SoldierWAR","SoldierWAT","TeamLeaderW","SoldierWG","SoldierWAR","SoldierWSniper","SoldierWMedic"] +
				["SquadleaderW","SoldierWMG","SoldierWB","SoldierWB","SoldierWMG","SoldierWB","SoldierWB","SoldierWMedic"]
			}
		}
	]
);

// "basic" groups for forest action (*_WDL[_]*)
d_allmen_forest_W = [];

d_allmen_forest_E = d_allmen_E;

d_allmen_G =
	[
		["SquadLeaderG","TeamLeaderG","SoldierGMG","SoldierGG","SoldierGAT","SoldierGMG","SoldierGB","SoldierGB","SoldierGB","SoldierGMedic"]+
		["SquadleaderG","SoldierGMG","SoldierGAA","SoldierGAT","SoldierGAT","SoldierGB","SoldierGMedic"]
	];

d_specops_E = (
	if (__ACEVer) then {
		["ACE_SquadLeaderE_SNR","ACE_SoldierESpotter_SNR","ACE_SoldierESniper_SNR","ACE_SoldierEB_SNR","ACE_SoldierEMG_SNR","ACE_SoldierEB_SN","ACE_SoldierEMedic_SN","ACE_SoldierEMG_SN","ACE_SoldierEDemo_SN","ACE_SoldierEAT_SN"]
	} else {
		["SoldierESaboteur","SoldierESaboteurPipe","SoldierESaboteurBizon","SoldierESaboteurMarksman"]
	}
);
d_specops_W = (
	if (__ACEVer) then {

// Specops
//##############################################################################
// Group must have: squad leader, radio-operator, medic, AT оператор, MG operator, sniper, other may be from a random list
["ACE_SoldierWSniper2_A","ACE_USMC8541A1A","ACE_SoldierWMAT_USSF_ST_BDUL","ACE_SoldierWAA","ACE_SoldierWB_USSF_ST_BDUL","ACE_SoldierW_Spotter_A","ACE_SoldierWMedic_A","ACE_SoldierWAT2_A"
    ,"ACE_SoldierWG_R" // grenade launcher to test grenade fix addon
#ifdef __JAVELIN__
, "ACE_SoldierWHAT_A"
#endif
]

	} else {
		["SoldierWSaboteur","SoldierWSaboteurPipe","SoldierWSaboteurPipe2","SoldierWSaboteurRecon","SoldierWSaboteurAssault","SoldierWSaboteurMarksman"]
	}
);
d_specops_G = ["SoldierGCommando","SoldierGMarksman","SoldierGGuard"];

d_sabotage_E = (
	if (__ACEVer) then {
		["ACE_SoldierEDemo_SN","ACE_SoldierEDemo_SNR"]
	} else {
		["SoldierESaboteur","SoldierESaboteurPipe"]
	}
);
d_sabotage_W = (
	if (__ACEVer) then {

// Sabotages on base
//##############################################################################
// Group must have: squad leader, radio-operator, medic, AT оператор, MG operator, sniper, other may be from a random list
["ACE_SquadLeaderW_A","ACE_SoldierWDemo_A","ACE_SoldierWMAT_A","ACE_SoldierWAA","ACE_SoldierWAA","ACE_SoldierWDemo_USSF_LRSD","ACE_SoldierWDemo_USSF_ST"]
//["ACE_SquadLeaderW_A","ACE_SoldierWMAT_A","ACE_SoldierWMAT_A","ACE_SoldierWAA","ACE_SoldierWAA","ACE_SoldierWMAT_A", "ACE_SoldierW_TACP_USAF_LRSD"] // no pipebomb equipment

	} else {
		["SoldierWSaboteur","SoldierWSaboteurPipe","SoldierWSaboteurPipe2"]
	}
);
d_sabotage_G = ["SoldierGCommando"];

d_veh_a_E = (
	if (__ACEVer) then {
		[
			["ACE_T72","ACE_T90","ACE_T90_K"],
			["ACE_BMP2",/*"ACE_BMD1",*/"ACE_BMP2_D","ACE_BMP2_K"],
			["BRDM2","ACE_BRDM2_ATGM"],
			["ACE_ZSU","ACE_BRDM2_SA9"],
			["ACE_UAZ_MG"],
			["ACE_UAZ_AGS30"],
			["DSHKM","DSHkM_Mini_TriPod"],
			["AGS","Stinger_Pod_East","TOW_TriPod_East"],
			["D30"],
			["ACE_Ural_Refuel"],
			["ACE_Ural_Repair"],
			["ACE_Ural_Reammo"]
		]
	} else {
		[
			["T72"],
			["BMP2"],
			["BRDM2"],
			["ZSU"],
			["UAZMG"],
			["UAZ_AGS30"],
			["DSHKM","DSHkM_Mini_TriPod"],
			["AGS","Stinger_Pod_East","TOW_TriPod_East"],
			["D30"],
			["UralRefuel"],
			["UralRepair"],
			["UralReammo"]
		]
	}
);

_bmp_list =
#ifdef __USE_M60__
			["ACE_M60", "ACE_M60_A3"] +
#else
			["ACE_Stryker_TOW"] +
#endif
			["ACE_Stryker_M2","ACE_Stryker_MK19","ACE_Stryker_MGS","ACE_Stryker_MGS_SLAT"]; // bmp

// TODO: Use in x_deleteempty.sqf to search for the empty western vehicles
d_veh_types_W = [
#ifdef __ACE__
		// ACE only vehicles
		"ACE_M60","ACE_TOW","ACE_M2A1",
#else
		// Arma Gold only vehicles
		"MK19","M2",
#endif
		// Arma Gold common vehicles
		"M1Abrams","M113","StrykerBase","HMMWV50","Truck5tMG","M119",
		// DBE1 (Warfare)  common vehicles
		"TOW_Tripod","M2HD_mini_TriPod","MK19_TriPod","Stinger_Pod",
		"WarfareBWestMGNest_M240"
		];

d_veh_a_W = (
	if (__ACEVer) then {
		[
// Vehicles in main towns
//##############################################################################
			ABRAMS_LIST,    // tank
			//["ACE_M1Abrams","ACE_M1A1_HA","ACE_M1A2","ACE_M1A2_SEP","ACE_M1A2_SEP_TUSK","ACE_M1A2_TUSK"], // tank
            _bmp_list, // bmp
			["ACE_M113_A3","ACE_M2A3"], // brdm
			["ACE_PIVADS","ACE_Vulcan","ACE_M6A1","ACE_M6A1"], // shilka
			["ACE_HMMWV_GAU19","ACE_HMMWV_50","ACE_Truck5t_MG","ACE_HMMWV_GMV", "ACE_HMMWV_GMV2"], // uaz_mg
			["ACE_HMMWV_GL","ACE_HMMWV_TOW"], // uaz_grenade
			["M2StaticMG","M2HD_mini_TriPod"], // DSHKM
			["MK19_TriPod","Stinger_Pod","TOW_Tripod"], // AGS
			["M119"], // D30
			["ACE_Truck5t_Refuel"], //uralfuel
			["ACE_Truck5t_Repair"], // uralrep
			["ACE_Truck5t_Reammo"] // uralammo
		]
	} else {
		if (__CSLAVer) then {
			[
				["CSLA_USM1A1"],
				["Stryker_ICV_M2"],
				["CSLA_USM113"],
				["CSLA_USM163"],
				["CSLA_USHMMWV_M2"],
				["CSLA_USHMMWV_Mk19"],
				["CSLA_USM2h","CSLA_USM2l"],
				["CSLA_USMk19l","Stinger_Pod","TOW_Tripod"],
				["CSLA_USM119"],
				["CSLA_USTruck5tRefuel"],
				["CSLA_USTruck5tRepair"],
				["CSLA_USTruck5tReammo"]
			]
		} else {
			[
				["M1Abrams"],
				["Stryker_ICV_M2"],
				["M113"],
				["Vulcan"],
				["HMMWV50"],
				["HMMWVMK"],
				["M2StaticMG","M2HD_mini_TriPod"],
				["MK19_TriPod","Stinger_Pod","TOW_Tripod"],
				["M119"],
				["Truck5tRefuel"],
				["Truck5tRepair"],
				["Truck5tReammo"]
			]
		}
	}
);

d_veh_a_W_desert = ABRAMS_DESERT_LIST; // tanks in desert towns

d_veh_a_G = [
	["M1Abrams"],
	["M113_RACS"],
	["M113_RACS"],
	["Vulcan_RACS"],
	["LandroverMG"],
	["HMMWVMK"],
	["M2StaticMG","M2HD_mini_TriPod"],
	["MK19_TriPod","Stinger_Pod","ACE_TOW"],
	["M119"],
	["Truck5tRefuel"],
	["Truck5tRepair"],
	["Truck5tReammo"]
];

// first element (array. for example: [2,1]): number of vehicle groups that will get spawned, the first number is the max number that will get spawned,
// the second one the minimum. So [2,0] means, there can be no vehicle groups at all or a maximum of 2 groups of this kind
// second element: maximum number of vehicles in group; randomly chosen
#ifndef __ACE__
d_vehicle_numbers_guard = [
	[[1,1], 1], // tanks
	[[1,1], 1], // apc (bmp)
	[[1,1], 1], // apc2 (brdm)
	[[1,1], 1], // jeep with mg (uaz mg)
	[[1,1], 1] 	// jeep with gl (uaz grenade)
];
#else
d_vehicle_numbers_guard = [
	[[1,1], 1], //2 tanks
	[[1,1], 1], //2 apc (bmp)
	[[1,1], 1], //1 apc2 (brdm)
	[[2,1], 1], //max 2 group with 1 jeep with mg (uaz mg)
	[[2,1], 2]  //max 2 groups with max 2 jeep with gl (uaz grenade)
];
#endif
#ifndef __ACE__
d_vehicle_numbers_guard_static = [
	[[1,1], 1], // tanks
	[[1,1], 1], // apc (bmp)
	[[1,1], 1] 	// aa (shilka)
];
#else
d_vehicle_numbers_guard_static = [
	[[1,1], 1], //1 tanks
	[[2,1], 1], //1 apc (bmp)
	[[2,1], 2]  //2 group of 2 aa (shilka)
];
#endif
#ifndef __ACE__
d_vehicle_numbers_patrol = [
	[[1,1], 1], // tanks
	[[1,1], 1], // apc (bmp)
	[[1,1], 1], // apc2 (brdm)
	[[1,1], 1], // jeep with mg (uaz mg)
	[[1,1], 1] 	// jeep with gl (uaz grenade)
];
#else
d_vehicle_numbers_patrol = [
	[[1,1], 1], //1 tanks
	[[1,1], 1], //1 apc (bmp)
	[[1,1], 1], //1 apc2 (brdm)
	[[1,1], 1], //1 jeep with mg (uaz mg)
	[[1,1], 1] 	//1 jeep with gl (uaz grenade)

];
#endif

// allmost the same like above
// first element the max number of ai "foot" groups that will get spawned, second element minimum number (no number for vehicles in group necessary)
d_footunits_guard = [
#ifndef __TT__
		[1,1], // basic groups
		[1,1] // specop groups
#else
//##############################################################################
[1,1], 		// 3,1 basic groups
[1,1] 		// 3,1 specop groups
#endif
];
d_footunits_patrol = [
#ifndef __ACE__
		[2,2], // basic groups
		[1,1] // specop groups
#else
//##############################################################################
[2,2], 		// 6,3 basic groups
[2,1] 		// 6,3 specop groups
#endif
];
d_footunits_guard_static = [
#ifndef __ACE__
		[1,0], // basic groups
		[1,1] // specop groups
#else
//##############################################################################
[0,0], 		// 1,1 basic groups
[0,0] 		// 0,0 specop groups
#endif
];

d_arti_observer_E = (
	if (__ACEVer) then {
		"ACE_SoldierE_FO"
	} else {
		"TeamLeaderE"
	}
);
d_arti_observer_W = (
	if (__ACEVer) then {

// КОРРЕКТИРОВЩИК
//##############################################################################
"ACE_SoldierW_FO_A"
	} else {
		if (__CSLAVer) then {
			"TeamLeaderW"
		} else {
			"TeamLeaderW"
		}
	}
);
d_arti_observer_G = "TeamLeaderG";

// position, where the attack or ai choppers and planes get spawned (flying)
d_airki_start_positions = [
	[1155.8,13968.2,0],
	[24739.8,9568.23,0]
];

// type of enemy plane that will fly over the main target
#ifndef __ACE__
d_airki_attack_plane = (
	if (d_enemy_side == "EAST") then {
		["Su34B"]
	} else {
		["A10"]
	}
);
#endif

#ifdef __CSLA__
d_airki_attack_plane = (
	if (d_enemy_side == "EAST") then {
		["Su34B"]
	} else {
		["CSLA_USA10"]
	}
);
#endif

#ifdef __ACE__
d_airki_attack_plane = (
	if (d_enemy_side == "EAST") then {
		["ACE_SU34B","ACE_Su27S2","ACE_Su27S","ACE_Su30Mk_Kh29T","ACE_Su30Mk_KAB500KR"]
	} else {

// САМОЛЕТЫ НАД ГОРОДОМ
//##############################################################################
//--- Sygsky: remove useless planes  ["ACE_A10_AGM_FFAR","ACE_A10_MK82","ACE_AV8B_AGM65","ACE_A10_MK82HD","ACE_AV8B_AG_AGM65","ACE_AV8B_AA","ACE_AV8B_GBU12","ACE_AV8B_AA_GBU12","ACE_AV8B_MK82","ACE_AV8B_AA_MK82","ACE_AV8B_AG_MK82_MK83","ACE_AV8B_MK83"]
SYG_AV8B_TYPES
	}
);
#endif
d_number_attack_planes = 1;

// type of enemy chopper that will fly over the main target
#ifndef __ACE__
d_airki_attack_chopper = (
	if (d_enemy_side == "EAST") then {
		["KA50"]
	} else {
		["AH1W"]
	}
);
#endif

#ifdef __CSLA__
d_airki_attack_chopper = (
	if (d_enemy_side == "EAST") then {
		["KA50"]
	} else {
		["CSLA_USAH1"]
	}
);
#endif

#ifdef __ACE__
d_airki_attack_chopper = (
	if (d_enemy_side == "EAST") then {
		["ACE_Ka50","ACE_Ka50_N","ACE_KA52","ACE_Mi24D","ACE_Mi24P","ACE_Mi24V"]
	} else {

// ВЕРТОЛЕТЫ НАД ГОРОДОМ
//##############################################################################
//    ["ACE_AH1Z_HE","ACE_AH1Z_HE_F","ACE_AH1Z_HE_S_I","ACE_AH1W_AGM_HE","ACE_AH1Z_AGM_HE_F_S_I","ACE_AH1Z_AGM_HE_F",
//     "ACE_AH1W_TOW_HE_F_S_I","ACE_AH1W_TOW2","ACE_AH1W_TOW_TOW_HE","ACE_AH64_HE_F",/*"ACE_AH64_AGM_AIM",*/"ACE_AH64_AGM_HE",
//     "ACE_AH64_AGM_HE_F","ACE_AH64_AGM_HE_F_S_I"/*,"ACE_AH64_AGM_AIM","ACE_AH64_AGM_AIM","ACE_AH64_AGM_AIM"*/];
SYG_HELI_BIG_LIST_ACE_W

	}
);
#endif
d_number_attack_choppers = 1;

// enemy parachute troops transport chopper
#ifndef __ACE__
d_transport_chopper = (
	if (d_enemy_side == "EAST") then {
		["Mi17"]
	} else {
		["UH60"]
	}
);
#endif

#ifdef __CSLA__
d_transport_chopper = (
	if (d_enemy_side == "EAST") then {
		["Mi17"]
	} else {
		["CSLA_USUH60"]
	}
);
#endif

#ifdef __ACE__
d_transport_chopper = (
	if (d_enemy_side == "EAST") then {
		["ACE_Mi17"]
	} else {
		["ACE_CH47D","ACE_CH47D_CARGO","ACE_UH60MG_M134","ACE_UH60MG_M2","ACE_MH6"]
	}
);
#endif

// light attack chopper (for example Mi17 with MG)
#ifndef __ACE__
d_light_attack_chopper = (
	if (d_enemy_side == "EAST") then {
		["Mi17_MG"]
	} else {
		["UH60MG"]
	}
);
#endif

#ifdef __CSLA__
d_light_attack_chopper = (
	if (d_enemy_side == "EAST") then {
		["Mi17_MG"]
	} else {
		["CSLA_USUH60MG"]
	}
);
#endif

#ifdef __ACE__
d_light_attack_chopper = (
	if (d_enemy_side == "EAST") then {
		["ACE_Mi17_MG"]
	} else {

// МАЛЕНЬКИЙ ВЕРТОЛЕТ НАД ГОРОДОМ
//##############################################################################
//["ACE_AH6_GAU19","ACE_AH6_TwinM134","ACE_UH60MG_M134","ACE_UH60MG_M240C","ACE_AH6_AGM"]
SYG_HELI_LITTLE_LIST_ACE_W
	}
);
#endif

/* 
#ifdef __SYG_AIRKI_DEBUG__
d_light_attack_chopper = ["ACE_UH60MG_M134","ACE_UH60MG_M240С"];
#endif
*/

// start positions of the choppers that will parachute new paratroopers over the main target (randomly chosen)
d_para_start_positions =
#ifdef __SCHMALFELDEN__
	[
		[-1730.63,4471.39,0],
		[-1727.08,3903.76,0],
		[-1769.66,3094.89,0]
	];
#endif

#ifdef __UHAO__
	[
		[236.8,7889.7,0],
		[812.8,7521.73,0],
		[7172.8,865.727,0]
	];
#endif

#ifdef __DEFAULT__
	[
		[236.8,13889.7,0],
		[812.8,9521.73,0],
		[8172.8,865.727,0]
	];
#endif

#ifdef __TT__
	[
		[236.8,13889.7,0],
		[812.8,9521.73,0],
		[8172.8,865.727,0]
	];
#endif

// end or delete positions of the choppers that will parachute new paratroopers over the main target (randomly chosen)
d_para_end_positions =
#ifdef __SCHMALFELDEN__
	[
		[6938.04,4634.89,0],
		[6910.04,4050.89,0],
		[6878.04,3442.89,0]
	];
#endif
#ifdef __UHAO__
	[
		[7500.8,6497.73,0],
		[7956.8,7329.7,0],
		[7476.8,7081.7,0]
	];
#endif
#ifdef __DEFAULT__
	[
		[19500.8,6497.73,0],
		[18956.8,17329.7,0],
		[10476.8,20081.7,0]
	];
#endif
#ifdef __TT__
	[
		[19500.8,6497.73,0],
		[18956.8,17329.7,0],
		[10476.8,20081.7,0]
	];
#endif

// positions of the tanks in the sidemissions, where you have to destroy tanks
d_sm_tanks_dir_array = [
	[115,115,115,115,292,292],
	[179, 179, 179, 0, 0, 273]
];

// enemy ai skill: [base skill, random value (random 0.2) that gets added to the base skill]
d_skill_array = [0.7,0.3];

// Type of aircraft, that will air drop stuff
x_drop_aircraft =
	#ifdef __OWN_SIDE_RACS__
	"UH60";
	#endif
	#ifdef __OWN_SIDE_WEST__
	if (__ACEVer) then {"ACE_CH47D_CARGO"} else {"UH60"};
	#endif
	#ifdef __OWN_SIDE_EAST__
	if (__CSLAVer) then {
		"CSLA_Mi8T"
	} else {
		if (__ACEVer) then {
			"ACE_Mi17"
		} else {
			"Mi17"
		}
	};
	#endif
	#ifdef __TT__
	"UH60";
	#endif

// max men for main target clear
d_man_count_for_target_clear = 5;
// max tanks for main target clear
d_tank_count_for_target_clear = 0;
// max cars for main target clear
d_car_count_for_target_clear = 1;
// max static for main target clear
d_static_count_for_target_clear = 1;

// add some random patrols on the island
// if the array is empty, no patrols
// same size like a rectangular trigger
// first element = center position, second element = a, third element = b, fourth element = angle, fifth element = number of groups
d_with_isledefense =
#ifdef __SCHMALFELDEN__
	[[2535.49,3112,0], 2000, 2000, 0, 3];
#endif
#ifdef __UHAO__
	[[12422.8,11518.5,0], 6850, 6850, 0, 4];
#endif
#ifdef __DEFAULT__
	[[12422.8,11518.5,0], 6850, 6850, 0, 5];
d_preferred_isledefence_spawn_points = []; // Future feature to spawn at predefined areas, not random point as is now
#endif
#ifdef __TT__
	[[12422.8,11518.5,0], 6850, 6850, 0, 4];
#endif

// if set to false, empty vehicles will not get deleted after the main target gets cleared. true = empty vehicles will get deleted after 25-30 minutes
d_do_delete_empty_main_target_vecs = true;

// if set to true no enemy AI will attack base and destroy bonus vehicles or whatever
d_no_sabotage = false;

// time (in sec) between attack planes and choppers over main target will respawn once they were shot down (a random value between 0 and 240 will be added)
#ifndef __ACE__
d_airki_respawntime = 1200;
#endif
#ifdef __ACE__
d_airki_respawntime = 2400;
#endif
#ifdef __SYG_AIRKI_DEBUG__
d_airki_respawntime = 300;
#endif

/*
#ifdef __SYG_AIRKI_DEBUG__
d_airki_respawntime = 120;
#endif
*/

side_missions_random = [];

mr1_lift_chopper = objNull;
mr2_lift_chopper = objNull;
#ifdef __TT__
mrr1_lift_chopper = objNull;
mrr2_lift_chopper = objNull;
#endif

// don't remove d_recapture_indices even if you set d_with_recapture to false
d_recapture_indices = [];

// ВРАГ ЗАХВАТЫВАЕТ ЗАХВАЧЕННЫЕ ГОРОДА
//##############################################################################
// if set to false enemy forces will not recapture towns !!!
d_with_recapture = true;

// position and direction of the AI HUT
d_pos_ai_hut =
#ifdef __DEFAULT__
	[[9695.9,9961.0,-0.3],-90];
#endif
#ifdef __SCHMALFELDEN__
	[[2521.1,97.7894,0],67];
#endif
#ifdef __UHAO__
	[[2226.98,4545.16,0],270];
#endif
#ifdef __TT__
	[];
#endif

// max number of cities that the enemy will recapture at once
// if set to value <= 0 no check is done
d_max_recaptures = 1;

#ifdef __AI__
AI_HUT = "WarfareBBarracks" createVehicle (d_pos_ai_hut select 0);
AI_HUT setDir (d_pos_ai_hut select 1);
AI_HUT setPos (d_pos_ai_hut select 0);
ADD_HIT_EH(AI_HUT)
ADD_DAM_EH(AI_HUT)
publicVariable "AI_HUT";
#endif

#ifndef __TT__
_wairfac = (
	switch (d_own_side) do {
		case "WEST": {"WarfareBWestAircraftFactory"};
		case "EAST": {"WarfareBEastAircraftFactory"};
		case "RACS": {"WarfareBWestAircraftFactory"};
	}
);
for "_i" from 0 to (count d_aircraft_facs - 1) do {
	_element = d_aircraft_facs select _i;
	_pos = _element select 0;
	_dir = _element select 1;
	_fac = _wairfac createVehicle _pos ;
	_fac setDir _dir;
	_fac addEventHandler ["killed", {_this execVM "x_scripts\x_fackilled.sqf";}];
};
#endif

d_time_until_next_sidemission = [
	[10,300], // if player number <= 10, it'll take 300 seconds = 5 minutes until the next sidemission
	[20,600], // if player number <= 20, it'll take 600 seconds = 10 minutes until the next sidemission
	[30,900]  // if player number <= 30, it'll take 900 seconds = 15 minutes until the next sidemission
];

#ifdef __MANDO__
//set inital mando variables
mando_support_left_re_west = 0;				//Number of AI reinforcement drops available
publicVariable "mando_support_left_re_west";
mando_support_left_ca_west= 1;				//Number of Attack Helis available (2 cobras per group)
publicVariable "mando_support_left_ca_west";
mando_airsupport_type_ca = "AH1W";				//Defines attack helis as cobra gunships
publicvariable "mando_airsupport_type_ca";
mando_support_left_west= 2;					//Number of bombers available
publicVariable "mando_support_left_west";
mando_support_left_pa_west= 0;				//Number of AI paratroop assaults available
publicVariable "mando_support_left_pa_west";
mando_support_left_cm_west= 0;				//Available Cruise Missiles available
publicVariable "mando_support_left_cm_west";
mando_support_left_rc_west= 1;				//Recon flights available
publicVariable "mando_support_left_rc_west";
mando_support_left_am_west= 0;				//Ammo drops available
publicVariable "mando_support_left_am_west";
mando_support_left_ve_west= 1;				//Vehicle drops available
publicVariable "mando_support_left_ve_west";
mando_support_left_cp_west= 1;				//Combat Patrols available
publicVariable "mando_support_left_cp_west";
mando_support_left_sa_west= 0;				//Saturation Missile attacks available
publicVariable "mando_support_left_sa_west";
mando_support_left_la_west= 2;				//Laser Designated bombing runs available
publicVariable "mando_support_left_la_west";
mando_support_left_ev_west= 2;				//Evac Blackhawks Available
publicVariable "mando_support_left_ev_west";

// the enemy vehicles in the d_enemy_aa_vehicle array will have aa missile capabilities
d_enemy_aa_vehicle = ["ZSU"];

[]spawn {
	while {true} do {
		if (mando_support_left_west< 1) then {
			Sleep 360;
			mando_support_left_west= 2;
			publicVariable "mando_support_left_west";
		};
		Sleep 5;
	};
};

[]spawn {
	while {true} do {
		if (mando_support_left_ca_west< 1) then {
			Sleep 360;
			mando_support_left_ca_west= 2;
			publicVariable "mando_support_left_ca_west";
		};
		Sleep 5;
	};
};
[]spawn {
	while {true} do {
		if (mando_support_left_rc_west< 1) then {
			Sleep 360;
			mando_support_left_rc_west= 1;
			publicVariable "mando_support_left_rc_west";
		};
		Sleep 5;
	};
};
[]spawn {
	while {true} do {
		if (mando_support_left_ve_west< 1) then {
			Sleep 360;
			mando_support_left_ve_west= 1;
			publicVariable "mando_support_left_ve_west";
		};
		Sleep 5;
	};
};
[]spawn {
	while {true} do {
		if (mando_support_left_cp_west< 1) then {
			Sleep 720;
			mando_support_left_cp_west= 1;
			publicVariable "mando_support_left_cp_west";
		};
		Sleep 5;
	};
};
[]spawn {
	while {true} do {
		if (mando_support_left_ev_west< 1) then {
			Sleep 360;
			mando_support_left_ev_west= 2;
			publicVariable "mando_support_left_ev_west";
		};
		Sleep 5;
	};
};
[]spawn {
	while {true} do {
		if (mando_support_left_la_west< 1) then {
			Sleep 360;
			mando_support_left_la_west= 2;
			publicVariable "mando_support_left_la_west";
		};
		Sleep 5;
	};
};
[]spawn {
	while {true} do {
		if (mando_support_left_sa_west< 1) then {
			_d_message = "Cruise Missile Saturation Attack Inbound on Target";
			["d_message",_d_message] call XSendNetStartScriptClient;
			_d_message = nil;
			Sleep 1200;
			mando_support_left_sa_west= 1;
			publicVariable "mando_support_left_sa_west";
			_d_message = "Cruise Missile Saturation Attack Available";
			["d_message",_d_message] call XSendNetStartScriptClient;
			_d_message = nil;
		};
		Sleep 5;
	};
};
#endif

// make main base structures imvulnerable
#ifdef __DEFAULT__
WALL1 addEventHandler["killed", {[_this select 0, _this select 1,[9662.3,9999.0], 90] call SYG_invulnerableBuilding}];
WALL2 addEventHandler["killed", {[_this select 0, _this select 1,[9683.5,9998.0], 90] call SYG_invulnerableBuilding}];
WALL3 addEventHandler["killed", {[_this select 0, _this select 1,[9662.3,9989.0], 90] call SYG_invulnerableBuilding}];
WALL4 addEventHandler["killed", {[_this select 0, _this select 1,[9683.5,9988.0], 90] call SYG_invulnerableBuilding}];
depot addEventHandler["killed", {[_this select 0, _this select 1,[9673.95,9992.74], 180] call SYG_invulnerableBuilding}];
#endif
// ГРАЖДАНСКИЕ В ГОРОДЕ
//##############################################################################
// add more civilian cars if you want
d_civ_cars = ["Skoda","SkodaBlue","SkodaRed","SkodaGreen","car_hatchback","car_sedan"];
// creates randomly spawned civilians (buses, cars, pedestrian) in some cities, if a player is near that city (to enable it set it to true)
d_create_civilian = false;
};
