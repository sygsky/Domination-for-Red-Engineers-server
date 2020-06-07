// ==================================================================================================================
//                                                    - Bomb-Drop Script -
//
// v 2.1.6 by 'RedSky84' (c-master@freenet.de)
//
//
// Overview:
//
// Given AI-Unit drops one PipeBomb on each given location. Then moves to RetreatPosition and waits for
// touch-off-command.
//
// Does not affect human players!!
//
// V 2.1.4 changes: Behaviour becomes altered near bomb place and restored if far away
// V 2.1.5 changes: NEW optional Debug-Param
//                  Bugfix -> moveToCompleted not working
//                  Bugfix -> missing "_error" check for satchel counting
// V 2.1.6 changes: Magically move pipebomb to exact desired location
//
// ------------------------------------------------------------------------------------------------------------------
// Usage:
//
// in init.sqf:
// FuncUnitDropPipeBomb = compile preprocessFile "unitDropPipeBombV2.sqf";
//
// Executing:
// DropHandle_X = ([Unit, [pos1ToDrop, Pos2ToDrop, ...], positionToRetreat, false, bombName, true] spawn FuncUnitDropPipeBomb);
//
// Input: 
// 0: Bombing Unit
// 1: Array of Objects (Tank, Car, Helicopter, Invisible H)... (I prefer the 'invisible H')!
// 2: Retreat position(by Sygsky)!!!
// 3: Optional: bool (debug) default false
// 4: Optional: pipebomb name, e.g. "ACE_PipeBomb", , may be skipped with empty string "" value to use default value "PipeBomb"
// 5: Optional: unit name to use in messages and variable names, may be skipped with empty string "" value
// 6: Optional: bool, if true (default) bomb is moved to target center before blast, if false is blasted as is
//
// Output:
// Not really
//
// Script must not be called again if not finished!
// ==================================================================================================================


//#define __DEBUG__

#ifdef __DEBUG__
	hint localize "================================= DropPipeBomb Script ===========================";
#endif

#define SAFE_DIST_TO_BOMB 35
#define ELAPSED_TIME (round(time-_startTime))

// ----------
// Init:

private ["_error", "_unit", "_dropArr", "_pos2Retreat", "_debug", "_pbname", "_dropItemPosIdx", "_dropArrCount", "_unitname",
    "_bomb2center", "_prevBehaviour", "_pipeBombCount", "_dropItemPos", "_distToBombPlace", "_moveRetryCount", "_arr",
    "_placedBomb", "_dropRealPos", "_distToRetreatPlace", "_cnt", "_dir","_prev_pos", "_i", "_val","_startTime", "_PBNAME_"];

if (isNil "m_PIPEBOMBNAME" ) then
{
	_PBNAME_ = "PipeBomb"; // default name for a pipebomb
}
else
{
	_PBNAME_ = m_PIPEBOMBNAME; // default name for a pipebomb (in ACE it can be "ACE_PipeBomb", for example!)
};

_unit	 	 = _this select 0;

if ( !(alive _unit && canStand _unit0) ) exitWith
{
#ifdef __DEBUG__
	hint localize format["DropScript: unit is bad (%1), exiting",_unit];
#endif
};

_startTime = time;

_dropArr	 = _this select 1;	// ARRAY!!!
_pos2Retreat = _this select 2;

//-------------
// optional parameters checking

//-------------
// Optional debug param:
_debug		= false;
if ((count _this) > 3) then
{
    _debug  = _this select 3;
    //hint format["DropScript: DEBUG is %1", _debug];
};

// Optional bombname:
_pbname = _PBNAME_;
if ((count _this) > 4) then
{
	if ( ! ((_this select 4 ) == "") )  then
	{
		_pbname  = _this select 4;
	};
};

_error		= false;
_dropItemPosIdx		= 0;
_dropArrCount		= count _dropArr;

if (isNil "callIndex" ) then
{
	callIndex = 0;
}
else{ callIndex = callIndex + 1; };

// Optional bomberman name:
_unitname = format["bomber_%1", callIndex];
if ((count _this) > 5) then
{
	if ( (_this select 5 ) != "" )  then
	{
		_unitname  = _this select 5;
	};
};

// Optional bomb positioning to the center of targer:
_bomb2center = true;
if ((count _this) > 6) then
{
	_bomb2center  = _this select 6;
};

//_unitname =  _unit;
if ( _debug ) then
{
	_unit sideChat (format["DropScript: PipeBomb name %1, internal unit name %2", _pbname, _unitname]);
};

_prevBehaviour	= "NONE";

// ----------
// Checks:

// Check if we are human player. If yes, exit.
if (isPlayer _unit) then
{
    // No Message, silently go to end of function
    if (_debug) then 
	{
		//hint "DropScript: Unit is player. Leaving bombDropScript!";
		player sideChat "DropScript: Unit is player. Leaving bombDropScript!";
	};
    _error = true;
};

// Check if we have enough pipeBombs to put on each desired location:
if (!_error) then 
{

    // OLD: not count any pipebomb if ACE used >>>>_pipeBombCount = {_x == _PBNAME} count magazines _unit;
	
	_pipeBombCount =  if(_pbname in (magazines _unit)) then {1} else { 0};
    // OLD: RETURNS 1 IF HAVE SOME  >>>>  _pipeBombCount = (_unit ammo "pipebombmuzzle");

    if ( _pipeBombCount < _dropArrCount ) then
    {
        if (_debug) then 
		{
			_unit sideChat format["I don't have enough satchels! Have %1 need %2", _pipeBombCount, _dropArrCount];
		};
        _unit sideChat format["I don't have enough satchels! Have %1 need %2", _pipeBombCount, _dropArrCount];
        _error = true;
    }
    else
    {
        _unit groupChat "Roger";
    };
};

// If something bad happened till here "_error" is true and the other stuff won't be executed:

// -------------------------
// Begin dropping the bombs:

_arr = [];
_dropItemPos = [0,0,0];
// Did we drop all bombs?
scopeName "main";
while { (_dropItemPosIdx < _dropArrCount) and (!_error) } do
{
    // Where to drop the next bomb:
    _dropItemPos 	 = position (_dropArr select _dropItemPosIdx);
	if ( (_dropItemPos select 2) < 0.1) then { _dropItemPos set [2, 0]};
	
	if ( _debug ) then 
	{
		player sideChat format["DropScript: object to drop is %1", typeOf (_dropArr select _dropItemPosIdx)];
	};
	
    _distToBombPlace = 999;
	_prev_pos        = position _unit;
    _moveRetryCount	 = 0;

    // Restore behaviour if it was altered
    if (_prevBehaviour != "NONE") then 
    {
        if (_debug) then 
		{
			player sideChat format["DropScript: prev. behaviour %1, change to NONE, drop index %2", _prevBehaviour, _dropItemPosIdx];
		};
        _unit setBehaviour _prevBehaviour;
        _prevBehaviour = "NONE";
    };

    // Move to this item to drop
    _unit doMove _dropItemPos;
#ifdef __DEBUG__
	hint localize format["DropScript (%1): unit sent to distance %2",ELAPSED_TIME,round(_unit distance _dropItemPos)];
#endif		

	scopeName "exit";
    // Not close enough?
    while { _distToBombPlace > 3 } do
    {
        sleep 1;

        _distToBombPlace = ((getPos _unit) distance (_dropItemPos));
		if ( _distToBombPlace >= SAFE_DIST_TO_BOMB ) then
		{
			_prev_pos = position _unit; // store last remote position to use it in some case later
		};

        // ------
        // Basic move controlling (fail check)

		if ( !canStand _unit ) exitWith 
		{
            if (_debug) then 
			{
				player sideChat "DropScript: unit !canStand :o(";
			};
#ifdef __DEBUG__
			hint localize format["DropScript (%1): unit !canStand :o(",ELAPSED_TIME];
#endif		
			_error = true;
			breakTo "main";
		};
        // Move to target completed? fine! :)
        if (unitReady _unit) exitWith 
        {
            if (_debug) then 
			{
				player sideChat "DropScript: unitReady :o)";
			};
#ifdef __DEBUG__
			hint localize format["DropScript (%2): unitReady, dist to bomb drop point is %1 :o)",_distToBombPlace, ELAPSED_TIME];
#endif		
        };

        // OH-O... Move failed!?!?
        if ( moveToFailed _unit ) then
        {
            if (_debug) then 
			{
				player sideChat "--- DropScript: moveToFailed :o(";
			};
#ifdef __DEBUG__
			hint localize format["--- DropScript (%1): moveToFailed :o(",ELAPSED_TIME];
#endif		

            // Retry 3 times:
            if ( _moveRetryCount < 3 ) then
            {
                _moveRetryCount = _moveRetryCount + 1;
                _unit doMove _dropItemPos;
            }
            else
            {
                // STUPID METHOD TO BREAK OUT OF WHILE. IT DOESN'T WORK FOR ME IN ANY OTHER WAY. ALL PROGRAMMERS MAY HIT ME!! SORRY!!!
                 _unit sideChat format["#### ERROR ####  UNIT %1 moveToFailed 3 times! DROP", _unitname];
                _error = true;
				if (_debug) then 
				{
					player sideChat format["--- DropScript:  UNIT %1 moveToFailed 3 times! DROP", _unitname];
				};
#ifdef __DEBUG__
				hint localize format["--- DropScript (%1):  UNIT moveToFailed 3 times! Exit!!! :o(",ELAPSED_TIME];
#endif		
				breakTo "main";
            };
        };


        // ------
        // Little AI-Pimp: Go careless if near location, to really do the job:

        // Check if we're near. Then -> careless. Store old behaviour
        if ( (_distToBombPlace < 10) and (_prevBehaviour == "NONE") ) then
        {
            _prevBehaviour = behaviour _unit;
            _unit setBehaviour "CARELESS";
            _unit doMove _dropItemPos;

            if (_debug) then 
			{
				player sideChat format["DropScript: distToBombPlace < 10, behaviour set to %1, prev. was %2",behaviour _unit, _prevBehaviour ];
			};
        };
    }; // while { _distToBombPlace > 3 } do

    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // If we are near to bombing position (while breakout):
	_unit groupChat format["Dropping bomb %1 out of %2...", (_dropItemPosIdx + 1), _dropArrCount];
	_unit fire ["pipebombmuzzle", "pipebombmuzzle", _pbname];
	_unit groupChat "Place Charge"; // TODO: say bomb dropped!
	_dropRealPos = getPos _unit;
	//-----------------------------------------------------------------------------------------------------------------

	if (_debug) then 
	{
		player sideChat "DropScript: Bomb placed, searching for bomb[s] dropped";
	};

	// Count up how many bombs we have dropped:
	_dropItemPosIdx = _dropItemPosIdx + 1;

	// Wait 5 seconds (10 step by 0.5. sec) until bomb is dropped:
	_error = true;
	for "_i" from 1 to 10 do
	{ 
		if ( !alive _unit) then
		{ 
#ifdef __DEBUG__
			hint localize format["DropScript (%1): Failure: unit !alive while dropping boms, exit",ELAPSED_TIME];
#endif		
			breakTo "main";
		};
		
		if ( unitReady _unit) exitWith
		{
//#ifdef __DEBUG__ // let check is this occures or not at all
			hint localize format["DropScript (%1): Success: unit ready after bomb drop",ELAPSED_TIME];
//#endif
			_error = false;
		};
		sleep 0.5; 
	};
	
#ifdef __DEBUG__
	if (_error) exitWith
	{
		hint localize format["DropScript (%1): Failure: unit time-out while dropping bomb!!! Exit from main loop",ELAPSED_TIME];
	};
#endif		
	
	// V 2.1.6 new: magically move the bomb to its exact desired location:
	sleep 2; // SLEEP IS IMPORTANT TO FIND THE BOMB!\
	_arr = nearestObjects [ _unit, [], 25];
	_cnt = count _arr;
	if ( _cnt > 0 ) then
	{
		for "_i" from 0 to ( (count _arr) - 1) do
		{
			_obj = _arr select _i;
//			if ( !((typeOf _obj) in ["PipeBomb","ACE_PipeBomb"]) )  then { _arr set [_i, "RM_ME"] };
			if ( !(_obj isKindOf "PipeBomb") )  then { _arr set [_i, "RM_ME"] };
		};
		_arr = _arr - ["RM_ME"]; // remove all non-bomb objects
		sleep 0.01;
	};		

	if ( (count _arr == 0)  ) exitWith 
	{
		_error = true;
#ifdef __DEBUG__
		hint localize format["DropScript (%1): Failure: no one bomb from %2 found objects found around goal. Exiting script",ELAPSED_TIME, _cnt];
#endif		
	};

	if ( _bomb2center ) then 
	{
		_pipeBombCount = count _arr;
		if (_debug) then
		{
			player sideChat (format["DropScript: %1 pipeBombs are placed to center", _pipeBombCount ]); // have to understand it works or not
		};
		
		{
			_x setPos _dropItemPos;
		} forEach _arr;
		_dropRealPos = _dropItemPos;
//#ifdef __DEBUG__
			hint localize format["DropScript (%2): %1 pipeBombs are placed to center", _pipeBombCount, ELAPSED_TIME ]; // have to understand it works or not
//#endif
	}
	else 
	{	
#ifdef __DEBUG__
		hint localize format["DropScript (%2): PipeBomb placed at dist %1 m. from targeted point", _dropRealPos distance _dropItemPos, ELAPSED_TIME ];
#endif		
	};
	sleep 0.3;
}; // scopeName "main"; while { (_dropItemPosIdx < _dropArrCount) and (!_error) } do {...};


// ---------------------------------------
// All bombs dropped/skipped. Return to original position retreatPos

if ( alive _unit ) then
{
    _moveRetryCount	= 0;

	//+++ Sygsky: added Set Timer action to blast in any case as unit can be killed after bomb dropping
	if (alive _unit) then
	{

	    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		{ _unit action["StartTimer", _unit, _x]; } forEach _arr;
		//--------------------------------------------------------------------------------------------------------------

#ifdef __DEBUG__
			hint localize format["DropScript (%2): Timer is started for %1 bomb[s] near targeted point. Returning unit to the home",count _arr, ELAPSED_TIME];
#endif		
		if (_debug) then  {	player sideChat format["DropScript: Timer is started for %1 bomb[s]",count _arr] };
		// Move him out
		if (!canStand _unit) exitWith {_error = false};

        _unit doMove /*position*/ _pos2Retreat;
        if (_debug) then
        {
            player sideChat "DropScript: Unit is returning to original pos";
        };

		// Let unit walk a bit in careless mode:
		Sleep 2; // was 3 

	}
	else
	{
		_error = true;
		if (_debug) then 
		{
			player sideChat "DropScript: Timer NOT started as unit is dead";
		};
#ifdef __DEBUG__
		hint localize format[ "DropScript (%1): Timer NOT started as unit is dead", ELAPSED_TIME ];
#endif		
	};
};

// Restore behaviour
if ( (alive _unit) && (_prevBehaviour != "NONE") ) then
{
    _unit setBehaviour _prevBehaviour;
    _prevBehaviour = "NONE";
};

_distToRetreatPlace 	= 999;
_cnt = 0;

//while { (_distToRetreatPlace > 3) and !(_error) } do

// try to move out at distance >= SAFE_DIST_TO_BOMB meters in 20 second. Bomb will blast in 30 seconds
while { ( ( (getPos _unit) distance _dropRealPos) < SAFE_DIST_TO_BOMB ) && ! _error   && ( _cnt < 20 ) } do
{
	if ( !canStand _unit ) exitWith {_error = true};
	
    sleep 1;

    _distToRetreatPlace = (getPos _unit) distance _pos2Retreat; //_dropItemPos

    // ------
    // Basic move controlling (failcheck)

    // Move to return place completed? fine! :)
    if (unitReady _unit) exitWith
    {
		_unit sideChat "Roger";
        if (_debug) then 
		{
			player sideChat format["DropScript: unitReady ( dist from bomb is %1 m, to retreat place %2)", (getPos _unit) distance _dropRealPos, _distToRetreatPlace ];
		};
#ifdef __DEBUG__
		hint localize format["DropScript (%3): unitReady. Dist to bomb is %1 m, dist to retreat place %2 m", (getPos _unit) distance _dropRealPos, _distToRetreatPlace, ELAPSED_TIME ];
#endif		
		if ( ((getPos _unit) distance _dropRealPos) < 15 ) then 
		{ 
			_dir = getDir _unit;
			_unit setPos _prev_pos; 
			_unit setDir _dir;
			sleep 0.2; 
			if (_debug) then { player sideChat format[ "---DropScript: Bomber teleported after being stucked at dist %2 m to bomb",(getPos _unit) distance _dropRealPos ] };
#ifdef __DEBUG__
			hint localize format[ "---DropScript (%2): Bomber teleported  to dist %1 m. from bomb after being stucked",(getPos _unit) distance _dropRealPos,ELAPSED_TIME ];
#endif		
		}; //help unit with teleporting him to somу previous position
    };

    // OH-O... Move failed!?!?
    if ( moveToFailed _unit ) then
    {
        if (_debug) then 
		{
			player sideChat format["---DropScript: Movement failed by moveToFailed, dist to group  %1 m. ", _distToRetreatPlace ];
		};
        // Retry 3 times:
        if ( _moveRetryCount < 3 ) then
        {
            _moveRetryCount = _moveRetryCount + 1;
            _unit doMove _pos2Retreat;
        }
        else
        {
            // SAME STUPID SHIT HERE:
            if ( true ) exitWith 
            {
                _unit sideChat format["#### ERROR ####  UNIT %1 moveToFailed 3 times! RETREAT", _unitname];
                _error = true
            };
        };
    };

    // ------
    // Little AI-Pimp: Switch to aware (no stealth anymore) if near location:
    // This causes the AI to get to the retreat location a bit faster.

    // Check if we're far enough from bomb place.
//    if ( _distToRetreatPlace < 15 ) then
    if ( ( _unit distance _dropRealPos) < SAFE_DIST_TO_BOMB ) then
    {
        // Store prev behaviour and set new one.
        if (_prevBehaviour == "NONE") then
        {
            _prevBehaviour = behaviour _unit;
            _unit setBehaviour "AWARE";
			if (_debug) then 
			{
				player sideChat "DropScript: Unit behaviour set to AWARE";
			};
        };
    };
	_cnt = _cnt + 1;
};

if ( ((getPos _unit) distance _dropItemPos) < SAFE_DIST_TO_BOMB ) then 
{ 
	if (_debug) then { player sideChat format["---DropScript: Bomber teleported at dist %1 after being stucked ", _unit distance _prev_pos ]};
#ifdef __DEBUG__
	hint localize format[ "---DropScript (%2): Bomber teleported after being stucked at dist %1 m to bomb", _unit distance _prev_pos,ELAPSED_TIME ];
#endif		
	_dir = getDir _unit;
	_unit setPos _prev_pos; 
	_unit setDir _dir;
	sleep 0.2; 
}; //help unit with teleporting him to somу previous position

// ----------------------------------------------------------------------------
// Evacuated successfully

if (_debug) then 
{
	player sideChat format["DropScript: EXIT, error = %1", _error];
};

Sleep 1;

// Return:
if (_error) then {false} else {true};