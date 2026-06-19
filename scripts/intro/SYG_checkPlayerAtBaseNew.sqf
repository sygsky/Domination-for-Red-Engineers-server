/*
    Current debug vaaraion with new changes
	scripts\intro\SYG_checkPlayerAtBase.sqf run on client only
	author: Sygsky
	description: checks if player visited base rectangle. If yes, set variable base_visit_session = 1 and exit
	returns: nothing

    Checks if alive player was at base.
	Call as: [] execVM  "scripts\intro\SYG_checkPlayerAtBase.sqf";

*/

#include "x_setup.sqf"

#ifdef SYG_TRAVEL_BONUS_ENHANCED

// --- Configuration ---
/*
	//+++ Sygsky: Paraiso airfield coordinates and its boundary rectangle box (semi-axis sizes)
	[[9821.47,9971.04,0], 600, 200, 0];
#endif
*/
#define BASE_CENTER_POS (d_base_array select 0)
#define BONUS_FOOT_ONLY 200
#define BONUS_NO_AIR_WATER 50
#define THRESHOLD_INTENSIVE 0.20 // 20% limit for air/water usage to get max bonus
#define KERZON_LINE_ADD 8000 // Add length to Kerzon line
#define KERZON_LINE_THICKNESS 10 // Thickness to see it on map at any scale
#define LINE_COLOR "ColorRedAlpha"
#define BONUS_EVAL_INTERVAL 5 // Seconds between dynamic bonus status checks

hint localize "+++ NEW SYG_checkPlayerAtBaseNew.sqf started";

// --- Helper: Simplified Travel Type to values of (0-3) ---
// Uses your existing SYG_getVehicleType1
_fnc_getTravelType = {
    private ["_input", "_typeCode"];
    _input = _this;
    if (typeName _input == "OBJECT") then { _input = typeOf _input };
    if (typeName _input != "STRING") exitWith { 0 }; // Foot

    _typeCode = _input call SYG_getVehicleType1;

    switch (_typeCode) do {
        case 3: { 1 }; // Helicopter -> Air
        case 4: { 1 }; // Plane -> Air
        case 5: { 2 }; // Ship -> Water
        case 0; case 1; case 2: { 3 }; // Tank/Car/Static -> Ground
        default { 0 }; // Unknown/Man -> Foot
    };
};

// --- Helper: Draw Kerzon Line (Extended Local Marker) ---
_fnc_drawKerzonLine = {
    private ["_p1", "_p2", "_mid", "_dir", "_baseLen", "_extLen", "_markerName", "_marker"];

    _p1 = SYG_Kerzon_line select 0;
    _p2 = SYG_Kerzon_line select 1;

    // 1. Calculate base geometry
    _baseLen = [_p1, _p2] call SYG_distance2D;
    _dir = [_p1, _p2] call XfDirToObj;

    // 2. Calculate Midpoint of the original segment
    _mid = [
        ((_p1 select 0) + (_p2 select 0)) / 2,
        ((_p1 select 1) + (_p2 select 1)) / 2,
        0
    ];

    // 3. Extend length: Base + added length
    _extLen = _baseLen + KERZON_LINE_ADD;

    // 4. Create/Update local marker
    _markerName = "SYG_KerzonLineMarker";
    deleteMarkerLocal _markerName; // Clean up if exists

    _marker = createMarkerLocal [_markerName, _mid];
    _marker setMarkerShapeLocal "RECTANGLE";

    // Size: [Half-Width, Half-Length] -> Swapped to align with Dir
    _marker setMarkerSizeLocal [KERZON_LINE_THICKNESS, _extLen / 2 ];

    _marker setMarkerDirLocal _dir;
    _marker setMarkerColorLocal LINE_COLOR; // Alpha blended color
    _marker setMarkerBrushLocal "Solid";

    hint localize format ["+++ Kerzon Line drawn. Length: %1m, dir: %2, marker: %3, p1,p2: %4,%5", round _extLen, round(_dir), _marker, _p1, _p2];
    [player, format [localize "MSG_KERZON_LINE_DRAWN", LINE_COLOR]] call XfVehicleChat; // "Kerzon Line drawn in %1"
};

// --- Helper: Remove Kerzon Line ---
_fnc_removeKerzonLine = {
    deleteMarkerLocal "SYG_KerzonLineMarker";
    localize "MSG_KERZON_LINE_REMOVED" call XfHQChat;
    hint localize "MSG_KERZON_LINE_REMOVED";
};

// --- Helper: Show Status HUD ---
_fnc_showStatus = {
    private ["_pos", "_distToLine", "_distToBase", "_typeCode", "_typeStr", "_msg"];

    _pos = getPos player;

    // Distance to Kerzon Line (using your vector distance function)
    _distToLine = round(abs([SYG_Kerzon_line select 0, SYG_Kerzon_line select 1, _pos] call SYG_distPoint2Vector1));

    // Distance to Base
    _distToBase = round([_pos, BASE_CENTER_POS] call SYG_distance2D);

    // Transport Type String
    _typeCode = (vehicle player) call _fnc_getTravelType;

    _typeStr = switch (_typeCode) do {
        case 0: {localize "MSG_TRAVEL_MODE_FOOT"};  // "ON FOOT"
        case 1: {localize "MSG_TRAVEL_MODE_AIR"};   // "AIR"
        case 2: {localize "MSG_TRAVEL_MODE_WATER"}; // "WATER"
        case 3: {localize "MSG_TRAVEL_MODE_LAND"};  // "LAND VEHICLE"
        default {localize "MSG_TRAVEL_MODE_UNK"};   // UNKNOWN"
    };
    _msg = format [localize "MSG_TRAVEL_STATUS", round _distToLine, round _distToBase, _typeStr]; // "STATUS | Dist to Line: %1m | To Base: %2m | Mode: %3"
    _msg call XfHQChat;
};

#endif


_start_time        = _this; // Session start time
_out_of_intro_time = time; // When we leave the intro and go into freefall with a parachute on our backs
hint localize format[ "+++ SYG_checkPlayerAtBase.sqf: Started, intro start at %1, intro stop at %2, diff is %3, base_visit_session %4",
    _start_time,
    _out_of_intro_time,
    _out_of_intro_time - _start_time,
    base_visit_session
    ];
_spent_time = 0; // Time to reach the base
_flare = objNull;
_pos = getPos AISPAWN; // FLAG_BASE; // [9529.5,9759.2,0]; // point near central gate to the base
_flag_pos = [];
_factor = (400 / 1600) max 12.5;

// Array of vehiles ised
_vehs_used_arr = [];
_active_veh = objNull; // Last vehicle in use by this player
_veh_exit_cnt = 0; // Number of consecutive visits to this transport by a player
_in_time_sum = 0;
_get_in_time = 0;
_was_in_veh = false;

#ifdef SYG_TRAVEL_BONUS_ENHANCED
// --- Init Travel Bonus Variables ---
_travel_active = false;
_travel_lengths = [0,0,0,0]; // [Foot, Air, Water, Ground]
_travel_veh = objNull;
_travel_type = 0;
_travel_dist_ref = -1;
_travel_curr_len = 0;

// Dynamic Bonus Tracking
_bonus_level = 2;          // 2=Full(+200), 1=Partial(+50), 0=None
_last_bonus_level = -1;    // To detect changes
_min_dist_for_eval = 500;  // Don't evaluate until 500m traveled

// Init HUD tracking vars
_last_status_time = 0;
_last_transport_type = -1;
_last_dist_base = -1;

// Draw the line once
[] call _fnc_drawKerzonLine;
#endif


_delay = 5;
while { base_visit_session <= 0 } do {
	sleep _delay;
	// launch a violet flare over the base to attract the player's attention (to tell him where to go)

	if (!alive _flare) then {
		_flag_pos set [ 0, (_pos select 0) + (random 5) ];
		_flag_pos set [ 1, (_pos select 1) + (random 5) ];
		_flag_pos set [ 2, 250 + (random 5) ]; // flare spawn height AGL
		_flare = "F_40mm_White" createVehicleLocal _flag_pos;
		[ _flare, "VIOLET", _factor] execVM "scripts\emulateFlareFiredLocal.sqf";
	};

	if ( alive player ) then {

#ifdef SYG_TRAVEL_BONUS_ENHANCED
	    // --- NEW TRAVEL BONUS LOGIC ---
	    _p_veh = vehicle player;
	    _p_pos = getPos player;

	    // 1. Check if crossed Kerzon Line (Start Tracking)
	        // SYG_pointToVectorRel: -1 left, 1 right, 0 on line.
	        // Assuming "Below" means one specific side (e.g., -1 or 1 depending on line orientation).
	        // Let's assume we track when player is on the "Base Side" of the line.
	        // You might need to swap -1/1 check depending on line direction.
	    _rel = [SYG_Kerzon_line select 0, SYG_Kerzon_line select 1, _p_pos] call SYG_pointToVectorRel;

	    // Start tracking if NOT above the line (adjust condition based on line orientation!)
	    if (!_travel_active && _rel != 1) then {
	        _travel_active = true;
	        _travel_veh = _p_veh;
	        _travel_type = (_p_veh) call _fnc_getTravelType;
	        _travel_dist_ref = [_p_pos, BASE_CENTER_POS] call SYG_distance2D;
	        _travel_curr_len = 0;

            // "Travel tracking STARTED." call XfHQChat;
            localize "MSG_TRAVEL_TRACKING_STARTED" call XfHQChat;
            // TODO: inform all that player is now really far from the Antigua
	    };

	    // 2. Update Progress
	    if (_travel_active) then {
	        _new_type = (_p_veh) call _fnc_getTravelType;
	        _curr_dist = [_p_pos, BASE_CENTER_POS] call SYG_distance2D;

	        // Vehicle Change?
	        if (_p_veh != _travel_veh) then {
	            // Save segment length to array
	            _travel_lengths set [_travel_type, (_travel_lengths select _travel_type) + _travel_curr_len];

	            // Switch to new vehicle
	            _travel_veh = _p_veh;
	            _travel_type = _new_type;
	            _travel_curr_len = 0;

	            // Notify player
	            _typeStr = switch (_travel_type) do {
	                case 0: {localize "MSG_TRAVEL_MODE_FOOT"};
                    case 1: {localize "MSG_TRAVEL_MODE_AIR"};
                    case 2: {localize "MSG_TRAVEL_MODE_WATER"};
                    case 3: {localize "MSG_TRAVEL_MODE_LAND"};
                    default {localize "MSG_TRAVEL_MODE_UNK"};
	            };
                // format ["Vehicle changed to: %1", _typeStr] call XfHQChat;
                format [localize "MSG_VEHICLE_CHANGED", _typeStr] call XfHQChat;
            };

	        // Calculate Delta (Your "Trick": + if closer, - if farther)
	        _delta = _travel_dist_ref - _curr_dist;
	        _travel_curr_len = _travel_curr_len + _delta;
	        _travel_dist_ref = _curr_dist;

	        // 3. Anti-Cheat: Static Air/Water Check (Optional logging)
	        if (_travel_type in [1, 2]) then {
	            if ((speed _p_veh) < 1 && (_travel_curr_len > 100)) then {
	                 // Optional: Penalize hovering?
	            };
	        };

	        // 4. DYNAMIC BONUS EVALUATION
            if (time - _last_status_time > BONUS_EVAL_INTERVAL) then {
                // Sum effective distance
                _total_eff = 0;
                { _total_eff = _total_eff + _x } forEach _travel_lengths;
                _total_eff = _total_eff + _travel_curr_len;

                // Evaluate only if enough distance traveled
                if (_total_eff > _min_dist_for_eval) then {
                    _air_water_dist = (_travel_lengths select 1) + (_travel_lengths select 2);
                    _ratio = _air_water_dist / _total_eff;

                    // Determine current bonus level
                    if (_ratio < 0.01) then {
                        _new_level = 2; // Full bonus
                    } else {
                        if (_ratio < THRESHOLD_INTENSIVE) then {
                            _new_level = 1; // Partial bonus
                        } else {
                            _new_level = 0; // No bonus
                        };
                    };

                    // If level changed, notify player!
                    if (_new_level != _last_bonus_level) then {
                        _last_bonus_level = _new_level;

                        _msg_key = switch (_new_level) do {
                            case 2: { "MSG_BONUS_STATUS_FULL" };
                            case 1: { "MSG_BONUS_STATUS_WARN" };
                            case 0: { "MSG_BONUS_STATUS_LOST" };
                            default { "" };
                        };

                        if (_msg_key != "") then {
                            localize _msg_key call XfHQChat;
                        };
                    };
                };

                _last_status_time = time;
            };

	        // 5. HUD Update (Throttled separately from bonus eval)
            // Note: We use _last_status_time for both to save a variable,
            // but bonus eval happens every BONUS_EVAL_INTERVAL seconds.
            // If you want separate throttling for HUD text, add another timer.
            // For now, let's keep HUD update frequent if transport/dist changes significantly.

            _changed = false;
            if (_new_type != _last_transport_type) then { _changed = true; _last_transport_type = _new_type; };
            if (_last_dist_base > 0) then {
                if (abs(_curr_dist - _last_dist_base) / _last_dist_base > 0.01) then { _changed = true; };
            };
            _last_dist_base = _curr_dist;

            if (_changed) then {
                [] call _fnc_showStatus;
            };
	    };
#endif

	    // --- ORIGINAL BASE CHECK LOGIC (Preserved) ---
		_player_veh = vehicle player;
		if ( _player_veh == player ) then { // only on feet player is counted to be on base
			if ( _was_in_veh ) then { // player get out of vehicle
				_veh_exit_cnt = _veh_exit_cnt + 1;
				_in_time_sum  = _in_time_sum + (time - _get_in_time);
				_was_in_veh   = false;
			};
			if (( getPos player ) call SYG_pointIsOnBase) then {  // player is in base rect!
				sleep 2;
                _spent_time = time  - _out_of_intro_time;

				if (( getPos player ) call SYG_pointIsOnBase) then {
					if (!isNull _active_veh) then {
						_vehs_used_arr set [count _vehs_used_arr, format["%1(c=%2,s=%3)", typeOf _active_veh, _veh_exit_cnt, round(_in_time_sum)]];
					};

                    if (base_visit_mission < 1) then {
                        base_visit_mission = 1;
                        [
                            "base_visit_mission",
                            name player,
                            base_visit_mission,
                            format["%1", _vehs_used_arr],
                            _spent_time
                        ] call XSendNetStartScriptServer;
                    };
                    base_visit_session = 1;
   					hint localize "+++ SYG_checkPlayerAtBase.sqf: base_visit_session/mission = 1";
				} else {
					hint localize "+++ SYG_checkPlayerAtBase.sqf: false base_visit_session/mission detectedm skipped";
				};
			};
			_delay = 5;
		} else { // player in vehicle
			if ( !_was_in_veh ) then {
				_was_in_veh  = true;
				_get_in_time = time;
				if ( _player_veh != _active_veh ) then {
					if (!isNull _active_veh) then {
						_vehs_used_arr set [count _vehs_used_arr, format["%1(c=%2,s=%3)", typeOf _active_veh, _veh_exit_cnt, round(_in_time_sum)]];
					};
					_active_veh   = _player_veh;
					_veh_exit_cnt = 0;
					_in_time_sum  = 0;
				};
			};
			_delay = 1;
		};
	} else {
    	// Player dead
    	_vehs_used_arr resize 0;
    	_active_veh  = objNull;
    	_was_in_veh  = false;
    	_in_time_sum = 0;
    	_delay       = 10;
#ifdef SYG_TRAVEL_BONUS_ENHANCED
    	// Reset travel tracking on death, but KEEP bonus eligibility
    	_travel_active = false;
    	_travel_lengths = [0,0,0,0]; // Reset all accumulated distances
    	_travel_veh = objNull;
    	_travel_type = 0;
    	_travel_dist_ref = -1;
    	_travel_curr_len = 0;

        // Reset Dynamic Bonus Status to Max
        _bonus_level = 2;
        _last_bonus_level = -1;

    	// Reset HUD tracking vars
    	_last_status_time = 0;
    	_last_transport_type = -1;
    	_last_dist_base = -1;

    	// Notify player (localized message)
    	localize "MSG_BONUS_RESET_DEATH" call XfHQChat;
#endif
    };
};

// Player reached base so remove Kerzon line
[] call _fnc_removeKerzonLine;

hint localize format["+++ SYG_checkPlayerAtBase.sqf: exit player check loop, base_visit_session = %1, veh history = %2", base_visit_session, _vehs_used_arr];

// --- Post-Loop Cleanup & Bonus Calculation ---

#ifdef SYG_TRAVEL_BONUS_ENHANCED
    // Remove Visuals (already called above, but safe to call again or ensure cleanup)
    // [] call _fnc_removeKerzonLine;

    // Calculate Final Bonus based on Dynamic Logic
    if (isNil "spell_cast") then {
        // Finalize last segment
        if (_travel_active) then {
            _travel_lengths set [_travel_type, (_travel_lengths select _travel_type) + _travel_curr_len];
        };

        // Sum effective distance
        _total_eff_dist = 0;
        { _total_eff_dist = _total_eff_dist + _x } forEach _travel_lengths;

        if (_total_eff_dist > 100) then {
            _air_water_dist = (_travel_lengths select 1) + (_travel_lengths select 2);
            _ratio = _air_water_dist / _total_eff_dist;

            // Final Decision
            if (_ratio < 0.01) then {
                BONUS_FOOT_ONLY call SYG_addBonusScore;
                format [localize "MSG_BONUS_FOOT_MASTER", BONUS_FOOT_ONLY] call XfHQChat;
            } else {
                if (_ratio < THRESHOLD_INTENSIVE) then {
                    BONUS_NO_AIR_WATER call SYG_addBonusScore;
                    format [localize "MSG_BONUS_LAND_ONLY", BONUS_NO_AIR_WATER] call XfHQChat;
                } else {
                    localize "MSG_BONUS_NONE_EXTENSIVE" call XfHQChat;
                };
            };
        };
    } else {
        if (!isNil "spell_cast") then {
            localize "MSG_BONUS_NONE_VODOO" call XfHQChat;
        };
    };
#endif

// --- Continue with original ACE block ---
#ifdef __ACE__
// inform players that he reached the base

_arr = [];
if (!isNil "SYG_initialEquipmentStr") then {
    _arr set [0, ["STR_INTRO_REARMED"]]; // First message to the player: "You have been given a weapon. Take care of it!"
};

_str   = (_spent_time/3600) call SYG_userTimeToStr; // Let's convert it to hours to match the parameter of this method
_bonus = d_ranked_a select 32;
_sound = "no_more_waiting";
_msg = "STR_INTRO_ON_BASE"; // "%1 reached base for %2! Life will be easier, more fun, especially with +%3 for that",

if (isNil "spell_cast") then { // If spell, not inform all about time you reached base
    _bonus call SYG_addBonusScore;
} else {
    _msg = "STR_INTRO_ON_BASE0"; // "%1 reached base for some time. But not receive +%2 points (voodoo used)! Life will be easier, more fun!"
    spell_cast = nil; // No need for it more
    _sound = "spell_wrong"; // For wrong spell
};

_arr set[count _arr, [_msg,name player,_str, _bonus]];
// STR_INTRO_ON_BASE1 = "You are assigned to the SpecNaz GRU detachment at Sahrani and to the local flying club, for the use of jump flags."
_arr set[count _arr, ["STR_INTRO_ON_BASE1"]];

// Sends upper common messages to you only
[ "msg_to_user", "*", _arr, 5, 0, false, _sound] spawn SYG_msgToUserParser; // Multu-msg-arr send to user

// Send this message to all except this player
[ "msg_to_user", "*", [[_msg,name player,_str, _bonus]], 0, 2, false, _sound ] call XSendNetStartScriptClient;

if (!isNil "SYG_initialEquipmentStr") then {
	// rearm from parajump set to the original equipment from last exit
	hint localize format["+++ SYG_checkPlayerAtBase.sqf: restore equipment: %1",SYG_initialEquipmentStr];
	[player, SYG_initialEquipmentStr] call SYG_rearmUnit;
    sleep 0.5;
    ["say_sound", player, call SYG_armorySound] call XSendNetStartScriptClientAll;
	SYG_initialEquipmentStr = nil;
};
#endif

// remove parachute
_para = player call SYG_getParachute;
if ( _para != "") then { player removeWeapon _para }; // The parachute is used, remove it from inventory

// stop last VIOLET flare, throw one GREEN flare
if (alive _flare) then { deleteVehicle _flare };
sleep 0.3;
_flare = "F_40mm_Green" createVehicleLocal _flag_pos;
[ _flare, "GREEN", _factor] execVM "scripts\emulateFlareFiredLocal.sqf";