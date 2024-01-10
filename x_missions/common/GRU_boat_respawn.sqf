/*
	GRU_boat_respawn.sqf
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

if (!isServer) exitWith {hint localize "--- GRU_boat_respawn.sqf called on client, exit!"};

#define GRU_BOAT_MARKER "GRU_boat_marker"
#define MIN_DIST_TO_REDRAW_MARKER 100
#define DELAY_DEFAULT 30
#define MINIMAL_DAMAGE_TO_SHOW 0.075
#define MARKER_COLOR_DEF "ColorGreen"
#define MARKER_COLOR_DMG "ColorRed"

#ifdef __ACE__
#define MARKER_COLOR_DMG "ColorGreenAlpha"
#endif

// 0.  Creates the boat
_pos  = _this select 0;
_type = _this select 1;

_veh = objNull; //createVehicle [_type, _pos, [], 1, "NONE"];
_marker       = ""; // Boat marker
_marker_type  = ""; // Boat marker type
#ifdef __ACE__
_color		  = "";
#endif
_marker_color = MARKER_COLOR_DEF; // Marker color

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
			// TODO: send msg about new GRU boat dead STR_GRU_BOAT_DEAD "The GRU boat has been destroyed. Another one may be arriving soon."
			["say_sound", _veh, "steal"] call XSendNetStartScriptClient;
			sleep 1;
			deleteVehicle _veh;
			_marker setMarkerType "Empty"; // remove marker
			sleep (30 + (random 30));
		};
		// "Extra mission continues. A special GRU boat appeared at the starting point. Probably with the help of the islanders."
		_veh = createVehicle [_type, _pos, [], 1, "NONE"];
		["msg_to_user","",["STR_GRU_BOAT_ARRIVED"], 0, 2, false, "return"] call XSendNetStartScriptClient;
		if (_marker_type == "") then { // Init GRU boat marker now
			_marker_type = _veh call SYG_getVehicleMarkerType;
			_marker_pos = getPosASL _veh;
			// TODO: add GRU boat name in the stringtable.csv!!!
			// STR_GRU_BOAT_NAME=GRU boat,GRU boat,GRU boat,Катер ГРУ
			_marker = [GRU_BOAT_MARKER, _marker_pos, "ICON", _marker_color, [0.7,0.7], localize "STR_GRU_BOAT_NAME", 0, _marker_type] call XfCreateMarkerLocal;
		};
		_marker setMarkerType _marker_type; // restore marker
	};
	if (_marker != "") then {
		if ( (_veh distance _marker_pos) > MIN_DIST_TO_REDRAW_MARKER) then {
			_delay = 5;
			_marker_pos = 	getPosASL _veh;
			_marker setMarkerPos _marker_pos;
		} else { _delay = DELAY_DEFAULT };
#ifdef __ACE__
		If (damage _veh > MINIMAL_DAMAGE_TO_SHOW) then {
			_marker_color = MARKER_COLOR_DMG;
		} else {
			_marker_color = MARKER_COLOR_DEF;
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