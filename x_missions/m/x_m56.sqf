// by Sygsky, radar installation mission (#410, request by Rokse). x_missions/m/x_m56.sqf
#include "x_setup.sqf"
#include "x_macros.sqf"

#define RADAR_POINT = [13592,15591,0] // central point of the area to install radar
#define INSTALL_RADIUS 2000 // how far from the RADAR_POINT
#define INSTALL_MIN_ALTITUDE 450 // minimal height above sea level to install

x_sm_pos = [RADAR_POINT]; // index: 52,   Shot down chopper
x_sm_type = "undefined"; // "normal", "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {RADAR_POINT}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_56"; // "Re-establish communication with the GRU center..."
	current_mission_resolved_text = localize "STR_SM_56_0"; // "Mission accomplished, mast in place and communication operational!"
};

if (!isServer) exitWith {};

// 1. create antenna and trucks on the base
_radar =  createVehicle ["Land_radar", [9472.9,9930,0], [], 0, "CAN_COLLIDE"];
_pos1 = getPos _radar;
_radar setPos [_pos select 0, _pos select 1, -5.7 ];
_radar setVectorUp [1,0,0];
_radar addEventHandler ["killed", { _this execVM "x_missions\common\sideradar\remove_radar.sqf" } ]; // remove killed radar after some delay
_radar setVariable ["RADAR",true];
_radar setVehicleInit "[this,0] execVM ""x_missions/common/sideradar/radio_truck_init.sqf""";

// 2. create trucks on the base
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
    extra_mission_vehicle_remover_array set [ count extra_mission_vehicle_remover_array, _veh ];
    _veh setVehicleInit format ["[this,%1] execVM ""x_missions/common/sideradar/radio_truck_init.sqf""", (count _vehs) + 1 ];
    processInitCommands;
	_vehs set [count _vehs, _veh];
} forEach[ 1, 3 ];

[x_sm_pos,_radar,_vehs]  execVM "x_missions\common\x_sideradio.sqf";

// TODO: add enemy infantry patrols on the way to the destination point

if (true) exitWith {};