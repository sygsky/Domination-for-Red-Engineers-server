/*
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
#define BASE_CENTER_POS (d_base_array select 0)
#define BONUS_FOOT_ONLY 200
#define BONUS_NO_AIR_WATER 50
#define THRESHOLD_INTENSIVE 0.20 // 20% limit for air/water usage to get max bonus
#define KERZON_LINE_ADD 8000 // Add length to Kerzon line
#define KERZON_LINE_THICKNESS 6 // Thickness in meters to see it on map at any scale
#define LINE_COLOR "ColorRedAlpha"
#define BONUS_EVAL_INTERVAL 3 // Seconds between dynamic bonus status checks

// HUD Update Thresholds
#define HUD_UPDATE_MIN_DIST 100   // Meters from last report point
#define HUD_UPDATE_MIN_RATIO 0.01 // 1% of remaining distance
#define HUD_UPDATE_ABS_MIN 10     // Minimum absolute change in meters

// --- Helper: Simplified Travel Type to values of (0-3) ---
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

    _baseLen = [_p1, _p2] call SYG_distance2D;
    _dir = [_p1, _p2] call XfDirToObj;

    _mid = [
        ((_p1 select 0) + (_p2 select 0)) / 2,
        ((_p1 select 1) + (_p2 select 1)) / 2,
        0
    ];

    _extLen = _baseLen + KERZON_LINE_ADD;

    _markerName = "SYG_KerzonLineMarker";
    deleteMarkerLocal _markerName;

    _marker = createMarkerLocal [_markerName, _mid];
    _marker setMarkerShapeLocal "RECTANGLE";
    _marker setMarkerSizeLocal [KERZON_LINE_THICKNESS, _extLen / 2 ];
    _marker setMarkerDirLocal _dir;
    _marker setMarkerColorLocal LINE_COLOR;
    _marker setMarkerBrushLocal "Solid";

    hint localize format ["+++ Kerzon Line drawn. Length: %1m, dir: %2", round _extLen, round(_dir)];
    [player, format [localize "MSG_KERZON_LINE_DRAWN", LINE_COLOR]] call XfVehicleChat;
};

// --- Helper: Remove Kerzon Line ---
_fnc_removeKerzonLine = {
    private ["_str"];
    deleteMarkerLocal "SYG_KerzonLineMarker";
    _str = localize "MSG_KERZON_LINE_REMOVED";
    _str call XfHQChat;
    hint localize _str;
};

// --- Helper: Show Status HUD ---
_fnc_showStatus = {
    private ["_pos", "_distToLine", "_distToBase", "_typeCode", "_typeStr", "_msg", "_totalEff", "_statsStr", "_pAir",
    "_pWater", "_pLand", "_pFoot"];

    _pos = getPos player;
    _distToLine = round(abs([SYG_Kerzon_line select 0, SYG_Kerzon_line select 1, _pos] call SYG_distPoint2Vector1));
    _distToBase = round([_pos, BASE_CENTER_POS] call SYG_distance2D);

    _typeCode = (vehicle player) call _fnc_getTravelType;

    _typeStr = switch (_typeCode) do {
        case 0: {localize "MSG_TRAVEL_MODE_FOOT"};
        case 1: {localize "MSG_TRAVEL_MODE_AIR"};
        case 2: {localize "MSG_TRAVEL_MODE_WATER"};
        case 3: {localize "MSG_TRAVEL_MODE_LAND"};
        default {localize "MSG_TRAVEL_MODE_UNK"};
    };

    // Calculate percentages for stats line
    _totalEff = 0;
    { _totalEff = _totalEff + _x } forEach _travel_lengths;
    _totalEff = _totalEff + _travel_curr_len;
    _statsStr = "";
    if ( (_totalEff > 0) && (!isNil "_dist_line_to_base_ref") && (_dist_line_to_base_ref > 0)) then {
        _type_path = [];
        for "_i" from 0 to 3 do {
            _len = _travel_lengths select _i;
            if (_i == _typeCode) then {
                _len = _len + _travel_curr_len; // Add to current path length
            };
            _type_path set [i, round(( _len / _dist_line_to_base_ref) * 100) ];
        };
        _statsStr = format [localize "MSG_TRAVEL_STATS_SHORT", _type_path select 1, _type_path select 2, _type_path select 3, _type_path select 0];
    } else {
        _statsStr = "ожидание...";
    };

    // "STATUS | Dist to Line: %1m | To Base: %2m (%3m)| Mode: %4"
    _msg = format [localize "MSG_TRAVEL_STATUS", _distToLine, _distToBase, _dist_line_to_base_ref, _typeStr];
    _msg call XfHQChat;

    format [localize "MSG_TRAVEL_STATS", _statsStr] call XfHQChat;
    hint localize format ["+++ SYG_checkPlayerAtBase.sqf: %1. %2", _statsStr, _msg];
    hint localize format ["+++ SYG_checkPlayerAtBase.sqf:_travel_lengths is %1", _travel_lengths];
};

// --- Placeholder: Send Message to All ---
_sendMsgToAll = {
    private ["_msg"];
    _msg = _this;
    // TODO: Implement network broadcast
    // diag_log format ["[GLOBAL MSG] %1", _msg];
};

#endif


_start_time        = _this;
_out_of_intro_time = time;
hint localize format[ "+++ SYG_checkPlayerAtBase.sqf: Started, intro start at %1, intro stop at %2", _start_time, _out_of_intro_time ];

_spent_time = 0;
_flare = objNull;
_pos = getPos AISPAWN;
_flag_pos = [];
_factor = (400 / 1600) max 12.5;

_vehs_used_arr = [];
_active_veh = objNull;
_veh_exit_cnt = 0;
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
_bonus_level = 2;
_last_bonus_level = -1;
_min_dist_for_eval = 500;

// Reference distance from Line crossing point to Base
_dist_line_to_base_ref = -1;

// Init HUD tracking vars
_last_status_time = 0;
_last_transport_type = -1;
_last_dist_base = -1;
_last_report_pos = []; // Position at last status update
_last_km_reported = -1; // For global km announcements

[] call _fnc_drawKerzonLine;
#endif


_delay = 5;
while { base_visit_session <= 0 } do {
	sleep _delay;

	if (!alive _flare) then {
		_flag_pos set [ 0, (_pos select 0) + (random 5) ];
		_flag_pos set [ 1, (_pos select 1) + (random 5) ];
		_flag_pos set [ 2, 250 + (random 5) ];
		_flare = "F_40mm_White" createVehicleLocal _flag_pos;
		[ _flare, "VIOLET", _factor] execVM "scripts\emulateFlareFiredLocal.sqf";
	};

	if ( alive player ) then {

#ifdef SYG_TRAVEL_BONUS_ENHANCED
	    // --- NEW TRAVEL BONUS LOGIC ---
	    _p_veh = vehicle player;
	    _p_pos = getPos player;

	    // 1. Check Relation to Kerzon Line
	    _rel = [SYG_Kerzon_line select 0, SYG_Kerzon_line select 1, _p_pos] call SYG_pointToVectorRel;

	    // CHECK FOR RETURN BEHIND LINE (Reset Logic)
	    // Assuming '-1' is the Safe/Antigua side.
	    if (_travel_active && _rel == -1) then {
	        localize "MSG_TRAVEL_RETURN_BEHIND_LINE" call XfHQChat;

            _travel_active = false;
            _travel_lengths = [0,0,0,0];
            _travel_veh = objNull;
            _travel_type = 0;
            _travel_dist_ref = -1;
            _travel_curr_len = 0;
            _dist_line_to_base_ref = -1;

            _bonus_level = 2;
            _last_bonus_level = -1;

            _last_status_time = 0;
            _last_transport_type = -1;
            _last_dist_base = -1;
            _last_report_pos = [];
            _last_km_reported = -1;

            hint localize format ["DEBUG: Reset due to return behind line."];
	    };

	    // Start tracking if NOT above the line (assuming '+1' is Base Side)
	    if (!_travel_active && _rel != -1) then {
	        _travel_active = true;
	        _travel_veh = _p_veh;
	        _travel_type = (_p_veh) call _fnc_getTravelType;

            _dist_line_to_base_ref = round([_p_pos, BASE_CENTER_POS] call SYG_distance2D);
	        _travel_dist_ref = _dist_line_to_base_ref;
	        _travel_curr_len = 0;

            localize "MSG_TRAVEL_TRACKING_STARTED" call XfHQChat;
            hint localize format ["DEBUG: Tracking started. Ref dist to base: %1m", round _dist_line_to_base_ref];

            // Init report position
            _last_report_pos = _p_pos;
            _last_dist_base = _dist_line_to_base_ref;
	    };

	    // 2. Update Progress
	    if (_travel_active) then {
	        _new_type = (_p_veh) call _fnc_getTravelType;
	        _curr_dist = [_p_pos, BASE_CENTER_POS] call SYG_distance2D;

	        // Vehicle Change?
	        if (_p_veh != _travel_veh) then {
	            _travel_lengths set [_travel_type, (_travel_lengths select _travel_type) + _travel_curr_len];
	            _travel_veh = _p_veh;
	            _travel_type = _new_type;
	            _travel_curr_len = 0;

	            _typeStr = switch (_travel_type) do {
	                case 0: {localize "MSG_TRAVEL_MODE_FOOT"};
                    case 1: {localize "MSG_TRAVEL_MODE_AIR"};
                    case 2: {localize "MSG_TRAVEL_MODE_WATER"};
                    case 3: {localize "MSG_TRAVEL_MODE_LAND"};
                    default {localize "MSG_TRAVEL_MODE_UNK"};
	            };
                format [localize "MSG_VEHICLE_CHANGED", _typeStr] call XfHQChat;
            };

	        // Calculate Delta
	        _delta = _travel_dist_ref - _curr_dist;
	        _travel_curr_len = _travel_curr_len + _delta;
	        _travel_dist_ref = _curr_dist;

	        // 3. DYNAMIC BONUS EVALUATION
            if (time - _last_status_time > BONUS_EVAL_INTERVAL) then {
                _total_eff = 0;
                { _total_eff = _total_eff + _x } forEach _travel_lengths;
                _total_eff = _total_eff + _travel_curr_len;

                if (_total_eff > _min_dist_for_eval) then {
                    _air_water_dist = (_travel_lengths select 1) + (_travel_lengths select 2);
                    _ratio = _air_water_dist / _total_eff;

                    if (_ratio < 0.01) then {
                        _new_level = 2;
                    } else {
                        if (_ratio < THRESHOLD_INTENSIVE) then {
                            _new_level = 1;
                        } else {
                            _new_level = 0;
                        };
                    };

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

	        // 4. HUD Update Logic
            _changed = false;

            // Check Transport Change
            if (_new_type != _last_transport_type) then {
                _changed = true;
                _last_transport_type = _new_type;
            };

            // Check Distance/Position Change (Only if below Kerzon Line)
            if (_rel != -1 && count _last_report_pos > 0) then {
                _dist_moved = [_p_pos, _last_report_pos] call SYG_distance2D;
                _dist_diff_abs = abs(_curr_dist - _last_dist_base);

                // Condition: Moved >= 100m OR (Approached > 1% AND absolute change >= 10m)
                _cond_dist = if (_travel_type == 1) then {
                    _dist_moved >= HUD_UPDATE_MIN_DIST * 10 // For air vehicles
                } else {
                    _dist_moved >= HUD_UPDATE_MIN_DIST // For water and land vehicles
                };
                _cond_ratio = (_last_dist_base > 0) && ((_dist_diff_abs / _last_dist_base) > HUD_UPDATE_MIN_RATIO);
                _cond_abs = _dist_diff_abs >= HUD_UPDATE_ABS_MIN;

                if (_cond_dist || (_cond_ratio && _cond_abs)) then {
                    _changed = true;
                };
            };

            if (_changed) then {
                [] call _fnc_showStatus;

                // Update report anchors
                _last_report_pos = _p_pos;
                _last_dist_base = _curr_dist;

                // Global KM Announcement
                _curr_km = floor(_curr_dist / 1000);
                if (_curr_km != _last_km_reported) then {
                    _last_km_reported = _curr_km;
                    // MSG_GLOBAL_KM_UPDATE = "New arrival '%1' is already %2 km from base."
                    _global_msg = format [localize "MSG_GLOBAL_KM_UPDATE", name player, _curr_km];
                    if (_curr_km == 0) then {
                        // MSG_GLOBAL_KM_UPDATE0 = "New arrival '%1' is already very close."
                        _global_msg = format [localize "MSG_GLOBAL_KM_UPDATE0", name player];
                    };
                    _global_msg call _sendMsgToAll;
                };
            };
	    };
#endif

	    // --- ORIGINAL BASE CHECK LOGIC (Preserved) ---
		_player_veh = vehicle player;
		if ( _player_veh == player ) then {
			if ( _was_in_veh ) then {
				_veh_exit_cnt = _veh_exit_cnt + 1;
				_in_time_sum  = _in_time_sum + (time - _get_in_time);
				_was_in_veh   = false;
			};
			if (( getPos player ) call SYG_pointIsOnBase) then {
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
		} else {
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
    	_travel_active = false;
    	_travel_lengths = [0,0,0,0];
    	_travel_veh = objNull;
    	_travel_type = 0;
    	_travel_dist_ref = -1;
    	_travel_curr_len = 0;
        _dist_line_to_base_ref = -1;

        _bonus_level = 2;
        _last_bonus_level = -1;

    	_last_status_time = 0;
    	_last_transport_type = -1;
    	_last_dist_base = -1;
        _last_report_pos = [];
        _last_km_reported = -1;

    	localize "MSG_BONUS_RESET_DEATH" call XfHQChat;
#endif
    };
};

[] call _fnc_removeKerzonLine;
hint localize format["+++ SYG_checkPlayerAtBase.sqf: exit loop, session=%1", base_visit_session];

#ifdef SYG_TRAVEL_BONUS_ENHANCED
if (isNil "spell_cast") then {
    if (_travel_active) then {
        _travel_lengths set [_travel_type, (_travel_lengths select _travel_type) + _travel_curr_len];
    };

    _total_eff_dist = 0;
    { _total_eff_dist = _total_eff_dist + _x } forEach _travel_lengths;

    if (_total_eff_dist > 100) then {
        _air_water_dist = (_travel_lengths select 1) + (_travel_lengths select 2);
        _ratio = _air_water_dist / _total_eff_dist;

        hint localize format["+++ SYG_checkPlayerAtBase.sqf: finally - _total_eff_dist %1, _air_water_dist %2, _ratio %3", _total_eff_dist, _air_water_dist, _ratio];

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

#ifdef __ACE__
_arr = [];
if (!isNil "SYG_initialEquipmentStr") then {
    _arr set [0, ["STR_INTRO_REARMED"]];
};
_str   = (_spent_time/3600) call SYG_userTimeToStr;
_bonus = d_ranked_a select 32;
_sound = "no_more_waiting";
_msg = "STR_INTRO_ON_BASE";

if (isNil "spell_cast") then {
    _bonus call SYG_addBonusScore;
} else {
    _msg = "STR_INTRO_ON_BASE0";
    spell_cast = nil;
    _sound = "spell_wrong";
};

_arr set[count _arr, [_msg,name player,_str, _bonus]];
_arr set[count _arr, ["STR_INTRO_ON_BASE1"]];
[ "msg_to_user", "*", _arr, 5, 0, false, _sound] spawn SYG_msgToUserParser;
[ "msg_to_user", "*", [[_msg,name player,_str, _bonus]], 0, 2, false, _sound ] call XSendNetStartScriptClient;

if (!isNil "SYG_initialEquipmentStr") then {
	hint localize format["+++ SYG_checkPlayerAtBase.sqf: restore equipment: %1",SYG_initialEquipmentStr];
	[player, SYG_initialEquipmentStr] call SYG_rearmUnit;
    sleep 0.5;
    ["say_sound", player, call SYG_armorySound] call XSendNetStartScriptClientAll;
	SYG_initialEquipmentStr = nil;
};
#endif

_para = player call SYG_getParachute;
if ( _para != "") then { player removeWeapon _para };

if (alive _flare) then { deleteVehicle _flare };
sleep 0.3;
_flare = "F_40mm_Green" createVehicleLocal _flag_pos;
[ _flare, "GREEN", _factor] execVM "scripts\emulateFlareFiredLocal.sqf";