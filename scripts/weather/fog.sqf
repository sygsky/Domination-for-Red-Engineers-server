// fog.sqf : to draw fogged environment around player on client computer
#include "x_setup.sqf"

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
	if ((speed vehicle player) > 100) then {
		10 setFog fFogMore;
	} else {
		if ((speed vehicle player) > 25) then {
			20 setFog fFogMore;
		} else {
			if ((speed vehicle player) < 25) then {
				30 setFog fFogMore;
			};
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
	if (not alive player) then {
		10 setFog fFogLess;
	} else {
		if ((speed vehicle player) > 100 or not alive player) then {
			10 setFog fFogLess;
		} else {
			if ((speed vehicle player) > 25) then {
				20 setFog fFogLess;
			} else {
				if ((speed vehicle player) < 25) then {
					30 setFog fFogLess;
				};
			};
		};
	};
	sleep 1.0;
};