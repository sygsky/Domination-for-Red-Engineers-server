/*
	x_missions\common\sideradar\truck_killed.sqf
	author: Sygsky
	description: truck "killed" event procedure
	returns: nothing
*/

_msg = (_this select 1) call SYG_getKillerInfo;
_veh = _this select 0;
hint localize format["+++  radio_service: Radar truck (%1) killed by %2",typeOf _veh, _msg];
if (alive d_radar)  then  { // unload mast if truck is killed
	_asl = getPosASL d_radar;
	if ((_asl select 2) < 0) then {
		_pos = _veh modelToWorld [0, -DIST_MAST_TO_INSTALL, 0];
		d_radar setPos _pos;
		["say_sound", _veh, call SYG_rustyMastSound] call XSendNetStartScriptClientAll;
	};
};

// remove truck after 10 minutes of players absence around 100 meters of truck.
_cnt = 0;
while {!(isNull _veh)} do {
	sleep (60 + (random 60));  // wait next period for player absence
	_pos = getPos _veh;
	hint localize format["+++ radio_service: truck killed at %1",  [_pos, 10] call SYG_MsgOnPosE0 ];
	_player =  [_pos, 100] call SYG_findNearestPlayer; // find any alive player in/out vehicles
	if ( (!(alive _player)) || (_cnt > 5)) exitWith { // 5 times with 90 seconds (on average) check if no players nearby
		["say_sound", _pos, "steal"] call XSendNetStartScriptClient;
		deleteVehicle _veh;
	};
	_cnt = _cnt + 1;
};
