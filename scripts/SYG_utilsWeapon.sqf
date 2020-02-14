/**
 * by Sygsky. Module to handle weapons: SYG_utilsWeapon.sqf
 *
 */

#include "x_setup.sqf"
 
#define arg(x) (_this select(x))
#define argp(arr,x) ((arr)select(x))
#define inc(x) ((x)=(x)+1)
#define argopt(num,val) (if((count _this)<=(num))then{val}else{arg(num)})
#define RAR(ARR) ((ARR)select(floor(random(count(ARR)))))
#define RANDOM_ARR_ITEM(ARR) ((ARR)select(floor(random(count(ARR)))))

#define MAG_STD 0
#define MAG_STD_SD 1
#define MAG_SNP 2
#define MAG_SNP_STD_SD 3
#define MAG_TRC 4

//#define __DEBUG__
#ifdef __ALLOW_SHOTGUNS__
hint localize "#define __ALLOW_SHOTGUNS__";
#endif

if ( isNil "SYG_UTILS_WEAPON_COMPILED" ) then  // generate some static information
{
	SYG_UTILS_WEAPON_COMPILED = true;
	//SYG_handleMags = compile preprocessFileLineNumbers "scripts\SYG_handleMagazine.sqf";

// СПЕЦГРУППА
//##############################################################################

	//SYG_SPECOPS_WEST = ["ACE_SoldierWSniper2_A","ACE_USMC8541A1A","ACE_SoldierWMAT_USSF_ST_BDUL","ACE_SoldierWAA","ACE_SoldierWB_USSF_ST_BDUL","ACE_SoldierW_Spotter_A","ACE_SoldierWMedic_A","ACE_SoldierWAT2_A"];

// ДЕСАНТ НА БАЗУ
//##############################################################################
	//SYG_SABOTAGE_WEST = ["ACE_SquadLeaderW_A","ACE_SoldierWDemo_A","ACE_SoldierWMAT_A","ACE_SoldierWAA","ACE_SoldierWDemo_USSF_LRSD","ACE_SoldierWDemo_USSF_ST"];


// ПЕХОТА В ГОРОДЕ
//##############################################################################
	// SYG_BASIC_WEST = ["ACE_SoldierWMG_A","ACE_SoldierWAR_A","ACE_SoldierWSniper_A","ACE_SoldierWMAT_A","ACE_SoldierWAA","ACE_SoldierWAT2_A","ACE_SoldierWMedic_A","ACE_SoldierWG","ACE_SoldierW_HMG","ACE_SoldierW_HMGAG","ACE_SoldierWMiner","ACE_SoldierWB_A","ACE_SoldierW_HMGAB"];

	SYG_MINE_LIST = ["ACE_PipeBomb","ACE_TimeBomb","ACE_Mine","ACE_MineE","ACE_Claymore_M","PipeBomb","TimeBomb","Mine","MineE"];

	SNIPER_WEAPON_LIST_WEST = ["ACE_M21", "M24", "m107", "ACE_Mk12SPR", "ACE_HK416_Leu","ACE_HK416_Leu_SD","ACE_HK416_Leu_gl", "ACE_HK416_Leu_gl_SD", "ACE_SCAR_L_Marksman", "ACE_HK417L_Leu", "ACE_HK417L_Leu_SD",  "ACE_SCAR_H_Sniper"];
	SNIPER_WEAPON_LIST_EAST = ["KSVK", "SVD", "aks74pso", "ACE_VSS"];
	SNIPER_WEAPON_LIST = SNIPER_WEAPON_LIST_WEST + SNIPER_WEAPON_LIST_EST;

	MG_WEAPON_LIST_WEST = ["M240", "M249", "ACE_MG36"/*, "M60"*/]; // M60 is not good weapon
	MG_WEAPON_LIST_EAST = ["PK", "ACE_RPK74", "ACE_RPK47"];
	MG_WEAPON_LIST = MG_WEAPON_LIST_WEST + MG_WEAPON_LIST_EAST;

	SMG_WEAPON_LIST = ["MP5SD", "ACE_MK13", "AKS74U"]; // All base classes for SMG/Short Muzzle Guns

	LAUNCHER_WEAPON_LIST = ["Launcher"];
	LIGHT_LAUNCHER_WEAPON_LIST = [ "ACE_RPG22","ACE_M72" ];

	LONG_MUZZLE_WEAPON_LIST = [ "KSVK", "SVD", "ACE_M14" ] + SNIPER_WEAPON_LIST_WEST + MG_WEAPON_LIST;

	//================================================

	SYG_STD_MEDICAL_SET = [ ["ACE_Bandage",2], ["ACE_Morphine"] , ["ACE_Epinephrine"] ];
	SYG_MEDIC_SET = [ ["ACE_Bandage",4], ["ACE_Morphine",2], ["ACE_Epinephrine",2] ];

	SYG_PILOT_GRENADE_SET = [["ACE_SmokeGrenade_Red"], ["ACE_SmokeGrenade_Green"], ["ACE_SmokeGrenade_Violet"],
	                         ["ACE_SmokeGrenade_White"], ["ACE_SmokeGrenade_Yellow"], ["ACE_HandGrenade"]];
	SYG_GL_SET = [["ACE_40mm_HEDP_M203",4]];

	SYG_PISTOL_WPN_SET_WEST_STD_NO_GLOCK = [
				 ["S", "ACE_M1911", "ACE_7Rnd_1143x23_B_M1911", 4],
				 ["S", "ACE_M9", "ACE_15Rnd_9x19_B_M9", 4]
				];
	SYG_PISTOL_WPN_SET_WEST_STD_GLOCK = [
				 ["S", "ACE_Glock17", "ACE_17Rnd_9x19_G17", 4],
				 ["S", "ACE_Glock18", "ACE_33Rnd_9x19_G18", 4]
				];

	SYG_PISTOL_WPN_SET_WEST_STD = SYG_PISTOL_WPN_SET_WEST_STD_NO_GLOCK + SYG_PISTOL_WPN_SET_WEST_STD_GLOCK;

	SYG_PISTOL_WPN_SET_WEST_STD_SD = [
				 ["S", "ACE_M1911SD", "ACE_7Rnd_1143x23_B_M1911", 4],
				 ["S", "ACE_M9SD", "ACE_15Rnd_9x19_SD_M9", 4]
				];

	SYG_PISTOL_WPN_SET_WEST = SYG_PISTOL_WPN_SET_WEST_STD + SYG_PISTOL_WPN_SET_WEST_STD_SD;

	SYG_PILOT_HANDGUN_EAST = [["S", "ACE_Scorpion", "ACE_20Rnd_765x17_vz61", 4]];

	SYG_SMG_WPN_SET_WEST = [
				["P", "ACE_MP5A5", "ACE_30Rnd_9x19_B_MP5", 6],
				["P", "ACE_MP5SD", "ACE_30Rnd_9x19_SD_MP5", 6],
				["P", "ACE_MP5A4", "ACE_30Rnd_9x19_B_MP5", 6],
				["P", "ACE_UMP45", "ACE_25Rnd_1143x23_B_UMP45", 6],
				["P", "ACE_UMP45_SD", "ACE_25Rnd_1143x23_B_UMP45", 6 ]
				];

	SYG_SMG_WPN_SET_EAST = [
				["P", "ACE_AKS74U", "ACE_30Rnd_545x39_B_AK", 6],
				["P", "ACE_AKS74U_Cobra", "ACE_30Rnd_545x39_B_AK", 6],
				["P", "ACE_AKS74USD","ACE_30Rnd_545x39_SD_AK",6],
				["P", "ACE_AKS74USD_Cobra", "ACE_30Rnd_545x39_SD_AK", 6],
				["P", "ACE_Bizon", "ACE_64Rnd_9x18_B_Bizon", 6],
				["P", "ACE_Bizon_SD", "ACE_64Rnd_9x18_B_Bizon_S", 6],
				["P", "ACE_Bizon_Cobra", "ACE_64Rnd_9x18_B_Bizon", 6],
				["P", "ACE_Bizon_SD_Cobra", "ACE_64Rnd_9x18_B_Bizon_S", 6]
			];

	//================================================= SPECIFIC ACE WEAPONS AND MAGAZINES ================================

	// ---------------------------------------------------------------------------------

	// ---------------------------------------------------------------------------------
 	// G36 weapon arrays
	// std weapon
	SYG_G36_WPN_SET_STD = ["ACE_G36","ACE_G36K","ACE_G36KA1","ACE_G36C","ACE_G36C_CompAim","ACE_G36C_CompEo","ACE_MG36"];
	SYG_G36_WPN_SET_STD_SD = [];
	SYG_G36_WPN_SET_SNIPER = ["ACE_G36"];
	SYG_G36_WPN_SET_SNIPER_SD = [];
	SYG_G36_MAGS = ["ACE_30Rnd_556x45_B_G36","ACE_30Rnd_556x45_B_G36","ACE_30Rnd_556x45_B_G36","ACE_30Rnd_556x45_B_G36","ACE_30Rnd_556x45_BT_G36", "ACE_100Rnd_556x45_BT_G36", "ACE_100Rnd_556x45_B_G36"];
	SYG_MG36_WPN_SET = ["ACE_MG36"];

	SYG_G36_WHOLE = SYG_G36_WPN_SET_STD + SYG_G36_WPN_SET_SNIPER;
	// ---------------------------------------------------------------------------------
 	// HK416 weapon arrays
	// std weapon
	SYG_HK416_WPN_SET_STD = ["ACE_HK416","ACE_HK416_aim","ACE_HK416_eotech"];
	SYG_HK416_WPN_SET_STD_OPTICS = ["ACE_HK416_ACOG"];
	SYG_HK416_WPN_SET_STD_SD = ["ACE_HK416_SD","ACE_HK416_aim_SD","ACE_HK416_eotech_SD"];
	//SYG_HK416_WPN_SET_STD_SD_OPTICS = ["ACE_HK416_ACOG_SD"];
	SYG_HK416_WPN_SET_SNIPER = ["ACE_Mk12SPR","ACE_HK416_Leu"];
	//SYG_HK416_WPN_SET_SNIPER_SD = ["ACE_Mk12SPR_SD","ACE_HK416_Leu_SD"];
	SYG_HK416_MAGS = ["ACE_30Rnd_556x45_B_Stanag","ACE_20Rnd_556x45_SB_Stanag","ACE_30Rnd_556x45_SD_Stanag","ACE_20Rnd_556x45_SB_Stanag","ACE_30Rnd_556x45_BT_Stanag"];

	SYG_M16_WPN_SET_STD = ["ACE_M16A2","ACE_M16A4","ACE_M16A4Aimpoint"];
	SYG_M16_WPN_SET_STD_OPTICS = ["ACE_M16A4ACOG"];
	SYG_M16_WPN_SET_STD_SD = [];
	SYG_M16_WPN_SET_STD_SD_OPTICS = [];
	SYG_M16_WPN_SET_SNIPER = ["ACE_Mk12SPR"];
	//SYG_M16_WPN_SET_SNIPER_SD = ["ACE_Mk12SPR_SD"];
	SYG_M16_MAGS = ["ACE_30Rnd_556x45_B_Stanag","ACE_20Rnd_556x45_SB_Stanag","ACE_30Rnd_556x45_SD_Stanag","ACE_20Rnd_556x45_SB_Stanag","ACE_30Rnd_556x45_BT_Stanag"];

	SYG_M16_WPN_SET_ALL_OPTICS = SYG_M16_WPN_SET_STD_OPTICS + SYG_M16_WPN_SET_SNIPER /*+ SYG_M16_WPN_SET_SNIPER_SD*/;

/*
	[
        "ACE_M4A1AimPointSD",
        "ACE_SCAR_L_CQB_SD","ACE_SCAR_L_CQB_Aim_SD",
        "ACE_HK416_SD","ACE_HK416_aim_SD","ACE_HK416_eotech_SD"
	];
*/
	SYG_ORDINAL_WPNSET_SD_GL =	["ACE_HK416_gl_SD","ACE_HK416_aim_gl_SD","ACE_HK416_eotech_gl_SD"]; // Not used anywhere
	// ---------------------------------------------------------------------------------
 	// HK417 weapon arrays
	// std weapon

	SYG_HK417_WPN_SET_STD = ["ACE_HK417C","ACE_HK417C_EOTECH","ACE_HK417L","ACE_HK417L_EOTECH","ACE_HK417L_M68"];
	SYG_HK417_WPN_SET_STD_OPTICS = ["ACE_HK417C_ACOG","ACE_HK417L_ACOG"];
	//SYG_HK417_WPN_SET_STD_SD = ["ACE_HK417C_SD", "ACE_HK417C_EOTECH_SD","ACE_HK417L_SD","ACE_HK417L_EOTECH_SD","ACE_HK417L_M68_SD"];
	//SYG_HK417_WPN_SET_STD_SD_OPTICS = ["ACE_HK417C_ACOG_SD","ACE_HK417L_ACOG_SD"];
	SYG_HK417_WPN_SET_SNIPER = ["ACE_HK417L_Leu"];
	//SYG_HK417_WPN_SET_SNIPER_SD = ["ACE_HK417L_Leu_SD"];
	SYG_HK417_MAGS = ["ACE_20Rnd_762x51_B_HK417", "ACE_20Rnd_762x51_SB_HK417", "ACE_20Rnd_762x51_B_HK417", "ACE_20Rnd_762x51_SB_HK417", "ACE_20Rnd_762x51_B_HK417"];


	// ---------------------------------------------------------------------------------
 	// SCAR-L weapon arrays
	// std weapon
	SYG_SCARL_WPN_SET_STD = ["ACE_SCAR_L","ACE_SCAR_L_CQB_EOtech","ACE_SCAR_L_CQB_Aim","ACE_SCAR_L_CQB_Docter"] ;
	SYG_SCARL_WPN_SET_STD_OPTICS = ["ACE_SCAR_L_ACOG","ACE_SCAR_L_CQB_mk4","ACE_SCAR_L_Specter","ACE_SCAR_L_shortdot"] ;
	// silenced weapon
	SYG_SCARL_WPN_SET_STD_SD = ["ACE_SCAR_L_CQB_SD","ACE_SCAR_L_CQB_EOtech_SD","ACE_SCAR_L_CQB_Aim_SD","ACE_SCAR_L_CQB_Docter_SD"] ;
	//SYG_SCARL_WPN_SET_STD_SD_OPTICS = ["ACE_SCAR_L_ACOG_SD","ACE_SCAR_L_CQB_mk4_SD","ACE_SCAR_L_Specter_SD","ACE_SCAR_L_shortdot_SD"] ;
	// sniper weapon
	SYG_SCARL_WPN_SET_SNIPER =  ["ACE_SCAR_L_Marksman", "ACE_SCAR_L_Marksman_ACOG","ACE_SCAR_L_Marksman_Leu"];
	// sniper weapon silenced
	SYG_SCARL_WPN_SET_SNIPER_SD =  ["ACE_SCAR_L_Marksman_SD","ACE_SCAR_L_Marksman_Leu_SD" ];
	SYG_SCARL_MAGS = ["ACE_30Rnd_556x45_B_Stanag", "ACE_20Rnd_556x45_SB_Stanag", "ACE_30Rnd_556x45_SD_Stanag", "ACE_20Rnd_556x45_SB_Stanag","ACE_30Rnd_556x45_BT_Stanag"];

	// ---------------------------------------------------------------------------------
 	// SCAR-H weapon arrays
	// std weapon
	SYG_SCARH_WPN_SET_STD = ["ACE_SCAR_H","ACE_SCAR_H_CQB","ACE_SCAR_H_CQB_EOtech","ACE_SCAR_H_CQB_Aim","ACE_SCAR_H_CQB_Docter"];
	SYG_SCARH_WPN_SET_STD_OPTICS = ["ACE_SCAR_H_CQB_mk4","ACE_SCAR_H_SPECTER","ACE_SCAR_H_ACOG"];
	// silent weapon
	//SYG_SCARH_WPN_SET_STD_SD =  ["ACE_SCAR_H_CQB_EOtech_SD","ACE_SCAR_H_CQB_Aim_SD", "ACE_SCAR_H_CQB_Docter_SD"];
	//SYG_SCARH_WPN_SET_STD_SD_OPTICS = ["ACE_SCAR_H_CQB_mk4_SD","ACE_SCAR_H_SPECTER_SD","ACE_SCAR_H_ACOG_SD"];
	// sniper weapon
	SYG_SCARH_WPN_SET_SNIPER =  ["ACE_SCAR_H_Sniper"];
	// sniper weapon silenced
	//SYG_SCARH_WPN_SET_SNIPER_SD =  ["ACE_SCAR_H_Sniper_SD"];
	// mags: ordinal, sniper, silenced, sniper silenced, tracers
	SYG_SCARH_MAGS = ["ACE_20Rnd_762x51_B_SCAR", "ACE_20Rnd_762x51_SB_SCAR", "ACE_20Rnd_762x51_B_SCAR", "ACE_20Rnd_762x51_B_SCAR","ACE_20Rnd_762x51_B_SCAR"];

	// ---------------------------------------------------------------------------------
 	// M14 weapon arrays
	// std weapon
	SYG_M14_WPN_SET_STD = ["ACE_M14","ACE_M14_reflex","ACE_M14_nam","ACE_M14_sop","ACE_M14_sop_aim","ACE_M14_sop_cmore", "ACE_M14_sop_eotech"];
	SYG_M14_WPN_SET_STD_OPTICS = ["ACE_M14_sop_acog_cqb","ACE_M14_wdl_acog_cqb","ACE_M14_sop_elcan_cqb"];
	// silenced weapon
	SYG_M14_WPN_SET_STD_SD =  ["ACE_M14_sopS","ACE_M14_sop_eotechS","ACE_M14_sop_aimS","ACE_M14_sop_cmoreS"];
	SYG_M14_WPN_SET_STD_SD_OPTICS =  ["ACE_M14_sop_acogS_cqb","ACE_M14_sop_elcanS_cqb"];
	// sniper weapon
	SYG_M14_WPN_SET_SNIPER =  ["ACE_M14_sop_dmr"];
	// sniper weapon silenced
	SYG_M14_WPN_SET_SNIPER_SD =  ["ACE_M14_sop_dmrS"];

	SYG_M14_WPN_SET_WHOLE = SYG_M14_WPN_SET_STD+SYG_M14_WPN_SET_STD_OPTICS+SYG_M14_WPN_SET_STD_SD+SYG_M14_WPN_SET_STD_SD_OPTICS+SYG_M14_WPN_SET_SNIPER+SYG_M14_WPN_SET_SNIPER_SD;

	// mags: ordinal, sniper, silenced, sniper silenced, tracers
	SYG_M14_MAGS = ["ACE_20Rnd_762x51_B_M14","ACE_20Rnd_762x51_SB_M14", "ACE_20Rnd_762x51_B_M14","ACE_20Rnd_762x51_SB_M14","ACE_20Rnd_762x51_B_M14"];

	// ---------------------------------------------------------------------------------
 	// M21 SNIPER weapon arrays
	// sniper weapon
	SYG_M21_WPN_SET =  ["ACE_M21","ACE_M21_dmr","ACE_M21_police","ACE_M21_wdl"];
	// sniper weapon silenced
	//SYG_M21_WPN_SET_SD =  ["ACE_M21_dmrS"];
	// mags: sniper
	SYG_M21_MAGS = ["ACE_20Rnd_762x51_SB_M14"];

	// ---------------------------------------------------------------------------------
 	// M24 SNIPER weapon arrays
	// sniper weapon
	SYG_M24_WPN_SET =  [ "ACE_M24","ACE_M40A3"];
	// mags: sniper
	SYG_M24_MAGS = ["ACE_5Rnd_762x51_SB"];


	// ---------------------------------------------------------------------------------
 	// M110 SNIPER weapon arrays, average sniper weapon
	SYG_M110_WPN_SET =  ["ACE_M110"];
	// sniper weapon silenced
	//SYG_M110_WPN_SET_SD =  ["ACE_M110_SD"];
	SYG_M110_WPN_SET_WHOLE =  SYG_M110_WPN_SET/* + SYG_M110_WPN_SET_SD*/;
	// mags: sniper
	SYG_M110_MAGS = ["ACE_20Rnd_762x51_SB_M110"];

	// ---------------------------------------------------------------------------------
 	// HEAVYSNIPER weapon arrays (12.7 mm caliber)
	// heavy sniper weapon

	SYG_HEAVYSNIPER_WPN_SET =
	[
		["ACE_M82A1",[ "ACE_10Rnd_127x99_API_Barrett", "ACE_10Rnd_127x99_SB_Barrett", "ACE_10Rnd_127x99_BT_Barrett"]],
		["ACE_M109",["ACE_5Rnd_25x59_HEDP_Barrett"]],
		["ACE_AS50",["ACE_5Rnd_127x99_API_AS50", "ACE_5Rnd_127x99_AS50", "ACE_5Rnd_127x99_SB_AS50", "ACE_5Rnd_127x99_BT_AS50"]]
	];

	// ---------------------------------------------------------------------------------
 	// MG weapon arrays (7.62 mm caliber). ACE_M60 is not good here - units often use pistol except it on short distance
	SYG_M240_MG_WPN_SET =
	[
		["ACE_M240G",["ACE_100Rnd_762x51_B_M240", "ACE_100Rnd_762x51_BT_M240", "ACE_50Rnd_762x51_B_M240", "ACE_50Rnd_762x51_BT_M240", "100Rnd_762x51_M240"]],
		["ACE_M240G_M145",["ACE_100Rnd_762x51_B_M240", "ACE_100Rnd_762x51_BT_M240", "ACE_50Rnd_762x51_B_M240", "ACE_50Rnd_762x51_BT_M240", "100Rnd_762x51_M240"]]
	];

 	// MG weapon arrays (5.56 mm caliber)
	SYG_M249_MG_WPN_SET =
	[
		["ACE_M249",["ACE_200Rnd_556x45_B_M249", "ACE_200Rnd_556x45_BT_M249"]],
		["ACE_M249Para",["ACE_200Rnd_556x45_B_M249", "ACE_200Rnd_556x45_BT_M249"]],
		["ACE_M249Para_M145",["ACE_200Rnd_556x45_B_M249", "ACE_200Rnd_556x45_BT_M249"]]
	];

    //"E:\Bin\ArmA\@ACE\Addons\ace_sys_ruck\config.cpp"
    SYG_RADIO_SET =
    [
        "ACE_ANPRC77_Alice", "ACE_ANPRC77_Raid", "ACE_P159_RD54", "ACE_P159_RD90", "ACE_P159_RD99"
    ];

    // ShotGuns Set
    SYG_SHOTGUN_SET =
    [
        "ACE_M1014", "ACE_M1014_Eotech", "ACE_SPAS12"
    ];

	SYG_SHOTGUN_AMMO9 = [ "ACE_9Rnd_12Ga_Slug", "ACE_9Rnd_12Ga_Buck00"];
	SYG_SHOTGUN_AMMO8 = [ "ACE_8Rnd_12Ga_Slug", "ACE_8Rnd_12Ga_Buck00"];

	SYG_ORDINAL_WPNSET_SD = SYG_SCARL_WPN_SET_STD_SD + SYG_HK416_WPN_SET_STD_SD + ["ACE_M4A1AimPointSD"];

	#define SYG_MAG_STD 0
	#define SYG_MAG_SNIPER 1
	#define SYG_MAG_STD_SD 2
	#define SYG_MAG_SNIPER_SD 3
	#define SYG_MAG_STD_TRACER 4
	// ---------------------------------------------------------------------------------

	SYG_STD_PILOT_EQUIPMENT = SYG_STD_MEDICAL_SET + SYG_PILOT_GRENADE_SET + [["E", "NVGoggles"]];

	#define WeaponNoSlot            0   // Dummy weapons
	#define WeaponSlotPrimary       1   // Primary weapon
	#define WeaponSlotHandGun       2   // Handgun slot
	#define WeaponSlotSecondary     4   // Secondary weapon (launcher)
	#define WeaponSlotHandGunMag   16   // Handgun magazines (8x)(or grenades for M203/GP-25)
	#define WeaponSlotMag         256   // Magazine slots (12x / 8x for medics)
	#define WeaponSlotGoggle     4096   // Goggle slot (2x)
	#define WeaponHardMounted   65536   // Hard mouted weapon (not for man)

	#define arg(x) (_this select (x))
	#define RANDOM_ARR_ITEM(ARR) (ARR select (floor (random (count ARR ))))

	#define DEFINE_WEAPON_FUNC_SET(NAME) SYG_get##NAME##StdWpn =  { ["P", SYG_##NAME##_WPN_SET_STD select (floor (random (count SYG_##NAME##_WPN_SET_STD ))), SYG_##NAME##_MAGS select SYG_MAG_STD, 6] }; \
	SYG_get##NAME##StdWpnOptics =  { ["P", SYG_##NAME##_WPN_SET_STD_OPTICS select (floor (random (count SYG_##NAME##_WPN_SET_STD_OPTICS ))), SYG_##NAME##_MAGS select SYG_MAG_STD, 6] }; \
	SYG_get##NAME##StdWpnSD =  { ["P", SYG_##NAME##_WPN_SET_STD_SD select (floor (random (count SYG_##NAME##_WPN_SET_STD_SD ))), SYG_##NAME##_MAGS select SYG_MAG_STD_SD, 6] }; \
	SYG_get##NAME##StdWpnSDOptics =  { ["P", SYG_##NAME##_WPN_SET_STD_SD_OPTICS select (floor (random (count SYG_##NAME##_WPN_SET_STD_SD_OPTICS ))), SYG_##NAME##_MAGS select SYG_MAG_STD_SD, 6] }; \
	SYG_get##NAME##Sniper =  { ["P", SYG_##NAME##_WPN_SET_SNIPER select (floor (random (count SYG_##NAME##_WPN_SET_SNIPER ))), SYG_##NAME##_MAGS select SYG_MAG_SNIPER, 6] }; \
	SYG_get##NAME##SniperSD =  { ["P", SYG_##NAME##_WPN_SET_SNIPER_SD select (floor (random (count SYG_##NAME##_WPN_SET_SNIPER_SD ))), SYG_##NAME##_MAGS select SYG_MAG_SNIPER_SD, 6] } \

	#define DEFINE_FILL_AMMO_BOX_FUNC(NAME) SYG_fillAmmoBox##NAME = { \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD_OPTICS; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD_SD; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD_SD_OPTICS; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_SNIPER; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_SNIPER_SD;} \

	#define DEFINE_FILL_AMMO_BOX_FUNC_STD(NAME) SYG_fillAmmoBox##NAME##_Std = { \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD_OPTICS; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD_SD; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD_SD_OPTICS;} \


	#define DEFINE_FILL_AMMO_BOX_FUNC_SNIPER(NAME) SYG_fillAmmoBox##NAME##_Sniper = { \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_SNIPER; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_SNIPER_SD;} \

	SYG_WHOLE_MAG_LIST = [];

	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_HK416_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_SCARL_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_HK417_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_SCARH_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_G36_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_M14_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_M21_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_M24_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_M110_MAGS;
/*
	{ // for each weapon set
		{ // for each subweapon array item kind
			{ // each magasize
				if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x] };
			}
			forEach _x select 1;
		} forEach _x;
	}forEach [SYG_HEAVYSNIPER_WPN_SET,SYG_M240_MG_WPN_SET,SYG_M249_MG_WPN_SET];
*/
	{
		{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; };} forEach (_x select 1);
	}forEach SYG_HEAVYSNIPER_WPN_SET;

	{
		{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; };} forEach (_x select 1);
	}forEach SYG_M240_MG_WPN_SET;

	{
		{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; }; } forEach (_x select 1);
	}forEach SYG_M249_MG_WPN_SET;
};

DEFINE_WEAPON_FUNC_SET(SCARL);
DEFINE_WEAPON_FUNC_SET(SCARH);
DEFINE_WEAPON_FUNC_SET(HK416);
DEFINE_WEAPON_FUNC_SET(HK417);

DEFINE_FILL_AMMO_BOX_FUNC_STD(SCARL);
DEFINE_FILL_AMMO_BOX_FUNC_STD(SCARH);
DEFINE_FILL_AMMO_BOX_FUNC_STD(HK416);
DEFINE_FILL_AMMO_BOX_FUNC_STD(HK417);

DEFINE_FILL_AMMO_BOX_FUNC_SNIPER(SCARL);
DEFINE_FILL_AMMO_BOX_FUNC_SNIPER(SCARH);
DEFINE_FILL_AMMO_BOX_FUNC_SNIPER(HK416);
DEFINE_FILL_AMMO_BOX_FUNC_SNIPER(HK417);

SYG_getWholeMagsList = { SYG_WHOLE_MAG_LIST };

SYG_clearAmmoBox = {clearMagazineCargo _this; clearWeaponCargo _this;};

SYG_fillAmmoBoxWithMags = { { _this addMagazineCargo [_x, 25];	} forEach SYG_WHOLE_MAG_LIST; };

//
// Returns 1 for rifle, 2 if pistol, 4 for launcher, 4096 for special items (binocular etc), 65536 - for vehicle guns
// call: _type = _wpn call SYG_readWeaponType;
//
SYG_readWeaponType = { getNumber ( configFile >> "CfgWeapons" >> _this >> "type" );};
SYG_readWeaponDisplayName = { getText ( configFile >> "CfgWeapons" >> _this >> "displayName" );};
SYG_isRifle = { (_this call SYG_readWeaponType) == 1};
SYG_isPistol = { (_this call SYG_readWeaponType) == 2};
SYG_isLauncher = { (_this call SYG_readWeaponType) == 4};

/*
SYG_readSlots = {

private ["_readSlots"];
_readSlots = { getNumber ( configFile >> "CfgVehicles" >> _this >> "weaponSlots" ) };
_slotPrimary     = { (_this call _readSlots) % 2 };
_slotHandGun     = { floor((_this call _readSlots) / WeaponSlotHandGun ) % 2 };
_slotSecondary   = { floor((_this call _readSlots) / WeaponSlotSecondary ) % 4 };
_slotHandGunMag  = { floor((_this call _readSlots) / WeaponSlotHandGunMag ) % 16 };
_slotMag         = { floor((_this call _readSlots) / WeaponSlotMag ) % 16 };
_slotGoggle      = { floor((_this call _readSlots) / WeaponSlotGoggle ) % 8 };
_hardMounted     = { floor((_this call _readSlots) / WeaponHardMounted ) % 2 };
};
*/


/**
 * Reads only weapons type (not equipment) list from unitPos
 * call: _list = _unit call SYG_readUnitWeapons;
 * returns: array of weapons with values: 1,2,4.
 * Values 4096, 65536 (see SYG_readWeaponType comments) not used here and is skipped
 */
SYG_readWeapons = {
	private ["_arr", "_type"];
	_arr = [];
	{
		_type = _x call SYG_readWeaponType;
		if ( _type <= 4 ) then {_arr = _arr + _type;};
	} forEach weapons _this;
	_arr;
};
/**
 * call: _hasMine = _unit call SYG_hasAnyMine;
 * Returns: true if ACE_PipeBomb, PipeBomb, TimeBomb, ACE_TimeBomb, ACE_Claymore arу found in unit inventory
 *
 */
SYG_hasAnyMine = {
	[SYG_MINE_LIST, magazines _unit] call Syg_isListInList;
};


/**
 * Rearms unit if he is known to function
 * Returns: true if success, else false. F.e. if unit not known to function
 * call: _res = [_unit<,_rearm_probability<,_advanced_probability>] call SYG_rearmSabotage;
 * params:
 *   _unit: unit to rearm with new weapon
 *   _rearm_probability: probabilty to reard unit. Optional. Default 0.5. Range 0.0 <-> 1.0
 *   _advanced_probability: probability to ream unit with advanced weapon. Must be < _ordinal_probability. Optional.
 *    Default 0.1. Range 0.0 <-> 1.0
 */
//#define __DEBUG_SYG_rearmSabotage__
SYG_rearmSabotage = {
// 	["ACE_SquadLeaderW_A","ACE_SoldierWDemo_A","ACE_SoldierWMAT_A","ACE_SoldierWAA","ACE_SoldierWDemo_USSF_LRSD","ACE_SoldierWDemo_USSF_ST"];

#ifdef __DEBUG_SYG_rearmSabotage__
    hint localize format["+++ SYG_rearmSabotage: %1", _this];
#endif
    private ["_unit","_unit_type","_prob","_adv_rearm","_super_rearm","_rnd","_equip", "_ret","_wpn","_i","_allow_shotgun",
             "_smoke_grenade","_glMuzzle"];
	if ( typeName _this == "ARRAY" ) then // [_unit<, prob1<, prob2>>] call
	{
		_unit = arg(0);
        _prob = argopt(1, 0.7);
        _adv_rearm = argopt(2, 0.1); // do advanced rearming  (true) or not (false)
#ifdef __ALLOW_SHOTGUNS__
        _allow_shotgun = argopt(3, true);
#endif
	}else{
		_unit = _this;
		_prob = 0.7;
        _adv_rearm = 0.1; // do advanced rearming  (true) or not (false)
#ifdef __ALLOW_SHOTGUNS__
        _allow_shotgun = true;
#endif
	};
    _unit_type = typeOf _unit;
	_ret = false;
	_rnd = random 1.0;
	_smoke_grenade = "ACE_SmokeGrenade_Violet";
	_glMuzzle = false;
	if ( _rnd < _prob ) then  { // do rearming
#ifdef __DEBUG_SYG_rearmSabotage__
	    hint localize format["+++ SYG_rearmSabotage do full rearming for %1", _unit_type];
#endif
		_super_rearm = _rnd < (_adv_rearm / 3.0); // do super rearming  (true) or not (false)
		_adv_rearm   = _rnd < _adv_rearm; // do advanced rearming  (true) or not (false)
		_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD_NO_GLOCK)] + SYG_STD_MEDICAL_SET;

		_ret = true;
		switch (_unit_type) do
		{
			case "ACE_SquadLeaderW_A":
			{
				_equip = _equip + [["P", "ACE_M136", "ACE_AT4_HP", 3]]; // average launcher + high penetration rocket
				if ( _super_rearm ) then
				{
					switch (floor (random 4)) do
					{
						//case 0: {_wpn = RAR(SYG_HK416_WPN_SET_STD_SD_OPTICS);};
						//case 0: {_wpn = RAR(SYG_HK417_WPN_SET_STD_SD_OPTICS);};
						case 0: {_wpn = RAR(SYG_SCARL_WPN_SET_STD_OPTICS);};
						case 1: {_wpn = RAR(SYG_SCARH_WPN_SET_STD_OPTICS);};
						case 2: {_wpn = RAR(SYG_G36_WPN_SET_STD);};
						case 3: {_wpn = RAR(SYG_SCARH_WPN_SET_STD);};
					};
				}
				else
				{
					if ( _adv_rearm ) then
					{
						_wpn = RAR(SYG_HK417_WPN_SET_STD);
					}
					else
					{
//						_wpn = RAR(SYG_HK416_WPN_SET_STD);
    					_wpn = RAR(SYG_ORDINAL_WPNSET_SD);
#ifdef __DEBUG_SYG_rearmSabotage__
        				hint localize format["+++ SYG_rearmSabotage _wpn %1 (%2)", _wpn,SYG_ORDINAL_WPNSET_SD];
#endif
					};
				};
				// check for GL muzzle for primary weapon
				_muzzles  = getArray(configFile>>"cfgWeapons" >> _wpn >> "muzzles");
				_glMuzzle = (_muzzles  find "ACE_M203Muzzle") >= 0; // GL found
				if (_glMuzzle) then {_equip set [0, SYG_GL_SET]};
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 3]]+ [["ACE_PipeBomb"],[_smoke_grenade]];
			};
			case "ACE_SoldierWMAT_A":
			{
				_equip = _equip + [["P", "ACE_M136", "ACE_AT4_HP", 3]]; // average launcher + 2 high penetration rocket2
				if ( _super_rearm ) then
				{
					_wpn = RAR(SYG_HK417_WPN_SET_STD);
				}
				else
				{
//					_wpn = RAR(SYG_HK416_WPN_SET_STD);
					_wpn = RAR(SYG_ORDINAL_WPNSET_SD);
#ifdef __DEBUG_SYG_rearmSabotage__
    				hint localize format["+++ SYG_rearmSabotage _wpn %1 (%2)", _wpn, SYG_ORDINAL_WPNSET_SD];
#endif
				};
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 3]] + [["ACE_PipeBomb"],[_smoke_grenade]];
			};
			case "ACE_SoldierWDemo_A": // TODO: add WOB with 2 "ACE_PipeBomb"
			{
				_equip = _equip + [["P", "ACE_M136", "ACE_AT4_HP", 3]]; // average launcher+ high penetration rocket
//				_wpn = RAR(SYG_HK416_WPN_SET_STD);
				_wpn = RAR(SYG_ORDINAL_WPNSET_SD);
#ifdef __DEBUG_SYG_rearmSabotage__
   				hint localize format["+++ SYG_rearmSabotage _wpn %1 (%2)", _wpn,SYG_ORDINAL_WPNSET_SD];
#endif
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 3]] + [["ACE_PipeBomb"],[_smoke_grenade]]; // special mine
			};
			case "ACE_SoldierWAA": // TODO: add ACE rucksack with 1 "ACE_Stinger"
			{
				_equip = _equip + [["P", "ACE_FIM92A", "ACE_Stinger"]]; // AA missile launcher
				if (_super_rearm) then
				{
					_wpn = RAR(SYG_M16_WPN_SET_ALL_OPTICS);
				}
				else
				{
					if (_adv_rearm ) then
					{
						_wpn = RAR(SYG_M16_WPN_SET_STD);
					}
					else
					{
//						_wpn = RAR(SYG_HK416_WPN_SET_STD);
    					_wpn = RAR(SYG_ORDINAL_WPNSET_SD);
#ifdef __DEBUG_SYG_rearmSabotage__
        				hint localize format["+++ SYG_rearmSabotage _wpn %1 (%2)", _wpn,SYG_ORDINAL_WPNSET_SD];
#endif
					};
				};
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 4]] + [[_smoke_grenade,2]];
			};
			case "ACE_SoldierWDemo_USSF_LRSD": // TODO: add ACE rucksack with 1 "ACE_PipeBomb"
			{
				_equip = _equip + [["P", "ACE_M136", "ACE_AT4_HP",2]]; // average launcher + high penetration rocket
				if ( _adv_rearm ) then
				{
					_wpn = RAR(SYG_HK417_WPN_SET_STD);
				}
				else
				{
//					_wpn = RAR(SYG_HK416_WPN_SET_STD_SD);
					_wpn = RAR(SYG_ORDINAL_WPNSET_SD);
#ifdef __DEBUG_SYG_rearmSabotage__
       				hint localize format["+++ SYG_rearmSabotage _wpn %1 (%2)", _wpn,SYG_ORDINAL_WPNSET_SD];
#endif
				};
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 3]] +	[[_smoke_grenade],["ACE_Claymore_M"], ["ACE_PipeBomb"]]; // special mine
			};
			case "ACE_SoldierWDemo_USSF_ST": // TODO: add ACE rucksack with 2 "ACE_PipeBomb"
			{
				_equip = _equip + [["P", "ACE_M136", "ACE_AT4_HP", 2]]; // average launcher + high penetration rocket
//				_wpn = RAR(SYG_HK416_WPN_SET_STD);
				_wpn = RAR(SYG_ORDINAL_WPNSET_SD);
#ifdef __DEBUG_SYG_rearmSabotage__
  				hint localize format["+++ SYG_rearmSabotage _wpn %1 (%2)", _wpn,SYG_ORDINAL_WPNSET_SD];
#endif
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 4]] + [["ACE_PipeBomb"],[_smoke_grenade,2]]; // special equipment
			};
			default {
			 /* player globalChat format["unit %1 not detected", _unit_type]; */
			 _ret = false; };
		};
		//player globalChat format["unit %1, prob %2, adv prob %3, rnd %4, equip %5", _unit_type, _prob, _adv_rearm, _rnd, _equip];

		if ( _ret ) then
		{
			_ret = [_unit,_equip] call SYG_armUnit;
			if (!(_unit hasWeapon "NVGoggles")) then {	_unit addWeapon "NVGoggles"; };
			//if (!(_unit hasWeapon "Binocular")) then {	_unit addWeapon "Binocular"; };
		}
		else{ hint localize format["+++ SYG_rearmSabotage full rearming falied due to unknown soldier type %1", _unit_type]; };
	}
	else // AI is not rearmed (used standart equipment)
	{
		/*
			men to replace some weapons:
			"ACE_SquadLeaderW_A": nothing to replace (leader has no bombs)
			"ACE_SoldierWDemo_A": "ACE_Claymore_M", "ACE_TimeBomb"
			<no such man: "ACE_SoldierWDemo_R": "ACE_Claymore_M">
			<no such man "ACE_SoldierWDemo_USSF_FID": "ACE_Claymore_M", "ACE_Claymore_M">
			"ACE_SoldierWDemo_USSF_LRSD": "ACE_Claymore_M", "ACE_Claymore_M"
			"ACE_SoldierWDemo_USSF_ST": "ACE_Claymore_M", "ACE_Claymore_M"
		*/
#ifdef __DEBUG_SYG_rearmSabotage__
	    hint localize format["+++ SYG_rearmSabotage do partial rearming"];
#endif
		private ["_removeMags","_removeWpn","_addWpn","_addMags"];
		_removeMags   = []; // remove mags
		_removeWpn    = ""; // remove weapon
		_addWpn       = []; // add weapons
		_addMags      = []; // add mags
		switch (_unit_type) do
		{
			case "ACE_SquadLeaderW_A": {_removeMags = ["ACE_SmokeGrenade_White"]; _addWpn = ["ACE_M136"]; _addMags = ["ACE_AT4_HP",_smoke_grenade];}; // He has 2 empty slots!!!
			case "ACE_SoldierWDemo_A":  {_removeMags = ["ACE_TimeBomb"]; _addWpn = ["ACE_M136"]; _addMags = ["ACE_PipeBomb", "ACE_AT4_HP"];};
			case "ACE_SoldierWDemo_USSF_LRSD":  {_removeMags = ["ACE_Claymore_M"]; _addWpn = ["ACE_M136"]; _addMags = ["ACE_PipeBomb", "ACE_AT4_HP"];};
			case "ACE_SoldierWDemo_USSF_ST":  {_removeMags = ["ACE_Claymore_M"]; _addWpn = ["ACE_M136"]; _addMags = ["ACE_PipeBomb", "ACE_AT4_HP"];};
			case "ACE_SoldierWMAT_A":
			{
			    _removeWpn = "ACE_M136";
			    _removeMags = ["ACE_AT4_HEAT","ACE_30Rnd_556x45_B_Stanag","ACE_30Rnd_556x45_B_Stanag","ACE_30Rnd_556x45_B_Stanag","ACE_30Rnd_556x45_B_Stanag"];
			    _addWpn = ["ACE_M136"];
			    _addMags = ["ACE_AT4_HP", "ACE_AT4_HP", "ACE_AT4_HP"];
			};
			default {   hint localize format["+++ SYG_rearmSabotage partial rearming failed due unknown soldier type %1",_unit_type ];};
		};

        { _unit removeMagazine _x; } forEach _removeMags;
		if ( _removeWpn != "") then { _unit removeWeapon _removeWpn; };
        { _unit addMagazine _x; } forEach _addMags;
        { _unit addWeapon _x; } forEach _addWpn;

		_ret = true;
		//	player globalChat format["unit %1, prob %2, adv prob %3, rnd %4, NOT rearmed", _unit_type, _prob, _adv_rearm, _rnd]
	};
   	// remove useless binocular from inventory
    if (_unit hasWeapon "Binocular") then {_unit removeWeapon "Binocular"}; // remove this bad device
	_ret
};

//
// Rearms sabotage group with std probablity
//
// call: _res = [_unit1,... , _unitN] call SYG_rearmSabotageGroup;
//
SYG_rearmSabotageGroup = {
	private ["_cnt"];
	_cnt = 0;
	switch typeName _this do
	{
		case "ARRAY": { { if (_x call SYG_rearmSabotage) then {_cnt = _cnt + 1; } } forEach _this };
		case "GROUP": { { if (_x call SYG_rearmSabotage) then {_cnt = _cnt + 1; } } forEach units _this };
		case "OBJECT": { if (_x call SYG_rearmSabotage) then {_cnt = _cnt + 1; } };
		default {hint localize format["--- SYG_rearmSabotageGroup: Expected _this (%1) is illegal",typeName _this]};
	};
	_cnt
};


/**
 * Rearms unit if he is known to this code
 * List of units, used in ACE Sahrani Domination and known to this function:
 * ["ACE_SoldierWSniper2_A","ACE_USMC8541A1A","ACE_SoldierWMAT_USSF_ST_BDUL","ACE_SoldierWAA","ACE_SoldierWB_USSF_ST_BDUL","ACE_SoldierW_Spotter_A","ACE_SoldierWMedic_A","ACE_SoldierWAT2_A"]
 * Returns: true if success, else false. F.e. if unit not known to function
 * calls as:
 *      _res = [_unit<,_rearm_probability<,_advanced_probability>] call SYG_rearmSpecops;
 *      _res = _unit call SYG_rearmSpecops;
 * params:
 *   _unit: unit to rearm with new weapon
 *   _rearm_probability: probabilty to reard unit. Optional. Default 0.5. Range 0.0 <-> 1.0
 *   _advanced_probability: probability to ream unit with advanced weapon. Must be < _ordinal_probability. Optional.
 *    Default 0.1. Range 0.0 <-> 1.0
 */
#define __SYG_rearmSpecops_DEBUG__

SYG_rearmSpecops = {

    private ["_unit","_unit_type","_prob","_adv_rearm","_super_rearm","_rnd","_equip", "_ret","_wpn","_smoke_grenade"];
	if ( typeName _this == "ARRAY" ) then // [_unit<, prob1<, prob2>>] call
	{
		_unit = arg(0);
		_unit_type = typeOf _unit;
		_prob = argopt(1, 0.5);
		_adv_rearm = argopt(2, 0.1); // do advanced rearming
	}
	else	// _this call
	{
		_unit = _this;
		_unit_type = typeOf _this;
		_prob = 0.5;
		_adv_rearm = 0.1;
	};
	_ret = false;
	_rnd = random 1.0;
	_smoke_grenade = "ACE_SmokeGrenade_Green";
	if ( _rnd < _prob) then  // do ordinal rearming
	{
#ifdef __SYG_rearmSpecops_DEBUG__
        hint localize format["+++ SYG_rearmSabotage: %1 full rearming", _unit_type];
#endif

		_super_rearm = _rnd < (_adv_rearm / 2.0);
		_adv_rearm = _rnd < _adv_rearm; // do advanced rearming  (true) or not (false)
		_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD_NO_GLOCK)] + SYG_STD_MEDICAL_SET;
		_ret = true;
		switch (_unit_type) do
		{
			case "ACE_SoldierWSniper2_A": // M21
			{
				_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD_SD)] + SYG_STD_MEDICAL_SET;
				if ( _adv_rearm ) then
				{
					_wpn = RAR(SYG_SCARH_WPN_SET_SNIPER);
				}
				else
				{
					_wpn = RAR(SYG_M21_WPN_SET + SYG_SCARL_WPN_SET_SNIPER + SYG_SCARL_WPN_SET_SNIPER_SD);
				};
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 9]];
				_equip = _equip + [[_smoke_grenade],["ACE_HandGrenadeTimed",2]];
			};

			case "ACE_USMC8541A1A": // M40A3
			{
				_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD_SD)] + SYG_STD_MEDICAL_SET;
				if ( _adv_rearm ) then
				{
					_wpn = RAR(SYG_M110_WPN_SET_WHOLE);
				}
				else
				{
					_wpn = RAR(SYG_M24_WPN_SET);
				};
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 9]];
				_equip = _equip + [[_smoke_grenade],["ACE_HandGrenadeTimed",2]];
			};

			case "ACE_SoldierW_Spotter_A":
			{
				_equip =  _equip + [["P","ACE_ANPRC77_Alice"], ["P","LaserDesignator"]] ;
				if ( _adv_rearm ) then
				{
				    _wpn = ([SYG_SCARH_WPN_SET_STD_OPTICS, SYG_SCARL_WPN_SET_STD_OPTICS, SYG_SCARH_WPN_SET_STD, SYG_G36_WPN_SET_STD] call XfRandomArrayVal) call XfRandomArrayVal;
				}
				else { _wpn = RAR(SYG_HK417_WPN_SET_STD_OPTICS); };
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 9]] + [[_smoke_grenade,2],["LaserBatteries"]];
			};

		    case "ACE_TeamLeaderW_USSF_ST_DCUL"; // leader, arms as a lower soldier
			case "ACE_SoldierWB_USSF_ST_BDUL":
			{
				if ( _adv_rearm ) then
				{
					_equip = _equip + [["P", "ACE_M72", "ACE_LAW_HP", 1]]; // small launcher
					_wpn = RAR(SYG_SCARH_WPN_SET_STD);
				}
				else
				{
					_equip = _equip + [["P", "ACE_M72", "ACE_LAW_HEAT", 1]]; // small launcher
					_wpn = RAR(SYG_SCARL_WPN_SET_STD_OPTICS);
				};
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 7]];
				_equip = _equip + [[_smoke_grenade,1],["ACE_HandGrenadeTimed",2]];
			};

			case "ACE_SoldierWAA":
			{
				_equip = _equip + [["P", "ACE_FIM92A", "ACE_Stinger"]]; // AA missile launcher
				if ( _adv_rearm ) then
				{
					_wpn = RAR(SYG_SCARH_WPN_SET_STD);
				}
				else
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD);
				};
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 6]];
			};

			case "ACE_SoldierWAT2_A":
			{
				_equip = _equip + [["P", "ACE_Dragon", "ACE_Dragon"]]; // AT missile launcher
				if ( _adv_rearm ) then
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD);
				}
				else
				{
					_wpn = RAR(SYG_HK417_WPN_SET_STD);
				};
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 6]] + [[_smoke_grenade,2]];
			};

#ifdef __JAVELIN__
			case "ACE_SoldierWHAT_A": // Javelin specialist
			{
				_equip = _equip + [["P", "ACE_Javelin", "ACE_Javelin"]]; // AT missile launcher
				if ( _adv_rearm ) then
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD);
				}
				else
				{
					_wpn = RAR(SYG_HK417_WPN_SET_STD);
				};
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 5]] + [[_smoke_grenade,1]];
			};
#endif

			case "ACE_SoldierWMAT_USSF_ST_BDUL":
			{
				if ( _adv_rearm ) then
				{
					if ( _super_rearm ) then
					{
						_equip = _equip + [["P", "ACE_M136", "ACE_AT4_HP", 2]]; // average launcher + high penetration rocket
					}
					else
					{
						_equip = _equip + [["P", "ACE_M72", "ACE_LAW_HP", 2]]; // small launcher + high penetration rocket
					};
					_wpn = RAR(SYG_SCARL_WPN_SET_STD_OPTICS);
				}
				else
				{
					_equip = _equip + [["P", "ACE_M72", "ACE_LAW_HEAT", 2]]; // small launcher ACE LAW
					_wpn = RAR(SYG_SCARL_WPN_SET_STD_OPTICS);
				};
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 7]] + [[_smoke_grenade,1]];
			};

			case "ACE_SoldierWMedic_A":
			{
				_equip = SYG_MEDIC_SET + [[_smoke_grenade,2]];
				if ( _adv_rearm ) then
				{
					_wpn = RAR(SYG_HK417_WPN_SET_STD);
				}
				else
				{
					_wpn = RAR(SYG_ORDINAL_WPNSET_SD);
				};
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 8]];
				//player globalChat format["Medic equipped: %1", _equip];
			};

			default {  hint localize format["--- SYG_rearmSpecops: unit %1 not detected", _unit_type];  _ret = false; };
		};
		//player globalChat format["unit %1, prob %2, adv prob %3, rnd %4, equip %5", _unit_type, _prob, _adv_rearm, _rnd, _equip];

		if ( _ret ) then
		{
			_ret = [_unit,_equip] call SYG_armUnit;
		};
	};
    if (!_ret) then
    {
#ifdef __ALLOW_SHOTGUNS__
        private ["_mags"];
        switch (_unit_type) do
        {
            case "ACE_TeamLeaderW_USSF_ST_DCUL";
            case "ACE_SoldierWB_USSF_ST_BDUL";
            case "ACE_SoldierWG_R";
            case "ACE_SoldierWMAT_USSF_ST_BDUL":
            {
                // average launcher + high penetration rocket
                _equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD_NO_GLOCK)] +
                SYG_STD_MEDICAL_SET + [[_smoke_grenade,1]] +
                [["P", "ACE_M136", "ACE_AT4_HP", 2]];
                _wpn = RAR(SYG_SHOTGUN_SET);
                if ( _wpn == "ACE_SPAS12" ) then
                    { _mags = RAR(SYG_SHOTGUN_AMMO9) }
                else
                    { _mags = RAR(SYG_SHOTGUN_AMMO8) };
                _equip = _equip + [["P", _wpn, _mags, 7]];
#ifdef __SYG_rearmSpecops_DEBUG__
                hint localize format["+++ SYG_rearmSpecops: %1 rearmed with shotgun %2", _unit_type, _wpn ];
#endif
                _ret = [_unit,_equip] call SYG_armUnit;
            };
            default {};
        };
#endif
    };

    if (!(_unit hasWeapon "NVGoggles")) then {	_unit addWeapon "NVGoggles"; };
	// remove useless binocular from inventory
    if (_unit hasWeapon "Binocular") then {_unit removeWeapon "Binocular"};
	_ret
};

//
// Rearms specops group with std probablity
//
// call: _res = [_unit1,... , _unitN] call SYG_rearmSpecopsGroup; // array of units from specops list (see in according source files)
//   or
// call: _res = _unit call SYG_rearmSpecopsGroup; // single unit
//   or
// call: _res = _group call SYG_rearmSpecopsGroup; // group to rearm
//
// returned value will be the same: number of rearmed units
//
SYG_rearmSpecopsGroup = {
	private ["_cnt"];
	_cnt = 0;
	switch typeName _this do
	{
		case "ARRAY": { { if (_x call SYG_rearmSpecops) then {_cnt = _cnt + 1; } } forEach _this };
		case "GROUP": { { if (_x call SYG_rearmSpecops) then {_cnt = _cnt + 1; } } forEach (units _this) };
		case "OBJECT": { if (_this call SYG_rearmSpecops) then {_cnt = _cnt + 1; } };
		default {hint localize format["SYG_rearmSpecopsGroup: typeName _this %1 illegal",typeName _this]};
	};
	_cnt
};
/**
 *
 * Special call format for group with non-standard rearm probability
 * call: _ret = [_units_arr, _rearm_prob, _adv_rearm_prob ] call SYG_rearmSpecopsGroupA;
 *
 */
SYG_rearmSpecopsGroupA = {
	private ["_cnt","_units","_prob","_aprob"];
	_units = arg(0); // array of separate units
	_prob  = arg(1); // simple rearm probability
	_aprob = arg(2); // advanced ream probability
	_cnt  = 0;
	{
		if ( [_x,_prob,_aprob] call SYG_rearmSpecops ) then {_cnt = _cnt + 1;};
	} forEach _units;
	_cnt
};

/**
 * SYG_BASIC_WEST = ["ACE_SoldierWMG_A","ACE_SoldierWAR_A","ACE_SoldierWSniper_A","ACE_SoldierWMAT_A","ACE_SoldierWAA","ACE_SoldierWAT2_A","ACE_SoldierWMedic_A","ACE_SoldierWG","ACE_SoldierW_HMG","ACE_SoldierW_HMGAG","ACE_SoldierWMiner","ACE_SoldierWB_A","ACE_SoldierW_HMGAB"];
 *
 * Rearms basic unit so that only mashingunners and snipers are concerned
 * Returns: true if success, else false. F.e. if unit not known to function
 * call: _res = [_unit<,_rearm_probability<,_advanced_probability>] call SYG_rearmBasic;
 * or:   _res = _unit call SYG_rearmBasic;
 * params:
 *   _unit: unit to rearm with new weapon
 *   _rearm_probability: probabilty to reard unit. Optional. Default 0.5. Range 0.0 <-> 1.0
 *   _advanced_probability: probability to ream unit with advanced weapon. Must be < _ordinal_probability. Optional.
 *    Default 0.1. Range 0.0 <-> 1.0
 */
SYG_rearmBasic = {
	private ["_unit","_prob","_adv_rearm","_super_rearm","_ret","_rnd","_wpn","_equip","_i","_smoke_grenade","_magnum"];
	if ( typeName _this == "ARRAY" ) then // [_unit<, prob1<, prob2>>] call
	{
		_unit = arg(0);
		_prob = argopt(1, 0.5);
		_adv_rearm = argopt(2, 0.1); // do advanced rearming
	}
	else	// _this call
	{
		_unit = _this;
		_prob = 0.5;
		_adv_rearm = 0.1;
	};
	_ret = false;
	_rnd = random 1.0;
	_smoke_grenade= "ACE_SmokeGrenade_White";
	//_probArr = _probArr + [format["%1%2:%3;",typeOf _unit, (typeOf _unit) isKindOf "SoldierWMG",  round(_rnd * 100) / 100]];
	if ( _rnd < _prob ) then
	{
		//_super_rearm = _rnd < (_adv_rearm / 2.0);
		_adv_rearm = _rnd < _adv_rearm;
		scopeName "main";
		_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD_NO_GLOCK)] + SYG_STD_MEDICAL_SET;
		for "_i" from 0 to 0 do
		{
			if ( (typeOf _unit) isKindOf "SoldierWMG" ) then // M240
			{ 	// rearm with some special kind of M240
				_wpn = if ( _adv_rearm ) then  {"ACE_M240G_M145"} else {"ACE_M240G"};
				//_probArr = _probArr + [format["%1:%2:%3;",typeOf _unit, round(_rnd * 100) / 100, _wpn]];
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 3]] + [[_smoke_grenade],["ACE_HandGrenadeTimed",2]];
				_ret = true;
				breakTo "main";
			}; // "SoldierWMG"

			if ( (typeOf _unit) isKindOf "SoldierWAR" ) then  // M249
			{	// rearm with some special kind of M249
				_wpn = if ( _adv_rearm ) then {"ACE_M249Para_M145"} else {"ACE_M249Para"};
				//_probArr = _probArr + [format["%1:%2:%3;",typeOf _unit, round(_rnd * 100) / 100, _wpn]];
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 3]] + [[_smoke_grenade],["ACE_HandGrenadeTimed",2]];
				_ret = true;
				breakTo "main";
			}; // "SoldierWAR"

			if ( (typeOf _unit) == "ACE_SoldierWSniper_A" ) then  // M24-M40
			{	// rearm with some special kind of M24-M40
				_magnum = 9;
				if ( _adv_rearm ) then  { _wpn = SYG_M110_WPN_SET/* + SYG_M110_WPN_SET_SD*/; _wpn = RAR(_wpn); } else { _wpn = RAR(SYG_M24_WPN_SET);};
				//_probArr = _probArr + [format["%1:%2:%3;",typeOf _unit, round(_rnd * 100) / 100, _wpn]];
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 9]] + [[_smoke_grenade],["ACE_HandGrenadeTimed",2]];
				_ret = true;
				breakTo "main";
			}; //"ACE_SoldierWSniper_A"

			if ( (typeOf _unit) == "ACE_SoldierWMAT_A" ) then  // M136
			{	// rearm with some special kind of m136/M72
				if (_adv_rearm ) then
				{
					_equip = _equip + [["P", "ACE_M136", "ACE_AT4_HP", 2]]; // average launcher + high penetration rocket ACE_AT4_HP
//					_equip = _equip + [["P", "ACE_M72", "ACE_LAW_HP", 2]]; // small launcher+ high penetration rocket
				}
				else
				{
					_equip = _equip + [["P", "ACE_M136", "ACE_AT4_HEAT", 2]]; // average launcher + high penetration rocket ACE_AT4_HEAT
//					_equip = _equip + [["P", "ACE_M72", "ACE_LAW_HEAT", 2]]; // small launcher
				};
				_wpn = RAR(SYG_HK416_WPN_SET_STD);
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 7]] + [[_smoke_grenade]];
				_ret = true;
				breakTo "main";
			}; // "ACE_SoldierWMAT_A"

			if ( (typeOf _unit) == "ACE_SoldierWAT2_A" ) then  // Dragon
			{	// rearm with Dragon
				_equip = _equip + [["P", "ACE_Dragon", "ACE_Dragon"]]; // AT missile launcher
				if ( _adv_rearm ) then
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD);
				}
				else
				{
					_wpn = RAR(SYG_HK416_WPN_SET_STD);
				};
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 7]] + [[_smoke_grenade]];
				_ret = true;
				breakTo "main";
			};

#ifdef __JAVELIN__
			if ( (typeOf _unit) == "ACE_SoldierWHAT_A" ) then  // Javelin
			{
				_equip = _equip + [["P", "ACE_Javelin", "ACE_Javelin"]]; // AT missile launcher
				if ( _adv_rearm ) then
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD);
				}
				else
				{
					_wpn = RAR(SYG_HK416_WPN_SET_STD);
				};
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 5]] + [[_smoke_grenade]];
				_ret = true;
				breakTo "main";
			};
#endif

		};
		if ( _ret )  then
		{
//			_equip = _equip + [["P",_wpn, _wpn call SYG_defaultMagazine,_magnum],[_smoke_grenade],["ACE_HandGrenadeTimed",2]];
			_ret = [_unit,_equip] call SYG_armUnit;
			if (!(_unit hasWeapon "NVGoggles")) then {_unit addWeapon "NVGoggles"};
		};
	};
    // remove useless binocular from inventory
    if (_unit hasWeapon "Binocular") then {_unit removeWeapon "Binocular"};
	_ret
};

//
// Rearms basic group with std probability
//
// call: _res = [_unit1,... , _unitN] call SYG_rearmBasicGroup;
//
SYG_rearmBasicGroup = {
	private ["_cnt"];
	_cnt = 0;
	switch typeName _this do
	{
		case "ARRAY": { { if (_x call SYG_rearmBasic) then {_cnt = _cnt + 1; } } forEach _this };
		case "GROUP": { { if (_x call SYG_rearmBasic) then {_cnt = _cnt + 1; } } forEach units _this };
		case "OBJECT": { if (_x call SYG_rearmBasic) then {_cnt = _cnt + 1; } };
		default {hint localize format["SYG_rearmBasicGroup: typeName _this %1 illegal",typeName _this]};
	};
	_cnt
};

// Spotter
SYG_rearmSpotter = {
	private ["_unit","_prob","_adv_rearm","_rnd","_equip", "_wpn"];
	if ( typeName _this == "ARRAY" ) then // [_unit<, prob1<, prob2>>] call
	{
		_unit = arg(0);
		_prob = argopt(1,0.666);
		_adv_rearm = argopt(2,0.333); // do advanced rearming
	}
	else	// _this call
	{
		_unit = _this;
		_prob = 0.666;
		_adv_rearm = 0.333;
	};
	_rnd = random 1.0;
    if (_unit hasWeapon "Binocular") then {_unit removeWeapon "Binocular"};

	if ( _rnd < _prob) then  // do ordinal rearming
	{
		_adv_rearm = _rnd < _adv_rearm; // do advanced rearming  (true) or not (false)
		_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD)] + SYG_STD_MEDICAL_SET;
		_equip =  _equip + [["P","ACE_ANPRC77_Alice"], ["P","LaserDesignator"]] ;
		if ( _adv_rearm ) then
		{
			switch ( floor(random 4)) do
			{
				case 0:
				{
					_wpn = RAR(SYG_SCARH_WPN_SET_STD_OPTICS);
				};
				case 1:
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD_OPTICS);
				};
				case 2:
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD_OPTICS);
				};
				case 3:
				{
					_wpn = RAR(SYG_SCARH_WPN_SET_STD_OPTICS);
				};
			};
		}
		else { _wpn = RAR(SYG_SCARL_WPN_SET_STD_OPTICS); };
		_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 9]] + [["ACE_SmokeGrenade_Yellow",2],["LaserBatteries"]];
		[_unit,_equip] call SYG_armUnit;
		if (!(_unit hasWeapon "NVGoggles")) then {_unit addWeapon "NVGoggles"};
		true
	}
	else {false};
};

// Governor: let him be a very bad boy
SYG_rearmGovernor = {
	private ["_unit","_prob","_adv_rearm","_rnd","_equip", "_wpn","_magnum"];
	if ( typeName _this == "ARRAY" ) then // [_unit<, prob1<, prob2>>] call
	{
		_unit = arg(0);
		_prob = argopt(1,1.0);
		_adv_rearm = argopt(2,0.95); // do advanced rearming
	}
	else	// _this call
	{
		_unit = _this;
		_prob = 1.0;
		_adv_rearm = 0.95;
	};
	_rnd = random 1.0;
	_magnum = 10;
	if ( _rnd < _prob ) then  // do ordinal rearming
	{
//		_adv_rearm = _rnd < _adv_rearm; // do advanced rearming  (true) or not (false)
		_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD_GLOCK)] + SYG_STD_MEDICAL_SET;
        switch (floor (random 4)) do
        {
            case 0;
            case 1: {_wpn = RAR(SYG_M14_WPN_SET_WHOLE);};
            case 2: {_wpn = RAR(SYG_G36_WHOLE);};
            case 3: {"ACE_MG36"; _magnum = 5;};
        };
		_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, _magnum],["ACE_SmokeGrenade_Yellow",2]];
		[_unit,_equip] call SYG_armUnit;
		if (!(_unit hasWeapon "NVGoggles")) then {_unit addWeapon "NVGoggles"};
        // remove useless binocular from inventory
        if (_unit hasWeapon "Binocular") then {_unit removeWeapon "Binocular"};

		true
	}
	else
	{
        // remove useless binocular from inventory
        if (_unit hasWeapon "Binocular") then {_unit removeWeapon "Binocular"};
        false
	};
};

// Heavy sniper
// call: _ret = _unit call SYG_rearmHeavySniper;
SYG_rearmHeavySniper = {
	private ["_unit","_prob","_rnd","_equip", "_wpn"];
	if ( typeName _this == "ARRAY" ) then // [_unit<, prob>] call
	{
		_unit = arg(0);
		_prob = argopt(1,1.0);
	}
	else	// _this call
	{
		_unit = _this;
		_prob = 1.0;
	};
    if (_unit hasWeapon "Binocular") then {_unit removeWeapon "Binocular"};
	_rnd = random 1.0;
	if ( _rnd < _prob ) then  // do ordinal rearming
	{
		_wpn = RAR(SYG_HEAVYSNIPER_WPN_SET);
		_mag = RAR(_wpn select 1);
		_wpn = _wpn select 0;
		_equip = SYG_STD_MEDICAL_SET + [RAR(SYG_PISTOL_WPN_SET_WEST_STD_SD),["P", _wpn,_mag, 8],["ACE_SmokeGrenade_Yellow",2],["ACE_HandGrenade",2]];
		[_unit,_equip] call SYG_armUnit;
		if (!(_unit hasWeapon "NVGoggles")) then {_unit addWeapon "NVGoggles"};
		true
	}
	else {false};
};

//
// Function for sidemissions to use heavy sniper in some of them (with suitable locality)
//
// call as: _rearm_cnt = [_pos<, _dist<, _num>>] call SYG_rearmAsheavySniper'
// _dist is in range 50..500, default 200
// _num >= 1, default 1
//
SYG_rearmAroundAsHeavySniper = {
    private ["_pos","_dist","_num","_cnt","_str"];
	if ( typeName _this != "ARRAY") exitWith { hint localize format["--- SYG_rearmAsHeavySniper: expected _this != ARRAY (%1)",_this] ;-1};
	_pos  = arg(0);
	_dist = argopt(1,200);
	_dist = (_dist max 50) min 500;
	_num  = argopt(2,1) max 1;
	_cnt = 0;
	_list = _pos nearObjects ["SoldierWSniper", _dist];
	{
		if ((alive _x) && ((damage _x) < 0.01)) then
		{
			if (_x call SYG_rearmHeavySniper ) then
			{
			    sleep 0.1;
#ifdef __DEBUG__
                _list = _pos nearObjects ["SoldierWSniper", _dist];
                _str = "";
                {
                    _str = _str + format["%1,", weapons _x];
                } forEach _list;
			    hint localize format["SYG_rearmAsHeavySniper: sniper armed with %1, list of men filtered %2 with weapons %3", weapons _x, count _list, _str];
#endif
			    _cnt = _cnt + 1;
			};
		};
		if ( _cnt >= _num ) exitWith
		{
		    true
		};
	} forEach _list;
	SM_HeavySniperCnt = _cnt;
	publicVariable "SM_HeavySniperCnt";
	_cnt
};


//
// Some officer with M14
//
// call:
//        _ret = _unit call SYG_rearmM14;
// or call:
//        _ret = [_unit<,prob<,weapon_list>> call SYG_rearmM14;
//
// Where: prob is probability to rearm (< 1.0). Optional, default is 1.0
//        weapon_list is list of user designated M14 list, e.g. SYG_M14_WPN_SET_STD_OPTICS. Optional, default is SYG_M14_WPN_SET_WHOLE
//
SYG_rearmM14 = {
	private ["_unit","_prob","_rnd","_equip", "_wpn","_wplist"];
	if ( typeName _this == "ARRAY" ) then // [_unit<, prob1<, prob2>>] call
	{
		_unit = arg(0);
		_prob = argopt(1,1.0);
		_wplist = argopt(2,SYG_M14_WPN_SET_WHOLE); //
	}
	else	// _this call
	{
		_unit = _this;
		_prob = 1.0;
		_wplist = SYG_M14_WPN_SET_WHOLE; //
	};
	_rnd = random 1.0;
	if ( _rnd < _prob ) then  // do ordinal rearming
	{
		_wpn = RAR(_wplist);
		_equip = SYG_STD_MEDICAL_SET + [RAR(SYG_PISTOL_WPN_SET_WEST_STD_GLOCK),["P", _wpn, _wpn call SYG_defaultMagazine, 9],["ACE_SmokeGrenade_Yellow",1],["ACE_HandGrenade",2]];
		[_unit,_equip] call SYG_armUnit;
		if (!(_unit hasWeapon "NVGoggles")) then {_unit addWeapon "NVGoggles"};
		if (_unit hasWeapon "Binocular") then {_unit removeWeapon "Binocular"};
		true
	}
	else {false};
};

// Some pistolero. Rearm any unit with pistol only
// call: _ret = _unit call SYG_rearmPistolero;
SYG_rearmPistolero = {
	private ["_unit","_prob","_rnd","_equip"];
	if ( typeName _this == "ARRAY" ) then // [_unit<, prob1<, prob2>>] call
	{
		_unit = arg(0);
		_prob = argopt(1,1.0);
	}
	else	// _this call
	{
		_unit = _this;
		_prob = 1.0;
	};
	_rnd = random 1.0;
	if ( _rnd < _prob ) then  // do ordinal rearming
	{
		_equip = SYG_STD_MEDICAL_SET + [RAR(SYG_PISTOL_WPN_SET_WEST_STD_GLOCK),["ACE_SmokeGrenade_Yellow",3],["ACE_HandGrenade",3]];
		[_unit,_equip] call SYG_armUnit;
		if (!(_unit hasWeapon "NVGoggles")) then {_unit addWeapon "NVGoggles"};
		if (_unit hasWeapon "Binocular") then {_unit removeWeapon "Binocular"};
		true
	}
	else {false};
};

SYG_spec1 = ["ACE_20Rnd_762X51_B_M14","ACE_20Rnd_762x51_B_SCAR","ACE_20Rnd_762x51_B_HK417"];
SYG_spec2 = ["ACE_20Rnd_762X51_SB_M14","ACE_20Rnd_762x51_SB_SCAR","ACE_20Rnd_762x51_SB_HK417"];

/*
 * Small routine to find static string in array of string from config file!!!
 * std 'find' Arma method not work here!
 *
 */
SYG_find = {
    private ["_find","_arr","_val","_i"];
    _find = -1;
    _arr = arg(0);
    _val = arg(1);
    for "_i" from 0 to (count _arr) - 1 do
    {
        if (_val == _arr select _i) exitWith {_find = _i;};
    };
    _find
};

/**
 * Returns default magazine type for the designated weapon. ACE magazines are preferrable
 * call: _mag = _wpnType call SYG_defaultMagazine;
 *
 * Where: _wpnType  - class name for the weapon ("ACE_MP5SD" etc)
 */
SYG_defaultMagazine = {
    private ["_arr","_arr1","_mag","_pos"];
	_arr = [];
	_arr1 = _this call SYG_defaultMagazinesACE;
	if ( count _arr1 > 0 ) then // ACE magazines found
	{
		_arr  = _arr1;
	}
	else {_arr = getArray( configFile >> "CfgWeapons" >> _this >> "magazines" );};
	_mag = format["%1",_arr select 0];
	// substitute some types to other ones
	_pos = [SYG_spec1, _mag] call SYG_find;
	if ( _pos >= 0) then { _mag = argp(SYG_spec2,_pos);};
    _mag
};

/**
 * Returns all found ACE magazine type for the designated weapon
 * call: _mags = _wpnType call SYG_defaultMagazinesACE;
 *
 * Where: _wpnType  - class name for the weapon ("ACE_MP5SD" etc)
 */
SYG_defaultMagazinesACE = {
	private ["_arr", "_cnt", "_i"];
	_arr = (getArray ( configFile >> "CfgWeapons" >> _this >> "magazines" ));
	// check magazines visible in game, use special case for ACE_SCAR_H and ACE_M110
	_cnt = 0;
	if ( (count _arr) > 0 ) then
	{
		for "_i" from 0 to (count _arr) - 1 do
		{
			if ( (getNumber ( configFile >> "CfgMagazines" >> (_arr select _i) >> "ACE_HIDE" )) != 0 ) then
			{
				_arr set [_i, "RM_ME"];
				_cnt = _cnt + 1;
			};
		};
	};
	if ( _cnt > 0 ) then {_arr = _arr - ["RM_ME"];};
	_arr
};

/**
 * METOD NOT USED YET
 * Returns filtered array of only ACE magazines from designated input
 * call: _mags = _mags call SYG_filterACEMagazines;
 *
 * Where: _mags  - array with magazines type names ["ACE_5Rnd_127x99_API_AS50", "ACE_64Rnd_9x18_B_Bizon","ACE_17Rnd_9x19_G17"] etc
 */
SYG_filterACEMagazines = {
	private ["_i","_cnt"];
	_cnt = 0;
	if ( (count _this) > 0 ) then
	{
		for "_i" from 0 to (count _this) - 1 do
		{

			if ( (getNumber ( configFile >> "CfgMagazines" >> (_this select _i) >> "ACE_HIDE" )) != 0 ) then
			{
				_this set [_i, "RM_ME"];
				_cnt = _cnt + 1;
			};
		};
	};
	if ( _cnt > 0 ) then {_this = _this - ["RM_ME"];};
	_this
};

/*
 * Returns random equipment list for the WEST pilot
 */
SYG_pilotEquipmentWest = {
//	player globalChat format["item 1: %1, item 2: %2",  _item1, _item2];
	SYG_STD_PILOT_EQUIPMENT + [RANDOM_ARR_ITEM( SYG_SMG_WPN_SET_WEST ), RANDOM_ARR_ITEM( SYG_PISTOL_WPN_SET_WEST ) ]
};

/*
 * Returns random equipment list for the EAST pilot
 */
SYG_pilotEquipmentEast = {
	SYG_STD_PILOT_EQUIPMENT + [ RANDOM_ARR_ITEM(SYG_SMG_WPN_SET_EAST) ] + SYG_PILOT_HANDGUN_EAST
};

//--- METOD NOT USED YET
// M240: Soldier Machine Gunner "SoldierWMG",
// M249: Soldier Automatic Rifleman "SoldierWAR"
SYG_replacePrimaryWeapon = {
	private ["_unit", "_newWpn", "_mag", "_magCnt", "_wpn", "_i", "_muzzles"];
	_unit   = arg(0);
	_newWpn = arg(1);
	_mag    = arg(2);

	_wpn = primaryWeapon _unit;
	if ( _wpn != "" ) then {
		_this removeWeapon _wpn;
		_cmags = _wpn call SYG_getCompatibleMagazines;
		_mags = magazines _unit;
		_magCnt = 0; // count how many primary magazines unit has
		{
			if ( _x in _cmags and _x != _mag) then
				{_magCnt = _magCnt + 1; _unit removeMagazine _x };
		} forEach _mags;
	}
	else
	{
		if ( count _this > 3 ) then { _magCnt = arg(3); };
	};
	//_magCnt = _magCnt max 1; // at last 1 magazine must be present
	if ( _magCnt > 0 ) then
	{
		for "_i" from 1 to _magCnt do { _unit addMagazine _mag }; // add new magazines
	};
	_unit addWeapon _newWpn;
	reload _unit;
	//_unit selectWeapon _newWpn;
	_muzzles = getArray(configFile>>"cfgWeapons" >> _newWpn >> "muzzles");
	_unit selectWeapon (_muzzles select 0);
	_magCnt // return number of magazines added
};

//
// adds binocular to unit
//
SYG_addBinocular = {
    if (_this hasWeapon "Binocular") exitWith {true};
    _this addWeapon "Binocular"
};

//
// remove binocular from unit
//
SYG_removeBinocular = {
    if (_this hasWeapon "Binocular") then { _this removeWeapon "Binocular"; };
    !(_this hasWeapon "Binocular")
};

//
// adds NVGoggles to unit
//
SYG_addNVGoggles = {
    if (_this hasWeapon "NVGoggles") exitWith {true};
    _this addWeapon "NVGoggles";
    _this hasWeapon "NVGoggles"
};

//
// removes NVGoggles from unit
//
SYG_removeNVGoggles = {
    if (_this hasWeapon "NVGoggles") then { _this removeWeapon "NVGoggles"; };
    !(_this hasWeapon "NVGoggles")
};

/*
 * Arms pilot with full ammunition. Work only for real pilot units of WEST and EAST returning true.
 * Other units are not armed and function returns false
 * Call: _res = _unit call SYG_armPilotFull;
 */
SYG_armPilotFull = {
	private [ "_res" ];
	_res = false;
	if ( (_this isKindOf "SoldierWPilot") or ( _this isKindOf "SoldierEPilot")) exitWith
	{
		switch ( side _this ) do
		{
			case east:
			{
				[_this, call SYG_pilotEquipmentEast ] call SYG_armUnit;
				_res = true;
			};
			case west:
			{
				//player globalChat format["%1: %2", typeName _this, call SYG_pilotEquipmentWest];
				[_this, call SYG_pilotEquipmentWest ] call SYG_armUnit;
				_res = true;
			};
		};
	};
	if ( true ) exitWith { _res };
};

/*
 * Arm unit with all equipment at one time
 * Params:
 *         unit : unit to equipment
 *         wpnarr: array of weapons/equipment descriptors. Each descriptor is array of items in follow sequence
 *                  [<<"P"|"S"|"M"|"E",> WPN/EQP name,> MAG name<,MAG num>], where <item> is optional in some cases
 *
 * Example: [_unit, [ ["P", "ACE_MP5A5", "ACE_30Rnd_9x19_B_MP5", 6], ["S", "ACE_Glock18", "ACE_33Rnd_9x19_G18", 4], ["M", "ACE_Bandage", 2], ["M", "ACE_Morphine",2], ["M", "ACE_MON100",2] ] ] call SYG_armUnit
 */
// #define __SYG_armUnit__
SYG_armUnit = {
#ifdef __SYG_armUnit__
    hint localize format["+++ SYG_armUnit(main): %1", _this];
#endif
	private [ "_itemCnt", "_itemType", "_pos", "_i", "_j", "_unit", "_args", "_primWpn", "_wpn", "_magCnt", "_secondWpn",
	"_equipList", "_arr", "_bsetWeapon","_muzzles", "_mag" ];
	if ( typeName _this != "ARRAY" ) exitWith {false};
	_itemCnt = count _this;
	if ( _itemCnt < 1 ) exitWith { hint localize format["+++ SYG_armUnit: Expected number of args >= 1, found %1", _itemCnt]; false };

	_unit = arg(0);
	if ( typeName _unit != "OBJECT") exitWith {hint localize format["--- SYG_armUnit: _this == %1", _this]; false};
	_arr = arg(1); // main array

	if ( (typeName _arr) != "ARRAY" ) exitWith
	{
		hint localize format["--- SYG_armUnit: Expected array of equipment not detected (%1):%2", typeName _arr, _arr];
		false
	};
	_itemCnt = count _arr;
	removeAllWeapons _unit;
	_primWpn = "";
	_secondWpn = "";
	_equipList = [];
	//_wpnList = [];
	if ( _itemCnt > 0 ) then
	{
		for "_i" from 0 to (_itemCnt - 1) do
		{
			_args = _arr select _i; // get _i-th array with item definition (<wpn_type, wpn_name,> mag_name <, mag_count>) to add to unti
			if ( (typeName _args) != "ARRAY" ) exitWith
			{
				hint localize format["--- SYG_armUnit: Item at pos %1 must be ARRAY, found %2 (%3)", _i, typeName _args, _args];
			};
	//		player globalChat format["SYG_armUnit: add %1-th array[%2] = %3", _i, count _args, _args ];
			_pos = 1;
			_magCnt = 0;
			// check 1st item of array, must be string in any case
			if ( (typeName (_args select 0)) != "STRING" ) exitWith
			{
                hint localize format["--- SYG_armUnit: 1st pos must be STRING, found '%1', skipped",  typeName (_args select  0) ];
			};
            switch ( toUpper( _args select 0 ) ) do
            {
                case "P": // Primary weapon, magazines + its optional count  (default 1)
                {
                    if ( _primWpn != "" ) then { _unit addWeapon _primWpn;}; // add previous weapon
                    _primWpn = _args select _pos; _pos = _pos + 1; // accept next weapon
                };

                case "S": // Secondary weapon, magazines + its optional count  (default 1)
                {
                    if ( _secondWpn != "" ) then { _unit addWeapon _secondWpn;}; // add previous weapon
                    _secondWpn = _args select _pos; _pos = _pos + 1;
                };

                case "M"; // Magazine[s], simply skip this character
                {};

                case "E": // special Equipment, binocular etc as the list of equipment ["E", _eqipment_1, _equipment_2, ...]
                {
                    for "_i" from 1 to (count _args - 1) do { _equipList = _equipList + [_args select _i]; _pos = _pos + 1;};
                };

                default { _pos = 0; };
            };
            // it may be magazine sequence in follow form: [... "mag_name", mag_cnt]
            if ( (count _args) > _pos ) then // read remaining items as magazine name and its count
            {
                _mag = _args select _pos;
                _pos = _pos + 1;
                _magCnt = if ( (count _args) > _pos ) then { _args select _pos } else { 1 }; // get number of magazines
                for "_j" from 1 to _magCnt do // adds all requested magazines directly now
                {
                    _unit addMagazine _mag;
                };
            };
		};
	}; // if ( _itemCnt > 0 )
	_bsetWeapon = ""; // weapon to select after adding
	// add some special equipment
	// load equipment
	{
		_unit addWeapon _x;
	} forEach _equipList;

	// add secondary weapon is exists
	if ( _secondWpn != "" ) then
	{
		_bsetWeapon = _secondWpn;
		_unit addWeapon _secondWpn;
	};
	// add primary weapon (if exists) after secondary to allow it to autoload magazine in
	if ( _primWpn != "" ) then
	{
		_bsetWeapon = _primWpn;
		_unit addWeapon _primWpn;
	};
	// now select and reload best weapon in the list
	if ( _bsetWeapon != "" ) then
	{
//		player globalChat format["SYG_armUnit: select/reload %1", _bsetWeapon ];
		//reload _unit;
		_unit selectWeapon _bsetWeapon;
		_muzzles = getArray( configFile>>"cfgWeapons" >> _bsetWeapon >> "muzzles" );
		_unit selectWeapon ( _muzzles select 0 );
	};
	if ( ( count (weapons _unit) == 0 ) && ( count(magazines _unit) == 0 )) exitWith // was not armed, inform developer about it
	{
	    hint localize format["--- SYG_armUnit: %1 can't be armed with %2", typeOf _unit, _arr];
	    false
	};
	true
};

#define  __REARM_FULL__
#ifdef __REARM_FULL__
//
// New version or rearm. It uses new simpler scheme of parameters in array of 2-5 embed arrays:
//
// 1st array is names of weapons/equipments, primary weapon MUST be last in the list to be selected after call
// 2nd array is names of magazines
// 3rd optional array is rucksack name
// 4th optional array is names of rucksack items
// 5th is optional value for player stored view distance, default value is 1500
//
//  _success = [_unit, [ [_wpn1,_wpn2,...,_wpnN], [_mag1, _mag2,..., _magM] <, _rucksack_name <, [_ruck_item_1, ... , _ruck_item_L]><, view_distance>>] ] call SYG_rearmUnit;
//
//  or
//
//  _success = [_unit, _str_arr] call SYG_rearmUnit;
//
// Example:
//
SYG_rearmUnit =
{
	private [ "_unit", "_list", "_mag", "_mags", "_cnt", "_i", "_wpn", "_muzzles", "_ruck", "_ruck_items",
	 "_wpn", "_rifle","_gun", "_sidearm","_vdist"];
	if ( typeName _this != "ARRAY") exitWith { false };
	if ( (count _this) < 2 ) exitWith { false };
    if ( (typeName arg(1)) == "STRING") then
    {
        _this = [arg(0)] + [arg(1) call SYG_equipStr2Arr];
    };
	hint localize format["arr %1", arg(1)];
   	player groupChat format["arr %1", arg(1)];
	_unit = arg(0);
	removeAllWeapons _unit;
	_this = arg(1);
	// at least unit, magazines and weapons are defined
	_list = arg(1); // read magazine list and add them to unit
	{
		// check if it is array: ["MAG_NAME", count]
		if ( typeName _x == "ARRAY") then
		{
			if ( count _x == 2) then
			{
				_mag = argp(_x,0);
				_cnt = argp(_x,1);
				for "_i" from 0 to _cnt - 1 do
				{
					_unit addMagazine _mag;
				};
			};
		}
		else // it is simple "MAG_NAME" item
		{
			if ( typeName _x == "STRING") then
			{
				_unit addMagazine _x;
			};
		};
	} forEach _list;

	// read weapon list and select best in order of value: rifle, gun, pistol
	_list = arg(0);
	_rifle = ""; _sidearm = "";
	{
		if ( typeName _x == "STRING") then
		{
			_unit addWeapon _x;
            switch (_x call SYG_weaponClass) do
            {
                // rifle/gun
                case 1:
                {
                    //hint localize format["SYG_weaponType found rifle %1",_x];
                    _rifle = _x;
                };
                // sidearm
                case 3:
                {
                    //hint localize format["SYG_weaponType found sidearm %1",_x];
                    _sidearm = _x;
                };
            };
		};
	} forEach _list;
	_wpn = "";
    if (_rifle != "" ) then {_wpn = _rifle;}
    else {if (_sidearm != "" ) then {_wpn = _sidearm;};};
    if ( _wpn != "") then
    {
        // select best weapon as primary one
        _unit selectWeapon _wpn;
        _muzzles = getArray( configFile >> "cfgWeapons" >> _wpn >> "muzzles" );
        if ( count _muzzles > 0) then
        {
            _unit selectWeapon ( _muzzles select 0 );
        };
    };

	// add rucksack
	_ruck = argopt(2,"");
	if ( _ruck != "") then
	{
	    if ( typeName _ruck == "STRING" ) then
	    {
	        _unit setVariable [ "ACE_weapononback", _ruck ];
	    };
	};

	// add rucksack items from array of type: [ [MAG_NAME_1,MAG_CNT_1], ... [MAG_NAME_N,MAG_CNT_N] ]
	_ruck_items = argopt( 3, [] );
	if ( typeName _ruck_items == "ARRAY") then
	{
        if ( count _ruck_items > 0) then
        {
            _unit setVariable [ "ACE_Ruckmagazines", _ruck_items ];
        };
	};
	// argopt(4) is value for player stored view distance
	_vdist = argopt(4, 1500);
	//hint localize format["++++++ SYG_rearmUnit: _vdist = %1 +++++++", _vdist];
	_vdist call SYG_setViewDistance;

	// argopt(5) is value for player reborn music play/not play
	_vdist = argopt(5, 0);
	if ( (typeName _vdist == "SCALAR") && (_vdist != d_rebornmusic_index) && (_vdist in [0,1]) ) then {
        d_rebornmusic_index = _vdist;
        _msg = ["STR_REBORN_1","STR_REBORN_0"] select _vdist; // "On", "Off"
        ( format [ "%1 -> %2", localize "STR_SYS_168", localize _msg ] ) call XfGlobalChat;
	};

	true
};
#endif

/**
 * Fills pilot with submachinegun and 6 magazines. Unit MUST be pilot, that is not armed with machinegun
 * Usage:
 *        pilot call SYG_armPilot;
 * Returns: true if pilot detected and equipped, false if equipment for unit not changed
 */
SYG_armPilot = SYG_armPilotFull;

/**
 * Not sure that it is correct function
 * Checks if designated weapon name is sniper one
 *
 * Example: "ACE_M21" call SYG_isSniperRifle; // returns true
 */
SYG_isSniperRifle = {
	[_this, SNIPER_WEAPON_LIST] call SYG_isInList;
	if ( _this == "" ) exitWith { false };
	private ["_str"];
	if ( _this call SYG_isMG ) exitWith {false}; // may be MG with optics
	_str = getText ( configFile >> "CfgWeapons" >> _this >> "modelOptics" );
	(_str != "-") && ( _str != "");
};

SYG_hasOptics = {
	if ( _this == "" ) exitWith { false };
	private ["_str"];
	_str = getText ( configFile >> "CfgWeapons" >> _this >> "modelOptics" );
	(_str != "-") && ( _str != "");
};

/**
 * Checks if designated vehicle (not weapon, it will not work in Arma-1 at least) name is inherited from designated vehicles list
 *
 * Example: [_this,  ["DATSUN_PK1", "HILUX_PK1","LandroverMG"] ] call SYG_isKindOfList;
 */
SYG_isKindOfList = {
	private [ "_name", "_retval"];
	_name = _this select 0;
	_retval = false;
	{
		if ( _name isKindOf _x ) exitWith {_retval = true;};
	} forEach (_this select 1);
	_retval
};

/**
 * Checks if designated weapon name is inherited from designated weapon list
 *
 * Example: ["ACE_Pecheneg_1P29", SNIPER_WEAPON_LIST ] call SYG_isInList; // returns true
 */
SYG_isInList = {
	private [ "_name", "_prev" ,"_retval", "_list"];
	_name = _this select 0;
	if ( _name == "" ) exitWith {false};
	_list = _this select 1;
	_prev = "";
	_retval = false;
	while { true} do
	{
		if (_name == "" ) exitWith {_retval = false;}; // not found rifle parent, it can be not weapon name
		if ( _name == "rifle" ) exitWith { _retval = _prev in _list;}; // found rifle parent, prev must be MG kind or not
		if ( _name in _list) exitWith { _retval = true; };
		_prev = _name;
		_name = configName(  inheritsFrom ( configFile >> "CfgWeapons" >> _name ) );
	};
	_retval
};

//
// checks if unit (_this) has sniper rifle as primary weapon
// Example: _unit call SYG_hasSniperRifle; // return true is unit has some kind of SVD, KSVK, M21, M24, M107 etc
//
SYG_hasSniperRifle =
{
	if (true) exitWith {(primaryWeapon _this) call SYG_isSniperRifle};
//	player globalChat format["SYG_hasSniperRifle test on '%1'", primaryWeapon _this];
};


/**
 * Checks if designated weapon name is MG
 *
 * Example: "ACE_Pecheneg_1P29" call SYG_isSniperRifle; // returns true
 */
SYG_isMG = {
	[_this, MG_WEAPON_LIST] call SYG_isInList;
};

//
// call: _isRadio = (secondaryWeapon player) call isRadio;
//
SYG_isRadio =
{
    //_wpn = secondaryWeapon _unit;
    _this in SYG_RADIO_SET;
};

//
// call: _isRadio = player call asRadio;
//
SYG_hasRadio =
{
    private ["_ret, _wpn, _ruck"];
    _ret = false;
    _wpn = weapons _this;
    _ruck = _this call ACE_Sys_Ruck_FindRuck;
    if (_ruck != "" ) then { _wpn = _wpn + [_ruck]; };

    {
        if  (_x in SYG_RADIO_SET) exitWith {_ret = true;}
    } forEach _wpn;

    _ret
};


//
// call: _wpnCls = "ACE_AKS74U" call SYG_weaponClass; // returns 1
//
// returns:
// -1 on illegal argument (not string, empty or not class)
// 0 of not a weapon, may be gear (map, binocular etc)
// 1 of rifle/gun
// 2 of lancher
// 3 of pistol (side arm)
// 4 of rucksack
SYG_weaponClass = {
	private ["_ret","_class"];
	_ret = -1;
	if ( (typeName _this) != "STRING") exitWith {-1};
	if ( _this == "") exitWith {-1};
	_class = configFile >> "CfgWeapons" >> _this;

//	hint localize format[ "SYG_weaponClass.sqf: %1 has class %2", _this, _class ];

	if (isClass _class) then
	{
	    if ( isNumber(configFile >> "CfgWeapons" >> configName _class >> "ACE_PackSize") ) exitWith
	    {
	        _ret = 4; // Rucksack
	    };
		_ret = 0;
		while { (isClass _class) && (_ret == 0) } do
		{
			switch (configName _class) do
			{
				case "RifleCore":
				{
					_ret = 1;
				};
				case "LauncherCore":
				{
					_ret = 2;
				};
				case "PistolCore":
				{
					_ret = 3;
				};
/*
				case "ACE_Rucksack":
				{
					_ret = 4;
				};
*/
			};
			_class = inheritsFrom _class;
		};
	};
	_ret
};

// returns true if a unit posess only pistol or nothing
SYG_hasOnlyPistol = {
	private ["_ret", "_other_weapon", "_onback", "_weapons","_wob"];
	if ( (typeName _this != "OBJECT") || (! (_this isKindOf "CAManBase")) ) exitWith { false };
	_other_weapon = false;
	_weapons = weapons _this;
	if (format["%1",_this getVariable "ACE_weapononback"] != "<null>") then
	{
		_wob = _this getVariable "ACE_weapononback";
		if (_wob != "" && isClass (configFile >> "cfgWeapons" >> _wob)) then
		{
			_weapons = _weapons + [_wob];
		};
	};

	{
		switch (_x call SYG_weaponClass) do {
			case 1; //: { if (_x != "ACE_MK13") then {_other_weapon = true} };
			case 2: { _other_weapon = true; };
		};
	}forEach (_weapons);
	(!_other_weapon)
};

GRU_allowedNonPistolList = ["ACE_MK13","ACE_M32","ACE_ShotgunBase"];
// returns true if a unit posess only pistol or nothing
// call: _only_pistols = _unit call SYG_hasWeapon4GRUMainTask;
SYG_hasWeapon4GRUMainTask = {
	private ["_ret", "_other_weapon", "_onback", "_weapons","_wob"];
	if ( (typeName _this != "OBJECT") || (! (_this isKindOf "CAManBase")) ) exitWith { false };
	_other_weapon = false;
	_weapons = weapons _this;
	if (format["%1",_this getVariable "ACE_weapononback"] != "<null>") then
	{
		_wob = _this getVariable "ACE_weapononback";
		if (_wob != "" && isClass (configFile >> "cfgWeapons" >> _wob)) then
		{
			_weapons = _weapons + [_wob];
		};
	};

	{
		switch (_x call SYG_weaponClass) do {
			case 1: { if ( !([_x, GRU_allowedNonPistolList] call SYG_isInList) ) then {_other_weapon = true;} };
			case 2: { _other_weapon = true;};
		};
	}forEach (_weapons);
	(!_other_weapon)
};


SYG_isBattleHeli = {
	private ["_type","_ret"];
	_type = typeOf _this;
	if ( ! (_type isKindOf "Helicopter") ) exitWith { false };
	_ret = false;
	{
		if (_type isKindOf _x) exitWith {_ret = true;};
	} forEach ["AH1W","ACE_AH64_AGM_HE","ACE_Mi24","Ka50"];
	_ret
};

// call as:
// _allowed_only = [_unit, ["rks","rfl","smg","pst","rpg","lng"]] call SYG_unitHasOnlyAlloweWeapon;
// where
//       lng for long-muzzle rifle, including sniper and mg
//       rfl stands for normal rifle,
//       smg for submachine gun,
//       pst for pistol,
//       rpg for launcher,
//       rks for rucksack
//
// if unit has any weapon not in allowed litd, function retunds true and false if vice versa
// e.g. call function to unit with AK74 with param [_unit,["rfl"]] will return true and call with [_unit,["pst"]] will return false
//
SYG_unitHasOnlyAllowedWeapon = {
	private ["_unit", "_list", "_other_weapon", "_weapons","_wob"];
	if (typeName _this != "ARRAY")exitWith { false };
	if ( count _this < 2) exitWith { false };
	_unit = arg(0);
	_list = arg(1);
	_other_weapon = false;
	_weapons = weapons _unit;
	if (format["%1",_unit getVariable "ACE_weapononback"] != "<null>") then
	{
		_wob = _unit getVariable "ACE_weapononback";
		if (_wob != "" && isClass (configFile >> "cfgWeapons" >> _wob)) then
		{
			_weapons = _weapons + [_wob];
		};
	};
	if (count _weapons == 0) exitWith {true}; // no weapon - always returns true
	if ( count _list == 0) exitWith {false}; // empty list and has any weapon - always returns false
	hint localize format["SYG_unitHasOnlyAllowedWeapon: wpn %1, list %2", _weapons, _list];

	scopeName "main";
	{
		switch (_x call SYG_weaponClass) do {
			case 1: 	// rifle
			{
				//detect if it is kind of: lng, rfl, smg
				if ( !("lng" in _list) ) then  // no long muzzles in list so check for shorter ones
				{
					// check weapon to be smg
					if ( [_x, SMG_WEAPON_LIST] call SYG_isInList ) then  // smg
					{
						hint localize format["SYG_unitHasOnlyAllowedWeapon: SMG (%1) found",_x];
						if (! (("smg" in _list) || ("rfl" in _list)) ) then
						{
							hint localize format[ "SYG_unitHasOnlyAllowedWeapon: SMG (%1) not allowed", _x ];
							_other_weapon = true; breakTo "main";
						};
					} else
					{
						// may be long muzzle rifle?
						if ( [_x, LONG_MUZZLE_WEAPON_LIST] call SYG_isInList ) then  // long muzzle detected
						{
							hint localize format["SYG_unitHasOnlyAllowedWeapon: LNG (%1) found",_x];
							hint localize format[ "SYG_unitHasOnlyAllowedWeapon: LNG (%1) not allowed", _x ];
							_other_weapon = true; breakTo "main";
						} else // ordinal rifle detected
						{
							hint localize format["SYG_unitHasOnlyAllowedWeapon: RFL (%1) found",_x];
							if (! ("rfl" in _list) ) then
							{
								hint localize format[ "SYG_unitHasOnlyAllowedWeapon: RFL (%1) not allowed", _x ];
								_other_weapon = true; breakTo "main";
							};
						};
					};
				};
			};
			case 2:	// Launcher
			{
				if (! ("rpg" in _list) ) then
				{
					hint localize format[ "SYG_unitHasOnlyAllowedWeapon: LNC (%1) not allowed", _x ];
					_other_weapon = true; breakTo "main";
				};
			};
			case 3:	// Pistol
			{
				if (! ("pst" in _list) ) then
				{
					hint localize format[ "SYG_unitHasOnlyAllowedWeapon: PST (%1) not allowed", _x ];
					_other_weapon = true; breakTo "main";
				};
			};
			case 4:	// Rucksack
			{
				if (! ("rks" in _list) ) then
				{
					hint localize format[ "SYG_unitHasOnlyAllowedWeapon: RKS (%1) not allowed", _x ];
					_other_weapon = true; breakTo "main";
				};
			};
		};
	}forEach (_weapons);

	(!_other_weapon)
};

// return name for excessive weapon or empty string "" if no such weapon detected
// call as:
// _excessive = [_unit, ["rks","rfl","smg","pst","rpg","lng"]] call SYG_unitHasOnlyAlloweWeapon;
// where array of weapons is list of allowed weapons with means as follow:
//       lng for long-muzzle rifle, including sniper and mg,
//       rfl stands for normal rifle,
//       smg for submachine gun,
//       pst for pistol, always allowed in any cases,
//       rpg for launcher, always allowed in any cases,
//       rpg1 for small launcher (RPG-22, M-72), always allowed in any cases,
//       rks for rucksack,
//       rks1 for small rucksack (ALICE OLD)
//
// if unit has any weapon not in allowed litd, function return its name or "" if vice versa
// e.g. call function to unit with AK74 with param [_unit,["rfl"]] will return "" and call with [_unit,["pst"]] return "ACE_AK74"
//
SYG_findExcessiveWeapon = {
	private ["_unit", "_list", "_other_weapon", "_weapons","_wob","_volume"];
	if (typeName _this != "ARRAY") exitWith { "RifleCore" };
	if ( count _this < 2) exitWith { "RifleCore" };
	_unit = arg(0);
	_list = arg(1);
	_other_weapon = "";
	_weapons = weapons _unit;
	if (format["%1",_unit getVariable "ACE_weapononback"] != "<null>") then
	{
		_wob = _unit getVariable "ACE_weapononback";
		if (_wob != "" && isClass (configFile >> "cfgWeapons" >> _wob)) then
		{
			_weapons = _weapons + [_wob];
		};
	};
	if ((count _weapons) == 0) exitWith {""}; // no weapon - always returns ""
	if ( (count _list == 0) ) exitWith { _weapons select 0 }; // empty list - always returns first weapon

	//hint localize format["SYG_findExcessiveWeapon: wpn %1, list %2", _weapons, _list];

	scopeName "main";

	{
		switch (_x call SYG_weaponClass) do {
			case 1: 	// rifle
			{
				//detect if it is kind of: lng, rfl, smg
				if ( !("lng" in _list) ) then  // no long muzzles in list so check for shorter ones
				{
					// check weapon to be smg
					if ( [_x, SMG_WEAPON_LIST] call SYG_isInList ) then  // smg
					{
						//hint localize format["SYG_findExcessiveWeapon: SMG (%1) found",_x];
						if (! (("smg" in _list) || ("rfl" in _list)) ) then
						{
							//hint localize format[ "SYG_findExcessiveWeapon: SMG (%1) not allowed", _x ];
							_other_weapon = _x; breakTo "main";
						};
					} else
					{
						// may be long muzzle rifle?
						if ( [_x, LONG_MUZZLE_WEAPON_LIST] call SYG_isInList ) then  // long muzzle detected
						{
							//hint localize format["SYG_findExcessiveWeapon: LNG (%1) found",_x];
							//hint localize format[ "SYG_findExcessiveWeapon: LNG (%1) not allowed", _x ];
							_other_weapon = _x; breakTo "main";
						} else // ordinal rifle detected
						{
							//hint localize format["SYG_findExcessiveWeapon: RFL (%1) found",_x];
							if (! ("rfl" in _list) ) then
							{
								//hint localize format[ "SYG_findExcessiveWeapon: RFL (%1) not allowed", _x ];
								_other_weapon = _x; breakTo "main";
							};
						};
					};
				};
			};
			case 2:	// Launcher
			{
				if (_x in LIGHT_LAUNCHER_WEAPON_LIST) then
				{
					if (!(("rpg1" in _list) || ("rpg" in _list))) then
					{
						//hint localize format[ "SYG_findExcessiveWeapon: LNC1 (%1) not allowed in list %2", _x, _list ];
						_other_weapon = _x; breakTo "main";
					};
				}else
				{
					if (!("rpg" in _list)) then
					{
						//hint localize format[ "SYG_findExcessiveWeapon: LNC (%1) not allowed in list %2", _x, _list ];
						_other_weapon = _x; breakTo "main";
					};
				};
			};
			case 3:	// Pistol
			{
/* 				if (! ("pst" in _list) ) then
				{
					//hint localize format[ "SYG_findExcessiveWeapon: PST (%1) not allowed", _x ];
					_other_weapon = _x; breakTo "main";
				};
 */			};
			case 4:	// Rucksack
			{
/* 				_volume = getNumber ( configFile >> "CfgWeapons" >> _x >> "ACE_PackSize" );
				//hint localize format[ "SYG_findExcessiveWeapon: volume  == %1", _volume ];
				if ( _volume < 15000) then
				{
					if (! (("rks" in _list) OR ("rks1" in _list))) then
					{
						//hint localize format[ "SYG_findExcessiveWeapon: volume  < 15000, no rks or rks1 in list", _x ];
						_other_weapon = _x; breakTo "main";
					};
				}else
				{
					if (! ("rks" in _list)) then
					{
						_other_weapon = _x; breakTo "main";
					};
				};
 */			};
		};
	}forEach (_weapons);

	_other_weapon
};

// call as:
//         _bulky_weapon = player call SYG_getVecRoleBulkyWeapon;
//
SYG_getVecRoleBulkyWeapon = {
	private ["_vec", "_role_arr", "_driver","_turret",/*"_cargo",*/"_bulky_weapon"];
	_vec = vehicle _this;
	if ( _vec == _this ) exitWith {""};
	if ( _vec isKindOf "Motorcycle")  exitWith {""};
	if ( _vec isKindOf "StaticWeapon" ) exitWith {""};
	if ( _vec isKindOf "ACE_ATV_HondaR" ) exitWith {""};
	if ( _vec isKindOf "Ship" ) exitWith {""};
	if ( _vec isKindOf "Land" ) exitWith {""};

	_role_arr = assignedVehicleRole player;
	//hint localize format["x_playerveccheck.sqf: player assigned as %1 to %2", _role_arr, typeOf _vec];
	if (count _role_arr == 0 ) exitWith {""}; // no role
	if ( (_role_arr select 0) == "Cargo" ) exitWith  {""};
	_driver = false;
	_turret = false;
	//_cargo  = false;
	if ( (_role_arr select 0) == "Driver" ) then  { _driver = true; }
	else { if ( (_role_arr select 0) == "Turret" ) then  { _turret = true; } };
	//else { if ( (_role_arr select 0) == "Cargo" ) then  { _cargo = true; };};};

	// if  (!(_driver || _turret || _cargo)) exitWith { hint localize format["--- SYG_getVecRoleBulkyWeapon: expected role array unknown %1",_role_arr]; "" };

	scopeName "main";
	_bulky_weapon = [];

	while {true} do
	{
		// first add allowed weapon in bulky_weapon array
		//if ( _cargo) exitWith {};
		// check pre-defined vehicles
//		if ( _vec in [HR1,HR2,HR3,HR4] ) exitWith { if (_driver) then {_bulky_weapon = ["smg"];} else {_bulky_weapon = ["rfl","rpg1"];};};
		if ( _vec in [HR1,HR2,HR3,HR4] ) exitWith { if (_driver) then {_bulky_weapon = ["lng"];};}; // Mi-17 transport heli on base
//		if ( _vec in [MRR1,MRR2] ) exitWith { _bulky_weapon = ["rfl","rpg1"];};
//		if (_vec isKindOf "LandVehicle" ) exitWith {_bulky_weapon = ["rfl","rpg1"];};

		if (_vec isKindOf "Air") then {
		    if (!((_vec isKindOf "ParachuteBase") || ( _vec isKindOf "RAS_Parachute"))) then
		    {
                if (_vec isKindOf "Helicopter") then {
                    //["rks","rfl","smg","pst","rpg","lng"]
//                    if (_driver || (_vec call SYG_isBattleHeli) ) then {_bulky_weapon = ["smg"]; breakTo "main";}
                    if (_driver || (_vec call SYG_isBattleHeli) ) then {_bulky_weapon = ["lng"]; breakTo "main";};
                } else {
                    if (_vec isKindOf "Plane") then { _bulky_weapon = ["smg"]; breakTo "main"; };
                };
			};
		};
		if (true) exitWith {};
	};
#ifdef __DEBUG__
	hint localize format["SYG_getVecRoleBulkyWeapon: bulky weapon %1", _bulky_weapon];
#endif
	if ( (count _bulky_weapon) == 0 ) exitWith { "" }; // all is allowed
	[player, _bulky_weapon] call SYG_findExcessiveWeapon;
};

// call: _wpnType = _wpn call SYG_weaponType;
// returns: 6..10 for [Rifle(6),MG(7),SideArm(8),Launcher(9),Explosive(10)] or -1 if not a weapon
SYG_weaponType = {
		private ["_type"];
		_type = getNumber (configFile >> "CfgWeapons" >> _this >> "type");
		// _class = configFile  >> _this;

		switch (_type) do
		{
			//Rifles.
			case 1:
			{
				6
			};

			//Sidearms.
			case 2:
			{
				8
			};

			//Launchers.
			case 4:
			{
				9
			};

			//Machineguns.
			case 5:
			{
				//Check autofire to see this is a machinegun.
				if (getNumber(_entry >> "autoFire") == 1) then
				{
					7
				}
				else
				{
					//Probably a heavy sniper rifle.
					6;
				};
			};

			default
			{
				//Explosives?
				if ((_type % 256) == 0) then
				{
					10
				};
			};
		}
};

//
// checks if unit (_this) has MG as primary weapon
// Example: _unit call SYG_hasMG; // return true is unit has some kind of M240, M249, PK, RPK47, RPK74
//
SYG_hasMG =
{
	if (true) exitWith {(primaryWeapon _this) call SYG_isMG};
//	player globalChat format["hasMG test on '%1'", primaryWeapon _this];
};

 /**
 * Checks if designated weapon name is SMG
 *
 * Example: "ACE_AKS74U_Cobra" call SYG_isSMG; // returns true
 */
SYG_isSMG = {
	[_this, SMG_WEAPON_LIST] call SYG_isInList;
};

SYG_hasSMG =
{
	if (true) exitWith { (primaryWeapon _this) call SYG_isSMG};
};

SYG_isLauncher =
{
	[_this, LAUNCHER_WEAPON_LIST] call SYG_isInList;
};

//
// call: _hasLauncher = _unit call SYG_hasLauncher;
//
SYG_hasLauncher =
{
	private ["_res"];
	_res = false;
	{
		if (_x call SYG_isLauncher) exitWith { _res = true;};
	} forEach weapons _this;
	_res;

//	if (true) exitWith { (secondaryWeapon _this) call SYG_isLauncher};
};

// Check if designated weapon has long muzzle
SYG_isLongMizzle = {
	if ( true) exitWith { [_this, LONG_MUZZLE_WEAPON_LIST] call SYG_isInList};
};

//
// call: _hasLongMuzzle = _unit call SYG_hasLongMuzzle;
//
SYG_hasLongMuzzle =
{
	private ["_res"];
	_res = false;
	{
		if (_x call SYG_isLongMizzle) exitWith { _res = true;};
	} forEach weapons _this;
	_res
};

//
// _wpnParent  = _weapon call SYG_getParent; // Parent config class Name
//
SYG_getParent = {
	configName (inheritsFrom (configFile >> "CfgWeapons" >> _this))
};


//
// Function for pistol detection - by Spooner
// params: _weapon  - item name expected to be or not to be pistol
// Example: isPistol = (secondaryWeapon _unit)  call SYG_isPistol;
//
/* SYG_isPistol = {
	private ["_unknownConfig", "_pistolConfig", "_isPistol"];
	_unknownConfig = configFile >> "CfgWeapons" >> _this;
	_pistolConfig = configFile >> "CfgWeapons" >> "PistolCore";

	_isPistol = false;
	while {isClass _unknownConfig} do
	{
	    if (_unknownConfig == _pistolConfig) exitWith
	    {
	        _isPistol = true;
	    };

	    _unknownConfig = inheritsFrom _unknownConfig;
	};

	_isPistol; // Return.
};
 */
SYG_hasPistol = {
	private ["_ret"];
	_ret = false;
	{
		if ( _x call SYG_isPistol ) exitWith {_ret = true;};
	} forEach weapons _this;
	_ret
};

/*
 * Detects is designated as _this weapon supressed (returns true) or not (returns false)
 *
 * call: _isSuprressed = "ACE_AKS74USD_Cobra" call SYG_isSupressed; // returns true
 */
SYG_isSupressed = {
	if ( _this == "" ) then { false} else
	{ getNumber( configFile >> "CfgWeapons" >> _this >> "ace_supressed") > 0 };
};

// Synonym for SYG_isSupressed
SYG_isSilenced = SYG_isSupressed;

// return true if primary weapon of designated unit is supressed one
SYG_hasSupressed = {
	(primaryWeapon _this != "") and ((primaryWeapon _this) call SYG_isSupressed)
};


// Gets all compatible magazines for designated weapon
// _compatibleMagazines = _weapon call SYG_getCompatibleMagazines;
//
SYG_getCompatibleMagazines = {
   private ["_weapon", "_mags"];

    _weapon = configFile >> "CfgWeapons" >> _this; // точка входа в самый верхний класс нашего ствола
    _mags = [];

    { // для всех muzzles нашего ствола
        _mags = _mags + getArray (
            // если очередной (обычно единственный) muzzle -- это this, то читаем магазины у себя,
            // иначе -- у подкласса с указанным muzzle classname.
            ( if(_x == "this")then{ _weapon }else{ _weapon >> _x } ) >> "magazines"
        );
    } forEach getArray (_weapon >> "muzzles");
    _mags
};

//
// call: _ret = _vehicle call SYG_reammoTruck;
// returns: true is reammed or false is not reammed
//
SYG_reammoTruck = {
	if ( _this isKindOf "Truck5tReammo" ) then
	{
		hint localize format["SYG_reammoTruck: called for %1", typeOf _this];

		clearMagazineCargo _this;
		clearWeaponCargo   _this;

		_this addWeaponCargo   ["ACE_FIM92A",2];
		_this addMagazineCargo ["ACE_Stinger", 5];

		_this addWeaponCargo   ["ACE_M136",2];
		_this addMagazineCargo ["ACE_AT4_HEAT", 30];
		_this addMagazineCargo ["ACE_AT4_HP", 30];
		_this addMagazineCargo ["ACE_AT4_HEDP", 30];

		_this addWeaponCargo   ["ACE_CarlGustav", 5];
		_this addMagazineCargo ["ACE_CarlGustav_HEAT", 30];
		_this addMagazineCargo ["ACE_CarlGustav_HEAT_2", 30];
		_this addMagazineCargo ["ACE_CarlGustav_HEDP", 30];
		_this addMagazineCargo ["ACE_CarlGustav_HE", 30];

		_this addWeaponCargo   ["ACE_SMAW", 5];
		_this addMagazineCargo ["ACE_SMAW_HEAA", 30];
		_this addMagazineCargo ["ACE_SMAW_HEDP", 30];
		_this addMagazineCargo ["ACE_SMAW_FTG", 30];
		_this addMagazineCargo ["ACE_SMAW_Spotting", 30];

		_this addWeaponCargo   ["ACE_M72", 5];
		_this addMagazineCargo ["ACE_LAW_HEAT", 30];
		_this addMagazineCargo ["ACE_LAW_HP", 30];
		_this addMagazineCargo ["ACE_LAW_HEF", 30];

		_this addMagazineCargo ["ACE_30Rnd_556x45_B_Stanag", 50];
		_this addMagazineCargo ["ACE_30Rnd_556x45_BT_Stanag", 50];
		_this addMagazineCargo ["ACE_30Rnd_556x45_SD_Stanag", 50];
		_this addMagazineCargo ["ACE_20Rnd_556x45_SB_Stanag", 50];

		//_this addMagazineCargo ["ACE_20Rnd_762x51_B_SCAR", 50];
		_this addMagazineCargo ["ACE_20Rnd_762x51_SB_SCAR", 50];

		//_this addMagazineCargo ["ACE_20Rnd_762x51_B_M14", 50];
		_this addMagazineCargo ["ACE_20Rnd_762x51_SB_M14", 50];

		//_this addMagazineCargo ["ACE_20Rnd_762x51_B_HK417", 50];
		_this addMagazineCargo ["ACE_20Rnd_762x51_SB_HK417", 50];
		_this addMagazineCargo ["ACE_200Rnd_556x45_B_M249", 50];
		_this addMagazineCargo ["ACE_200Rnd_556x45_BT_M249", 50];

		_this addMagazineCargo ["ACE_100Rnd_762x51_B_M240", 50];
		_this addMagazineCargo ["ACE_100Rnd_762x51_BT_M240", 50];

		_this addMagazineCargo ["ACE_10Rnd_127x99_API_Barrett", 50];
		_this addMagazineCargo ["10Rnd_127x99_m107", 50];
		_this addMagazineCargo ["ACE_10Rnd_127x99_SB_Barrett", 50];
		_this addMagazineCargo ["ACE_10Rnd_127x99_BT_Barrett", 50];
		_this addMagazineCargo ["ACE_5Rnd_25x59_HEDP_Barrett", 50];
		_this addMagazineCargo ["ACE_5Rnd_127x99_API_AS50", 50];
		_this addMagazineCargo ["ACE_5Rnd_127x99_AS50", 50];
		_this addMagazineCargo ["ACE_5Rnd_127x99_SB_AS50", 50];
		_this addMagazineCargo ["ACE_5Rnd_127x99_BT_AS50", 50];
		_this addMagazineCargo ["ACE_20Rnd_762x51_SB_M110", 50];

		_this addMagazineCargo ["ACE_5Rnd_762x51_SB", 50];

		_this addMagazineCargo ["ACE_30Rnd_556x45_B_G36",50];
		_this addMagazineCargo ["ACE_30Rnd_556x45_BT_G36",50];
		_this addMagazineCargo ["ACE_100Rnd_556x45_BT_G36",50];
		_this addMagazineCargo ["ACE_100Rnd_556x45_B_G36",50];

		_this addMagazineCargo ["ACE_25Rnd_1143x23_B_UMP45", 50];
		_this addMagazineCargo ["ACE_30Rnd_9x19_B_MP5", 50];
		_this addMagazineCargo ["ACE_30Rnd_9x19_SD_MP5", 50];
		_this addMagazineCargo ["ACE_15Rnd_9x19_B_M9", 20];
		_this addMagazineCargo ["ACE_15Rnd_9x19_SD_M9", 20];
		_this addMagazineCargo ["ACE_17Rnd_9x19_G17", 20];
		_this addMagazineCargo ["ACE_33Rnd_9x19_G18", 20];
		_this addMagazineCargo ["ACE_7Rnd_1143x23_B_M1911", 20];

		_this addMagazineCargo ["ACE_9Rnd_12Ga_Slug",20];
		_this addMagazineCargo ["ACE_9Rnd_12Ga_Buck00",20];
		_this addMagazineCargo ["ACE_8Rnd_12Ga_Slug"];
		_this addMagazineCargo ["ACE_8Rnd_12Ga_Buck00"];

		_this addMagazineCargo ["ACE_1Rnd_Flare_Red", 20];
		_this addMagazineCargo ["ACE_1Rnd_Flare_Green", 20];
		_this addMagazineCargo ["ACE_1Rnd_Flare_Yellow", 20];
		_this addMagazineCargo ["ACE_1Rnd_Flare_White", 20];

		_this addMagazineCargo ["ACE_6Rnd_40mm_M32", 20];
		_this addMagazineCargo ["ACE_40mm_HEDP_M203", 20];
		_this addMagazineCargo ["ACE_40mm_SmokeWhite_M203", 20];
		_this addMagazineCargo ["ACE_40mm_SmokeRed_M203", 20];
		_this addMagazineCargo ["ACE_40mm_SmokeGreen_M203", 20];
		_this addMagazineCargo ["ACE_40mm_SmokeYellow_M203", 20];
		_this addMagazineCargo ["ACE_40mm_FlareWhite_M203", 20];
		_this addMagazineCargo ["ACE_40mm_FlareGreen_M203", 20];
		_this addMagazineCargo ["ACE_40mm_FlareRed_M203", 20];
		_this addMagazineCargo ["ACE_40mm_FlareYellow_M203", 20];
		_this addMagazineCargo ["ACE_40mm_FlareIR_M203", 50];
		_this addMagazineCargo ["ACE_HuntIR_M203", 10];

		_this addMagazineCargo ["ACE_PipeBomb", 10];

		_this addMagazineCargo ["ACE_SmokeGrenade_Red", 10];
		_this addMagazineCargo ["ACE_SmokeGrenade_Green", 10];
		_this addMagazineCargo ["ACE_SmokeGrenade_Yellow", 10];
		_this addMagazineCargo ["ACE_SmokeGrenade_Violet", 10];
		_this addMagazineCargo ["ACE_SmokeGrenade_White", 10];

		_this addMagazineCargo ["ACE_HandGrenadeTimed", 10];

        _this setAmmoCargo 1; // Ensure full reammo ability

		true
	}
 	else
	{
		//hint localize format["SYG_reammoTruck: --- Expected input vehicle type Truck5tReammo, detected %1 ---", typeOf _this ];
		false
	};
};

//
// reammo all not locked western ammo trucks around designated point
// call as: [_center<, _dist>] call SYG_reammoTruckAround;
// returns: number of trucks rearmed
// _dist is mandatory, default value is 400 meters
//
SYG_reammoTruckAround = {
	private [ "_truck", "_center", "_dist", "_rearmed" ];
	_rearmed = 0;
	if (d_enemy_side == "WEST") then {
		_center = _this select 0;
		_dist = if ( count _this > 1 ) then {_this select 1} else {400};
		{
			if (!locked _x) then { _x call SYG_reammoTruck; _rearmed = _rearmed + 1; }
		} forEach ( _center nearObjects ["Truck5tReammo", _dist] ); //position player nearObjects 50;
	};
	_rearmed
};

//
// call: _ret = _vehicle call SYG_reammoMHQ;
//
SYG_reammoMHQ = {
	if ( _this isKindOf "BMP2_MHQ" ) then
	{
		// hint localize format["SYG_reammoMHQ: entered with %1", _this];

		clearMagazineCargo _this;
		clearWeaponCargo   _this;

		_this addMagazineCargo ["ACE_Strela", 2];

		//_this addWeaponCargo   ["ACE_RPG7_PGO7",  3];
		_this addMagazineCargo ["ACE_RPG7_PG7VR", 3];
		_this addMagazineCargo ["ACE_RPG7_PG7VL", 3];

		_this addMagazineCargo ["ACE_PipeBomb", 4];

		_this addMagazineCargo ["ACE_SmokeGrenade_Red",    3];
		_this addMagazineCargo ["ACE_SmokeGrenade_Green",  1];
		_this addMagazineCargo ["ACE_SmokeGrenade_Yellow", 1];
		_this addMagazineCargo ["ACE_SmokeGrenade_Violet", 1];
		_this addMagazineCargo ["ACE_SmokeGrenade_White",  1];

		_this addMagazineCargo ["ACE_HandGrenade", 2];
/*
		_this addMagazineCargo ["ACE_64Rnd_9x18_B_Bizon", 10];
		_this addMagazineCargo ["ACE_10Rnd_9x39_SB_VSS",  10];
 */
		_this addMagazineCargo ["ACE_45Rnd_545x39_BT_AK",  15];
		_this addMagazineCargo ["ACE_100Rnd_762x54_BT_PK", 3];
		_this addMagazineCargo ["ACE_40Rnd_762x39_BT_AK",  5];
		_this addMagazineCargo ["ACE_20Rnd_9x39_B_VAL",    5];
		_this addMagazineCargo ["ACE_10Rnd_762x54_SB_SVD", 5];
		_this addMagazineCargo ["ACE_5Rnd_127x108_SB_KSVK",5];
		_this addMagazineCargo ["ACE_5Rnd_127x108_BT_KSVK",5];

		_this addMagazineCargo ["ACE_Bandage",     3];
		_this addMagazineCargo ["ACE_Morphine",    5];
		_this addMagazineCargo ["ACE_Epinephrine", 1];
		true
	}
	else
	{
		hint localize format["--- SYG_reammoMHQ: --- Expected input vehicle type BMP2_MHQ, detected %1 ---", typeOf _this ];
		false
	};
};

// Reloads any vehicle at the moment
//
// call as follow:
// _res = _vec call SYG_fastReload;
// or
// _res = [_vec1, _vec2, ... _vecN] call  SYG_fastReload;
// returns true if reloaded, false if arguments wrong (not object, not array of objects
//
SYG_fastReload = {
	private ["_i","_type","_mags","_removed","_config","_count","_vec"];

	if ( (typeName _this) == "OBJECT" ) then { _this = [_this]; };
	if ( ( typeName _this) != "ARRAY") exitWith { false};
	_ret = count _this > 0;
	{
		_vec = _x;
		if ( (!isNull _vec) && (alive _vec) && ((typeName _vec) == "OBJECT") ) then
		{
			_type = typeOf _vec;
			_mags = getArray(configFile >> "CfgVehicles" >> _type >> "magazines"); //low level mags

			if (count _mags > 0) then {
				_removed = [];
				{
					if (!(_x in _removed)) then {
						_vec removeMagazines _x;
						_removed = _removed + [_x];
					};
				} forEach _mags;
				{
					_vec addMagazine _x;
				} forEach _mags;
			};

			_count = count (configFile >> "CfgVehicles" >> _type >> "Turrets"); // turrets mags

			if (_count > 0) then {
				for "_i" from 0 to (_count - 1) do {
					_config = (configFile >> "CfgVehicles" >> _type >> "Turrets") select _i;
					_mags = getArray(_config >> "magazines");
					_removed = [];
					{
						if (!(_x in _removed)) then {
							_vec removeMagazines _x;
							_removed = _removed + [_x];
						};
					} forEach _mags;
					{
						_vec addMagazine _x;
					} forEach _mags;
				};
			};
		};
	} forEach _this;
	_ret
};

// _eqip_list_as_str = _name call SYG_getPlayerEquipment;
SYG_findPlayerEquipmentAsStr = {
    private ["_index", "_parray"];
    if ( (typeName _this) == "OBJECT") then {_this = name _this;};
    if ( (typeName _this) != "STRING" ) exitWith
    {
        hint localize format["--- SYG_findPlayerEquipmentAsStr: expected param isn't string: %1", _this ];
    };
    //hint localize format["--- %1 call SYG_findPlayerEquipmentAsStr;", _this ];
    _index = d_player_array_names find _this;
    if (_index >= 0) exitWith
    {
        //  player array is: [d_player_air_autokick, time, _name, 0, "", eqp_list_as_str]
        _parray = d_player_array_misc select _index;
        _parray select 5
    };
    ""
};

// [_name,_wpn_arr_str] call SYG_storePlayerEquipmentAsStr;
SYG_storePlayerEquipmentAsStr = {
    if ( (typeName _this) != "ARRAY" ) exitWith {hint localize format["--- SYG_storePlayerEquipmentAsStr: expected param isn't array: %1",_this];};
    if ( (count _this) < 2 ) exitWith
    {
        hint localize format["--- SYG_storePlayerEquipmentAsStr: expected params are not 2 item array: %1", _this ];
    };
    if ( (typeName arg(0)) == "OBJECT") then {_this set[0,name arg(0)];};

    //hint localize format["SYG_storePlayerEquipmentAsStr(%1 param[s]);",count _this];

    if ( (typeName arg(0)) == "STRING" && (typeName arg(1)) == "STRING" )  then
    {
        //hint localize "SYG_storePlayerEquipmentAsStr: enter store code";
        private ["_index", "_parray", "_name"];
        _name = arg(0);
        _index = d_player_array_names find _name;
        if (_index >= 0) then
        {
            //  player array is: [d_player_air_autokick, time, _name, 0, "", eqp_list_as_str]
            _parray = argp( d_player_array_misc,_index);
            _parray set [ 5, arg(1)];
            hint localize format ["+++ equipment re-written for %1: %2", _name, arg(1)];
        }
        else
        {
            d_player_array_names = d_player_array_names + [_name];
            d_player_array_misc = d_player_array_misc + [[d_player_air_autokick, time, _name, 0, "", arg(1)]];
            hint localize format ["+++ equipment stored for %1: %2", _name, arg(1)];
        };
    };
};

//
// call: _eq_arr = _eq_str call SYG_equipStr2Arr;
//
SYG_equipStr2Arr = {
    call compile format["%1", _this]
};

//
// call: _eq_str = _eq_arr call SYG_equipArr2Str;
//
SYG_equipArr2Str = {
    format["%1", _this]
};

//
// _isRuck = _item call SYG_isRucksack;
//
SYG_isRucksack = {
    isNumber(configFile >> "CfgWeapons" >> _this >> "ACE_PackSize")
};

//
// gets unit whole equipment and store it into array
// _eqp_arr = player call SYG_unitEquipment;
// returns array [ [weapons names], [magazines names]<, rucksack_name<,[mags_in_rucksack_names]>> ]
SYG_getPlayerEquiptArr = {
    private ["_wpn", "_ruck", "_ruckMags"];
    _wpn = weapons _this;

#ifdef __ACE__
	_ruck = _this getVariable "ACE_weapononback";
	if ( isNil "_ruck") then  {_ruck = "";};
	_ruckMags = _this getVariable "ACE_Ruckmagazines";
	if ( isNil "_ruckMags") then  {_ruckMags = [];};
	//hint localize format["_ruck %1, _ruckMags %2", _ruck, _ruckMags];
#else
// no rucksack if no ACE
	_ruck = "";
	_ruckMags = [];
#endif

#ifdef __JAVELIN__
    [_wpn, (magazines _this) - ["ACE_Javelin"], _ruck, _ruckMags, d_viewdistance, d_rebornmusic_index]
#else
    [_wpn, magazines _this, _ruck, _ruckMags, d_viewdistance, d_rebornmusic_index]
#endif

};

//
// gets unit whole equipment and store it into string
// _eqp_arr = player call SYG_unitEquipment;
// returns array [ [weapons names], [magazines names]<, rucksack_name<,[mags_in_rucksack_names]>> ]
SYG_getPlayerEquipAsStr = {
    (call SYG_getPlayerEquiptArr) call SYG_equipArr2Str;
};

// _wpn_arr = _str_wpn call SYG_unpackEquipmentFromStr;
SYG_unpackEquipmentFromStr =
{
    call compile _this
};

//
// call as: _param = [_settingsArr, PARAM_NAME] call SYG_getParamFromSettingsArray;
//
// where PARAM_NAME is in ["VD", "GI", "PI"]
//  d_viewdistance = 1500;
//  d_graslayer_index = 0;
//  d_playermarker_index = 1;
//  d_rebornmusic_index = 0;
//
// if any error, -1 always returned
//
SYG_getParamFromSettingsArray = {
    private ["_arr","_prm"];
    if (typeName _this != "ARRAY") exitWith {-1};
    if ( count _this < 2) exitWith {-1};
    _arr = arg(0);
    if (typeName _arr != "ARRAY" ) exitWith{-1};
    _prm = arg(1);
    if (typeName _arr != "STRING" ) exitWith{-1};
    // return requested value
    switch toUpper(_prm) do
    {
        case "VD": {argp(_arr, 0)}; // ViewDistance
        case "GI": {argp(_arr, 1)}; // GrassIndex
        case "PI": {argp(_arr, 2)}; // Player marker Index
        case "RM": {argp(_arr, 3)}; // Reset defeat Music on/o
        default {-1};
    }
};
