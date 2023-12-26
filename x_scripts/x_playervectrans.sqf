// by Xeno, x_scripts/x_playervectrans.sqf, on client only
if (!XClient) exitWith {};

sleep 6;

dd_index = 0;
dd_first_index = -989;

d_getOutEHPoints = {
	private ["_vec", "_unit", "_var", "_dist"];
	_vec = _this select 0;
	_unit = _this select 2;
	if (alive player && _unit != player && isPlayer _unit && alive _unit) then {
		_var = _unit getVariable "D_TRANS_START";
		if (format ["%1",_var] != "<null>") then {
			_dist = _var distance position _unit;
			if ( _dist > d_transport_distance) then { // 2000 m.
				_var = ceil (_dist / 1000); // 2500 => 3, 3250 => 4, 9800 => 10
				//player addScore ( _var );
				_var call SYG_addBonusScore;
				(format [localize "STR_SYS_360"/* "За перевозку 1-го бойца +%1 очков" */, _var ]) call XfHQChat;
			};
		};
	};
	if (dd_index >= dd_first_index) then {
		_vec removeEventHandler ["getout",dd_index];
		dd_index = dd_index - 1;
	} else {
		dd_first_index = -989;
	};
};

[] spawn {
	private ["_vec", "_eindex", "_i"];
	while {true} do {
		waitUntil {sleep 0.407;vehicle player != player};
		_vec = vehicle player;
		_eindex = -1;
		if (_vec isKindOf "Car" || (_vec isKindOf "Helicopter" && !(_vec isKindOf "ParachuteBase"))) then {
			while {vehicle player != player} do {
				if (player == driver _vec && _eindex == -1) then {
					{
						if (_x != player && isPlayer _x) then {
							dd_index = _vec addEventHandler ["getout",{_this call d_getOutEHPoints}];
							_x setVariable ["D_TRANS_START", position _vec];
						};
					} forEach (crew _vec);
					
					_eindex = _vec addEventHandler ["getin",{
						dd_index = (_this select 0) addEventHandler ["getout",{_this call d_getOutEHPoints}];
						if (dd_first_index == -989) then {dd_first_index = dd_index};
						(_this select 2) setVariable ["D_TRANS_START", position (_this select 0)];
					}];
				};
				if (player != driver _vec && _eindex != -1) then {
					_vec removeEventHandler ["getin",_eindex];
					_eindex = -1;
					if (dd_index >= 0) then {
						if (dd_index > dd_first_index) then {
							for "_i" from dd_first_index to dd_index do {
								_vec removeEventHandler ["getout",_i];
							};
						};
					};
					dd_index = 0;
					dd_first_index = -989;
				};
				sleep 0.412;
			};
		} else {
			waitUntil {sleep 0.407;vehicle player == player};
		};
		if (_eindex != -1) then {
			_vec removeEventHandler ["getin",_eindex];
			_eindex = -1;
			if (dd_index >= 0) then {
				if (dd_index > dd_first_index) then {
					for "_i" from dd_first_index to dd_index do {
						_vec removeEventHandler ["getout",_i];
					};
				};
			};
			dd_index = 0;
			dd_first_index = -989;
		};
	};
};

if (true) exitWith {};