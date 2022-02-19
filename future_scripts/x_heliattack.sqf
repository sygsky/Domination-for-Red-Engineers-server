// by Xeno

_heli = _this select 0;
_heli_target = _this select 1;

if !(local server) exitWith{};

_heli reveal _heli_target;
sleep 0.2;
_heli doTarget _heli_target;

for "_i" from 1 to 30 step 1 do {
 	_heli fire (weapons _heli select 1);
	sleep 0.1;
};

