// by Xeno, scripts/barracks_info.sqf.sqf to inform player about barracks
//
//  Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
//    target (_this select 0): Object - the object which the action is assigned to
//    caller (_this select 1): Object - the unit that activated the action
//    ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
//    arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
//

// "This is a barracks, a place to call AI for military service. Only the rescue ranger can use it!"
_args = [localize "STR_AI_10"];
["msg_to_user", "", [_args]] call XHandleNetStartScriptClient; // message output

(_this select 0) removeAction (_this select 2); // Remove action
if (true) exitWith {};
