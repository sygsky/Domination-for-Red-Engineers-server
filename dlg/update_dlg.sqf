// Xeno, dlg\update_dlg.sqf: update info about MHQ status
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
        _mr1text ctrlSetText localize "STR_SYS_21";//"Mobile respawn 1 gets transported by airlift..."
        _mr1_available = false;
    } else {
        if (speed MRR1 > 4) then {
            _mr1text ctrlSetText localize "STR_SYS_23"; //"Mobile respawn 1 currently driving..."
            _mr1_available = false;
        } else
        {
            if (surfaceIsWater [(position MRR1) select 0,(position MRR1) select 1]) then {
                _mr1text ctrlSetText localize "STR_SYS_25";// "MHQ 1 is in water..."
                _mr1_available = false;
#ifdef __NO_TELEPORT_ON_DAMAGE__
            } else {
                if (damage MRR1 > __NO_TELEPORT_ON_DAMAGE__) then {
                    _mr1text ctrlSetText format[localize "STR_SYS_25_1", round((damage MRR1) * 100),"%"]; // "MHQ 1 damaged (%1) respawn not possible..."
                    _mr1_available = false;
                };
#endif
            };
        };
    };
    if (mr2_in_air) then {
        _mr2text ctrlSetText localize "STR_SYS_22";  //"Mobile respawn 2 gets transported by airlift..."
        _mr2_available = false;
    } else {
        if (speed MRR2 > 4) then {
            _mr2text ctrlSetText localize "STR_SYS_24"; //"Mobile respawn 2 currently driving..."
            _mr2_available = false;
        } else {
            if (surfaceIsWater [(position MRR2) select 0,(position MRR2) select 1]) then {
                _mr2text ctrlSetText localize "STR_SYS_26"; // "MHQ 2 is in water..."
                _mr2_available = false;
#ifdef __NO_TELEPORT_ON_DAMAGE__
            } else {
                if (damage MRR2 > 0.1) then {
                    _mr2text ctrlSetText format[localize "STR_SYS_25_2", round((damage MRR2) * 100),"%"]; // "MHQ 2 damaged (%1) respawn not possible..."
                    _mr2_available = false;
                };
#endif
            };
        };
    };
#ifdef __TT__
} else {
	if (mrr1_in_air) then {
		_mr1text ctrlSetText localize "STR_SYS_21"; // "Мобильный респаун 1 в воздухе...";
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
		_mr2text ctrlSetText localize "STR_SYS_22";  //"Мобильный респаун 2 в воздухе...";
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
