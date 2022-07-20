/*
    scripts/fireLitAction.sqf by Sygsky.

    Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
    target (_this select 0): Object - the object which the action is assigned to
    caller (_this select 1): Object - the unit that activated the action
    ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
    arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
*/

#include "GRU_setup.sqf"

_type = typeOf (_this  select 0);
_name = name (_this select 1);
_msg = switch _type do {
    case "FireLit": {"STR_FIRELIT_NUM" call SYG_getRandomText};
    case "Fire": {"STR_FIRE_NUM" call SYG_getRandomText};
    default {"STR_FIRE_UNKNOWN"};
};
["msg_to_user", [_name], [[_msg]]] call SYG_msgToUserParser; // message output
hint localize format["scripts/fireLitAction.sqf message on fireAction: %1", localize _msg];
if ( _msg == "STR_FIRELIT_1" || _msg == "STR_FIRE_1" ) then {
	hint localize format["scripts/fireLitAction.sqf msg on fireAction, add score: %1", _msg];
    GRU_SPECIAL_SCORE_ON_FIRELIT_INFO call GRU_SpecialScores;
}