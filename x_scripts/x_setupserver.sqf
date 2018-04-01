// by Xeno
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_pos = [0,0,0];

d_island_center = getArray(configFile>>"CfgWorlds">>worldName>>"centerPosition");

if (X_InstalledECS) then {
	ECS_public set[2, false];           //Dynamic weather OFF, use builtin instead
	ECS_public set[5, true];            //Bleeding enabled. See also below
	ECS_public set[7, false];           //First aid turned off, since mission has builtin 2xheal options  --This one might be bad shit--
	ECS_public set[13, false];          //Weapon jam disabled due to playerweapons system. Might be bad to respawn without weapons since little available
	ECS_public set[14, 0.00];           //Rifle jam rating, just in case
	ECS_public set[15, 0.00];           //Machinegun malfunction rating, just in case
};

// called on side mission completed
XSideMissionResolved = {
	[] spawn XClearSidemission;
	current_mission_index = -1;
	if (side_mission_winner > 0) then {
		#ifdef __TT__
		switch (side_mission_winner) do {
			case 1: {points_racs = points_racs + 7;};
			case 2: {points_west = points_west + 7;};
		};
		#endif
		execVM "x_scripts\x_getbonus.sqf";
	};
	if (side_mission_winner in [-1,-2,-300,-400,-500,-600,-700]) then {
		["sm_res_client",side_mission_winner,-1] call XSendNetStartScriptClient;
		side_mission_winner = 0;
	};
};

//
// Clear all side missions vehicles and start next SM
//
XClearSidemission = {
	private ["_waittime", "_num_p", "_was_captured", "_man", "_vehicle"];
	_waittime = 200 + random 20;
	_num_p = call XPlayersNumber;
	if (_num_p > 0) then {
		{
			if (_num_p <= (_x select 0)) exitWith {
				_waittime = (_x select 1) + random 10;
			}
		} forEach d_time_until_next_sidemission;
	};
	sleep _waittime;
	{
		if !(isNull _x) then {
			if (_x isKindOf "LandVehicle" ) then {
				if ( alive _x ) then
				{
					_was_captured = false;
					{
						if (isPlayer _x) exitWith {_was_captured = true;};
					} forEach (crew _x);
					// check vehicle being on base
					if ( ! _was_captured ) then
					{
#ifdef __OWN_SIDE_EAST__
						_was_captured = (side _x != west) && ( [getPos _x, d_base_array] call SYG_pointInRect ) && (getDammage _x < 0.000001);
#else
						_was_captured = (side _x != east) && ( [getPos _x, d_base_array] call SYG_pointInRect ) && (getDammage _x < 0.000001);
#endif
						_was_captured = _was_captured && (!(_x call SYG_vehIsUpsideDown));
					};
					if (_was_captured) then { // vehicle was captured by player
						[_vehicle] call XAddCheckDead;
					} else {
						{deleteVehicle _x} forEach ([_x] + crew _x);
					};
				};
			} else {
				deleteVehicle _x;
			};
		};
		sleep 0.1;
	} forEach extra_mission_vehicle_remover_array;
	extra_mission_vehicle_remover_array=nil;
	{
		if !(isNull _x) then {
			deleteVehicle _x;
		}
	} forEach extra_mission_remover_array;
	extra_mission_remover_array = nil;
	side_mission_resolved = false;

    SM_HeavySniperCnt = 0;
    publicVariable "SM_HeavySniperCnt"; // set SM heavy sniper being wiped out status

	execVM "x_missions\x_getsidemission.sqf"; // start next SM
};

_trigger = createTrigger["EmptyDetector" ,_pos];
_trigger setTriggerArea [0, 0, 0, false];
_trigger setTriggerActivation ["NONE", "PRESENT", true];
_trigger setTriggerStatements["side_mission_resolved", "xhandle = [] spawn XSideMissionResolved", ""];

// check mr
x_checktransport = compile preprocessFileLineNumbers "x_scripts\x_checktransport.sqf";

#ifdef __TT__
x_checktransport2 = compile preprocessFileLineNumbers "x_scripts\x_checktransport2.sqf";
#endif

// drop ammo box from vehicle
// handles only positions and markers.
// boxes get created locally on clients
if (!d_old_ammobox_handling) then {
	XCreateDroppedBox = {
		private ["_the_box_pos"];
		_the_box_pos = _this;
		ammo_boxes = ammo_boxes + 1;
		["ammo_boxes",ammo_boxes] call XSendNetVarClient;
		_mname = format ["bm_%1", str(_the_box_pos)];
		d_ammo_boxes = d_ammo_boxes + [[_the_box_pos,_mname]];
		[_mname, _the_box_pos,"ICON","ColorBlue",[0.5,0.5],"Ящик",0,"Marker"] call XfCreateMarkerGlobal;
	};

	execVM "x_scripts\x_boxhandling.sqf";
} else {
	d_check_boxes = [];

	// drop ammo box from vehicle, old version
	XCreateDroppedBox = {
		private ["_vec","_the_box_pos","_cbox"];
		_vec = _this select 0;
		_the_box_pos = _this select 1;
		ammo_boxes = ammo_boxes + 1;
		["ammo_boxes",ammo_boxes] call XSendNetVarClient;
		_cbox = [_vec, _the_box_pos];
		d_check_boxes = d_check_boxes + [_cbox];
		d_ammo_boxes = d_ammo_boxes + [[_the_box_pos,""]];
	};

	execVM "x_scripts\x_boxhandling_old.sqf";
};

/*
 * Set target unvulnerable while any own side vehicle not in 20 meters distance. After it tower became vulnerable again!
 */
XCheckSMHardTarget = {
	private ["_vehicle","_trigger","_trigger2"];
	_vehicle = _this select 0;
	#ifdef __TT__
	_vehicle addEventHandler ["killed", {side_mission_winner = (switch (side (_this select 1)) do {case resistance:{1};case west:{2};default{-1};});side_mission_resolved = true;}];
	#endif
	#ifndef __TT__
	_vehicle addEventHandler ["killed", {side_mission_winner = 2;side_mission_resolved = true;}];
	#endif
	#ifdef __WITH_SCALAR__
	_vec_init = "this addEventHandler [""hit"", {if (local (_this select 0)) then {(_this select 0) setDamage 0}}];this addEventHandler [""damage"", {if (local (_this select 0)) then {(_this select 0) setDamage 0}}];";
	if (typeOf _vehicle == "Land_telek1") then {
		_vec_init = _vec_init + "xhandle = [this] execVM ""scripts\scalar.sqf"";";
	};
	_vehicle setVehicleInit  _vec_init;
	#endif
	#ifndef __WITH_SCALAR__
	_vehicle setVehicleInit "this addEventHandler [""hit"", {if (local (_this select 0)) then {(_this select 0) setDamage 0}}];this addEventHandler [""damage"", {if (local (_this select 0)) then {(_this select 0) setDamage 0}}];";
	#endif
	processInitCommands;
	extra_mission_vehicle_remover_array = extra_mission_vehicle_remover_array + [_vehicle];
	friendly_near_sm_target = false;
	_trigger = createTrigger["EmptyDetector" ,position _vehicle];
	_trigger setTriggerArea [20, 20, 0, false];
	#ifndef __TT__
	_trigger setTriggerActivation [d_own_side_trigger, "PRESENT", false];
	#else
	_trigger setTriggerActivation ["WEST", "PRESENT", false];
	#endif
	_trigger setTriggerStatements["this && ((getpos (thislist select 0)) select 2 < 20)", "friendly_near_sm_target = true", ""];
	#ifdef __TT__
	_trigger2 = createTrigger["EmptyDetector" ,position _vehicle];
	_trigger2 setTriggerArea [20, 20, 0, false];
	_trigger2 setTriggerActivation ["GUER", "PRESENT", false];
	_trigger2 setTriggerStatements["this && ((getpos (thislist select 0)) select 2 < 20)", "friendly_near_sm_target = true", ""];
	#endif
	while {!friendly_near_sm_target && alive _vehicle} do {
		if (X_MP) then {
			waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
		};
		sleep (1.021 + random 1);
	};
	if (alive _vehicle) then {
		_vehicle setVehicleInit "this removeAllEventHandlers ""hit""; this removeAllEventHandlers ""damage"";";
		processInitCommands;
	};
	deleteVehicle _trigger;
	#ifdef __TT__
	deleteVehicle _trigger2;
	#endif
	sleep 0.513;
	clearVehicleInit _vehicle;
};

/*
 * Set target unvulnerable while any own side vehicle not in 20 meters distance. After it tower became vulnerable again!
 */
XCheckMTHardTarget = {
	private ["_vehicle","_trigger","_trigger2"];
	_vehicle = _this select 0;
//	_vehicle addEventHandler ["killed", {mt_radio_down = true;["mt_radio_down",mt_radio_down,if (!isNull (_this select 1)) then { name (_this select 1) } else {""}] call XSendNetStartScriptClient;_this spawn x_removevehiextra;}];
	_vehicle addEventHandler ["killed", {mt_spotted = false;mt_radio_down = true;["mt_radio_down",mt_radio_down,if (!isNull (_this select 1)) then { name (_this select 1) } else {""}] call XSendNetStartScriptClient;_this spawn x_removevehiextra;}];
	#ifdef __TT__
//	_vehicle addEventHandler ["killed", {[4,_this select 1] call XAddPoints;_mt_radio_tower_kill = (_this select 1);mt_spotted = false;["mt_radio_tower_kill",_mt_radio_tower_kill] call XSendNetStartScriptClient;}];
	_vehicle addEventHandler ["killed", {[4,_this select 1] call XAddPoints;_mt_radio_tower_kill = (_this select 1);["mt_radio_tower_kill",_mt_radio_tower_kill] call XSendNetStartScriptClient;}];
	#endif
	_vehicle setVehicleInit "this addEventHandler [""hit"", {if (local (_this select 0)) then {(_this select 0) setDamage 0}}];this addEventHandler [""damage"", {if (local (_this select 0)) then {(_this select 0) setDamage 0}}];";
	processInitCommands;
	friendly_near_mt_target = false;
	_trigger = createTrigger["EmptyDetector" ,position _vehicle];
	_trigger setTriggerArea [20, 20, 0, false];
	#ifndef __TT__
	_trigger setTriggerActivation [d_own_side_trigger, "PRESENT", false]; // trigger on "EAST PRESENT" for Red Engineers server
	#else
	_trigger setTriggerActivation ["WEST", "PRESENT", false];
	#endif
	_trigger setTriggerStatements["this && ((getpos (thislist select 0)) select 2 < 20)", "friendly_near_mt_target = true", ""];
	#ifdef __TT__
	_trigger2 = createTrigger["EmptyDetector" ,position _vehicle];
	_trigger2 setTriggerArea [20, 20, 0, false];
	_trigger2 setTriggerActivation ["GUER", "PRESENT", false];
	_trigger setTriggerStatements["this && ((getpos (thislist select 0)) select 2 < 20)", "friendly_near_mt_target = true", ""];
	#endif
	while {!friendly_near_mt_target && alive _vehicle} do {
		if (X_MP) then {
			waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
		};
		sleep (1.021 + random 1);
	};
	if (alive _vehicle) then {
		_vehicle setVehicleInit "this removeAllEventHandlers ""hit""; this removeAllEventHandlers ""damage"";";
		processInitCommands;
	};
	deleteVehicle _trigger;
	#ifdef __TT__
	deleteVehicle _trigger2;
	#endif
	sleep 0.513;
	clearVehicleInit _vehicle;
};

#ifndef __TT__
XFacRebuild = {
	private ["_pos", "_oldfac", "_index", "_dir", "_buildpos", "_i", "_element", "_apos", "_wairfac", "_fac"];
	_pos = _this select 0;
	_oldfac = _this select 1;
	_index = -1;
	_dir = 0;
	_buildpos = _pos;
	for "_i" from 0 to (count d_aircraft_facs - 1) do {
		_element = d_aircraft_facs select _i;
		_apos = _element select 0;
		if (_apos distance _pos < 20) exitWith {
		    // todo: не понятно, зачем это вычисляется!!!
		    // fixme: теперь понятно. Если расстояние от сервиса до позиции где он создавался, более 20 метров, то
		    // fixme: это означает, что он разрушен и помещён на большую глубину, где его не видно игрокам.
		    // fixme: Такая вот "гениальная" придумка у разрабов случаилась
			_index = _i;
			_buildpos = _apos;
			_dir = _element select 1;
		};
	};

	if (_index != -1) then {
		switch (_index) do {
			case 0: {d_jet_service_fac_rebuilding = true;["d_jet_service_fac_rebuilding",d_jet_service_fac_rebuilding] call XSendNetVarClient;};
			case 1: {d_chopper_service_fac_rebuilding = true;["d_chopper_service_fac_rebuilding",d_chopper_service_fac_rebuilding] call XSendNetVarClient;};
			case 2: {d_wreck_repair_fac_rebuilding = true;["d_wreck_repair_fac_rebuilding",d_wreck_repair_fac_rebuilding] call XSendNetVarClient;};
		};
	};

	sleep 300 + random 300;
	_wairfac = (
		switch (d_own_side) do {
			case "WEST": {"WarfareBWestAircraftFactory"};
			case "RACS": {"WarfareBWestAircraftFactory"};
			case "EAST": {"WarfareBEastAircraftFactory"};
		}
	);
	_fac = _wairfac createVehicle _buildpos;
	_fac setDir _dir;
	_fac addEventHandler ["killed", {[_this select 0] execVM "x_scripts\x_fackilled.sqf";}];

	if (!isNull _oldfac) then {deleteVehicle _oldfac;};

	if (_index != -1) then {
		switch (_index) do {
			case 0: {d_jet_service_fac = objNull;["d_jet_service_fac",d_jet_service_fac] call XSendNetStartScriptClient;d_jet_service_fac_rebuilding = false;["d_jet_service_fac_rebuilding",d_jet_service_fac_rebuilding] call XSendNetVarClient;};
			case 1: {d_chopper_service_fac = objNull;["d_chopper_service_fac",d_chopper_service_fac] call XSendNetStartScriptClient;d_chopper_service_fac_rebuilding = false;["d_chopper_service_fac_rebuilding",d_chopper_service_fac_rebuilding] call XSendNetVarClient;};
			case 2: {d_wreck_repair_fac = objNull;["d_wreck_repair_fac",d_wreck_repair_fac] call XSendNetStartScriptClient;d_wreck_repair_fac_rebuilding = false;["d_wreck_repair_fac_rebuilding",d_wreck_repair_fac_rebuilding] call XSendNetVarClient;};
		};
	};
};
#endif

#ifdef __TT__
execVM "x_scriptsґ\x_ttpoints.sqf";
#endif

#ifdef __AI__
execVM "x_scripts\x_delaiserv.sqf";
#endif

// start airki after short time
[] spawn {
#ifdef __SYG_AIRKI_DEBUG__
	sleep 24;
#else
	sleep 924;
#endif	
	["KA",d_number_attack_choppers] execVM "x_scripts\x_airki.sqf";
#ifdef __SYG_AIRKI_DEBUG__
	sleep 34;
#else
	sleep 801.123;
#endif	
	["SU",d_number_attack_planes] execVM "x_scripts\x_airki.sqf";
	
#ifdef __SYG_AIR_RESQUE__
	[] execVM "scripts\SYG_airResque.sqf"; // under development
#endif	
};

[] spawn {

	private ["_waittime","_num_p"];
	sleep 20;
    hint localize "x_getsidemission.sqf execution loop spawn";
#ifdef __FAST_START_SM__
	_waittime = 40;
#else
	_waittime = 200 + random 10; // default wait value if no players in the game
#endif
#ifdef __FAST_START_SM__
    sleep 30;
#else
	_num_p = call XPlayersNumber;
	if (_num_p > 0) then {
		{
			_waittime = (_x select 1) + random 10;
			if (_num_p <= (_x select 0)) exitWith {true};
		} forEach d_time_until_next_sidemission;
	};
    hint localize format["Wait %1 secs for 1st sidemission spawn", round(_waittime)];
	sleep _waittime;
#endif

	execVM "x_missions\x_getsidemission.sqf";
};

if (d_with_recapture) then {
	execVM "x_scripts\x_recapture.sqf";
};

if (d_create_civilian) then {
	execVM "x_scripts\x_civs.sqf";
};

#ifndef __TT__
if (!d_no_sabotage) then {execVM "x_scripts\x_infiltrate.sqf";};
#endif


#ifdef __ACE__
//+++ Sygsky: added on heli wind effect for server only as all heli are created on host (server) computer
if ( d_with_wind_effect ) then
{
	"ACE_HeliWind" createVehicle [0,0,0]; ACE_Wind_Modifier_Vehicles = 0.75;
 };
#endif

//hint localize format["x_setupserver.sqf: d_with_wind_effect == %1",d_with_wind_effect];

//
// Detect is it request for Side Mission position or call for SM execution, for konvoy return finish point, for all other - 1st point in array
//
SYG_isSMPosRequest = {
    private ["_ret"];
    _ret = false;
    if ( !isNull _this ) then
    {
        if (typeof _this == "STRING") then
        {
            if (_this == "SM_POS_REQUEST") then
            {
                _ret = true;
            };
        };
    };
    _ret
};

if (true) exitWith {};
