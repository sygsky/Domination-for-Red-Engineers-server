/*
	GRU_boat_respawn.sqf
	author: Sygsky
	description:

        0. Creates and controls an additional GRU boat to help capture an enemy boat.
        1. If the boat dies, a new one is created.
        2. If the SM completes successfully, waits for the GRU boat to be delivered to a mission point or void on the server.
        3. If the boat is delivered, everyone in it gets +10 points.
        4. Wait for all players to leave and delete the GRU boat.

    _this = [ _point_coord_array as after {@link getPos}, boat_type ("RHIB") ]
	returns: nothing
*/

#define GRU_BOAT_MARKER "GRU_boat_marker"
#define MIN_DIST_TO_REDRAW_MARKER 100
#define DELAY_DEFAULT 60
#define MINIMAL_DAMAGE_TO_SHOW 0.075
#define MARKER_COLOR_DEF "ColorGreen"

#ifdef __ACE__
#define MARKER_COLOR_DMG "ColorGreenAlpha"
#endif

// 0.  Creates the boat
_pos  = _this select 0;
_type = _this select 1;

_veh = objNull; //createVehicle [_type, _pos, [], 1, "NONE"];
_marker_type = "";
_marker_color = MARKER_COLOR_DEF;

_SM_current_id = current_mission_counter; // Index of current mission, if chanage, this SM is completed and we have to finish
_delay = DELAY_DEFAULT;
while { true } do {
	if (current_mission_counter != _SM_current_id) exitWith {
		// 2. If the SM completes successfully, waits for the GRU boat to be delivered to a mission point or void on the server.
		// TODO: send msg about GRU boat vdelivery to the point STR_GRU_BOAT_RETURN
		// "SM completed. Return the GRU boat to the mission point (the mission marker has been erased, but the yellow circle remains) and prevent it from being destroyed by the enemy. This is the request of our handler."
		while { true } do {
			// Mission is completed, wait GRU boat dead OR boat on point OR server is empty (player count == 0)
			if ( !alive _veh ) exitWith { // Boat is killed
				// TODO: send msg about failed attempt to delivery boat to the SM point  STR_GRU_BOAT_DEAD_0
				// "Alas the GRU boat has been destroyed. There's nothing more to wait for. SM is finished."
			};
			// 4. Wait for all players to leave and delete the GRU boat.
			if ( (call XPlayersNumber) == 0) exitWith{
				deleteVehicle _veh;
				while {(call XPlayersNumber) == 0 } do { sleep 60; };
				// TODO:  send msg about GRU boat mistically disappear STR_GRU_BOAT_DISAPPEARED "The boat mysteriously disappeared. Perhaps it was swallowed by the local Leviathan."
			};
			// 3. If the boat is delivered, everyone in it gets +10 points.
			if ( (_veh distance _pos)  < 2 ) exitWith {
				// TODO: add half score of SM success to all player in the boat STR_GRU_BOAT_DELIVERED "GRU boat delivered to designated location. Thank you for your service, fellow fighters! You get points: +%1."
			};
			sleep 10;
		};
	};

	// If the boat dies, a new one is created.
	if ( !(alive _veh) ) then {
		if (!isNull _veh) then {
			// TODO: send msg about new GRU boat dead STR_GRU_BOAT_DEAD "The GRU boat has been destroyed. Another one may be arriving soon."
			["say_sound", _veh, "steal"] call XSendNetStartScriptClientAll;
			sleep 1;
			deleteVehicle _veh;
			_marker setMarkerType "Empty"; // remove marker
			sleep (30 + (random 30));
		};
		// TODO: send msg about new GRU boat arrived STR_GRU_BOAT_ARRIVED "SM continues. A special GRU boat has appeared at the starting point. Probably with the direct help of the islanders."
		_veh = createVehicle [_type, _pos, [], 1, "NONE"];
		["say_sound", _veh, "return"] call XSendNetStartScriptClientAll;
		if (_marker_type == "") then { // Init GRU boat marker now
			_marker_type = _veh call SYG_getVehicleMarkerType;
			_marker_pos = getPosASL _veh;
			// TODO: add GRU boat name to the stringtable.csv!!!
			_marker = [GRU_BOAT_MARKER, _marker_pos, "ICON", _marker_color, [0.7,0.7], localize "STR_GRU_BOAT_NAME", 0, _marker_type] call XfCreateMarkerLocal;
		};
		_marker setMarkerType _marker_type; // restore marker
	};
	if (_marker != "") then {
		if ( (_veh distance _marker_pos) > MIN_DIST_TO_REDRAW_MARKER) then {
			_delay = 5;
			_marker_pos = 	getPosASL _veh;
			_marker setMarkerPos _marker_pos;
		} else { _delay = DELAY_DEFAULT};
#ifdef __ACE__
		_color = "";
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