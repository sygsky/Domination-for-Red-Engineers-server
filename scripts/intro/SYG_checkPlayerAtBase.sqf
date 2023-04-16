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

_flare = objNull;
_pos = getPos AISPAWN; // FLAG_BASE; // [9529.5,9759.2,0]; // point near central gate to the base
_flag_pos = [];
_factor = (400 / 1600) max 12.5;
// set flare position as slightly random one

// if (isNil "base_visit_session") then { base_visit_session = 0 }; // init visit status
while { base_visit_session <= 0 } do {
	sleep 5;
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
			if (base_visit_session == 0) then {
				if (( getPos player ) call SYG_pointIsOnBase) then {  // player is in base rect!
					base_visit_mission = 1;
					["base_visit_mission", name player, base_visit_mission] call XSendNetStartScriptServer; // store new value on the server
					base_visit_session = base_visit_mission;
					hint localize "+++ SYG_checkPlayerAtBase.sqf: base_visit_session/mission = 1";
				};
			};
		};
	};
};
hint localize format["+++ SYG_checkPlayerAtBase.sqf: exit player check loop, base_visit_session = %1", base_visit_session];

#ifdef __ACE__
// inform player that he reached the base
if (!isNil "SYG_initialEquipmentStr") then {
	[ "msg_to_user", "*", [["STR_INTRO_REARMED"],["STR_INTRO_ON_BASE",name player],["STR_INTRO_ON_BASE1"]], 5, 0, false, "no_more_waiting" ] spawn SYG_msgToUserParser; // Send to client:"%1 have reached the base! Life will get easier from here."
	[ "msg_to_user", "*", [["STR_INTRO_ON_BASE",name player]], 5, 0, false, "no_more_waiting" ] call XSendNetStartScriptClient; // Send to all others: "%1 have reached the base! Life will get easier from here."
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

