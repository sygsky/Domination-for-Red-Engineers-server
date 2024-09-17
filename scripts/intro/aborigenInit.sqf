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

if (isNil "aborigen") exitWith {hint localize "--- aborigenInit.sqf: ""aborigen"" var is nil, exit"};
hint localize format["+++ aborigenInit.sqf: abo (%1alive) = %2", if( alive aborigen) then {""} else {"not "}, aborigen];
while {!alive aborigen} do {sleep 5}; // Wait for aborigen to respawn

#define ABORIGEN "ABORIGEN"

#define __DO_SMOKE__

_val = aborigen getVariable ABORIGEN;
if ( !isNil "_val" ) exitWith { hint localize "*** aborigenInit.sqf: abo alive and already intialized!" };
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

["msg_to_user","",["STR_ABORIGEN_CREATED", name aborigen], 0,0,true] call SYG_msgToUserParser; // "There's an Aborigen %1 in Antigua"

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

//++++++++++++++++++++++++++ Giggle while not closer than 10 meters +++++++++++++++++++++++++++++++++++
_prevSound = ""; // No sound still
_sound = "";
_delay = 0;
_arr = ["no_way_jose",1,"cantar1",13,"local_partisan_spa",4, "pamal", 3,"porque", 1,"adios", 2]; // Sound array for initial aborigen activity
_cnt = (count _arr) / 2;
_time = time + 300;
while { (alive aborigen) && ((player distance aborigen) > 10) && (time < _time)} do {
	aborigen setMimic (["Default","Normal","Smile","Hurt","Ironic","Sad","Cynic","Surprised","Agresive","Angry"] call XfRandomArrayVal); // TODO: This may not work (as abo is server burnt)!!!
	// Prevent the same sound from playing twice in a row
	while {_sound == _prevSound} do {
	   _ind = floor(random _cnt) * 2;
	   _sound = _arr select _ind;
	   _delay = _arr select (_ind + 1);
	};
	aborigen say _sound;
	_delay = _delay + ((random 2) + 5);
	hint localize format["+++ aborigenInit.sqf: abo say '%1', prev '%2', delay %3, time %4", _sound, _prevSound, _delay, round( time - _time ) ];
	_prevSound = _sound;
	sleep _delay;
	//	aborigen setDir (getDir aborigen) + ((random 20) - 10); // It is not working really
};

#ifdef __DO_SMOKE__
deleteVehicle _grenade;
#endif

hint localize "+++ aborigenInit.sqf: player dist <= 10 m, abo marker created";

// set marker on civ
_marker = "aborigen_marker";
if ((markerType _marker) == "") then {
	_marker = createMarkerLocal[_marker, getPosASL aborigen];
	_marker setMarkerTypeLocal  "Vehicle";
	_marker setMarkerColorLocal "ColorGreen";
	if ( (name aborigen) == "Error: No unit") then {
		_marker setMarkerTextLocal ("<?>");
	} else { _marker setMarkerTextLocal (name aborigen); };

	_marker setMarkerSizeLocal [0.5, 0.5];
};

aborigen setMimic "Normal";
// Do watch while alive or near
aborigen setDir ([aborigen, player] call XfDirToObj);
hint localize "+++ aborigenInit.sqf: wait player to be far from aborigen > 40 meters";
while { (alive aborigen) && (alive player) && ((player distance aborigen) < 40)} do { sleep 5};
if (alive aborigen) then {
	aborigen spawn {
		private ["_list","_arr","_cnt","_anim", "_dir", "_dir1"];
		_list = [ // lower case is needed in lower names as so used internally to name animations
			"actspercmstpslowwrfldnon_lolling",  // Stretches, as if the unit has just woken up
			"actspercmstpsnonwnondnon_dancingduoivan", // Does various dance moves
			"actspercmstpsnonwnondnon_dancingduostefan", // Dances
			"actspercmstpsnonwnondnon_dancingstefan",	// As above
			"testdance",
			"testflipflop",
			"testjabbafun",
			"amovpercmstpsnonwnondnon_exercisekata",	//		Martial arts moves
			"amovpercmstpsnonwnondnon_exercisepushup",	//	Pushups
			"amovpercmstpsnonwnondnon_ease",	//	"At ease"
			"amovpercmstpsnonwnondnon_amovpsitmstpsnonwnondnon_ground",	//	Sits on the ground
			"amovpercmstpsnonwnondnon",	//	Stand without weapon
			"amovpercmstpslowwrfldnon_seewatch",	//	Checks watch with weapon in other hand
			"amovpercmstpslowwrfldnon_amovpsitmstpslowwrfldnon"	//	Sits on ground
		];
		_anim_cnt = count _list;
		_list = _list + [
            "amovpsitmstpslowwrfldnon_smoking", //	p	sitting - Sitting, smoking. Used if weapon was lowered before sitting
            "amovpsitmstpsnonwpstdnon_ground", //	p	sitting - Sitting without weapon. (alternate, looks like others)
            "amovpsitmstpsnonwpstdnon_smoking", //	p	sitting - Sitting, smoking (alternate, looks like others)
            "amovpsitmstpsnonwnondnon_ground", //	p	sitting - sitting without weapon (alternate, looks same as others)
            "amovpsitmstpsnonwnondnon_smoking",  // p	sitting - Sitting, smoking (alternate, looks like others)
            "amovpsitmstpslowwrfldnon"  //	p	sitting - default sitting used if weapon was lowered before sitting
		];
		//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Dancing
        _dir = [aborigen, player] call XfDirToObj;
        _state = ""; // "far"/"near"
		while { (alive aborigen) && (base_visit_mission < 1) } do { // Player not visited vase and alive aborigen
//            hint localize format["+++ aborigenInit.sqf: abo animation is ""%1""", animationState aborigen];
		    while {!(canStand aborigen)} do {sleep 5}; // Wait until aborigen can stand
		    if (alive player) then {
		        _cnt = count ([aborigen, 300] call SYG_findNearestPlayers); // Count all players in aborigen vicinity of 1500 m.
		        if ( _cnt > 0 ) then { // Some players in vicinity 300 meters
		            // Check if players not very close to abo
		            _cnt = [aborigen,  50] call SYG_findNearestPlayers;
                    if (_cnt > 0) exitWith { // Some player is too close <= 50 meters
    		            if (_state != "near") then {hint localize "+++ aborigenInit.sqf: some player near abo, start watching"; _state = "near" };
                        aborigen switchMove "AmovPercMstpSnonWnonDnon"; // Stand without weapon
                        sleep 0.1;
                        aborigen doWatch (_arr select 0);
                        sleep 0.9;
                        hint localize format["+++ aborigenInit.sqf: after 1 sec abo anim == ""%1""", animationState aborigen];
                        sleep (2 + (random 2));
                    };
                    // Any player is at distance 50-300 m. from aborigen
		            if (_state != "far") then {hint localize "+++ aborigenInit.sqf: no player near abo, stop watching"; _state = "far" };
		            aborigen doWatch objNull;
    		        while { toLower(animationState aborigen) in _list} do {
//                        hint localize format["+++ aborigenInit.sqf: abo is in listed animation ""%1""", animationState aborigen];
    		            sleep 5;
	    	        };
	    	        if (!alive aborigen) exitWith {};
                    _dir = [aborigen, player] call XfDirToObj;
//                    aborigen setDir _dir;
                    _anim = [_list, _anim_cnt] call XfRandomArrayValPart;
                    if (local aborigen) then {
                        hint localize format["+++ aborigenInit.sqf: abo is local, so set animation to ""%1""", _anim];
                        aborigen playMove _anim;
                        sleep 5;
                    } else {
                        ["remote_execute",
                            format[ "aborigen playMove ""%1"";", _anim ],
                            name player,
                            format[" dist %1 m.", round (aborigen distance player)],
                            format["abo animation ""%1""", animationState aborigen]
                        ] call XSendNetStartScriptServer;
                        sleep 5;
                    };
                };
			} else  { sleep 5 }; // Sleep until alive player
		};
	};
};

hint localize format["+++ aborigenInit.sqf: abo %1alive, marker loop...", if (alive aborigen) then {""} else {"not "}];
while {alive aborigen} do {
	sleep 10;
	_pos = getPosASL aborigen;
	if ( ([getMarkerPos _marker, _pos] call SYG_distance2D) > 10) then {
		_marker setMarkerPosLocal _pos;
	};
};
hint localize format["+++ aborigenInit.sqf: abo dead, exit marker loop"];
deleteMarkerLocal _marker;
// exit this humorescue

