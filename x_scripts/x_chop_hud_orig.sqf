// by Xeno
private ["_control","_dam_str","_fuel_str","_vec","_X_Chopper_Welcome"];

_X_Chopper_Welcome = nil;

#include "x_setup.sqf"

if (d_show_chopper_welcome) then {
	d_rsc_end = true;

	_X_Chopper_Welcome = {
		private ["_state","_vec"];
		d_rsc_end = false;
		_state = _this select 0;
		_vec = _this select 1;
		_welcome_str1 = format ["Добро пожаловать на борт, %1!", name player];

		_welcome_str2 = "";
		_welcome_str3 = "";
		if (format ["%1",_vec] in d_no_lift_chopper) then {
			_state = 2;
		};
		if (_state == 1) then {
			_welcome_str2 = "Вертолет для транспортировки подбитой техники.";
			_welcome_str3 = "Напоминаем, этот вертолёт используется только для транспортировки подбитой техники.";
		} else {
			if (_state == 0) then {
				_welcome_str2 = "Это транспортный вертолет.";
				_welcome_str3 = "Используется для транспортировки грузов и легкой техники.";
			} else {
				_welcome_str2 = "Это транспортный вертолет.";
				_welcome_str3 = "Не предназначен для транспортировки грузов.";
			};
		};

		_end_welcome = time + 14;
		while {vehicle player != player && alive player && player == driver _vec} do {
			cutRsc["chopper_hud", "PLAIN"];
			_control = DCHOP_HUD displayCtrl 64438;
			_control ctrlSetText _welcome_str1;
			_control = DCHOP_HUD displayCtrl 64439;
			_control ctrlSetText _welcome_str2;
			_control = DCHOP_HUD displayCtrl 64440;
			_control ctrlSetText _welcome_str3;
			if (time >= _end_welcome) exitWith {};
			sleep 0.431;
		};
		cutText["", "PLAIN"];
		d_rsc_end = true;
	};
};

_ui_forward = "\CA\ui\data\ui_tankdir_forward_ca.paa";
_ui_back = "\CA\ui\data\ui_tankdir_back_ca.paa";
_ui_left = "\CA\ui\data\ui_tankdir_left_ca.paa";
_ui_right = "\CA\ui\data\ui_tankdir_right_ca.paa";
_ui_tohigh = "\CA\ui\data\ui_action_close_ca.paa";
_ui_ok = "\CA\ui\data\ui_tankdir_tower_ca.paa";

while {true} do {
	waitUntil {sleep random 0.3;vehicle player != player};
	_vec = vehicle player;
	while {vehicle player != player} do {
		if (player == driver _vec) then {
			if (_vec isKindOf "Helicopter" && !(_vec isKindOf "ParachuteBase")) then {
				_is_in_complete_list = false;
				{
					call compile format ["
						if (%1 == _vec) exitWith {
							_is_in_complete_list = true;
						};
					", _x];
				} forEach d_chop_all;
				_is_in_lift_list = false;
				{
					call compile format ["
						if (%1 == _vec) exitWith {
							_is_in_lift_list = true;
						};
					", _x];
				} forEach d_chop_lift_list;
				_is_in_wreck_lift_list = false;
				if (!_is_in_lift_list) then {
					{
						call compile format ["
							if (%1 == _vec) exitWith {
								_is_in_wreck_lift_list = true;
							};
						", _x];
					} forEach d_chop_wreck_lift_list;
				};
				if (d_show_chopper_welcome) then {
					if (_is_in_complete_list) then {
						_state = (
							if (_is_in_lift_list) then {
								0
							} else {
								if (_is_in_wreck_lift_list) then {
									1
								} else {
									2
								}
							}
						);
						[_state,_vec] spawn _X_Chopper_Welcome;
						sleep 0.321;
						waitUntil {d_rsc_end};
					};
				};
				if (_is_in_lift_list || _is_in_wreck_lift_list) then {
					_search_height = 0;
					_lift_height = 0;
					_possible_types = [];
					if (_is_in_wreck_lift_list) then {
						_possible_types = x_heli_wreck_lift_types;
						_search_height = 70;
						_lift_height = 50;
					} else {
#ifndef __TT__
						{
							call compile format ["
								if (_vec == %1) exitWith {
									_possible_types = %2;
								};
							", _x select 0, _x select 3];
						} forEach d_choppers;
#endif
#ifdef __TT__
						if (playerSide == west) then {
							{
								call compile format ["
									if (_vec == %1) exitWith {
										_possible_types = %2;
									};
								", _x select 0, _x select 3];
							} forEach d_choppers_west;
						} else {
							{
								call compile format ["
									if (_vec == %1) exitWith {
										_possible_types = %2;
									};
								", _x select 0, _x select 3];
							} forEach d_choppers_racs;
						};
#endif;
						_search_height = 50;
						_lift_height = 50;
					};
					while {vehicle player != player && alive player && player == driver _vec} do {
						if (d_chophud_on) then {
							_nobjects = nearestObjects [_vec, ["LandVehicle","Air"],_search_height];
							_nearest = objNull;
							if (count _nobjects > 0) then {
								_dummy = _nobjects select 0;
								if (_dummy == _vec) then {
									if (count _nobjects > 1) then {
										_nearest = _nobjects select 1;
									};
								} else {
									_nearest = _dummy;
								};
								_lift_height = 11;
							};

							_check_cond = false;
							if (_is_in_wreck_lift_list) then {
								_check_cond = (!(isNull _nearest) && (damage _nearest >= 1) && ((typeof _nearest) in _possible_types));
							} else {
								_check_cond = (!isNull _nearest && ((typeof _nearest) in _possible_types) && ((position _vec) select 2 > 2.5));
							};

							sleep 0.001;

							if (_check_cond) then {
								cutRsc["chopper_lift_hud", "PLAIN"];
								_control = DCHOP_LIFT_HUD displayCtrl 64440;
								if (_vec == HR4) then {
									_control ctrlSetText "Wreck Lift Chopper";
								} else {
									_control ctrlSetText "Lift Chopper";
								};
								_control = DCHOP_LIFT_HUD displayCtrl 64438;
								_type_name = [(typeof _nearest),0] call XfGetDisplayName;
								if (!Vehicle_Attached) then {
									_control ctrlSetText format ["Type: %1", _type_name];
								} else {
									_control ctrlSetText format ["Lifting %1", _type_name];
								};


								_control = DCHOP_LIFT_HUD displayCtrl 64439;
								if (getText (configFile >> "CfgVehicles" >> (typeof _nearest) >> "picture") != "picturestaticobject") then {
									_control ctrlSetText getText (configFile >> "CfgVehicles" >> (typeof _nearest) >> "picture");
								} else {
									_control ctrlSetText "";
								};

								if (!Vehicle_Attached) then {
									_control = DCHOP_LIFT_HUD displayCtrl 64441;
									_control ctrlSetText format ["Dist to vec: %1", _vec distance _nearest];
									_nearest_pos = position _nearest;
									_pos_vec = position _vec;
									_nx = _nearest_pos select 0;_ny = _nearest_pos select 1;_px = _pos_vec select 0;_py = _pos_vec select 1;
									if ((_px <= _nx + 10 && _px >= _nx - 10) && (_py <= _ny + 10 && _py >= _ny - 10) && (_pos_vec select 2 < _lift_height)) then {
										_control2 = DCHOP_LIFT_HUD displayCtrl 64448;
										_control2 ctrlSetText _ui_ok;
									} else {
										_control = DCHOP_LIFT_HUD displayCtrl 64442;
										if ((position _vec) select 2 >= _lift_height) then {
											_control ctrlSetText "Too high";
										} else {
											_control ctrlSetText "";
										};
										_control2 = DCHOP_LIFT_HUD displayCtrl 64447;
										_control2 ctrlSetText _ui_tohigh;
										_angle = 0; _a = ((_nearest_pos select 0) - (_pos_vec select 0));_b = ((_nearest_pos select 1) - (_pos_vec select 1));
										if (_a != 0 || _b != 0) then {_angle = _a atan2 _b};

										_dif = (_angle - direction _vec);
										if (_dif < 0) then {_dif = 360 + _dif;};
										if (_dif > 180) then {_dif = _dif - 360;};
										_angle = _dif;
										_control2 = DCHOP_LIFT_HUD displayCtrl 64444;
										if (_angle >= -70 && _angle <= 70) then {
											_control2 ctrlSetText _ui_forward;
										} else {
											_control2 ctrlSetText "";
										};
										_control2 = DCHOP_LIFT_HUD displayCtrl 64446;
										if (_angle >= 20 && _angle <= 160) then {
											_control2 ctrlSetText _ui_right;
										} else {
											_control2 ctrlSetText "";
										};
										_control2 = DCHOP_LIFT_HUD displayCtrl 64443;
										if (_angle <= -110 || _angle >= 110) then {
											_control2 ctrlSetText _ui_back;
										} else {
											_control2 ctrlSetText "";
										};
										_control2 = DCHOP_LIFT_HUD displayCtrl 64445;
										if (_angle <= -20 && _angle >= -160) then {
											_control2 ctrlSetText _ui_left;
										} else {
											_control2 ctrlSetText "";
										};
										sleep 0.001;
									};
								} else {
									_control = DCHOP_LIFT_HUD displayCtrl 64441;
									_control ctrlSetText format ["Dist attached to ground: %1", (position _nearest) select 2];
									_control = DCHOP_LIFT_HUD displayCtrl 64442;
									_control ctrlSetText "Attached";
								};
							} else {
								cutRsc["chopper_lift_hud2", "PLAIN"];
								_control = DCHOP_HUD2 displayCtrl 61422;
								if (!(format ["%1",_vec] in d_no_lift_chopper)) then {
									if (_is_in_wreck_lift_list) then {
										_control ctrlSetText "Wreck Lift Chopper";
									} else {
										_control ctrlSetText "Lift Chopper";
									};
								};
							};
						};
						sleep 0.231;
					};
					cutText["", "PLAIN"];
				} else {
					while {vehicle player != player && alive player && player == driver _vec} do {
						cutRsc["chopper_lift_hud2", "PLAIN"];
						_control = DCHOP_HUD2 displayCtrl 61422;
						_control ctrlSetText "Normal Chopper";
						sleep 0.421;
					};
				};
			};
		};
		sleep 0.432;
	};
	waitUntil {sleep random 0.2;vehicle player == player};
};

if (true) exitWith {};
