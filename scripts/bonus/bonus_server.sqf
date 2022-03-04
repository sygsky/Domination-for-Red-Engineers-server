/*
	scripts\bonus\bonus_server.sqf

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
hint localize "+++ server_bonus_markers_array initiated +++";


