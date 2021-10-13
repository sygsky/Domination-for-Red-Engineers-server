// by Xeno, dlg\teleport.sqf - teleport from base flag pole!
private ["_caller","_ok","_vehicle"];

#include "x_setup.sqf"

//player groupChat format["+++ teleport.sqf: %1", _this];

_caller == objNull;
_mhqcall = false;
if ( count _this  > 0)
    then { _caller = _this select 1; } // called from FLAG_BASE or other building (flag object), not from MHQ Menu
    else { _caller = player; _mhqcall = true}; // without parameters it is called from MHQ menus as follow: action = "closeDialog 0;_handle = [] execVM ""dlg\teleport.sqf""";

if (vehicle _caller != _caller) exitWith {
	localize "STR_SYS_73" call XfGlobalChat; // "Teleport not available in a vehicle !!!"
};

if (!isNull (flag _caller)) exitWith {
	localize "STR_SYS_74" call XfGlobalChat; // "You are carrying the flag. Teleport is not possible !!!"
};

if ( !isNil "player_is_on_town_raid" ) exitWith {
	localize "STR_GRU_39" call XfGlobalChat; // "Teleport isn't allowed during GRU task"
};

_is_swimmer = (if ((animationState player) in ["aswmpercmstpsnonwnondnon","aswmpercmstpsnonwnondnon_aswmpercmrunsnonwnondf","aswmpercmrunsnonwnondf_aswmpercmstpsnonwnondnon","aswmpercmrunsnonwnondf","aswmpercmsprsnonwnondf","aswmpercmwlksnonwnondf"]) then {true} else {false});
if (_is_swimmer) exitWith {
	localize "STR_SYS_75" call XfGlobalChat; // Teleporting not possible while swimming !!!"
};

#ifdef __TELEPORT_ONLY_WHEN_ALL_SERVICES_ARE_VALID__
if (!isNull d_jet_service_fac) exitwith {
	format[localize  "STR_SYS_75_1", localize "STR_SYS_220"] call XfGlobalChat;
};
if (!isNull d_chopper_service_fac) exitwith {
	format[localize  "STR_SYS_75_1", localize "STR_SYS_221"] call XfGlobalChat;
};
if (!isNull d_wreck_repair_fac) exitwith {
	format[localize  "STR_SYS_75_1", localize "STR_SYS_222"] call XfGlobalChat;
};
#endif

#ifdef __NO_TELEPORT_ON_DAMAGE__
_exit = false;
if ( _mhqcall ) then {
    // find nearest teleport vehicle
    _veh = nearestObject [_caller, "BMP2_MHQ"];
    if (isNull _veh) exitWith {};
    if (damage _veh > __NO_TELEPORT_ON_DAMAGE__) exitWith {
        format[localize "STR_SYS_75_2", round((damage _veh) * 100),"%"]  call XfGlobalChat; // "Teleporting not possible while MHQ has damage (%1%2)!!!"
        playSound "damaged";
        _exit = true;
    };
    if (damage _veh > (__NO_TELEPORT_ON_DAMAGE__ / 5)) then {
        format[localize "STR_SYS_75_3", round((damage _veh) * 100),"%"]  call XfGlobalChat; // ""Damage to MHQ %1%2, repair immediately, otherwise the teleport will stop working!"
        playSound "damaging";
    };
};
if (_exit) exitWith {false};
#endif

if (dialog) then {closeDialog 0};

beam_target = -1;
tele_dialog = 1; // 0 = respawn, 1 = teleport

_ok = createDialog "TeleportModule";

_display = findDisplay 100001;
_ctrl = _display displayCtrl 100102;
_ctrl ctrlSetText localize "STR_FLAG_0"; // "Teleport"
_ctrl = _display displayCtrl 100111;
_ctrl ctrlSetText localize "STR_SYS_69"; //"Выбор направления телепортирования";
_ctrl = _display displayCtrl 100107;
_ctrl ctrlShow false;

x_loop_end = false;

[d_last_telepoint] execVM "dlg\update_target.sqf";

[] spawn {
	while {!x_loop_end && alive player && dialog} do {
		if (!x_loop_end && alive player) then {execVM "dlg\update_dlg.sqf";};
		sleep 1.012;
	};
	if (!alive player) then {closeDialog 100001;};
};

if (true) exitWith {};
