// open.sqf, called on player respawn on client side only

_base_visit_status = base_visit_session;
if (base_visit_session == 0) then {
	base_visit_session = -1; // mark player to be respawning
};

_this execVM "scripts\deathSound.sqf";

#include "x_setup.sqf"

private ["_ok",/* "_killer",*/"_display","_ctrl"];
//_killer = _this select 1;
//hint localize format["+++ open.sqf runs for killed %1 and killer %2 +++", name player, name _killer];

#ifdef __CONNECT_ON_PARA__
if ( _base_visit_status <= 0 ) then {
	[ "msg_to_user", "*", [ ["STR_INTRO_NOT_AT_BASE", name player] ], 0, 2, false, "losing_patience" ] call XSendNetStartScriptClientAll; // "%1 didn't manage to get to the base this time..."
};
#endif

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++ wait predefined delay before respawn ++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sleep d_respawn_delay;

if (dialog) then {closeDialog 0};

#ifdef __CONNECT_ON_PARA__
if (_base_visit_status < 1) exitWith { // player killed before it reached the base
//	_spawn_point  = (drop_zone_arr select 0) call XfGetRanPointSquareOld;
	_spawn_point = [];
	#ifdef __ARRIVED_ON_ANTIGUA__
	if ( base_visit_mission < 1 ) then { // Spawn in tent on Antigua
		_spawn_point = spawn_tent call SYG_housePosCount;
		_spawn_point = spawn_tent buildingPos ( floor (random _spawn_point) );
	};
	#endif
	if ( (count _spawn_point) == 0 ) then {
		_rect = SPAWN_INFO select 3;
		while {(count _spawn_point) == 0} do {
		    // Wу are searching good point now as player is spawned on feet (between Somato and airbase)!
			_spawn_point = _rect call XfGetRanPointSquare; // [position trigger2, 200, 300, 30] call XfGetRanPointSquare;
		};
	};
	if ( !d_still_in_intro) then {
		_str = if ((score player) != 0) then { format[localize "STR_INTRO_PARAJUMP", (round ((_spawn_point distance FLAG_BASE)/50)) * 50 ] } else { "STR_INTRO_PARAJUMP_5" };
		[ "msg_to_user", "*", [[_str]], 0, 0, false ] spawn SYG_msgToUserParser; // "Get to the base any way you want (%1 m)!" or "We have to get to the base. They promised to launch flares!"
	};
	// respawn him at random point between base and Somato
	player setPos _spawn_point;
	player setDir (random 360);
	hint localize format["+++ open.sqf: base_visit_session <= 0, respawn at %1", [round (_spawn_point select 0), round (_spawn_point select 1)] ];
	if (base_visit_session < 0) then { // if not changed, restore status to original vqlue
		base_visit_session = _base_visit_status;
	};
};
#endif

[-1] execVM "GRU_Scripts\GRU_removedoc.sqf"; // remove map just in case

beam_target = -1;
tele_dialog = 0; // 0 = respawn, 1 = teleport

_ok = createDialog "TeleportModule";

_display = findDisplay 100001;
_ctrl = _display displayCtrl 100102;
_ctrl ctrlSetText localize "STR_SYS_30"; //"Респаун";
_ctrl = _display displayCtrl 100111;
_ctrl ctrlSetText localize "STR_SYS_20"; // "Выбор места возрождения"

x_loop_end = false;

[d_last_telepoint] execVM "dlg\update_target.sqf";

[] spawn {
	while {!x_loop_end && alive player && dialog} do {
		if (!x_loop_end && alive player) then {execVM "dlg\update_dlg.sqf";};
		sleep 1.012;
	};
	if (!alive player) then {
		closeDialog 100001;
	};
};

if (true) exitWith {};


