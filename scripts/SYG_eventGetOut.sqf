/*
	author: Sygsky
	description: none
	returns: nothing

	Triggered when a unit exits the object (only useful when the event handler is assigned to a vehicle).
	It does not trigger upon a change of positions within the same vehicle.

    Global.

    Passed array: [vehicle, role, unit]

    vehicle: Object - Vehicle the event handler is assigned to
    role:    String - Can be either "driver", "gunner", "commander" or "cargo"
    unit:    Object - Unit that exit the vehicle
*/

#include "x_setup.sqf"
#include "x_macros.sqf"

#define EVENT_ID_VAR_NAME "AntiTurnIdx" // name for vehicle variable with event assigned index
#define EVENT_NAME "GetOut" // name for event

#define __DEBUG__
#ifdef __DEBUG__
    player groupChat format["+++ *********** SYG_getOutEvent(%1) ************ +++", _this];

   X_MP = true;
   XPlayersNumber = {0};
   XAddDead = {};
   x_dosmoke = {};
//    hint localize format["+++ SYG_getOutEvent: %1", _this];
#endif

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++ SYG_preventTurnOut
// call: _success = _veh call SYG_preventTurnOut;
SYG_preventTurnOut = {

    if ( !alive _this ) exitWith { false };
    if ( !( (_this isKindOf "Tank") || (_this isKindOf "Car") ) ) exitWith { false };

    _GetOutEventInd = _this getVariable EVENT_ID_VAR_NAME;
    if (! isNil "_GetOutEventInd") exitWith { false };

    _id = _this addEventHandler ["GetOut", {_this spawn SYG_getOutEvent}];
    _this setVariable [EVENT_ID_VAR_NAME, _id];
    true;
};
//---------------------------------------------------------

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++ SYG_getOutEvent
// Event handler to prevent vehicles turn out
SYG_getOutEvent =
{
    _GetOutEventInd = (_this select 0) getVariable EVENT_ID_VAR_NAME;
    if ( isNil "_GetOutEventInd" ) exitWith
    {
        hint localize format["<<< SYG_getOutEvent: no ""%1"" event id found for %2 (%3), exiting, time %4 >>>",
        EVENT_NAME,
        typeOf _veh,
        _this select 1,
        time
        ]; false
    };

    _veh  = _this select 0;
    _veh setVariable [EVENT_ID_VAR_NAME, nil]; // remove event number forever
    _crew = crew _veh; // crew still in vehicle
    hint localize format["+++ ************** SYG_getOutEvent: ""%1"" (id %2) event  hidden, crew %3, time %4 *********** +++",
                         EVENT_ID_VAR_NAME, _GetOutEventInd, {alive _x} count crew _veh, time ];

    if ( (_veh isKindOf "Air") /*|| (_veh isKindOf "Ship")*/) exitWith
    {
        _veh removeEventHandler [EVENT_NAME, _GetOutEventInd]; // prevent event on air vehicles
        hint localize format["--- SYG_getOutEvent: REMOVE EVENT call on invalid vehicle type %1, exit", typeOf _veh];
    };

    // continue here only for land vehicles

    _role = toLower (_this select 1);
    _first_out_man = _this select 2; // firts man got out of vehicle
    hint localize format["+++ SYG_getOutEvent: params %1, %2, %3", typeOf _veh, _role, typeOf _first_out_man];

    _crewtype = typeOf _first_out_man; //"SoldierWB";

    _dmgstr = "";

    if ( !alive _veh ) exitWith // vehicle is dead, nothing to do with it
    {
        _veh removeEventHandler [EVENT_NAME, _GetOutEventInd]; // prevent event on dead vehicles
        #ifdef __DEBUG__
        hint localize format["--- SYG_getOutEvent: REMOVE EVENT vehicle %1 is dead, exit, time %2", typeOf _veh, time];
        #endif
       false
    };

    #ifdef __DEBUG__
    if (damage _veh != 0 ) then {hint localize format["+++ SYG_getOutEvent: %1 has damage %2", typeOf _veh, damage _veh]};
    #endif

    ////////////////////////////////////////////////////////////////////// PROCS start

    _getNextRole = {
        if (_this emptyPositions "driver" > 0) exitWith { "driver"};
        if (_this emptyPositions "gunner" > 0) exitWith { "gunner"};
        if (_this emptyPositions "commander" > 0) exitWith { "commander"};
        if (_this emptyPositions "cargo" > 0) exitWith { "cargo"};
        "" // no more roles
    };

    _assignUnit2Vehicle = {
        _man = _this select 0;
        _veh = _this select 1;
        _newrole = _this select 2;
        _ret = true;

        switch (_newrole ) do
        {
            case "driver":    {
                if (_veh emptyPositions _newrole == 0) exitWith {_ret = false};
                _man assignAsDriver    _veh; _man moveInDriver    _veh;
            };
            case "gunner":    {
                if (_veh emptyPositions _newrole == 0) exitWith {_ret = false};
                _man assignAsGunner    _veh; _man moveInGunner    _veh;
             };
            case "commander": {
                if (_veh emptyPositions _newrole == 0) exitWith {_ret = false};
                _man assignAsCommander    _veh; _man moveInCommander    _veh;
             };
            case "cargo":     {
                if (_veh emptyPositions _newrole == 0) exitWith {_ret = false};
                _man assignAsCargo    _veh; _man moveInCargo    _veh ;
            };
        };
        _ret
    };

    _fillMainRoles = {
        _required_roles = [];
        if (_this emptyPositions "driver" > 0) then { _required_roles set [count _required_roles, "driver"] };
        if (_this emptyPositions "gunner" > 0) then { _required_roles set [count _required_roles, "gunner"] };
        if (_this emptyPositions "commander" > 0) then { _required_roles set [count _required_roles, "commander"] };
        _required_roles
    };

    ///////////////////////////////////////////////////////////////////// PROCS end


#ifdef __DEBUG__
    hint localize format["+++ SYG_getOutEvent: vehicle crew of %1 has %2 alive men, wait for vehicle to be empty", count crew _veh, {alive _x} count crew _veh];
#endif

    // Wait while all AI are jumped out
    for "_i" from 1 to 15 do
    {
        if ( !alive _veh ) exitWith { false };
        if ( {alive _x} count (crew _veh) == 0) exitWith { true };
        sleep 1;
        if (_veh call SYG_vehIsUpsideDown) exitWith {true};
    };


    // check if vehicle is upsidedown
    _udState = _veh call SYG_vehIsUpsideDown;
    if (!_udState) exitWith // Vehicle stands on feet, exit mow
    {
        // try to fit jumped out crew
        _crew = [];
        // find all outer crew member
        {
            if ( (alive _x) && ( vehicle _x == _x) && (_veh distance _x < 20) ) then {_crew = _crew + [_x];};
        } forEach units group _first_out_man;

        if ( count _crew > 0 ) then // fit some to the vehicle
        {
            {
                _newrole = _veh call _getNextRole;

                if ( _newrole == "" || _newrole == "cargo") exitWith { true };
                _x setDamage 0;

                if ([_x, _veh, _newrole] call _assignUnit2Vehicle) then
                {
                    sleep 0.01;
                    #ifdef __DEBUG__
                    hint localize format["+++ SYG_getOutEvent: move %1 in vehicle as %4. Crew size %2 (%3 alive)", _newrole, count crew _veh,{alive _x} count crew _veh, assignedVehicleRole _x];
                    #endif
                    _required_roles = _required_roles - [_newrole];
                };
                sleep 0.1;

            } forEach _crew;
        };
        // not overturned, exit
        _veh setVariable [EVENT_ID_VAR_NAME, _GetOutEventInd]; // restore event handling
        hint localize format["--- SYG_getOutEvent: vehicle not overturned, leave it as is, crew %1", count crew _veh];
        true
    };

    if ( vehicle _first_out_man == _veh ) exitWith
    {
        _veh setDamage 0;
        _veh setVariable [EVENT_ID_VAR_NAME, _GetOutEventInd]; // restore event handling
        hint localize format["--- SYG_getOutEvent: jumped out man already moved inside %1, repair vehicle damage and exit", typeOf _veh];
        true
    };

    if ( !alive _veh ) exitWith
    {
        #ifdef __DEBUG__
        hint localize format["--- SYG_getOutEvent: %1 vehicle is down, exit", typeof _veh];
        #endif
        //  _veh removeEventHandler [EVENT_NAME, _GetOutEventInd]; // remove event at all
        false
    }; // vehicle is dead, nothing to do with him


    if ( count (crew _veh) > 0 ) then
    {
        {
            if (!alive _x) then
            {
                _x setPos [(getPos _x select 0) + 3 + (random 3),(getPos _x select 1) + 3 + (random 3), 0];
                hint localize format["+++ SYG_getOutEvent: ejecting detected dead (role %1) from vehicle", assignedVehicleRole _x];
            }
            else
            {
                hint localize format["+++ SYG_getOutEvent: ejecting next crew (role %1) from vehicle", assignedVehicleRole _x];
            };
            unassignVehicle _x;
            sleep 0.01;
        } forEach crew _veh;
        sleep 0.2;
    };
    #ifdef __DEBUG__
    hint localize format["+++ SYG_getOutEvent: vehicle is emptied, crew count %1", count crew _veh];
    #endif

    // set it upside
    sleep 0.1;
    _veh setDamage 0; // remove any vehicle damage
    _pos = position _veh;

    _random_point = [_pos, 30] call XfGetRanPointCircle; // try Xeno method
    if ( count _random_point == 0 ) then // not found, use Arma simplest method
    {
        _nil = "Logic" createVehicleLocal _pos;
        sleep 0.01;
        _random_point = getPos _nil;
        deleteVehicle _nil;
        #ifdef __DEBUG__
        hint localize format["+++ SYG_getOutEvent: XfGetRanPointCircle doesn't work at (%1, 30), std Arma method found point %2", _pos, _random_point];
        #endif
    };
    _veh setPos _random_point;

    #ifdef __DEBUG__
    hint localize format["=== SYG_getOutEvent: Upsidedown vehicle %1 with %2 crew (alive %4) turned back, dist from orig pos %3 m.",
    typeOf _veh, count crew _veh, round (_random_point distance _pos), {alive _x} count crew _veh];
    #endif
    sleep 0.01;

    // prepare available empty roles array
    _required_roles = _veh call _fillMainRoles;

    // vehicle now must be empty, try to populate it again with nearest group members

    #ifdef __DEBUG__
    hint localize format["+++ SYG_getOutEvent: try to move first out man into vehicle (as %1), empty roles are %2", _role, _required_roles];
    #endif

    if ( _role != "cargo") then
    {
        _ret = [_first_out_man, _veh, _role] call _assignUnit2Vehicle; // assign first crew man to vehicle
        sleep 0.01;
        if ( _ret ) then
        {
            _crew = _crew - [_first_out_man];
            _required_roles = _required_roles - [_role];
            #ifdef __DEBUG__
            hint localize format["+++ SYG_getOutEvent: first man (%1) fit as %2", _role, assignedVehicleRole _first_out_man];
            #endif
        }
        else
        {
            #ifdef __DEBUG__
            hint localize format["--- SYG_getOutEvent: first man (%1) fit failure", _role];
            #endif
        };
        _dmgstr = format["%3%1%2", if ( _dmgstr != "") then {","} else {""} ,round ((damage _first_out_man) *10)/10, _dmgstr];
        _first_out_man setDamage 0;
    };

    _crew = [];

    // accumulate all nearest pedestrians of the group
    {
        if ( (alive _x) && (canStand _x) && ( vehicle _x == _x) && (_veh distance _x < 50) && !(_x in _crew) ) then {_crew = _crew + [_x];};
    } forEach units group _first_out_man;

    #ifdef __DEBUG__
    hint localize format["+++ SYG_getOutEvent: %1 men in group, %2 men near vehicle, %3 men in vehicle, empty main roles %4",
                         count units group _first_out_man, count _crew, count crew _veh, _required_roles
                         ];
    _cnt = count _crew;
    #endif

    _newrole = "";
    {
        _newrole = _veh call _getNextRole;

        if ( _newrole == "") exitWith { true };
        _dmgstr = format["%3%1%2", if ( _dmgstr != "") then {","} else {""} ,round ((damage _x) *10)/10, _dmgstr];
        _x setDamage 0;


        if ([_x, _veh, _newrole] call _assignUnit2Vehicle) then
        {
            sleep 0.01;
            #ifdef __DEBUG__
            hint localize format["+++ SYG_getOutEvent: move %1 in vehicle as %4. Crew size %2 (%3 alive)", _newrole, count crew _veh,{alive _x} count crew _veh, assignedVehicleRole _x];
            #endif
            _required_roles = _required_roles - [_newrole];
        }
        else
        {
             #ifdef __DEBUG__
             hint localize format["--- SYG_getOutEvent: %1 fit failure", _newrole];
             #endif
        };
        sleep 0.1;

    } forEach _crew;

    #ifdef __DEBUG__
    hint localize format["+++ SYG_getOutEvent: vehicle %1 populated with %2 of crew (alive %6, orig dmg %5), outer crew size now %3, vacant roles %4", typeOf _veh, count crew _veh, (count _crew) - (count crew _veh), _required_roles, _dmgstr, {alive _x} count crew _veh];
    #endif

    {
        _newrole = _veh call _getNextRole;
        if ( newrole == "") exitWith{};


        _x = group _first_out_man createUnit [_crewtype, position _veh, [], 0, "NONE"];
		_unit addEventHandler ["killed", {[_this select 0] call XAddDead;if (d_smoke) then {[_this select 0, _this select 1] spawn x_dosmoke}}];
        _x setSkill 1.0;
        if ([_x, _veh, _newrole] call _assignUnit2Vehicle ) then
        {
            #ifdef __DEBUG__
            hint localize format["+++ SYG_getOutEvent: New crewman created and added as %1 to the vehicle",  _newrole];
            #endif
            sleep 0.01;
        }
        else
        {

        };
    } forEach _required_roles;

    _veh setVariable [EVENT_ID_VAR_NAME, _GetOutEventInd]; // restore event handling
    _rem_roles = _veh call _fillMainRoles;
    if (_veh emptyPositions "cargo" > 0) then { _rem_roles set [count _rem_roles, format["cargo(%1)",_veh  emptyPositions "cargo"]]; };

    hint localize format["<<< SYG_getOutEvent: end of script, empty roles %1, crew %2, time %3", _rem_roles, count crew _veh, time];
    true
};