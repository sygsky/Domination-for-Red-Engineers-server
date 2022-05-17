/*
	author: Sygsky
	description: controls the installation of an antenna for radio communication with the USSR.
	returns: nothing
*/
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define RADAR_POINT = [13592,15591,0] // central point of the area to install radar
#define INSTALL_RADIUS 2000 // how far from the RADE_POINT
#define INSTALL_MIN_ALTITUDE 450 // minimal height above sea level to install

private ["_radar","_success"];
//
// Returns "" if radar is installed on correct height and place, else return MSG CSV error code
//
_destination_error = {
	private ["_pos"];
	if (radar_loaded) exitWith {"SYS_RADAR_0"}; // "Radar in loaded state, unload it before check"
	_pos = getPosASL _radar;
	if ( ([_pos, RADAR_POINT] call SYG_distance2D) > INSTALL_RADIUS) exitWith {"SYS_RADAR_1"}; // "You are too far from the installation zone"
	if ( (_pos select 2) < INSTALL_MIN_ALTITUDE ) exitWith {"SYS_RADAR_2"}; // "Radar must be installed on height not lower than %1 m., now you at %2 m."
	if ( (_radar call SYG_vehUpAngle) < 85 ) exitWith {"SYS_RADAR_3"}; // "The radar is set at a slope of %1 degree. Set it at an inclination of no more than 5 degrees"
	"" // Reached, no error !!!
};

// 0. Inform about mission in the

// 1. create antenna and truck on the base

_radar =  createVehicle ["Land_radar", [9472.9,9930,0], [], 0, "CAN_COLLIDE"];
_pos1 = getPos _radar;
_radar setPos [_pos select 0, _pos select 1, -5.7 ];
_radar setVectorUp [1,0,0];

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
    _veh setVehicleInit "this execVM ""x_missions\init_radio_truck.sqf""";
    processInitCommands;
	_vehs set [count _vehs, _veh];
}forEach[1,3];

// 2. wait until antenna killed or truck get it, inform all about antenna damage
_truck, = objNull;
while { (alive _radar) && (alive _truck) } do {
	if (!radar_loaded) {
		// check radio on the point
		if (call _destination_reached) {
			_success = true;
		}
	}
	sleep 3;
};

// 2.1. Check distance of the truck to the antenna center and if it is reached, add menu "Load antenna" to the track
// 3. if killed, SM failed
// 4. wait until antenna is set anywhere and is on the good height and stands stright enough, inform all about antenna damage
// 5. play special melody, may be sound of "Mayak" radiostation and SM is successfull
