// by Xeno
private ["_vec","_ari1","_vec_id","_artinum"];
_artinum = _this select 0;
_ari1 = -8881;
_vec_id = -8882;
_vec = objNull;
while {true} do {
	waitUntil {sleep 0.212; alive player};
	waitUntil {sleep 0.312; (player hasWeapon "ACE_ANPRC77_Alice") || (player hasWeapon "ACE_ANPRC77_Raid") || (player hasWeapon "ACE_P159_RD90") || (player hasWeapon "ACE_P159_RD54") || (player hasWeapon "ACE_P159_RD99")};
	switch (_artinum) do {
		case 1: {
			_ari1 = player addAction [localize "STR_SYS_98", "x_scripts\x_artillery.sqf",[],-1,false]; // "Вызвать артиллерию"
		};
		case 2: {
			_ari1 = player addAction [localize "STR_SYS_98", "x_scripts\x_artillery2.sqf",[],-1,false]; // "Вызвать артиллерию"
		};
	};
	while {(player hasWeapon "ACE_ANPRC77_Alice") || (player hasWeapon "ACE_ANPRC77_Raid") || (player hasWeapon "ACE_P159_RD90") || (player hasWeapon "ACE_P159_RD54") || (player hasWeapon "ACE_P159_RD99")} do {
		sleep 0.52;
		if (!alive player) exitWith {
			if (_ari1 != -8881) then {
				player removeAction _ari1;
				_ari1 = -8881;
			};
			if (_vec_id != -8882) then {
				_vec removeAction _vec_id;
				_vec_id = -8882;
			};
		};
		if (vehicle player != player) then {
			_vec = vehicle player;
			if (player != driver _vec && _vec_id == -8882) then {
				switch (_artinum) do {
					case 1: {
						_vec_id = _vec addAction [localize "STR_SYS_98", "x_scripts\x_artillery.sqf",[],-1,false]; // "Вызвать артиллерию"
					};
					case 2: {
						_vec_id = _vec addAction [localize "STR_SYS_98", "x_scripts\x_artillery2.sqf",[],-1,false]; // "Вызвать артиллерию"
					};
				};
			} else {
				if (_vec_id != -8882 && player == driver _vec) then {
					_vec removeAction _vec_id;
					_vec_id = -8882;
				};
			};
		} else {
			if (_vec_id != -8882) then {
				_vec removeAction _vec_id;
				_vec_id = -8882;
			};
		};
	};
	if (alive player && (!(player hasWeapon "ACE_ANPRC77_Alice") && !(player hasWeapon "ACE_ANPRC77_Raid") && !(player hasWeapon "ACE_P159_RD90") && !(player hasWeapon "ACE_P159_RD54") && !(player hasWeapon "ACE_P159_RD99"))) then {
		if (_ari1 != -8881) then {
			player removeAction _ari1;
			_ari1 = -8881;
		};
		if (_vec_id != -8882) then {
			_vec removeAction _vec_id;
			_vec_id = -8882;
		};
	};
	sleep 1.021;
};