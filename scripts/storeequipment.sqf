// scripts\storeequipment.sqf: by Sygsky
// script to store\restore equipment for player. Run ony on client computers as action command executed
// Example:
// [...] execVM "scripts\storeequipment.sqf";
//     Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
//       target (_this select 0): Object - the object which the action is assigned to
//       caller (_this select 1): Object - the unit that activated the action
//       ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
//       arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
//

if (isServer && ! X_SPE) exitWith{false};  // isDedicated

#include "x_setup.sqf"
#include "x_macros.sqf"

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
if ( ( typeName (_this select 3) ) != "STRING" ) exitWith {
    hint localize format["--- scripts/storeequipment.sqf: illegal argument ""%1"" found, expected ""S""[tore]", arg(3)];
};

switch (toUpper (_this select 3) ) do {
    case "S": {
        // store equipment
//        _equip = if ( (( primaryWeapon player ) == "") && (( secondaryWeapon player ) == "") ) then { "" }  else { player call SYG_getPlayerRucksackAsStr };
        _equip = player call SYG_getPlayerRucksackAsStr;
        ["d_ad_wp", name player, _equip, call SYG_armorySound, FLAG_BASE] call XSendNetStartScriptServer; // sent to the server

#ifdef __EQUIP_OPD_ONLY__

		localize "STR_WPN_TITLE" hintC [
			composeText[ image "img\red_star_64x64.paa",lineBreak, localize "STR_WPN_INFO"],  // "Remembering your armament is now done automatically when you exit the mission!"
			localize "STR_WPN_INFO_1",  // "Your backpack is saved every time you change its contents.
			localize "STR_WPN_INFO_2",	// "Weapons are saved at the moment you exit the mission."
			parseText  ("<t align='center'><t color='#ffff0000'>" + (format[localize "STR_WPN_EXIT",localize "STR_DISP_INT_CONTINUE"])) // "press '%1' to exit from dialog"
		];
		//(localize _str) + "\n\n" + (localize "STR_COMP_0")
#else
        _args = if ( _equip == "" )
                    then { ["STR_SYS_613"] } // "Your recorded equipment wiped"
                    else { ["STR_SYS_611"] }; // "Your equipment is recorded and will be given out next time"
        ["msg_to_user", "", [_args]] spawn SYG_msgToUserParser; // message output
#endif

//        hint localize format["--- scripts/storeequipment.sqf: msg is %1", args ];
    };
    case "L": {
        // load equipment
    };
};

if true exitWith{true};
