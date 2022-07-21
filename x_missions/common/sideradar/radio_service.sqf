/*
	x_missions\common\sideradar\radio_service.sqf: started after first 56th SM completed
	author: Sygsky
	description: Handles the radio relay mast in good order
	sideradio_status is variable with radio-relay status value as follow:
	-1 - radar is down, no truck
	 0 - radar alive not set, truck exists
	 1 - radar installed, truck not returned
	 2 - radar installed, truck successfully returned to the base and removed
	returns: nothing
*/
#define __DEBUG__

// Creates new radar in towns near airbase, old one must be removed before this call
_create_radar = {
#ifdef __DEBUG__
	"BASE" execVM "x_missions\common\sideradar\createRelayMast.sqf"; // "BASE" used for debug purposes
#else
	"" execVM "x_missions\common\sideradar\createRelayMast.sqf"; // "BASE" used for debug purposes
#endif
	while {!alive d_radar_truck} do {sleep 1};
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
_create_items = {
	private ["_created","_pos"];
	_createdMast = false;
	_msg = ["STR_RADAR_INIT"];
	if (!alive d_radar) then {
		// remove dead radar
		call _create_radar;
		_createdMast = true;
		_msg set [1, "STR_RADAR_INIT1"];
	} else { _msg set [1, ""] };
	_createdTruck = false;
	if (!alive d_radar_truck) then {
		// remove dead truck
		call _create_truck;
		_createdTruck = true;
		// STR_SYS_AND
		_msg set [2,if (_createdMast) then {"STR_SYS_AND"} else {""}];
		_msg set [3, "STR_RADAR_INIT2"];
	} else { _msg set [2, ""]; _msg set [3, ""];};
	if ( _createdMast || _createdTruck ) then {
		processInitCommands;
		sideradio_status = 0;
		publicVariable "sideradio_status";
//		["msg_to_user", "",  [ _msg ]] call XSendNetStartScriptClient; // "The GRU relay mast <and the truck to transport it> can be found in the nearest to the base settlements"
	};
	_created
};

while { isNil "d_radar" } do { sleep 120 };
["msg_to_user", "",  [["STR_RADAR_INFO"]], 0, 15 ] call XSendNetStartScriptClient; // "The GRU requires a radio relay mast to work!"

while { true } do {
	// wait until radio-relay is ready
	while {sideradio_status != 2} do { // We provide simultaneous availability of a mast and a truck
		sleep 60;
		if (!(alive d_radar && alive d_radar_truck) ) then { _create_items };
	};
	while {sideradio_status == 2} do { // if radio is working, do nothing
		sleep 60;
	};
};