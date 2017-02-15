private ["_dust","_dust2","_herald","_pos","_times","_tribune","_vec","_pos","_soundsource","_use_vp"];
if (!X_Client) exitWith {};
_dust = _this select 0;
_dust2 = _this select 1;
_times = _this select 2;
_herald = _this select 3;
_tribune = _this select 4;
_object = _this select 5;

_use_vp = (if (_object == vehicle player) then {true} else {false});

while {x_do_sandstorm} do {
	_pos = (if (_use_vp) then {position vehicle player} else {position _object});
	_dust setPos _pos;
	_dust2 setPos _pos;
	
	if !(isnull (_pos nearestObject "house")) then {
		_times setPos _pos;
		_herald setPos _pos;
		_tribune setPos _pos;
	} else {
		_times setPos [0,0,0];
		_herald setPos [0,0,0];
		_tribune setPos [0,0,0];
	};
	sleep 1.016;
};

deleteVehicle _dust;
deleteVehicle _dust2;
deleteVehicle _times;
deleteVehicle _herald;
deleteVehicle _tribune;

if (true) exitWith {};