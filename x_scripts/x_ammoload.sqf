// by Xeno, x_scripts/x_ammoload.sqf
if (!XClient) exitWith {};

#include "x_setup.sqf"

#ifdef __TT__
if (d_own_side == "WEST") then {
#endif
[] spawn {
	private ["_old_vec","_vec"];
	_old_vec = objNull;
	_vec = objNull;
	while {true} do {
		_nobjs = nearestObjects [AMMOLOAD, d_check_ammo_load_vecs, 5];
		if (count _nobjs > 0) then {
			_vec = _nobjs select 0;
		} else {
			_vec = objNull;
			_old_vec = objNull;
		};
		if (!isNull _vec && alive _vec) then {
			if (local (driver _vec) || player == driver _vec) then {
				_thebox = _vec getVariable "d_ammobox";
				if (format["%1",_thebox] == "<null>") then {
					_thebox = false;
				};
				if (_vec != _old_vec) then {
					if (_thebox) then {
						[_vec, localize "STR_SYS_406"] call XfVehicleChat; // "This vehicle already has an ammobox loaded"
						_old_vec = _vec;
					} else {
						if (ammo_boxes >= max_number_ammoboxes) then {
							[_vec, format [ localize "STR_SYS_406_1", max_number_ammoboxes]] call XfVehicleChat; // "Maximum number ammo boxes (%1) already loaded... Please pick up a dropped box..."
							_old_vec = _vec;
						} else {
							[_vec, localize "STR_SYS_406_2"] call XfVehicleChat; // "Loading ammobox... please wait..."
							sleep 5;
							_vec setVariable ["d_ammobox", true];
							_old_vec = _vec;
							[_vec, localize "STR_SYS_406_3"] call XfVehicleChat; // "Ammo box loaded... ready !!!"
							["d_ammo_load", _vec, true] call XSendNetStartScriptAll;
							ammo_boxes = ammo_boxes + 1;
						};
					};
				};
			};
		};
		sleep 1.023;
	};
};
#ifdef __TT__
};
[] spawn {
	private ["_old_vec","_vec"];
	_old_vec = objNull;
	_vec = objNull;
	while {true} do {
		_nobjs = nearestObjects [AMMOLOAD2, d_check_ammo_load_vecs, 5];
		if (count _nobjs > 0) then {
			_vec = _nobjs select 0;
		} else {
			_vec = objNull;
			_old_vec = objNull;
		};
		if (!isNull _vec && alive _vec) then {
			if (local (driver _vec) || player == driver _vec) then {
				_thebox = _vec getVariable "d_ammobox";
				if (format["%1",_thebox] == "<null>") then {
					_thebox = false;
				};
				if (_vec != _old_vec) then {
					if (_thebox) then {
						[_vec, localize "STR_SYS_406"] call XfVehicleChat;
						_old_vec = _vec;
					} else {
						if (ammo_boxes >= max_number_ammoboxes) then {
							[_vec, format [localize "STR_SYS_406_1", max_number_ammoboxes]] call XfVehicleChat;
							_old_vec = _vec;
						} else {
							[_vec,  localize "STR_SYS_406_2"] call XfVehicleChat;
							sleep 5;
							_vec setVariable ["d_ammobox", true];
							["d_ammo_load", _vec, true] call XSendNetStartScriptAll;
							_old_vec = _vec;
							[_vec,  localize "STR_SYS_406_3"] call XfVehicleChat;
							ammo_boxes = ammo_boxes + 1;
						};
					};
				};
			};
		};
		sleep 1.023;
	};
};
#endif
