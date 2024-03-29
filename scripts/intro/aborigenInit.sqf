/*
	scripts\intro\aborigenInit.sqf: called on player client
	author: Sygsky
	description: add all actions and events to the aborigen on player client
	returns: nothing
	TODO:
		Move ammobox creation and re-arming in this file to make it local and fully available!!!
		Create ammobox always on far position from the tent entrance.
		Loading the ammo proc is situated at line 301 , file setupplayer1.sqf: _box = nearestObject [getPos spawn_tent, "ReammoBox"];
*/
#include "x_setup.sqf"

if (isNil "aborigen") exitWith {"--- aborigenInit.sqf: ""aborigen"" var is nil, exit"};
while {!alive aborigen} do {sleep 5};

#define ABORIGEN "ABORIGEN"

#define __DO_SMOKE__

_val = aborigen getVariable ABORIGEN;
if ( !isNil "_val" ) exitWith { hint localize "*** Aborigen alive and already intialized!" };
aborigen setVariable [ABORIGEN, true];

while { (isNull player) || (isNil "SYG_UTILS_COMPILED")} do {sleep 0.2};
hint localize format["+++ aborigenInit.sqf: processed unit %1, pos %2", typeOf aborigen, [aborigen, 10] call SYG_MsgOnPosE0];

// 1. "Ask about boats". 2. "Ask about cars". 3. "Ask about weapons". 4. "Ask about soldiers". 5. "Ask about rumors". 6. "Go with me"

{
	aborigen addAction[ localize format["STR_ABORIGEN_%1", _x], "scripts\intro\SYG_aborigenAction.sqf", _x]; // "STR_ABORIGEN_BOAT", "STR_ABORIGEN_CAR" etc
} forEach ["NAME", "BOAT", "CAR", "AIR", "WEAPON", "MEN", "FAQ", "RUMORS", "GO"];

// Inform about tent  info
["log2server", name player, format["spawn_tent pos %1, alive %2", getPos spawn_tent, alive spawn_tent]] call XSendNetStartScriptServer;

//  Add actions for some objects around the tent
_arr = nearestObjects [spawn_tent, ["CampEast","Land_hlaska","BarrelBase","ReammoBox"], 50];
hint localize format["+++ aborigenInit.sqf: found %1 items to add action 'Inspect': %2", count _arr, _arr call SYG_objArrToTypeStr];
{
	_x addAction [localize "STR_CHECK_ITEM", "scripts\intro\SYG_aborigenAction.sqf", "FAQ"];
} forEach _arr;

["msg_to_user","","STR_ABORIGEN_CREATED", 0,0,true] call SYG_msgToUserParser; // "There's an Aborigen %1 in Antigua"

while { !(player call SYG_pointOnAntigua) } do { sleep 5; }; // While out of Antigua

#ifdef __DO_SMOKE__

//+++++++++++++++++++++++++++++++++++++++++++++
//+++  Drop red smoke grenade near aborigen  +++
//+++++++++++++++++++++++++++++++++++++++++++++

#ifdef __ACE__
_smoke_grenade_type = "ACE_SmokeGrenade_Red";
#endif
#ifndef __ACE__
_smoke_grenade_type = "SmokeShellRed";
#endif

_arr = [aborigen, _smoke_grenade_type, player];
if (local aborigen) then  {
    _arr call SYG_throwSmokeGrenade
} else {
    ["remote_execute", "(_this select 2) call SYG_throwSmokeGrenade", _arr] call XSendNetStartScriptServer;
};

/*
aborigen addMagazine _smoke_grenade_type;
reload aborigen;
aborigen selectWeapon "SmokeShellRedMuzzle";
sleep 0.121;
aborigen doTarget player;

hint localize format["+++ aborigenInit.sqf: aborigen local %1, will try to throw %2, mags %3", local aborigen, _smoke_grenade_type, magazines aborigen];

sleep 1.634;
aborigen fire "SmokeShellRedMuzzle";
sleep 1.437;
aborigen doWatch objNull;

hint localize format["+++ aborigenInit.sqf: aborigen mags after throw %1", magazines aborigen];
*/

#endif

while {((getPos player) select 2) > 5} do { sleep 2}; // while in air
/*
#ifdef __ACE__
			    case "ACE_SmokeGrenade_Red"
#endif
			    case "SmokeShellRed"
#endif
*/
_land_dist = round (player distance aborigen);
if (alive aborigen) then { // show info
    _add = d_ranked_a select 32;
    _msg = if (_land_dist < 10) then {format [localize "STR_ABORIGEN_INFO_0", _add]} else {""}; // " You have been awarded (+%1) for landing close to an Aborigen. Know our crew!!!"
	_arr = ["msg_to_user", "",
		[
			[ "STR_ABORIGEN_INFO", _land_dist,  ([ player, aborigen ] call XfDirToObj) call SYG_getDirNameEng, _msg ],  // "The islander is %1 m away in the %2 direction.%3"
			[ "STR_ABORIGEN_INFO_1" ] // "Find him, question him a few times until you understand everything."
		],	0, 6, false
	];
	if (_land_dist < 10) then {
	    _arr set [count _arr, "good_news"]; // Add success sound if +10 score added for landing near aborigen
	    _add call SYG_addBonusScore;
	}; // Add success sound for landing near aborigen
	_arr spawn SYG_msgToUserParser;
	_say1= "come_again_spa"; _say2 = "local_partisan_spa";
	if (localize "STR_LANG" == "ENGLISH") then { _say1= "come_again_eng"; _say2 = "local_partisan_eng"};
	aborigen say ([ _say1, _say2, "come_again_spa","hey_chico","adios","porque","hola","pamal"] call XfRandomArrayVal);

} else {
	player groupChat (localize "STR_ABORIGEN_INFO_NONE"); // "Locals are not observed"
};

//++++++++++++++++++++++++++ Giggle while not closer than 5 meters +++++++++++++++++++++++++++++++++++
_prevSound = ""; // No sound still
_sound = "";
_delay = 0;
_arr = ["no_way_jose",1,"cantar1",13,"local_partisan_spa",4, "pamal", 3,"porque", 1,"adios", 2]; // Sound array for initial aborigen activity
_cnt = (count _arr) / 2;
while {(alive aborigen) && ((player distance aborigen) > 10) } do {
	aborigen setMimic (["Default","Normal","Smile","Hurt","Ironic","Sad","Cynic","Surprised","Agresive","Angry"] call XfRandomArrayVal);
	// Prevent the same sound from playing twice in a row
	while {_sound == _prevSound} do {
	   _ind = floor(random _cnt) * 2;
	   _sound = _arr select _ind;
	   _delay = _arr select (_ind + 1);
	};
	aborigen say _sound;
	_delay = _delay + ((random 2) + 5);
	hint localize format["+++ aborigenInit.sqf: abo say '%1', prev '%2', delay %3", _sound, _prevSound, _delay ];
	_prevSound = _sound;
	sleep _delay;
	//	aborigen setDir (getDir aborigen) + ((random 20) - 10); // It is not working really
};

#ifdef __DO_SMOKE__
deleteVehicle _grenade;
#endif

// set marker on civ
_marker = "aborigen_marker";
if ((markerType "aborigen_marker") == "") then {
	_marker = createMarkerLocal[_marker, getPosASL aborigen];
	_marker setMarkerTypeLocal  "Vehicle";
	_marker setMarkerColorLocal "ColorGreen";
	if ( (name aborigen) == "Error: No unit") then {
		_marker setMarkerTextLocal ("*");
	} else { _marker setMarkerTextLocal (name aborigen); };

	_marker setMarkerSizeLocal [0.5, 0.5];
};

aborigen setMimic "Normal";
// Do watch while alive or near
aborigen setDir ([aborigen, player] call XfDirToObj);
while { (alive aborigen) && (alive player) && ((player distance aborigen) < 40)} do { sleep 5};
if (alive aborigen) then {
	aborigen spawn {
		private ["_list","_arr","_cnt"];
		_list = [
			"ActsPercMstpSlowWrflDnon_Lolling",  // Stretches, as if the unit has just woken up
			"ActsPercMstpSnonWnonDnon_DancingDuoIvan", // Does various dance moves
			"ActsPercMstpSnonWnonDnon_DancingDuoStefan", // Dances
			"ActsPercMstpSnonWnonDnon_DancingStefan",	// As above
			"TestDance",
			"TestFlipflop",
			"TestJabbaFun",
			"AmovPercMstpSnonWnonDnon_exerciseKata",	//		Martial arts moves
			"AmovPercMstpSnonWnonDnon_exercisePushup",	//	Pushups
			"AmovPercMstpSnonWnonDnon_Ease",	//	"At ease"
			"AmovPercMstpSnonWnonDnon_AmovPsitMstpSnonWnonDnon_ground",	//	Sits on the ground
			"AmovPercMstpSnonWnonDnon",	//	Stand without weapon
			"AmovPercMstpSlowWrflDnon_seeWatch",	//	Checks watch with weapon in other hand
			"AmovPercMstpSlowWrflDnon_AmovPsitMstpSlowWrflDnon"	//	Sits on ground
		];
		//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Dancing
		while { (canStand aborigen) && ((player distance aborigen) > 30)} do {
			_arr = aborigen nearObjects [ "CAManBase", 50];
			_cnt = {(canStand _x) && (isPlayer _x)} count _arr;
			if (_cnt  == 1) then { // only for single player
				if (local aborigen) then {
					aborigen setDir ([aborigen, player] call XfDirToObj);
					aborigen playMove (_list call XfRandomArrayVal);
				} else {
					["remote_execute",
						format["aborigen setDir %1; aborigen playMove ""%2"";",
							[aborigen, player] call XfDirToObj, _list call XfRandomArrayVal
						],
						name player
					] call XSendNetStartScriptServer;
				};
				sleep 10;
			};
			sleep (random 5);
		};
	};
};

while {alive aborigen} do {
	sleep 10;
	_pos = getPosASL aborigen;
	if ( ([getMarkerPos _marker, _pos] call SYG_distance2D) > 10) then {
		_marker setMarkerPosLocal _pos;
	};
};
deleteMarkerLocal _marker;
// exit this humorescue

