/*
	scripts\SYG_checkPlayerAtBase.sqf
	author: Sygsky
	description: checks if player visited base rectangle. If yes, set variable was_at_base to true and exit
	returns: nothing

    Checks if alive player was at base.
	Call as: [] execVM  SYG_checkPLayerAtBase;

*/
_time = 0;
if (isNil "was_at_base") then {was_at_base = false};
while {!was_at_base} do {
	if (alive player) then {
		if ( (getPos player) call SYG_pointIsOnBase) then {
			was_at_base = (vehicle player == player);
		};
	};
	sleep 5;
};
// inform player that he reached the base
[ "msg_to_user", "*", ["localize", "STR_INTRO_WAS_AT_BASE"], 0, 0, false, "no_more_waiting" ] call SYG_msgToUserParser; // "You have reached the base! Life will get easier from here."

