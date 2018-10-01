// by Xeno

_vec = _this select 0;
_state = _this select 3;

switch (_state) do {
	case 0: {
		d_chophud_on = false;
		_vec removeAction hud_id;
		hud_id = _vec addAction [localize "STR_HUD_ON", "x_scripts\x_sethud.sqf",1,-1,false];
	};
	case 1: {
		d_chophud_on = true;
		_vec removeAction hud_id;
		hud_id = _vec addAction [localize "STR_HUD_OFF", "x_scripts\x_sethud.sqf",0,-1,false];
	};
};

if (true) exitWith {};
