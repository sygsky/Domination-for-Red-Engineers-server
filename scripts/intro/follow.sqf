/*
    NOTE: not used any more!

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

/*
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
aborigen disableAI "MOVE";
doStop aborigen;
*/

if ( alive _aborigen ) then {  // "I can't follow you anymore"
    _msg = "STR_ABORIGEN_INFO_NUM" call SYG_getRandomText;
    player groupChat (localize _msg);
};
