// by Sygsky, scripts\info_ammobox.sqf to inform player about barracks
//
//  Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
//    target (_this select 0): Object - the object which the action is assigned to
//    caller (_this select 1): Object - the unit that activated the action
//    ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
//    arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
//
// // Usage from code: ammobox1 addAction[localize "STR_CHECK_ITEM","scripts\info_ammobox.sqf"]; // "Inspect"

["msg_to_user", "", [ [_this select 3] ] ] spawn SYG_msgToUserParser; // message output
(_this select 0) removeAction (_this select 2); // Remove action
(_this select 0) setVariable ["ACTION_ARR", nil]; // Remove also action vector
playSound "losing_patience"; // he-he
if (true) exitWith {};
