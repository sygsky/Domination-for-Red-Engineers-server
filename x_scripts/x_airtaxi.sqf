// by Xeno, x_scripts/x_airtaxi.sqf
if (!XClient) exitWith {};
#include "x_setup.sqf"

if (!d_heli_taxi_available) exitWith {
	localize "STR_SYS_1178" call XfHQChat; // "An air taxi is allready on the way to your position!"
};

if (FLAG_BASE distance player < 1000) exitWith {
	localize "STR_SYS_1179" call XfHQChat; // "You are less than 1000 m away from the base, no air taxi for you!"
};

#ifdef __RANKED__
if (score player < (d_ranked_a select 15)) exitWith {
	(format [localize "STR_SYS_1180", score player,(d_ranked_a select 15)]) call XfHQChat; // "You can't call an air taxi. You need %2 points for that, your score is %1!"
};
player addScore (d_ranked_a select 15) * -1;
#endif

localize "STR_SYS_1181" call XfHQChat; // "Air taxi will start in a few seconds, stand by. Stay at your position!"

d_heli_taxi_available = false;

["d_air_taxi",player] call XSendNetStartScriptServer;

if (true) exitWith {};