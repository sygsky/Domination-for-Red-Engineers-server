/*
    scripts\eventKilledMT.sqf
	author: Sygsky
	description: none
	returns: nothing

    2.13 Killed
    Triggered when the unit is killed. Local.
    Passed array: [unit, killer]
    unit: Object - Object the event handler is assigned to
    killer: Object - Object that killed the unit
    Contains the unit itself in case of collisions.

    Event assigned to Main Task (TV-Tower) and protect it from any kill except: a) unrecognized, b) by man on feet, not in vehicle

*/
//
// _dead_heli_is_near = _killer call _air_veh_near;
//
_air_veh_near = {
	private ["_veh"];
	_veh = nearestObject [_this, "Air"];
	if ( isNull _veh ) exitWith { objNull };
	if ( _veh isKindOf "ParachuteBase" ) exitWith { objNull };
	_veh
};

private [ "_house", "_killer","_restored","_sleep_until","_time","_ruin","_ruin_type","_newhouse","_house_type","_name"
			,"_veh","_alive","_correct_kill","_kamikadze","_time_delta" ];
// 1.check if tower was killed from some vehicle, not by units with explosive
_house = _this select 0;
_killer = _this select 1;
_restored = false;
_name = _killer;
if ( !( isNull _killer ) ) then {
    if ( isPlayer _killer ) exitWith  {
		// Killer is player, but he is in vehicle, not on feet?
		_alive = if(alive _killer) then {"alive "} else {"dead "};
		if ( vehicle _killer != _killer ) exitWith { // killer (player) is in vehicle
			_name = format[ "%1%2(%3)", _alive, name _killer, typeOf ( vehicle _killer )];
			if (!alive (vehicle _killer)) then { _name = format["%1<KAMIKADZE>", _name]; }; // killer is in dead vehicle!
		};
		_veh = _killer call _air_veh_near;
		if (isNull _veh) then {
	    	_name = name _killer;
		} else {
			_name = format[ "%1%2(%3)<KAMIKADZE>", _alive, name _killer, typeOf ( vehicle _killer )];
		};
    };
    if ( !( _killer isKindOf "CaManBase" ) )  exitWith { // killer is some vehicle
        if ( isPlayer ( gunner _killer ) )    exitWith { _name = format["%1(%2)", name  (gunner _killer), typeOf __killer] };
        if ( isPlayer ( driver _killer ) )    exitWith { _name = format["%1(%2)", name  (driver _killer), typeOf __killer] };
        if ( isPlayer ( commander _killer ) ) exitWith { _name = format["%1(%2)", name  (commander _killer), typeOf __killer] };
    };
} else { _name = "<null>"; };

// PRINT INFO LINE TO THE *.RPT
hint localize format[ "+++ MTTarget ""killed"": house %1, killer %2, dist %3, damage %4, vUp %5", _house, _name, round(_killer distance _house), damage _house, vectorUp _house ];

// Don't accept kill if done not by direct existing player action
_kamikadze = nil;
if ( !( isNull  _killer ) ) then { // not NULL killer
	_correct_kill = false;
	if  ( _killer isKindOf "CAManBase" ) then {  // if killer is a man, check for his vehicle too
		if (vehicle _killer == _killer) exitWith {
			if (alive _killer) exitWIth { _correct_kill = true; }; // killer is alive on feet, so tower is killed correctly
			// killer not alive. It also can be, but check if some friendly air vehicle is near. If so, restore tower.
			_kamikadze = _killer getVariable "KAMIKADZE";
			if (!isNil "_kamikadze") exitWith {
				_killer setVariable ["KAMIKADZE", nil]; // remove variable
				_time_delta = time - _kamikadze;
				if (_time_delta < 5) exitWith {
					hint localize format["--- Kamikadze detected, tower will be restored, time delta %1!!!", _time_delta];
				};
				hint localize format["--- Kamikadze detected, but time delta too high: %1", _time_delta];
			};
			_veh = _killer call _air_veh_near;
			if ( alive _veh ) exitWith { _correct_kill = true; };
			if ( ( _veh distance _killer ) > 20) exitWith { _correct_kill = true; };
		};
		_correct_kill = alive _killer; // if killer is alive and is in vehicle - tower is killed correctly
	};
	if (_correct_kill ) exitWith{}; // not restore target
     hint localize format["*** MTTarget: resurrect tower, killer %1, veh %2, dist %3 m.", typeOf _killer, typeOf (vehicle _killer), round(_killer distance _house)];
    // killed NOT directly by man, but from some kind of vehicle etc!!!
    // 1.1 Don't wait animation end, create new TVTower object
    if (!(_house isKindOf "House")) exitWith {};
    _time        = time;
    _ruin        = objNull;
    _house_type  = typeOf _house;
    _pos         = getPos _house;
    _ruin_type   = format["%1_ruin", _house_type];
    if ( !(_ruin_type isKindOf "Ruins") ) then { _ruin_type = "Ruins"};
    _sleep_until = _time + 5;
    while { (time < _sleep_until) && (isNull _ruin)} do {
        _ruin = nearestObject [_pos, _ruin_type];
        sleep 0.05;
    };
    if ( isNull _ruin) exitWith { hint localize format["--- MTTarget: _ruin not found in %1 sec, exit", round(time - _time) ] };
    hint localize format["+++ MTTarget: _ruin found in %1 sec", time - _time ];
    _house removeAllEventHandlers "hit";
    _house removeAllEventHandlers "dammaged";
    _house removeAllEventHandlers "killed";
    deleteVehicle _house;
    deleteVehicle _ruin;
	["d_del_ruin",position _ruin] call XSendNetStartScriptAll;
	deleteVehicle _ruin;

    _newhouse = createVehicle [_house_type, _pos, [], 0, "CAN_COLLIDE"];
    _vUp = vectorUp _newhouse;
    _newhouse setVectorUp [0,0,1];

    // Send msg to anybody in radious of ### meters: "The %1 hit on the TV tower has gone to waste!". And play special gong sound
    if ( _killer isKindOf "CAManBase") then { _name = name _killer } else { _name = _killer };
	_str = ("STR_TV_NUM" call SYG_getRandomText); // "Damn tower, it fell!..."
	if (!isNil "_kamikadze") then {
		[ "change_score", name _killer, -(d_ranked_a select 11), [ "msg_to_user", name _killer,  [ [_str],["STR_TV_VEH", 20] ], 7, 2, false ] ] call XSendNetStartScriptClientAll;
	} else {
		[ "msg_to_user", _name,  [ [_str] ], 0, 0, false, "gong_15" ] call XSendNetStartScriptClient;
	};

    hint localize format[ "+++ MTTarget: tower %1(%2) vUp %3 restored, XCheckMTHardTarget is assigned to !", _newhouse, typeOf _newhouse, _vUp ];
    // ["msg_to_user",_player_name | "*" | "",[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay<,no_title_msg><,sound_name>>>>]
    [_newhouse] spawn XCheckMTHardTarget;
    _restored = true;
};
if (_restored) exitWith {}; // continue with the same assignments
hint localize "+++ MTTarget: killed finalization -> destroyed by human or unrecognized means -> follow  the path of Xeno";
// 2. Killed by man or by unknown cause, allow continue in natural way
mt_spotted = false;
mt_radio_down = true;
["mt_radio_down",mt_radio_down,if (!isNull _killer) then { name _killer } else {""}] call XSendNetStartScriptClient;
_this spawn x_removevehiextra;
