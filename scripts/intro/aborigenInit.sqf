/*
	scripts\intro\aborigenInit.sqf
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

_val = aborigen getVariable ABORIGEN;
if ( !isNil "_val" ) exitWith { hint localize "*** Aborigen alive and already intialized!" };
aborigen setVariable [ABORIGEN, true];

waitUntil {!isNull player};

hint localize format["+++ aborigenInit.sqf: processed unit %1, pos %2", typeOf aborigen, [aborigen, 10] call SYG_MsgOnPosE0];

// TODO: add follow sub-menus to the civilian:
// 1. "Ask about boats". 2. "Ask about cars". 3. "Ask about weapons". 4. "Ask about soldiers". 5. "Ask about rumors"

{
	aborigen addAction[ localize format["STR_ABORIGEN_%1", _x], "scripts\intro\SYG_aborigenAction.sqf", _x]; // "STR_ABORIGEN_BOAT", "STR_ABORIGEN_CAR" etc
} forEach ["NAME", "BOAT", "CAR", "PLANE", "WEAPON", "MEN", "RUMORS","GO"];

while { !(player call SYG_pointOnAntigua) } do { sleep 5; }; // while out of Antigua

while {((getPos player) select 2) > 5} do { sleep 2}; // while in air

if (alive aborigen) then { // show info
	// "STR_ABORIGEN_INFO_1" Syg_parse
	["msg_to_user", "",
		[
			["STR_ABORIGEN_INFO", round (player distance aborigen), [player,aborigen]call XfDirToObj],
			["STR_ABORIGEN_INFO_1"]
		],	0, 6, false,"adios"
	] spawn SYG_msgToUserParser;
	player groupChat format [localize "STR_ABORIGEN_INFO", round (player distance aborigen), ([player,aborigen] call XfDirToObj) call SYG_getDirName]; // "Aborigen is on dist. %1 to %2"
} else {
	player groupChat (localize "STR_ABORIGEN_INFO_NONE"); // "Locals are not observed"
};

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Giggle while not closer than 5 meters
_prevSound = ""; // No sound still
_sound = "";
while {(player distance aborigen) > 5} do {
	sleep (5 + (random 2));
	aborigen setMimic (["Default","Normal","Smile","Hurt","Ironic","Sad","Cynic","Surprised","Agresive","Angry"] call XfRandomArrayVal);

	// Prevent the same sound from playing twice in a row
	while {_sound == _prevSound} do {
	    _sound = format["laughter_%1", (floor (random 12)) + 1]; // laughter_1..12
	};
	aborigen say _sound;
	_prevSound = _sound;
	aborigen setDir (getDir aborigen) + ((random 20) - 10);
};

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
						]
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
	if ( ([getMarkerPos _marker, getPosASL aborigen] call SYG_distance2D) > 10) then {
		_marker setMarkerPosLocal (getPosASL aborigen);
	};
};
deleteMarkerLocal _marker;
// exit this humorescue

