// Xeno, x_scripts/x_calldrop.sqf, called and worked on client ONLY
if (!X_Client) exitWith {};

private ["_array","_control","_display","_ok","_oldpos"];

#include "x_setup.sqf"

if (!para_available) exitWith {
	localize "STR_SYS_1125" call XfHQChat; // "Transport chopper in the air... Drop not available!"
};

#ifdef __RANKED__
_score = score player;
if (_score < (d_ranked_a select 16)) exitWith {
	(format [localize "STR_SYS_1126", _score,(d_ranked_a select 16)]) call XfHQChat; // You don't have enough points to call in an air drop. You need %2 points for an air drop, your current score is %1
};
#endif

#ifdef __ACE__
_exitacedrop = false;
if (d_with_ace_map) then {
	if (!(call XCheckForMap)) then {
		_exitacedrop = true;
		localize "STR_SYS_304" call XfHQChat; // "!!!!!!!!!!!! Нужна карта !!!!!!!!!!!"
	};
};
if (_exitacedrop) exitWith {};
#endif

["arti1_marker_1",position player,"ELLIPSE","ColorYellow",[d_drop_max_dist,d_drop_max_dist],"",0,"","FDiagonal"] call XfCreateMarkerLocal;

x_drop_type = "";
_oldpos = position X_DropZone;
_ok = createDialog "XD_AirDropDialog";
_display = findDisplay 77899;
_control = _display displayCtrl 11002;
_array = x_drop_array select 0;
_control ctrlSetText (_array select 0);
if (count x_drop_array > 1) then {
	_control = _display displayCtrl 11003;
	_array = x_drop_array select 1;
	_control ctrlSetText (_array select 0);
} else {
	ctrlShow [11003, false];
	ctrlShow [11004, false];
};
if (count x_drop_array > 2) then {
	_control = _display displayCtrl 11004;
	_array = x_drop_array select 2;
	_control ctrlSetText (_array select 0);
};

onMapSingleClick "X_DropZone setPos _pos;""x_drop_zone"" setMarkerPos _pos;";

waitUntil {x_drop_type != "" || !dialog || !alive player};

onMapSingleClick "";
if (!alive player) exitWith {
	if (dialog) then {
		closeDialog 77899;
	};
};

if (x_drop_type != "") then {
	deleteMarkerLocal "arti1_marker_1";
	if (player distance X_DropZone > d_drop_max_dist) exitWith {
		(format [localize "STR_SYS_1127", d_drop_max_dist]) call XfHQChat; // "You are to far away from the drop point, no line of sight !!! Get closer (<%1 m)."
		x_dropzone setPos _oldpos;
		"x_drop_zone" setMarkerPos _oldpos;
	};
	(format [localize "STR_SYS_1128", x_drop_type]) call XfHQChat; // "Calling in %1 air drop"
	#ifdef __RANKED__
	player addScore (d_ranked_a select 22) * -1;
	#endif
	["x_drop_type",x_drop_type,markerPos "x_drop_zone"] call XSendNetStartScriptServer;
} else {
	deleteMarkerLocal "arti1_marker_1";
	(localize "STR_SYS_1129") call XfHQChat; // "Air drop canceled"
	x_dropzone setPos _oldpos;
	"x_drop_zone" setMarkerPos _oldpos;
};

if (true) exitWith {};
