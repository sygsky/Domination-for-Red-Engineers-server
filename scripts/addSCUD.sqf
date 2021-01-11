/*
    scripts\addSCUD.sqf

	author: Sygsky
	description: adds SCUD, hangar and control panel onto base (by НЕ_МАСТЕР request)
	returns: nothing
*/

// TODO: add std "killed" event handler
_veh = createVehicle [ "GIG_Scud", [9411,10063,0], [], 0, "NONE" ];
_veh setDir 180;
//hint localize format[ "+++ veh %1: %2", typeof _veh, getPos _veh];

_veh = createVehicle [ "GIG_Hanger1", [9411,10081,0], [], 0, "NONE" ];
_veh setDir 180;
//hint localize format[ "+++ veh %1: %2", typeof _veh, getPos _veh];

_veh = createVehicle [ "GIG_ScudConfig", [9416.6,10080,0.6], [], 0, "NONE" ];
_veh setPos [9416.6,10080,0.6];
_veh setDir 270;
//hint localize format[ "+++ veh %1: %2", typeof _veh, getPos _veh];

hint localize "+++ 3 SCUD objects added to base";
