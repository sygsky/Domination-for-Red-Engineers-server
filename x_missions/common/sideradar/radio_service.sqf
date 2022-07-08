/*
	x_missions\common\sideradar\radio_service.sqf: started after first 56th SM completed
	author: Sygsky
	description: Handles the radio relay mast in good order
	sideradio_status is veriable with radio-relay status value as follow:
	-1 - radar is down, no truck
	 0 - radar not set, truck exists
	 1 - radar installed, truck not returned
	 2 - radar installed, truck successfully returned to the base and removed
	returns: nothing
*/

private [""];
while { isNil "d_radar" } do { sleep 120 };
// TODO: send message about radar existance
while { true } do {
	while {sideradio_status == 2} do {sleep 60};
	// if here, radar is killed and sideradio_status set to -1
	// run new radar installation procedure:
	//
	// 1. find radar (relay mast) and one or more trucks,
	// 2. transport and install relay mast on the Nothern ridge,
	// 3. return truck to the base)
	execVM "x_missions\common\x_sideradio.sqf";		// do all descibed in the higher lines
	while {sideradio_status != 2} do {sleep 60};
	// TODO: inform about GRU relay mast installed
};