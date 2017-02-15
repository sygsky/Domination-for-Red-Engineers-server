// open.sqf, called on player respawn
private ["_ok","_unit"];
_unit = _this select 1;

#include "x_setup.sqf"

if (!(local _unit)) exitWith {};
if (!(isPlayer _unit)) exitWith {};
sleep d_respawn_delay;
if (dialog) then {closeDialog 0};

[-1] execVM "GRU_Scripts\GRU_removedoc.sqf"; // remove map just in case

beam_target = -1;
tele_dialog = 0; // 0 = respawn, 1 = teleport

_ok = createDialog "TeleportModule";

_display = findDisplay 100001;
_ctrl = _display displayCtrl 100102;
_ctrl ctrlSetText localize "STR_SYS_30"; //"Респаун";
_ctrl = _display displayCtrl 100111;
_ctrl ctrlSetText localize "STR_SYS_20"; // "Выбор места возрождения"

x_loop_end = false;

[d_last_telepoint] execVM "dlg\update_target.sqf";

[] spawn {
	while {!x_loop_end && alive player && dialog} do {
		if (!x_loop_end && alive player) then {execVM "dlg\update_dlg.sqf";};
		sleep 1.012;
	};
	if (!alive player) then {
		closeDialog 100001;
	};
};

if (true) exitWith {};


