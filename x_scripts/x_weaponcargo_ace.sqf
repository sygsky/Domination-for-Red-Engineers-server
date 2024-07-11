// by Xeno: x_scripts\x_weaponcargo_ace.sqf
// called if ACE non RANKED version (really both loads are equal)
private ["_ve"];

#include "x_setup.sqf"

_ve = _this select 0;

if (isNil "x_ranked_weapons") then {
	x_ranked_weapons = [

[
//АВТОМАТИЧЕСКОЕ ОРУЖИЕ
//################################################################################
				// РЯДОВОЙ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_RIFLE",3]
				#else
				["ACE_Dummy_RIFLE",3],["ACE_AK74",10],["ACE_AKS74U",10],["ACE_Bizon",10],["ACE_AKM",10],["ACE_AKMS",10],["ACE_AK47",10],["ACE_AKS47",10],["ACE_AKS47nobutt",10]
				#endif
			],
				// ЕФРЕЙТОР
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_RIFLE",3]
				#else
				["ACE_AK74GL",10],["ACE_AKMGL",10],["ACE_AKMSGL",10],["ACE_AK47GL",10]
				#endif
			],
				// СЕРЖАНТ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_RIFLE",3]
				#else
				["ACE_AKS74USD",10],["ACE_Bizon_SD",10],["ACE_AKMS_PBS1",10],["ACE_Val",10]
				#endif
			],
				// ЛЕЙТЕНАНТ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_RIFLE",3]
				#else
				["ACE_AKS74U_Cobra",10],["ACE_Bizon_Cobra",10],["ACE_AKM_Cobra",10],["ACE_AKMGL_Cobra",10],["ACE_AKMS_Cobra",10]
				#endif
			],
				// КАПИТАН
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_RIFLE",3]
				#else
				["ACE_Val_Cobra",10],["ACE_AKS74USD_Cobra",10],["ACE_Bizon_SD_Cobra",10]
				#endif
			],
				// МАЙОР
			[
			    #ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_RIFLE",3]
				#else
				["ACE_AKMS_PBS1_Cobra",10]
				#endif
			],
				// ПОЛКОВНИК
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_RIFLE",3]
				#else
				#endif
			]
],
[
//СНАЙПЕРСКИЕ ВИНТОВКИ
//################################################################################
				// РЯДОВОЙ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_SNIPER",3]
				#else
				#endif
			],
				// ЕФРЕЙТОР
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_SNIPER",3]
				#else
				["ACE_Dummy_SNIPER",3],["ACE_AKS74PSO",10]
				#endif
			],
				// СЕРЖАНТ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_SNIPER",3]
				#else
				["ACE_SVD",10]
				#endif
			],
				// ЛЕЙТЕНАНТ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_SNIPER",3]
				#else
				["ACE_VSS",10]
				#endif
			],
				// КАПИТАН
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_SNIPER",3]
				#else
				["ACE_KSVK",10]
				#endif
			],
				// МАЙОР
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_SNIPER",3]
				#else
				["ACE_SV98",10]
				#endif
			],
				// ПОЛКОВНИК
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_SNIPER",3]
				#else
				["ACE_OSV96",10]
				#endif
			]
],
[
//ПУЛЕМЕТЫ
//################################################################################
				// РЯДОВОЙ
            [
            	#ifdef __OWN_SIDE_WEST__
            	["ACE_Dummy_MG",3]
				#else
				["ACE_Dummy_MG",3],["ACE_RPK47",10]
				#endif
            ],
				// ЕФРЕЙТОР
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_MG",3]
				#else
				["ACE_RPK74",10],["ACE_RPK74M",10]
				#endif
			],
				// СЕРЖАНТ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_MG",3]
				#else
                ["ACE_PK",10],["ACE_RPK74M_1P29",10],["ACE_NSVProxy",10],["ACE_6T7TripodProxy",10]
				#endif
			],
				// ЛЕЙТЕНАНТ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_MG",3]
				#else
				["ACE_Pecheneg",10]
				#endif
			],
				// КАПИТАН
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_MG",3]
				#else
				["ACE_Pecheneg_1P29",10]
				#endif
			],
				// МАЙОР
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_MG",3]
				#else
				#endif
			],
				// ПОЛКОВНИК
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_MG",3]
				#else
				#endif
			]
],
[
//ГРАНАТОМЕТЫ
//################################################################################
				// РЯДОВОЙ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_LAUNCHER",3]
				#else
				["ACE_Dummy_LAUNCHER",3],["ACE_RPG7_PGO7",10],["ACE_Strela",10]
				#endif
			],
				// ЕФРЕЙТОР
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_LAUNCHER",3]
				#else
                ["ACE_RPG22",10]
				#endif
			],
				// СЕРЖАНТ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_LAUNCHER",3]
				#else
                ["ACE_RPG27",10],["ACE_RPO",10]
				#endif
			],
				// ЛЕЙТЕНАНТ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_LAUNCHER",3]
				#else
				["ACE_AGS30Proxy",10],["ACE_AGS30TripodProxy",10]
				#endif
			],
				// КАПИТАН
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_LAUNCHER",3]
				#else
				["ACE_RPG29",10]
				#endif
			],
				// МАЙОР
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_LAUNCHER",3]
				#else
				#endif
			],
				// ПОЛКОВНИК
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_LAUNCHER",3]
				#else
				#endif
			]
],
[
//ПИСТОЛЕТЫ
//################################################################################
				// РЯДОВОЙ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_PISTOL",3]
				#else
				["ACE_Dummy_PISTOL",3],["ACE_Makarov",10],["ACE_FlareGun",10],["ACE_MK13",10]
				#endif
			],
				// ЕФРЕЙТОР
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_PISTOL",3]
				#else
				["ACE_TT",10]
				#endif
			],
				// СЕРЖАНТ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_PISTOL",3]
				#else
				["ACE_MakarovSD",10]
				#endif
			],
				// ЛЕЙТЕНАНТ
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_PISTOL",3]
				#else
				#endif
			],
				// КАПИТАН
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_RIFLE",3]
				#else
				["ACE_Scorpion",10]
				#endif
			],
				// МАЙОР
			[
				#ifdef __OWN_SIDE_WEST__
  				["ACE_Dummy_PISTOL",3]
				#else
				#endif
  			],
				// ПОЛКОВНИК
			[
				#ifdef __OWN_SIDE_WEST__
				["ACE_Dummy_PISTOL",3]
				#else
				#endif
			]
]
];
};

_ve spawn {
	private ["_ve", "_old_rank", "_index", "_weapons", "_i", "_rk"];
	_ve = _this;
	_old_rank = "";
	while { alive _ve } do {
		if (_old_rank != rank player) then {
			_ve call SYG_clearAmmoBox;
			_old_rank = rank player;
			_index = _old_rank call XGetRankIndex;
			if (d_enemy_side == "EAST") then {
				// weaponcargo that is allways in a box
				_ve addweaponcargo ["NVGoggles",5];
				_ve addweaponcargo ["Binocular",5];
				_ve addweaponcargo ["LaserDesignator",5];
				_ve addweaponcargo ["ACE_ANPRC77_Alice",5];
				_ve addweaponcargo ["ACE_ParachutePack",5]; // Western planning new style chute
				_ve addweaponcargo ["ACE_ParachuteRoundPack",5]; // Ordinal round old style chute

				// ranked stuff
				{
					_weapons = _x;
					for "_i" from 0 to _index do {
						_rk = _weapons select _i;
						{_ve addweaponcargo _x} forEach _rk;
					};
				} forEach x_ranked_weapons;

				_ve addmagazinecargo ["ACE_Dummy_EQUIP",48];

			} else {
				//weaponcargo that is always in a box
				_ve addweaponcargo ["NVGoggles",10];
				_ve addweaponcargo ["Binocular",10];
				_ve addweaponcargo ["LaserDesignator",10];
				//_ve addweaponcargo ["T-10",10];
				//_ve addweaponcargo ["ACE_ANPRC77_Alice",100];

				// ranked stuff
				{
					_weapons = _x;
					for "_i" from 0 to _index do {
						_rk = _weapons select _i;
						{_ve addweaponcargo _x} forEach _rk;
					};
				} forEach x_ranked_weapons;
			_ve addmagazinecargo ["ACE_Dummy_EQUIP",3];
				_ve addmagazinecargo ["ACE_Bandage",100];
				_ve addmagazinecargo ["ACE_Morphine",100];
				_ve addmagazinecargo ["ACE_Epinephrine",100];
				_ve addmagazinecargo ["Laserbatteries",100];
				_ve addmagazinecargo ["ACE_IRStrobe",100];
				_ve addmagazinecargo ["ACE_SandBag_Magazine",100];
				_ve addmagazinecargo ["ACE_Flashbang",100];
				_ve addmagazinecargo ["ACE_POMZ_M",100];
				//_ve addmagazinecargo ["ACE_Claymore_M",100];
			_ve addmagazinecargo ["ACE_Dummy_RIFLE",3];
   				_ve addmagazinecargo ["ACE_30Rnd_545x39_B_AK",100];
				_ve addmagazinecargo ["ACE_30Rnd_545x39_BT_AK",100];
				_ve addmagazinecargo ["ACE_30Rnd_545x39_SD_AK",100];
				_ve addmagazinecargo ["ACE_30Rnd_762x39_B_RPK",100];
//				_ve addmagazinecargo ["ACE_30Rnd_762x39_B_AK",100];
				_ve addmagazinecargo ["ACE_30Rnd_762x39_BT_AK",100];
				_ve addmagazinecargo ["ACE_30Rnd_762x39_SD_AK",100];
				_ve addmagazinecargo ["ACE_64Rnd_9x18_B_Bizon",100];
				_ve addmagazinecargo ["ACE_20Rnd_9x39_B_VAL",100];
			_ve addmagazinecargo ["ACE_Dummy_SNIPER",3];
				_ve addmagazinecargo ["ACE_10Rnd_762x54_SB_SVD",100];
 				_ve addmagazinecargo ["ACE_10Rnd_9x39_SB_VSS",100];
               	_ve addmagazinecargo ["ACE_5Rnd_127x108_SB_KSVK",100];
				_ve addmagazinecargo ["ACE_5Rnd_127x108_BT_KSVK",100];
				_ve addmagazinecargo ["ACE_10Rnd_762x54_SB_SV98",100];
				_ve addmagazinecargo ["ACE_5Rnd_127x108_SB_OSV96",100];
			_ve addmagazinecargo ["ACE_Dummy_MG",3];
				_ve addmagazinecargo ["ACE_40Rnd_762x39_B_AK",100];
				_ve addmagazinecargo ["ACE_40Rnd_762x39_BT_AK",100];
				_ve addmagazinecargo ["ACE_45Rnd_545x39_B_AK",100];
				_ve addmagazinecargo ["ACE_45Rnd_545x39_BT_AK",100];
				_ve addmagazinecargo ["ACE_75Rnd_762x39_B_AK",100];
				_ve addmagazinecargo ["ACE_75Rnd_762x39_BT_AK",100];
				_ve addmagazinecargo ["ACE_100Rnd_762x54_B_PK",100];
				_ve addmagazinecargo ["ACE_100Rnd_762x54_BT_PK",100];
				_ve addmagazinecargo ["ACE_NSV_CSWDM",100];
			_ve addmagazinecargo ["ACE_Dummy_LAUNCHER",3];
				_ve addmagazinecargo ["ACE_Strela",100];
				_ve addmagazinecargo ["ACE_RPG7_PG7V",100];
				_ve addmagazinecargo ["ACE_RPG7_PG7VR",100];
				_ve addmagazinecargo ["ACE_RPG7_PG7VL",100];
				_ve addmagazinecargo ["ACE_RPG7_OG7V",100];
				_ve addmagazinecargo ["ACE_RPG7_TBG7V",100];
				_ve addmagazinecargo ["ACE_RPG22",100];
				_ve addmagazinecargo ["ACE_RPG27",100];
				_ve addmagazinecargo ["ACE_RPO_A",100];
				_ve addmagazinecargo ["ACE_RPG29_PG29",100];
				_ve addmagazinecargo ["ACE_RPG29_TBG29",100];
				_ve addmagazinecargo ["ACE_AGS30_CSWDM",100];
			_ve addmagazinecargo ["ACE_Dummy_PISTOL",3];
				_ve addmagazinecargo ["ACE_8Rnd_9x18_B_Makarov",100];
				_ve addmagazinecargo ["ACE_8Rnd_9x18_SD_Makarov",100];
				_ve addmagazinecargo ["ACE_8Rnd_762x25_B_Tokarev",100];
				_ve addmagazinecargo ["ACE_20Rnd_765x17_vz61",100];
				_ve addmagazinecargo ["ACE_1Rnd_Flare_White",100];
				_ve addmagazinecargo ["ACE_1Rnd_Flare_Green",100];
				_ve addmagazinecargo ["ACE_1Rnd_Flare_Red",100];
				_ve addmagazinecargo ["ACE_1Rnd_Flare_Yellow",100];
			//_ve addmagazinecargo ["ACE_Dummy_RIFLE",3];
				_ve addmagazinecargo ["ACE_40mm_FlareWhite_GP25",100];
				_ve addmagazinecargo ["ACE_40mm_FlareGreen_GP25",100];
				_ve addmagazinecargo ["ACE_40mm_FlareRed_GP25",100];
				_ve addmagazinecargo ["ACE_40mm_FlareYellow_GP25",100];
				_ve addmagazinecargo ["ACE_40mm_SmokeWhite_GP25",100];
				_ve addmagazinecargo ["ACE_40mm_SmokeRed_GP25",100];
				_ve addmagazinecargo ["ACE_40mm_SmokeGreen_GP25",100];
				_ve addmagazinecargo ["ACE_40mm_SmokeYellow_GP25",100];
				_ve addmagazinecargo ["ACE_SmokeGrenade_White",100];
				_ve addmagazinecargo ["ACE_SmokeGrenade_Red",100];
				_ve addmagazinecargo ["ACE_SmokeGrenade_Green",100];
				_ve addmagazinecargo ["ACE_SmokeGrenade_Yellow",100];
				_ve addmagazinecargo ["ACE_SmokeGrenade_Violet",100];
				_ve addmagazinecargo ["ACE_HandGrenade",100];
				_ve addmagazinecargo ["ACE_40mm_HEDP_GP25",100];
				_ve addmagazinecargo ["ACE_40mm_VOG25P_GP25",100];
				_ve addmagazinecargo ["ACE_PipeBomb",100];
				_ve addmagazinecargo ["ACE_MineE",100];
			};
		};
		sleep 15;
	};
};

if (true) exitWith {};
