/*
  INITIALISATION SCRIPT FOR AI_DISABLED REVIVE SCRIPT


  JANUARY 2008 - norrin (norrins_nook@iprimus.com.au)

  Version:  1.4x FX
*******************************************************
Start r_init.sqf
*/

//Init.sqf settings for revive_player scripts by norrin
// ====================================================
waitUntil{X_INIT};
if (X_Client) then {sleep 1;waitUntil {(local player && alive player)};};

//This next line can be commented out or removed if it 
//interferes with intro movies  
// ====================================================
//titleText ["AI_DISABLED REVIVE v1.4x FX", "PLAIN DOWN", 0.2];
titleText ["AI_DISABLED REVIVE v1.4x FX", "PLAIN DOWN", 0.2];

//Configurable revive script options (Off = 0, On = 1)
// ====================================================
_NORRN_mission_end_function = 0; 		//array no.0 
_NORRN_reward_function = 1; 			//array no.1
_NORRN_team_kill_function = 0;     		//array no.2
_NORRN_all_dead_dialog = 1;			//array no.3
_NORRN_JIP_spawn_dialog = 1;			//array no.4
_NORRN_nearest_teammate_dialog = 1; 	//array no.5
_NORRN_unconcious_markers = 1;		//array no.6
_NORRN_follow_cam = 1;  			//array no.7
_NORRN_call_out_function = 1;			//array no.8
_NORRN_revive_timer = 1; 			//array no.9
_NORRN_heal_yourself = 1;			//array no.10
_NORRN_kegetys_spectator = 1;			//array no.11
_NORRN_water_dialog = 1;			//array no.38

//list of playable units 
// ====================================================
NORRN_player_units = d_player_entities;

// no of respawn points, spawn position names for 
//respawn and the time before the respawn dialog appears 
//for JIP players - Option to make base_1 respawn possible 
//even if enemy forces are within 50 metres (options OFF = 0, ON = 1)
// =====================================================
_NORRN_no_respawn_points = 3;			//array no.12
_NORRN_Base_1 = "base_spawn_1";		//array no.13
_NORRN_Base_2 = "Respawn 1";		//array no.14
_NORRN_Base_3 = "Respawn 2";		//array no.15
_NORRN_Base_4 = "";		//array no.16
_NORRN_time_b4_JIP_spawn_dialog = 10000;	//array no.17
_NORRN_Base_1_respawn = 1;			//array no.18

//The can_revive variable can be changed if for example
// you only one sort of unit to be able to revive eg. "soldierWMedic" 
//The can_be_revived variable can be changed if you want
//to use these scripts for a different side
// =====================================================
_soldier = (
	switch (d_own_side) do {
		case "EAST": {"soldierEB"};
		case "WEST": {"soldierWB"};
		case "RACS": {"soldierGB"};
	}
);

_NORRN_can_revive = _soldier;		//array no.19
_NORRN_can_revive_2 = "";		//array no.20
_NORRN_can_be_revived = _soldier;	//array no.21
_NORRN_can_be_revived_2 = "";	//array no.22

//No of Enemy sides (0, 1 or 2). Enemy sides can be "EAST",
//"WEST","RESISTANCE" etc
// ======================================================
_r_side_enemy = (
	switch (d_enemy_side) do {
		case "EAST": {"EAST"};
		case "WEST": {"WEST"};
		case "RACS": {"RESISTANCE"};
	}
);
_NORRN_no_enemy_sides = 0;			//array no.23
_NORRN_enemy_side_1 = _r_side_enemy;			//array no.24
_NORRN_enemy_side_2 = "";			//array no.25

//Friendly sides. These next options are linked to the camera script and
//allow the players to spectate other team members and friendly sides
//while unconscious.  Friendly sides can be "EAST", "WEST","RESISTANCE" etc.  
//If all players are from the same side make sure you set the same side 
//for both variables eg "WEST", "WEST" ie do not leave these variables blank 
//if using the follow cam option (//array no.7)
//=======================================================
_r_side = (
	switch (d_own_side) do {
		case "EAST": {"EAST"};
		case "WEST": {"WEST"};
		case "RACS": {"RESISTANCE"};
	}
);

_NORRN_allied_side_1 = _r_side;		//array no.40
_NORRN_allied_side_2 = _r_side;	//array no.41

//Maximum number of revives per unit - adjust to whatever 
//value you like and the unit's level of damage following revive
//Whether you want to use HulkingUnicorn's script that does not allow the
//player to stand until after he has been healed by a medic
// ======================================================
//_NORRN_max_respawns = param2;			//array no.26
_NORRN_max_respawns = d_NORRN_max_respawns;			//array no.26
_NORRN_revive_damage = 0; 			//array no.39
_HULK_rProne = 0;					//array no.43

//Time until respawn button appears (0 = approx. 12 seconds)
//Set to a high number like 100000 seconds if you do not want
//to use this option
// ======================================================
_NORRN_respawn_button_timer = d_NORRN_respawn_button_timer;		//array no.27

//If the closest friendly unit is further 
//than this distance away trigger respawn dialog
// ======================================================
_NORRN_distance_to_friend = 200; 		//array no.28

//Number fo the revives required for bonus
// ======================================================
_NORRN_revives_required = 1;			//array no.29

//Number of teamkills before punishment
// ======================================================
_NORRN_no_team_kills = 1;			//array no.30

//Choose what type of respawn option for the revive_timer
//function: 0 = dead or 1 = spawns at base (NORRN_respawn_position = 0)
//or the closest enemy free respawn point to where the player died 
//NORRN_respawn_positon = 1) or player's choice of free respawn point 
//NORRN_respawn_positon = 2) When using the revive_timer function 
//the length of time before the unconscious player is declared dead 
//or respawns. Also you have the option of viewing a revive count down 
//timer 
// ======================================================
_NORRN_revive_timer_type = 1;			//array no.31
_NORRN_respawn_position = 1;			//array no.32
_NORRN_revive_time_limit = d_NORRN_revive_time_limit;		//array no.33
_NORRN_visible_timer = 1;			//array no.42

//Number of heals that each player gets during a mission 
//The damage level range between which the heal action becomes available 
//=======================================================
_NORRN_no_of_heals = d_NORRN_no_of_heals;				//array no.34
_NORRN_lower_bound_heal = 0.1;		//array no.35
_NORRN_upper_bound_heal = 0.7;		//array no.36									

//This sets the distance that you wish the unconscious 
//follow cam to follow other team members
//=======================================================
_NORRN_follow_cam_distance = 250;		//array no.37


//User code - eg. NORRNCustonexec1="execvm ""myscript.sqf"";hint ""myoutput"";"
//Exec1 occurs following being revived
//Exec2 occurs when you team kill
//Exec3 occurs when you spawn at base
//Exec4 occurs when you try and spawn at base but it is still occupied
NORRNCustomExec1="";
NORRNCustomExec2="";
NORRNCustomExec3="";
NORRNCustomExec4="";

NORRN_revive_array = [];
NORRN_revive_array = [_NORRN_mission_end_function,_NORRN_reward_function, _NORRN_team_kill_function, _NORRN_all_dead_dialog, _NORRN_JIP_spawn_dialog,
			    _NORRN_nearest_teammate_dialog, _NORRN_unconcious_markers, _NORRN_follow_cam, _NORRN_call_out_function, _NORRN_revive_timer,
			    _NORRN_heal_yourself, _NORRN_kegetys_spectator,_NORRN_no_respawn_points,_NORRN_Base_1,_NORRN_Base_2,_NORRN_Base_3,_NORRN_Base_4,
			    _NORRN_time_b4_JIP_spawn_dialog,_NORRN_Base_1_respawn,_NORRN_can_revive,_NORRN_can_revive_2,_NORRN_can_be_revived,
			    _NORRN_can_be_revived_2,_NORRN_no_enemy_sides,_NORRN_enemy_side_1,_NORRN_enemy_side_2,_NORRN_max_respawns,_NORRN_respawn_button_timer,
			    _NORRN_distance_to_friend,_NORRN_revives_required,_NORRN_no_team_kills,_NORRN_revive_timer_type,_NORRN_respawn_position,
			    _NORRN_revive_time_limit,_NORRN_no_of_heals,_NORRN_lower_bound_heal,_NORRN_upper_bound_heal,_NORRN_follow_cam_distance,
			    _NORRN_water_dialog, _NORRN_revive_damage, _NORRN_allied_side_1, _NORRN_allied_side_2, _NORRN_visible_timer, _HULK_rProne];


execVM "revive_sqf\revive_init.sqf";

//Initialise isplayer script
[NORRN_player_units] execVM "revive_sqf\isplayer.sqf";

if (isServer) then 
{
	//Initialise mission end script
	if (_NORRN_mission_end_function == 1) then {[NORRN_player_units] execVM "revive_sqf\mission_end.sqf"};
	
	//Initialise marker color script
	if (_NORRN_no_enemy_sides > 0) then {execVM "revive_sqf\marker_color.sqf"};

};

if (true) exitWith {};	



