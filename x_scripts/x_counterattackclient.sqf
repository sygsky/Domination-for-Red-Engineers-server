// by Xeno, x_scripts\x_counterattackclient.sqf: counter attack execution
//
// call: ["an_countera", "start_real" <,_sound>] execVM "x_scripts\x_counterattackclient.sqf";
//
private ["_reason","_sound","_str"];

if (!X_Client) exitWith {};

#include "x_macros.sqf"

_reason = _this select 1;
switch (_reason) do {
	case "start" : {
		_current_target_name = call SYG_getTargetTownName; // __TargetInfo

		// first play special radio signal, it is received only player who are:
		// 1. Near any antenna alive
		// 2. In any vehicle except ATV, motocycle, bike
		// 3. Has radio in inventory
		"counterattack" call SYG_receiveRadio;
		sleep 5;

    	// Play relevant music if any set (_this select 2) and show music title if possible
    	if ((count _this) > 2) then { // sound is present
    		_sound = _this select 2;
			if ((typeName _sound) == "ARRAY") then { // Arma internal soundtrack
				_str = localize format["STR_%1", _sound select 0];
			} else {
				_str = localize format["STR_%1", _sound]
			};
			if ( _str != "") then { // title defined and found
				["say_sound","PLAY",_sound,0,30] call XHandleNetStartScriptClient; // show known music title on this client computer
			} else {
				_sound call SYG_playRandomTrack;
			};
    	};

		[format [localize "STR_SYS_541", _current_target_name], "HQ"] call XHintChatMsg; // "It seems that the enemy doesn't want to give up %1 and starts a counterattack. Search defensive positions, the attack will start in a few minutes..."
	};
	case "start_real": {
		[localize "STR_SYS_541_1", "HQ"] call XHintChatMsg; // "The counterattack starts. Hold the current target. Good luck and god help us all...
	};
	case "over" : {
		[localize "STR_SYS_541_2", "HQ"] call XHintChatMsg; // "Good job. The counterattack was defeated."
	};
};

if (true) exitWith {};
