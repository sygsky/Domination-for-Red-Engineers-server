// by Xeno
if (!XClient) exitWith {};
#include "x_setup.sqf"

if (!d_heli_taxi_available) exitWith {
	"An air taxi is allready on the way to your position!" call XfHQChat;
};

if (FLAG_BASE distance player < 500) exitWith {
	"You are less than 500 m away from the base, no air taxi for you!" call XfHQChat;
};

#ifdef __RANKED__
if (score player < (d_ranked_a select 15)) exitWith {
	(format ["You can't call an air taxi. You need %2 points for that, your score is %1!", score player,(d_ranked_a select 15)]) call XfHQChat;
};
player addScore (d_ranked_a select 15) * -1;
#endif

"Air taxi will start in a few seconds, stand by. Stay at your position!" call XfHQChat;

d_heli_taxi_available = false;

["d_air_taxi",player] call XSendNetStartScriptServer;

if (true) exitWith {};