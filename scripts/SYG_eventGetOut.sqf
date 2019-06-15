/*
    scripts/SYG_eventGetOut.sqf, 17-JAN-2019

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

#ifndef __RED_ENGINEERS_SERVER__

X_MP = true;
XPlayersNumber = {0};
XAddDead = {};
x_dosmoke = {};

#define __DEBUG_PRINT__

#endif



SYG_FalseGetOutsCnt = 0; // number of false "GetOut" events (vehicle is not overturned)
SYG_TrueGetOutsCnt = 0; // number of false "GetOut" events (vehicle is not overturned)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++ SYG_preventTurnOut
// call: _success = _veh call SYG_preventTurnOut;
SYG_preventTurnOut = {

    if ( !alive _this ) exitWith { false };
    if ( !( (_this isKindOf "Tank") || (_this isKindOf "Car") ) ) exitWith { false };

    _getOutEventInd = _this getVariable EVENT_ID_VAR_NAME;
    if (! isNil "_getOutEventInd") exitWith { false };

    _id = _this addEventHandler ["GetOut", {_this spawn SYG_getOutEvent}];
    _this setVariable [EVENT_ID_VAR_NAME, _id];
    true;
};
//---------------------------------------------------------

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++ SYG_getOutEvent
// Event handler to prevent vehicles turn out
SYG_getOutEvent =
{
    private ["_getOutEventInd"];

    _getOutEventInd = (_this select 0) getVariable EVENT_ID_VAR_NAME;
    if ( isNil "_getOutEventInd" ) exitWith
    {
        #ifdef __DEBUG_PRINT__
        hint localize format["<<< SYG_getOutEvent: no ""%1"" event id found for %2 (on %3 got out), exiting >>>",
        EVENT_NAME,
        _this select 0,
        _this select 1
        ];
        #endif
        SYG_FalseGetOutsCnt = SYG_FalseGetOutsCnt + 1;
        false
    };
    // only enemy is allowed for auto revert back
    if ( str(side (_this select 2)) != d_enemy_side ) exitwith {false};

    _start_time = time; // remember start time of the event processing

    _veh  = _this select 0;
    _veh setVariable [EVENT_ID_VAR_NAME, nil]; // remove event number to prevent other processing

    _start_dmg  = damage _veh; // remember inital damage

    _crew = crew _veh; // crew still in vehicle
    _first_man_out = _this select 2;

    if ( (_veh isKindOf "Air") /*|| (_veh isKindOf "Ship")*/) exitWith
    {
        _veh removeEventHandler [EVENT_NAME, _getOutEventInd]; // prevent event on air vehicles
        hint localize format["--- SYG_getOutEvent: REMOVE GetOut EVENT on invalid vehicle %1, exit", _veh];
        SYG_FalseGetOutsCnt = SYG_FalseGetOutsCnt + 1;
        false
    };

    // continue here only for land vehicles

    _whole_crew = [_first_man_out] + _crew; // whole crew including dead (if any)\
    _tlist = _veh call SYG_turretsList;
    _grp_count = count units group _first_man_out; // whole group count

    #ifdef __DEBUG_PRINT__
    hint localize "[[[                                                       ]]]";
    #endif

    _role = toLower (_this select 1);
    _first_man_out = _this select 2; // first man got out of vehicle

    _crewtype = typeOf _first_man_out; //"SoldierWB";

    _dmgstr = "";

    if ( !alive _veh ) exitWith // vehicle is dead, nothing to do with it
    {
        _veh removeEventHandler [EVENT_NAME, _getOutEventInd]; // prevent event on dead vehicles
        hint localize format["--- SYG_getOutEvent: REMOVE EVENT vehicle %1(%2) is dead, exit", typeOf _veh, _veh];
        SYG_FalseGetOutsCnt = SYG_FalseGetOutsCnt + 1;
        false
    };

    #ifdef __DEBUG_PRINT__
    if (damage _veh != 0 ) then {hint localize format["+++ SYG_getOutEvent: %1(%2) has damage %3", typeof _veh, _veh, damage _veh]};
    #endif

    ////////////////////////////////////////////////////////////////////// PROCS start

    //----------------------------------------
    _getNextRole = {
        if (_this emptyPositions "driver" > 0) exitWith { "driver"};
        if (_this emptyPositions "gunner" > 0) exitWith { "gunner"};
        if (_this emptyPositions "commander" > 0) exitWith { "commander"};
        if (_this emptyPositions "cargo" > 0) exitWith { "cargo"};
        "" // no more roles
    };

    //----------------------------------------
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

    //----------------------------------------
    _getVehicleMainRoles = {
        _required_roles = [];
        if ( _this emptyPositions "driver" > 0)    then { _required_roles set [ count _required_roles,    "driver" ] };
        if ( _this emptyPositions "gunner" > 0)    then { _required_roles set [ count _required_roles,    "gunner" ] };
        if ( _this emptyPositions "commander" > 0) then { _required_roles set [ count _required_roles, "commander" ] };
        _required_roles
    };

    ///////////////////////////////////////////////////////////////////// PROCS end

#ifdef __DEBUG_PRINT__
    hint localize format["+++ SYG_getOutEvent: vehicle crew of %1 has %2 alive men, wait for vehicle to be empty", count crew _veh, {alive _x} count crew _veh];
#endif

    // Wait while all AI are jumped out
    for "_i" from 1 to 15 do
    {
        if ( !alive _veh ) exitWith { false };
        if ( { alive _x } count ( crew _veh ) == 0) exitWith
        {
            #ifdef __DEBUG_PRINT__
            hint localize format["+++ SYG_getOutEvent: vehicle empty by itself"];
            #endif
            true
        };
        sleep 1;
        if (!(_veh call SYG_vehIsUpsideDown)) exitWith {true};
    };


    if ( !alive _veh ) exitWith
    {
        hint localize format["<<< SYG_getOutEvent:  veh ""%1""(%2) is dead in %3, exit >>>", typeOf _veh, _veh, (round((time - _start_time) *10))/10];
        SYG_FalseGetOutsCnt = SYG_FalseGetOutsCnt + 1;
        _veh removeEventHandler [EVENT_NAME, _getOutEventInd]; // remove event at all
        false
    }; // vehicle is dead, nothing to do with him

    //
    /////////////////////// check if vehicle is upsidedown
    //
    _udState = _veh call SYG_vehIsUpsideDown;

    //
    // Cheсk if first man retuned to nor,mally staying vehicle by himself
    //
    if ( !_udState && vehicle _first_man_out == _veh ) exitWith
    {
        hint localize format["<<< SYG_getOutEvent: got out man moved in %1(%2), repair dmg (%3) and exit >>>", typeOf _veh, _veh, damage _veh];
        _veh setDamage 0;
        _veh setVariable [EVENT_ID_VAR_NAME, _getOutEventInd]; // restore event handling
        true
    };


    if (!_udState) exitWith // Vehicle stands on wheels, exit mow
    {
        // not overturned, exit
        _veh setVariable [EVENT_ID_VAR_NAME, _getOutEventInd]; // restore event handling

        SYG_FalseGetOutsCnt = SYG_FalseGetOutsCnt + 1;
    #ifdef __DEBUG_PRINT__
        hint localize format["<<< SYG_getOutEvent: veh %1(%2) not overturned (%3), dmg %4, role %5, crew %6 -> %7, evnts %8/%9, %10 >>>",
                            typeOf _veh, _veh, round(_veh call SYG_vehUpAngle), _start_dmg, _role, _whole_crew, count crew _veh,
                            SYG_TrueGetOutsCnt, SYG_FalseGetOutsCnt,
                            [_veh, "at %1 m. to %2 from %3",50] call SYG_MsgOnPosA ];
    #endif
        true
    };

    if ( count (crew _veh) > 0 ) then
    {
        {
            if (!alive _x) then
            {
                _x setPos [(getPos _x select 0) + 3 + (random 3),(getPos _x select 1) + 3 + (random 3), 0];
            #ifdef __DEBUG_PRINT__
                hint localize format["+++ SYG_getOutEvent: ejecting detected dead (role %1) from %2", assignedVehicleRole _x, typeOf _veh];
            #endif
            }
            else
            {
            #ifdef __DEBUG_PRINT__
                hint localize format["+++ SYG_getOutEvent: ejecting next crew (role %1) from %2", assignedVehicleRole _x, typeOf _veh];
            #endif
            };
            unassignVehicle _x;
            _x action ["GetOut", _veh ];
            sleep 0.01;
        } forEach crew _veh;
        sleep 0.2;
    };
    #ifdef __DEBUG_PRINT__
    hint localize format["+++ SYG_getOutEvent: vehicle is emptied, crew in it count %1", {vehicle _x == _veh} count crew _veh];
    #endif

    // set it upside
    sleep 0.1;
    _veh setDamage 0; // remove any vehicle damage
    _pos = position _veh;

    _veh setVectorUp [0,0,1];

/*
    _cnt = 5; // 5 attempts to overturn the machine
    for "_cnt" from 1 to 5 do
    {
        _random_point = [_pos, 30] call XfGetRanPointCircle; // try Xeno method
        if ( count _random_point == 0 ) then // not found, use Arma simplest method
        {
            _nil = "Logic" createVehicleLocal _pos;
            sleep 0.01;
            _random_point = getPos _nil;
            deleteVehicle _nil;
            #ifdef __DEBUG_PRINT__
            hint localize format["+++ SYG_getOutEvent: XfGetRanPointCircle doesn't work at (%1, 30), std Arma method found point %2", _pos, _random_point];
            #endif
        };
        _veh setPos _random_point;
        sleep 2;
        if ( !(_veh call SYG_vehIsUpsideDown) ) exitWith {true};
        sleep 1;
    };
    #ifdef __DEBUG_PRINT__
    hint localize format["=== SYG_getOutEvent: Upsidedown vehicle %1 with %2 crew (alive %4) turned back, dist from orig pos %3 m.",
    typeOf _veh, {vehicle _x == _veh} count crew _veh, round (_random_point distance _pos), {alive _x && vehicle _x == _veh} count crew _veh];
    #endif
*/
    sleep 1;

    // prepare available empty roles array
    _required_roles = _veh call _getVehicleMainRoles;

    // vehicle now must be empty, try to populate it again with nearest group members

    #ifdef __DEBUG_PRINT__
    hint localize format["+++ SYG_getOutEvent: try to move first out man into vehicle (as %1), empty roles are %2", _role, _required_roles];
    #endif

    if ( _role != "cargo") then
    {
        _ret = [_first_man_out, _veh, _role] call _assignUnit2Vehicle; // assign first crew man to vehicle
        sleep 0.01;
        if ( _ret ) then
        {
            _crew = _crew - [_first_man_out];
            _required_roles = _required_roles - [_role];
            #ifdef __DEBUG_PRINT__
            hint localize format["+++ SYG_getOutEvent: first man (%1) fit (%2) as %3", _role, vehicle _first_man_out == _veh,assignedVehicleRole _first_man_out];
            #endif
        }
        else
        {
            #ifdef __DEBUG_PRINT__
            hint localize format["--- SYG_getOutEvent: first man (%1) fit failure", _role];
            #endif
        };
        _dmgstr = format["%3%1%2", if ( _dmgstr != "") then {","} else {""} ,round ((damage _first_man_out) *10)/10, _dmgstr];
        _first_man_out setDamage 0;
    };

    _crew = [];

    // accumulate all nearest pedestrians belonging to the same group
    {
        if ( (alive _x) && ( vehicle _x == _x) && (_veh distance _x < 100) && !(_x in _crew) ) then {_crew = _crew + [_x];};
    } forEach units group _first_man_out;

    #ifdef __DEBUG_PRINT__
    hint localize format["+++ SYG_getOutEvent: %1 men in group, %2 men near vehicle (ready to put), %3 men in vehicle, vacant std roles %4",
                         count units group _first_man_out, count _crew, count crew _veh, _required_roles
                         ];
    _cnt = count _crew;
    #endif

    //
    // Move found men to vehicle for std roles
    //
    _newrole = "";
    {
        _newrole = _veh call _getNextRole;

        if ( _newrole == "") exitWith { true };
        _dmgstr = format["%3%1%2", if ( _dmgstr != "") then {","} else {""} ,round ((damage _x) *10)/10, _dmgstr];
        _x setDamage 0;

        if ([_x, _veh, _newrole] call _assignUnit2Vehicle) then
        {
            sleep 0.01;
            #ifdef __DEBUG_PRINT__
            hint localize format["+++ SYG_getOutEvent: move %1 in vehicle as %4. Crew size %2 (%3 alive)", _newrole, count crew _veh,{alive _x} count crew _veh, assignedVehicleRole _x];
            #endif
            _required_roles = _required_roles - [_newrole];
        }
        else
        {
             #ifdef __DEBUG_PRINT__
             hint localize format["--- SYG_getOutEvent: %1 fit failure", _newrole];
             #endif
        };
        sleep 0.1;

    } forEach _crew;

    #ifdef __DEBUG_PRINT__
    hint localize format["+++ SYG_getOutEvent: vehicle %1 populated with %2 of crew (alive %6, orig dmg %5), outer crew size now %3, vacant roles %4", typeOf _veh, count crew _veh, (count _crew) - (count crew _veh), _required_roles, _dmgstr, {alive _x} count crew _veh];
    #endif

    //
    // Find more places
    //
    #ifdef __DEBUG_PRINT__
    hint localize format["+++ SYG_getOutEvent: check men near vehicle to find place for"];
    #endif
    {
        if ((alive _x) && (vehicle _x == _x) ) then
        {
            // if tank we can try to fit it to RCWS M2
//            if ( _veh isKindOf "M1Abrams") then
//            {
                if (count _tlist > 0) then
                {
                    _last_ind = count _tlist - 1;
                    _x setDamage 0;
                    _x moveInTurret [_veh, _tlist select _last_ind];
                    #ifdef __DEBUG_PRINT__
                    hint localize format["+++ SYG_getOutEvent: adding next crewman with extra role %1 to vehicle (is Tank -> %2) of roles %3",
                        _tlist select _last_ind,
                        _veh isKindOf "M1Abrams",
                        _tlist
                        ];
                    #endif
                    _tlist resize _last_ind;
                    sleep 0.1;
                    #ifdef __DEBUG_PRINT__
                    hint localize format["+++ SYG_getOutEvent: put (next) crewman with assignedVehicleRole %1",  assignedVehicleRole _x];
                    #endif
                };
//            };
        }
        else
        {
            if ( !alive _x ) then
            {
                #ifdef __DEBUG_PRINT__
                hint localize format["--- SYG_getOutEvent: one of the crew in vehicle found dead"];
                #endif
            }
            else
            {
                #ifdef __DEBUG_PRINT__
                hint localize format["--- SYG_getOutEvent: skip one of the crew (%1)", assignedVehicleRole _x];
                #endif
            };
        };
    } forEach _crew;

    //
    // Well all turrets are filled, may be it is time to fill cargo space if there are some candidates outside?
    //
    if (_veh emptyPositions "cargo" > 0) then
    {
        {
            if ((alive _x) && (vehicle _x == _x) ) then
            {
                if (_veh emptyPositions "cargo" > 0) then
                {
                    _x setDamage 0;
                    _ret = [_x, _veh, "cargo"] call _assignUnit2Vehicle; // assign next free group man to the vehicle cargo if any
                };
            };
        } forEach _crew;
    };

    _veh setVariable [EVENT_ID_VAR_NAME, _getOutEventInd]; // restore event handling
    _rem_roles = _veh call _getVehicleMainRoles;
    if (_veh emptyPositions "cargo" > 0) then { _rem_roles set [count _rem_roles, format["cargo(%1)",_veh  emptyPositions "cargo"]]; };
    _tlist = [];
    {
        _tlist set [count _tlist, assignedVehicleRole _x];
    } forEach crew _veh;
    SYG_TrueGetOutsCnt = SYG_TrueGetOutsCnt + 1;

    hint localize format["[[[ SYG_getOutEvent: turned back %1(%2) in %3, ini dmg %4, roles %5, crew %6/alive %7, calls %8/%9, %10 ]]]",
        typeOf _veh,
        _veh,
        (round((time - _start_time) *10))/10,
        _start_dmg,
        _tlist,
        count crew _veh,
        {alive _x} count crew _veh,
        SYG_TrueGetOutsCnt,
        SYG_FalseGetOutsCnt,
        [_veh,"at %1 m. to %2 from %3", 50] call SYG_MsgOnPosA
        ];
    true
};