// by Xeno
private ["_i", "_element", "_vec", "_box_pos"];
if (!isServer) exitWith {};

while {true} do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	};
	for "_i" from 0 to (count d_check_boxes - 1) do {
		_element = d_check_boxes select _i;
		_vec = _element select 0;
		_box_pos = _element select 1;
		if (isNull _vec) then {
			d_check_boxes set [_i, "X_RM_ME"];
			d_ammo_boxes set [_i, "X_RM_ME"];
			ammo_boxes = ammo_boxes - 1;
			["ammo_boxes",ammo_boxes] call XSendNetVarClient;
			sleep 0.01;
			["d_rem_box",_box_pos] call XSendNetStartScriptClient;
		} else {
			if (_vec distance _box_pos > 30) then {
				d_check_boxes set [_i, "X_RM_ME"];
				d_ammo_boxes set [_i, "X_RM_ME"];
				ammo_boxes = ammo_boxes - 1;
				["ammo_boxes",ammo_boxes] call XSendNetVarClient;
				sleep 0.01;
				["d_rem_box",_box_pos] call XSendNetStartScriptClient;
			};
		};
		sleep 0.01;
	};
	sleep 0.043;
	d_ammo_boxes = d_ammo_boxes - ["X_RM_ME"];
	sleep 0.1;
	d_check_boxes = d_check_boxes - ["X_RM_ME"];
	sleep 5.321;
};