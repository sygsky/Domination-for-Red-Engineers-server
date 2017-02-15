// by Xeno
private ["_chopper","_nr"];
_chopper = _this select 0;

_nr = 1;
if (_chopper == mrr2_lift_chopper) then {_nr = 2;};

call compile format ["
while {mrr%1_in_air && !isNull (driver _chopper)} do {sleep 2.453;};
if (mrr%1_in_air && isNull (driver _chopper)) then {mrr%1_lift_chopper = objNull;mrr%1_in_air = false;[""mrr%1_in_air"",mrr%1_in_air] call XSendNetStartScriptClient;};
", _nr];

if (true) exitWith {};
