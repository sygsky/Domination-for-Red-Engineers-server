// rain.sqf : to draw rainy environment around player on client computer
#include "x_setup.sqf"

while {true} do {
	#ifndef __REVIVE__
	waitUntil {sleep random 0.3;vehicle player in list rainy or vehicle player in list rainy2 or vehicle player in list rainy3};
	#endif
	#ifdef __REVIVE__
	_do_loop = true;
	while {_do_loop} do {
		if (!p_uncon) then {
			if (vehicle player in list rainy or vehicle player in list rainy2 or vehicle player in list rainy3) then {
				_do_loop = false;
			};
		} else {
			if (unconscious_body in list rainy or unconscious_body in list rainy2 or unconscious_body in list rainy3) then {
				_do_loop = false;
			};
		};
		sleep 0.321;
	};
	#endif
	2 setRain (2*(fRainMore-0.5))^2;
	sleep 2.345;
	if (fRainMore >= 0.55) then {
		2 setRain (2*(fRainMore-0.5))^2; //Restart the rain without having to use extreme overcast values.
		_nil = [] spawn {
			while {vehicle player in list rainy or vehicle player in list rainy2 or vehicle player in list rainy3} do {
				_rnd = fRainMore*(5+(random 5)); //reset in intervals to give the impression of slightly varying rain intensities.
				(_rnd*1.3) setRain (2*(fRainMore-0.5))^2; //fRainMore 0.5-1 should cause rain from 0 to 1, in a squared fashion.
				sleep (2.2*_rnd);
			};
		};
	};
// Randomize the thunder a little. Each time a new player enters the trigger a new high fRainMore value will be sent to clients.
	if (fRainMore >= 0.750 && player != vehicle player) then {
		_driver = driver (vehicle player);
		if (_driver == player) then {
			fRainMore = 0.75 + (random 0.35); //Just for a slightly better chance of thunder.
			["fRainMore",fRainMore] call XSendNetVarAll; // PVEH shouldn't be needed, this script will access it.
		};
	};
	if ((speed vehicle player) > 100) then {
		10 setOvercast fRainMore;
	} else {
		if ((speed vehicle player) > 25) then {
			20 setOvercast fRainMore;
		} else {
			if ((speed vehicle player) < 25) then {
				30 setOvercast fRainMore;
			};
		};
	};
	#ifndef __REVIVE__
	waitUntil {sleep random 0.3;not (vehicle player in list rainy or vehicle player in list rainy2 or vehicle player in list rainy3) or not alive player};
	#endif
	#ifdef __REVIVE__
	_do_loop = true;
	while {_do_loop} do {
		if (!p_uncon) then {
			if (not (vehicle player in list rainy or vehicle player in list rainy2 or vehicle player in list rainy3) or not alive player) then {
				_do_loop = false;
			};
		} else {
			if (not (unconscious_body in list rainy or unconscious_body in list rainy2 or unconscious_body in list rainy3) or isNull unconscious_body) then {
				_do_loop = false;
			};
		};
		sleep 0.221;
	};
	#endif
	if (not alive player) then {
		10 setOvercast fRainLess;
	} else {
		if ((speed vehicle player) > 100 or not alive player) then {
			10 setOvercast fRainLess;
		} else {
			if ((speed vehicle player) > 25) then {
				20 setOvercast fRainLess;
			} else {
				if ((speed vehicle player) < 25) then {
					30 setOvercast fRainLess;
				};
			};
		};
	};
	2 setRain 0.0;
	sleep 1.0;
};