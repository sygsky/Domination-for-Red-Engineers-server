/*
	Runs only on server!
	x_missions\common\sideradar\radio_service.sqf: started after first 56th SM completed
	author: Sygsky
	description: Handles the radio relay mast in good order during whole game period
	sideradio_status is variable with radio-relay status value as follow:
	-1 - radar is down, no truck
	 0 - radar alive not set, truck exists
	 1 - radar installed, truck still not returned to the base (to the FLAG_BASE).
	    If truck is killed, you should to reinstall radiomast with new truck and again try to return to the FLAG_BASE
	 2 - radar installed, truck successfully returned to the FLAG_BASE, and from now not needed (if killed etc)
	returns: nothing
*/
//#define __DEBUG__

// Creates new radar in towns near airbase, old one must be removed before this call
_create_radar = {
#ifdef __DEBUG__
	"BASE" execVM "x_missions\common\sideradar\createRelayMast.sqf"; // "BASE" used for debug purposes
#else
	"" execVM "x_missions\common\sideradar\createRelayMast.sqf"; // "BASE" used for debug purposes
#endif
	while {!alive d_radar} do {sleep 1};
};

// Creates new truck in town near airbase, old one must be removed before this call
_create_truck = {
#ifdef __DEBUG__
	"BASE" execVM "x_missions\common\sideradar\createTruck.sqf";
#else
	"" execVM "x_missions\common\sideradar\createTruck.sqf";
#endif
	while {!alive d_radar_truck} do {sleep 1};
};

// creates radar/truck somewhere, assign "killed" event to them etc
// returns true if something is created, else false
_create_items = {
	hint localize format["+++ radio_service.sqf: create radio items, alive radar %1, alive truck %2",alive d_radar, alive d_radar_truck];
	private ["_msg","_status"];
	_msg = [];
	_status = sideradio_status;
	// Check if mast needs to be recreated
	if (!alive d_radar) then {
		// remove dead radar
		call _create_radar;
		sideradio_status = 0;
		_msg set [count _msg, ["STR_RADAR_INIT"] ]; // "Look for a replacement radio mast in one of the settlements closest to the base"
	};
	// Check if we need to create truck now.
	// If mast installation not completed (it is not installed or install truck still not returned to the FLAG_BASE),
	//  we have to recreate the truck
	if (sideradio_status < 2) then {
        if (!alive d_radar_truck) then {
            // create new truck
            call _create_truck;
            sideradio_status = 0;  // Do we need it?
            _msg set [count _msg, ["STR_RADAR_INIT2"] ]; // "Look for an blue truck to transport relay mast in one of the towns near the base"
        };
	};
	if ( count _msg > 0 ) exitWith { // something was changed
	    processInitCommands;
	    // send messages to all players
	    [ "msg_to_user", "",  _msg, 5, 5, false, "return" ] call XSendNetStartScriptClientAll; // Messages about mast and/or truck recreation
	    if (_status != sideradio_status) then { publicVariable "sideradio_status" };
	    true // mast and/or truck created
	};
	false // nothing created
};

while { isNil "d_radar" } do { sleep 120 };

sleep 2;

while { true } do {
	if (!alive d_radar) then {
		// say radio and print message in the same time: "The GRU requires a radio relay mast to work!"
		["say_radio", call SYG_randomRadioNoise, ["msg_to_user", "",  [["STR_RADAR_INFO"]], 0, 15, false ]] call XSendNetStartScriptClientAll;
		hint localize "+++ radio_service.sqf: radar killed";
	};
	hint localize format["+++ radio_service.sqf: wait while status < 2 (%1)",sideradio_status];
	// wait until radio-relay is ready
	while {sideradio_status < 2} do { // Provide simultaneous availability of a mast and a truck
		sleep 30;
		if ( !( (alive d_radar) && (alive d_radar_truck) ) ) then {call _create_items };
	};
	hint localize format["+++ radio_service.sqf: wait while status == 2 (now %1)", sideradio_status];
	while {sideradio_status == 2} do { sleep 60; }; // while radio is workable, do nothing
	hint localize format["+++ radio_service.sqf: continue with status == %1", sideradio_status];
};