// by Xeno, x_scripts/x_createnexttargetclient.sqf
private ["_current_target_name","_current_target_pos","_marker","_t_array","_radious","_sound"];
if (!X_Client) exitWith{};
hint localize format["+++ x_createnexttargetclient.sqf: resolved targets counter %1", count resolved_targets];
if (count resolved_targets <= 0) then { // if it is still first town, wait 30 seconds to allow intro music to be completed
	sleep 30;
	_sound = "desant";
} else  {
	sleep 1.012;
	_sound = call SYG_invasionSound;
};
_t_array = target_names select current_target_index;

#define OBJECT_ID (_t_array select 3)

_current_target_pos = _t_array select 0;
_current_target_name = _t_array select 1;
// _radious = (_t_array select 2) max 300; // marker is create with radius minimum 300, in real active radius may be smaller (e.g. Somato is 230!!!)
_radious = _t_array select 2; // real town radius

[_current_target_name, _current_target_pos,"ELLIPSE","ColorRedAlpha",[_radious,_radious]] call XfCreateMarkerLocal;
"dummy_marker" setMarkerPosLocal _current_target_pos;

"1" objStatus "DONE"; // Paraiso airport (future start target, under development)
call compile format ["""%1"" objStatus ""ACTIVE"";", OBJECT_ID];
hint localize format ["+++ ""%1"" objStatus ""ACTIVE"";", OBJECT_ID];

// if town is big type info about it:  "Текущая цель :Nnnn (большая)"
if ( (_t_array select 2) >= big_town_radious) then { _current_target_name = format["%1 (%2)", _current_target_name, localize "STR_SYS_271_1"];};

(format [localize "STR_SYS_271", _current_target_name]) call XfHQChat; // "Next target is: %1"
hint localize format ["+++ x_createnexttargetclient.sqf: %1, radious %2 m", format[localize "STR_SYS_271", _current_target_name], _radious];
hint format[localize "STR_SYS_271", _current_target_name];

if (count resolved_targets <= 0) then { // if it is still first town, show white big message on the screen
	titleText[ format[localize "STR_SYS_271_0", _current_target_name], "PLAIN DOWN" ]; // "Enemy troops are landing in the ""%1"" area!"
};

playSound _sound;

target_clear = false; // set town state as occupied

sleep 1;

if (true) exitWith {};
