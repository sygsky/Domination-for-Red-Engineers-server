// by Sygsky, radar installation mission (#410, request by Rokse). x_missions/m/x_m56.sqf
#include "x_setup.sqf"
#include "x_macros.sqf"
#include "sideradio_vars.sqf"

x_sm_pos = [RADAR_POINT]; // index: 52,   Shot down chopper
x_sm_type = "undefined"; // "normal", "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {RADAR_POINT}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_56"; // "Re-establish communication with the GRU center..."
	current_mission_resolved_text = localize "STR_SM_056"; // "Mission accomplished, mast in place and communication operational!"
};

if (!isServer) exitWith {};

// 0. Enemy destroys GRU radio-must! before start of mission
if (alive d_radar) then {
// TODO: add code for radar destroy
};

// 1. create antenna the base
d_radar =  createVehicle ["Land_radar", [9472.9,9930,0], [], 0, "CAN_COLLIDE"];
d_radar setVehicleInit "this execVM ""x_missions\common\sideradar\radio_init.sqf""";

_pos = getPos d_radar;
d_radar setPos [_pos select 0, _pos select 1, -5.7 ];
d_radar setVectorUp [1,0,0];
d_radar addEventHandler ["killed", { _this execVM "x_missions\common\sideradar\radio_delete.sqf" } ]; // remove killed radar after some delay

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
    _veh setVehicleInit format ["this execVM ""x_missions\common\sideradar\radio_init.sqf""", (count _vehs) + 1 ];
	_vehs set [count _vehs, _veh];
} forEach[ 1, 3 ];
processInitCommands;
(_vehs select 1) lock true; // Lock 2nd truck only
//      0,     1,    2
_vehs  execVM "x_missions\common\x_sideradio.sqf";

// TODO: add enemy infantry patrols on the way to the destination point

if (true) exitWith {};