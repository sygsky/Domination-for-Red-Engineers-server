// by Xeno
private ["_vec","_dropaction","_vec_id"];
_dropaction = -8883;
_vec_id = -8884;
_vec = objNull;
while {true} do {
	waitUntil {alive player};
	waitUntil {sleep 0.312; (player hasWeapon "ACE_ANPRC77_Alice" || player hasWeapon "ACE_ANPRC77_Raid" || player hasWeapon "ACE_P159_RD90" || player hasWeapon "ACE_P159_RD54" || player hasWeapon "ACE_P159_RD99")};
	_dropaction = player addAction [localize "STR_SYS_99", "x_scripts\x_calldrop.sqf",[],-1,false]; // "Вызов снабжения"
	while {player hasWeapon "ACE_ANPRC77_Alice" || player hasWeapon "ACE_ANPRC77_Raid" || player hasWeapon "ACE_P159_RD90" || player hasWeapon "ACE_P159_RD54" || player hasWeapon "ACE_P159_RD99"} do {
		sleep 0.512;
		if (!alive player) exitWith {
			if (_dropaction != -8883) then {
				player removeAction _dropaction;
				_dropaction = -8883;
			};
			if (_vec_id != -8884) then {
				_vec removeAction _vec_id;
				_vec_id = -8884;
			};
		};
		if (vehicle player != player) then {
			_vec = vehicle player;
			if (player != driver _vec && _vec_id == -8884) then {
				_vec_id = _vec addAction [localize "STR_SYS_99", "x_scripts\x_calldrop.sqf",[],-1,false]; // "Вызов снабжения"
			} else {
				if (_vec_id != -8884 && player == driver _vec) then {
					_vec removeAction _vec_id;
					_vec_id = -8884;
				};
			};
		} else {
			if (_vec_id != -8884) then {
				_vec removeAction _vec_id;
				_vec_id = -8884;
			};
		};
	};
	if (alive player && (!(player hasWeapon "ACE_ANPRC77_Alice") && !(player hasWeapon "ACE_ANPRC77_Raid") && !(player hasWeapon "ACE_P159_RD90") && !(player hasWeapon "ACE_P159_RD54") && !(player hasWeapon "ACE_P159_RD99"))) then {
		if (_dropaction != -8883) then {
			player removeAction _dropaction;
			_dropaction = -8883;
		};
		if (_vec_id != -8884) then {
			_vec removeAction _vec_id;
			_vec_id = -8884;
		};
	};
	sleep 1.021;
};