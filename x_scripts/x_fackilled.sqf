// x_fackilled.sqf, by Xeno
private ["_fac","_pos","_index"];
if (!isServer) exitWith {};

_fac = _this select 0;
_pos = position _fac;

_index = -1;
for "_i" from 0 to (count d_aircraft_facs - 1) do {
	_element = d_aircraft_facs select _i;
	_apos = _element select 0;
	if (_apos distance _pos < 10) exitWith { // this factory is deep underground now (so Arma kills building)
		_index = _i;
	};
};

if (_index != -1) then {
	switch (_index) do {
		case 0: {d_jet_service_fac = _fac;["d_jet_service_fac",d_jet_service_fac] call XSendNetStartScriptClient;};
		case 1: {d_chopper_service_fac = _fac;["d_chopper_service_fac",d_chopper_service_fac] call XSendNetStartScriptClient;};
		case 2: {d_wreck_repair_fac = _fac;["d_wreck_repair_fac",d_wreck_repair_fac] call XSendNetStartScriptClient;};
	};
};

if (true) exitWith {};
