// scripts\jail.sqf
// By sygsky: Remastered jail from Evolution
// no special input parameters except ["TEST"] for testing purposes.
// Call on client only,
/*
	author: Sygsky
	description:
        Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
        target (_this select 0): Object - the object which the action is assigned to
        caller (_this select 1): Object - the unit that activated the action
        ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
        arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
	returns: nothing
*/

//#define __JAIL_DEBUG__

hint localize "+++ JAIL SCRIPT called +++";

if ( isServer && !X_SPE ) exitWith {"--- jail called on server, exit!"};

#define JAIL_START_PERIOD 60

#define FADE_OUT_DURATION 0.3
#define FADE_IN_DURATION 6

scopeName "main";

//===================================== FIND AND PREPARE PLAYER =========================
if ( !alive player ) then {
    waitUntil {
        sleep 0.05;
        if  (isNull player) then  {  breakOut "main"; }; // if not alive, exit
        if (dialog) then {breakOut "main"}; // if in dialog, exit
        alive player
    };
};

#include "x_setup.sqf"
#include "x_macros.sqf"

_test = false; // defines if this is test call or real one
if ( typeName _this == "ARRAY") then {
    if ( count _this > 3) then { // test call from test action at flag
        _test = (typeName (_this select 3) == "STRING") && ((_this select 3) == "TEST");
    };
};
_playerPos = getPos player;
_playerDir = getDir player;

//============================================ INIT JAIL PLACES ===========================
if (isNil "jail_places") then {
    jail_buildings = [[10270.2,7384.86,8.01088],[8274.52,9045.37,7.85906],[7610.99,6363.07,7.86087]]; // all 3 Sahrani hotels model center coordinates
    // jail rooms, array items: [offset point for jail position, jail pos dir, hotel search point]
    jail_places = [
        [[-5.26367,-6.39551,-7.74754],0], // behind the logotype of the hotel
        [[-2.8457,2.97168,-7.73003],-270] // in the lift cabine
    ];
};

// ============================= FIND ALIVE HOTEL ===========================

// check hotel to be alive
_hotel = objNull;
_hotel_pos = [];
for "_i" from 0 to count jail_buildings -1 do {
    //_id = jail_buildings call  XfRandomFloorArray;
    _hotel_pos = jail_buildings select _i;
    _hotel = _hotel_pos nearestObject "Land_Hotel";
    if (  !isNull _hotel) exitWith {};
    jail_buildings set [_i, "RM_ME"];
};

jail_buildings = jail_buildings - ["RM_ME"];

if (isNull _hotel) exitWith {
#ifdef __JAIL_DEBUG__
    hint localize format["--- jail.sqf: No jail buildings found, remained pos array %1", jail_buildings];
#endif
	["log2server", name player, "--- jail building not found"] call XSendNetStartScriptServer;
};

//hint localize format[ "jail: %1", _jailArr ];

// select pos to jail
_jailArr = jail_places call XfRandomArrayVal;
_jailArr set [2, _hotel_pos]; // set hotel position

//hint localize format[ "jail: hotel %1", _hotel ];

//=================================== START JAIL PROCEDURE =====================
disableUserInput true;
player setDamage 0;
player setVelocity [0,0,0];
player playMove "AmovPercMstpSnonWnonDnon"; // stand up!

_score = -((score player)-JAIL_START_PERIOD);

_wpn = weapons player;
_mags = magazines player;
if (!_test) then {
    removeAllWeapons player; // TODO: remove ACE backpack too
#ifdef __ACE__
    player setVariable ["ACE_weapononback",nil];
    player setVariable ["ACE_Ruckmagazines", nil];
#endif
};

//======================================= PLAY WITH VISIBILITY AND AUDIBILITY ============================
playSound "FlashbangRing";
FADE_OUT_DURATION fadeSound (0.2); // stun him

cutText["","WHITE OUT",FADE_OUT_DURATION];  // blind him fast
sleep FADE_OUT_DURATION; // wait until blindness on

FADE_IN_DURATION fadeSound 1; // smoothly restore hearing

_pos = [_hotel, player, _jailArr] call SYG_setObjectInHousePos; // move player to the position in the jail
_new_pos = [_hotel, _jailArr select 0 ] call SYG_modelObjectToWorld;
_cam = "camera" camCreate getPos player;
player switchCamera "INTERNAL";
_cam camPreload 0;
waitUntil {camPreloaded _cam};
showCinemaBorder true;

//preloadCamera _new_pos;// prepare environment for player first glance

//(call _rnd_port_msg) spawn {sleep 1; _this call GRU_msg2player;}; // self-feeling rnd message
sleep (FADE_IN_DURATION/2);
cutText["","WHITE IN",FADE_IN_DURATION]; // restore vision

_weaponHolderPos = player modelToWorld [0, 2.5, 0.2]; // put weapon holder before the players

//player globalChat format["holder %1", _weaponHolderPos];

_weaponHolder = "WeaponHolder" createVehicleLocal [0,0,0];
_weaponHolder setPos _weaponHolderPos;// [_weaponHolderPos, [], 0, "CAN_COLLIDE"];
{
    _weaponHolder addWeaponCargo [_x,1];
} forEach _wpn;
_weaponHolder addWeaponCargo ["Phone",1];

{
    _weaponHolder addMagazineCargo [_x,1];
} forEach _mags;
sleep 0.05;
_cam camSetTarget _weaponHolder;
_cam camCommit 0.5;
waitUntil { camCommitted _cam };
player doWatch _weaponHolder;

#ifdef __JAIL_DEBUG__
_str = format["+++jail.sqf: pos %1, hld %2, model %3", getPos player, getPos _weaponHolder, player worldToModel (getPos _weaponHolder)];
//player groupChat _str;
hint localize _str;
#endif
["log2server", name player, format["+++ jail process started for %1 seconds", _score]] call XSendNetStartScriptServer;

//if (bancount > 2) exitWith {hint "press Alt + F4 to exit"};

_msg_arr = [
   localize "STR_JAIL_1",//"Hint: You have been punished for having a negitive score",
   format[localize "STR_JAIL_2",_score], //format["You will regain control after you have served your sentence of %1 seconds",
   localize "STR_JAIL_3"//"Or you can press  Alt + F4 to exit"
];

//================================= select sound for this day

_sound_arr = ["countdown","countdown10","countdown_alarm"];
_soundName =  _sound_arr select ((date select 2) mod (count _sound_arr));
#ifdef __JAIL_DEBUG__
hint localize format[ "jail.sqf: %1 sound selected at %2, in jail count %3", _soundName, date, _score ];
#endif

player say _soundName;
_sound = nearestObject [player, "#soundonvehicle"];
waitUntil {_sound = (getPos player) nearestObject "#soundonvehicle";!isNull _sound };
//if (isNull _sound) then {hint localize "--- jail.sqf: No initial sound object detected!"};

for "_i" from 0 to (_score - 1) do {
    if ( (_i mod 10) == 0 ) then {
        _id = (floor(_i / 10)) mod (count _msg_arr);
        //player groupChat format["Prepare sound with _i = %1",_i];
        cutText [_msg_arr select _id, "PLAIN"];
    };

    titleText [format ["%1",_i - _score],"PLAIN DOWN"];

	{
	    sleep 0.25;
        if ((isNull _sound) && (alive player)) then {
            player say _soundName;

            waitUntil {_sound = (getPos player) nearestObject "#soundonvehicle";!isNull _sound };
        };
	} forEach [1,2,3,4];
};

titleText ["", "PLAIN DOWN"];
cutText ["", "PLAIN"];

//if (!_test) then { player addScore 1; player setDamage 1;};

if (!isNull _sound) then  {deleteVehicle _sound;};
showCinemaBorder false;
camDestroy _cam;

player doWatch objNull;
player setDir _playerDir;
player setPos _playerPos;

disableUserInput false;
disableUserInput true;
disableUserInput false;

deleteVehicle _weaponHolder;

/*
[] spawn {
	sleep 15;
  	cutText [localize "STR_JAIL_4", "PLAIN"]; // "Don't be in a hurry to spoil military property!"
};
*/