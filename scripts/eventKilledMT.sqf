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

    Event assigned to Main Task (TV-Tower) and protect it from any kill except: a) unrecognized, b) by man on feet but not in vehicle

*/

private ["_house", "_killer","_restored","_sleep_until","_time","_ruin","_ruin_type","_newhouse","_house_type","_name"];
// 1.check if tower was killed from some vehicle, not by units with explosive
_house = _this select 0;
_killer = _this select 1;
_restored = false;
_name = "not player";
if ( !(isNull _killer) ) then{
    if ( isPlayer _killer ) exitWith  {_name = format["%1", name _killer]};
    if ( !( _killer isKindOf "CaManBase" ) ) exitWith {
        if ( isPlayer (gunner _killer) ) exitWith { _name = format["%1", name  (gunner _killer)]};
        if ( isPlayer (driver _killer)) exitWith {_name = format["%1", name  (driver _killer)]};
        if ( isPlayer (commander _killer)) exitWith {_name = format["%1", name  (commander _killer)]};
    }
};
hint localize format["+++ MTTarget ""killed"": house %1, killer %2(%3), damage %4 m, vUp %5.", typeOf _house, typeOf _killer, _name, damage _house, vectorUp _house];

// Don't accept kill if done not by direct existing player action
if ( ! ( ( isNull  _killer) || ( (_killer isKindOf "CAManBase" ) && (vehicle _killer == _killer) )  )  ) then { // not NULL killer, killer is man and not driver, so some VEHICLE
     hint localize format["+++ MTTarget: killer %1(not man), dist %2 m.", typeOf _killer, round(_killer distance _house)];
    // killed NOT directly by man, but from some kind of vehicle!!
    // 1.1 Don't wait animation end, create new TVTower object
    if (!(_house isKindOf "House")) exitWith {};
    _time        = time;
    _ruin        = objNull;
    _house_type  = typeOf _house;
    _pos         = getPos _house;
    _ruin_type   = format["%1_ruin", _house_type];
    if ( !(_ruin_type isKindOf "Ruins") ) then { _ruin_type = "Ruins"};
    _sleep_until = _time + 60;
    while { (time < _sleep_until) && (isNull _ruin)} do
    {
        _ruin = nearestObject [_pos, _ruin_type];
        sleep 0.05;
    };
    if ( isNull _ruin) exitWith { hint localize format["--- MTTarget: _ruin not found in %1 sec, exit", time - _time ] };
    hint localize format["+++ MTTarget: _ruin found in %1 sec", time - _time];
    _house removeAllEventHandlers "hit";
    _house removeAllEventHandlers "killed";
    deleteVehicle _house;
    deleteVehicle _ruin;
    _newhouse = createVehicle [_house_type, _pos, [], 0, "CAN_COLLIDE"];
    _vUp = vectorUp _newhouse;
    hint localize format["+++ MTTarget: tower %1(%2) vUp %3 restored, XCheckMTHardTarget is assigned to !", _newhouse, typeOf _newhouse, _vUp];
    _newhouse setVectorUp [0,0,1];
    [_newhouse] spawn XCheckMTHardTarget;
    _restored = true;
};
if (_restored) exitWith {}; // continue with the same assignments
hint localize "--- MTTarget: killed finalization -> destroyed by human or unrecognized means -> follow  the path of Xeno";
// 2. Killed by man or by unknown cause, allow continue in natural way
mt_spotted = false;
mt_radio_down = true;
["mt_radio_down",mt_radio_down,if (!isNull _killer) then { name _killer } else {""}] call XSendNetStartScriptClient;
_this spawn x_removevehiextra;
