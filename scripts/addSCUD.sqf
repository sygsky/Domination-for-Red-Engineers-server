/*
    scripts\addSCUD.sqf

	author: Sygsky
	description: adds SCUD, hangar and control panel onto base
	returns: nothing
*/

_veh = createVehicle ["GIG_Scud", [9411,10063,0], [], 0, "NONE"];
_veh setDir 180;

_veh = createVehicle ["GIG_Hanger1", [9411,10081,0], [], 0, "NONE"];
_veh setDir 180;

_veh = createVehicle ["SCUD_config", [9416.6,10080,0.6], [], 0, "NONE"];
_veh setDir 270;

hint localize "+++ 3 SCUD objects added to base";
