/*
	scripts\bonus\bonus_server.sqf: not used anymore

	author: Sygsky

	description: this code checks if bonus vehicle is not dead.
	This code does not control whether the machine is in the base or not.
	Player must call "Inspect" command on the vehicle (client computer only) to registed it to be onto base
	If vehicle is dead, it is removed from the list and new array is published over network;

	returns: nothing
*/

#include "bonus_def.sqf"

// Markered bonus vehicles array, any new vehicles added to it one by one
if (!isNil "server_bonus_markers_array" ) exitWith {};
server_bonus_markers_array = [];
while { true } do {
	_killed = false;
	_last_id = (count server_bonus_markers_array) -1;
	for "_i" from 0 to _last_id  do {
		_veh = server_bonus_markers_array select _i;
		if ( !alive _veh ) then { server_bonus_markers_array set[ _i, "RM_ME" ] };
		if (_i mod 10 == 0) then { sleep 0.05; };
	};
	if (_killed) then { server_bonus_markers_array call SYG_cleanArray; }; // remove "RM_ME" items
	sleep 60;
};
hint localize "+++ server_bonus_markers_array initiated +++";


