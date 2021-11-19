// scripts\storeequipment.sqf: by Sygsky
// script to store\restory equipment for player
// Example:
// [...] execVM "scripts\storeequipment.sqf";
//     Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
//       target (_this select 0): Object - the object which the action is assigned to
//       caller (_this select 1): Object - the unit that activated the action
//       ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
//       arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax

//
#include "x_macros.sqf"

if (isServer && ! X_SPE) exitWith{false};  // isDedicated

// comment next line to not create debug messages
//#define __DEBUG__
//#define __PRINT__

#define inc(val) (val=val+1)
#define TIMEOUT(addval) (time+(addval))
#define ROUND0(val) (round(val))
#define ROUND2(val) (floor((val)*100.0)/100.0)
#define ROUND1(val) (floor((val)*10.0)/10.0)

#define arg(num) (_this select(num))
#define argp(arr,num) ((arr)select(num))
#define argopt(num,val) (if((count _this)<=(num))then{val}else{arg(num)})

//
// =======================================================================================
//

// hint localize format["--- scripts/storeequipment.sqf: _this is %1", _this ];

if ( ( typeName (_this select 3) ) != "STRING" ) exitWith {
    hint localize format["--- scripts/storeequipment.sqf: illegal argument ""%1"" found, expected ""S""[tore]", arg(3)];
};

switch (toUpper (_this select 3) ) do {
    case "S": {
        // store equipment
        _equip = if ( ( primaryWeapon player ) == "" ) then { "" }
                    else {
                        player call SYG_getPlayerEquipAsStr
                    };
		_sound = format["armory%1", ceil(random 4)];
		["say_sound", player, _sound] call XSendNetStartScriptClientAll;
        ["d_ad_wp", name player, _equip] call XSendNetStartScriptServer;

        _args = if ( _equip == "" )
                    then  { ["STR_SYS_613"]} // Record is wiped off
                    else {["STR_SYS_611"] }; // Record is stored
        ["msg_to_user", "", [_args]] call SYG_msgToUserParser; // message output
//        hint localize format["--- scripts/storeequipment.sqf: msg is %1", args ];

    };
    case "L": {
        // load equipment
    };
};

if true exitWith{true};
