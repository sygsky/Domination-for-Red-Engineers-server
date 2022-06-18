// by Xeno, x_scripts\x_counterattackclient.sqf: counter attack execution
private ["_reason"];

if (!X_Client) exitWith {};

#include "x_macros.sqf"

_reason = _this select 0;

switch (_reason) do {
	case "start" : {
		_current_target_name = call SYG_getTargetTownName; // __TargetInfo
		_s = format [localize "STR_SYS_541", _current_target_name]; // "It seems that the enemy doesn't want to give up %1 and starts a counterattack. Search defensive positions, the attack will start in a few minutes..."

		// Todo: first play special radio signal, it is received only player who are:
		// 1. On base with any antenna alive
		// 2. In any vehicle except ATV, motocycle, bike
		// 3. Has radio in inventory
		"counterattack" call SYG_receiveRadio;
		sleep 5;

    	// Play relevant music
    	SYG_counterAttackTracks call SYG_playRandomTrack;

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
