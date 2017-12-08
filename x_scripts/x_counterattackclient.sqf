// by Xeno
private ["_reason"];

if (!X_Client) exitWith {};

#include "x_macros.sqf"

_reason = _this select 0;

switch (_reason) do {
	case "start" : {
		__TargetInfo
		_s = format [localize "STR_SYS_541", _current_target_name]; // "It seems that the enemy doesn't want to give up %1 and starts a counterattack. Search defensive positions, the attack will start in a few minutes..."
		[_s, "HQ"] call XHintChatMsg;
	};
	case "start_real": {
		[localize "STR_SYS_541_1", "HQ"] call XHintChatMsg; // "The counterattack starts. Hold the current target. Good luck and god help us all...
	};
	case "over" : {
		[localize "STR_SYS_541_2", "HQ"] call XHintChatMsg; // "Good job. The counterattack was defeated."
	};
};

if (true) exitWith {};
