/*
	scripts\SYG_checkPlayerAtBase.sqf
	author: Sygsky
	description: checks if player visited base rectangle. If yes, set variable was_at_base to true
	returns: nothing

    Checks if alive player was at base.
	Call as: [] execVM  SYG_checkPLayerAtBase;

*/

if (isNil "was_at_base") then {was_at_base = false};
if (was_at_base) exitWith {};
if (!alive player) exitWith { [ "msg_to_user", "*", ["localize", "STR_INTRO_NOT_AT_BASE"], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser; };

while { (alive player) && (! ((getPos player) call SYG_pointIsOnBase)) } do { sleep 5};

if (!alive player) exitWith { [ "msg_to_user", "*", ["localize", "STR_INTRO_NOT_AT_BASE"], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser; };

[ "msg_to_user", "*", ["localize", "STR_INTRO_WAS_AT_BASE"], 0, 0, false, "no_more_waiting" ] call SYG_msgToUserParser;
was_at_base = true;

