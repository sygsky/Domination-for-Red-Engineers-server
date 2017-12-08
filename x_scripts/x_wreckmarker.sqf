// by Xeno, x_scripts/x_wreckmarker.sqf
private ["_vehicle", "_mname", "_sav_pos", "_type_name", "_marker", "_i", "_element"];
if (!isServer) exitWith {};
#include "x_setup.sqf"
#include "x_macros.sqf"
_vehicle = _this;
while {alive _vehicle} do {sleep 1.532 + random 2.2};
while {speed _vehicle > 4} do {sleep 1.532 + random 2.2;};
sleep 0.01;
if ((vectorUp _vehicle) select 2 < 0) then {_vehicle setVectorUp [0,0,1]};
while {speed _vehicle > 4} do {sleep 0.532 + random 1};
_mname = format ["%1", _vehicle];
_sav_pos = position _vehicle;
_type_name = [typeOf (_vehicle),0] call XfGetDisplayName;
[_mname, _sav_pos,"ICON","ColorBlue",[1,1],format [localize "STR_MIS_18", _type_name],0,"DestroyedVehicle"] call XfCreateMarkerGlobal; // "%1 wreck"
d_wreck_marker = d_wreck_marker + [[_mname, _sav_pos,_type_name]];
while {!isNull _vehicle && _vehicle distance (markerPos _marker) < 30} do {sleep 3.321 + random 2.2};
for "_i" from 0 to (count d_wreck_marker - 1) do {
	_element = d_wreck_marker select _i;
	if ((_element select 0) == _mname && format ["%1",(_element select 1)] == format ["%1",_sav_pos]) exitWith {
		d_wreck_marker set [_i, "X_RM_ME"];
	};
};
deleteMarker _marker;
d_wreck_marker = d_wreck_marker - ["X_RM_ME"];
_vehicle execVM "x_scripts\x_wreckmarker2.sqf";
if (true) exitWith {};