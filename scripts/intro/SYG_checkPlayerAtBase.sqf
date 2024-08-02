/*
	scripts\intro\SYG_checkPlayerAtBase.sqf run on client only
	author: Sygsky
	description: checks if player visited base rectangle. If yes, set variable base_visit_session = 1 and exit
	returns: nothing

    Checks if alive player was at base.
	Call as: [] execVM  "scripts\intro\SYG_checkPlayerAtBase.sqf";

*/

#include "x_setup.sqf"


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
// set flare position as slightly random one

// Array of vehiles ised
_vehs_used_arr = [];
_active_veh = objNull; // Last vehicle in use by this player
_veh_exit_cnt = 0; // Number of consecutive visits to this transport by a player
_in_time_sum = 0;
_get_in_time = 0;
_was_in_veh = false;

// if (isNil "base_visit_session") then { base_visit_session = 0 }; // init visit status
_delay = 5;
while { base_visit_session <= 0 } do {
	sleep _delay;
	// launch a yellow flare over the base to attract the player's attention (to tell him where to go)
	if (!alive _flare) then {
		_flag_pos set [ 0, (_pos select 0) + (random 5) ];
		_flag_pos set [ 1, (_pos select 1) + (random 5) ];
		_flag_pos set [ 2, 250 + (random 5) ]; // flare spawn height AGL
		_flare = "F_40mm_White" createVehicleLocal _flag_pos;
//		_flare = "F_40mm_Yellow" createVehicleLocal _flag_pos;
//		[ _flare, "YELLOW", _factor] execVM "scripts\emulateFlareFiredLocal.sqf";
		[ _flare, "VIOLET", _factor] execVM "scripts\emulateFlareFiredLocal.sqf"; // not works
	};
	if ( alive player ) then {
		_player_veh = vehicle player;
		if ( _player_veh == player ) then { // only on feet player is counted to be on base
			if ( _was_in_veh ) then { // player get out of vehicle
				_veh_exit_cnt = _veh_exit_cnt + 1;	// bump in vehicle exit counters
				_in_time_sum  = _in_time_sum + (time - _get_in_time);	// bump in vehicle time
				_was_in_veh   = false;
			};
			if (( getPos player ) call SYG_pointIsOnBase) then {  // player is in base rect!
				// Ensure player being on base 2 seconds
				sleep 2;
				if (( getPos player ) call SYG_pointIsOnBase) then {
					// add last visited vehicle to the history array
					if (!isNull _active_veh) then {
						_vehs_used_arr set [count _vehs_used_arr, format["%1(c=%2,s=%3)", typeOf _active_veh, _veh_exit_cnt, round(_in_time_sum)]]; // store visited vehicle type to print afer visit
					};

                    if (base_visit_mission < 1) then {
                        base_visit_mission = 1;
                        _spent_time = time  - _out_of_intro_time; // _start_time;
                        [
                            "base_visit_mission",
                            name player,
                            base_visit_mission,
                            format["%1", _vehs_used_arr], // history of vehicles
                            _spent_time // Time spent to reach the base from Antigua
                        ] call XSendNetStartScriptServer; // store new value on the server
                    };
                    base_visit_session = 1;
   					hint localize "+++ SYG_checkPlayerAtBase.sqf: base_visit_session/mission = 1";
				} else {
					hint localize "+++ SYG_checkPlayerAtBase.sqf: false base_visit_session/mission detectedm skipped";
				};
			} else { // We are on feet

			};
			_delay = 5; // Player is on his own, slow check on base frequence
		} else { // player in vehicle, up the frequence of on base checks
			// Handle with last used and newly visited vehicles
			if ( !_was_in_veh ) then { // player entered vehicle 1-5 seconds ago
				_was_in_veh  = true;
				_get_in_time = time; // Time when player get in the vehicle (it doesn't matter, if first time or if next one)
				// check if player vehicle is the same as old one
				if ( _player_veh != _active_veh ) then { // Other vehicle visited
					if (!isNull _active_veh) then {
						_vehs_used_arr set [count _vehs_used_arr, format["%1(c=%2,s=%3)", typeOf _active_veh, _veh_exit_cnt, round(_in_time_sum)]]; // store visited vehicle type to print after get out
					};
					_active_veh   = _player_veh; // store as last vehicle visited
					_veh_exit_cnt = 0;	// Init exit count
					_in_time_sum  = 0; // start new time sum calcuulation of player being in the vehicle
				};
			};
			_delay = 1;
		};
	} else {
		// remove all used vehicles list on player death
		_vehs_used_arr resize 0;
		_active_veh  = objNull;
		_was_in_veh  = false;
		_in_time_sum = 0;
		_delay       = 10;
	};
};

hint localize format["+++ SYG_checkPlayerAtBase.sqf: exit player check loop, base_visit_session = %1, veh history = %2", base_visit_session, _vehs_used_arr];

#ifdef __ACE__
// inform players that I've reached the base
if (!isNil "SYG_initialEquipmentStr") then {
    _str = (_spent_time/3600) call SYG_userTimeToStr; // Let's convert it to hours to match the parameter of this method
	// "You have been given a weapon. Take care of it!",
	// "%1 have reached the base in %2! Life will get easier from here.",
	// "You are assigned to the SpecNaz GRU detachment at Sahrani and to the local flying club, for the use of jump flags."
	// Sends upper messages to you only
	[ "msg_to_user", "*", [["STR_INTRO_REARMED"],["STR_INTRO_ON_BASE",name player,_str],["STR_INTRO_ON_BASE1"]], 5, 0, false, "no_more_waiting" ] spawn SYG_msgToUserParser; // Send to client:"%1 have reached the base! Life will get easier from here."
	// Send this message to all except this player
    if (!isNil "spell_сast") then { // If spell, not inform all about time you reached base
        _str = localize "STR_INTRO_ON_BASE_SPELL"; // "some time"
        spell_cast = nil; // No need for it more
    };
	[ "msg_to_user", "*", [["STR_INTRO_ON_BASE",name player,_str]], 0, 2, false, "no_more_waiting" ] call XSendNetStartScriptClient; // Send to all others: "%1 have reached the base! Life will get easier from here."
	// rearm from parajump set to the original equipment from last exit
	hint localize format["+++ SYG_checkPlayerAtBase.sqf: restore equipment: %1",SYG_initialEquipmentStr];
	[player, SYG_initialEquipmentStr] call SYG_rearmUnit;
	SYG_initialEquipmentStr = nil; // not needed more
};

sleep 0.5;
["say_sound", player, call SYG_armorySound] call XSendNetStartScriptClientAll; // playSound on all connected player computers immediately
//playSound (call SYG_armorySound); // random armory sound
#endif
// remove parachute
_para = player call SYG_getParachute;
if ( _para != "") then { player removeWeapon _para }; // The parachute is used, remove it from inventory

// stop last VIOLET flare, throw one GREEN flare
if (alive _flare) then { deleteVehicle _flare };
sleep 0.3;
_flare = "F_40mm_Green" createVehicleLocal _flag_pos;
[ _flare, "GREEN", _factor] execVM "scripts\emulateFlareFiredLocal.sqf";
