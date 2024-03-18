/*
	x_missions\common\GRU_boat_respawn.sqf
	author: Sygsky
	description:
		Works on server only!
        0. Creates and controls an additional GRU boat to help capture an enemy boat.
        1. If the boat dies, a new one is created.
        2. If the SM completes successfully, waits for the GRU boat to be delivered to a mission point or void on the server.
        3. If the boat is delivered, everyone in it gets +10 points.
        4. Wait for all players to leave and delete the GRU boat.

    _this = [ _point_coord_array as after {@link getPos}, boat_type ("RHIB") ]
	returns: nothing
*/

// check if is called on client at "remote_execute" sent from server
_remote = false;
if (typeName _this == "ARRAY") then {
    if ( (typeName (_this select 0)) == "STRING") then { _remote = (_this select 0) == "remote_execute" }
};
if (_remote) exitWith {
    // Call to client from server as if: ["remote_execute",_cmd_str, _veh] execVM "x_missions\common\GRU_boat_respawn.sqf";
    if (count _this < 3) exitWIth {
        hint localize format["--- GRU_boat_respawn.sqf error: unexpected _this count (must be >= 3) on client call, _this = %1", _this];
    };
    _boat = _this select 2;
    if (typeName _boat != "OBJECT") exitWith {
        hint localize format["--- GRU_boat_respawn.sqf error: expected 'OBJECT' in (_boat = _this select 2), found _boat = %1", _boat];
    };
    if (local _boat) exitWith {
        _boat engineOn false;
        sleep 0.6;
        ["log2server", name player, format["The moving GRU boat has been stopped (in real %1).", isEngineOn _boat]] call XSendNetStartScriptServer;
        hint localize format["--- GRU_boat_respawn.sqf success: local boat engine stopped, after 0.5 sec. engine is %1",
         if (isEngineOn _boat) then {"on"} else {"off"}];
    };
};

if (!isServer) exitWith {hint localize "--- GRU_boat_respawn.sqf called on client, exit!"};

#include "x_setup.sqf"

#define GRU_BOAT_MARKER "GRU_boat_marker"
#define MIN_DIST_TO_REDRAW_MARKER 100
#define DELAY_DEFAULT 30
#define DELAY_SMALL 5
#define MINIMAL_DAMAGE_TO_SHOW 0.075
#define MARKER_COLOR_DEF "ColorGreen"
#define MARKER_COLOR_DMG "ColorRed"

#ifdef __ACE__
#define MARKER_COLOR_DMG "ColorGreenAlpha"
#endif

// 0.  Creates the boat
_pos  = _this select 0;
_type = _this select 1;

hint localize format["+++ GRU_boat_respawn.sqf started: pos %1, type %2", _pos, _type];

_veh = objNull; //createVehicle [_type, _pos, [], 1, "NONE"];
_marker       = ""; // Boat marker
_marker_type  = ""; // Boat marker type
#ifdef __ACE__
_color		  = "";
#endif
_marker_color = MARKER_COLOR_DEF; // Marker color
_marker_pos = [0,0,0];

_SM_current_id = current_mission_counter; // Index of current mission, if changed, this SM is completed and we have to finish
_delay = DELAY_DEFAULT;
while { true } do {
	if (current_mission_counter != _SM_current_id) exitWith {
		// 2. If the SM completes successfully, waits for the GRU boat to be delivered to a mission point or void on the server.
		// "SM complete. Return the GRU boat to the underwater yellow circle without letting it be destroyed. That is the command's order."
		["msg_to_user","",["STR_GRU_BOAT_RETURN"], 0, 0, false, "naval"] call XSendNetStartScriptClient;
		while { true } do {
			// Mission is completed, wait GRU boat dead OR boat on point OR server is empty (player count == 0)
			if ( !alive _veh ) exitWith { // Boat is killed
				// "Alas the GRU boat has been destroyed. There's nothing more to wait for. SM is finished."
				["msg_to_user","",["STR_GRU_BOAT_DEAD"], 0, 0, false, "naval"] call XSendNetStartScriptClient;
			};
			// 4. Wait for all players to leave and delete the GRU boat.
			if ( (call XPlayersNumber) == 0 ) exitWith {
				deleteVehicle _veh;
				while {(call XPlayersNumber) == 0 } do { sleep 80; };
				// "The GRU boat mysteriously disappeared while island was without players. Perhaps it was swallowed by the local Leviathan."
				["msg_to_user","",["STR_GRU_BOAT_DISAPPEARED"], 0, 0, false, "under_water_3"] call XSendNetStartScriptClient;
			};
			// 3. If the boat is delivered, everyone in it gets +10 points.
			if ( (_veh distance _pos)  < 2 ) exitWith {
				_names = [];
				{
					if ( isPLayer _x ) then { _names set [ count _names, name _x ] };
				} forEach (crew _veh); // Are men in boat ?
				if (count _name > 0 ) then { // "The GRU boat has been delivered to the agreed place. Thank you for your service, comrade! You get points: +%1."
					[ "change_score", _names, d_ranked_a select 18, [ "msg_to_user", "",  [ ["STR_GRU_BOAT_DELIVERED", d_ranked_a select 18] ], 0, 0, false, "naval" ] ] call XSendNetStartScriptClient;
				};
			};
			sleep 5;
		};
	};

	// If the boat dies, a new one is created.
	if ( !(alive _veh) ) then {
		if (!isNull _veh) then {
			// "The GRU boat has been destroyed. Another one may be arriving soon."
			["msg_to_user","",["STR_GRU_BOAT_DEAD_0"], 0, 0, false, "naval"] call XSendNetStartScriptClient;
//			["say_sound", _veh, "steal"] call XSendNetStartScriptClient;
			sleep 1;
			deleteVehicle _veh;
			_marker setMarkerType "Empty"; // Hide marker
			sleep (30 + (random 30));
		};
		// "Extra mission continues. A special GRU boat appeared at the starting point. Probably with the help of the islanders."
		_veh = createVehicle [_type, _pos, [], 1, "NONE"];
		["msg_to_user","",["STR_GRU_BOAT_ARRIVED"], 0, 2, false, "naval"] call XSendNetStartScriptClient;
		if (_marker_type == "") then { // Init GRU boat marker now
			_marker_type = _veh call SYG_getVehicleMarkerType;
			_marker_pos = getPosASL _veh;
			// STR_GRU_BOAT_NAME="GRU boat"
			_marker = [GRU_BOAT_MARKER, _marker_pos, "ICON", _marker_color, [0.7,0.7], localize "STR_GRU_BOAT_NAME", 0, _marker_type] call XfCreateMarkerGlobal;
			hint localize format["+++ GRU_boat_respawn.sqf: marker %1 created", _marker];
		} else {
			_marker setMarkerType _marker_type; // restore marker just in case
		};
	} else {
	    // Check if boat is empty and engine is on
	    if ( isEngineOn _veh) then {
	        if ( ( {(isPlayer _x) && (alive _x)} count (crew _veh) ) == 0) then {// Boat is empty
                if (local _veh) then {
                    _veh engineOn false;
                } else {
                    Hint localize format["+++ GRU_boat_respawn.sqf: empty non local boat engine would be stopped on some client at %1", [_veh, 10 ] call SYG_MsgOnPos0];
                    ["remote_execute","_this execVM ""x_missions\common\GRU_boat_respawn.sqf""", _veh] call  XSendNetStartScriptClientAll;
                };
	        };
	    };
	};
	if (_marker != "") then {
		_vpos = getPosASL _veh;
		if ( ([_vpos, _marker_pos] call SYG_distance2D) > MIN_DIST_TO_REDRAW_MARKER) then {
			_marker_pos = _vpos;
			_marker setMarkerPos _vpos;
			_delay = DELAY_SMALL;
		} else { _delay = DELAY_DEFAULT };
#ifdef __ACE__
		if (damage _veh > MINIMAL_DAMAGE_TO_SHOW) then {
			_color = MARKER_COLOR_DMG;
		} else {
			_color = MARKER_COLOR_DEF;
		};
		if (_marker_color != _color) then {
			_marker setMarkerColor _color;
			_marker_color = _color;
		};
#endif
	};
	sleep _delay;
};

if (!isNull _veh) then {
	["say_sound", _veh, "steal"] call XSendNetStartScriptClientAll;
	sleep 1;
	deleteVehicle _veh;
};
deleteMarker _marker;
hint localize "+++ GRU_boat_respawn.sqf finished!";
