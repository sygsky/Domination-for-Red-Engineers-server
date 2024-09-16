/*
	scripts\intro\follow.sqf
	author: Sygsky
	description: allow aborigen to follow player not very long time
		call: _player execVM "scripts\intro\follow.sqf";
	returns: nothing
*/

_player = _this;
if (!alive _player) exitWith {hint localize format["--- follow.sqf: designated player '%1' is dead, exit...", _player]};
if (!local aborigen) exitWith {hint localize format["--- follow.sqf: aborigen is not local, exit...", _player]};
if (!alive aborigen) exitWith {hint localize "--- follow.sqf: aborigen is dead, exit..."};
hint localize format["+++ follow.sqf: aborigen (grp %1) follow player %2 ", group aborigen, _player];

//aborigen doFollow _player;

//#define __OLD__

#ifdef __OLD __

_pos = getPos aborigen;	// Initial position, abo can move no further than 40 meters away from it.
_time = time + 40; // follow only 40 seconds then stop again
while {(alive aborigen) && (alive _player) && (time < _time) && (((getPos _player) distance (getPos aborigen)) < 40)} do {sleep 3};

#else

aborigen setSpeedMode "LIMITED";
aborigen enableAI "MOVE";
_pos = getPos aborigen;	// Initial position, abo can move no further than 40 meters away from it.
_time = time + 40; // follow only 40 seconds then stop again
while {	(alive aborigen) && (alive _player) && (time < _time) && ((_pos distance (getPos _player)) < 50)  && ([aborigen, [[17352,17931,100], 100, 100, 0]] call SYG_pointInRect)} do {
	_pos = getPos aborigen;
	if ( (_pos distance (getPos _player)) > 2 ) then {
		aborigen doMove _pos;
		sleep 3;
	};
};
if ( alive _aborigen ) then { player groupChat (localize "STR_ABORIGEN_INFO_OUT") }; // "I can't follow you anymore"
aborigen disableAI "MOVE";
doStop aborigen;
#endif

if ( (alive aborigen) && (alive _player) ) then {
	//                       "That's all. I'm  tired to follow you, %1..." || "That's it. I'm not going any further, got tired, %1..."
	if (time < _time) then { _msg =  "STR_ABORIGEN_GO_TIMEOUT" } else { _msg =  "STR_ABORIGEN_GO_DISTOUT" };
	["msg_to_user", "", [ [ _msg, name _player ] ], 0, 1, false, "losing_patience"] call XSendNetStartScriptClient;
};

// aborigen doFollow aborigen;