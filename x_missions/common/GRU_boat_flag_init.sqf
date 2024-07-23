/*
	x_missions\common\GRU_boat_flag_init.sqf
	author: Sygsky
	description:
		Thrown on client only! When player connected...

    _this = FLAG_OBJECT_ITSELF
	returns: nothing
*/

// check if is called on client at "remote_execute" sent from server
if (!X_Client) exitWith { hint localize "--- GRU_boat_flag_init.sqf: called not on client, exit!"};

if ( typeName _this != "OBJECT" ) exitWith { hint localize format["--- GRU_boat_flag_init.sqf: object type expected, _this = %1", _this]; };

// TODO: set correct string except of "STR_GRU_BOAT_REAMMO"
_this addAction [ localize "STR_GRU_BOAT_REAMMO", "x_missions\common\GRU_boat_flag_reammo.sqf", _this ];

hint localize "+++ GRU_boat_flag_init.sqf finished!";
