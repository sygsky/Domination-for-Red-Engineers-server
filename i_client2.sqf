// init include client 2

_bmp_list =
#ifdef __USE_M60__
			["ACE_M60", "ACE_M60_A3"] +
#else
			["ACE_Stryker_TOW"] +
#endif
			["ACE_Stryker_M2","ACE_Stryker_MK19","ACE_Stryker_MGS","ACE_Stryker_MGS_SLAT"]; // bmp

if (X_Client) then {

#ifdef __OWN_SIDE_EAST__
_armor = (if (!d_lock_ai_armor) then {if (__ACEVer) then {
    _bmp_list + ["ACE_M113","ACE_M113_A1","ACE_M113_A3","ACE_M2A1","ACE_M2A3","ACE_PIVADS","ACE_Vulcan","ACE_M6A1"]
} else {["Stryker_ICV_M2","Stryker_ICV_MK19","Vulcan","Stryker_TOW"]}} else {[]});
_car = (if (!d_lock_ai_car) then {if (__ACEVer) then {["ACE_HMMWV_GAU19","ACE_HMMWV_50","ACE_HMMWV_GL","ACE_HMMWV_TOW","WarfareWestSalvageTruck","ACE_Truck5t_Repair","ACE_Truck5t_Refuel","ACE_Truck5t_Reammo","ACE_Truck5t_Open","ACE_Truck5t","ACE_Truck5t_MG","ACE_HMMWV_GMV","ACE_HMMWV_GMV2"]} else {["HMMWV50","HMMWVMK","HMMWVTOW"]}} else {[]});

_enymy_heli_list =
    ( if ((!d_lock_ai_air) && (__ACEVer))
        then
        {
            SYG_HELI_BIG_LIST_ACE_W + SYG_HELI_LITTLE_LIST_ACE_W
        }
        else {[]});
#endif

#ifdef __OWN_SIDE_WEST__
_armor = (if (!d_lock_ai_armor) then {if (__ACEVer) then {["ACE_BMD1","ACE_BMD1p","ACE_BMP2_D","ACE_BMP2","ACE_BMP2_K","ACE_BRDM2_ATGM"]} else {["BMP2","BRDM2","BRDM2_ATGM"]}} else {[]});
_car = (if (!d_lock_ai_car) then {if (__ACEVer) then {["ACE_UAZ_AGS30","ACE_UAZ_MG","D30"]} else {["UAZ_AGS30","D30","UAZMG"]}} else {[]});
#endif

#ifdef __OWN_SIDE_RACS__
_armor = (if (!d_lock_ai_armor) then {["BMP2","BRDM2","BRDM2_ATGM"]} else {[]});
_car = (if (!d_lock_ai_car) then {["UAZ_AGS30","D30","UAZMG"]} else {[]});
#endif

#ifdef __TT__
_armor = (if (!d_lock_ai_armor) then {["BMP2","BRDM2","BRDM2_ATGM"]} else {[]});
_car = (if (!d_lock_ai_car) then {["UAZ_AGS30","D30","UAZMG"]} else {[]});
#endif

d_helilift1_types =
#ifdef __OWN_SIDE_EAST__
	if (__CSLAVer) then {
		["CSLAWarfareEastMobileHQ","CSLAWarfareEastSalvageTruck","CSLA_BVP2","CSLA_BVP1","CSLA_OT64C","CSLA_BRDM2","CSLA_9P148","CSLA_OZ90","CSLA_DTP90","CSLA_T815Ammo8","CSLA_T815CAP6","CSLA_UAZ","CSLA_T813o","WarfareEastSalvageTruck","UralRepair","UralRefuel","UralReammo","UralOpen","BMP2","UAZ_AGS30","M119","D30","UAZMG","BRDM2","BRDM2_ATGM","BMP2_MHQ","BMP2Ambul"] + _armor + _car
	} else {
		if (__ACEVer) then {
//			["BMP2_MHQ","ACE_BMP2_Ambul","WarfareEastSalvageTruck","ACE_Ural_Repair","ACE_Ural_Reammo","ACE_Ural_Refuel","ACE_Ural","ACE_BMP2","ACE_BMD1","ACE_BMP2_D","ACE_BMP2_K","ACE_BMD1p","BRDM2","ACE_BRDM2_ATGM","ACE_UAZ_MG","ACE_UAZ_AGS30","ACE_UAZ","M119","D30","ACE_ZSU"] + _armor + _car
			[ "BMP2_MHQ","ACE_BMP2_Ambul","ACE_M113_Ambul","WarfareEastSalvageTruck","ACE_Ural_Repair","ACE_Ural_Reammo","ACE_Ural_Refuel","ACE_Ural","ACE_UAZ_MG","ACE_UAZ_AGS30","ACE_UAZ","M119","D30","ACE_ZU23M" ] + _car //+++ Sygsky to prevent lift heavy vec
		} else {
			["BMP2_MHQ","BMP2Ambul","WarfareEastSalvageTruck","UralRepair","UralRefuel","UralReammo","UralOpen","BMP2","UAZ_AGS30","M119","D30","UAZMG","BRDM2","BRDM2_ATGM"] + _armor + _car
		}
	};
#endif
#ifdef __OWN_SIDE_WEST__
	if (__ACEVer) then {
		["M113_MHQ","ACE_M113_Ambul","ACE_M2A2","ACE_M2A1","ACE_Stryker_M2","ACE_Stryker_MK19","ACE_Stryker_MGS","ACE_Stryker_MGS_SLAT",/*"ACE_Stryker_RV",*/"ACE_HMMWV_50","ACE_HMMWV_GL","ACE_HMMWV_TOW","ACE_HMMWV_GAU19","ACE_M113_A3","WarfareWestSalvageTruck","ACE_Truck5t_Repair","ACE_Truck5t_Refuel","ACE_Truck5t_Reammo","ACE_Truck5t_Open","ACE_Truck5t"] + _armor + _car
	} else {
		["M113_MHQ","M113Ambul","M113AmbulRacs","WarfareWestSalvageTruck","Truck5tRepair","Truck5tRefuel","Truck5tReammo","Truck5tOpen","Truck5tMG","Stryker_ICV_M2","Stryker_ICV_MK19","HMMWV50","HMMWVMK","Stryker_TOW","HMMWVTOW","M113_RACS","Vulcan_RACS","Vulcan"] + _armor + _car
	};
#endif
#ifdef __OWN_SIDE_RACS__
	["M113_MHQ","M113Ambul","M113AmbulRacs","WarfareWestSalvageTruck","Truck5tRepair","Truck5tRefuel","Truck5tReammo","Truck5tOpen","Truck5tMG","Stryker_ICV_M2","Stryker_ICV_MK19","HMMWV50","HMMWVMK","Stryker_TOW","HMMWVTOW","M113_RACS","Vulcan_RACS","Vulcan"] + _armor + _car;
#endif
#ifdef __TT__
	["M113_MHQ","M113Ambul","WarfareWestSalvageTruck","Truck5tRepair","Truck5tRefuel","Truck5tReammo","Truck5tOpen","Truck5tMG","Stryker_ICV_M2","Stryker_ICV_MK19","HMMWV50","HMMWVMK","Stryker_TOW","HMMWVTOW","M113_RACS","Vulcan_RACS","Vulcan"] + _armor + _car;
#endif

#ifdef __TT__
for "_i" from 0 to (count d_choppers_west - 1) do {
	_elem = d_choppers_west select _i;
	_elem set [3, d_helilift1_types];
};
for "_i" from 0 to (count d_choppers_racs - 1) do {
	_elem = d_choppers_racs select _i;
	_elem set [3, d_helilift1_types];
};
#endif
#ifndef __TT__
for "_i" from 0 to (count d_choppers - 1) do {
	_elem = d_choppers select _i;
	_elem set [3, d_helilift1_types];
};
// also possible:
// _element = d_choppers select 2; // third chopper
// _elem set [3, d_helilift_types_custom];
#endif

ts_vec_id = -1;
ts_nearest = objNull;
ts_id = -1;
player_backpack = [];
prim_weap_player = "";
x_weapon_array = [];
d_last_telepoint = 0;
d_chophud_on = true;

// if set to false, no chopper hud and no welcome message will be shown when entering a chopper as pilot
// turned off in Mando version to interfere with stuff from Mandoble
#ifndef __MANDO__
d_show_chopper_hud = true;
#endif
#ifdef __MANDO__
d_show_chopper_hud = false;
#endif
#ifdef __ACE__
d_show_chopper_hud = false;
#endif

// show a welcome message in a chopper (mainly used to tell the player if it is a lift or wreck lift chopper).
// false = disable it
d_show_chopper_welcome = true;

// show a welcome message in some special vehicles (currently mobile respawns and engineer salvage trucks).
// false = disable it
d_show_vehicle_welcome = false;

// TODO: add some fun menus to any vehicles, units etc

// add action menu entries + scripts that will be executed to specific player types
// if the first array is empty, then all players will get that action menu entry
// default, nothing in it
// you have to set fourth element allways to -1000
// example:
//	d_action_menus_type = [
//		[[],"Whatever2", "whateverscript2.sqf", -1000], // ALL players will get the action menu entry "Whatever2"
//		[["SoldierWMiner", "SoldierWAT","OfficerW"],"Whatever1", "whateverscript1.sqf", -1000] // only players of type SoldierWMiner, SoldierWAT and OfficerW will get the action menu entry "Whatever1"
//	];
d_action_menus_type = [];

// add action menu entries + scripts that will be executed to specific player units
// if the first array is empty, then all players will get that action menu entry
// default, nothing in it
// you have to set fourth element allways to -1000
// example:
// 	d_action_menus_unit = [
//		[[],"Whatever2", "whateverscript2.sqf", -1000], // ALL players will get the action menu entry "Whatever2"
//		[["RESCUE", "delta_1","bravo_6"],"Whatever1", "whateverscript1.sqf", -1000] // only players who are RESCUE, delta_1 and bravo_6 will get the action menu entry "Whatever1"
//	];
d_action_menus_unit = [];

// add action menu entries to all or specific vehicles, default = none
// example:
// d_action_menus_vehicle = [
// 		[[],"Whatever2", "whateverscript2.sqf", -1000], // will add action menu entry "Whatever2" to all vehicles
// 		[["UH60MG", "M113_MHQ"],"Whatever1", "whateverscript1.sqf", -1000] // will add action menu entry "Whatever1" to chopper 1 and MHQ 1
//
// ];
d_action_menus_vehicle = [];

// if set to false, no check for friendly units is done near arti target
d_arti_check_for_friendlies = false;
};