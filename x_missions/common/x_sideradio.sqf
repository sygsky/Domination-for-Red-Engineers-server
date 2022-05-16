/*
	author: Sygsky
	description: controls the installation of an antenna for radio communication with the USSR.
	returns: nothing
*/
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

//private [""];

// this setPos [(getPos this) select 0, (getPos this) select 1, -5.7 ];this setVectorUp [0,1,0];

// 0. Inform about mission in the

// 1. create antenna and truck on the base

_radar =  createVehicle ["Land_radar", [9472.9,9930,0], [], 0, "CAN_COLLIDE"];
_pos1 = getPos _radar;
_radar setPos [_pos select 0, _pos select 1, -5.7 ];this setVectorUp [1,0,0];

#ifdef __ACE__
_ural = switch (d_own_side) do {
	case "EAST": {[[9452.5,9930.5,0],"UralCivil",[9447.5,9930.5],"UralCivil2"]};
	case "RACS";
	case "WEST": {[[9452.5,9930.5,0],"ACE_Truck5t_Open",[9447.5,9930.5],"ACE_Truck5t_Open"]};
};
#else
_ural = switch (d_own_side) do {
	case "EAST": {[[9452.5,9930.5,0],"UralCivil",[9447.5,9930.5],"UralCivil2"]};
	case "RACS";
	case "WEST": {[[9452.5,9930.5,0],"Truck5tOpen",[9447.5,9930.5],"Truck5tOpen"]};
};
#endif
_vehs = [];
{
	_veh = _ural select _x;
	_pos = _ural select (_x-1);
	_veh = createVehicle [_veh, _pos, [], 0, "NONE"];

	#ifdef __TT__
    _veh addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
    #endif

    #ifndef __TT_
        #ifdef __RANKED__
        _veh addEventHandler ["killed", { _this execVM "x_missions\common\eventKilledAtSM.sqf" } ]; // mark neighbouring users to be at SM
        #endif
    #endif

    extra_mission_vehicle_remover_array set [ count extra_mission_vehicle_remover_array, _veh ];
    _veh setVehicleInit "";
    processInitCommands;
	_vehs set [count _vehs, _veh];
}forEach[1,3];

// 2. wait until antenna killed or truck get it, inform all about antenna damage
while {} do {
	sleep 3;
}

// 2.1. Check distance of the truck to the antenna center and if it is reached, add menu "Load antenna" to the track
// 3. if killed, SM failed
// 4. wait until antenna is set anywhere and is on the good height and stands stright enough, inform all about antenna damage
// 5. play special melody, may be sound of "Mayak" radiostation and SM is successfull
