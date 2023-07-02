/*
	scripts\intro\SYG_checkPlayerAtBase.sqf
	author: Sygsky
	description: checks if player visited base rectangle. If yes, set variable base_visit_session to 1 and exit
	returns: nothing

    Checks if alive player was at base.
	Call as: [] execVM  "scripts\intro\SYG_checkPlayerAtBase.sqf";

*/

#include "x_setup.sqf"

hint localize "+++ SYG_checkPlayerAtBase.sqf: Started";

_start_time = _this; // Session start time
_spent_time = 0; // Time to reach the base
_flare = objNull;
_pos = getPos AISPAWN; // FLAG_BASE; // [9529.5,9759.2,0]; // point near central gate to the base
_flag_pos = [];
_factor = (400 / 1600) max 12.5;
// set flare position as slightly random one

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
		if (vehicle player == player) then { // only on feet player is counted to be on base
			if (( getPos player ) call SYG_pointIsOnBase) then {  // player is in base rect!
				// Ensure player being on base 2 seconds
				sleep 2;
				if (( getPos player ) call SYG_pointIsOnBase) then {
					base_visit_mission = 1;
					_veh = nearestObjects [player,["LandVehicle","Air"/*,"Ship"*/],50];// Any nearest vehicle
					_spent_time = time  - _start_time;
					[
						"base_visit_mission",
						name player,
						base_visit_mission,
						if ((count _veh) == 0) then {"<no veh>"} else {typeOf (_veh select 0)},
						_spent_time // Time spent to reach the base from Antigua
					] call XSendNetStartScriptServer; // store new value on the server
					base_visit_session = base_visit_mission;
					hint localize "+++ SYG_checkPlayerAtBase.sqf: base_visit_session/mission = 1";
				} else {
					hint localize "+++ SYG_checkPlayerAtBase.sqf: false base_visit_session/mission detectedm skipped";
				};
			};
			_delay = 5; // Player is on his own, slow check on base frequence
		}  else {_delay = 1}; // player in vehicle, up the check on base frequence
	} else { _delay = 10; };
};
hint localize format["+++ SYG_checkPlayerAtBase.sqf: exit player check loop, base_visit_session = %1", base_visit_session];

#ifdef __ACE__
// inform players that I've reached the base
if (!isNil "SYG_initialEquipmentStr") then {
	_str = (_spent_time/3600) call SYG_userTimeToStr; // Let's convert it to hours to match the parameter of this method
	// "You have been given a weapon. Take care of it!",
	// "%1 have reached the base in %2! Life will get easier from here.",
	// "You are assigned to the SpecNaz GRU detachment at Sahrani and to the local flying club, for the use of jump flags."
	// Sends upper messages to you only
	[ "msg_to_user", "*", [["STR_INTRO_REARMED"],["STR_INTRO_ON_BASE",name player,_str],["STR_INTRO_ON_BASE1"]], 5, 0, false, "no_more_waiting" ] spawn SYG_msgToUserParser; // Send to client:"%1 have reached the base! Life will get easier from here."
	// Send this message to all
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
