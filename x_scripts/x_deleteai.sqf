// by Xeno
private ["_to_delete"];
_to_delete = _this select 0;

_to_delete removeAllEventHandlers "killed";
unassignVehicle _to_delete;
sleep 45 + random 15;
deleteVehicle _to_delete;

if (true) exitWith {};
