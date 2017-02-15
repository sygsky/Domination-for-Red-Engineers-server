private ["_display","_mr1text","_mr2text","_mr1_available","_mr2_available"];

#include "x_setup.sqf"

if (x_loop_end) exitWith {};

_display = findDisplay 100001;
_mr1text = _display displayCtrl 100105;
_mr2text = _display displayCtrl 100106;

_mr1_available = true;
_mr2_available = true;

_mr1text ctrlSetText "";
_mr2text ctrlSetText "";

#ifdef __TT__
if (playerSide == west) then {
#endif
if (mr1_in_air) then {
	_mr1text ctrlSetText localize "STR_SYS_21";// "Мобильный респаун 1 подготовлен для транспортировки по воздуху...";
	_mr1_available = false;
} else {
	if (speed MRR1 > 4) then {
		_mr1text ctrlSetText localize "STR_SYS_23"; //"Мобильный респаун 1 в движении...";
		_mr1_available = false;
	} else {
		if (surfaceIsWater [(position MRR1) select 0,(position MRR1) select 1]) then {
			_mr1text ctrlSetText localize "STR_SYS_25";// "Мобильный респаун 1 сейчас в воде...";
			_mr1_available = false;
		};
	};
};
if (mr2_in_air) then {
	_mr2text ctrlSetText localize "STR_SYS_22";  //"Мобильный респаун 2 подготовлен для транспортировки по воздуху...";
	_mr2_available = false;
} else {
	if (speed MRR2 > 4) then {
		_mr2text ctrlSetText localize "STR_SYS_24";// "Мобильный респаун 2 в движении...";
		_mr2_available = false;
	} else {
		if (surfaceIsWater [(position MRR2) select 0,(position MRR2) select 1]) then {
			_mr2text ctrlSetText localize "STR_SYS_26"; // "Мобильный респаун 2 сейчас в воде...";
			_mr2_available = false;
		};
	};
};
#ifdef __TT__
} else {
	if (mrr1_in_air) then {
		_mr1text ctrlSetText localize "STR_SYS_21"; // "Мобильный респаун 1 подготовлен для транспортировки по воздуху...";
		_mr1_available = false;
	} else {
		if (speed MRRR1 > 4) then {
			_mr1text ctrlSetText localize "STR_SYS_23"; // "Мобильный респаун 1 в движении...";
			_mr1_available = false;
		} else {
			if (surfaceIsWater [(position MRRR1) select 0,(position MRRR1) select 1]) then {
				_mr1text ctrlSetText localize "STR_SYS_25"; // "Мобильный респаун 1 сейчас в воде...";
				_mr1_available = false;
			};
		};
	};
	if (mrr2_in_air) then {
		_mr2text ctrlSetText localize "STR_SYS_22";  //"Мобильный респаун 2 подготовлен для транспортировки по воздуху...";
		_mr2_available = false;
	} else {
		if (speed MRRR2 > 4) then {
			_mr2text ctrlSetText localize "STR_SYS_24"; //"Мобильный респаун 2 в движении...";
			_mr2_available = false;
		} else {
			if (surfaceIsWater [(position MRRR2) select 0,(position MRRR2) select 1]) then {
				_mr2text ctrlSetText localize "STR_SYS_26"; // "Мобильный респаун 2 сейчас в воде...";
				_mr2_available = false;
			};
		};
	};
};
#endif

if (x_loop_end) exitWith {};

if (!_mr1_available) then {
	_button = _display displayCtrl 100108;
	_button ctrlEnable false;
	if (beam_target == 1) then {
		beam_target = -1;
		_textctrl = _display displayCtrl 100110;
		_textctrl ctrlSetText "";
	};
} else {
	_button = _display displayCtrl 100108;
	_button ctrlEnable true;
};

if (!_mr2_available) then {
	_button = _display displayCtrl 100109;
	_button ctrlEnable false;
	if (beam_target == 2) then {
		beam_target = -1;
		_textctrl = _display displayCtrl 100110;
		_textctrl ctrlSetText "";
	};
} else {
	_button = _display displayCtrl 100109;
	_button ctrlEnable true;
};

if (true) exitWith {};
