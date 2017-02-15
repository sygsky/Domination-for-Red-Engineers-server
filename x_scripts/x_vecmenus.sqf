while {true} do {
	_type = "";
	_vec = objNull;
	waitUntil {sleep (0.2 + random 0.3);vehicle player != player};
	if (count d_action_menus_vehicle > 0) then {
		_vec = vehicle player;
		_type = typeOf _vec;
		{
			_entry = _x;
			if (count (_entry select 0) > 0) then {
				if (_type in (_entry select 0)) then {
					_action = _vec addAction [_entry select 1, _entry select 2,[],-1,false];
					_entry set [3, _action];
				};
			} else {
				_action = _vec addAction [_entry select 1, _entry select 2,[],-1,false];
				_entry set [3, _action];
			};
		} forEach d_action_menus_vehicle;
	};
	waitUntil {sleep (0.2 + random 0.3);vehicle player == player};
	if (count d_action_menus_vehicle > 0) then {
		{
			_entry = _x;
			if (count (_entry select 0) > 0) then {
				if (_type in (_entry select 0)) then {
					_action = _entry select 3;
					_vec removeAction _action;
					_entry set [3, -1000];
				};
			} else {
				_action = _entry select 3;
				_vec removeAction _action;
				_entry set [3, -1000];
			};
		} forEach d_action_menus_vehicle;
	};
};
