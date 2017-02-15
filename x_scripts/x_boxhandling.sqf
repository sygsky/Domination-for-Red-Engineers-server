// by Xeno
private ["_i", "_boxa", "_boxpos", "_mname"];
if (!isServer) exitWith {};

while {true} do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	};
	if (count d_ammo_boxes > 0) then {
		for "_i" from 0 to (count d_ammo_boxes - 1) do {
			_boxa = d_ammo_boxes select _i;
			_boxpos = _boxa select 0;
			if (count _boxpos == 0) then {
				_mname = _boxa select 1;
				deleteMarker _mname;
				d_ammo_boxes set [_i, "X_RM_ME"];
				ammo_boxes = ammo_boxes - 1;
				["ammo_boxes",ammo_boxes] call XSendNetVarClient;
			};
			sleep 0.01;
		};
		d_ammo_boxes = d_ammo_boxes - ["X_RM_ME"];
	};
	sleep 1.321;
};