// by Xeno: x_repwreck.sqf, rebuilds wreck vehicle, work only on server
private ["_rep_station","_name","_types","_wreck","_type","_dpos","_ddir","_new_vec"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_rep_station = _this select 0;
_name = _this select 1;
_types = _this select 2;

sleep 10;

while {true} do {
	_wreck = objNull;
	while {isNull _wreck} do {
		if (X_MP) then {
			waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
		};
		//__DEBUG_NET("x_repwreck.sqf",(call XPlayersNumber))
		sleep 2.432;
		if (isNull d_wreck_repair_fac) then {
			_wreck = [_rep_station,_types] call XGetWreck;
		};
	};
 	_player = objNull;
#ifdef __RANKED__
	// wreck vehicle detected on recovery service, lets award player who delivered it
	 _nearArr =   nearestObjects [getPos _rep_station, ["Man"], 30];
	 if (count _nearArr > 0 ) then {
	 	{
	 		if (isPlayer (driver  _x) && alive (driver _x)) exitWith { _player = driver  _x } ;
	 	} forEach _nearArr;
	 };
//	 hint localize format["+++ x_repwreck.sqf: count _nearArr == %1, _player %2", count _nearArr, typeOf _player];
#endif
	_type = typeOf _wreck;
	_dpos = position _wreck;
	_ddir = direction _wreck;
	deleteVehicle _wreck;
	sleep 1.012;
	_new_vec = _type createVehicle _dpos;
	_new_vec setDir _ddir;
	_new_vec setPos _dpos;
	sleep 0.3;
	_new_vec lock true;
	_type_name = [_type,0] call XfGetDisplayName;
	_player = if (isNull _player) then {""} else {name _player};
	x_wreck_repair = [_type_name, _name, 0, _player ];
	["x_wreck_repair", x_wreck_repair] call XSendNetStartScriptClient;

	_sleep_time = 120;
	if (_new_vec isKindOf "Plane") then {
#ifdef __AI__
	#ifdef __NO_AI_IN_PLANE__
		// prevent to enter AI as driver, pilot or commander into any plane. AI are too bad pilots)))
		_new_vec addEventHandler ["getin", {_this execVM  "scripts\SYG_eventPlaneGetIn.sqf"}];
	#endif
#endif

		_sleep_time = 360;
	} else {
		if (_new_vec isKindOf "Helicopter") then {
			_sleep_time = 240;
		};
	};
    //sleep (1 + random 1);
    //_new_vec say "horse"; //  whi-i-i-i-nn-y-i-i
    //["say_sound", _new_vec, "horse"] call XSendNetStartScriptClientAll; // set to all clients

	sleep _sleep_time + (random 10);
	_new_vec lock false;
	x_wreck_repair = [_type_name, _name, 1];
	["x_wreck_repair",x_wreck_repair] call XSendNetStartScriptClient;
	_new_vec execVM "x_scripts\x_wreckmarker.sqf";
#ifdef __REARM_SU34__
	_new_vec call SYG_rearmVehicleA; // try to rearm  upgraded vehicle
#endif
};

if (true) exitWith {};
