/*
	scripts\SYG_checkPlayerAtBase.sqf
	author: Sygsky
	description: checks if player visited base rectangle. If yes, set variable was_at_base to true and exit
	returns: nothing

    Checks if alive player was at base.
	Call as: [] execVM  SYG_checkPLayerAtBase;

*/
_flare = objNull;
_pos = getPos FLAG_BASE;
_flag_pos = [];
_factor = (400 / 1600) max 12.5;
// set flare position as slightly random one

if (isNil "was_at_base") then {was_at_base = false};
while { !was_at_base } do {
	if ( alive player ) then {
		if ( ( getPos player ) call SYG_pointIsOnBase ) then {
			was_at_base = (vehicle player == player);
		};
	};
	sleep 5;
	// launch a yellow flare over the base to attract the player's attention (to tell him where to go)
	if (!alive _flare) then {
		_flag_pos set [ 0, (_pos select 0) + (random 2) ];
		_flag_pos set [ 1, (_pos select 1) + (random 2) ];
		_flag_pos set [ 2, 250 + (random 2) ]; // flare spawn height AGL
		_flare = "F_40mm_Yellow" createVehicleLocal _flag_pos;
		[ _flare, "YELLOW", _factor] execVM "scripts\emulateFlareFiredLocal.sqf";
	};
};

// inform player that he reached the base
[ "msg_to_user", "*", ["localize", "STR_INTRO_WAS_AT_BASE"], 0, 0, false, "no_more_waiting" ] call SYG_msgToUserParser; // "You have reached the base! Life will get easier from here."

// throw last GREEN flare
while { alive _flare } do { sleep 0.1 };
_flare = "F_40mm_Green" createVehicleLocal _flag_pos;
[ _flare, "GREEN", _factor] execVM "scripts\emulateFlareFiredLocal.sqf";

