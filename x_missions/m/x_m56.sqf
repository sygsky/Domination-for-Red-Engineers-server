// by Sygsky, radar installation mission (#410, request by Rokse). x_missions/m/x_m56.sqf
#include "x_setup.sqf"
#include "x_macros.sqf"
#include "sideradio_vars.sqf"

x_sm_pos = [RADAR_INSTALL_POINT]; // index: 52,   Shot down chopper
x_sm_type = "undefined"; // "normal", "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {x_sm_pos select 0}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = format[localize "STR_SM_56", localize "STR_RADAR_TRUCK_FIRM_TITLE", RADAR_INSTALL_POINT call SYG_nearestLocationName, INSTALL_MIN_ALTITUDE]; // "Re-establish communication with the GRU center..."
	current_mission_resolved_text = localize "STR_SM_056"; // "Mission accomplished, mast in place and communication operational!"
};

if (!isServer) exitWith {};

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Start the service of radar+truck restoration
//
"BASE" execVM "x_missions\common\sideradar\radio_service.sqf";
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


// 0. Enemy destroys GRU radio-must! before start of mission
_cnt1 = 0;
if (alive d_radar) then {
	hint localize format["+++ x_m56.sqf: initial radar alive, try to bomb it"];
	_cnt = 10;
	_type = if (d_enemy_side == "WEST") then { "Sh_120_HE" } else { "Sh_125_HE" };
	_pos =  d_radar call SYG_getPos;

	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//++ "Attention all! GRU radio relay mast is under attack!!!" ++
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	["msg_to_user", "",  [ ["STR_RADAR_UNDER_ATTACK"] ], 0, 0, false, "losing_patience" ] call XSendNetStartScriptClient;
	for "_i" from 1 to _cnt do {
		sleep (0.923 + ((ceil (random 10)) / 10));
		[_pos, _type] call SYG_bombPos;
		if (!alive d_radar) exitWith{
			// "Attention all! GRU radio relay mast destroyed!"
			["msg_to_user", "",  [ ["STR_RADAR_BOMBED"] ], 0, 2, false, "tvpowerdown" ] call XSendNetStartScriptClient;
		};
		_cnt1 = _cnt1 + 1;
	};

} else { hint localize format["+++ x_m56.sqf: initial radar is not alive, no need to bomb it"]; };

hint localize format["+++ x_m56.sqf: initial radar %1 after %2 bomb[s]", if (alive d_radar) then {"alive"} else {"killed"}, _cnt1];

// 1. Wait for antenna and truck to be alive (is provided by radio_service.sqf)
execVM "x_missions\common\x_sideradio.sqf";

if (true) exitWith {};