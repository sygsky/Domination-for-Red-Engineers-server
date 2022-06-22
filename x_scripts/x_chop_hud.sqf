// by Xeno, x_scripts/x_chop_hud.sqf
private ["_control","_veh","_X_Chopper_Welcome"];

_X_Chopper_Welcome = nil;

#include "x_setup.sqf"

if (d_show_chopper_welcome) then {
	d_rsc_end = true;

	_X_Chopper_Welcome = {
		private ["_state","_veh"];
		d_rsc_end = false;
		_state = _this select 0;
		_veh = _this select 1;
		_welcome_str1 = format [localize "STR_CHOP_WELCOME", name player]; // "Welcome aboard, %1"

		_welcome_str2 = "";
		_welcome_str3 = "";
		if (format ["%1",_veh] in d_no_lift_chopper) then {
			_state = 2;
		};
		if (_state == 1) then {
			_welcome_str2 = localize "STR_CHOP_WELCOME_1"; // "This is the wreck lift chopper."
			_welcome_str3 = localize "STR_CHOP_WELCOME_2"; // "Remember, it can only lift wrecks."
		} else {
			if (_state == 0) then {
				_welcome_str2 = localize "STR_CHOP_WELCOME_3";  // "This is a normal lift chopper."
				_welcome_str3 = localize "STR_CHOP_WELCOME_4"; // "It can lift allmost any vehicle except wrecks."
			} else {
				_welcome_str2 = localize "STR_CHOP_WELCOME_5"; // "This is a normal chopper."
				_welcome_str3 = localize "STR_CHOP_WELCOME_6"; // "It is not able to lift anything."
			};
		};

		_end_welcome = time + 14;
		while {((vehicle player) != player) && (alive player) && (player == driver _veh)} do {
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
	waitUntil {sleep random 0.3;(vehicle player) != player};
	_veh = vehicle player;
	while { _veh != player} do {
		if (player == driver _veh) then {
			if (_veh isKindOf "Helicopter" && !(_veh isKindOf "ParachuteBase")) then {
				_is_in_complete_list = false;
				{
					call compile format ["
						if (%1 == _veh) exitWith {
							_is_in_complete_list = true;
						};
					", _x];
				} forEach d_chop_all;
				_is_in_lift_list = false;
				{
					call compile format ["
						if (%1 == _veh) exitWith {
							_is_in_lift_list = true;
						};
					", _x];
				} forEach d_chop_lift_list;
				_is_in_wreck_lift_list = false;
				if (!_is_in_lift_list) then {
					{
						call compile format ["
							if (%1 == _veh) exitWith {
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
						[_state,_veh] spawn _X_Chopper_Welcome;
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
								if (_veh == %1) exitWith {
									_possible_types = %2;
								};
							", _x select 0, _x select 3];
						} forEach d_choppers;
#endif
#ifdef __TT__
						if (playerSide == west) then {
							{
								call compile format ["
									if (_veh == %1) exitWith {
										_possible_types = %2;
									};
								", _x select 0, _x select 3];
							} forEach d_choppers_west;
						} else {
							{
								call compile format ["
									if (_veh == %1) exitWith {
										_possible_types = %2;
									};
								", _x select 0, _x select 3];
							} forEach d_choppers_racs;
						};
#endif;
						_search_height = 50;
						_lift_height = 50;
					};
					while { (vehicle player != player) && (alive player) && (player == driver _veh)} do {
						if (d_chophud_on) then {
							_nobjects = nearestObjects [_veh, ["LandVehicle","Air"],_search_height];
							_nearest = objNull;
							if (count _nobjects > 0) then {
								_dummy = _nobjects select 0;
								if (_dummy == _veh) then {
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
								_check_cond = (!(isNull _nearest) && (damage _nearest >= 1) && ((typeOf _nearest) in _possible_types));
							} else {
								_check_cond = (!isNull _nearest && ((typeOf _nearest) in _possible_types) && ((position _veh) select 2 > 2.5));
							};

							sleep 0.001;

							if (_check_cond) then {
								cutRsc["chopper_lift_hud", "PLAIN"];
								_control = DCHOP_LIFT_HUD displayCtrl 64440;
								if (_veh == HR4) then {
									_control ctrlSetText (localize "STR_CHOP_WRECK_HELI");
								} else {
									_control ctrlSetText (localize "STR_CHOP_LIFT_HELI");
								};
								_control = DCHOP_LIFT_HUD displayCtrl 64438;
								_type_name = [(typeOf _nearest),0] call XfGetDisplayName;
								if (!Vehicle_Attached) then {
									_control ctrlSetText format [localize "STR_CHOP_TYPE", _type_name];
								} else {
									_control ctrlSetText format [localize "STR_CHOP_LIFTING", _type_name];
								};

								_control = DCHOP_LIFT_HUD displayCtrl 64439;
								if (getText (configFile >> "CfgVehicles" >> (typeOf _nearest) >> "picture") != "picturestaticobject") then {
									_control ctrlSetText getText (configFile >> "CfgVehicles" >> (typeOf _nearest) >> "picture");
								} else {
									_control ctrlSetText "";
								};

								if (!Vehicle_Attached) then {
									_control = DCHOP_LIFT_HUD displayCtrl 64441;
									_control ctrlSetText format [localize "STR_CHOP_DIST", _veh distance _nearest];
									_nearest_pos = position _nearest;
									_pos_veh = position _veh;
									_nx = _nearest_pos select 0;_ny = _nearest_pos select 1;_px = _pos_veh select 0;_py = _pos_veh select 1;
									if ((_px <= _nx + 10 && _px >= _nx - 10) && (_py <= _ny + 10 && _py >= _ny - 10) && (_pos_veh select 2 < _lift_height)) then {
										_control2 = DCHOP_LIFT_HUD displayCtrl 64448;
										_control2 ctrlSetText _ui_ok;
									} else {
										_control = DCHOP_LIFT_HUD displayCtrl 64442;
										if ((position _veh) select 2 >= _lift_height) then {
											_control ctrlSetText localize ("STR_CHOP_HIGH");
										} else {
											_control ctrlSetText "";
										};
										_control2 = DCHOP_LIFT_HUD displayCtrl 64447;
										_control2 ctrlSetText _ui_tohigh;
										_angle = 0; _a = ((_nearest_pos select 0) - (_pos_veh select 0));_b = ((_nearest_pos select 1) - (_pos_veh select 1));
										if (_a != 0 || _b != 0) then {_angle = _a atan2 _b};

										_dif = (_angle - direction _veh);
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
									_control ctrlSetText format [localize "STR_CHOP_AGL", (position _nearest) select 2];
									_control = DCHOP_LIFT_HUD displayCtrl 64442;
									_control ctrlSetText localize "STR_CHOP_ATTACHED"; //"Attached";
								};
							} else {
								cutRsc["chopper_lift_hud2", "PLAIN"];
								_control = DCHOP_HUD2 displayCtrl 61422;
								if (!(format ["%1",_veh] in d_no_lift_chopper)) then {
									if (_is_in_wreck_lift_list) then {
										_control ctrlSetText "STR_CHOP_WRECK_HELI";
									} else {
										_control ctrlSetText "STR_CHOP_LIFT_HELI";
									};
								};
							};
						};
						sleep 0.231;
					};
					cutText["", "PLAIN"];
				} else {
					while {((vehicle player) != player) && (alive player) && (player == driver _veh)} do {
						cutRsc["chopper_lift_hud2", "PLAIN"];
						_control = DCHOP_HUD2 displayCtrl 61422;
						_control ctrlSetText (localize "STR_CHOP_ORDINAL");
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
