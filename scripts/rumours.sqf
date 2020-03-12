// scripts\c: by Sygsky
// script to find rumours for player
// Example:
// [...] execVM "scripts\rumours.sqf";
//     Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
//       target (_this select 0): Object - the object which the action is assigned to
//       caller (_this select 1): Object - the unit that activated the action
//       ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
//       arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax

//
#include "x_macros.sqf"

if (isServer && ! X_SPE) exitWith{false};  // isDedicated

// comment next line to not create debug messages
//#define __DEBUG__
//#define __PRINT__
//_param = _this select 3;

_msg = call SYG_getRumourText;
hint localize ("+++ Rumour:" + _msg);
titleText [_msg, "PLAIN"];
