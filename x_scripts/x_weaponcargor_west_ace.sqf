// by Xeno, x_scripts/x_weaponcargor_east_ace.sqf
// called only for __ACE__ + __RANKED__ defined version

#include "x_setup.sqf"

private ["_ve"];
_ve = _this select 0;

if (isNil "x_ranked_weapons_west") then {

	x_ranked_weapons_west = [
		[
			// private rifles
			[
				["ACE_Dummy_RIFLE",48],["ACE_FAL_Para",5],["ACE_SA58",5],["ACE_HK416",5],
				["ACE_M16A2",5],["ACE_M16A4",5],
				["ACE_M4A1",5],["ACE_MP5A4",5],["ACE_MP5A5",5],
				["ACE_M1014",5]
				#ifdef __VEH_1985__
				,["ACE_HK417C",5],["ACE_SCAR_L_CQB",5],
				["ACE_SCAR_L_CQB_Docter",5],["ACE_SCAR_H_CQB",5],["ACE_SCAR_H_CQB_Docter",5],
				["ACE_SR25K",5],["ACE_M14",5],["ACE_M14_des",5],["ACE_M14_wdl",5],["ACE_M14_reflex",5],
				["ACE_M14_nam",5],["ACE_M14_sop",5],["ACE_M14_sop_cmore",5],
				["ACE_MP5SD",5],["ACE_UMP45",5],["ACE_UMP45_SD",5],["ACE_G36C",5]
				#endif
			],
			// corporal rifles (gets added to private rifles)
			[
				["ACE_HK416_GL",5],["ACE_HK416_SD",5],["ACE_HK416_GL_SD",5],["ACE_HK416_aim",5],["ACE_HK416_aim_SD",5],["ACE_HK416_aim_GL",5],
				["ACE_HK416_aim_GL_SD",5],["ACE_HK416_eotech",5],
				["ACE_M16A2GL",5],["ACE_M16A4GL",5],
				["ACE_HK416_eotech_SD",5],["ACE_HK416_eotech_gl",5],["ACE_HK416_eotech_gl_SD",5],["ACE_M1014_Eotech",5]
			    #ifdef __VEH_1985__
				,["ACE_HK417C_SD",5],["ACE_HK417L",5],["ACE_HK417L_SD",5],["ACE_HK417L_M68",5],
				["ACE_HK417L_M68_SD",5],["ACE_HK417C_Eotech",5],
				["ACE_HK417C_Eotech_SD",5],["ACE_HK417L_Eotech",5],["ACE_HK417L_Eotech_203",5],["ACE_HK417L_Eotech_SD",5],
				["ACE_M16A4Aimpoint",5],["ACE_M4A1AimPointSD",5],["ACE_M4A1GLAimpoint",5],
				["ACE_SCAR_L_CQB_EOtech",5],["ACE_SCAR_L_CQB_EOtech_SD",5],["ACE_SCAR_L_CQB_Eotech_EGLM",5],["ACE_SCAR_L_CQB_AIM",5],
				["ACE_SCAR_L_CQB_AIM_SD",5],["ACE_SCAR_H_CQB_EOtech",5],["ACE_SCAR_H_CQB_EOtech_SD",5],["ACE_SCAR_H_CQB_AIM",5],["ACE_SCAR_H_CQB_AIM_SD",5],
				["ACE_SCAR_L",5],["ACE_SCAR_L_Eotech",5],["ACE_SCAR_L_CQB_Docter_SD",5],["ACE_SCAR_H_CQB_Docter_SD",5],
				["ACE_M14_sop_aim",5],["ACE_M14_sopS",5],["ACE_M14_sop_aim_gl",5],["ACE_M14_sop_cmoreS",5],["ACE_M14_sop_gl",5],
				["ACE_M14_sop_eotech",5],["ACE_M14_sop_eotech_gl",5],["ACE_M14_sop_aimS",5],["ACE_M14_sop_eotechS",5],
				["ACE_G36K",5],["ACE_G36KA1",5],["ACE_G36C_CompAim",5],["ACE_G36C_CompEo",5],["ACE_G36",5]
			    #endif
			],
			// sergeant rifles (gets added to corporal and private rifles)
			[
			    #ifdef __VEH_1985__
				["ACE_SCAR_L_Specter",5],["ACE_SCAR_L_Specter_SD",5],["ACE_SCAR_L_Shortdot",5],["ACE_SCAR_L_Shortdot_SD",5],
				["ACE_SCAR_L_CQB_mk4",5],["ACE_SCAR_L_CQB_mk4_SD",5],["ACE_SCAR_H_Shortdot",5],["ACE_SCAR_H_Shortdot_SD",5],
				["ACE_M14_sop_elcan",5],["ACE_M14_sop_elcanS",5],
			    #endif
			    ["ACE_SPAS12",5]
			],
			// lieutenant rifles (gets added to...)
			[
				["ACE_M16A4ACOG",5],["ACE_M16A4GLACOG",5],["ACE_M4A1ACOG",5],["ACE_M4A1GLACOG",5],["ACE_M4A1GL",5]
			    #ifdef __VEH_1985__
				,["ACE_HK416_ACOG",5],["ACE_HK416_ACOG_SD",5],["ACE_HK416_ACOG_gl",5],
				["ACE_HK416_ACOG_gl_SD",5],["ACE_HK417C_ACOG",5],["ACE_HK417C_ACOG_SD",5],["ACE_HK417C_ACOG_gl",5],
				["ACE_HK417C_M68",5],["ACE_HK417C_M68_SD",5]
			    #endif
			],
			// captain rifles (gets added...)
			[
			    #ifdef __VEH_1985__
                ["ACE_HK417L_ACOG",5],["ACE_HK417L_ACOG_SD",5],["ACE_SCAR_L_ACOG",5],
				["ACE_SCAR_L_ACOG_SD",5],["ACE_SCAR_L_ACOG_EGLM",5]
			    #endif
			],
			// major rifles (gets...)
			[
			    #ifdef __VEH_1985__
			    ["ACE_SCAR_H_ACOG",5],["ACE_SCAR_H_ACOG_SD",5]
			    #endif
			],
			// colonel rifles (...)
			[
			    #ifdef __VEH_1985__
			    ["ACE_M14_wdl_acog",5],["ACE_M14_sop_acog",5],["ACE_M14_sop_acog_gl",5],["ACE_M14_sop_acogS",5]
			    #endif
			]
		],
		[
			// private sniper rifles
			[ ],
			// corporal sniper rifles
			[ ["ACE_Dummy_SNIPER",48],["ACE_Mk12SPR",5] ],
			// sergeant sniper rifles
			[ ["ACE_Mk12SPR_SD",5] ],
			// lieutenant sniper rifles
			[ ["ACE_M242",5] ],
			// captain sniper rifles
			[ ["ACE_M21",5],["ACE_M21_des",5],["ACE_M21_wdl",5],["ACE_M21_dmr",5],["ACE_M21_police",5] /*,["ACE_M21_dmrS",5]*/ ],
			// major sniper rifles
			[
                ["ACE_HK416_Leu",5],["ACE_HK416_Leu_SD",5],["ACE_HK417L_Leu",5],["ACE_HK417L_Leu_SD",5],["ACE_SCAR_L_Marksman",5],
                ["ACE_SCAR_L_Marksman_SD",5],["ACE_SCAR_L_Marksman_ACOG",5],["ACE_M40A3",5]
                #ifdef __VEH_1985__
                ,["ACE_SCAR_H_Sniper",5],["ACE_SCAR_H_Sniper_SD",5],
                ["ACE_M14_sop_dmr",5],["ACE_M14_sop_dmrS",5],["ACE_M110_SD",5],
                ["ACE_M82A1",5],["ACE_AS50",5]
                #endif
			],
			// colonel sniper rifles
			[
			    #ifdef __VEH_1985__
				["ACE_HK416_Leu",5],["ACE_HK416_Leu_SD",5],["ACE_HK417L_Leu",5],["ACE_HK417L_Leu_SD",5],["ACE_SCAR_L_Marksman",5],
				["ACE_SCAR_L_Marksman_SD",5],["ACE_SCAR_L_Marksman_ACOG",5],["ACE_SCAR_H_Sniper",5],["ACE_SCAR_H_Sniper_SD",5],
				["ACE_M14_sop_dmr",5],["ACE_M14_sop_dmrS",5],["ACE_M110_SD",5],
				["ACE_M82A1",5],["ACE_AS50",5],
				#endif
				["ACE_M109",5],["ACE_M110",5]
			]
		],
		[
			// private MG
			[ ],
			// corporal MG
			[ ["ACE_Dummy_MG",48],["ACE_M249",5] ],
			// sergeant MG
			[ ["ACE_M240G",5] ],
			// lieutenant MG
			[ ["ACE_M249Para",5],["ACE_MG36",5],["ACE_M2HBProxy",2],["ACE_M3TripodProxy",2] ],
			// captain MG
			[ ["ACE_M249Para_M145",5] ],
			// major MG
			[ ["ACE_M240G_M145",5] ],
			// colonel MG
			[]
		],
		[
			// private launchers
			[ ["ACE_Dummy_LAUNCHER",48],["ACE_M136",5],["ACE_FIM92A",5] ],
			// corporal launchers
			[ ["ACE_M72",5] ],
			// sergeant launchers
			[ ["ACE_M79",5] ],
			// lieutenant launchers
			[ ["ACE_SMAW",5],["ACE_CarlGustav",5],["ACE_MK13",5],["ACE_M32",5] ],
			// captan launchers
			[ ["ACE_Dragon",5] ],
			// major launchers
			[ ],
			// colonel launchers
			[
//				["ACE_Javelin",2] // Not usable as is IMBA
			]
		],
		[
			// private pistols
			[ ["ACE_Dummy_PISTOL",48],["ACE_M9",5],["ACE_FlareGun",5],["ACE_MK13",10] ],
			// corporal pistols
			[ ["ACE_M9SD",5] ],
			// sergeant pistols
			[ ["ACE_M1911",5] ],
			// lieutenant pistols
			[ ["ACE_M1911SD",5] ],
			// capain pistols
			[ ["ACE_Glock17",5] ],
			// major pistols
			[ ["ACE_Glock18",5] ],
			// colonel pistols
			[ ]
		]
	];
};

//
// New format to add weapon/magazine cargo to the main ammobox without many statements, only by array using
//
_ve spawn {
	private ["_ve", "_old_rank", "_index", "_weapons", "_i", "_rk", "_ammo_list", "_x"];
	_ve = _this;
	_old_rank = "";
	
	_ammo_list = [
        ["ACE_Dummy_EQUIP",40],
        ["ACE_Bandage",48],["ACE_Morphine",48],["ACE_Epinephrine",48],["Laserbatteries",10],["ACE_IRStrobe",10],["ACE_SandBag_Magazine",50],

        ["ACE_Dummy_RIFLE",48],
        ["ACE_20Rnd_762x51_B_FAL",48],["ACE_30Rnd_9x19_B_MP5",48],["ACE_30Rnd_9x19_SD_MP5",48],["ACE_25Rnd_1143x23_B_UMP45",48],
        ["ACE_20Rnd_556x45_SB_Stanag",48],["ACE_30Rnd_556x45_B_Stanag",48],["ACE_30Rnd_556x45_SD_Stanag",48],
        ["ACE_30Rnd_556x45_BT_Stanag",48],["ACE_20Rnd_762x51_B_SCAR",48],["ACE_20Rnd_762x51_SB_SCAR",48],["ACE_20Rnd_762x51_B_HK417",48],
        ["ACE_20Rnd_762x51_SB_HK417",48],["ACE_20Rnd_762x51_B_M14",48],["ACE_30Rnd_556x45_BT_G36",48],
        ["ACE_100Rnd_556x45_BT_G36",48],
        ["ACE_8Rnd_12Ga_Buck00",48],["ACE_9Rnd_12Ga_Slug",48],["ACE_9Rnd_12Ga_Buck00",48],

        ["ACE_Dummy_SNIPER",40],
        ["ACE_5Rnd_762x51_SB",48],["ACE_20Rnd_762x51_SB_M14",48],
        ["ACE_20Rnd_762x51_SB_M110",48],["ACE_10Rnd_127x99_SB_Barrett",15],
        ["ACE_10Rnd_127x99_BT_Barrett",15],["ACE_10Rnd_127x99_API_Barrett",15],["ACE_5Rnd_25x59_HEDP_Barrett",15],["ACE_8Rnd_12Ga_Slug",48],

        ["ACE_Dummy_MG",48],
        ["ACE_200Rnd_556x45_BT_M249",48],["ACE_100Rnd_762x51_BT_M240",48],["ACE_50Rnd_762x51_BT_M240",48],
        ["ACE_100Rnd_762x51_B_M60",48],["ACE_M2_CSWDM",48],

        ["ACE_Dummy_PISTOL",48],
        ["ACE_15Rnd_9x19_B_M9",48],["ACE_15Rnd_9x19_SD_M9",48],["ACE_7Rnd_1143x23_B_M1911",48],["ACE_17Rnd_9x19_G17",48],
        ["ACE_33Rnd_9x19_G18",48],

        ["ACE_Dummy_LAUNCHER",48],
        ["ACE_Stinger",48],["ACE_AT4_HEAT",48],["ACE_AT4_HP",48],["ACE_AT4_HEDP",48],["ACE_LAW_HEAT",48],["ACE_LAW_HP",48],
        ["ACE_LAW_HEF",48],["ACE_SMAW_HEDP",48],["ACE_SMAW_HEAA",48],["ACE_SMAW_FTG",48],["ACE_SMAW_Spotting",5],
        ["ACE_CarlGustav_HEAT",48],["ACE_CarlGustav_HEDP",48],["ACE_CarlGustav_HE",48],["ACE_Dragon",3], // ["ACE_Javelin",1],

        ["ACE_Dummy_EQUIP",40],
        ["ACE_40mm_Buck_M79",48],["ACE_6Rnd_40mm_M32",48],["ACE_40mm_HEDP_M203",48],["ACE_40mm_FlareWhite_M203",48],
        ["ACE_40mm_FlareGreen_M203",48],["ACE_40mm_FlareRed_M203",48],["ACE_40mm_FlareYellow_M203",48],["ACE_40mm_FlareIR_M203",48],
        ["ACE_40mm_SmokeWhite_M203",48],["ACE_40mm_SmokeRed_M203",48],["ACE_40mm_SmokeGreen_M203",48],["ACE_40mm_SmokeYellow_M203",48],
        ["ACE_1Rnd_Flare_White",48],["ACE_1Rnd_Flare_Green",48],["ACE_1Rnd_Flare_Red",48],["ACE_1Rnd_Flare_Yellow",48],

        ["ACE_Dummy_EQUIP",40],
        ["ACE_HandGrenade",48],["ACE_HandGrenadeTimed",48],["ACE_SmokeGrenade_White",48],["ACE_SmokeGrenade_Red",48],
        ["ACE_SmokeGrenade_Green",48],["ACE_SmokeGrenade_Yellow",48],["ACE_SmokeGrenade_Violet",48],["ACE_Flashbang",48],
        ["ACE_PipeBomb",48],["ACE_Claymore_M",48],["ACE_POMZ_M",48],["ACE_Mine",48]
    ];

	while { alive _ve } do {
		if (_old_rank != rank player) then {
			_ve call SYG_clearAmmoBox;
			_old_rank = rank player;
			_index = _old_rank call XGetRankIndex;
            // Weaponcargo that is on the top in a box
            {
				_ve addWeaponCargo _x;
            } forEach [["NVGoggles",5], ["Binocular",5], ["LaserDesignator",5], ["ACE_ParachutePack",5], ["ACE_ParachuteRoundPack",5]];

            // Add ranked stuff of weapon
            {
                _weapons = _x;
                for "_i" from 0 to _index do {
                    _rk = _weapons select _i;
                    {_ve addWeaponCargo _x} forEach _rk;
                };
            } forEach x_ranked_weapons_west;

            // Add all available east ammo
            {
                _ve addMagazineCargo _x;
            } forEach _ammo_list;
		};
		sleep 15;
	};
};

if (true) exitWith {};
