// by Xeno
private ["_vec", "_caller", "_ok", "_XD_display", "_control", "_the_box", "_vec_name", "_hasbox", "_ctrl_but_drop", "_ctrl_but_load", "_move_controls", "_pic", "_index", "_pos"];
if (!X_Client) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_vec = _this select 0;
_caller = _this select 1;

_ok = createDialog "XD_VecDialog";

_XD_display = findDisplay 11002;

_control = _XD_display displayCtrl 44444;
if (getText (configFile >> "CfgVehicles" >> typeOf _vec >> "picture") != "picturestaticobject") then {
	_control ctrlSetText getText (configFile >> "CfgVehicles" >> typeOf _vec >> "picture");
} else {
	_control ctrlSetText "";
};

_the_box = (
	switch (d_own_side) do {
		case "RACS": {"WeaponBoxGuer"};
		case "EAST": {"WeaponBoxEast"};
		case "WEST": {"WeaponBoxWest"};
	}
);

_vec_name = (
	switch (_vec) do {
#ifndef __TT__
		case MRR1: { localize "STR_SYS_71"}; // "Мобильный респаун 1"
		case MRR2: { localize "STR_SYS_72"}; // "Мобильный респаун 2"
		case HR1: { format [localize "STR_SYS_78", 1 ] }; // "Транспортный вертолет 1"
		case HR2: { format [localize "STR_SYS_78", 2 ] }; // "Транспортный вертолет 2"
		case HR3: { format [localize "STR_SYS_78", 3 ] }; // "Транспортный вертолет 3"
		case HR4: { localize "STR_SYS_79"}; // "Вертолет для утилизации отходов"
#endif
#ifdef __TT__
		case MRR1: {"West MHQ One"};
		case MRR2: {"West MHQ Two"};
		case HR1: {"West Lift One"};
		case HR2: {"West Lift Two"};
		case HR3: {"West Lift Three"};
		case HR4: {"West Wreck Lift"};
		case MRRR1: {"Racs MHQ One"};
		case MRRR2: {"Racs MHQ Two"};
		case HRR1: {"Racs Lift One"};
		case HRR2: {"Racs Lift Two"};
		case HRR3: {"Racs Lift Three"};
		case HRR4: {"Racs Wreck Lift"};
#endif
	}
);

_control = _XD_display displayCtrl 44446;
_control ctrlSetText getText (configFile >> "CfgVehicles" >> _the_box >> "icon");

_control = _XD_display displayCtrl 44445;
_control ctrlSetText _vec_name;

_hasbox = _vec getVariable "d_ammobox";
if (format["%1",_hasbox] == "<null>") then {
	_hasbox = false;
};
if (d_old_ammobox_handling) then {
	_hasbox = true;
};

_control = _XD_display displayCtrl 44447;
_ctrl_but_drop = _XD_display displayCtrl 44448;
_ctrl_but_load = _XD_display displayCtrl 44452;
if (_hasbox) then {
	_control ctrlSetText "\CA\ui\data\objective_complete_ca.paa";
	_ctrl_but_load ctrlEnable false;
} else {
	_control ctrlSetText "\CA\ui\data\objective_incomplete_ca.paa";
	_ctrl_but_drop ctrlEnable false;
};

_move_controls = false;

if (_caller != driver _vec) then {
	_ctrl_but_load ctrlEnable false;
	_ctrl_but_drop ctrlEnable false;

#ifndef __TT__
	if (_vec in [MRR1,MRR2]) then {
#endif
#ifdef __TT__
	if (_vec in [MRR1,MRR2,MRRR1,MRRR2]) then {
#endif
		if (!(_caller in _vec)) then {
			lbClear 44449;
			_control = _XD_display displayCtrl 44449;
			{
				_pic = getText(configFile >> "cfgVehicles" >> _x >> "picture");
				_index = _control lbAdd ([_x,0] call XfGetDisplayName);
				_control lbSetPicture [_index, _pic];
				_control lbSetColor [_index, [1, 1, 0, 0.5]];
			} forEach d_create_bike;

			_control lbSetCurSel 0;
		} else {
			_move_controls = true;
		};
	};
} else {
	_move_controls = true;
};

#ifndef __TT__
if (_vec in [HR1,HR2,HR3,HR4]) then {
#endif
#ifdef __TT__
if (_vec in [HR1,HR2,HR3,HR4,HRR1,HRR2,HRR3,HRR4]) then {
#endif
	_move_controls = true;
};

if (_move_controls) then {
	_control = _XD_display displayCtrl 44453;
	_control ctrlShow false;
	_control = _XD_display displayCtrl 44449;
	_control ctrlShow false;
	_control = _XD_display displayCtrl 44451;
	_control ctrlShow false;
	_control = _XD_display displayCtrl 44450;
	_control ctrlShow false;
	_control = _XD_display displayCtrl 44454;
	_pos = ctrlPosition _control;
	_pos = [(_pos select 0) + 0.17, _pos select 1,_pos select 2,_pos select 3];
	_control ctrlSetPosition _pos;
	_control ctrlCommit 0;
	_control = _XD_display displayCtrl 44446;
	_pos = ctrlPosition _control;
	_pos = [(_pos select 0) + 0.17, _pos select 1,_pos select 2,_pos select 3];
	_control ctrlSetPosition _pos;
	_control ctrlCommit 0;
	_control = _XD_display displayCtrl 44447;
	_pos = ctrlPosition _control;
	_pos = [(_pos select 0) + 0.17, _pos select 1,_pos select 2,_pos select 3];
	_control ctrlSetPosition _pos;
	_control ctrlCommit 0;
	_control = _XD_display displayCtrl 44448;
	_pos = ctrlPosition _control;
	_pos = [(_pos select 0) + 0.17, _pos select 1,_pos select 2,_pos select 3];
	_control ctrlSetPosition _pos;
	_control ctrlCommit 0;
	_control = _XD_display displayCtrl 44452;
	_pos = ctrlPosition _control;
	_pos = [(_pos select 0) + 0.17, _pos select 1,_pos select 2,_pos select 3];
	_control ctrlSetPosition _pos;
	_control ctrlCommit 0;
};

waitUntil {!dialog || !alive player};

if (!alive player) then {
	closeDialog 11002;
};

if (true) exitWith {};
