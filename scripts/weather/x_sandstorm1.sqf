private ["_dust","_dust2","_herald","_pos","_times","_tribune","_object"];
if (!X_Client) exitWith {};

_object = objNull;

x_do_sandstorm = false;

while {true} do {
	if (!x_with_revive) then {
		waitUntil {sleep random 0.3;vehicle player in list rainy or vehicle player in list rainy2 or vehicle player in list rainy3};
		_object = vehicle player;
	} else {
		_do_loop = true;
		while {_do_loop} do {
			if (!p_uncon) then {
				if (vehicle player in list rainy or vehicle player in list rainy2 or vehicle player in list rainy3) then {
					_object = vehicle player;
					_do_loop = false;
				};
			} else {
				if (unconscious_body in list rainy or unconscious_body in list rainy2 or unconscious_body in list rainy3) then {
					_object = unconscious_body;
					_do_loop = false;
				};
			};
			sleep 0.321;
		};
	};
	x_do_sandstorm = true;
	_pos = position _object;
	_dust = "#particlesource" createVehicleLocal _pos;  
	_dust   setParticleParams [["\Ca\Data\Cl_basic.p3d", 1, 0, 1], "","Billboard", 1, 1, [0, 0, 0], [12, 0, 0], 5, 0.2, 0.1568, 0.0, [10, 10, 50],[[0.7,0.6,0.5,0.01],[0.7,0.6,0.5,0.05],[0.7,0.6,0.5,0.01]],[0, 1], 1, 0, "", "", vehicle player];
	_dust setParticleRandom   [0, [10, 10, 0], [2, 1, 0], 0, 0, [0, 0, 0, 0], 0, 0];
	_dust setParticleCircle [0.6, [1, 1, 0]];
	_dust setDropInterval 0.01*1;
	
	_dust2 = "#particlesource" createVehicleLocal _pos;
	_dust2 setParticleParams [["\Ca\Data\Cl_basic.p3d",   1, 0, 1], "","Billboard", 1, 1,[0, 0, 0],[20, 0, 0], 5, 0.2, 0.1568, 0.0, [5, 10, 50],[[0.7/3,0.6/3,0.5/3,0.01],[0.7/3,0.6/3,0.5/3,0.01],[0.7/3,0.6/3,0.5/3,0.01]],[0, 1], 1, 0, "", "", vehicle player];
	_dust2 setParticleRandom   [0, [10, 10, 0], [2, 1, 0], 0, 0, [0, 0, 0, 0], 0, 0];
	_dust2 setParticleCircle [0.6, [1, 1, 0]];
	_dust2 setDropInterval 0.01*1;
	
	_times = "#particlesource" createVehicleLocal _pos;  
	_times   setParticleParams [["\ca\Desert2\Data\Prop\gnews1.p3d", 5, 3, 5], "","SpaceObject", 1,10,[0, 0, 0], [15,0,0],1, 1, 0.7777,  0.0,[0,1,1,1,0],[[1,1,1,1]], [0.7], 1, 0, "", "", vehicle player];
	_times setParticleRandom [0, [20, 20, 0], [1, 1, 0], 2, 0.3, [0, 0, 0, 0], 0, 0];
	_times setParticleCircle [0.1, [1, 1, 0]];
	_times setDropInterval 1;
	
	_herald = "#particlesource" createVehicleLocal _pos;  
	_herald   setParticleParams [["\ca\Desert2\Data\Prop\gnews2.p3d", 5, 3, 5], "", "SpaceObject", 1,     10,    [0, 0, 0], [15,0,0],        1, 1, 0.7777, 0.0,           [0,1,1,1,0],        [[1,1,1,1]], [0.7], 1, 0, "", "", vehicle player];
	_herald setParticleRandom [0, [20, 20, 0], [1, 1, 0], 2, 0.3, [0, 0, 0, 0], 0, 0];
	_herald setParticleCircle [0.1, [1, 1, 0]];
	_herald setDropInterval 1;
	
	_tribune = "#particlesource" createVehicleLocal _pos; 
	_tribune   setParticleParams [["\ca\Desert2\Data\Prop\gnews3.p3d", 5, 3, 5], "", "SpaceObject", 1,    10,    [0, 0, 0], [15,0,0],        1, 1, 0.7777, 0.0,           [0,1,1,1,0],        [[1,1,1,1]], [0.7], 1, 0, "", "", vehicle player];
	_tribune setParticleRandom [0, [20, 20, 0], [1, 1, 0], 2, 0.3, [0, 0, 0, 0], 0, 0];
	_tribune setParticleCircle [0.1, [1, 1, 0]];
	_tribune setDropInterval 1;
	[_dust,_dust2,_times,_herald,_tribune,_object] spawn x_dosandstorm;
	if ((speed vehicle player) > 100) then {
		10 setFog 0.7;
		10 setOvercast 0.5;
	} else {
		if ((speed vehicle player) > 25) then {
			20 setFog 0.7;
			20 setOvercast 0.5;
		} else {
			if ((speed vehicle player) < 25) then {
				30 setFog 0.7;
				30 setOvercast 0.5;
			};
		};
	};
	if (!x_with_revive) then {
		waitUntil {sleep random 0.3;not (vehicle player in list rainy or vehicle player in list rainy2 or vehicle player in list rainy3) or not alive player};
	} else {
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
	};
	if (not alive player) then {
		10 setFog fFogLess;
		10 setOvercast fRainLess;
	} else {
		if ((speed vehicle player) > 100 or not alive player) then {
			10 setFog fFogLess;
			10 setOvercast fRainLess;
		} else {
			if ((speed vehicle player) > 25) then {
				20 setFog fFogLess;
				20 setOvercast fRainLess;
			} else {
				if ((speed vehicle player) < 25) then {
					30 setFog fFogLess;
					30 setOvercast fRainLess;
				};
			};
		};
	};
	x_do_sandstorm = false;
	sleep 1.012;
};