private ["_current_target_name","_current_target_pos","_marker","_t_array","_radious"];
if (!X_Client) exitWith{};

sleep 1.012;
_t_array = target_names select current_target_index;
_current_target_pos = _t_array select 0;
_current_target_name = _t_array select 1;
_radious = (_t_array select 2) max 300;

[_current_target_name, _current_target_pos,"ELLIPSE","ColorRed",[_radious,_radious]] call XfCreateMarkerLocal;
"dummy_marker" setMarkerPosLocal _current_target_pos;

"1" objStatus "DONE";
//call compile format ["""%1"" ObjStatus ""VISIBLE"";", current_target_index + 2];
//"1" objStatus "HIDDEN"; // remove initial goal
call compile format ["""%1"" ObjStatus ""ACTIVE"";", current_target_index + 2];

// if town is big type info about it:  "Текущая цель :Nnnn (большая)"
if ( (_t_array select 2) >= big_town_radious) then { _current_target_name = format["%1 (%2)", _current_target_name, localize "STR_SYS_271_1"];};


(format [localize "STR_SYS_271"/* "Текущая цель: %1" */, _current_target_name]) call XfHQChat;
//hint localize format ["x_createnexttargetclient.sqf: %1, radious %2 m", format[localize "STR_SYS_271", _current_target_name], _radious];
hint format[localize "STR_SYS_271", _current_target_name];

playMusic (["invasion","kwai","baraban","starwars"] call XfRandomArrayVal);

target_clear = false; // set town state as occupied

sleep 1;

if (true) exitWith {};
