// by Xeno, x_newflagclient.sqf - executed on client comp only
// Params: _this = ["new_jump_flag",_flag, false]
if (!X_Client) exitWith {};

private ["_marker","_marker_name"];

#include "x_setup.sqf"

_marker_name = "";
call compile format ["_marker_name = ""paraflag%1"";", client_target_counter];
[_marker_name, position new_jump_flag,"ICON","ColorYellow",[0.5,0.5],"Parajump",0,"Flag1"] call XfCreateMarkerLocal;

if (d_own_side == "EAST") then  {//+++Sygsky: add more fun with flags
    new_jump_flag say "USSR";
};

_type_name = (if (d_jumpflag_vec != "") then {[d_jumpflag_vec,0] call XfGetDisplayName} else {""});

#ifndef __ACE__
if (d_jumpflag_vec == "") then {
	(localize "STR_SYS_339")/* "Создано новое место для десантирования." */ call XfHQChat;
} else {
		(localize "STR_SYS_340")/*"В городе создано место вызова техники." */call XfHQChat;
};
#endif

if (d_jumpflag_vec == "") then {
	new_jump_flag addAction [localize "STR_FLAG_1"/* "(Выбор места десантирования)" */,"AAHALO\x_paraj.sqf"];
} else {
	_text = format [localize "STR_FLAG_7"/* "(Create %1)" */,d_jumpflag_vec];
	new_jump_flag addAction [_text,"x_scripts\x_bike.sqf",[d_jumpflag_vec,1]];
};
_x addaction [localize "STR_FLAG_5"/* "{Rumours}" */,"scripts\rumours.sqf",""];

#ifdef __ACE__
_str = "";
if (d_jumpflag_vec == "") then {
	_box = "ACE_RuckBox" createVehicleLocal (position new_jump_flag);
	ClearMagazineCargo _box;
	ClearWeaponCargo _box;
	_box addweaponcargo ["ACE_ParachutePack",50];
	_str = "STR_SYS_339"; // "New flag for parajump created at current target."
	if (count _this > 2) then { if (! (_this select 2)) then { _str = "STR_SYS_339_1"; }; }; // "A new parajump flag was created at a secret base."
} else {
	_str = "STR_SYS_340"; // "New vehicle call flag created at current target."
	if (count _this > 2) then { if (! (_this select 2)) then { _str = "STR_SYS_340_1"; }; }; // "New vehicle call flag created at a secret base."
};
(localize _str)call XfHQChat;
#endif

if (true) exitWith {};
