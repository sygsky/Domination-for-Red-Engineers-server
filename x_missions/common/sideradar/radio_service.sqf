/*
	x_missions\common\sideradar\radio_service.sqf: started after first 56th SM completed
	author: Sygsky
	description: Handles the radio relay mast in good order
	sideradio_status is veriable with radio-relay status value as follow:
	-1 - radar is down, no truck
	 0 - radar alive not set, truck exists
	 1 - radar installed, truck not returned
	 2 - radar installed, truck successfully returned to the base and removed
	returns: nothing
*/

// Creates new radar in towns near airbase, old one must be removed before this call
_create_radar = {
	"BASE" execVM "x_missions\common\sideradar\createRelayMast.sqf";
	while {!alive d_radar_truck} do {sleep 1};
};

// Creates new truck in town near airbase, old one must be removed before this call
_create_truck = {
	"BASE" execVM "x_missions\common\sideradar\createTruck.sqf";
	while {!alive d_radar_truck} do {sleep 1};
};

// creates radar/truck somwhere, assign "killed" event to it etc
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
		_msg set [2, "STR_RADAR_INIT2"];
	} else { _msg set [2, ""] };
	if ( _createdMast || _createdTruck ) then {
		processInitCommands;
		sideradio_status = 0;
		["msg_to_user", "",  [ _msg ]] call XSendNetStartScriptClient; // "The GRU repeater mast and the truck to transport it can be found in the nearest to the base settlements"
	};
	_created
};

while { isNil "d_radar" } do { sleep 120 };
["msg_to_user", "",  [["STR_RADAR_INFO"]], 0, 15 ] call XSendNetStartScriptClient; // "The GRU requires a radio relay mast to work!"

while { true } do {
	// wait until radio-relay is ready
	while {sideradio_status != 2} do {
		sleep 60;
		if (!(alive d_radar && alive d_radar_truck) ) then { _create_items };
	};
	sleep 60;
};