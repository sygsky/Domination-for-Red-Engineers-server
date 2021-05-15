//
// GRU_scripts/mapAction.sqf, created at 02-JUL-2016 by Sygsky for Red-Engineers server
//
// Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
// target (_this select 0): Object - the object which the action is assigned to
// caller (_this select 1): Object - the unit that activated the action
// ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
// arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
//

#include "GRU_setup.sqf"

// 1. show joke message

_type = typeOf (_this select 0);
_msg = "STR_MAP_NUM" call SYG_getRandomText;
_args = ["STR_MAP_10", _msg, "STR_" + _type]; // '%1 всматриваясь в карту, вы воcклицаете: "Да это-же %2!"'
//hint localize format["GRU_scripts\mapAction.sqf: %1",_args];
["msg_to_user", "", [_args]] call SYG_msgToUserParser; // message output
if ( _msg == "STR_MAP_7" ) then {
    GRU_SPECIAL_SCORE_ON_MAP_INFO call GRU_SpecialScores;
};

// 2. remove action from object

//(_this select 0) removeAction (_this select 2);
