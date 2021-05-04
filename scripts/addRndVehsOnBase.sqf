/*
	scripts\addRndVehsOnBase.sqf
	author: Sygsky
	description: Adds some vehicles on base at game start
	returns: nothing
*/

// #define __DEBUG__

// positions for Camel only, not use it for BMP
_camelPosArr = [[9428,9749,0], [9728,9824,0], [9731,9778,0], [9621,9781], [9767,9962,0], [9804,9956,0], [9842,9954,0]]; // Camel positions
_camelDirArr = [          225,             0,             0,         180,             0,             0,            0];  // Camel directions

{ // start loop for vehicle creation
    // parameters:
    // 0: position or array of positions
    // 1: type or array of types
    // 2: direction or array of directions for each position (see parameter 0)
    // 3: vector (for setVectorUp)
    // 4: probability to create
    // 5: fuel volume
    // 6: remove magazines (true) or not (false)
    _prob = if (count _x > 4) then {_x select 4} else {1}; // probability to create
    if ( (random 1) < _prob ) then
    {
        //+++ get type
        _type = _x select 1;
        if ((typeName _type) == "ARRAY") then {
            _type = _type call XfRandomArrayVal;  // get random type if array
        };
        _veh = createVehicle [_type, [0,0,0], [], 0, "NONE"];
#ifdef __DEBUG__
        if (_type == "ACE_BRDM2") then {
        	_veh setVariable ["RECOVERABLE", true];
        	sleep 0.05;
   			hint localize format["+++ addRndVehsOnBase.sqf: %1 on recovery service, var ""RECOVERABLE"" == %2", typeOf _veh, _veh getVariable "RECOVERABLE"];
        };
#endif
        [_veh] call SYG_addEventsAndDispose; // dispose these vehicles along with the enemy ones. No smoke and points

        //+++ get position
        _pos = _x select 0;
        _ind = -1;
        if ((typeName (_pos select 0)) == "ARRAY") then
        {
            _ind = floor (random (count _pos));
            _pos = _pos select _ind;  // select random pos if array
            // remove selected direction
            _arr =  _x select 0;
            _arr set [_ind, "RM_ME"];
            _arr = _arr - ["RM_ME"];
        };
        hint localize format["+++ vehicle %1 added to base at pos[%1] = %3", _type, _ind, _pos];

        //+++ get and set dir
        _dir = _x select 2;
        if (typeName _dir == "ARRAY") then
        {
            if ( count _dir <= _ind) then { _dir = 0;}
            else {_dir = _dir select _ind}; // get special direction for each separate position
            // remove selected direction
            _arr =  _x select 2;
            _arr set [_ind, "RM_ME"];
            _arr = _arr - ["RM_ME"];
        };
        _veh setDir (_dir);

        //+++ set position
        _veh setPos (_pos);

        //+++ set damage
        _veh setDamage 0.8;

        //+++ get and set fuel
        _fuel = if (count _x > 5) then {_x select 5} else {0};
        _veh setFuel _fuel;

        //+++ remove magazines  or not
        _no_mags = if (count _x > 6) then {_x select 6} else {true};
        if (_no_mags) then { {_veh removeMagazine _x} forEach magazines _veh};

        // set vector up
        _veh setVectorUp (_x select 3);
    }
    else
    {
        hint localize format["+++ vehicle %1 not added to base due to low probability", _x select 1];
    };
    sleep 1.023;
} forEach [
            [[9439.2,9800.7,0],"ACE_BRDM2", 180,[0,0,-1], 1, 0],
            [[10254.87,10062,0],"ACE_BMP1_D",180,[0,0,-1], 1, 0],
            [_camelPosArr, ["Camel2","Camel"], _camelDirArr, [0,0,1], 1, 0.1, false]
          ];
