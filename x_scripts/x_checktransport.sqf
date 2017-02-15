// by Xeno
private ["_chopper","_nr"];
_chopper = _this select 0;

_nr = 1;
if (_chopper == mr2_lift_chopper) then {_nr = 2;};

call compile format ["
while {mr%1_in_air && !isNull (driver _chopper)} do {sleep 2.453;};
if (mr%1_in_air && isNull (driver _chopper)) then {mr%1_lift_chopper = objNull;mr%1_in_air = false;[""mr%1_in_air"",mr%1_in_air] call XSendNetStartScriptClient;};
", _nr];

if (true) exitWith {};
