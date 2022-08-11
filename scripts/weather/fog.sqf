// fog.sqf : to draw fogged environment around player on client computer
#include "x_setup.sqf"
_next_fog_sound = time;
while {true} do {
	#ifndef __REVIVE__
	waitUntil {sleep random 0.3;vehicle player in list foggy};
	#endif
	#ifdef __REVIVE__
	_do_loop = true;
	while {_do_loop} do {
		if (!p_uncon) then {
			if (vehicle player in list foggy) then {
				_do_loop = false;
			};
		} else {
			if (unconscious_body in list foggy) then {
				_do_loop = false;
			};
		};
		sleep 0.321;
	};
	#endif

	// we are entering foggy zone, try to play corresponding sound
	if (time > _next_fog_sound) then { // it is time to play fog sound
		["say_sound","PLAY","tuman",0,30] call XHandleNetStartScriptClient; // show music title on playing
		_next_fog_sound = time + 10800; // three hours interval for the next fog sound
	};
    _speed = speed vehicle player;
	if (_speed > 100) then {
		10 setFog fFogMore; // 100..
	} else {
		if (_speed > 25) then {
			20 setFog fFogMore; // 25..100
		} else {
			30 setFog fFogMore; // .. 25
		};
	};
	#ifndef __REVIVE__
	waitUntil {sleep random 0.3;not (vehicle player in list foggy) or not alive player};
	#endif
	#ifdef __REVIVE__
	_do_loop = true;
	while {_do_loop} do {
		if (!p_uncon) then {
			if (not (vehicle player in list foggy) or not alive player) then {
				_do_loop = false;
			};
		} else {
			if (not (unconscious_body in list foggy) or isNull unconscious_body) then {
				_do_loop = false;
			};
		};
		sleep 0.221;
	};
	#endif
	// we exiting foggy zone
	if (not alive player) then {
		10 setFog fFogLess;
	} else {
	    _speed = speed vehicle player;
		if (_speed > 100) then {
			10 setFog fFogLess; // 100..
		} else {
			if (_speed > 25) then {
				20 setFog fFogLess; // 25..100
			} else {
				30 setFog fFogLess; // .. 25
			};
		};
	};
	sleep 1.0;
};