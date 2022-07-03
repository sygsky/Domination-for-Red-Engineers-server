// by Sygsky, radar installation mission (#410, request by Rokse). x_missions/m/x_m56.sqf
#include "x_setup.sqf"
#include "x_macros.sqf"
#include "sideradio_vars.sqf"

x_sm_pos = [RADAR_POINT]; // index: 52,   Shot down chopper
x_sm_type = "undefined"; // "normal", "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {x_sm_pos select 0}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = format[localize "STR_SM_56", RADAR_POINT call SYG_nearestLocationName, INSTALL_MIN_ALTITUDE]; // "Re-establish communication with the GRU center..."
	current_mission_resolved_text = localize "STR_SM_056"; // "Mission accomplished, mast in place and communication operational!"
};

if (!isServer) exitWith {};

// 0. Enemy destroys GRU radio-must! before start of mission
_cnt1 = 0;
if (alive d_radar) then {
	hint localize format["+++ x_m56.sqf: initial radar alive, try to bomb it"];
	if ( (_pos select 0) == 0 ) exitWith {
		hint localize format["+++ x_m56.sqf: initial radar (%1) pos is illegal (%2), exit destroy procedure!", typeOf d_radar, _pos];
	};
	_cnt = 10;
	_type = if (d_enemy_side == "WEST") then { "Sh_120_HE" } else { "Sh_125_HE" };
	_pos =  d_radar call SYG_getPos;
	// "Attention all! GRU radio relay mast is under attack!!!"
	["msg_to_user", "",  [ ["STR_RADAR_UNDER_ATTACK"] ], 0, 0, false, "losing_patience" ] call XSendNetStartScriptClient;
	for "_i" from 1 to _cnt do {
		[_pos, _type] call SYG_bombPos;
		sleep (0.923 + ((ceil (random 10)) / 10));
		if (!alive d_radar) exitWith{
			// "Attention all! GRU radio relay mast destroyed!"
			["msg_to_user", "",  [ ["STR_RADAR_BOMBED"] ], 0, 2, false, "tvpowerdown" ] call XSendNetStartScriptClient;
		};
		_cnt1 = _cnt1 + 1;
	};
};

hint localize format["+++ x_m56.sqf: initial radar %1 after %2 bomb[s]", if (alive d_radar) then {"alive"} else {"killed"}, _cnt1];

// 1. create antenna the base
d_radar =  createVehicle [RADAR_TYPE, [9472.9,9930,0], [], 0, "CAN_COLLIDE"];
publicVariable "d_radar";
d_radar setVehicleInit "this execVM ""x_missions\common\sideradar\radio_init.sqf""";

_pos = getPos d_radar;
d_radar setPos [_pos select 0, _pos select 1, -5.7 ];
d_radar setVectorUp [1,0,0];
d_radar addEventHandler ["killed", { _this execVM "x_missions\common\sideradar\radio_delete.sqf" } ]; // remove killed radar after some delay
["say_sound",d_radar, call SYG_rustyMastSound] call XSendNetStartScriptClient;
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
	sleep 2 + (random 2);
	_veh = _ural select _x;
	_pos = _ural select (_x-1);
	_veh = createVehicle [_veh, _pos, [], 0, "NONE"];
    extra_mission_vehicle_remover_array set [ count extra_mission_vehicle_remover_array, _veh ];
    _veh setVehicleInit format ["this execVM ""x_missions\common\sideradar\radio_init.sqf""", (count _vehs) + 1 ];
	_vehs set [count _vehs, _veh];
	["say_sound",_veh, call SYG_truckDoorCloseSound] call XSendNetStartScriptClient; //SYG_rustyMastSound
} forEach[ 1, 3 ];
_vehs call SYG_addToExtraVec; // add both vehicles to the remover array (cleaned after SM finish)
(_vehs select 1) lock true; // Lock 2nd truck only
processInitCommands;
//      0,     1,    2
_vehs  execVM "x_missions\common\x_sideradio.sqf";

// TODO: add enemy infantry patrols on the way to the destination point

if (true) exitWith {};