// by Xeno, x_scripts/x_weaponcargor_east_ace.sqf
// called only for __ACE__ + __RANKED__ defined version

#include "x_setup.sqf"

private ["_ve"];
_ve = _this select 0;

if (isNil "x_ranked_weapons") then {
	x_ranked_weapons =
    [

        [
    // ################################################################################ Auto Rifles
                // РЯДОВОЙ 0
            [ ["ACE_Dummy_RIFLE",3],["ACE_AK74",10],["ACE_AKS74U",10],["ACE_Bizon",10],["ACE_AKM",10]/*, ["ACE_AKMS",10], ["ACE_AK47",10],["ACE_AKS47",10],["ACE_AKS47nobutt",10],["ACE_M1014",10] */ ],
                // ЕФРЕЙТОР 1
            [ ["ACE_AK74GL",10],["ACE_AKMGL",10]/*,["ACE_AKMSGL",10]*/,["ACE_AK47GL",10],["ACE_SPAS12",10],["ACE_M1014_Eotech", 10] ],
                // СЕРЖАНТ 2
            [ ["ACE_AKS74USD",10],["ACE_Bizon_SD",10],["ACE_AKMS_PBS1",10],["ACE_Val",10] ],
                // ЛЕЙТЕНАНТ 3
            [ ["ACE_AKS74U_Cobra",10],["ACE_Bizon_Cobra",10],["ACE_AKM_Cobra",10],["ACE_AKMGL_Cobra",10]/* ,["ACE_AKMS_Cobra",10] */ ],
                // КАПИТАН 4
            [ ["ACE_Val_Cobra",10],["ACE_AKS74USD_Cobra",10],["ACE_Bizon_SD_Cobra",10] ],
                // МАЙОР 5
            [  ],
                // ПОЛКОВНИК 6++
            [ ]
       ],
        [
    //################################################################################ Sniper rifles
                // РЯДОВОЙ
            [ ["ACE_Dummy_SNIPER",3] ],
                // ЕФРЕЙТОР
            [ ["ACE_AKS74PSO",10] ],
                // СЕРЖАНТ
            [ ["ACE_SVD",10] ],
                // ЛЕЙТЕНАНТ
            [ ["ACE_VSS",10] ],
                // КАПИТАН
            [ ["ACE_KSVK",10] ],
                // МАЙОР
            [ /*["ACE_SV98",10]*/ ],
                // ПОЛКОВНИК
            [ /*["ACE_OSV96",10]*/ ]
        ],
        [
    //################################################################################ Machine guns
                // РЯДОВОЙ
            [ ],
                // ЕФРЕЙТОР
            [  /* ["ACE_RPK74",10], */["ACE_RPK74M",10] ],
                // СЕРЖАНТ
            [ ["ACE_PK",10],["ACE_RPK74M_1P29",10] ],
                // ЛЕЙТЕНАНТ
            [ ["ACE_Pecheneg",10],["ACE_NSVProxy",10],["ACE_6T7TripodProxy",10] ],
                // КАПИТАН
            [ ["ACE_Pecheneg_1P29",10] ],
                // МАЙОР
            [ ],
                // ПОЛКОВНИК
            [ ]
        ],
        [
    //################################################################################ RPG
                // РЯДОВОЙ
            [ ],
                // ЕФРЕЙТОР
            [ ["ACE_RPG7_PGO7",10] ],
                // СЕРЖАНТ
            [ ["ACE_RPG27",10],["ACE_RPO",10] ],
                // ЛЕЙТЕНАНТ
            [ ["ACE_AGS30Proxy",10],["ACE_AGS30TripodProxy",10] ],
                // КАПИТАН
            [ ["ACE_RPG29",10] ],
                // МАЙОР
            [ ],
                // ПОЛКОВНИК
            [ ]
        ],
        [
//################################################################################ Pistols
				// РЯДОВОЙ
			[ ["ACE_Dummy_PISTOL",3],["ACE_Makarov",10],["ACE_FlareGun",10],["ACE_MK13",10] ],
				// ЕФРЕЙТОР
			[ ["ACE_TT",10] ],
				// СЕРЖАНТ
			[ ["ACE_MakarovSD",10] ],
				// ЛЕЙТЕНАНТ
			[ ["ACE_M32",10] ],
				// КАПИТАН
			[ ["ACE_Scorpion",10] ],
				// МАЙОР
			[ ],
				// ПОЛКОВНИК
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
//    	["ACE_Dummy_EQUIP",3],
    	["ACE_Bandage",100],["ACE_Morphine",100],["ACE_Epinephrine",100],["Laserbatteries",100],
    	["ACE_IRStrobe",100],["ACE_SandBag_Magazine",100],["ACE_Flashbang",100],["ACE_POMZ_M",100],
    	["ACE_Dummy_RIFLE",3],
    	["ACE_30Rnd_545x39_BT_AK",100],["ACE_30Rnd_545x39_SD_AK",100],["ACE_30Rnd_762x39_BT_AK",100],
    	["ACE_30Rnd_762x39_SD_AK",100],["ACE_64Rnd_9x18_B_Bizon",100],["ACE_20Rnd_9x39_B_VAL",100],["ACE_9Rnd_12Ga_Slug",100],
    	["ACE_9Rnd_12Ga_Buck00",100],
    	["ACE_Dummy_SNIPER",3],
    	["ACE_10Rnd_762x54_SB_SVD",100],["ACE_10Rnd_9x39_SB_VSS",100],["ACE_5Rnd_127x108_BT_KSVK",100],
    	["ACE_Dummy_MG",3],["ACE_45Rnd_545x39_BT_AK",100],["ACE_40Rnd_762x39_BT_AK",100],["ACE_75Rnd_762x39_BT_AK",100],
    	["ACE_100Rnd_762x54_BT_PK",100],["ACE_NSV_CSWDM",100],
    	["ACE_Dummy_LAUNCHER",3],
    	["ACE_RPG7_PG7VL",100],["ACE_RPG7_PG7V",100],["ACE_Strela",100],["ACE_RPG7_PG7VR",100],
    	["ACE_RPG7_OG7V",100],["ACE_RPG7_TBG7V",100],["ACE_RPG22",100],["ACE_RPG27",100],["ACE_RPO_A",100],["ACE_RPG29_PG29",100],
    	["ACE_RPG29_TBG29",100],["ACE_AGS30_CSWDM",100],
    	["ACE_Dummy_PISTOL",3],
    	["ACE_8Rnd_9x18_B_Makarov",100],["ACE_8Rnd_9x18_SD_Makarov",100],["ACE_8Rnd_762x25_B_Tokarev",100],["ACE_20Rnd_765x17_vz61",100],
    	["ACE_Dummy_EQUIP",3],
    	["ACE_1Rnd_Flare_White",100],["ACE_1Rnd_Flare_Green",100],["ACE_1Rnd_Flare_Red",100],
    	["ACE_1Rnd_Flare_Yellow",100],["ACE_40mm_FlareWhite_GP25",100],["ACE_40mm_FlareGreen_GP25",100],
    	["ACE_40mm_FlareRed_GP25",100],["ACE_40mm_FlareYellow_GP25",100],["ACE_40mm_SmokeWhite_GP25",100],
    	["ACE_40mm_SmokeRed_GP25",100],["ACE_40mm_SmokeGreen_GP25",100],["ACE_40mm_SmokeYellow_GP25",100],
    	["ACE_Dummy_EQUIP",3],
    	["ACE_SmokeGrenade_White",100],["ACE_SmokeGrenade_Red",100],["ACE_SmokeGrenade_Green",100],
    	["ACE_SmokeGrenade_Yellow",100],["ACE_SmokeGrenade_Violet",100],["ACE_HandGrenade",100],
    	["ACE_HandGrenadeRGN",30],["ACE_HandGrenadeRGO",30],["ACE_40mm_HEDP_GP25",100],
    	["ACE_40mm_VOG25P_GP25",100],["ACE_PipeBomb",100],["ACE_MineE",100]
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
            } forEach x_ranked_weapons;

            // Add all available east ammo
            {
                _ve addMagazineCargo _x;
            } forEach _ammo_list;
		};
		sleep 15;
	};
};

if (true) exitWith {};
