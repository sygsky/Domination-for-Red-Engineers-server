// i_client2.sqf: init include client 2

if (X_Client) then {
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