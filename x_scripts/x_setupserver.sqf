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
		[] execVM "x_scripts\x_getbonus.sqf";
	};
	if (side_mission_winner < 0 /*in [-1,-2,-300,-400,-500,-600,-700,-701,-702]*/ ) then {
		["sm_res_client",side_mission_winner,-1] call XSendNetStartScriptClient;
		side_mission_winner = 0;
	};
};

//
// Clear all side missions vehicles and start next SM
//
XClearSidemission = {
	private ["_waittime", "_num_p", "_was_captured", "_man", "_vehicle","_x"];
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
//			if (_x isKindOf "LandVehicle" ) then {
				if ( alive _x ) then {
					_was_captured = false;
					{
						if (isPlayer _x) exitWith { // if player is in vehicle, consider it to be captured
							_was_captured = true;
						};
					} forEach (crew _x);
					// check vehicle being on base
					if ( ! _was_captured ) then {
#ifdef __OWN_SIDE_EAST__
						_was_captured = (side _x != west) && ( _x call SYG_pointIsOnBase ) && (getDammage _x < 0.000001);
#else
						_was_captured = (side _x != east) && ( _x call SYG_pointIsOnBase ) && (getDammage _x < 0.000001);
#endif
						_was_captured = _was_captured && (!(_x call SYG_vehIsUpsideDown));
					};
					if (! _was_captured) then {
					    _was_captured = _x getVariable "CAPTURED_ITEM";
					    _was_captured = !(isNil "_was_captured");
					    // if (_was_captured == true) then { "vehicle was already captured by player[s]"};
					};
					if (_was_captured ) then { // vehicle was captured by player
						[_x] call XAddCheckDead;
						_x setVariable ["CAPTURED_ITEM","SM"];
					} else {
						{deleteVehicle _x} forEach ((crew _x) + [_x]);
					};
				} else {
					deleteVehicle _x;
				};
//			} else {
//				hint localize format["+++ XClearSidemission: deleteVehicle %1",typeOf _x ];
//				deleteVehicle _x;
//			};
		};
		sleep 0.1;
	} forEach extra_mission_vehicle_remover_array;
	extra_mission_vehicle_remover_array=nil;
	{
		if !(isNull _x) then { deleteVehicle _x; }
	} forEach extra_mission_remover_array;
	extra_mission_remover_array = nil;
	side_mission_resolved = false;

    SM_HeavySniperCnt = 0;
    publicVariable "SM_HeavySniperCnt"; // set SM heavy sniper being wiped out status

	execVM "x_missions\x_getsidemission.sqf"; // start next SM
};

#ifdef __OLD__

_trigger = createTrigger["EmptyDetector" ,_pos];
_trigger setTriggerArea [0, 0, 0, false];
_trigger setTriggerActivation ["NONE", "PRESENT", true];
_trigger setTriggerStatements["side_mission_resolved", "xhandle = [] spawn XSideMissionResolved", ""];

#else
// new version of the missions resulution
[] spawn {
	private ["_xhandle"];
	while { true } do {
		if ( side_mission_resolved ) then {
			call XSideMissionResolved;
			waitUntil {sleep 8; !side_mission_resolved }; // wait end of finish processing
		};
		sleep 2;
	};
};

#endif

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
		[_mname, _the_box_pos,"ICON","ColorBlue",[0.5,0.5],localize "STR_SYS_338",0,"Marker"] call XfCreateMarkerGlobal;
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
 * Set SM target unvulnerable while any own side vehicle not in 20 meters distance. After it tower became vulnerable again!
 * TODO: may be we need to replace logic with the one developed in lower XCheckMTHardTarget subroutine, to reject any kills except manual blasting
 */
XCheckSMHardTarget = {
	private ["_vehicle","_trigger","_trigger2"];
	_vehicle = _this select 0;

	#ifdef __TT__
	_vehicle addEventHandler ["killed", {side_mission_winner = (switch (side (_this select 1)) do {case resistance:{1};case west:{2};default{-1};});side_mission_resolved = true;}];
	#endif

	#ifndef __TT__
	if (typeOf _vehicle == "Land_telek1") then {
		_vehicle addEventHandler ["killed", {side_mission_winner = 2;side_mission_resolved = true; ["say_sound", "PLAY", "tvpowerdown"] call XSendNetStartScriptClientAll}];
	} else {
		_vehicle addEventHandler ["killed", {side_mission_winner = 2;side_mission_resolved = true;}];
	};
	#endif

   _vehicle addEventHandler ["hit", {(_this select 0) setDamage 0}];
   _vehicle addEventHandler ["dammaged", {(_this select 0) setDamage 0}];

	#ifdef __WITH_SCALAR__
	if (typeOf _vehicle == "Land_telek1") then {
        _vehicle setVehicleInit  "xhandle = [this] execVM ""scripts\scalar.sqf"";";
        processInitCommands;
	};
	#endif

	extra_mission_vehicle_remover_array set [ count extra_mission_vehicle_remover_array, _vehicle ];
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
		sleep (4 + random 1);
	};

	if (alive _vehicle) then {
	    _vehicle removeAllEventHandlers "hit";
	    _vehicle removeAllEventHandlers "dammaged";
// all this garbage not work at all:	    hint localize "+++ friendly_near_sm_target is now true: remove HIT & DAMMAGED protect events";
	};

	deleteVehicle _trigger;

	#ifdef __TT__
	deleteVehicle _trigger2;
	#endif

	sleep 0.513;

	#ifdef __WITH_SCALAR__
    clearVehicleInit _vehicle;
	#endif

};

/**
 by Sygsky 12-APR-2020

 Triggered when the unit is "hit".

 Is not always triggered when unit is killed by a hit.
 Most of the time only the killed event handler is triggered when a unit dies from a hit.
 The hit EH will not necessarily fire if only minor damage occurred (e.g. firing a bullet at a tank), even though the damage increased.

 Local.

 Passed array: [unit, causedBy, damage]

 unit:     Object - Object the event handler is assigned to
 causedBy: Object - Object that caused the damage. Contains the unit itself in case of collisions.
 damage:   Number - Level of damage caused by the hit
 */
SYG_hitMTTarget = {
    // drop damage if < 1 or hit not from man
    if ( ( (_this select 2)  > 2 ) && ( (_this select 1) isKindOf "CAManBase") ) exitWith {
   		(_this select 1) setVariable ["KAMIKADZE", time]; // set it to check later in kill event
        hint localize  format["*** Hit dmg %1(total %2) to %3, by %4(%5) may be refused as kamikadze detected",
            _this select 2,
            damage (_this select 0),
            typeOf (_this select 0),
            name (_this select 1),
            typeOf (vehicle (_this select 1))
            ];
    };
    if ( ( damage (_this select 0)  >= 1 ) && ( (_this select 1) isKindOf "CAManBase") || ( isNull (_this select 1) ) ) exitWith {
        hint localize  format["*** Hit dmg %1(total %2) to %3, by %4(%5) is accepted",
            _this select 2,
            damage (_this select 0),
            typeOf (_this select 0),
            name (_this select 1),
            typeOf (vehicle (_this select 1))
            ];
    };
    (_this select 0) setDamage  0; // fix possible negative value
	hint localize format["*** Hit to %1 is not accepted: dmg %2, by %3, dist. %4 m",
		typeOf (_this select 0),
		_this select 2,
		name  (_this select 1),
		round ((_this select 1) distance (_this select 0))]
};

//
// Set target (always "Land_telek1" from x_createsecondary.sqf, line 320) unvulnerable while any own side vehicle not in circle 20 meters and less than 20 m. height.
// After it tower became vulnerable again!
// call as: [_obj_to_protect] call XCheckMTHardTarget
//
XCheckMTHardTarget = {
    private ["_vehicle"];

	if ( typeName _this != "ARRAY" ) then { _this = [_this] }; // allow any form of input, as array [_obj] as single object _obj
	_vehicle = _this select 0;
	_vehicle addEventHandler ["killed", { _this execVM "scripts\eventKilledMT.sqf" } ]; // protect the tower from forbidden attacks (by kamikadze, by tanks etc)
#ifdef __TT__
	_vehicle addEventHandler ["killed", { [ 4, _this select 1 ] call XAddPoints;private ["_mt_radio_tower_kill"];_mt_radio_tower_kill = (_this select 1);["mt_radio_tower_kill",_mt_radio_tower_kill] call XSendNetStartScriptClient; } ];
#endif
	_vehicle addEventHandler [ "hit", { _this call SYG_hitMTTarget } ]; // drop damage from easy forbidden attacks
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
		    // fixme: Такая вот "гениальная" придумка у разрабов случилась
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
	_fac addEventHandler ["killed", {_this execVM "x_scripts\x_fackilled.sqf";}];

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

//++++++++++++++++++++++ Start of sidemission processings
[] spawn {

	private ["_waittime","_num_p"];
	sleep 20;
    hint localize "+++ x_getsidemission.sqf execution loop spawn";
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
    hint localize format["+++ Wait %1 secs for 1st sidemission spawn", round(_waittime)];
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
if ( d_with_wind_effect ) then {
	"ACE_HeliWind" createVehicle [0,0,0]; ACE_Wind_Modifier_Vehicles = 0.75;
 };
//hint localize format["x_setupserver.sqf: d_with_wind_effect == %1",d_with_wind_effect];
#endif

#ifdef __DOSAAF_BONUS__
server_bonus_markers_array = [];
#endif

//
// Detect is it request for Side Mission position or call for SM execution, for konvoy return finish point, for all other - 1st point in array
//
SYG_isSMPosRequest = {
    private ["_ret"];
    _ret = false;
    if ( !isNull _this ) then{
        if (typeof _this == "STRING") then {
            if (_this == "SM_POS_REQUEST") then {
                _ret = true;
            };
        };
    };
    _ret
};

if (true) exitWith {};
                                                                                                                                                                                                         