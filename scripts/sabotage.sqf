// SYG sabotage, scripts\sabotage.sqf
//
// Sabotage functionality: try to blast factories
// Parameters:
// _this select 0 : group of saboteurs units
// _this select 1 : boolean, if true debug messages will be sent about important events
// _this select 2 : boolean, if true debug messages from bombing unit will be sent about important events
//
// 
// global variable m_PIPEBOMBNAME  redefines pipe-bomb name, e.g. to "ACE_PipeBomb". Default value used is Arma standard "PipeBomb" (name always case-sensitive!!!)

private ["_units", "_unit", "_shell_unit","_grp", "_leader", "_mags", "_no", "_cnt", "_obj", "_obj_pos","_pos", "_continue",
        "_bombScript", "_i", "_objClassType", "_objTypesArr", "_debug", "_debug1","_fire","_time", "_msgPrev","_msg1","_list",
        "_replaceFire","_delUnitsInWater"];

if (!isServer) exitWith {};

//#define __DEBUG__
//#define __DEBUG_FIRE__
//#define __PRINT_FIRE__

#define __PRINT__

#define DELAY_BETWEEN_BOMBS 60

#define FIRE_CHOKE_DELAY 1800
#define FIRE_DISTANCE_TO_LIT 100
#define SEARCH_OTHER_GROUP_DIST 1500
#define OBJ_SEARCH_DISTANCE 1400

_replaceFire = {
	private ["_nextType","_pos"];
	if (!isNull _this ) then {
		_nextType = "";
		if (typeOf _this == "Fire") then {_nextType = "FireLit";}
		else {
			if (typeOf _this == "FireLit") then {_nextType = "Fire";}
		};
		if ( _nextType != "" ) then {
			_pos = getPos _this;
			_pos set [2,0];
			deleteVehicle _this;
			sleep 0.5;
			_this = createVehicle [_nextType, _pos, [], 0, "NONE"];
#ifdef __PRINT_FIRE__
			hint localize format[ "sabotage.sqf. replaceFire: campfire changed to ""%1"" at pos %2", _nextType, _pos ];
#endif			
		};
	};
};

// _grp call _delUnitsInWater;
// (units _grp) call _delUnitsInWater;
_delUnitsInWater = {
    if ( typeName _this  == "GROUP") then {
        _this = units _this;
    };
    if (typeName _this != "ARRAY") exitWith {false;};
    for "_i" from 0 to (count _this) -1 do {
        _x = _this select _i;
        if ( surfaceIsWater position _x ) then {
            _x removeAllEventHandlers "killed";
            deleteVehicle _x;
            sleep 0.2;
        };
    };
};

if ( typeName (_this select 0) == "OBJECT") then {
	_this = _this select 3;
};

_grp = _this select 0;

if (isNull _grp) exitWith {
	if ( _debug ) then { player globalChat "--- sabotage.sqf: Expected saboteur group is <null>, exit";};
#ifdef __PRINT__
	hint localize "--- sabotage.sqf: Expected saboteur group is <null>, exit";
#endif
};

_debug = false;
if ( count _this > 1 ) then {
	_debug = _this select 1;
};

_debug1 = _debug;
if ( count _this > 2 ) then {
	_debug1 = _this select 2;
};

if (isNil "m_PIPEBOMBNAME") then {
	m_PIPEBOMBNAME = "PipeBomb";
	if ( _debug ) then { player globalChat format["PipeBomb name is %1",m_PIPEBOMBNAME]; };
#ifdef __PRINT__
	hint localize format["+++ PipeBomb name is set to %1",m_PIPEBOMBNAME];
#endif	
};

_msgPrev = "";
_continue = true;

_objClassType = ""; // type of current target object

_objTypesArr = [ "WarfareBEastAircraftFactory", "WarfareBWestAircraftFactory"]; // allowed types on base to bomb

#ifdef __DEBUG__
sleep 30; // wait approximately 30 secs before sabotage start
#else
sleep (250 + random 100); // wait approximately 5 minutes before sabotage start
#endif

_grp setBehaviour "AWARE";
_grp setCombatMode "YELLOW";

if ( _debug ) then { player globalChat format["+++ sabotage.sqf: Start, group units count: %1", count units _grp]; };
#ifdef __PRINT__
_cnt = 0;
_cnt1 = 0;
{
    if (m_PIPEBOMBNAME in (magazines _x)) then {_cnt = _cnt + 1;};
    if ( canStand _x) then {_cnt1 = _cnt1 + 1;};
} forEach units _grp;
hint localize format["+++ sabotage.sqf: Start, units in group %1, canStand %2, bombs in inventory %3", count units _grp, _cnt1, _cnt];
#endif	

// do up to the last man
while { (({ (alive _x) && (canStand _x) } count units _grp) > 0) && _continue } do {
    _leader = _grp call SYG_getLeader;
    if ( isNull _leader ) then { sleep 1; _leader = _grp call SYG_getLeader };
    if (isNull _leader) exitWith {
#ifdef __PRINT__
        hint localize format["--- sabotage.sqf: leader is empty, grp units count %1, exit!", {alive _x}count units _grp];
#endif
    };
	
	_no = nearestObjects [_leader, _objTypesArr, OBJ_SEARCH_DISTANCE];
	_obj_pos =  -1; /*(floor random (count _no))*/
	_obj = objNull;
	
	//++++++++++++++++++
	// seek factories  +
	//++++++++++++++++++
	if ( _debug ) then 	{ player globalChat format["+++ sabotage.sqf: WarfareBEastAircraftFactory %1, grp (%2) leader at %3",
	    count _no,
	    {alive _x} count units _grp,
	    [_leader, "%1 m. to %2 from %3", 50] call SYG_MsgOnPosE];
    };
#ifdef __PRINT__
    hint localize format["+++ sabotage.sqf: WarfareBEastAircraftFactory cnt = %1, grp (%2), leader at %3",
    count _no,
    { alive _x } count units _grp,
    [_leader, "%1 m. to %2 from %3", 50] call SYG_MsgOnPosE];
#endif

	//--------------
	// find alive factory
	_i = 0;
	for "_i" from 0 to (count _no) -1 do {
		_x = _no select _i;
		_objClassType = typeOf _x;
		_pos  = position _x;
		if ( (_pos select 2) < -10) then  { // factory is buried (destroyed) remove it from array
		    _no set [_i, "RM_ME"];
		};
	}; // forEach _no;
    _no = _no - ["RM_ME"];

    if ( count _no > 0 ) then { // select random target to blast
        _obj_pos = _no call XfRandomFloorArray;
    };

	 // if some alive factory found
	if ( _obj_pos >= 0 ) then {

	    // TODO: check if enemy detected at the base
        if (!alive _leader) then {
    	    _leader = _grp call SYG_getLeader;
        };
	    _enemy = objNull;
	    if ( alive _leader ) then {
            _enemy = [_leader, floor(d_viewdistance / 2 ) ] call SYG_detectedEnemy;
	    };

        if( !isNull _enemy ) exitWith {
#ifdef __PRINT__
			hint localize format["+++ sabotage.sqf: Enemy %1 (%2) found at dist %3 m., factory sabotage skipped", _enemy,typeOf _enemy, _enemy distance _leader];
#endif
        };

	    _obj = _no select _obj_pos; // define target to bomb
		if ( _debug ) then { player globalChat format["+++ sabotage.sqf: targets cnt: %1, selected %2, type %3, z = %4", count _no, _obj_pos, _objClassType, (position _obj) select 2 ]; };
#ifdef __PRINT__
		hint localize format["+++ sabotage.sqf: units %1, factory cnt %2, attacked ind %3, type %4, z %5 m", {alive _x} count (units _grp), count _no, _obj_pos, _objClassType, round((position _obj) select 2) ];
#endif	
		
		// wait until target destroyed and while group alive and there is any bomberman in it
		while { ( ((position _obj) select 2) > -10.0) && (!(isNull _grp)) && _continue } do {
			if ( ( {(alive _x) && (canStand _x)} count units _grp) == 0) exitWith {
				_continue = false;
				if (_debug ) then {player globalChat "---sabotage.sqf: no units in group, exit!"}; 
#ifdef __PRINT__
				hint localize "---sabotage.sqf: no units in group, exit!";
#endif	
			};
			
			//+++++++++++++++++
			// find bomberman +
			//+++++++++++++++++
			_units = units _grp;
			// if ( _debug ) then
			// {
				// player globalChat format["sabotage.sqf: Group units count: %1", count units _grp];
			// }; // "Sabotage: starting procedure"
			scopeName "bb";
			_shell_unit = objNull;
			{
				if (alive _x)  then {
				    if (canStand _x ) then {
				        if ( m_PIPEBOMBNAME in (magazines _x) ) exitWith { _shell_unit = _x; breakTo "bb"; };
				    };
				};
				sleep 0.011;
			} forEach _units;
			
			if ( !(isNull _shell_unit) )  then {
				//+++++++++++++++++++++++++++++++++++++++++++++++
				//+++ Sygsky: start pipebomb dropping procedure +
				//+++++++++++++++++++++++++++++++++++++++++++++++
				_obj_pos = position _obj;
				sleep  0.5;
				_retreat_pos = position _shell_unit;
				// first eject unit from vehicle if any
				if ( (vehicle _shell_unit) != _shell_unit ) then {
					_shell_unit action ["eject", vehicle _shell_unit];
					sleep 1.0;
					if (_debug ) then { player globalChat "+++ sabotage.sqf: shell unit ejected from vehicle"; };
#ifdef __PRINT__
					hint localize "+++ sabotage.sqf: shell unit ejected from vehicle";
#endif	
				};
				_leader = _grp call XfGetLeader;
				if ( !( isNull _leader ) ) then  { // show good bye animation
					if ( _leader != _shell_unit ) then {
						_shell_unit doWatch _leader;
						_leader doWatch _shell_unit;
						sleep 0.5; // salute 1 second
						_shell_unit action ["salute", _leader]; // salute to commander for order
						_leader action ["salute", _shell_unit]; // salute to shell unit with order
						sleep 1.0; // salute 1 second
						_shell_unit doWatch objNull;
						_leader doWatch objNull;
					};
				} else {
					if (_debug ) then { player globalChat format["+++ sabotage.sqf: No leader in grp, units count is %1", {alive _x} count units _grp]; };
#ifdef __PRINT__
					hint localize format["+++ sabotage.sqf: No leader in grp, units count is %1", {alive _x} count units _grp];
#endif	
				};
				
				// remove bombing unit from his group
				[_shell_unit] join grpNull;
				sleep 0.2;

				// bombing unit, position to bomb, return position (now current), debug on, user bomb name
				if (_debug ) then { player globalChat (format["+++ sabotage.sqf: Run bombing script with  unit %1 for obj at pos %2 on distance %3", name _unit, getPos _obj, round(_obj distance _shell_unit)]); };

				 // last boolean is (true) to put bombs to the center or (false) not 
                _obj_prev_dmg = damage _obj; // current damage of targeted service
#ifdef __DEBUG__
				_bombScript = [_shell_unit, [ _obj ], _retreat_pos, true, m_PIPEBOMBNAME, "", true ] spawn FuncUnitDropPipeBomb;
#else				
				_bombScript = [_shell_unit, [ _obj ], _retreat_pos, _debug1, m_PIPEBOMBNAME, "", true ] spawn FuncUnitDropPipeBomb;
#endif

				_time = time;
//				_timeout = ([_shell_unit, _obj] call SYG_distance2D) + 60;
				_timeout = (round (_shell_unit distance _obj)) + 60;
#ifdef __PRINT__
				hint localize format["+++ sabotage.sqf: Run bombing script for  unit from grp of %1 unit[s], at timeout %2", (_grp call XfGetAliveUnits) + 1, round(_timeout)];
#endif
                _timeout = _time + _timeout;
	
				while {	(time < _timeout) &&  (!(scriptDone _bombScript )) } do { // wait 600 seconds (10 minutes) to complete script
					sleep 1.0;
				};
				
				if ( _debug ) then {
					player globalChat format["+++ sabotage.sqf: Bombing script finished with %1 after %2 second[s]", scriptDone _bombScript, round(time-_time)];
				};
				
#ifdef __PRINT__
				hint localize format["+++ sabotage.sqf: Bombing script finished with %1 after %2 second[s]", scriptDone _bombScript, round(time-_time)];
#endif	

				if ( (!scriptDone _bombScript) && (alive _shell_unit)) then {
					terminate _bombScript;
					sleep 1;
#ifdef __PRINT__
					hint localize format["--- sabotage.sqf: DropScrip terminated after %1 seconds waiting, shell_unit dist %2", round(_timeout - _time), round(_shell_unit distance  _obj)];
#endif	
				};
                if ( damage _obj > _obj_prev_dmg ) then {
                        [ "msg_to_user", "*", [["STR_SYS_SERVICE_DMG_1"]], 0, random 5 ] call  XSendNetStartScriptClient; // "One of the services of the base was damaged by saboteurs!"
#ifdef __PRINT__
					    hint localize "+++ sabotage.sqf: One of the services of the base was damaged by saboteurs!";
#endif
                };
				//==============================================
				//======== unit returning to the duty ==========
				//==============================================
				if ( alive _shell_unit ) then {
					if ( (isNull _grp) || (({ alive _x } count units _grp) == 0)) then { // try to find other active group
					    _origGrp = _grp; // save current group to check where bomberman returned after script end
						if (_debug ) then {player globalChat "+++ sabotage.sqf: bomberman group is dissapeared, try to assign bomberman into near friendly group"};
#ifdef __PRINT__
						hint localize "+++ sabotage.sqf: bomberman group is disappeared, try to assign bomberman into near friendly group";
#endif	
						_grp = [_shell_unit, SEARCH_OTHER_GROUP_DIST] call SYG_findNearestSideGroup; // find nearest friendly group in radious of 1000 meters
						_continue = false;
					};
					if ( (! isNull _grp)  && ( ( {alive _x} count units _grp) > 0) ) then { // group found, assign unit to some group, may be not original one
						[_shell_unit] join _grp;
						if (_origGrp != _grp) then {
			    			if (_debug ) then { player globalChat format["+++ sabotage.sqf: bomberman joined to the same group (%1 men, %2 m.) of his side ", {alive _x} count units _grp, round(_shell_unit distance (units _grp_ select 0))] };
#ifdef __PRINT__
		    				hint localize format["+++ sabotage.sqf: bomberman joined to the same group (%1 men, %2 m.) of his side ", {alive _x} count units _grp, round(_shell_unit distance (units _grp_ select 0))];
#endif	
						}
						else {
    						if (_debug ) then { player globalChat format["+++ sabotage.sqf: bomberman joined to other group (%1 men, %2 m.) of his side ", {alive _x} count units _grp, round(_shell_unit distance (units _grp_ select 0)) ] };
#ifdef __PRINT__
	    					hint localize format["+++ sabotage.sqf: bomberman joined to other group (%1 men, %2 m.) of his side ", {alive _x} count units _grp, round(_shell_unit distance (units _grp_ select 0)) ];
#endif

						};
						sleep 0.3;
					} else { // no other group found so put him to his fate.
						if ( !(_shell_unit call SYG_ACEUnitUnconscious) ) then { // unit can move
							// no group found so put unit to its own fate
							if (_debug ) then {player globalChat "+++ sabotage.sqf: no group found, find some cover for an alone bomberman"};
#ifdef __PRINT__
							hint localize "+++ sabotage.sqf: no group found, find some cover for an alone bomberman";
#endif	
							
							// TODO: send unit to the roof of any suitable building (towers, hangars, air terminal, some houses etc)
							// find enemy to hide from
							_obj = _shell_unit findNearestEnemy (position _shell_unit);
							if ( (!isNull _obj) && (_obj isKindOf  "CAManBase") ) then  { // no enemies found
							    _obj_pos = position _obj;
#ifdef __PRINT__
    							hint localize format ["+++ sabotage.sqf: found enemy %1(%2) at pos %3", name _obj, typeOf _obj, _obj_pos];
#endif
							} else {
								if ( !isNil "FLAG_BASE" ) then {
									_obj_pos = position FLAG_BASE;
								} else {
									_obj_pos = position _shell_unit;
								};
							};

							_obj = _shell_unit findCover [ position _shell_unit, _obj_pos, 400, 100, _obj_pos ];
							if ( isNull _obj ) then {
                                // todo: find any building and hide to it
                                // find house to hide when min 3 pos in it and not closer then 150 meters
                                // _ngb = [position _shell_unit,3,150] call SYG_nearestGoodHouse;
                                // ... buildingPos _ngb;
#ifdef __PRINT__
    							hint localize "+++ sabotage.sqf: cover not found, use FLAG/factory for it";
#endif
								if ( !isNil "FLAG_BASE" ) then {
									_obj = FLAG_BASE;
								} else {
									_obj = _no select 0;
								};
							};
							_shell_unit setSpeedMode "FULL";
							_shell_unit moveTo position _obj;
#ifdef __PRINT__
							hint localize "+++ sabotage.sqf: unit is moving to cover";
#endif
							waitUntil {	sleep 1.111; (unitReady _shell_unit) or (moveToFailed _shell_unit) or (!canStand _shell_unit) or (!alive _shell_unit) };
#ifdef __PRINT__
							hint localize "+++ sabotage.sqf: unit completed move to cover";
#endif
							_shell_unit setBehaviour "STEALTH";
							_shell_unit setCombatMode "YELLOW";
						} else { // do nothing as unit is nearly death
#ifdef __PRINT__
							hint localize "+++ sabotage.sqf: (!canStand unit && isNull group) so exit script";
#endif	
						};
						_continue = false; // exit script ASAP as this was last unit in group
					};
				} /* if ( alive _shell_unit) then */ else {
					_continue = false; // exit script as unit is dead
				}; // if ( alive _shell_unit) then
			} /* if ( !(isNull _shell_unit))  then */ else  { // no unit with bomb found, so exit now
			    // TODO: try to find bomb on dead bodies or somewhere else (MHQ, ammotrack, ammo boxes, rucksack[s] etc)
				if (_debug ) then { player globalChat format["--- sabotage.sqf: Group (%1 men) has no more bombs, exiting", count units _grp]; };
#ifdef __PRINT__
				hint localize format["--- sabotage.sqf: Group (%1 men) has no more bombs, exiting", count units _grp];
#endif	
				_continue = false; // exit as no more bombs/men found
			};
			sleep random (DELAY_BETWEEN_BOMBS + DELAY_BETWEEN_BOMBS); // wait before send other man to bomb place
		}; // while { ( ((position _obj) select 2) > -10.0) and (!(isNull _grp)) and  _continue }
	} /* if ( _obj_pos >= 0 ) then */ else {
		if ( _debug ) then {player globalChat "--- sabotage.sqf: No alive factories, script is sleeping for 2-3 minutes"};
#ifdef __PRINT__
		if (alive _leader ) then {
		    _msg1 = [_leader, "%1 m. to %2 from %3"] call SYG_MsgOnPosE;
		    if ( _msg1 != _msgPrev) then {
    			hint localize format["--- sabotage.sqf: No alive factories, <group[%2] is at %1>, script is sleeping for 2-3 minutes", _msg1, count units _grp];
    			_msgPrev = _msg1;
		    };
		} else {
			hint localize format["--- sabotage.sqf: No alive factories, <group(%1) leader is absent>, script is sleeping for 2-3 minutes",count units _grp];
		};
#endif	
	};

    //
	// check campfire state near leader
	//
	_leader = _grp call SYG_getLeader;
	if ( alive _leader ) then {
          _no = nearestObjects [_leader, ["Fire","FireLit"], FIRE_DISTANCE_TO_LIT];
          {
            if (typeOf _x == "Fire") then {
                // light this campfire
                _x call _replaceFire;
            } else {
#ifdef __PRINT_FIRE__
                hint localize format["+++ sabotage.sqf: Update FireLit at %1", getPos _x];
#endif
            };
            _x setVariable ["fire_off_time", time + FIRE_CHOKE_DELAY];
          } forEach _no;
	};
	if ( !_continue) exitWith { _no = nil;};

	sleep (120 + (random 60)); // interval to attack other  factories
	if (X_MP) then { if ((call XPlayersNumber) == 0) then {waitUntil { sleep 15; (call XPlayersNumber) > 0 }; } };

    _grp call _delUnitsInWater; // just in case

}; // while { (({ (alive _x) and ( canMove _x	)} count units _grp) > 0) && _continue }

//group is dead, try to remove it from he list
if ( !isNil "d_on_base_groups") then {
    if (count d_on_base_groups > 0) then {
        for "_i" from 0 to (count d_on_base_groups) - 1 do {
            _grp = d_on_base_groups select _i;
            if ( ({alive _x} count (units _grp))  == 0 ) then  { // group is dead, remove it from list
                d_on_base_groups set [_i, "RM_ME"];
            };
        };
    };
    d_on_base_groups call SYG_clearArrayB;
};

if ( _debug ) then
	{player globalChat format["--- sabotage.sqf: --- Exiting sabotage group script, d_on_base_groups %1 ---",d_on_base_groups]};
#ifdef __PRINT__
        _list = [];
        { _list set [count _list, {alive _x} count units _x ]} forEach d_on_base_groups;
    	hint localize format["--- sabotage.sqf: --- Exiting sabotage group script, d_on_base_groups %1 ---",_list];
		_list = nil;
#endif

if (true) exitWith {
    // supress any campfire lit too long time
    {
#ifndef __TT__
        _pos = getPos FLAG_BASE;
#else
        _pos = getPos (if (d_own_side == "WEST") then { WFLAG_BASE } else { RFLAG_BASE  });
#endif

        _no = nearestObjects [_pos, ["FireLit"], SEARCH_OTHER_GROUP_DIST];
        if (count _no > 0 ) then {
#ifdef __PRINT__
           if (count d_on_base_groups == 0) then {
               hint localize format["+++ sabotage.sqf: --- Exiting sabotage, all groups are dead, finishing %1 campfire[s]", count _no];
           };
#endif
            {
                sleep (30 + (random 60));
                if (count d_on_base_groups == 0) then {
                    _x call _replaceFire;
                }
                else {
                    _time = _x getVariable "fire_off_time";
                    if (!isNil "_time") then {
                        if ( _time <= time ) then {
                            sleep random 20;
                            _x  call _replaceFire;
                        };
                    };
                };
            }forEach _no;
        };
    } forEach d_base_patrol_fires_array;
};
