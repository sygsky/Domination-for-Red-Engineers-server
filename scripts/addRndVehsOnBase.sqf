/*
	scripts\addRndVehsOnBase.sqf
	author: Sygsky
	description: Adds some vehicles on base at game start. Vehicles are not recoverable and wilд be removed from map on kill
	returns: nothing
*/
#include "x_setup.sqf"

// #define __DEBUG__

#ifdef __DEFAULT__
// positions for Camel only, not use it for BMP
_camelPosArr = [[+9428,9749,0], [11079,9844,0], [9721,9849,0], [9222,10346], [+9767,9962,0], [+9804,9956,0], [+9842,9954,0]]; // Camel positions
_camelDirArr = [           225,              0,            90,          180,              0,              0,              0];  // Camel directions
_landPosArr  = [ [9439.2,9800.7,0], [10254.87,10062,0], [10503,10090,0], [9153,10045,0], [9064,10036,0] ]; // cars (land) vehicles positions
_landDirArr  = [               180,               180,                0,              0,           350  ]; // cars (land) vehicles directions
_landTypeArr = [ "ACE_BRDM2", "ACE_BMP1_D", "ACE_UAZ", "ACE_UAZ_MG", "ACE_UAZ_AGS30", "ACE_BRDM2_ATGM", "ACE_BRDM2_SA9"  ];
#endif

#ifdef __MULTI_ISLAND_WORLD__

#endif

#define __LAND_VEH_NUM__ 2 // how many vehicle create on the base in init procedure

#ifdef __LAND_VEH_NUM__

for "_i" from 1 to (count _landTypeArr) - __LAND_VEH_NUM__ do { [_landTypeArr, _landTypeArr call XfRandomFloorArray] call SYG_removeFromArrayByIndex; };

#endif

//hint localize format["+++ addRndVehsOnBase.sqf: added %1", _landTypeArr];

{   // start loop for vehicle creation
    // parameters:
    // 0: position or array of positions
    // 1: type or array of types
    // 2: direction or array of directions for each position (see parameter 0)
    // 3: vector (for setVectorUp)
    // 4: probability to create
    // 5: fuel volume
    // 6: remove magazines (true) or not (false)
    _prob = if (count _x > 4) then { _x select 4 } else { 1 }; // probability to create
    if ( (random 1) < _prob ) then {
        _type = _x select 1; //+++ get type
        if ((typeName _type) == "ARRAY") then {   // get random type from array
        	_ind = _type call XfRandomFloorArray;
         	_type = _type select _ind;
         	_arr = _x select 1;
         	[_arr, _ind] call SYG_removeFromArrayByIndex;
        };
        _veh = createVehicle [_type, [0,0,0], [], 0, "NONE"];
#ifdef __DEBUG__
        if (_type == "ACE_BRDM2") then {
        	_veh setVariable ["RECOVERABLE", true];
        	sleep 0.05;
   			hint localize format["+++ addRndVehsOnBase.sqf: %1 on recovery service, var ""RECOVERABLE"" == %2", typeOf _veh, _veh getVariable "RECOVERABLE"];
        };
#endif
		//++++++++++++++++++++++++++++++++++++++++++++++
        [_veh,-5] call SYG_addEventsAndDispose; // dispose these vehicles along with the enemy ones. No smoke and -5 points on AI killing
		//++++++++++++++++++++++++++++++++++++++++++++++

        //+++ get position
        _pos = _x select 0;
        _ind = -1;
        if ((typeName (_pos select 0)) == "ARRAY") then { // select random pos from many
            _ind = floor (random (count _pos)); // random index
            _pos = _pos select _ind;  // select random pos in array
            _arr =  _x select 0; // remove selected positions
         	[_arr, _ind] call SYG_removeFromArrayByIndex;
//            _arr set [_ind, "RM_ME"];
//            _arr call SYG_clearArrayB; // remove "RM_ME" item from the array of positions
        };

        //+++ get and set dir
        _dir = _x select 2;
        if (typeName _dir == "ARRAY") then {
            if ( count _dir <= _ind) then { _dir = 0;}
            else {_dir = _dir select _ind}; // get special direction for each separate position
            // remove selected direction
            _arr =  _x select 2;
         	[_arr, _ind] call SYG_removeFromArrayByIndex;
//            _arr set [_ind, "RM_ME"];
//            _arr call SYG_clearArrayB; // remove "RM_ME" item from the array of directions
        };
        _veh setDir (_dir);

        _veh setPos (_pos);         //+++ set position
        sleep 2;
        _veh setDamage 0.8;        //+++ set damage

        //+++ get and set fuel
        _fuel = if (count _x > 5) then {_x select 5} else {0};
        _veh setFuel _fuel;

        //+++ remove magazines  or not
        _no_mags = if (count _x > 6) then {_x select 6} else {true};
        if (_no_mags) then { {_veh removeMagazine _x} forEach magazines _veh};

        // set vector up
        _veh setVectorUp (_x select 3);
        hint localize format["+++ addRndVehsOnBase.sqf: vehicle %1 added to base at pos[%2] = %3, dir %4, fuel %5, mags %6, dmg 0.8",
        	_type, _ind, _pos, _dir, _fuel, if (_no_mags) then {"removed"} else {"std"}];
    } else {
        hint localize format["+++ vehicle %1 not added to base due to low probability (%2) ", _x select 1, _prob];
    };
    sleep 1.023;
} forEach [
			// offsets:      0,                  1,            2,      3,     4,    5,    6
			// descr        pos               type            dir,    vUp   prob  fuel  mags
            [       _landPosArr,       _landTypeArr,  _landDirArr, [0,0,-1], 1,      0],
            [       _landPosArr,       _landTypeArr,  _landDirArr, [0,0,-1], 1,      0],
            [      _camelPosArr, ["Camel2","Camel"], _camelDirArr,  [0,0,1], 1,    0.1, false]
          ];
