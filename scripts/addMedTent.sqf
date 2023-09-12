/*
	scripts\addMedTent.sqf: #598: add Mash to the new town, runs only on server
	author: Sygsky
	description: adds Medical text to the town/SM (in future)
	call: (_wp_arr select _ind) execVM "scripts\addMedTent.sqf";
	returns: nothing
*/

#include "x_macros.sqf"

hint localize format[ "+++ scripts\addMedTent.sqf: MASH created in town at %1", _this ];

_mash = createVehicle ["MASH", _this, [], 0, "NONE"];
_mash setVariable ["TOWN", true]; // mark it to belong to the town
sleep 1;
_mash setDir (random 360);
ADD_HIT_EH(_mash)
ADD_DAM_EH(_mash)

